SWEP.PrintName			= "ALYX GUN"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_alyx_gun.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_alyx_gun.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "pistol"
SWEP.FiresUnderwater = true
SWEP.Base = "weapon_hl2mpbase_selectfiremachinegun_strafe"
SWEP.ViewModelFOV = 45

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AlyxGun"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_Alyx_Gun.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_Pistol.Reload"

DEFINE_BASECLASS( "weapon_hl2mpbase_selectfiremachinegun_strafe" )

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_alyxgun"):GetInt()
end

function SWEP:GetFireRate()
	if self:GetFireMode()==0 then
		return 0.1
	else
		return 0.05
	end
end

function SWEP:OnDrop()
    local ent = ents.Create("weapon_alyxgun")
    ent:SetPos(self:GetPos())
    ent:SetAngles(self:GetAngles())
    ent:Spawn()
    self:Remove()
end

function SWEP:AddViewKick()
    self:DoMachineGunKick( 1, self:GetFireDuration(), 5)
end

function SWEP:HandleFireOnEmpty()
	if self:GetFireOnEmpty() then
		self:ReloadOrSwitchWeapons()
		self:SetFireDuration(0)
	else
		if CurTime() > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			temps = CurTime() + 0.5
			self:SetNextEmptySoundTime(temps)
            self:SendWeaponAnimIdeal(ACT_VM_DRYFIRE)
		end
		self:SetFireOnEmpty(true)
	end
end