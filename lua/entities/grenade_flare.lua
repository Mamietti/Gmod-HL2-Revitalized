
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "FLARE"
ENT.Author = "Strafe"
ENT.Information = "FLARE"
ENT.Category = "NO"

ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT 

ENT.MinSize = 4
ENT.MaxSize = 128

local FLARE_DECAY_TIME = 3

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/flare.mdl" )
		self:SetSolid( SOLID_BBOX )
		self:AddSolidFlags( FSOLID_NOT_STANDABLE )
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
		self:SetSaveValue("m_bSmoke", true)
		self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
		self:SetFriction( 0.6 )
		self:SetGravity( 1 )
	end
	self.Sound = CreateSound(self,"Weapon_FlareGun.Burn")
	self.Sound:Play()
	self.m_flTimeBurnOut = CurTime() + 30
	self.m_flNextDamage = CurTime()
	self.m_nBounces = 0
	self.BurnTouch = false
	self:AddFlags(FL_OBJECT)
	self:NextThink(CurTime() + 0.5)
	if SERVER then
		flare = ents.Create("env_flare")
		flare:SetPos(self:GetPos())
		flare:SetAngles(self:GetAngles())
		flare:SetParent(self)
		flare:SetOwner(self)
		flare:Spawn()
		--PrintTable(flare:GetSaveTable())
	end
end

function ENT:Think()
	deltatime = self.m_flTimeBurnOut - CurTime()
	if deltatime <= FLARE_DECAY_TIME and !self.m_bFading then
		self.m_bFading = true
		self.Sound:ChangePitch(60, deltatime)
		self.Sound:FadeOut(deltatime)
	end
	if SERVER then
		if CurTime() > self.m_flTimeBurnOut then
			--self.Sound:Stop()
			self:Remove()
			return
		end
	end
	if self:WaterLevel()>1 then
	else
		if math.random(0,8)==1 then
			self:Sparks(self:GetPos())
		end
	end
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Sparks(pos)
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetStart( pos )
	effectdata:SetMagnitude( 1 )
	util.Effect( "Sparks", effectdata )
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Touch(ent)
	if !self.BurnTouch then
		if !ent:IsSolid() then
			return
		end
		if self.m_nBounces < 10 and self:WaterLevel()<1 then
			self:Sparks(self:GetPos())
		end
		if ent:GetSaveTable().m_takedamage > 0 then
			ent:Ignite(30)
			self:SetAbsVelocity(self:GetAbsVelocity() * 0.1)
			self.m_flTimeBurnOut = 0.5
		else
			tr = self:GetTouchTrace() 
			if self.m_nBounces == 0 then
				impactDir = tr.HitPos - tr.StartPos
				impactDir:Normalize()

				surfDot = tr.HitNormal:Dot( impactDir )

				if tr.HitNormal.z > -0.5 and surfDot < -0.9 then
					self:RemoveSolidFlags( FSOLID_NOT_SOLID )
					self:AddSolidFlags( FSOLID_TRIGGER )
					self:SetPos(tr.HitPos + ( tr.HitNormal * 2.0 ) )
					self:SetAbsVelocity(Vector(0,0,0))
					self:SetMoveType( MOVETYPE_NONE )
					
					self.BurnTouch = true
					util.Decal( "SmallScorch", tr.StartPos, tr.HitPos-tr.HitNormal, self )

					self:EmitSound("Flare.Touch")

					return
				end
			end
			self.m_nBounces = self.m_nBounces + 1
			self:SetOwner(self)
			self:SetGravity( 1.5 )
			vecNewVelocity = self:GetAbsVelocity()
			vecNewVelocity.x = vecNewVelocity.x * 0.8
			vecNewVelocity.y = vecNewVelocity.x * 0.8
			self:SetAbsVelocity(vecNewVelocity)
			if self:GetAbsVelocity():Length()<64 or self.m_nBounces == 3 then
				self:SetAbsVelocity(Vector(0,0,0))
				self:SetMoveType( MOVETYPE_NONE )
				self:RemoveSolidFlags( FSOLID_NOT_SOLID )
				self:AddSolidFlags( FSOLID_TRIGGER )
				self.BurnTouch = true
			end
		end
	else
		if ent:GetSaveTable().m_takedamage and CurTime()>=self.m_flNextDamage then
			d = DamageInfo()
			d:SetDamage( 1 )
			d:SetAttacker( self )
			d:SetDamageType( bit.bor(DMG_BULLET, DMG_BURN) )
			ent:TakeDamageInfo( d )
			self.m_flNextDamage = CurTime() + 1
		end
	end
end