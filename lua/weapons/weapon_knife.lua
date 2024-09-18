SWEP.PrintName			= "KNIFE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbasebludgeon_strafe"

SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = true

SWEP.HoldType			= "melee2"

SWEP.SINGLE = "Weapon_Knife.Miss"
SWEP.MELEE_HIT = "Weapon_Knife.Hit"

SWEP.WeaponLetter = "n"
SWEP.WeaponSelectedLetter = "n"

function SWEP:SecondaryAttack()
	return false
end

function SWEP:GetFireRate()
	return 0.4
end

function SWEP:GetDamageForActivity()
	return 25
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
	return ACT_VM_PRIMARYATTACK;
end

function SWEP:Swing(IsSecondary)

	pOwner = self.Owner
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	swingStart = pOwner:GetShootPos( )
	forward = pOwner:GetAimVector()
	
	swingEnd = swingStart + forward * self:GetRange()
	traceHit = util.TraceLine({ start = swingStart, endpos = swingEnd, mask = MASK_SHOT_HULL, filter = pOwner, collisiongroup = COLLISION_GROUP_NONE })
	nHitActivity = ACT_VM_PRIMARYATTACK

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

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_STAND ] 						= ACT_STAND
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY
	self.ActivityTranslateAI [ ACT_MP_WALK ] 					= ACT_HL2MP_WALK_MELEE
	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_MELEE
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH_MELEE

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_GESTURE_MELEE_ATTACK1

end