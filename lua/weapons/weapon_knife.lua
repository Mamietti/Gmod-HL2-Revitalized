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

SWEP.Category           = "Counter-Life 2"
SWEP.FiresUnderwater = true

SWEP.HoldType			= "melee2"

SWEP.SINGLE = "Weapon_Knife.Slash"
SWEP.MELEE_HIT = "Weapon_Knife.Hit"

SWEP.HitActivity = ACT_VM_PRIMARYATTACK
SWEP.DamageType = DMG_SLASH

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "j"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "j"

if CLIENT then
	killicon.AddFont("weapon_knife", "CSKillIcons", "j", Color(255, 100, 0, 255))
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:GetFireRate()
	return 0.4
end

function SWEP:GetDamageForActivity()
	return GetConVar("sk_plr_dmg_crowbar"):GetInt() * 2
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