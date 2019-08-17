SWEP.PrintName			= "Flare Gun"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.Category           = "Half-Life 2 Extended"
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "pistol"
SWEP.FiresUnderwater = true
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "FlareRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_Flaregun.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = ""

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    local letter = "sd"
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( "WeaponIconsLarge" )
	local w, h = surface.GetTextSize(letter)
	surface.SetTextPos( x + ( wide - w ) / 2,
						y + ( tall - h ) / 2 )
                        
	surface.DrawText( letter )
    surface.SetFont( "WeaponIconsSelectedLarge" )
    	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
    surface.DrawText( letter )
end

function SWEP:DoDrawCrosshair( x, y )
    height = ScrH()*0.016
	surface.SetDrawColor( Color(255, 150, 0, 255) )
    surface.SetMaterial( Material("sprites/crosshairs.vmt") )
    surface.DrawTexturedRectUV( x - height * 0.5, y - height * 0.5, height, height, 72/128, 48/128, 95/128, 71/128)
	return true
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar( "Bool" , 5 , "NeedHolster" )
end

function SWEP:DoPrimaryAttack()
    if self:GetNeedHolster() then return end
	if self.Owner then
		if self:Clip1()<=0 then
			self:SendWeaponAnimIdeal(ACT_VM_DRYFIRE)
			self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		end

		self:TakePrimaryAmmo(1)
		self:SendWeaponAnimIdeal(ACT_VM_PRIMARYATTACK)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:SetNextPrimaryFire(CurTime() + 1)
		if SERVER then
			CFlare = ents.Create("grenade_flare")
			if !IsValid(CFlare) then return end
			CFlare:SetPos(self.Owner:GetShootPos())
			CFlare:SetAngles(self.Owner:EyeAngles())
			CFlare:SetOwner(self.Owner)
			CFlare:Spawn()
			CFlare:SetVelocity(self.Owner:EyeAngles():Forward()*1500)
		end
		self:WeaponSound(self.SINGLE)
	end
end

function SWEP:ItemPreFrame()
    if self:GetNeedHolster() then
        self:SendWeaponAnimIdeal(ACT_VM_DRAW)
        self:WeaponSound("Weapon_Shotgun.Reload")
        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
        self:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
        self:SetNeedHolster(false)
    end
    BaseClass.ItemPreFrame()
end

function SWEP:FinishReload()
    self:SetNeedHolster(true)
	BaseClass.FinishReload(self)
end

function SWEP:DoReload()
    return self:DefaultReloadAlt(ACT_VM_HOLSTER)
end