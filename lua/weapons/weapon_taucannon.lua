SWEP.PrintName			= "TAU CANNON"
SWEP.Author			= "Strafe"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.Base               = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_taucannon.mdl"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/w_gauss.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = false

SWEP.HoldType			= "shotgun"

SWEP.Primary.FireRate = 0.25
SWEP.Primary.BulletSpread = Vector(0,0,0)
SWEP.Primary.TracerOverride = "HelicopterTracer"
SWEP.Primary.TracerRate = 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "GaussEnergy"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "PropJeep.FireCannon"
SWEP.EMPTY = "Weapon_IRifle.Empty"

SWEP.m_fMinRange1 = 65
SWEP.m_fMinRange2 = 65
SWEP.m_fMaxRange1 = 1024
SWEP.m_fMaxRange2 = 1024

SWEP.Sound = nil

SWEP.WeaponLetter = "h"
SWEP.WeaponSelectedLetter = "h"

local GAUSS_CHARGE_TIME = 0.2
local MAX_GAUSS_CHARGE = 16
local MAX_GAUSS_CHARGE_TIME = 3
local DANGER_GAUSS_CHARGE_TIME = 10
local GAUSS_NUM_BEAMS = 4

local GAUSS_BEAM_SPRITE = "sprites/laserbeam.vtf"

SWEP.SoundCannonCharge = nil

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar( "Bool", "CannonCharging" )
	self:NetworkVar( "Float", "CannonChargeStartTime" )
	self:NetworkVar( "Float", "ChargeAmount" )
	--self:NetworkVar( "Entity", "SoundCannonCharge" )
end

function SWEP:Reload()
end

function SWEP:GetDamage()
	return game.GetAmmoNPCDamage(game.GetAmmoID(self.Primary.Ammo))
end

function SWEP:DrawBeam( startPos, endPos, width )
    
    local effectdata2 = EffectData()
    effectdata2:SetOrigin( endPos )
    effectdata2:SetStart( startPos )
    effectdata2:SetScale(6000)
    effectdata2:SetAngles( Vector(endPos-startPos):Angle())
    effectdata2:SetFlags(0)
    util.Effect( "GaussTracer", effectdata2, false, true)
    
    if SERVER then

    local hit = ents.Create("info_target")
    hit:SetPos(endPos)
    hit:SetName("target"..tostring(self.Owner))
    hit:Spawn()
    hit:Activate()
	hit:Fire("kill",0,0.1)
    
    local zappy = ents.Create( "env_beam" )
	zappy:SetPos(startPos)
    zappy:SetKeyValue( "texture", GAUSS_BEAM_SPRITE )
	zappy:SetKeyValue( "Spawnflags", "17" )
	zappy:SetName("beam"..tostring(self.Owner))
    zappy:SetKeyValue( "LightningStart", zappy:GetName() )
    zappy:SetKeyValue("LightningEnd", hit:GetName() )
    --pBeam->SetEndAttachment( LookupAttachment("Muzzle") );
    zappy:SetKeyValue( "BoltWidth", width*0.25 )
    
    zappy:SetKeyValue( "life", "0" )
    zappy:SetKeyValue( "damage", "0" )
    zappy:SetColor(Color(255,185+math.random(-16,16),40,255))
    zappy:Spawn()
    zappy:Activate()
	zappy:Fire("kill",0,0.1)

	local zappy2 = ents.Create( "env_beam" )
	zappy2:SetPos(startPos)
    zappy2:SetKeyValue( "texture", GAUSS_BEAM_SPRITE )
	zappy2:SetKeyValue( "Spawnflags", "17" )
	zappy2:SetName("beam2"..tostring(self.Owner))
    zappy2:SetKeyValue( "LightningStart", zappy2:GetName() )
    zappy2:SetKeyValue("LightningEnd", hit:GetName() )
    --pBeam->SetEndAttachment( LookupAttachment("Muzzle") );
    zappy2:SetKeyValue( "BoltWidth", width*0.3 )
    
    zappy2:SetKeyValue( "life", "0" )
    zappy2:SetKeyValue( "damage", "0" )
    zappy2:SetColor(Color(255,255,150+math.random(0,64),math.random( 64, 255 )))
	zappy2:Fire("noise", "1.6", 0)
    zappy2:Spawn()
    zappy2:Activate()
	zappy2:Fire("kill",0,0.1)
    
    end
end

