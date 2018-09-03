SWEP.PrintName			= "Test SMG"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.UseHands			= true
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_smg_mac10.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "smg"
SWEP.FiresUnderwater = false
SWEP.Base = "weapon_base"
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize		= 18
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

AccessorFunc( SWEP, "fNPCMinBurst", 		"NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst", 		"NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate", 		"NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime", 	"NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime", "NPCMaxRest" )
AccessorFunc( SWEP, "m_flTimeWeaponIdle", "TimeWeaponIdle" )
AccessorFunc( SWEP, "m_flNextEmptySoundTime", "NextEmptySoundTime")
SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = ""
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""

DEFINE_BASECLASS( "weapon_base" )

function SWEP:GetCapabilities()

	return bit.bor( CAP_WEAPON_RANGE_ATTACK1 )

end

function SWEP:WeaponSound(sound)
	self:EmitSound(sound)
end

function SWEP:Initialize()
    self:SetNPCMinBurst( 3 )
    self:SetNPCMaxBurst( 3 )
    self:SetNPCFireRate( 0.05 )
    self:SetNPCMinRest( 0 )
    self:SetNPCMaxRest( 0 )
	self:SetSaveValue("m_fMinRange1",65)
	self:SetSaveValue("m_fMinRange2",65)
	self:SetSaveValue("m_fMaxRange1",1024)
	self:SetSaveValue("m_fMaxRange2",1024)
    self:SetHoldType(self.HoldType)
	self:SetTimeWeaponIdle(CurTime())
	self:SetNextEmptySoundTime(CurTime())
	self.m_nShotsFired = 0
    self.m_flRaiseTime = -3000
end

function SWEP:UsesClipsForAmmo1()
	return self.Primary.ClipSize!=0
end

function SWEP:UsesClipsForAmmo2()
	return self.Secondary.ClipSize!=0
end
function SWEP:IsMeleeWeapon()
	return false
end

function SWEP:HasIdleTimeElapsed()
	if CurTime()>=self:GetTimeWeaponIdle() then
		return true
	end
	return false
end

function SWEP:HasAnyAmmo()
	if !self:UsesPrimaryAmmo() and !self:UsesSecondaryAmmo() then
		return true
	end
	return (self:HasPrimaryAmmo() or self:HasSecondaryAmmo())
end

function SWEP:HasPrimaryAmmo()
	if self:UsesClipsForAmmo1() then
		if self:Clip1()>0 then
			return true
		end
	end
	if self.Owner then
		if self:Ammo1()>0 then
			return true
		end
	end
	return false
end

function SWEP:HasSecondaryAmmo()
	if self:UsesClipsForAmmo2() then
		if self:Clip2()>0 then
			return true
		end
	end
	if self.Owner then
		if self:Ammo2()>0 then
			return true
		end
	end
	return false
end

function SWEP:UsesPrimaryAmmo()
	return (self.Primary.Ammo == "None")
end

function SWEP:UsesSecondaryAmmo()
	return (self.Secondary.Ammo == "None")
end

function SWEP:ReloadOrSwitchWeapons()
	if self.Owner then
		self:SetSaveValue( "m_bFireOnEmpty", false ) 
		if !self:HasAnyAmmo() and (CurTime()>self:GetNextPrimaryFire()) and (CurTime()>self:GetNextSecondaryFire()) then
			return false
		else
			if self:UsesClipsForAmmo1() and self:Clip1()==0 and (CurTime()>self:GetNextPrimaryFire()) and (CurTime()>self:GetNextSecondaryFire()) then
				if self:DoReload() then
					return true
				end
			end
		end
		return false
	end
end

function SWEP:Deploy()
	self:WeaponSound(self.DEPLOY)
	self.m_nShotsFired = 0
	return true
end

function SWEP:GetDrawActivity()
	return ACT_VM_DRAW
end

function SWEP:Holster()
	return true
end

function SWEP:CanReload()
	return true
end

function SWEP:CanPerformSecondaryAttack()
	return (CurTime()>=self:GetNextPrimaryFire())
end

