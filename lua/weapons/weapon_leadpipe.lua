SWEP.PrintName			= "LEAD PIPE"
SWEP.Author			= "Strafe"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Base = "weapon_hl2mpbasebludgeon_strafe"

SWEP.Slot				= 0
SWEP.SlotPos			= 4
SWEP.DrawAmmo			= true
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel			= "models/weapons/c_mattpipe.mdl"
SWEP.ViewModelFlip = false
SWEP.WorldModel			= "models/props_canal/mattpipe.mdl"

SWEP.Category           = "Half-Life 2 Extended"
SWEP.FiresUnderwater = true

SWEP.HoldType			= "melee"

SWEP.SINGLE = "Weapon_Crowbar.Single"
SWEP.MELEE_HIT = "Weapon_Crowbar.Melee_Hit"

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    local letter = "n"
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

function SWEP:SecondaryAttack()
	return false
end

function SWEP:GetFireRate()
	return 0.8
end

function SWEP:GetDamageForActivity()
	return 40
end