SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.DrawWeaponInfoBox = false
SWEP.Base = "weapon_base"
DEFINE_BASECLASS( "weapon_base" )

SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.ViewModelFOV = 54

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.HoldType			= "pistol"

SWEP.Primary.Damage = 5
SWEP.Primary.FireRate = 0
SWEP.Primary.BulletSpread = VECTOR_CONE_15DEGREES
SWEP.Primary.TracerOverride = nil
SWEP.Primary.TracerRate = 2
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.SINGLE = ""
SWEP.EMPTY = ""
SWEP.DEPLOY = ""
SWEP.RELOAD = ""
SWEP.SPECIAL1 = ""
SWEP.SPECIAL2 = ""
SWEP.SPECIAL3 = ""

SWEP.m_fMinRange1 = 65
SWEP.m_fMinRange2 = 65
SWEP.m_fMaxRange1 = 1024
SWEP.m_fMaxRange2 = 1024

SWEP.m_bMeleeWeapon = false
SWEP.m_bReloadsSingly = false
SWEP.m_bFiresUnderwater = false

SWEP.WeaponFont = "WeaponIconsLarge"
SWEP.WeaponLetter = nil
SWEP.WeaponSelectedFont = "WeaponIconsSelectedLarge"
SWEP.WeaponSelectedLetter = nil

SWEP.IconMaterial = Material("sprites/w_icons2.vmt")

VECTOR_CONE_PRECALCULATED = vec3_origin
VECTOR_CONE_1DEGREES = Vector( 0.00873, 0.00873, 0.00873 )
VECTOR_CONE_2DEGREES = Vector( 0.01745, 0.01745, 0.01745 )
VECTOR_CONE_3DEGREES = Vector( 0.02618, 0.02618, 0.02618 )
VECTOR_CONE_4DEGREES = Vector( 0.03490, 0.03490, 0.03490 )
VECTOR_CONE_5DEGREES = Vector( 0.04362, 0.04362, 0.04362 )
VECTOR_CONE_6DEGREES = Vector( 0.05234, 0.05234, 0.05234 )
VECTOR_CONE_7DEGREES = Vector( 0.06105, 0.06105, 0.06105 )
VECTOR_CONE_8DEGREES = Vector( 0.06976, 0.06976, 0.06976 )
VECTOR_CONE_9DEGREES = Vector( 0.07846, 0.07846, 0.07846 )
VECTOR_CONE_10DEGREES = Vector( 0.08716, 0.08716, 0.08716 )
VECTOR_CONE_15DEGREES = Vector( 0.13053, 0.13053, 0.13053 )
VECTOR_CONE_20DEGREES = Vector( 0.17365, 0.17365, 0.17365 )

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	if self.WeaponLetter != nil and self.WeaponSelectedLetter != nil then
		surface.SetDrawColor( color_transparent )
		surface.SetTextColor( 255, 220, 0, alpha )
		surface.SetFont( self.WeaponFont )
		local w, h = surface.GetTextSize(self.WeaponLetter)
		surface.SetTextPos( x + ( wide - w ) / 2,
							y + ( tall - h ) / 2 )
							
		surface.DrawText( self.WeaponLetter )
		surface.SetFont( self.WeaponSelectedFont )
		surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
		surface.DrawText( self.WeaponSelectedLetter )		
	elseif eu then
		surface.SetDrawColor( Color(255, 220, 0, 255) )
		surface.SetMaterial( self.IconMaterial )
		surface.GetTextureSize()
		surface.DrawTexturedRectUV( x, y+tall*0.2, wide, tall/2, 0, 0.80, 0.5, 1 )
	end
end

function SWEP:GetBulletSpread()
    return self.Primary.BulletSpread
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Float" , 0 , "WeaponIdleTime" )
    self:NetworkVar( "Float" , 1 , "FireDuration" )
    self:NetworkVar( "Float" , 2 , "NextEmptySoundTime" )
    self:NetworkVar( "Bool" , 0 , "InReload" )
    self:NetworkVar( "Bool" , 1 , "FireOnEmpty" )
end

function SWEP:UsesPrimaryAmmo()
    return self.Primary.Ammo != "none"
end

function SWEP:UsesSecondaryAmmo()
    return self.Secondary.Ammo != "none"
end

function SWEP:HasPrimaryAmmo()
    --If I use a clip, and have some ammo in it, then I have ammo
	if self:UsesClipsForAmmo1() then
		if self:Clip1() > 0 then
			return true
        end
	end

	if self.Owner then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
			return true
        end
	end

    return false
end