function SWEP:ItemPostFrame()
	if !self.Owner then return end
	if self:UsesClipsForAmmo1() then
		self:CheckReload()
	end
	if !self.Owner:KeyDown(IN_ATTACK) then
		self.m_nShotsFired = 0
		self.FireStart = nil
	end
	if self.FireStart!=nil then
		self:SetSaveValue( "m_fFireDuration", CurTime() - self.FireStart )
	end
	if !(self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) or (self:CanReload() and self.Owner:KeyDown(IN_RELOAD))) then
		if self:GetSaveTable().m_bInReload == false and !self:ReloadOrSwitchWeapons() then
			self:WeaponIdle()
		end
	end
end

function SWEP:SecondaryAttack()
	if self:UsesSecondaryAmmo() and self:Ammo2()<=0 then
		if CurTime > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			temps = CurTime() + 0.5
			self:SetNextSecondaryFire(temps)
			self:SetNextEmptySoundTime(temps)
		end
	elseif self.Owner:WaterLevel()==3 and self.FiresUnderwater==false then
		self:WeaponSound(self.EMPTY)
		self:SetNextEmptySoundTime(CurTime() + 0.2)
	else
		self:DoSecondaryAttack()
		if self:UsesClipsForAmmo2() then
			if self:Clip1()<1 then
				self.Owner:RemoveAmmo( 1, self.Secondary.Ammo )
				self:SetClip1(self:Clip1()+1)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	if !self:IsMeleeWeapon() and ((self:UsesClipsForAmmo1() and self:Clip1()<=0) or (!self:UsesClipsForAmmo1() and self:Ammo1()<=0)) then
		self:HandleFireOnEmpty()
	elseif self.Owner:WaterLevel()==3 and self.FiresUnderwater==false then
		self:WeaponSound(self.EMPTY)
		self:SetNextPrimaryFire(CurTime() + 0.2)
	else
		if self.FireStart==nil then
			self.FireStart = CurTime()
		end
		self:DoPrimaryAttack()
	end
end

function SWEP:HandleFireOnEmpty()
	if self:GetSaveTable().m_bFireOnEmpty then
		self:ReloadOrSwitchWeapons()
		self:SetSaveValue( "m_fFireDuration", 0 )
	else
		if CurTime() > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			temps = CurTime() + 0.5
			self:SetNextEmptySoundTime(temps)
		end
		self:SetSaveValue( "m_bFireOnEmpty", true )
	end
end

function SWEP:UsesClipsForAmmo1()
	return self.Primary.ClipSize!=-1
end

function SWEP:UsesClipsForAmmo2()
	return self.Secondary.ClipSize!=-1
end

function SWEP:DoPrimaryAttack()
	if self.Owner then
		if (self:UsesClipsForAmmo1() and self:Clip1()==0) or (!self:UsesClipsForAmmo1() and self:Ammo1()==0) then
			return
		end
		self.m_nShotsFired = self.m_nShotsFired + 1
		self.Owner:MuzzleFlash()
		self:WeaponSound(self.SINGLE)
		self:SetNextPrimaryFire(CurTime() + self:GetFireRate())
		if self:UsesClipsForAmmo1() then
			self:TakePrimaryAmmo(1)
		end
		local bullet = {}
		bullet.Src 		= self.Owner:GetShootPos()			-- Source
		bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
		bullet.Spread 	= self:GetBulletSpread()		-- Aim Cone
		bullet.Tracer	= 2									-- Show a tracer on every x bullets 
		bullet.AmmoType = self.Primary.Ammo
		bullet.Damage = self:GetDamage()
		self.Owner:FireBullets(bullet)
		self:AddViewKick()
		self:SendWeaponAnimIdeal(self:GetPrimaryAttackActivity())
		self.Owner:SetAnimation(PLAYER_ATTACK1)
	end
end

function SWEP:FireBullets(info)
	if self.Owner then
		self.Owner:FireBullats(info)
	end
end

function SWEP:GetBulletSpread()
	return Vector(0.03,0.03,0)
end

function SWEP:GetDamage()
	return 30
end

function SWEP:GetFireRate()
	return 0
end

function SWEP:DoSecondaryAttack()
	return false
end

function SWEP:Reload()
	if CurTime()>=self:GetNextPrimaryFire() and self:UsesClipsForAmmo1() and !self:GetSaveTable().m_bInReload then
		self:DoReload()
		self:SetSaveValue( "m_fFireDuration", 0 )
	end
end

