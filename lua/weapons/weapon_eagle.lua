SWEP.PrintName			= "DESERT EAGLE"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Extended"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbase_machinegun_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbase_machinegun_strafe" )

SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModelFOV = 50

SWEP.CSMuzzleFlashes	= true
SWEP.HoldType			= "revolver"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 7
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"
SWEP.Primary.FireRate = 0.5
SWEP.Primary.BurstFireRate = 0.224

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "Weapon_DEagle.Single"
SWEP.EMPTY = "Weapon_SMG1.Empty"
SWEP.BURST = ""
SWEP.RELOAD = ""
SWEP.SPECIAL1 = "Weapon_AR2.Special1"
SWEP.SPECIAL2 = "Weapon_AR2.Special2"
SWEP.m_bReloadsSingly = false

--SWEP.EASY_DAMPEN = 0.5
SWEP.MaxVerticalKick = 1
SWEP.SlideLimit = 2
SWEP.KickMinX = 0.2
SWEP.KickMinY = 0.2
SWEP.KickMinZ = 0.1

SWEP.WeaponFont = "CSWeaponIconsLarge"
SWEP.WeaponLetter = "f"
SWEP.WeaponSelectedFont = "CSWeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = "f"

if CLIENT then
	killicon.AddFont("weapon_eagle", "CSKillIcons", "f", Color(255, 100, 0, 255))
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Int" , 3 , "FireMode" )
end

function SWEP:DrawHUD()
	if CLIENT then
		if self:GetFireMode() == 0 then
			local x, y
			if ( self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() ) then
				local tr = util.GetPlayerTrace( self.Owner )
				local trace = util.TraceLine( tr )
				local coords = trace.HitPos:ToScreen()
				x, y = coords.x, coords.y
			else
				x, y = ScrW() / 2, ScrH() / 2
			end

			surface.SetTexture( surface.GetTextureID( "sprites/redglow1" ) )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( x - 10, y - 10, 20, 20 )
		end
	end
end

--use only primary firesound for now
function SWEP:WeaponSound(sound)
	self:EmitSound(sound)
end

function SWEP:GetBulletSpread()
	if self:GetFireMode()==0 then
		return Vector(0, 0, 0)
	else
		return VECTOR_CONE_6DEGREES
	end
end

function SWEP:GetDamage()
    return GetConVar("sk_plr_dmg_357"):GetInt() * 0.85
end

function SWEP:AddViewKick()
	local angles = self.Owner:EyeAngles()

	angles.x = angles.x + math.random( -1, 1 )
	angles.x = angles.x + math.random( -1, 1 )
	angles.z = 0

	self.Owner:SetEyeAngles( angles )

	self.Owner:ViewPunch( Angle( -4, math.Rand( -2, 2 ), 0 ) );
end

function SWEP:GetFireRate()
	if self:GetFireMode()==0 then
		return self.Primary.FireRate
	else
		return self.Primary.BurstFireRate
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

function SWEP:GetSecondaryAttackActivity()
    return ACT_VM_SECONDARYATTACK
end

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_STAND ] 						= ACT_STAND
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SMG1

	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_SMG1
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH_SMG1

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_SMG1
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 				= ACT_RANGE_ATTACK_SMG1_LOW

	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SMG1

end