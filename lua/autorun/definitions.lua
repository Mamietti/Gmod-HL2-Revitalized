local Category = ""
local function ADD_ITEM( name, class )

	list.Set( "SpawnableEntities", class, { PrintName = name, ClassName = class, Category = Category, NormalOffset = 32, DropToFloor = true, Author = "VALVe" } )
	duplicator.Allow( class )

end

local function ADD_WEAPON( name, class )

	list.Set( "Weapon", class, { ClassName = class, PrintName = name, Category = Category, Author = "VALVe", Spawnable = true } )
	duplicator.Allow( class )

end

Category = "Half-Life 2"

ADD_ITEM( "Flare Ammo", "item_flare_round" )
ADD_ITEM( "Flare Ammo (Large)", "item_box_flare_rounds" )
ADD_ITEM( "Sniper Ammo", "item_box_sniper_rounds" )

ADD_WEAPON( "Annabelle", "weapon_annabelle" )
ADD_WEAPON( "Alyx Gun", "weapon_alyxgun" )

Category = "Half-Life 2 Plus"

ADD_WEAPON( "Combat Knife", "weapon_knife" )
ADD_WEAPON( "Flare Gun", "weapon_flaregun" )
ADD_WEAPON( "Manhack", "weapon_manhack_mp" )
ADD_WEAPON( "Sniper Rifle", "weapon_sniper" )


if CLIENT then
	surface.CreateFont( "WeaponIconsLarge", {
		font = "HalfLife2",
		size = 120,
		weight = 0,
		additive = true,
        antialias = true,
        custom = true
	} )
    surface.CreateFont( "WeaponIconsSelectedLarge", {
		font = "HalfLife2",
		size = 120,
		weight = 0,
		blursize = 0,
		additive = true,
        blursize = 15,
        scanlines = 7
	} )
    
    language.Add( "SniperRound_ammo", "Sniper Ammo" )
    language.Add( "Manhack_ammo", "Manhacks" )
    language.Add( "FlareRound_ammo", "Flares" )
    
    killicon.Add( "weapon_alyxgun_player", "HUD/alyxgun_icon", Color( 255, 80, 0, 255 ) )
    killicon.AddFont( "weapon_annabelle_player", "HL2MPTypeDeath", "0", Color( 255, 80, 0, 255 ) )
end

game.AddAmmoType( {
	name = "Manhack",
	dmgtype = DMG_SLASH,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )
game.AddAmmoType( {
	name = "FlareRound",
	dmgtype = DMG_BURN,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )


---SOUNDS

sound.Add( {
	name = "Weapon_Pknife.Swing",
	channel = CHAN_WEAPON,
	volume = 0.7,
	level = 80,
	pitch = { 95, 110 },
	sound = "weapons/pknife/pulseknife_kara.wav"
} )
sound.Add( {
	name = "Weapon_Pknife.Melee_Hit",
	channel = CHAN_WEAPON,
	volume = 0.7,
	level = 80,
	pitch = { 95, 110 },
	sound = "weapons/pknife/pulseknife_hit.wav"
} )

hook.Add( "PlayerCanPickupWeapon", "SwitchPlayerWeapon", function( ply, wep )
	if wep:GetClass() == "weapon_annabelle" then
		ply:Give( "weapon_annabelle_player" )
		wep:Remove()
		return false
	end
	if wep:GetClass() == "weapon_alyxgun" then
		ply:Give( "weapon_alyxgun_player" )
		wep:Remove()
		return false
	end
end )

CreateClientConVar( "hl2base_running_enabled", "0", true, false )
CreateClientConVar( "hl2base_examining_enabled", "0", true, false )

