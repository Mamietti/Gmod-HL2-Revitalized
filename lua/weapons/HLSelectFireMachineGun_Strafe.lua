SWEP.PrintName			= "Test SMG BURST"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.UseHands			= true
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "smg"
SWEP.FiresUnderwater = false
SWEP.Base = "hlmachinegun_strafe"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.m_bReloadsSingly = false

SWEP.SINGLE = "Weapon_SMG1.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
SWEP.SPECIAL1 = "Weapon_SMG1.Special1"
SWEP.SPECIAL2 = "Weapon_SMG1.Special2"
SWEP.BURST = "Weapon_Pistol.Burst"

DEFINE_BASECLASS( "hlmachinegun_strafe" )

function SWEP:Initialize()
    self:SetNPCMinBurst( 3 )
    self:SetNPCMaxBurst( 3 )
    self:SetNPCFireRate( 0.05 )
    self:SetNPCMinRest( 0 )
    self:SetNPCMaxRest( 0 )
	self:SetSaveValue("m_fMinRange1",65)
	self:SetSaveValue("m_fMinRange2",65)
	self:SetSaveValue("m_fMaxRange1",1024)
	self:SetSaveValue("m_fMaxRange2",1024)
    self:SetHoldType(self.HoldType)
	self:SetTimeWeaponIdle(CurTime())
	self:SetNextEmptySoundTime(CurTime())
	self.m_nShotsFired = 0
	self.m_iBurstSize = 0
	self.m_iFireMode = 0
	self.ThinkMode = false
end

function SWEP:GetBurstCycleRate()
	return 0.5
end

function SWEP:GetFireRate()
	if self.m_iFireMode==0 then
		return 0.075
	else
		return 0.075
	end
end

function SWEP:Deploy()
	self.m_iBurstSize = 0
	BaseClass.Deploy(self)
end

function SWEP:DoPrimaryAttack()
	if self:GetSaveTable().m_bFireOnEmpty then
		return
	end
	if self.m_iFireMode==0 then
		BaseClass.DoPrimaryAttack(self)
		self:SetTimeWeaponIdle( CurTime() + 3.0 )
	else
		self.m_iBurstSize = self:GetBurstSize()
		
		self:BurstThink()
		self.ThinkMode = true
		self:SetNextPrimaryFire(CurTime() + self:GetBurstCycleRate())
		self:SetNextSecondaryFire(CurTime() + self:GetBurstCycleRate())

		self.NextoThink = CurTime() + self:GetFireRate()
	end
end

function SWEP:DoSecondaryAttack()
	if self.m_iFireMode==0 then
		self.m_iFireMode = 1
		self:EmitSound(self.SPECIAL2)
	else
		self.m_iFireMode = 0
		self:EmitSound(self.SPECIAL1)
	end
	
	self:SendWeaponAnimIdeal( self:GetSecondaryAttackActivity() )

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:BurstThink()
	toot = self:GetNextPrimaryFire()
	BaseClass.DoPrimaryAttack(self)
	self:SetNextPrimaryFire(toot)

	self.m_iBurstSize = self.m_iBurstSize - 1

	if self.m_iBurstSize <= 0 then
		self:SetTimeWeaponIdle( CurTime() )
		self.NextoThink = nil
		return
	end
	self.NextoThink = CurTime() + self:GetFireRate()
end

function SWEP:WeaponSound(sound)
	if sound == self.SINGLE then
		if self.m_iFireMode==0 then
			self:EmitSound(sound)
		else
			if( self.m_iBurstSize == self:GetBurstSize() and self:Clip1() >= self.m_iBurstSize ) then
				self:EmitSound(self.BURST)
			elseif( self:Clip1() < self.m_iBurstSize ) then
				self:EmitSound(sound)
			end
		end
		return
	end
	self:EmitSound(sound)
end

function SWEP:AddViewKick()
end

function SWEP:Think()
	if self.ThinkMode then
		if self.NextoThink!=nil then
			if CurTime()>self.NextoThink then
				self:BurstThink()
			end
		end
	end
	BaseClass.Think(self)
end

function SWEP:GetBurstSize()
	return 3
end