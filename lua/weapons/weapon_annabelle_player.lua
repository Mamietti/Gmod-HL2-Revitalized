SWEP.PrintName			= "Annabelle"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 1
SWEP.SlotPos			= 8
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_shotgun.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_annabelle.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "shotgun"
SWEP.FiresUnderwater = true
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.SINGLE = "Weapon_Shotgun.Single"
SWEP.EMPTY = "Weapon_Shotgun.Empty"
SWEP.RELOAD = "Weapon_Shotgun.Reload"
SWEP.SPECIAL1 = "Weapon_Shotgun.Special1"
SWEP.m_bReloadsSingly = true

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetHoldType(self.HoldType)
	self:SetWeaponIdleTime(CurTime())
	self:SetNextEmptySoundTime(CurTime())
    
    self.m_bDelayedFire1 = false
    self.m_bInReload = false
end

function SWEP:Deploy()
    print("DIPS")
    if CLIENT then
        self.Owner:GetViewModel():SetMaterial("models/weapons/v_shotgun/vshotgun_albedo_annabelle")
    end
    BaseClass.Deploy(self)
    self:CallOnClient( 'Deploy' )
    return true
end

function SWEP:Holster()
    print("HOES")
    if CLIENT then
        self.Owner:GetViewModel():SetMaterial("")
    end
    return true
end

function SWEP:DoPrimaryAttack()
	if self.Owner then
        self:WeaponSound(self.SINGLE)

        self:MuzzleFlash()

        self:SendWeaponAnimIdeal( ACT_VM_PRIMARYATTACK );

        self.Owner:SetAnimation( PLAYER_ATTACK1 );

        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
        self:SetClip1(self:Clip1()-1)

        local bullet = {}
		bullet.Src 		= self.Owner:GetShootPos()			-- Source
		bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
		bullet.Spread 	= self:GetBulletSpread()		-- Aim Cone
		bullet.Tracer	= 0									-- Show a tracer on every x bullets 
		bullet.AmmoType = self.Primary.Ammo
		bullet.Damage = self:GetDamage()
		self.Owner:FireBullets(bullet)
        
        self.Owner:ViewPunch( Angle( math.Rand( -2, -1 ), math.Rand( -2, 2 ), 0 ) )

        if self:Clip1()>0 then
            self.m_bNeedPump = true
        end
    end
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_357"):GetInt()
end

function SWEP:GetFireRate()
    return 0.7
end

function SWEP:OnDrop()
    local ent = ents.Create("weapon_annabelle")
    ent:SetPos(self:GetPos())
    ent:SetAngles(self:GetAngles())
    ent:Spawn()
    self:Remove()
end

function SWEP:StartReload()
	if !self.Owner then
		return false
    end

	if self:Ammo1() <= 0 then
		return falses
    end

	if self:Clip1() >= self:GetMaxClip1() then
		return false
    end
    
    if self:Clip1() <= 0 then
        self.m_bNeedPump = true
    end

	j = math.min(1, self:Ammo1())

	if (j <= 0) then
		return false
    end
    
	self:SendWeaponAnimIdeal( ACT_SHOTGUN_RELOAD_START )

	self:SetBodygroup(1,0)

	self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.01)

	self.m_bInReload = true
    
    if SERVER then
        self.Owner:SetAnimation( PLAYER_RELOAD )
    end

	return true
end

function SWEP:Think()
	if !self.Owner then return end
	if self.m_bInReload then
		if self.Owner:KeyDown(IN_ATTACK) and self:Clip1() >=1 then
			self.m_bInReload = false
			self.m_bNeedPump = false
			self.m_bDelayedFire1 = true
		elseif CurTime() >= self:GetNextPrimaryFire() then
			if self:Ammo1() <=0 then
				self:FinishReload()
				return
			elseif self:Clip1() < self:GetMaxClip1() then
				self:DoReload()
				return
			else
				self:FinishReload()
				return
			end
		end
	else
		self:SetBodygroup(1,1)
    end
	if self.m_bNeedPump and CurTime()>=self:GetNextPrimaryFire() then
		self:Pump()
		return
    end
    if self.m_bDelayedFire1 and CurTime()>=self:GetNextPrimaryFire() then
        self.m_bDelayedFire1 = false
        self:DoPrimaryAttack()
    end
	if self.Owner:KeyDown(IN_RELOAD) and self:UsesClipsForAmmo1() and !self.m_bInReload then
		self:StartReload()
	else
		self.m_bFireOnEmpty = false;

		if !self:HasAmmo() and CurTime()>=self:GetNextPrimaryFire() then
            return
		else
			if self:Clip1() <= 0 and CurTime()>=self:GetNextPrimaryFire() then
				if self:StartReload() then
					return
                end
            end
        end
        self:WeaponIdle()
    end
end

function SWEP:PrimaryAttack()
    if (self:Clip1() <= 0 and self:UsesClipsForAmmo1()) or (!self:UsesClipsForAmmo1() and self:Ammo1()>0 ) then
        if self:Ammo1()<=0 then
            self:DryFire()
        else
            self:StartReload()
        end
    elseif self.Owner:WaterLevel()==3 and self.FiresUnderwater==false then
        self:WeaponSound(self.EMPTY)
        self:SetNextPrimaryFire(CurTime() + 0.2)
        return
    else
        if self.Owner and self.Owner:KeyPressed(IN_ATTACK) then
            self:SetNextPrimaryFire(CurTime())
        end
        self:DoPrimaryAttack()
    end
end

function SWEP:DoReload()
	if !self.m_bInReload then
		print("called in fail")
	end
	
	if !self.Owner then
		return false
    end

	if self:Ammo1() <= 0 then
		return false
    end

	if self:Clip1() >= self:GetMaxClip1() then
		return false
    end

	j = math.min(1, self:Ammo1())

	if (j <= 0) then
		return false
    end

	self:FillClip()
	self:WeaponSound(self.RELOAD)
	self:SendWeaponAnimIdeal( ACT_VM_RELOAD )

    self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.01)

	return true
end

function SWEP:FinishReload()
	if self.Owner then
        self:SetBodygroup(1,1)
        self.m_bInReload = false
        self:SendWeaponAnimIdeal( ACT_SHOTGUN_RELOAD_FINISH )
        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.01)
	end
end

function SWEP:FillClip()
	if !self.Owner then
		return
    end
	if self:Ammo1() > 0 then
		if self:Clip1() < self:GetMaxClip1() then
			self:SetClip1(self:Clip1()+1)
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo )
        end
	end
end

function SWEP:DryFire()
    self:WeaponSound( self.EMPTY )

    self:SendWeaponAnimIdeal( ACT_VM_DRYFIRE )
    self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.01)
end

function SWEP:Pump()
	if self.Owner then
        self.m_bNeedPump = false
        
        self:WeaponSound( self.SPECIAL1 )

        self:SendWeaponAnimIdeal( ACT_SHOTGUN_PUMP )
        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.01)
    end
end

function SWEP:Reload()
end