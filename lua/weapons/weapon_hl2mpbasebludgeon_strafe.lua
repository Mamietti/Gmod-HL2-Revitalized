SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.Base = "weapon_hl2basehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.ViewModel			= "models/weapons/c_stunstick.mdl"
SWEP.WorldModel			= "models/weapons/w_stunstick.mdl"

SWEP.HoldType			= "melee"

SWEP.Primary.Damage = 25
SWEP.Primary.FireRate = 0.4
SWEP.Primary.Range = 64
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "Weapon_Crowbar.Single"
SWEP.MELEE_HIT = "Weapon_Crowbar.Melee_Hit"

SWEP.BLUDGEON_HULL_DIM = 16
SWEP.HitActivity = ACT_VM_HITCENTER
SWEP.DamageType = DMG_CLUB

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetHoldType(self.HoldType)
	self.g_bludgeonMins = Vector(-self.BLUDGEON_HULL_DIM, -self.BLUDGEON_HULL_DIM, -self.BLUDGEON_HULL_DIM)
	self.g_bludgeonMaxs = Vector(self.BLUDGEON_HULL_DIM, self.BLUDGEON_HULL_DIM, self.BLUDGEON_HULL_DIM)
end

function SWEP:GetCapabilities()

	return bit.bor( CAP_WEAPON_MELEE_ATTACK1 )

end

function SWEP:Think()
	if self.Owner and CurTime()>self:GetNextPrimaryFire() and CurTime()>self:GetNextSecondaryFire() then
		self:WeaponIdle()
	end
end

function SWEP:WeaponIdle()
	if self:HasIdleTimeElapsed() then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetWeaponIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end
end

function SWEP:HasIdleTimeElapsed()
	if CurTime()>=self:GetWeaponIdleTime() then
		return true
	end
	return false
end

function SWEP:PrimaryAttack()
	self:Swing(false)
end

function SWEP:SecondaryAttack()
	self:Swing(true)
end

function SWEP:Swing(bIsSecondary)
end

function SWEP:Hit(traceHit, nHitActivity, bIsSecondary )

	self:AddViewKick()

	pHitEntity = traceHit.Entity

	if pHitEntity then
		hitDirection = self.Owner:EyeAngles():Forward()

		info = DamageInfo()
		info:SetAttacker(self.Owner)
		info:SetInflictor(self)
		info:SetDamage(self:GetDamageForActivity( nHitActivity ))
		info:SetDamageType(self.DamageType)

		self:CalculateMeleeDamageForce( info, hitDirection, traceHit.HitPos );
		traceHit.HitGroup = HITGROUP_CHEST --HACKHACK equalize damage for Half-Life-ness
		pHitEntity:DispatchTraceAttack( info, traceHit, hitDirection )
	end
	self:WeaponSound( self.MELEE_HIT )
	self:ImpactEffect(traceHit)
end

function SWEP:GetDamageForActivity()
	return self.Primary.Damage
end

function SWEP:CalculateMeleeDamageForce(info, vecMeleeDir, vecForceOrigin)
	info:SetDamagePosition( vecForceOrigin )
	flForceScale = info:GetBaseDamage() * 75 * 4
	vecForce = vecMeleeDir
	vecForce:Normalize()
	vecForce = vecForce * flForceScale
    phys_pushscale = GetConVar("phys_pushscale"):GetFloat()
	vecForce = vecForce * phys_pushscale
	info:SetDamageForce( vecForce )
end

function SWEP:ChooseIntersectionPointAndActivity( hitTrace, mins, maxs, pOwner )
	distance = 0
	minmaxs = {mins, maxs}
	vecHullEnd = hitTrace.HitPos
	vecEnd = Vector(0,0,0)
	distance = 111
	vecSrc = hitTrace.StartPos 

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc)*2)
	tmpTrace = util.TraceLine({start = vecSrc, endpos = vecHullEnd, mask = MASK_SHOT_HULL, filter = pOwner, collisiongroup = COLLISION_GROUP_NONE })
	if ( tmpTrace.Fraction == 1.0 ) then
		for i = 0,1 do
			for j = 0,1 do
				for k = 0,1 do
					vecEnd.x = vecHullEnd.x + minmaxs[i+1].x
					vecEnd.y = vecHullEnd.y + minmaxs[j+1].y
					vecEnd.z = vecHullEnd.z + minmaxs[k+1].z

					tmpTrace = util.TraceLine({start = vecSrc, endpos = vecEnd, mask = MASK_SHOT_HULL, filter = pOwner, collisiongroup = COLLISION_GROUP_NONE } )
					if ( tmpTrace.Fraction < 1.0 ) then
						thisDistance = (tmpTrace.HitPos - vecSrc):Length()
						if ( thisDistance < distance ) then
							hitTrace = tmpTrace
							distance = thisDistance
						end
					end
				end
			end
		end
	else
		hitTrace = tmpTrace
	end
	return self.HitActivity;
