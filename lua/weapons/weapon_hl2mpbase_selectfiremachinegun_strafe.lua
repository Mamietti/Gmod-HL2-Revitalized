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
SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"

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

DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

function SWEP:Initialize()
    BaseClass.Initialize( self )
	self:SetThinkMode(false)
    self:SetBurstSize(0)
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Int" , 2 , "BurstSize" )
    self:NetworkVar( "Int" , 3 , "FireMode" )
    self:NetworkVar( "Bool" , 4 , "ThinkMode" )
    self:NetworkVar( "Float" , 5 , "NextThink" )
    self:NetworkVar( "Int" , 0 , "ShotsFired" )
end

function SWEP:GetBurstCycleRate()
	return 0.5
end

function SWEP:GetFireRate()
	if self:GetFireMode()==0 then
		return 0.075
	else
		return 0.05
	end
end

function SWEP:Deploy()
	self:SetBurstSize(0)
	return BaseClass.Deploy(self)
end

function SWEP:DoPrimaryAttack()
	if self:GetFireOnEmpty() then
		return
	end
	if self:GetFireMode()==0 then
		BaseClass.DoPrimaryAttack( self )
		self:SetWeaponIdleTime( CurTime() + 3.0 )
	else
		self:SetBurstSize(self:GetBurstCount())
		
		self:BurstThink()
		self:SetThinkMode(true)
		--self:SetNextPrimaryFire(CurTime() + self:GetBurstCycleRate())
		--self:SetNextSecondaryFire(CurTime() + self:GetBurstCycleRate())

		self:SetNextThink(CurTime() + self:GetFireRate())
	end
end

function SWEP:DoSecondaryAttack()
	if self:GetFireMode()==0 then
		self:SetFireMode(1)
		self:EmitSound(self.SPECIAL2)
	else
		self:SetFireMode(0)
		self:EmitSound(self.SPECIAL1)
	end
	
	self:SendWeaponAnimIdeal( self:GetSecondaryAttackActivity() )

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:BurstThink()
	BaseClass.DoPrimaryAttack( self )

	self:SetBurstSize(self:GetBurstSize() - 1)

	if self:GetBurstSize() <= 0 then
        --HACKHACK: Fix broken firerate
        self:SetNextPrimaryFire(CurTime() + self:GetBurstCycleRate() - (self:GetFireRate() * self:GetBurstCount()))
        self:SetNextSecondaryFire(CurTime() + self:GetBurstCycleRate() - (self:GetFireRate() * self:GetBurstCount()))
        
        --The burst is over!
		self:SetThinkMode(false)
        
        --idle immediately to stop the firing animation
		self:SetWeaponIdleTime( CurTime() )
		return
	end
	self:SetNextThink(CurTime() + self:GetFireRate())
end

function SWEP:WeaponSound(sound)
	if sound == self.SINGLE then
		if self:GetFireMode()==0 then
			self:EmitSound(sound)
		else
			if( self:GetBurstSize() == self:GetBurstCount() and self:Clip1() >= self:GetBurstSize() ) then
				self:EmitSound(self.BURST)
			elseif( self:Clip1() < self:GetBurstSize() ) then
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
	if self:GetThinkMode() then
		if self:GetNextThink()!=nil then
            if CurTime()>self:GetNextThink() then
				self:BurstThink()
			end
		end
    else
        BaseClass.Think(self)
    end
end

function SWEP:GetBurstCount()
	return 3
end

function SWEP:GetSecondaryAttackActivity()
    return ACT_VM_SECONDARYATTACK
end