function SWEP:ReloadsSingly()
	return self:GetSaveTable().m_bReloadsSingly
end

function SWEP:DoReload()
	if self:BaseDefaultReload(ACT_VM_RELOAD) then
		self:SetTimeWeaponIdle(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		self.FireStart = nil
	end
end

function SWEP:BaseDefaultReload(iActivity)
	if !self.Owner then
		return false
	end

	if self:Ammo1() <= 0 then
		return false
	end

	bReload = false

	if self:UsesClipsForAmmo1() then
		primary	= math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1())
		if primary != 0 then
			bReload = true
		end
	end

	if self:UsesClipsForAmmo2() then
		secondary = math.min(self.Secondary.ClipSize - self:Clip2(), self:Ammo2())
		if primary != 0 then
			bReload = true
		end
	end

	if !bReload then
		return false
	end

	self:EmitSound(self.RELOAD)
	self:SendWeaponAnimIdeal( iActivity )

	if self.Owner:IsPlayer() then
		self.Owner:SetAnimation( PLAYER_RELOAD )
	end

	flSequenceEndTime = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self:SetNextPrimaryFire(flSequenceEndTime)
	self:SetNextSecondaryFire(flSequenceEndTime)
    self:SetTimeWeaponIdle(flSequenceEndTime)
    

	self:SetSaveValue( "m_bInReload", true )
	
	return true
end

function SWEP:WeaponIdle()
	if self:WeaponShouldBeLowered() then
		if !table.HasValue({ACT_VM_IDLE_LOWERED,ACT_VM_IDLE_TO_LOWERED,ACT_TRANSITION},self:GetActivity()) then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		elseif self:HasIdleTimeElapsed() then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE_LOWERED)
		end
	else
        if CurTime() > self.m_flRaiseTime and self:GetActivity() == ACT_VM_IDLE_LOWERED then
            self:SendWeaponAnimIdeal(ACT_VM_IDLE)
        elseif self:HasIdleTimeElapsed() then
			self:SendWeaponAnimIdeal(ACT_VM_IDLE)
		end
	end
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:GetSecondaryAttackActivity()
	return ACT_VM_SECONDARYATTACK
end

function SWEP:AddViewKick()
	--self:DoMachineGunKick( 5, self:GetSaveTable().m_fFireDuration, 5)
end

function SWEP:SendWeaponAnimIdeal(act)
    self:SendWeaponAnim(act)
    self:SetTimeWeaponIdle(CurTime() + self.Owner:GetViewModel():SequenceDuration())
end

function SWEP:CheckReload()
	if self:ReloadsSingly() then
		if !self.Owner then return end
		if self:GetSaveTable().m_bInReload and (CurTime()>=self:GetNextPrimaryFire()) then
			if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) and self:Clip1()>0 then
				self:SetSaveValue( "m_bInReload", false )
				return
			end
		end
		if self:Ammo1()<=0 then
			self:FinishReload()
			return
		elseif self:Clip1()<self:GetMaxClip1() then
			self:SetClip1(self:Clip1()+1)
			self.Owner:RemoveAmmo(1,self.Primary.Ammo)
			self:DoReload()
			return
		else
			self:FinishReload()
			self:SetNextPrimaryFire(CurTime())
			self:SetNextSecondaryFire(CurTime())
			return
		end
	else
		if self:GetSaveTable().m_bInReload and CurTime()>=self:GetNextPrimaryFire() then
			self:FinishReload()
			self:SetNextPrimaryFire(CurTime())
			self:SetNextSecondaryFire(CurTime())
			self:SetSaveValue( "m_bInReload", false )
		end
	end
end

function SWEP:FinishReload()
	if self.Owner then
		if self:UsesClipsForAmmo1() then
			primary	= math.min( self:GetMaxClip1() - self:Clip1(), self:Ammo1())
			self:SetClip1(self:Clip1()+primary)
			self.Owner:RemoveAmmo( primary, self.Primary.Ammo)
		end

		if self:UsesClipsForAmmo2() then
			secondary	= math.min( self:GetMaxClip2() - self:Clip2(), self:Ammo2())
			self:SetClip2(self:Clip2()+secondary)
			self.Owner:RemoveAmmo( secondary, self.Secondary.Ammo)
		end
		if self:GetSaveTable().m_bReloadsSingly then
			self:SetSaveValue( "m_bInReload", false )
		end
	end
