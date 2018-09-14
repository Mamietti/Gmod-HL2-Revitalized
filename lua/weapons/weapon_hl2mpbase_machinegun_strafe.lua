SWEP.PrintName			= "Test SMG"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.HoldType			= "smg"
SWEP.Base = "weapon_hl2mpbasehlmpcombatweapon_strafe"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFOV = 54

DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self.m_nShotsFired = 0
end

function SWEP:DoPrimaryAttack()
	if self:UsesClipsForAmmo1() and !self:Clip1() then
		self:DoReload()
		return
    end

    self.m_nShotsFired = self.m_nShotsFired + 1
    
	if self.Owner then

        self:MuzzleFlash()

        self:SendWeaponAnimIdeal( self:GetPrimaryAttackActivity() )

        self.Owner:SetAnimation( PLAYER_ATTACK1 );
		local bullet = {}
		bullet.Src 		= self.Owner:GetShootPos()			-- Source
		bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
		bullet.Spread 	= self:GetBulletSpread()		-- Aim Cone
		bullet.Tracer	= 2									-- Show a tracer on every x bullets 
		bullet.AmmoType = self.Primary.Ammo
		bullet.Damage = self:GetDamage()
        
        self:WeaponSound(self.SINGLE)
        fireRate = self:GetFireRate()
        self:SetNextPrimaryFire(CurTime() + fireRate)

        if self:UsesClipsForAmmo1() then
            self:SetClip1(self:Clip1()-1)
        else
            self:RemoveAmmo(1, self.Primary.AmmoType)
        end
        
        self.Owner:FireBullets(bullet)
        self:AddViewKick()
    end
end

function SWEP:DoMachineGunKick( maxVerticleKickAngle, fireDurationTime, slideLimitTime)
	KICK_MIN_X	= 0.2
	KICK_MIN_Y	= 0.2
	KICK_MIN_Z	= 0.1
	vecScratch = Angle(0,0,0)
	duration	= math.min(fireDurationTime,slideLimitTime)
	kickPerc = duration / slideLimitTime

	self.Owner:ViewPunchReset( 10 );

	vecScratch.x = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) )
	vecScratch.y = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3
	vecScratch.z = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8

	if math.random(0,1)==0 then
		vecScratch.y = vecScratch.y * -1
	end

	if math.random(0,1)==0 then
		vecScratch.z = vecScratch.z * -1
	end

	--UTIL_ClipPunchAngleOffset( vecScratch, pPlayer->m_Local.m_vecPunchAngle, QAngle( 24.0f, 3.0f, 1.0f ) );

	self.Owner:ViewPunch( vecScratch * 0.5 )
end

function SWEP:Deploy()
    self.m_nShotsFired = 0
    return true
end

function SWEP:Think()
    if !self.Owner:KeyDown(IN_ATTACK) then
        self.m_nShotsFired = 0
    end
end