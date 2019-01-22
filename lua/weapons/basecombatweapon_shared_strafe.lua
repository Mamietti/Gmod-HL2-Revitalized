SWEP.PrintName			= "Test SMG NEW BASE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= false
SWEP.AdminOnly			= true
SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.HoldType			= "pistol"
SWEP.Base = "weapon_base"
SWEP.DrawWeaponInfoBox = false

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

DEFINE_BASECLASS( "weapon_base" )

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

SWEP.SINGLE = "Weapon_357.Single"
SWEP.EMPTY = "Weapon_Pistol.Empty"
SWEP.DEPLOY = ""
SWEP.RELOAD = "Weapon_SMG1.Reload"
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

function SWEP:GetBulletSpread()
    return VECTOR_CONE_15DEGREES
end

function SWEP:Initialize()
    self.m_bInitialized = true
    self:SetSaveValue("m_fMinRange1", self.m_fMinRange1)
    self:SetSaveValue("m_fMinRange2", self.m_fMinRange2)
    self:SetSaveValue("m_fMaxRange1", self.m_fMaxRange1)
    self:SetSaveValue("m_fMaxRange2", self.m_fMaxRange2)
    self:SetHoldType(self.HoldType)
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Float" , 0 , "WeaponIdleTime" )
    self:NetworkVar( "Float" , 1 , "FireDuration" )
    self:NetworkVar( "Float" , 2 , "NextEmptySoundTime" )
    self:NetworkVar( "Bool" , 0 , "InReload" )
    self:NetworkVar( "Bool" , 1 , "FireOnEmpty" )
end

function SWEP:UsesPrimaryAmmo()
    return self.Primary.Ammo != "None"
end

function SWEP:UsesSecondaryAmmo()
    return self.Secondary.Ammo != "None"
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
            --if CurTime() < self:GetNextPrimaryFire() then return end
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

	if self:UsesClipsForAmmo1() then
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
	info.Tracer	= 2

    info.Spread = self:GetBulletSpread()

	self.Owner:FireBullets( info )

	--Add our view kick in
    self:AddViewKick()
end

function SWEP:GetPrimaryAttackActivity()
    return ACT_VM_PRIMARYATTACK
end

function SWEP:GetDamage()
    return 5
end

function SWEP:GetFireRate()
    return 0
end

function SWEP:AddViewKick()
end

function SWEP:SecondaryAttack()
    self:DoSecondaryAttack()
end

function SWEP:DoSecondaryAttack()
end


