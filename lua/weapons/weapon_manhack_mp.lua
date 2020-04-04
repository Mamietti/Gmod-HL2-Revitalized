SWEP.PrintName			= "MANHACK"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.Category           = "Half-Life 2 Extended"
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.ViewModel			= "models/weapons/c_manhack.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_manhack.mdl"
SWEP.CSMuzzleFlashes	= false
SWEP.HoldType			= "slam"
SWEP.FiresUnderwater = false
SWEP.Base               = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )
SWEP.ViewModelFOV = 74

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

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    local letter = "A"
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