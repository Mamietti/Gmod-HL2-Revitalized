SWEP.PrintName			= "TAU CANNON"

SWEP.Author			= "Strafe"
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.Base               = "weapon_hl2mpbasehlmpcombatweapon_strafe"
DEFINE_BASECLASS( "weapon_hl2mpbasehlmpcombatweapon_strafe" )

SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/v_gauss.mdl"
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/w_gauss.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = false

SWEP.HoldType			= "shotgun"

SWEP.Primary.FireRate = 0.25
SWEP.Primary.BulletSpread = Vector(0,0,0)
SWEP.Primary.TracerOverride = "HelicopterTracer"
SWEP.Primary.TracerRate = 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "GaussEnergy"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = "PropJeep.FireCannon"
SWEP.EMPTY = "Weapon_IRifle.Empty"

SWEP.m_fMinRange1 = 65
SWEP.m_fMinRange2 = 65
SWEP.m_fMaxRange1 = 1024
SWEP.m_fMaxRange2 = 1024

SWEP.NextDeploy = nil
SWEP.StartTime = nil
SWEP.DamageMult = 0
SWEP.Sound = nil


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( "HL2HUDFONT" )
	local w, h = surface.GetTextSize("h")

	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( "h" )
end

function SWEP:FireBeam(dmgbonus)
    self:EmitSound( self.SINGLE )
    
    local forward = self.Owner:EyeAngles():Forward()
    local up = self.Owner:EyeAngles():Up()
    local right = self.Owner:EyeAngles():Right()  
    local shootpos = self.Owner:GetShootPos()+right*10+forward*20-up*8
    
    local trace = nil   
    if self.Owner.GetEyeTrace!=nil then
        trace = self.Owner:GetEyeTrace()
    end
    
    local bullet = {}
    bullet.Attacker = self.Owner
    bullet.Inflictor = self
    bullet.Num 		= self.Primary.Number
    bullet.HullSize = 0
    bullet.Src 		= self.Owner:GetShootPos()
    bullet.Dir 		= self.Owner:GetAimVector()
    bullet.TracerName = ""
    bullet.Tracer	= 0
    bullet.AmmoType = "GaussEnergy"
    bullet.Damage	= 20 + dmgbonus*20
    bullet.Force    = 1 + dmgbonus*5
    bullet.Callback = function(attacker,tr,dmginfo)
        trace = tr
        --shootpos = self.Owner:GetShootPos()
    end
    
    self.Owner:FireBullets(bullet)
    
    local effectdata2 = EffectData()
    effectdata2:SetOrigin( trace.HitPos)
    effectdata2:SetStart(shootpos)
    effectdata2:SetScale(6000)
    effectdata2:SetAngles( Vector(trace.HitPos-shootpos):Angle())
    effectdata2:SetNormal(trace.HitNormal )
    effectdata2:SetEntity( trace.Entity )
    effectdata2:SetSurfaceProp( trace.SurfaceProps )
    effectdata2:SetHitBox( trace.HitBox )
    effectdata2:SetFlags(0)
    util.Effect( "GaussTracer", effectdata2, false, true)
    
    if SERVER then
    local hit = ents.Create("info_particle_system")
    hit:SetPos(trace.HitPos)
    hit:SetName("target"..tostring(self.Owner))
    hit:SetAngles(self:GetAngles())

    local zappy = ents.Create( "env_beam" )
        zappy:SetPos(shootpos)
        zappy:SetKeyValue( "life", "0" )
        zappy:SetKeyValue( "BoltWidth", "0.5" )
        zappy:SetKeyValue( "NoiseAmplitude", "1" )
        zappy:SetKeyValue( "damage", "0" )
        zappy:SetKeyValue( "Spawnflags", "17" )
        zappy:SetKeyValue( "texture", "sprites/laserbeam.vtf" )
        zappy:SetName("beam"..tostring(self.Owner))
        zappy:SetKeyValue( "LightningStart", zappy:GetName() )
        zappy:SetKeyValue("LightningEnd", hit:GetName() )
        zappy:SetColor(Color(255,255,255,100))
        zappy:Spawn()
        zappy:Activate()
        
        hit:Fire("kill",0,0.1)
        zappy:Fire("kill",0,0.1)
    end
    
    util.Decal("RedGlowFade", trace.HitPos+trace.HitNormal, trace.HitPos-trace.HitNormal)
end

