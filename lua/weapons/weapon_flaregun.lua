SWEP.PrintName			= "FLARE GUN"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 1
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_flaregun.mdl"
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_flaregun.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = true

SWEP.HoldType			= "pistol"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "FlareRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_Flaregun.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = ""

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( Color(255, 255, 0, 255) )
    surface.SetMaterial( Material("sprites/w_icons1b.vmt") )
    texwide = wide*0.75*0.8
    textall = tall/2*0.8
    surface.DrawTexturedRectUV( x+(wide-texwide)/2, y+(tall-textall)/2, texwide, textall, 0.5, 0.25, 1, 0.5)
end

function SWEP:DoDrawCrosshair( x, y )
    height = ScrH()*0.016
	surface.SetDrawColor( Color(255, 150, 0, 255) )
    surface.SetMaterial( Material("sprites/crosshairs.vmt") )
    surface.DrawTexturedRectUV( x - height * 0.5, y - height * 0.5, height, height, 72/128, 48/128, 95/128, 71/128)
	return true
end

function SWEP:DoPrimaryAttack()
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

function SWEP:DrawWorldModel()
	if not self.Owner:IsValid() then
		self:DrawModel()
	else
		local hand, offset, rotate
		hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))
		offset = hand.Ang:Right() * 1 + hand.Ang:Forward() * 4 + hand.Ang:Up() * 3

		hand.Ang:RotateAroundAxis(hand.Ang:Right(), 90)
		hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 90)
		hand.Ang:RotateAroundAxis(hand.Ang:Up(), -90)

		self:SetRenderOrigin(hand.Pos + offset)
		self:SetRenderAngles(hand.Ang)

		self:DrawModel()
	end
end