end

function SWEP:GetMaxClip1()
	return self.Primary.ClipSize
end

function SWEP:GetMaxClip2()
	return self.Secondary.ClipSize
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

function SWEP:Think()
	self:ItemPostFrame()
end

function SWEP:MaintainIdealActivity()
	if self:GetActivity() == ACT_TRANSITION then
		if self:GetActivity() != self:GetSaveTable().m_IdealActivity or self:GetSequence() != self:GetSaveTable().m_IdealSequence() then
			if self:IsViewModelSequenceFinished() then
				self:SendWeaponAnimIdeal(self:GetSaveTable().m_IdealActivity)
			end
		end
	end
end

function SWEP:IsViewModelSequenceFinished()
	if self:GetActivity()==ACT_RESET or self:GetActivity()==ACT_INVALID then
		return true
	end
	if self.Owner then
		if self.Owner:GetViewModel() then
			return self.Owner:GetViewModel():GetSaveTable().m_bSequenceFinished
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

function SWEP:DoMachineGunKick( maxVerticleKickAngle, fireDurationTime, slideLimitTime)
	KICK_MIN_X	= 0.2
	KICK_MIN_Y	= 0.2
	KICK_MIN_Z	= 0.1
	vecScratch = Angle(0,0,0)
	duration	= math.min(fireDurationTime,slideLimitTime)
	kickPerc = duration / slideLimitTime

	self.Owner:ViewPunchReset( 10 );

	vecScratch.x = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) )
	vecScratch.y = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3
	vecScratch.z = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8

	if math.random(0,1)==0 then
		vecScratch.y = vecScratch.y * -1
	end

	if math.random(0,1)==0 then
		vecScratch.z = vecScratch.z * -1
	end

	--UTIL_ClipPunchAngleOffset( vecScratch, pPlayer->m_Local.m_vecPunchAngle, QAngle( 24.0f, 3.0f, 1.0f ) );

	self.Owner:ViewPunch( vecScratch * 0.5 )
end

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_STAND ] 						= ACT_STAND
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_SMG1
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SMG1
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SMG1_RELAXED
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SMG1_STIMULATED
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_SMG1
	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_SMG1
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH_SMG1
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_SMG1
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 				= ACT_RANGE_ATTACK_SMG1_LOW
	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SMG1

end

