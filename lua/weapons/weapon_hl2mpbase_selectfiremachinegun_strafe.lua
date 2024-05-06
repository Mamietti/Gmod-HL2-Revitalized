SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true

SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

SWEP.Primary.FireRate = 0.075

SWEP.Primary.BurstCycleRate = 0.5
SWEP.Primary.BurstCount = 3
SWEP.Primary.BurstFireRate = 0.05

SWEP.BURST = ""

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
	return self.Primary.BurstCycleRate
end

function SWEP:GetFireRate()
	if self:GetFireMode()==0 then
		return self.Primary.FireRate
	else
		return self.Primary.BurstFireRate
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
		self:WeaponSound(self.SPECIAL2)
	else
		self:SetFireMode(0)
		self:WeaponSound(self.SPECIAL1)
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
	return self.Primary.BurstCount
end

function SWEP:GetSecondaryAttackActivity()
    return ACT_VM_SECONDARYATTACK
end