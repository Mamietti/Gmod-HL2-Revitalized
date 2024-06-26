SWEP.PrintName			= "ALYX GUN"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_alyx_gun.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_alyx_gun.mdl"

SWEP.FiresUnderwater = true

SWEP.HoldType			= "pistol"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AlyxGun"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.m_bReloadsSingly = false

if ( !IsMounted( "ep2" ) ) then
    SWEP.SINGLE = "Weapon_Pistol.NPC_Single"
else
    SWEP.SINGLE = "Weapon_Alyx_Gun.Single"
end
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_Pistol.Reload"

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( Color(255, 255, 0, 255) )
    surface.SetMaterial( Material("sprites/w_icons1b.vmt") )
    texwide = wide*0.75*0.8
    textall = tall/2*0.8
    surface.DrawTexturedRectUV( x+(wide-texwide)/2, y+(tall-textall)/2, texwide, textall, 0.5, 0.5, 1, 0.75)
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_alyxgun"):GetInt()
end

function SWEP:GetFireRate()
    return 0.1
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

function SWEP:DoReload()
	--self:WeaponSound( self.RELOAD )
    BaseClass.DoReload(self)
end