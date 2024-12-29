SWEP.PrintName			= "MOLOTOV"
SWEP.Author			= "Strafe"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.Base               = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 4
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_bb_bottle.mdl"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/weapons/w_molotov.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = false

SWEP.HoldType			= "grenade"

SWEP.Primary.FireRate = 0.25
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "grenade"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = ""
SWEP.EMPTY = ""

SWEP.m_fMinRange1 = 200
SWEP.m_fMaxRange1 = 1000

SWEP.WeaponLetter = "h"
SWEP.WeaponSelectedLetter = "h"

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables( self )
    self:NetworkVar( "Bool", 0, "NeedDraw" )
end

function SWEP:ThrowMolotov(vecSrc, vecVelocity)

    if SERVER then
        pMolotov = ents.Create("grenade_molotov")
        if !IsValid(pMolotov) then
            return
        end

        pMolotov:SetPos(vecSrc)
        pMolotov:SetAngles(self.Owner:EyeAngles())
        --pMolotov:SetThrower(self.Owner)

        pMolotov:Spawn()
        pMolotov:SetOwner(self.Owner)
        pMolotov:Activate()

        pMolotov:SetVelocity(vecVelocity)
        local angVel = Angle(math.random(-100, -500), math.random(-100, -500), math.random(-100, -500))
        pMolotov:SetLocalAngularVelocity(angVel)
    end
end

function SWEP:DoPrimaryAttack()
    pPlayer = self.Owner

	if !pPlayer:IsPlayer() then
		return
    end

	--vecSrc		= pPlayer:WorldSpaceCenter()
	--vecFacing	= pPlayer:direct
	--vecSrc				= vecSrc + vecFacing * 18.0;
	// BUGBUG: is this some hack because it's not at the eye position????
	--vecSrc.z		   += 24.0f;
    local vecSrc = pPlayer:EyePos()
    local vecFacing = pPlayer:GetAimVector()

	// Player may have turned to face a wall during the throw anim in which case
	// we don't want to throw the SLAM into the wall
	--if ObjectInWay() then
		--vecSrc  = pPlayer->WorldSpaceCenter() + vecFacing * 5.0;
    --end

	--Vector vecAiming = pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );
	--vecAiming.z += 0.20; // Raise up so passes through reticle
    local vecAimingo = vecFacing
    vecAimingo.z = vecAimingo.z + 0.20

	self:ThrowMolotov(vecSrc, vecAimingo*800);
	pPlayer:RemoveAmmo( 1, self.Primary.Ammo );

    self:SendWeaponAnimIdeal(ACT_VM_THROW)
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	// Don't fire again until fire animation has completed
	vm = self.Owner:GetViewModel()
    self.Weapon:SetNextPrimaryFire( CurTime() + vm:SequenceDuration()*1 )   
    self.Weapon:SetNextSecondaryFire( CurTime() + vm:SequenceDuration()*1) 

	self:SetNeedDraw(true)
end

function SWEP:DrawAmmo()
    // -------------------------------------------
	// Make sure I have ammo of the current type
	// -------------------------------------------
	pOwner = self.Owner
	if pOwner:GetAmmoCount(self.Primary.Ammo) <=0 then
        if SERVER then
            pOwner:DropWeapon(self)
            self:Remove()
        end
		return;
    end
	--("Drawing Molotov...\n");
	self:SetNeedDraw(false)

	self:SendWeaponAnimIdeal(ACT_VM_DRAW)
    vm = self.Owner:GetViewModel()
    self.Weapon:SetNextPrimaryFire( CurTime() + vm:SequenceDuration()*1 )   
    self.Weapon:SetNextSecondaryFire( CurTime() + vm:SequenceDuration()*1) 
end

function SWEP:ItemPostFrame( void )
	if self:GetNeedDraw() and self:GetNextPrimaryFire() <= CurTime() then
		self:DrawAmmo();
    end
    BaseClass.ItemPreFrame(self)
end

list.Add( "NPCUsableWeapons", { class = "weapon_molotov",	title = "Molotov" }  )

function SWEP:VecCheckToss(pNPC, launchPos, vecTarget, 1.0)

    // Get Toss Vector
    Vector			throwStart  = pNPC->Weapon_ShootPosition();
    Vector			vecToss;
    CBaseEntity*	pBlocker	= NULL;
    float			throwDist	= (throwStart - vecTarget).Length();
    float			fGravity	= GetCurrentGravity();
    float			throwLimit	= pNPC->ThrowLimit(throwStart, vecTarget, fGravity, 35, WorldAlignMins(), WorldAlignMaxs(), pEnemy, &vecToss, &pBlocker);

    // If I can make the throw (or most of the throw)
    if (!throwLimit || (throwLimit != throwDist && throwLimit > 0.8*throwDist))
    {
    return vecToss;
end

function SWEP:GetNPCBulletSpread( proficiency )
	return 0
end

function SWEP:FireNPCPrimaryAttack( pNPC, vecShootOrigin, vecShootDir )

    local pEnemy = pNPC:GetEnemy();
    if !IsValid(pEnemy) then
        return
    end

    local vec_target = pEnemy:GetPos()

    // -----------------------------------------------------
    //  Get position of throw
    // -----------------------------------------------------
    // If owner has a hand, set position to the hand bone position
    local launchPos = nil
    local iBIndex = pNPC:LookupBone("ValveBiped.Bip01_R_Hand");
    if (iBIndex != -1) then
        launchPos = pNPC:GetBonePosition( iBIndex)
    else 
        local vFacingDir = vecShootDir
        vFacingDir = vFacingDir * 60.0; 
        launchPos = pNPC:GetPos()+vFacingDir;
    end


    local vecTossVelocity = VecCheckToss( pNPC, launchPos, vec_target, 1.0 );

    ThrowMolotov( launchPos, vecTossVelocity);

    // Drop the weapon and remove as no more ammo
    pNPC:DropWeapon(self)
    self:Remove()
end

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}

	-- Default is pistol/revolver for reasons
	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI[ ACT_GESTURE_RANGE_ATTACK1 ]	= ACT_GESTURE_RANGE_ATTACK_THROW
end