function SWEP:HasSecondaryAmmo()
    --If I use a clip, and have some ammo in it, then I have ammo
	if self:UsesClipsForAmmo2() then
		if self:Clip2() > 0 then
			return true
        end
	end

	if self.Owner then
		if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > 0 then
			return true
        end
	end

    return false
end

function SWEP:UsesClipsForAmmo1()
    return self:GetMaxClip1()!=-1
end

function SWEP:UsesClipsForAmmo2()
    return self:GetMaxClip2()!=-1
end

function SWEP:Think()
    if ( not self.m_bInitialized ) then
		self:Initialize()
	end
    self:ItemPreFrame()
    self:ItemPostFrame()
end

function SWEP:GetDefaultClip1()
	return self.Primary.DefaultClip
end

function SWEP:GetDefaultClip2()
	return self.Secondary.DefaultClip
end

function SWEP:IsMeleeWeapon()
    return self.m_bMeleeWeapon
end

function SWEP:ItemPreFrame()

end

function SWEP:HasWeaponIdleTimeElapsed()
	if ( CurTime() > self:GetWeaponIdleTime() ) then
		return true
    end
	return false
end

function SWEP:ItemPostFrame()
	if !self.Owner then return end
    local pOwner = self.Owner

	--self:UpdateAutoFire();

    if self.Owner:KeyDown(IN_ATTACK) then
        self:SetFireDuration(self:GetFireDuration() + FrameTime())
    else
        self:SetFireDuration(0)
    end

	if self:UsesClipsForAmmo1() then
		self:CheckReload()
	end

	if (!(pOwner:KeyDown(IN_ATTACK) or (pOwner:KeyDown(IN_ATTACK2) or (self:CanReload() and pOwner:KeyDown(IN_RELOAD))))) then
		--no fire buttons down or reloading
		if !self:ReloadOrSwitchWeapons() and self:GetInReload() == false then
            --HACKHACK: make it care about firing
            if CurTime() < self:GetNextPrimaryFire() then return end
			self:WeaponIdle()
        end
    end
end

function SWEP:WeaponIdle()
    if self:HasWeaponIdleTimeElapsed() then
        self:SendWeaponAnimIdeal(ACT_VM_IDLE)
    end
end

function SWEP:SendWeaponAnimIdeal(iActivity)
    self:SendWeaponAnim(iActivity)
    local vm = self.Owner:GetViewModel()
    self:SetWeaponIdleTime(CurTime() + vm:SequenceDuration(vm:SelectWeightedSequence(iActivity)))
end

function SWEP:CanReload()
    return true
end

function SWEP:CheckReload()
	if self.m_bReloadsSingly then
		if !self.Owner then return end

		if self:GetInReload() and CurTime()>=self:GetNextPrimaryFire() then
			if (self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2)) and self:Clip1() > 0 then
				self:SetInReload(false)
				return
			end

            -- If out of ammo end reload
			if self.Owner:GetAmmoCount(self.Primary.Ammo) <=0 then
				self:FinishReload()
				return
			--If clip not full reload again
			elseif self:Clip1() < self:GetMaxClip1() then
				self:SetClip1(self:Clip1()+1)
				self.Owner:RemoveAmmo( 1, self.Primary.Ammo )
				self:DoReload()
				return
			--Clip full, stop reloading
			else
                self:FinishReload()
                self:SetNextPrimaryFire(CurTime())
                self:SetNextSecondaryFire(CurTime())
				return;
            end
		end
	else
		if self:GetInReload() and CurTime()>=self:GetNextPrimaryFire() then
			self:FinishReload()
			self:SetNextPrimaryFire(CurTime())
			self:SetNextSecondaryFire(CurTime())
			self:SetInReload(false)
        end
    end
end

function SWEP:FinishReload()
	if self.Owner then
		if self:UsesClipsForAmmo1() then
			local primary	= math.min(self:GetMaxClip1() - self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo))
			self:SetClip1(self:Clip1() + primary)
			self.Owner:RemoveAmmo( primary, self.Primary.Ammo )
		end

		--If I use secondary clips, reload secondary
		if self:UsesClipsForAmmo2() then
			local secondary	= math.min(self:GetMaxClip2() - self:Clip2(), self.Owner:GetAmmoCount(self.Secondary.Ammo))
			self:SetClip2(self:Clip2() + primary)
			self.Owner:RemoveAmmo( secondary, self.Secondary.Ammo )
		end
		if self.m_bReloadsSingly then
			self:SetInReload(false)
        end
    end
end

