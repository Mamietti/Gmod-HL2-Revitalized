SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true

SWEP.UseHands = true

SWEP.Base = "basecombatweapon_shared_strafe"
DEFINE_BASECLASS( "basecombatweapon_shared_strafe" )

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Bool" , 3 , "Lowered" )
    self:NetworkVar( "Float" , 4 , "RaiseTime" )
end

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetRaiseTime(-3000)
end

function SWEP:CanLower()
	if self.Owner:GetViewModel():SelectWeightedSequence( ACT_VM_IDLE_LOWERED ) == ACTIVITY_NOT_AVAILABLE then
		return false
	end
	return true
end

function SWEP:Lower()
	if self.Owner:GetViewModel():SelectWeightedSequence( ACT_VM_LOWERED_TO_IDLE ) == ACTIVITY_NOT_AVAILABLE then
		return false
	end
    self:SetLowered(true)
    return true
end

function SWEP:Deploy()
	if self.Owner and self.Owner:IsPlayer() then
		if self:IsWeaponLowered() then
			if self.Owner:GetViewModel():SelectWeightedSequence( ACT_VM_LOWERED_TO_IDLE ) != ACTIVITY_NOT_AVAILABLE then
				self:SetLowered(true)
				self:SetNextPrimaryFire(CurTime() + 1.0)
				self:SetNextSecondaryFire(CurTime() + 1.0)
				return true
			end
		end
	end
	self:SetLowered(false)
	return BaseClass.Deploy(self)
end

function SWEP:IsWeaponLowered()
	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * (50 * 12),
		mask = MASK_SHOT,
		filter = self.Owner,
		collisiongroup = COLLISION_GROUP_PLAYER,
	} )
	if tr.HitEntity and !tr.HitWorld then
		ent = tr.HitEntity
		if ent:IsNPC() and ent:GetState() != NPC_STATE_COMBAT then
			if ent:Disposition(self.Owner)==D_LI then
				return true
			end
		end
	end
	return false
end

function SWEP:WeaponShouldBeLowered()
	if self:CanLower() and !table.HasValue({ACT_VM_IDLE_LOWERED,ACT_VM_IDLE,ACT_VM_IDLE_TO_LOWERED,ACT_VM_LOWERED_TO_IDLE}, self:GetSaveTable().m_iIdealActivity) then
		if self:IsWeaponLowered() then
			return true
		end
		if SERVER then
			if game.GetGlobalState("friendly_encounter") == GLOBAL_ON then
				return true
			end
		end
	end
	return false
end

function SWEP:WeaponIdle()
	if self:WeaponShouldBeLowered() then
		if !table.HasValue({ACT_VM_IDLE_LOWERED,ACT_VM_IDLE_TO_LOWERED,ACT_TRANSITION},self:GetActivity()) and self:GetActivity() != self:GetPrimaryAttackActivity() then --HACK: it somehow does not detect the fire anim.
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		elseif self:HasWeaponIdleTimeElapsed() then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		end
	else
        if CurTime() > self:GetRaiseTime() and self:GetActivity() == ACT_VM_IDLE_LOWERED then
            self:SendWeaponAnimIdeal(ACT_VM_IDLE)
        elseif self:HasWeaponIdleTimeElapsed() then
            self:SendWeaponAnimIdeal(ACT_VM_IDLE)
        end
    end
end

function SWEP:Ready()
	if self.Owner:GetViewModel():SelectWeightedSequence( ACT_VM_LOWERED_TO_IDLE ) == ACTIVITY_NOT_AVAILABLE then
		return false
	end
	self:SetLowered(false)
	self:SetRaiseTime(CurTime() + 0.5)
	return true
end

--HACKHACK: Glitchy lowered idle animation
function SWEP:HasWeaponIdleTimeElapsed()
    if self:WeaponShouldBeLowered() then
        if ( CurTime() > self:GetWeaponIdleTime() - 0.1 ) then
            return true
        end
    else
		-- HACK: In multiplayer, if there is no lowered animation on the model 
		-- it might play reload anim twice unless we delay the next idle
        if ( CurTime() > self:GetWeaponIdleTime() + 0.05) then
            return true
        end
    end
	return false
end