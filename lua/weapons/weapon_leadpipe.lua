SWEP.PrintName			= "LEAD PIPE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbasebludgeon_strafe"

SWEP.Slot				= 0
SWEP.SlotPos			= 4
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_mattpipe.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/props_canal/mattpipe.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = true

SWEP.HoldType			= "melee"

SWEP.SINGLE = "Weapon_Crowbar.Single"
SWEP.MELEE_HIT = "Weapon_Crowbar.Melee_Hit"

SWEP.WeaponLetter = "n"
SWEP.WeaponSelectedLetter = "n"

function SWEP:SecondaryAttack()
	return false
end

function SWEP:GetFireRate()
	return 0.8
end

function SWEP:GetDamageForActivity()
	return 40
end