function SWEP:ReloadOrSwitchWeapons()
	if !self.Owner then return end

	self:SetFireOnEmpty(false)

	-- If we don't have any ammo, switch to the next best weapon
	if !self:HasAnyAmmo() and CurTime() > self:GetNextPrimaryFire() and CurTime() > self:GetNextSecondaryFire() then
		--weapon isn't useable, switch.
		-- if ( ( (GetWeaponFlags() & ITEM_FLAG_NOAUTOSWITCHEMPTY) == false ) && ( g_pGameRules->SwitchToNextBestWeapon( pOwner, this ) ) )
		-- {
			-- m_flNextPrimaryAttack = gpGlobals->curtime + 0.3;
			-- return true;
		-- }
	else
		--Weapon is useable. Reload if empty and weapon has waited as long as it has to after firing
		if self:UsesClipsForAmmo1() and !self:AutoFiresFullClip() and self:Clip1() == 0 and CurTime() > self:GetNextPrimaryFire() and CurTime() > self:GetNextSecondaryFire() then
			--if we're successfully reloading, we're done
			if self:DoReload() then
				return true
            end
		end
	end

    return false
end

function SWEP:AutoFiresFullClip()
    return false
end

function SWEP:HasAnyAmmo()
	-- If I don't use ammo of any kind, I can always fire
	if !self:UsesPrimaryAmmo() and !self:UsesSecondaryAmmo() then
		return true
    end

	-- Otherwise, I need ammo of either type
	return self:HasPrimaryAmmo() or self:HasSecondaryAmmo()
end

function SWEP:DoReload()
    return self:DefaultReloadAlt(ACT_VM_RELOAD)
end

function SWEP:Reload()
    if CurTime() >= self:GetNextPrimaryFire() and self:UsesClipsForAmmo1() and !self:GetInReload() then
        self:DoReload()
        self:SetFireDuration(0)
    end
end

function SWEP:DefaultReloadAlt(iActivity)
    if !self.Owner then return false end

	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		return false
    end

	local bReload = false

	--If you don't have clips, then don't try to reload them.
	if self:UsesClipsForAmmo1() then
		--need to reload primary clip?
		local primary	= math.min(self:GetMaxClip1() - self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo))
		if primary != 0 then
			bReload = true
		end
	end

	if self:UsesClipsForAmmo2() then
		--need to reload secondary clip?
		local secondary	= math.min(self:GetMaxClip2() - self:Clip2(), self.Owner:GetAmmoCount(self.Secondary.Ammo))
		if secondary != 0 then
			bReload = true
		end
	end

	if !bReload then
		return false
    end

	self:WeaponSound( self.RELOAD )
	self:SendWeaponAnimIdeal( iActivity )

	if self.Owner:IsPlayer() then
		self.Owner:SetAnimation( PLAYER_RELOAD )
	end

    local vm = self.Owner:GetViewModel()
	local flSequenceEndTime = CurTime() + vm:SequenceDuration(vm:SelectWeightedSequence(iActivity))
	self:SetNextPrimaryFire(flSequenceEndTime)
    self:SetNextSecondaryFire(flSequenceEndTime)

	self:SetInReload(true)

    return true
end

function SWEP:WeaponSound(sounde)
    self:EmitSound(sounde)
end

function SWEP:Holster()
    return true
end