function SWEP:PrimaryAttack()
	if self.Owner:IsNPC() or self:Ammo1()>1 then
		if self.Owner:WaterLevel()!=3 then
			self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate)
            self:FireBeam(0)
            if !self.Owner:IsNPC() then
                self.FireStart = CurTime()
                self:AddViewKick()
                self:ShootEffects(self)
                self:TakePrimaryAmmo(2)
                self.NextIdle = CurTime() + self:SequenceDuration()
            end
        else
            self.Weapon:EmitSound( self.Primary.EmptySound )
            self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
		end
        if self.Owner:IsNPC() then
            if !timer.Exists(tostring(self.Owner:EntIndex())) then
                timer.Create( tostring(self.Owner:EntIndex()), self.Primary.FireRate, 3, function() 
                    if IsValid(self) and IsValid(self.Owner) and self:Clip1()>0 and self.Owner:GetEnemy() then
                        self:PrimaryAttack()
                    end
                end )
            end
        end
    else
        self.Weapon:EmitSound( self.Primary.EmptySound )
        self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
	end
end

function SWEP:SecondaryAttack()
    local view = self.Owner:GetViewModel()
    if self:Ammo1()>1 then
        if self.DamageMult==0 then
            local sound = CreateSound(self,"weapons/gauss/chargeloop.wav")
            sound:Play()
            sound:ChangePitch( 255, 2 )
            self.Sound = sound
            self.ZapTime = CurTime() + 10
            self:TakePrimaryAmmo(2)
            view:SendViewModelMatchingSequence( view:LookupSequence("spin") )
            self.NextIdle = nil
        end
        if self.DamageMult<5 then
            self.DamageMult = self.DamageMult + 1
            self:TakePrimaryAmmo(2)
        end
    end
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:DrawWorldModel()
	if not self.Owner:IsValid() then
		self:DrawModel()
	else
		local hand, offset, rotate
		hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))
		offset = hand.Ang:Right() * 0 + hand.Ang:Forward() * 2 + hand.Ang:Up() * 0

		hand.Ang:RotateAroundAxis(hand.Ang:Right(), 20)
		hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 0)
		hand.Ang:RotateAroundAxis(hand.Ang:Up(), 170)

		self:SetRenderOrigin(hand.Pos + offset)
		self:SetRenderAngles(hand.Ang)
        self:SetModelScale( 0.5, 0)

		self:DrawModel()
	end
end

function SWEP:Think()
    BaseClass.Think(self)
    if self.Owner:IsNPC() then return end
    if self.ZapTime!=nil and CurTime()>=self.ZapTime then
        self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
        self.Weapon:EmitSound("ReallyLoudSpark" )
        self.Owner:TakeDamage(50)
        self:ResetSecondary()
    end
    if self.Owner:KeyReleased(IN_ATTACK2) and self.DamageMult>0 then
        self:FireBeam(self.DamageMult)
        self.Owner:SetVelocity(-self.Owner:GetAimVector()*75*self.DamageMult)
        self:ResetSecondary()
    end
end

function SWEP:ResetSecondary()
    self:ShootEffects(self)
    self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
    self:SetNextSecondaryFire(CurTime() + 1.5)
    self:SetNextPrimaryFire(CurTime() + 1.5)
    self.DamageMult = 0
    self.ZapTime = nil
    self.NextIdle = CurTime() + self:SequenceDuration()
    self.Sound:Stop()
end
--[[
function SWEP:PostDrawViewModel(view)
    bone = view:LookupBone("spinner")
    boner = view:LookupBone("fan")
    if self.Owner:KeyDown( IN_ATTACK2 ) and (view:GetSequenceActivity( view:GetSequence() )==ACT_VM_PULLBACK_LOW or view:GetSequenceActivity( view:GetSequence() )==ACT_VM_PULLBACK) then
        view:ManipulateBoneAngles( boner, Angle(0,0,1000)*CurTime() )
        if view:GetSequenceActivity( view:GetSequence() )==ACT_VM_PULLBACK_LOW then
            view:ManipulateBoneAngles( bone, Angle(0,0,500)*CurTime() )
        else
            view:ManipulateBoneAngles( bone, Angle(0,0,1000)*CurTime() )
        end
    end
end
]]--
function SWEP:Holster(wep)
	timer.Stop( "weapon_idle" .. self:EntIndex() )
    if self.Sound!=nil then
        self.Sound:Stop()
    end
	return true
end

function SWEP:OnRemove()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
    if self.Sound!=nil then
        self.Sound:Stop()
    end
end

function SWEP:Initialize()
	if ( SERVER ) then
		self:SetNPCMinBurst( 2 )
		self:SetNPCMaxBurst( 5 )
		self:SetNPCFireRate( self.Primary.Delay )
	end
	self:SetWeaponHoldType("shotgun")
end

function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	if ( t == "shotgun" ) then
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_SMG1
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SMG1_RELAXED
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SMG1_STIMULATED
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_SMG1

	self.ActivityTranslateAI [ ACT_RUN ] 					= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH_SHOTGUN

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_SHOTGUN
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_SHOTGUN_LOW
	
	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SHOTGUN
	return end	
end

list.Add( "NPCUsableWeapons", { class = "weapon_gauss",	title = "Tau Cannon" }  )