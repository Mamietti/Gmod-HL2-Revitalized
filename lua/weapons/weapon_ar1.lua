SWEP.PrintName			= "AR1"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Extended"
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
SWEP.ViewModelFOV = 50

SWEP.CSMuzzleFlashes	= true
SWEP.HoldType			= "ar2"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.FireRate = 0.1

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
SWEP.SINGLE_NPC = "Weapon_AK47.Single"
SWEP.EMPTY = "Weapon_Shotgun.Empty"
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_Shotgun.Special1"
SWEP.m_bReloadsSingly = false

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "b"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "b"

SWEP.m_fMinRange1 = 65
SWEP.m_fMaxRange1 = 2048

if CLIENT then
	killicon.AddFont("weapon_ar1", "CSKillIcons", "b", Color(255, 100, 0, 255))
end

function SWEP:GetBulletSpread()
	return VECTOR_CONE_10DEGREES
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_smg1"):GetInt()
end

function SWEP:AddViewKick()
	self:DoMachineGunKick(self.MaxVerticalKick, self:GetFireDuration(), self.SlideLimit)
end

list.Add( "NPCUsableWeapons", { class = "weapon_ar1",	title = "AR1" }  )

function SWEP:GetNPCBurstSettings()
	return 2, 5, self.Primary.FireRate
end

function SWEP:GetNPCBulletSpread( proficiency )
	--Proficiency from poor to perfect
	spreadValue = {7, 5, 3, 5/3, 1}
	return spreadValue[proficiency]
end

function SWEP:FireNPCPrimaryAttack( pOperator, vecShootOrigin, vecShootDir )
	self:EmitSound( self.SINGLE_NPC );

	sound.EmitHint( bit.bor(SOUND_COMBAT, SOUND_CONTEXT_GUNFIRE), pOperator:GetPos(), SOUNDENT_VOLUME_MACHINEGUN, 0.2, pOperator);

	local bulletInfo = {}
	bulletInfo.Src = vecShootOrigin
	bulletInfo.Dir = vecShootDir
	bulletInfo.AmmoType = self:GetPrimaryAmmoType()
	bulletInfo.Damage = GetConVar("sk_npc_dmg_smg1"):GetInt()

	pOperator:FireBullets(bulletInfo)

	pOperator:MuzzleFlash();
	self:SetClip1(self:Clip1() - 1)
end
