SWEP.PrintName			= "HMG1"
SWEP.Author			= "Strafe"
SWEP.Category	= "Counter-Life 2"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

SWEP.Slot				= 3
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"
SWEP.ViewModelFOV = 60

SWEP.CSMuzzleFlashes	= true
SWEP.HoldType			= "ar2"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "HelicopterGun"
SWEP.Primary.FireRate = 0.07

---SWEP.EASY_DAMPEN = 0.5
SWEP.MaxVerticalKick = 2
SWEP.SlideLimit = 1.5
SWEP.KickMinX = 0.8
SWEP.KickMinY = 0.8
SWEP.KickMinZ = 0.2

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "Weapon_M249.Single"
SWEP.EMPTY = "Weapon_Shotgun.Empty"
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_Shotgun.Special1"
SWEP.m_bReloadsSingly = false

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "z"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "z"

if CLIENT then
	killicon.AddFont("weapon_hmg1", "CSKillIcons", "z", Color(255, 100, 0, 255))
end

function SWEP:GetBulletSpread()
	return VECTOR_CONE_7DEGREES
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_ar2"):GetInt() * 1.75
end

function SWEP:AddViewKick()
	self.Owner:SetVelocity(self.Owner:GetAimVector()*-20)
	self:DoMachineGunKick(self.MaxVerticalKick, self:GetFireDuration(), self.SlideLimit)
end