end

function SWEP:ImpactWater(start, endpos)
	if bit.band( util.PointContents( start ), CONTENTS_WATER ) == CONTENTS_WATER then
		return false
	end

	if bit.band( util.PointContents( endpos ), CONTENTS_WATER ) != CONTENTS_WATER then
		return false
	end
	
	waterTrace = util.TraceLine({ start = start, endpos = endpos, mask = CONTENTS_WATER, filter=self.Owner, collisiongroup=COLLISION_GROUP_NONE })
	if ( waterTrace.Fraction < 1.0 ) then
		data = EffectData()
		data:SetOrigin(waterTrace.HitPos)
		data:SetFlags(0)
		data:SetNormal(waterTrace.Normal)
		data:SetScale(8.0)

		if bit.band( util.PointContents( start ), CONTENTS_SLIME ) == CONTENTS_SLIME then
			data:SetFlags(FX_WATER_IN_SLIME)
		end
		util.Effect( "watersplash", data )	
	end

	return true
end

function SWEP:ImpactEffect(traceHit)
	if self:ImpactWater(traceHit.StartPos, traceHit.HitPos) then
		return
	end
	self:ImpactTrace(traceHit,self.DamageType)
end

function SWEP:ImpactTrace(traceHit,dmgtype)

	data = EffectData()
	data:SetOrigin(traceHit.HitPos)
	data:SetStart(traceHit.StartPos)
	data:SetSurfaceProp(traceHit.SurfaceProps)
	data:SetDamageType(dmgtype)
	data:SetHitBox(traceHit.HitBox)
	if CLIENT then
		data:SetEntity(traceHit.Entity)
	else
		data:SetEntIndex(traceHit.Entity:EntIndex())
	end
	util.Effect( "Impact", data )
end

function SWEP:GetRange()
	return self.Primary.Range
end

function SWEP:Swing(IsSecondary)

	pOwner = self.Owner
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	swingStart = pOwner:GetShootPos( )
	forward = pOwner:GetAimVector()
	
	swingEnd = swingStart + forward * self:GetRange()
	traceHit = util.TraceLine({ start = swingStart, endpos = swingEnd, mask = MASK_SHOT_HULL, filter = pOwner, collisiongroup = COLLISION_GROUP_NONE })
	nHitActivity = self.HitActivity

	--CTakeDamageInfo triggerInfo( GetOwner(), GetOwner(), GetDamageForActivity( nHitActivity ), DMG_CLUB );
	--triggerInfo.SetDamagePosition( traceHit.startpos );
	--triggerInfo.SetDamageForce( forward );
	--TraceAttackToTriggers( triggerInfo, traceHit.startpos, traceHit.endpos, forward );

	if traceHit.Fraction == 1.0 then
		bludgeonHullRadius = 1.732 * self.BLUDGEON_HULL_DIM

		swingEnd = swingEnd - forward * bludgeonHullRadius

		traceHit = util.TraceHull({start = swingStart, endpos = swingEnd, mins = self.g_bludgeonMins, maxs = self.g_bludgeonMaxs, mask = MASK_SHOT_HULL, filter = pOwner, collisiongroup = COLLISION_GROUP_NONE})
		if traceHit.Fraction < 1.0 and traceHit.Entity then
			vecToTarget = traceHit.Entity:GetPos() - swingStart
			vecToTarget:Normalize()

			dot = vecToTarget:Dot(forward)

			if dot < 0.70721 then
				traceHit.Fraction = 1.0
			else
				nHitActivity = self:ChooseIntersectionPointAndActivity( traceHit, self.g_bludgeonMins, self.g_bludgeonMaxs, pOwner )
			end
		end
	end
	--	Miss
	if traceHit.Fraction == 1.0 then
		self:WeaponSound( self.SINGLE )
		if bIsSecondary then
			nHitActivity = ACT_VM_MISSCENTER2
		else
			nHitActivity = ACT_VM_MISSCENTER
		end

		testEnd = swingStart + forward * self:GetRange()
		self:ImpactWater( swingStart, testEnd )
	else
		self:Hit( traceHit, nHitActivity, bIsSecondary )
	end

	self:SendWeaponAnim( nHitActivity )
	self:SetWeaponIdleTime(CurTime() + self:SequenceDuration())

	self:SetNextPrimaryFire(CurTime() + self:GetFireRate())
	self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:AddViewKick()
end

function SWEP:GetFireRate()
	return 0.4
end