function SWEP:ChargeCannon()
    --//Don't fire again if it's been too soon
	if self:GetNextSecondaryFire() > CurTime() then return end

	--//See if we're starting a charge
	if !self:GetCannonCharging() then
		self:SetCannonChargeStartTime(CurTime())
		self:SetCannonCharging(true)

		--//Start charging sound
		--CPASAttenuationFilter filter( this );
		--m_sndCannonCharge = (CSoundEnvelopeController::GetController()).SoundCreate( filter, entindex(), CHAN_STATIC, "Jeep.GaussCharge", ATTN_NORM );
		local snd = CreateSound(self, "Jeep.GaussCharge")
		self.SoundCannonCharge = snd

		if ( self.SoundCannonCharge != nil ) then
			--local snd = self:GetSoundCannonCharge()
			self.SoundCannonCharge:PlayEx(1, 50)
            self.SoundCannonCharge:ChangePitch( 250, 3 )
		end

	end
		--float flChargeAmount = ( gpGlobals->curtime - m_flCannonChargeStartTime ) / MAX_GAUSS_CHARGE_TIME;
	self:SetChargeAmount((CurTime() - self:GetCannonChargeStartTime()) / MAX_GAUSS_CHARGE_TIME)
	if self:GetChargeAmount() > 1.0 then
		self:SetChargeAmount(1)
	else
		self.Owner:RemoveAmmo( 1, self.Primary.Ammo )
	end

	self:SetNextSecondaryFire(CurTime() + GAUSS_CHARGE_TIME)
end

function SWEP:StopChargeSound()
	if self.SoundCannonCharge != nil then
		self.SoundCannonCharge:FadeOut(0.1)
	end
end

