SWEP.PrintName			= "Test SMG"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/c_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"
SWEP.HoldType			= "smg"
SWEP.Base = "basehlcombatweapon_shared_strafe"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFOV = 54

DEFINE_BASECLASS( "basehlcombatweapon_shared_strafe" )

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self.m_flRaiseTime = -3000
end

function SWEP:CanLower()
	if self.Owner:GetViewModel():SelectWeightedSequence( ACT_VM_IDLE_LOWERED ) == ACTIVITY_NOT_AVAILABLE then
		return false
	end
	return true
end

function SWEP:Lower()
	if self:CanLower() then
		self:SetSaveValue( "m_bLowered", true )
		return true
	end
end

function SWEP:Deploy()
	if self.Owner and self.Owner:IsPlayer() then
		if self:IsWeaponLowered() then
			if self:CanLower() then
				self:SetSaveValue( "m_bLowered", true)
				self:SetNextPrimaryFire(CurTime() + 1.0)
				self:SetNextSecondaryFire(CurTime() + 1.0)
				return true
			end
		end
	end
	self:SetSaveValue( "m_bLowered", false )
	return true
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
	if table.HasValue({ACT_VM_IDLE_LOWERED,ACT_VM_IDLE,ACT_VM_IDLE_TO_LOWERED,ACT_VM_LOWERED_TO_IDLE},self:GetSaveTable().m_IdealActivity) then
		if self:GetSaveTable().m_bLowered then
			return true
		end
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
		if !table.HasValue({ACT_VM_IDLE_LOWERED,ACT_VM_IDLE_TO_LOWERED,ACT_TRANSITION},self:GetActivity()) then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		elseif self:HasWeaponIdleTimeElapsed() then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		end
	else
        if CurTime() > self.m_flRaiseTime and self:GetActivity() == ACT_VM_IDLE_LOWERED then
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
	self:SetSaveValue( "m_bLowered", false )
	self.m_flRaiseTime = CurTime() + 0.5
	return true
end