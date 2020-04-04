SWEP.PrintName			= "ANNABELLE"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2"
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 3
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_annabelle.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_annabelle.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "shotgun"
SWEP.FiresUnderwater = true
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )
--SWEP.ViewModelFOV = 55

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

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    local letter = "qb"
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

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetHoldType(self.HoldType)
	self:SetWeaponIdleTime(CurTime())
	self:SetNextEmptySoundTime(CurTime())
    self:SetDelayedFire(false)
    self:SetInReload(false)
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar( "Bool" , 4 , "DelayedFire" )
    self:NetworkVar( "Bool" , 5 , "NeedPump" )
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
		self:FireBullets(bullet)
        
        self.Owner:ViewPunch( Angle( math.Rand( -2, -1 ), math.Rand( -2, 2 ), 0 ) )

        if self:Clip1()>0 then
            self:SetNeedPump(true)
        end
    end
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_357"):GetInt()
end

function SWEP:GetBulletSpread()
    return VECTOR_CONE_PRECALCULATED
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
		return false
    end

	if self:Clip1() >= self:GetMaxClip1() then
		return false
    end
    
    if self:Clip1() <= 0 then
        self:SetNeedPump(true)
    end

	j = math.min(1, self:Ammo1())

	if (j <= 0) then
		return false
    end
    
	self:SendWeaponAnimIdeal( ACT_SHOTGUN_RELOAD_START )

	self:SetBodygroup(1,0)

	self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())

	self:SetInReload(true)
    
    if SERVER then
        self.Owner:SetAnimation( PLAYER_RELOAD )
    end

	return true
end

function SWEP:ItemPreFrame()
	if !self.Owner then return end
	if self:GetInReload() then
		if self.Owner:KeyDown(IN_ATTACK) and self:Clip1() >=1 then
			self:SetInReload(false)
			self:SetNeedPump(false)
			self:SetDelayedFire(true)
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
	if self:GetNeedPump() and CurTime()>=self:GetNextPrimaryFire() then
		self:Pump()
		return
    end
    if self:GetDelayedFire() and CurTime()>=self:GetNextPrimaryFire() then
        self:SetDelayedFire(false)
        self:DoPrimaryAttack()
    end
	if self.Owner:KeyDown(IN_RELOAD) and self:UsesClipsForAmmo1() and !self:GetInReload() then
		self:StartReload()
	else
		self:SetFireOnEmpty(false)

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
	if !self:GetInReload() then
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

    self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())

	return true
end

function SWEP:FinishReload()
	if self.Owner then
        self:SetBodygroup(1,1)
        self:SetInReload(false)
        self:SendWeaponAnimIdeal( ACT_SHOTGUN_RELOAD_FINISH )
        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
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
    self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
end

function SWEP:Pump()
	if self.Owner then
        self:SetNeedPump(false)
        
        self:WeaponSound( self.SPECIAL1 )

        self:SendWeaponAnimIdeal( ACT_SHOTGUN_PUMP )
        self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    end
end

function SWEP:Reload()
end