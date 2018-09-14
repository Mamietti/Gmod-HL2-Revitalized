SWEP.PrintName			= "Test SMG"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/c_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"
SWEP.HoldType			= "pistol"
SWEP.Base = "weapon_base"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFOV = 54

DEFINE_BASECLASS( "weapon_base" )

VECTOR_CONE_PRECALCULATED = vec3_origin
VECTOR_CONE_1DEGREES = Vector( 0.00873, 0.00873, 0.00873 )
VECTOR_CONE_2DEGREES = Vector( 0.01745, 0.01745, 0.01745 )
VECTOR_CONE_3DEGREES = Vector( 0.02618, 0.02618, 0.02618 )
VECTOR_CONE_4DEGREES = Vector( 0.03490, 0.03490, 0.03490 )
VECTOR_CONE_5DEGREES = Vector( 0.04362, 0.04362, 0.04362 )
VECTOR_CONE_6DEGREES = Vector( 0.05234, 0.05234, 0.05234 )
VECTOR_CONE_7DEGREES = Vector( 0.06105, 0.06105, 0.06105 )
VECTOR_CONE_8DEGREES = Vector( 0.06976, 0.06976, 0.06976 )
VECTOR_CONE_9DEGREES = Vector( 0.07846, 0.07846, 0.07846 )
VECTOR_CONE_10DEGREES = Vector( 0.08716, 0.08716, 0.08716 )
VECTOR_CONE_15DEGREES = Vector( 0.13053, 0.13053, 0.13053 )
VECTOR_CONE_20DEGREES = Vector( 0.17365, 0.17365, 0.17365 )

SWEP.m_bMeleeWeapon = false

AccessorFunc( SWEP, "m_flTimeWeaponIdle", "WeaponIdleTime" )
AccessorFunc( SWEP, "m_flNextEmptySoundTime", "NextEmptySoundTime")

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""

function SWEP:Initialize()
    self:SetWeaponIdleTime(0)
    self:SetNextEmptySoundTime(0)
    self.m_fFireDuration = 0
end

function SWEP:IsMeleeWeapon()
	return self.m_bMeleeWeapon
end

function SWEP:HasWeaponIdleTimeElapsed()
	if ( CurTime() > self:GetWeaponIdleTime() ) then
		return true
    end
	return false
end

function SWEP:GetViewModelSequenceDuration()
    return self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:Think()
    if self.Owner:KeyDown(IN_ATTACK) then
        self.m_fFireDuration = self.m_fFireDuration + FrameTime()
    else
        self.m_fFireDuration = 0
    end
    
	if !(self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) or (self:CanReload() and self.Owner:KeyDown(IN_RELOAD))) then
		if self:GetSaveTable().m_bInReload == false and !self:ReloadOrSwitchWeapons() then
			self:WeaponIdle()
		end
	end
end

function SWEP:CanReload()
	return true
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

function SWEP:ReloadsSingly()
	return self:GetSaveTable().m_bReloadsSingly
end

function SWEP:WeaponIdle()
    if self:HasWeaponIdleTimeElapsed() then
        self:SendWeaponAnimIdeal(ACT_VM_IDLE)
    end
end

function SWEP:SendWeaponAnimIdeal(act)
    self:SendWeaponAnim(act)
    self:SetWeaponIdleTime(CurTime() + self:GetViewModelSequenceDuration())
end

function SWEP:SecondaryAttack()
	if self:UsesSecondaryAmmo() and self:Ammo2()<=0 then
		if CurTime > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			temps = CurTime() + 0.5
			self:SetNextSecondaryFire(temps)
			self:SetNextEmptySoundTime(temps)
		end
	elseif self.Owner:WaterLevel()==3 and !self:GetSaveTable().m_bAltFiresUnderwater then
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
	elseif self.Owner:WaterLevel()==3 and !self:GetSaveTable().m_bFiresUnderwater then
		self:WeaponSound(self.EMPTY)
		self:SetNextPrimaryFire(CurTime() + 0.2)
	else
		if self.FireStart==nil then
			self.FireStart = CurTime()
		end
		self:DoPrimaryAttack()
	end
end

function SWEP:DoSecondaryAttack()
end

function SWEP:UsesClipsForAmmo1()
	return self.Primary.ClipSize!=-1
end

function SWEP:UsesClipsForAmmo2()
	return self.Secondary.ClipSize!=-1
end

function SWEP:UsesPrimaryAmmo()
	return (self.Primary.Ammo == "None")
end

function SWEP:UsesSecondaryAmmo()
	return (self.Secondary.Ammo == "None")
end

function SWEP:HandleFireOnEmpty()
	if self:GetSaveTable().m_bFireOnEmpty then
		self:ReloadOrSwitchWeapons()
		self.m_fFireDuration = 0
	else
		if CurTime() > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			temps = CurTime() + 0.5
			self:SetNextEmptySoundTime(temps)
		end
		self:SetSaveValue( "m_bFireOnEmpty", true )
	end
end

function SWEP:GetFireRate()
	return 0
end

function SWEP:WeaponSound(sound)
	self:EmitSound(sound)
end

function SWEP:ReloadOrSwitchWeapons()
	if self.Owner then
		self:SetSaveValue( "m_bFireOnEmpty", false ) 
		if !self:HasAmmo() and (CurTime()>self:GetNextPrimaryFire()) and (CurTime()>self:GetNextSecondaryFire()) then
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

function SWEP:DoReload()
	if self:BaseDefaultReload(ACT_VM_RELOAD) then
		self:SetWeaponIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end
end

function SWEP:Reload()
    self:DoReload()
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
    self:SetWeaponIdleTime(flSequenceEndTime)
    

	self:SetSaveValue( "m_bInReload", true )
	
	return true
end

function SWEP:DoPrimaryAttack()
	if self:UsesClipsForAmmo1() and !self:Clip1() then
		self:DoReload()
		return
    end

	if self.Owner then

        self:MuzzleFlash()

        self:SendWeaponAnimIdeal( self:GetPrimaryAttackActivity() )

        self.Owner:SetAnimation( PLAYER_ATTACK1 );
		local bullet = {}
		bullet.Src 		= self.Owner:GetShootPos()			-- Source
		bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
		bullet.Spread 	= self:GetBulletSpread()		-- Aim Cone
		bullet.Tracer	= 2									-- Show a tracer on every x bullets 
		bullet.AmmoType = self.Primary.Ammo
		bullet.Damage = self:GetDamage()
        
        self:WeaponSound(self.SINGLE)
        fireRate = self:GetFireRate()
        self:SetNextPrimaryFire(CurTime() + fireRate)

        if self:UsesClipsForAmmo1() then
            self:SetClip1(self:Clip1()-1)
        else
            self:RemoveAmmo(1, self.Primary.AmmoType)
        end
        
        self.Owner:FireBullets(bullet)
        self:AddViewKick()
    end
end

function SWEP:GetDamage()
	return 30
end

function SWEP:AddViewKick()
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:GetBulletSpread()
	return Vector(0.03,0.03,0)
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

