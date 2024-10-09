SWEP.PrintName			= "AR1"
SWEP.Author			= "Strafe"
SWEP.Category	= "Counter-Life 2"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

SWEP.Slot				= 3
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"
SWEP.ViewModelFOV = 60

SWEP.CSMuzzleFlashes	= true
SWEP.HoldType			= "ar2"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.FireRate = 0.2

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

SWEP.SINGLE = "Weapon_AK47.Single"
SWEP.EMPTY = "Weapon_Shotgun.Empty"
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_Shotgun.Special1"
SWEP.m_bReloadsSingly = false

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "b"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "b"

if CLIENT then
	killicon.AddFont("weapon_ar1", "CSKillIcons", "b", Color(255, 100, 0, 255))
end

function SWEP:GetBulletSpread()
	return VECTOR_CONE_10DEGREES
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_ar2"):GetInt()
end

function SWEP:AddViewKick()
	self:DoMachineGunKick(self.MaxVerticalKick, self:GetFireDuration(), self.SlideLimit)
end

list.Add( "NPCUsableWeapons", { class = "weapon_ar1",	title = "AR1" }  )
