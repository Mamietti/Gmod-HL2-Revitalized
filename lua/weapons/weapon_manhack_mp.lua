SWEP.PrintName			= "MANHACK"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base               = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_manhack.mdl"
SWEP.ViewModelFOV = 74
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_manhack.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = false

SWEP.HoldType			= "slam"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Manhack"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextDeploy = nil

SWEP.WeaponLetter = "A"
SWEP.WeaponSelectedLetter = "A"

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Float", 5, "NextDeploy" )
    self:NetworkVar( "Bool", 6, "NeedDeploy" )
end

function SWEP:DoPrimaryAttack()
    self:SendWeaponAnimIdeal( ACT_VM_THROW )
    self:SetNextPrimaryFire(CurTime() + 1)
    local Forward = self.Owner:EyeAngles():Forward()
    self:EmitSound("Weapon_SLAM.TripMineMode")
    if SERVER then
        local ent = ents.Create( "npc_manhack" )
        if ( IsValid( ent ) ) then
            ent:SetPos( self.Owner:GetShootPos() + Forward * 32 )
            ent:SetAngles( self.Owner:EyeAngles() )
            ent:SetOwner( self.Owner )
            ent:SetKeyValue( "spawnflags", 65536 + 256)
            ent:Spawn()
            ent:SetSaveValue("m_bHackedByAlyx", true)
            ent:Fire("SetSquad", "!player_squad", 0)
            ent:GetPhysicsObject():ApplyForceCenter(Forward*100+Vector(0,0,500))
            ent:AddRelationship( "npc_zombie D_HT 99" )
            ent:AddRelationship( "npc_zombie_torso D_HT 99" )
            ent:AddRelationship( "npc_fastzombie D_HT 99" )
            ent:AddRelationship( "npc_fastzombie_torso D_HT 99" )
            ent:AddRelationship( "npc_zombine D_HT 99" )
            ent:SetSubMaterial(1, "models/weapons/manhack/manhack_sheet_r")
            ent:Fire("Unpack",0,0)
            ent:Fire("InteractivePowerDown",0,30)
            self:SetNextDeploy(CurTime() + 0.5)
            self:SetNeedDeploy(true)
            self:TakePrimaryAmmo(1)
        end
    end
end

function SWEP:ItemPreFrame()
    if self:GetNeedDeploy()==true and CurTime()>=self:GetNextDeploy() then
        self:Deploy()
        self:SetNeedDeploy(false)
    end
    BaseClass.ItemPreFrame(self)
end

function SWEP:Deploy()
    self:SetDeploySpeed( 1 )
    self:SendWeaponAnimIdeal(ACT_VM_DRAW)
    vm = self.Owner:GetViewModel()
    self.Weapon:SetNextPrimaryFire( CurTime() + vm:SequenceDuration()*1 )   
    self.Weapon:SetNextSecondaryFire( CurTime() + vm:SequenceDuration()*1) 
	return true
end