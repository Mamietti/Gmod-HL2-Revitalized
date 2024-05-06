SWEP.PrintName			= "SNIPER RIFLE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 3
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_sniper.mdl"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_sniper.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = false

SWEP.HoldType			= "ar2"

SWEP.Primary.FireRate = 1
SWEP.Primary.BulletSpread = Vector(0,0,0)
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SniperRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "Weapon_SniperRifle.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SniperRifle.Reload"
SWEP.SPECIAL1 = "Weapon_SniperRifle.Special1"
SWEP.SPECIAL2 = "Weapon_SniperRifle.Special2"

SWEP.m_fMinRange1 = 65
SWEP.m_fMinRange2 = 65
SWEP.m_fMaxRange1 = 1024
SWEP.m_fMaxRange2 = 1024

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( Color(255, 220, 0, 255) )
    surface.SetMaterial( Material("sprites/w_icons2.vmt") )
    surface.DrawTexturedRectUV( x, y+tall*0.2, wide, tall/2, 0, 0.80, 0.5, 1 )
end

function SWEP:DrawHUD()
	if self.Owner:GetFOV()<= 60 then
		local x = ScrW()
		local y = ScrH()
		local w = x/2
		local h = y/2

		surface.SetTexture(surface.GetTextureID("sprites/reticle"))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x/2-y*0.101, y/2-y*0.1, y*0.2, y*0.2)
	end
end

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetNextZoom(CurTime())
	self:SetZoomLevel(0)
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar( "Float" , 5 , "NextZoom" )
    self:NetworkVar( "Int" , 5 , "ZoomLevel" )
end

function SWEP:Holster()
    if self.Owner then
        if self:GetZoomLevel() != 0 then
            self.Owner:SetFOV(0, 0)
            self:SetZoomLevel(0)
        end
    end
	return true
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_sniper_round"):GetInt()
end

function SWEP:DoSecondaryAttack()
    if CurTime()>=self:GetNextZoom() then
        self:Zoom()
    end
end

function SWEP:Zoom()
    g_nZoomFOV = {}
    g_nZoomFOV[0] = 20
    g_nZoomFOV[1] = 5
	if !self.Owner then
        return
    end
	if self:GetZoomLevel() >= 2 then
		self.Owner:SetFOV(0, 0)
        self.Owner:DrawViewModel(true)
        self:EmitSound(self.SPECIAL2)
        self:SetZoomLevel(0)
	else
        self.Owner:SetFOV(g_nZoomFOV[self:GetZoomLevel()],0)
		if self:GetZoomLevel() == 0 then
            self.Owner:DrawViewModel(true)
		end
        self:EmitSound(self.SPECIAL1)
        self:SetZoomLevel(self:GetZoomLevel() + 1)
	end
    self:SetNextZoom(CurTime() + 0.2)
end

function SWEP:DoReload()
	if self:DefaultReloadAlt(ACT_VM_RELOAD) then
        if self:GetZoomLevel() != 0 then
            self.Owner:SetFOV(0, 0)
            self:SetZoomLevel(0)
        end       
		self:SetWeaponIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end
end