SWEP.PrintName			= "Dual Pistols"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 8
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_pistol_dual.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_alyx_gun.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "duel"
SWEP.FiresUnderwater = true
SWEP.Base = "hlmachinegun_strafe"
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize		= 36
SWEP.Primary.DefaultClip	= 36
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_Pistol.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_Pistol.Reload"

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_pistol"):GetInt()
end

function SWEP:GetFireRate()
	return 0.12
end

function SWEP:GetPrimaryAttackActivity()
	if ( self.m_nShotsFired < 1 ) then
		return ACT_VM_PRIMARYATTACK
    end
	if ( self.m_nShotsFired < 2 ) then
		return ACT_VM_RECOIL1
    end
	if ( self.m_nShotsFired < 3 ) then
		return ACT_VM_RECOIL2
    end
    return ACT_VM_RECOIL3;
end
