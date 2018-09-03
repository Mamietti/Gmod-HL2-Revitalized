SWEP.PrintName			= "Sniper Rifle"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 8
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_sniper.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_sniper.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "ar2"
SWEP.FiresUnderwater = true
SWEP.Base = "hlmachinegun_strafe"
DEFINE_BASECLASS( "hlmachinegun_strafe" )
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SniperRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_SniperRifle.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SniperRifle.Reload"
SWEP.SPECIAL1 = "Weapon_SniperRifle.Special1"
SWEP.SPECIAL2 = "Weapon_SniperRifle.Special2"

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( Color(255, 220, 0, 255) )
    surface.SetMaterial( Material("sprites/w_icons2.vmt") )
    surface.DrawTexturedRectUV( x, y+tall*0.2, wide, tall/2, 0, 0.75, 0.5, 1 )
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
    self.m_fNextZoom = CurTime()
	self.m_nZoomLevel = 0
	self:SetSaveValue("m_fMinRange1",65)
	self:SetSaveValue("m_fMinRange2",65)
	self:SetSaveValue("m_fMaxRange1",1024)
	self:SetSaveValue("m_fMaxRange2",1024)
end

function SWEP:Holster()
    if self.Owner then
        if self.m_nZoomLevel != 0 then
            self.Owner:SetFOV(0, 0)
            self.m_nZoomLevel = 0
        end
    end
	return true
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_sniper_round"):GetInt()
end

function SWEP:GetFireRate()
	return 1
end

function SWEP:GetBulletSpread()
	return Vector(0,0,0)
end

function SWEP:DoSecondaryAttack()
    if CurTime()>=self.m_fNextZoom then
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
	if self.m_nZoomLevel >= 2 then
		self.Owner:SetFOV(0, 0)
        self.Owner:DrawViewModel(true)
        self:EmitSound(self.SPECIAL2)
        self.m_nZoomLevel = 0
	else
        self.Owner:SetFOV(g_nZoomFOV[self.m_nZoomLevel],0)
		if self.m_nZoomLevel == 0 then
            self.Owner:DrawViewModel(true)
		end
        self:EmitSound(self.SPECIAL1)
        self.m_nZoomLevel = self.m_nZoomLevel + 1
	end
    self.m_fNextZoom = CurTime() + 0.2
end

function SWEP:DoReload()
	if self:BaseDefaultReload(ACT_VM_RELOAD) then
        if self.m_nZoomLevel != 0 then
            self.Owner:SetFOV(0, 0)
            self.m_nZoomLevel = 0
        end       
		self:SetTimeWeaponIdle(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		self.FireStart = nil
	end
end