function SWEP:PrimaryAttack()
    --Clip empty? Or out of ammo on a no-clip weapon?
    if !self:IsMeleeWeapon() and (( self:UsesClipsForAmmo1() and self:Clip1() <= 0) or ( !self:UsesClipsForAmmo1() and self.Owner:GetAmmoCount(self.Primary.Ammo)<=0 )) then
        self:HandleFireOnEmpty()
    elseif self.Owner:WaterLevel() == 3 and self.m_bFiresUnderwater == false then
        --This weapon doesn't fire underwater
        self:WeaponSound(self.EMPTY)
        self:SetNextPrimaryFire(CurTime() + 0.2)
        return
    else
        --NOTENOTE: There is a bug with this code with regards to the way machine guns catch the leading edge trigger
        --			on the player hitting the attack key.  It relies on the gun catching that case in the same frame.
        --			However, because the player can also be doing a secondary attack, the edge trigger may be missed.
        --			We really need to hold onto the edge trigger and only clear the condition when the gun has fired its
        --			first shot.  Right now that's too much of an architecture change -- jdw
        
        -- If the firing button was just pressed, or the alt-fire just released, reset the firing time
        -- if ( ( pOwner->m_afButtonPressed & IN_ATTACK ) || ( pOwner->m_afButtonReleased & IN_ATTACK2 ) )
        -- {
             -- m_flNextPrimaryAttack = gpGlobals->curtime;
        -- }

        self:DoPrimaryAttack()

        -- if ( AutoFiresFullClip() )
        -- {
            -- m_bFiringWholeClip = true;
        -- end
    end
end

function SWEP:HandleFireOnEmpty()
	-- If we're already firing on empty, reload if we can
	if self:GetFireOnEmpty() then
		self:ReloadOrSwitchWeapons()
		self:SetFireDuration(0)
	else
		if CurTime() > self:GetNextEmptySoundTime() then
			self:WeaponSound(self.EMPTY)
			self:SetNextEmptySoundTime(CurTime() + 0.5)
		end
		self:SetFireOnEmpty(true)
	end
end

function SWEP:DoPrimaryAttack()
    --If my clip is empty (and I use clips) start reload
	if self:UsesClipsForAmmo1() and !self:Clip1() then 
		Reload()
		return
	end

	--Only the player fires this way so we can cast

	self.Owner:MuzzleFlash()

	self:SendWeaponAnimIdeal( self:GetPrimaryAttackActivity() )

	--player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local info = {}
    info.Src 		= self.Owner:GetShootPos()
    info.Dir 		= self.Owner:GetAimVector()
    info.Tracer	= 0
    info.AmmoType = self.Primary.Ammo
    info.Damage = self:GetDamage()

	info.Num = 1
	local fireRate = self:GetFireRate()

    --MUST call sound before removing a round from the clip of a CMachineGun
    self:WeaponSound(self.SINGLE)
    self:SetNextPrimaryFire(CurTime()+self:GetFireRate())

	if self:UsesClipsForAmmo1() then
		info.Num = math.min( info.Num, self:Clip1() )
        self:SetClip1(self:Clip1() - info.Num)
	else
		info.Num = math.min( info.Num, self.Owner:GetAmmoCount(self.Primary.Ammo) )
		self.Owner:RemoveAmmo( info.Num, self.Primary.Ammo )
	end

	info.AmmoType = self.Primary.Ammo
	info.Tracer	= self.Primary.TracerRate
	if self.Primary.TracerOverride != nil then
		info.TracerName = self.Primary.TracerOverride
	end

    info.Spread = self:GetBulletSpread()

	self.Owner:FireBullets( info )

	--Add our view kick in
    self:AddViewKick()
end

function SWEP:GetPrimaryAttackActivity()
    return ACT_VM_PRIMARYATTACK
end

function SWEP:GetDamage()
    return self.Primary.Damage
end

function SWEP:GetFireRate()
    return self.Primary.FireRate
end

function SWEP:AddViewKick()
end

function SWEP:SecondaryAttack()
    self:DoSecondaryAttack()
end

function SWEP:DoSecondaryAttack()
end

function SWEP:ImpactTrace(traceHit,dmgtype)

	data = EffectData()
	data:SetOrigin(traceHit.HitPos)
	data:SetStart(traceHit.StartPos)
	data:SetSurfaceProp(traceHit.SurfaceProps)
	data:SetDamageType(dmgtype)
	data:SetHitBox(traceHit.HitBox)
	if CLIENT then
		data:SetEntity(traceHit.Entity)
	else
		data:SetEntIndex(traceHit.Entity:EntIndex())
	end
	util.Effect( "Impact", data )
end

function SWEP:CalculateBulletDamageForce( info, bulletType, bulletDir, forceOrigin, scale )
	info:SetReportedPosition( forceOrigin )
	local vecForce = bulletDir
	vecForce:Normalize()
	vecForce = vecForce * game.GetAmmoForce( bulletType )
	vecForce = vecForce * GetConVar("phys_pushscale"):GetFloat();
	vecForce = vecForce * scale;
	info:SetDamageForce( vecForce );
	--Assert(vecForce!=vec3_origin);
end

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()
	-- other initialize code goes here
    
    self.m_bInitialized = true
    self:SetSaveValue("m_fMinRange1", self.m_fMinRange1)
    self:SetSaveValue("m_fMinRange2", self.m_fMinRange2)
    self:SetSaveValue("m_fMaxRange1", self.m_fMaxRange1)
    self:SetSaveValue("m_fMaxRange2", self.m_fMaxRange2)
    self:SetHoldType(self.HoldType)
    
	if CLIENT then
	
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels
		
		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				-- Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)
		if (!self.vRenderOrder) then
			
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}
			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end
		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r -- Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				-- make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			-- !! WORKAROUND !! --
			-- We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			-- !! ----------- !! --
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				-- !! WORKAROUND !! --
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				-- !! ----------- !! --
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	-- Does not copy entities of course, only copies their reference.
	-- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) -- recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end


