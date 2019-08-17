SWEP.PrintName			= "LEAD PIPE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.Category           = "Half-Life 2 Extended"
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 0
SWEP.SlotPos			= 4
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_mattpipe.mdl"
SWEP.WorldModel			= "models/props_canal/mattpipe.mdl"
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "melee"
SWEP.FiresUnderwater = true
SWEP.Base = "weapon_hl2mpbasebludgeon_strafe"

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

SWEP.SINGLE = "Weapon_Crowbar.Single"
SWEP.MELEE_HIT = "Weapon_Crowbar.Melee_Hit"--"Weapon_Pknife.Melee_Hit"

SWEP.BLUDGEON_HULL_DIM = 16

function SWEP:SecondaryAttack()
	return false
end

function SWEP:GetFireRate()
	return 0.8
end

function SWEP:GetDamageForActivity()
	return 40
end