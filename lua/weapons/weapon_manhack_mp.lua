SWEP.PrintName			= "Manhack"
SWEP.Author			= "Strafe"
SWEP.Category	= "Half-Life 2 Plus"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_manhack.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_manhack.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "slam"
SWEP.FiresUnderwater = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Manhack"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.NextDeploy = nil
function SWEP:PrimaryAttack()
    if self:Ammo1()>0 then
        self:SendWeaponAnim( ACT_VM_THROW )
        self:SetNextPrimaryFire(CurTime() + 2)
        local Forward = self.Owner:EyeAngles():Forward()
        self:EmitSound("Weapon_SLAM.TripMineMode")
        local ent = ents.Create( "npc_manhack" )
        if ( IsValid( ent ) ) then
            ent:SetPos( self.Owner:GetShootPos() + Forward * 32 )
            ent:SetAngles( self.Owner:EyeAngles() )
            ent:SetOwner( self.Owner )
            ent:SetKeyValue( "spawnflags", 65536 + 256)
            ent:Spawn()
			ent:SetSaveValue("m_bHackedByAlyx", true)
			ent:Fire("SetSquad","player_squad",0)
			ent:GetPhysicsObject():ApplyForceCenter(Forward*100+Vector(0,0,500))
            ent:AddRelationship( "npc_zombie D_HT 99" )
            ent:AddRelationship( "npc_zombie_torso D_HT 99" )
            ent:AddRelationship( "npc_fastzombie D_HT 99" )
            ent:AddRelationship( "npc_fastzombie_torso D_HT 99" )
            ent:AddRelationship( "npc_zombine D_HT 99" )
			ent:SetSubMaterial(1, "models/weapons/manhack/manhack_sheet_r")
            ent:Fire("Unpack",0,0)
            self.NextDeploy = CurTime() + 1
            self:TakePrimaryAmmo(1)
            ent:Fire("InteractivePowerDown",0,30)
        end
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end
function SWEP:Think()
    if self.NextDeploy!=nil and CurTime()>=self.NextDeploy then
        self:Deploy()
        self.NextDeploy = nil
    end
end
function SWEP:Deploy()
    self:SetDeploySpeed( 1 )
    self:SendWeaponAnim(ACT_VM_DRAW)
    self.Weapon:SetNextPrimaryFire( CurTime() + self:SequenceDuration()*1 )   
    self.Weapon:SetNextSecondaryFire( CurTime() + self:SequenceDuration()*1)
    self.NextIdle = CurTime() + self:SequenceDuration()  
	return true
end