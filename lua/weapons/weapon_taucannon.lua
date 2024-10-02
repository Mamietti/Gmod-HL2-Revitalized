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
SWEP.Secondary.Automatic	= false
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

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar( "Bool" , 0 , "CannonCharging" )
end

function SWEP:Reload()
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
	--if ( m_flCannonTime > gpGlobals->curtime )
		--return;

	--//See if we're starting a charge
	--if ( m_bCannonCharging == false )
	--{
		--m_flCannonChargeStartTime = gpGlobals->curtime;
		--m_bCannonCharging = true;

		--//Start charging sound
		--CPASAttenuationFilter filter( this );
		--m_sndCannonCharge = (CSoundEnvelopeController::GetController()).SoundCreate( filter, entindex(), CHAN_STATIC, "Jeep.GaussCharge", ATTN_NORM );

		--if ( m_hPlayer )
		--{
			--m_hPlayer->RumbleEffect( RUMBLE_FLAT_LEFT, (int)(0.1 * 100), RUMBLE_FLAG_RESTART | RUMBLE_FLAG_LOOP | RUMBLE_FLAG_INITIAL_SCALE );
		--}

		--assert(m_sndCannonCharge!=NULL);
		--if ( m_sndCannonCharge != NULL )
		--{
			--(CSoundEnvelopeController::GetController()).Play( m_sndCannonCharge, 1.0f, 50 );
			--(CSoundEnvelopeController::GetController()).SoundChangePitch( m_sndCannonCharge, 250, 3.0f );
		--}

		--return;
	--}
	--else
	--{
		--float flChargeAmount = ( gpGlobals->curtime - m_flCannonChargeStartTime ) / MAX_GAUSS_CHARGE_TIME;
		--if ( flChargeAmount > 1.0f )
		--{
			--flChargeAmount = 1.0f;
		--}

		--float rumble = flChargeAmount * 0.5f;

		--if( m_hPlayer )
		--{
			--m_hPlayer->RumbleEffect( RUMBLE_FLAT_LEFT, (int)(rumble * 100), RUMBLE_FLAG_UPDATE_SCALE );
		--}
	--}
end

function SWEP:FireChargedCannon()
    --bool penetrated = false;

	--m_bCannonCharging	= false;
	--m_flCannonTime		= gpGlobals->curtime + 0.5f;

	--StopChargeSound();

	--CPASAttenuationFilter sndFilter( this, "PropJeep.FireChargedCannon" );
	--EmitSound( sndFilter, entindex(), "PropJeep.FireChargedCannon" );

	--if( m_hPlayer )
	--{
		--m_hPlayer->RumbleEffect( RUMBLE_357, 0, RUMBLE_FLAG_RESTART );
	--}

	--//Find the direction the gun is pointing in
	--Vector aimDir;
	--GetCannonAim( &aimDir );

	--Vector endPos = m_vecGunOrigin + ( aimDir * MAX_TRACE_LENGTH );
	
	--//Shoot a shot straight out
	--trace_t	tr;
	--UTIL_TraceLine( m_vecGunOrigin, endPos, MASK_SHOT, this, COLLISION_GROUP_NONE, &tr );
	
	--ClearMultiDamage();

	--//Find how much damage to do
	--float flChargeAmount = ( gpGlobals->curtime - m_flCannonChargeStartTime ) / MAX_GAUSS_CHARGE_TIME;

	--//Clamp this
	--if ( flChargeAmount > 1.0f )
	--{
		--flChargeAmount = 1.0f;
	--}

	--//Determine the damage amount
	--//FIXME: Use ConVars!
	--float flDamage = 15 + ( ( 250 - 15 ) * flChargeAmount );

	--CBaseEntity *pHit = tr.m_pEnt;
	
	--//Look for wall penetration
	--if ( tr.DidHitWorld() && !(tr.surface.flags & SURF_SKY) )
	--{
		--//Try wall penetration
		--UTIL_ImpactTrace( &tr, m_nBulletType, "ImpactJeep" );
		--UTIL_DecalTrace( &tr, "RedGlowFade" );

		--CPVSFilter filter( tr.endpos );
		--te->GaussExplosion( filter, 0.0f, tr.endpos, tr.plane.normal, 0 );
		
		--Vector	testPos = tr.endpos + ( aimDir * 48.0f );

		--UTIL_TraceLine( testPos, tr.endpos, MASK_SHOT, GetDriver(), COLLISION_GROUP_NONE, &tr );
			
		--if ( tr.allsolid == false )
		--{
			--UTIL_DecalTrace( &tr, "RedGlowFade" );

			--penetrated = true;
		--}
	--}
	--else if ( pHit != NULL )
	--{
		--CTakeDamageInfo dmgInfo( this, GetDriver(), flDamage, DMG_SHOCK );
		--CalculateBulletDamageForce( &dmgInfo, GetAmmoDef()->Index("GaussEnergy"), aimDir, tr.endpos, 1.0f + flChargeAmount * 4.0f );

		--//Do direct damage to anything in our path
		--pHit->DispatchTraceAttack( dmgInfo, aimDir, &tr );
	--}

	--ApplyMultiDamage();

	--//Kick up an effect
	--if ( !(tr.surface.flags & SURF_SKY) )
	--{
  		--UTIL_ImpactTrace( &tr, m_nBulletType, "ImpactJeep" );

		--//Do a gauss explosion
		--CPVSFilter filter( tr.endpos );
		--te->GaussExplosion( filter, 0.0f, tr.endpos, tr.plane.normal, 0 );
	--}

	--//Show the effect
	--DrawBeam( m_vecGunOrigin, tr.endpos, 9.6 );

	--// Register a muzzleflash for the AI
	--if ( m_hPlayer )
	--{
		--m_hPlayer->SetMuzzleFlashTime( gpGlobals->curtime + 0.5f );
	--}

	--//Rock the car
	--IPhysicsObject *pObj = VPhysicsGetObject();

	--if ( pObj != NULL )
	--{
		--Vector	shoveDir = aimDir * -( flDamage * 500.0f );

		--pObj->ApplyForceOffset( shoveDir, m_vecGunOrigin );
	--}

	--//Do radius damage if we didn't penetrate the wall
	--if ( penetrated == true )
	--{
		--RadiusDamage( CTakeDamageInfo( this, this, flDamage, DMG_SHOCK ), tr.endpos, 200.0f, CLASS_NONE, NULL );
	--}
    --}

end

function SWEP:DoImpactEffect( tr, nDamageType )

	local forward = self.Owner:EyeAngles():Forward()
    local up = self.Owner:EyeAngles():Up()
    local right = self.Owner:EyeAngles():Right()  
    local shootpos = self.Owner:GetShootPos()+right*10+forward*20-up*8

	self:DrawBeam(shootpos, tr.HitPos, 2.4)
    
    if bit.band( tr.SurfaceFlags, SURF_SKY ) == SURF_SKY then
		--CPVSFilter filter( tr.endpos );
		--te->GaussExplosion( filter, 0.0f, tr.endpos, tr.plane.normal, 0 );

		--UTIL_ImpactTrace( &tr, m_nBulletType );
	end

end

function SWEP:FireCannon()
    --//Don't fire again if it's been too soon
	--if ( m_flCannonTime > gpGlobals->curtime )
		--return;

	--if ( m_bUnableToFire )
		--return;

	self:SetNextPrimaryFire(CurTime() + 0.2)
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
    info.Damage = game.GetAmmoNPCDamage(game.GetAmmoID(self.Primary.Ammo))
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