--[[
LightingOrigin	=	
LightingOriginHack	=	
ResponseContext	=	
SetBodyGroup	=	0
TeamNum	=	0
avelocity	=	0.000000 0.000000 0.000000
basevelocity	=	0.000000 0.000000 0.000000
body	=	0
classname	=	hlmachinegun_strafe
cycle	=	0
damagefilter	=	
effects	=	129
fademaxdist	=	0
fademindist	=	0
fadescale	=	0
friction	=	1
globalname	=	
gravity	=	0
hammerid	=	0
health	=	0
hitboxset	=	0
ltime	=	0
m_CollisionGroup	=	11
m_GMOD_EHANDLE	=	[NULL Entity]
m_GMOD_QAngle	=	0.000000 0.000000 0.000000
m_GMOD_Vector	=	0.000000 0.000000 0.000000
m_GMOD_bool	=	false
m_GMOD_float	=	0
m_GMOD_int	=	0
m_IdealActivity	=	204
m_MoveCollide	=	0
m_MoveType	=	0
m_OverrideViewTarget	=	0.000000 0.000000 0.000000
m_angAbsRotation	=	0.000000 131.693710 0.000000
m_angRotation	=	0.000000 0.000000 0.000000
m_bAltFireHudHintDisplayed	=	false
m_bAltFiresUnderwater	=	false
m_bAlternateSorting	=	false
m_bAnimatedEveryTick	=	false
m_bClientSideAnimation	=	false
m_bClientSideFrameReset	=	false
m_bFireOnEmpty	=	false
m_bFiresUnderwater	=	false
m_bInReload	=	false
m_bLowered	=	false
m_bReloadHudHintDisplayed	=	false
m_bReloadsSingly	=	false
m_bRemoveable	=	false
m_bSequenceFinished	=	false
m_bSequenceLoops	=	false
m_bSimulatedEveryTick	=	true
m_debugOverlays	=	0
m_fBoneCacheFlags	=	0
m_fFireDuration	=	0
m_fFlags	=	0
m_fMaxRange1	=	1500
m_fMaxRange2	=	200
m_fMinRange1	=	24
m_fMinRange2	=	24
m_flAnimTime	=	-0.01513671875
m_flDesiredShadowCastDistance	=	0
m_flDissolveStartTime	=	-3011.7600097656
m_flElasticity	=	1
m_flEncodedController	=	0
m_flGroundChangeTime	=	-3011.7600097656
m_flGroundSpeed	=	0
m_flHolsterTime	=	-92.26513671875
m_flHudHintMinDisplayTime	=	-3011.7600097656
m_flHudHintPollTime	=	-86.530029296875
m_flLastEventCheck	=	-3011.7600097656
m_flModelScale	=	1
m_flMoveDoneTime	=	0
m_flNavIgnoreUntilTime	=	-3011.7600097656
m_flNextPrimaryAttack	=	-66.28515625
m_flNextSecondaryAttack	=	-66.28515625
m_flPoseParameter	=	0
m_flPrevAnimTime	=	-0.030029296875
m_flRaiseTime	=	-3011.7600097656
m_flSimulationTime	=	-621.94506835938
m_flTimeWeaponIdle	=	2.169921875
m_flUnlockTime	=	-3011.7600097656
m_flVPhysicsUpdateLocalTime	=	0
m_hDamageFilter	=	[NULL Entity]
m_hEffectEntity	=	[NULL Entity]
m_hGroundEntity	=	[NULL Entity]
m_hLightingOrigin	=	[NULL Entity]
m_hLightingOriginRelative	=	[NULL Entity]
m_hLocker	=	[NULL Entity]
m_hMoveChild	=	[NULL Entity]
m_hMoveParent	=	Player [1][STRλFE]
m_hMovePeer	=	Entity [79][predicted_viewmodel]
m_hOwner	=	Player [1][STRλFE]
m_hOwnerEntity	=	Player [1][STRλFE]
m_iAltFireHudHintCount	=	0
m_iClip1	=	30
m_iClip2	=	-1
m_iEFlags	=	46159872
m_iIKCounter	=	0
m_iName	=	
m_iParentAttachment	=	0
m_iPrimaryAmmoCount	=	0
m_iPrimaryAmmoType	=	4
m_iReloadHudHintCount	=	0
m_iSecondaryAmmoCount	=	-1
m_iSecondaryAmmoType	=	-1
m_iState	=	2
m_iSubType	=	0
m_iTeamNum	=	1001
m_iszName	=	
m_iszOverrideSubMaterials	=	
m_lifeState	=	0
m_nIdealSequence	=	11
m_nLastThinkTick	=	-41456
m_nMuzzleFlashParity	=	0
m_nNewSequenceParity	=	0
m_nResetEventsParity	=	0
m_nSimulationTick	=	-41456
m_nTransmitStateOwnedCounter	=	0
m_nViewModelIndex	=	0
m_nWaterType	=	0
m_pBlocker	=	[NULL Entity]
m_pBoneManipulator	=	[NULL Entity]
m_pFlexManipulator	=	[NULL Entity]
m_pParent	=	Player [1][STRλFE]
m_rgflCoordinateFrame	=	-0.66514837741852
m_strOverrideMaterial	=	0
m_strRealClassName	=	104
m_takedamage	=	1
m_vecAbsOrigin	=	-535.436218 279.239716 -12287.968750
m_vecAbsVelocity	=	0.000000 0.000000 0.000000
m_vecOrigin	=	0.000000 0.000000 0.000000
max_health	=	0
model	=	models/weapons/c_smg1.mdl
modelindex	=	6
modelscale	=	1
nextthink	=	-200785
parentname	=	
playbackrate	=	0
rendercolor	=	255 255 255 255
renderfx	=	0
rendermode	=	0
sequence	=	11
shadowcastdist	=	0
skin	=	0
spawnflags	=	1073741824
speed	=	0
target	=	
texframeindex	=	0
touchStamp	=	0
velocity	=	0.000000 0.000000 0.000000
view_ofs	=	0.000000 0.000000 0.000000
waterlevel	=	0

]]--