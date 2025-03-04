SWEP.PrintName			= "HMG1"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Extended"
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

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
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
SWEP.SINGLE_NPC = "Weapon_M249.Single"
SWEP.EMPTY = "Weapon_Shotgun.Empty"
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_Shotgun.Special1"
SWEP.m_bReloadsSingly = false

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "z"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "z"

SWEP.m_fMinRange1 = 65
SWEP.m_fMaxRange1 = 2048

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

list.Add( "NPCUsableWeapons", { class = "weapon_hmg1",	title = "HMG1" }  )

function SWEP:GetNPCBurstSettings()
	return 3, 7, self.Primary.FireRate
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
	bulletInfo.Damage = GetConVar("sk_npc_dmg_ar2"):GetInt() * 1.75

	pOperator:FireBullets(bulletInfo)

	pOperator:MuzzleFlash();
	self:SetClip1(self:Clip1() - 1)
end