function SWEP:FireChargedCannon()
    local penetrated = false;

	self:SetCannonCharging(false)

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)

	self:StopChargeSound();

	self:EmitSound( "PropJeep.FireChargedCannon" )

	--//Find the direction the gun is pointing in
	local aimDir = self.Owner:GetAimVector()

	local endPos = self.Owner:GetShootPos() + ( aimDir * 56756 );
	
	--//Shoot a shot straight out
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = endPos,
		filter = {self, self.Owner},
		mask = MASK_SHOT,
		collisiongroup = COLLISION_GROUP_NONE
	} )

	--//Determine the damage amount
	flDamage = (1 + ( ( MAX_GAUSS_CHARGE - 1 ) * self:GetChargeAmount() )) * self:GetDamage();

	pHit = tr.Entity;
	
	--//Look for wall penetration
	if ( tr.HitWorld and not tr.HitSky ) then
		--//Try wall penetration
		self:ImpactTrace(tr, DMG_SHOCK)
		util.Decal("RedGlowFade",tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)

		if SERVER then
			local filter = RecipientFilter()
			filter:AddPVS(tr.HitPos)
			self:GaussExplosion( filter, 0.0, tr.HitPos, tr.HitNormal, 0 );
		end
		
		local testPos = tr.HitPos + ( aimDir * 48.0 );

		tr = util.TraceLine( {
			start = testPos,
			endpos = tr.HitPos,
			filter = self.Owner,
			mask = MASK_SHOT,
			collisiongroup = COLLISION_GROUP_NONE
		} )
			
		if !tr.AllSolid then
			util.Decal("RedGlowFade",tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)

			penetrated = true;
		end
	elseif pHit != nil then
		--CTakeDamageInfo dmgInfo( this, GetDriver(), flDamage, DMG_SHOCK );
		local dmgInfo = DamageInfo()
		dmgInfo:SetAttacker(self.Owner)
		dmgInfo:SetInflictor(self)
		dmgInfo:SetDamage(flDamage)
		dmgInfo:SetDamageType(DMG_SHOCK)
		self:CalculateBulletDamageForce( dmgInfo, game.GetAmmoID( self.Primary.Ammo ), aimDir, tr.HitPos, 1.0 + self:GetChargeAmount() * 4.0 );
		pHit:DispatchTraceAttack( dmgInfo, tr, aimDir )
	end

	--ApplyMultiDamage();

	--//Kick up an effect
	if !tr.HitSky then
		self:ImpactTrace(tr, DMG_SHOCK)
		util.Decal("RedGlowFade",tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
		--//Do a gauss explosion
		if SERVER then
			local filter = RecipientFilter()
			filter:AddPVS(tr.HitPos)
			self:GaussExplosion( filter, 0.0, tr.HitPos, tr.HitNormal, 0 );
		end
	end

	--//Show the effect
	local forward = self.Owner:EyeAngles():Forward()
    local up = self.Owner:EyeAngles():Up()
    local right = self.Owner:EyeAngles():Right()  
    local shootpos = self.Owner:GetShootPos()+right*10+forward*20-up*8

	self:DrawBeam( shootpos, tr.HitPos, 9.6 );

	--// Register a muzzleflash for the AI
	self.Owner:MuzzleFlash()

	--//Do radius damage if we didn't penetrate the wall
	if penetrated == true then
		local dmgInfo = DamageInfo()
		dmgInfo:SetAttacker(self.Owner)
		dmgInfo:SetInflictor(self)
		dmgInfo:SetDamage(flDamage)
		dmgInfo:SetDamageType(DMG_SHOCK)
		util.BlastDamageInfo(dmgInfo, tr.HitPos, 200)
	end

	self:SendWeaponAnimIdeal( ACT_VM_SECONDARYATTACK )

end

function SWEP:DoImpactEffect( tr, nDamageType )

	local forward = self.Owner:EyeAngles():Forward()
    local up = self.Owner:EyeAngles():Up()
    local right = self.Owner:EyeAngles():Right()  
    local shootpos = self.Owner:GetShootPos()+right*10+forward*20-up*8

	self:DrawBeam(shootpos, tr.HitPos, 2.4)
    
    if ( tr.HitSky ) then return end

	local filter = RecipientFilter()
	filter:AddPVS(tr.HitPos)
	self:GaussExplosion( filter, 0.0, tr.HitPos, tr.HitNormal, 0 );

	self:ImpactTrace(tr, nDamageType)
	util.Decal("RedGlowFade",tr.HitPos+tr.HitNormal, tr.HitPos-tr.HitNormal)
end

function SWEP:GaussExplosion(filter, x, pos, normal, y)
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetMagnitude(2)
	effectdata:SetScale(1)
	effectdata:SetRadius(5)
	util.Effect( "Sparks", effectdata, false, filter )
end

function SWEP:FireCannon()

	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:SetNextSecondaryFire(CurTime() + 0.2)
	self:SetCannonCharging(false)

	--//Find the direction the gun is pointing in
	local aimDir = self.Owner:GetAimVector()

    local tr = self.Owner:GetEyeTrace()
    local info = {}
    info.Num 		= self.Primary.Number
    info.Src 		= self.Owner:GetShootPos()
    info.Dir 		= self.Owner:GetAimVector()
    info.Spread   = VECTOR_CONE_1DEGREES
    info.AmmoType = self.Primary.AmmoType
    info.Attacker = self.Owner
	info.Callback = function(attacker,tr,dmginfo)
        dmginfo:SetDamageType(DMG_SHOCK)
    end
    
    -- HOX: Why do we need to do this?
    info.Damage = self:GetDamage()
    info.Tracer = 0

	self:FireBullets( info )
	self.Owner:RemoveAmmo( 1, self.Primary.Ammo )

	--// Register a muzzleflash for the AI
	if self.Owner:IsPlayer() then
		self.Owner:MuzzleFlash()
	end

	self:EmitSound("PropJeep.FireCannon")
    self:SendWeaponAnimIdeal(ACT_VM_PRIMARYATTACK)
	
	--// make cylinders of gun spin a bit
	--m_nSpinPos += JEEP_GUN_SPIN_RATE;
	--//SetPoseParameter( JEEP_GUN_SPIN, m_nSpinPos );	//FIXME: Don't bother with this for E3, won't look right
end

function SWEP:DoPrimaryAttack()
    if self:GetCannonCharging() then
        self:FireChargedCannon()
    else
        self:FireCannon()
    end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

    self:ChargeCannon()
end

function SWEP:Think()
    BaseClass.Think(self)
    if self.Owner:KeyReleased(IN_ATTACK2) and self:GetCannonCharging() then
        self:FireChargedCannon()
    end
end

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	if ( t == "shotgun" ) then
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_SMG1
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SMG1_RELAXED
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SMG1_STIMULATED
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_SMG1

	self.ActivityTranslateAI [ ACT_RUN ] 					= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH_SHOTGUN

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_SHOTGUN
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_SHOTGUN_LOW
	
	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SHOTGUN
	return end	
end

list.Add( "NPCUsableWeapons", { class = "weapon_gauss",	title = "Tau Cannon" }  )