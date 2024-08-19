SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"

SWEP.HoldType			= "smg"

SWEP.Primary.BulletSpread = VECTOR_CONE_3DEGREES

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetShotsFired(0)
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Int" , 0 , "ShotsFired" )
end

function SWEP:DoPrimaryAttack()
	if (self:UsesClipsForAmmo1() and self:Clip1()<=0) or (!self:UsesClipsForAmmo1() and self.Owner:GetAmmoCount(self.Primary.Ammo)) then
        return
    end

    self:SetShotsFired(self:GetShotsFired() + 1)
    
	if self.Owner then

        self:MuzzleFlash()

        self:SendWeaponAnimIdeal( self:GetPrimaryAttackActivity() )

        self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local info = {}
		info.Src 		= self.Owner:GetShootPos()			-- Source
		info.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
		info.Spread 	= self:GetBulletSpread()		-- Aim Cone
		info.Tracer	= 2									-- Show a tracer on every x bullets 
		info.AmmoType = self.Primary.Ammo
		info.Damage = self:GetDamage()

        info.Tracer	= self.Primary.TracerRate
        if self.Primary.TracerOverride != nil then
            info.TracerName = self.Primary.TracerOverride
        end
        
        self:WeaponSound(self.SINGLE)
        fireRate = self:GetFireRate()
        self:SetNextPrimaryFire(CurTime() + fireRate)

        if self:UsesClipsForAmmo1() then
            self:SetClip1(self:Clip1()-1)
        else
            self:RemoveAmmo(1, self.Primary.AmmoType)
        end
        
        self:FireBullets(info)
        self:AddViewKick()
    end
end

function SWEP:FireBullets(info)
    self.Owner:FireBullets(info)
end

function SWEP:DoMachineGunKick( maxVerticleKickAngle, fireDurationTime, slideLimitTime)
	KICK_MIN_X	= 0.2
	KICK_MIN_Y	= 0.2
	KICK_MIN_Z	= 0.1
	vecScratch = Angle(0,0,0)
	duration	= math.min(fireDurationTime,slideLimitTime)
	kickPerc = duration / slideLimitTime

	self.Owner:ViewPunchReset( 10 )

	vecScratch.x = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) )
	vecScratch.y = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3
	vecScratch.z = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8

	if math.random(0,1)==0 then
		vecScratch.y = vecScratch.y * -1
	end

	if math.random(0,1)==0 then
		vecScratch.z = vecScratch.z * -1
	end

	self.Owner:ViewPunch( vecScratch * 0.5 )
end

function SWEP:Deploy()
    self:SetShotsFired(0)
    return BaseClass.Deploy( self )
end

function SWEP:ItemPostFrame()
    if !self.Owner:KeyDown(IN_ATTACK) then
        self:SetShotsFired(0)
    end
    BaseClass.ItemPostFrame( self )
end