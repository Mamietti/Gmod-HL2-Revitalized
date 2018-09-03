SWEP.PrintName			= "Flare Gun"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 8
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_flaregun.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_flaregun.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "pistol"
SWEP.FiresUnderwater = true
SWEP.Base = "hlmachinegun_strafe"
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

function SWEP:DoPrimaryAttack()
	if self.Owner then
		if self:Clip1()<=0 then
			self:SendWeaponAnimIdeal(ACT_VM_DRYFIRE)
			self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		end
		self.m_nShotsFired = self.m_nShotsFired + 1

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
		offset = hand.Ang:Right() * 1 + hand.Ang:Forward() * 4.5 + hand.Ang:Up() * 3

		hand.Ang:RotateAroundAxis(hand.Ang:Right(), 0)
		hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 90)
		hand.Ang:RotateAroundAxis(hand.Ang:Up(), -90)

		self:SetRenderOrigin(hand.Pos + offset)
		self:SetRenderAngles(hand.Ang)

		self:DrawModel()
	end
end