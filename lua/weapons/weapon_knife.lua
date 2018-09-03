SWEP.PrintName			= "Combat Knife"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 8
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_combatknife.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_combatknife.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "knife"
SWEP.FiresUnderwater = true
SWEP.Base = "hlbludgeonweapon_strafe"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_Pknife.Swing"
SWEP.MELEE_HIT = "Weapon_Knife.Hitwall"--"Weapon_Pknife.Melee_Hit"

SWEP.BLUDGEON_HULL_DIM = 16

function SWEP:ImpactEffect(traceHit)
	if self:ImpactWater(traceHit.StartPos, traceHit.HitPos) then
		return
	end
	self:ImpactTrace(traceHit,DMG_SLASH)
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
		info:SetDamageType(DMG_SLASH)

		self:CalculateMeleeDamageForce( info, hitDirection, traceHit.HitPos );
		traceHit.HitGroup = HITGROUP_CHEST --HACK AS F**K
		pHitEntity:DispatchTraceAttack( info, traceHit, hitDirection )
	end
	self:EmitSound( self.MELEE_HIT )
	self:ImpactEffect(traceHit)
end

function SWEP:SecondaryAttack()
	return false
end