SWEP.PrintName			= "SMG2"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Extended"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbase_selectfiremachinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_selectfiremachinegun_strafe" )

SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"
SWEP.ViewModelFOV = 50

SWEP.CSMuzzleFlashes	= true
SWEP.HoldType			= "smg"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.FireRate = 0.075*1.25
SWEP.Primary.BurstFireRate = 0.05*1.25

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "Weapon_MP5Navy.Single"
SWEP.SINGLE_NPC = "Weapon_MP5Navy.Single"
SWEP.EMPTY = "Weapon_SMG1.Empty"
SWEP.BURST = ""
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_SMG1.Special1"
SWEP.SPECIAL2 = "Weapon_SMG1.Special2"
SWEP.m_bReloadsSingly = false

--SWEP.EASY_DAMPEN = 0.5
SWEP.MaxVerticalKick = 1
SWEP.SlideLimit = 2
SWEP.KickMinX = 0.2
SWEP.KickMinY = 0.2
SWEP.KickMinZ = 0.1

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "x"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "x"

SWEP.m_fMinRange1 = 0
SWEP.m_fMaxRange1 = 1400

if CLIENT then
	killicon.AddFont("weapon_smg2", "CSKillIcons", "x", Color(255, 100, 0, 255))
end

--use only primary firesound for now
function SWEP:WeaponSound(sound)
	self:EmitSound(sound)
end

function SWEP:GetBulletSpread()
	return VECTOR_CONE_2DEGREES
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_smg1"):GetInt() * 1.25
end

function SWEP:AddViewKick()
	self:DoMachineGunKick(self.MaxVerticalKick, self:GetFireDuration(), self.SlideLimit)
end

list.Add( "NPCUsableWeapons", { class = "weapon_smg2",	title = "SMG2" }  )

function SWEP:GetNPCBurstSettings()
	return 2, 5, self.Primary.FireRate
end

function SWEP:GetNPCBulletSpread( proficiency )
	--Proficiency from poor to perfect
	spreadValue = {7, 5, 10/3, 5/3, 1}
	return spreadValue[proficiency]
end

function SWEP:FireNPCPrimaryAttack( pOperator, vecShootOrigin, vecShootDir )
	self:EmitSound( self.SINGLE_NPC );

	sound.EmitHint( bit.bor(SOUND_COMBAT, SOUND_CONTEXT_GUNFIRE), pOperator:GetPos(), SOUNDENT_VOLUME_MACHINEGUN, 0.2, pOperator);

	local bulletInfo = {}
	bulletInfo.Src = vecShootOrigin
	bulletInfo.Dir = vecShootDir
	bulletInfo.AmmoType = self:GetPrimaryAmmoType()
	bulletInfo.Damage = GetConVar("sk_npc_dmg_smg1"):GetInt() * 1.25

	pOperator:FireBullets(bulletInfo)

	pOperator:MuzzleFlash();
	self:SetClip1(self:Clip1() - 1)
end