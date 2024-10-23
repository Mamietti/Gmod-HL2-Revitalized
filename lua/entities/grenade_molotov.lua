AddCSLuaFile()

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = ""
ENT.Author = "Strafe"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Information	= ""  
ENT.Category		= ""

ENT.Spawnable = false
ENT.AdminSpawnable = false

local m_flDamage = 100
// sk_plr_dmg_molotov			"100"
// sk_npc_dmg_molotov			"50"
// sk_max_molotov				"5"
// sk_molotov_radius			"150"
local m_DmgRadius = 150
local BASEGRENADE_EXPLOSION_VOLUME = 1024

local FIRE_MAX_GROUND_OFFSET = 24

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "FireTrail" )
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/w_molotov.mdl" )
        self:SetMoveType(MOVETYPE_FLYGRAVITY)
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:SetSolid( SOLID_BBOX )
		self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
		self:SetGravity( 1 )

        local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

        local fireTrail = ents.Create("env_smoketrail")
        fireTrail:SetKeyValue( "spawnrate", "48" )
        fireTrail:SetKeyValue( "lifetime", "1" )

        fireTrail:SetKeyValue( "startcolor", "51 51 51" ) // 0.2 x 255
        fireTrail:SetKeyValue( "endcolor", "0 0 0" )
		
        fireTrail:SetKeyValue( "startsize", "8" ) // 0.2 x 255
        fireTrail:SetKeyValue( "endsize", "32" )
        fireTrail:SetKeyValue( "spawnradius", "4" )
        fireTrail:SetKeyValue( "minspeed", "8" )
        fireTrail:SetKeyValue( "maxspeed", "16" )
		fireTrail:SetKeyValue( "opacity", "0.25" )

        fireTrail:SetKeyValue( "emittime", "20.0" )
        fireTrail:SetKeyValue( "opacity", "0.25" )
        fireTrail:SetPos(self:GetPos())
        fireTrail:SetParent(self)

        fireTrail:Spawn()
        self:SetFireTrail(fireTrail)
	end
	--self:AddFlags(FL_OBJECT)
end

function ENT:StartFire(position, fireHeight, attack, fuel, flags, owner)
    local testPos = position

    local fire = ents.Create("env_fire")
    if !IsValid(fire) then
        return
    end

    fire:SetPos(testPos)
    fire:SetKeyValue( "firesize", tostring(fireHeight) )
    fire:SetKeyValue( "fireattack", tostring(attack) )
    fire:SetKeyValue( "spawnflags", tostring(flags) )
    fire:Spawn()
    fire:Fire("StartFire", "", 0)
    fire:Fire("kill",0, 20)

    return true
end

function ENT:Detonate()
    self:SetModel( "" )
	self:AddSolidFlags( FSOLID_NOT_SOLID )	// intangible

	// m_takedamage = DAMAGE_NO;

    local trace = util.TraceLine( {
        start = self:GetPos(),
        endpos = self:GetPos() + Vector ( 0, 0, -128 ),
        mask = MASK_SOLID_BRUSHONLY,
        filter = self,
        collisiongroup = COLLISION_GROUP_NONE
    } )
        

	// Pull out of the wall a bit
	if trace.fraction != 1.0 then
		self:SetPos( trace.HitPos + (trace.HitNormal * (m_flDamage - 24) * 0.6) )
    end

	contents = util.PointContents( self:GetPos() )
	if bit.band( util.PointContents( trace.HitPos ), CONTENTS_WATER ) == CONTENTS_WATER then
		self:Remove()
		return;
    end

	self:EmitSound( "Grenade_Molotov.Detonate");

	local vecTraceAngles = Angle(0, 0, 0)
	local vecTraceDir = Vector(0, 0, 0)
	local firetrace = NULL 

    for i=0, 16 do
        vecTraceAngles.pitch = math.random(45, 135)
		vecTraceAngles.yaw = math.random(0, 360)
		vecTraceAngles.roll = 0

		--AngleVectors( vecTraceAngles, &vecTraceDir );
        vecTraceDir = vecTraceAngles:Forward()

		local vecStart = NULL 
        local vecEnd = NULL

		vecStart = self:GetPos() + ( trace.HitNormal * 128 );
		vecEnd = vecStart + vecTraceDir * 512;

        firetrace = util.TraceLine( {
            start = vecStart,
            endpos = vecEnd,
            mask = MASK_SOLID_BRUSHONLY,
            filter = self,
            collisiongroup = COLLISION_GROUP_NONE
        } )

		local ofsDir = firetrace.HitPos - self:GetPos()
		local offset = ofsDir:Length()

		if offset > 128 then
			offset = 128
        end

		//Get our scale based on distance
		local scale	 = 0.1 + ( 0.75 * ( 1.0 - ( offset / 128.0 ) ) )
		local growth = 0.1 + ( 0.75 * ( offset / 128.0 ) )

		if firetrace.fraction != 1.0 then
            local effectdata = EffectData()
            effectdata:SetOrigin( firetrace.HitPos )
            util.Effect( "balloon_pop", effectdata )
			self:StartFire( firetrace.HitPos, scale, growth, 30.0, 4 + 2 + 32, self ); // (SF_FIRE_START_ON|SF_FIRE_SMOKELESS|SF_FIRE_NO_GLOW)
        end
    end
    // End Start some fires
	
	//CPASFilter filter2( trace.endpos );

	//te->Explosion( filter2, 0.0,
		//&trace.endpos, 
		//g_sModelIndexFireball,
		//2.0, 
		//15,
		//TE_EXPLFLAG_NOPARTICLES,
		//m_DmgRadius,
		//m_flDamage );

	//CBaseEntity *pOwner;
	//pOwner = GetOwnerEntity();
	//SetOwnerEntity( NULL ); // can't traceline attack owner if this is set

    local effectdata = EffectData()
    effectdata:SetOrigin( trace.HitPos )
	effectdata:SetStart( trace.HitPos )
	effectdata:SetMagnitude( 2 )
    effectdata:SetScale(15)
    effectdata:SetFlags(8)

    util.Effect("Explosion", effectdata)

    util.Decal( "Scorch", trace.StartPos, trace.HitPos)

    util.ScreenShake( self:GetNetworkOrigin(), 25, 150, 1, 750)

    sound.EmitHint( SOUND_DANGER, self:GetNetworkOrigin(), BASEGRENADE_EXPLOSION_VOLUME, 3)

    local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(self:GetOwner())
	dmgInfo:SetInflictor(self)
	dmgInfo:SetDamage(m_flDamage)
	dmgInfo:SetDamageType(DMG_BLAST)

    util.BlastDamageInfo( dmgInfo, self:GetNetworkOrigin(), m_DmgRadius )

	self:AddEffects( EF_NODRAW )
	self:SetAbsVelocity( Vector(0, 0, 0) )
	self:NextThink( CurTime() + 0.2 );

	if self:GetFireTrail() then
		self:GetFireTrail():Remove()
    end

	self:Remove();
end

function ENT:Touch(entity)
    self:Detonate()
end