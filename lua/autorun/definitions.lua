local Category = ""
local function ADD_ITEM( name, class )

	list.Set( "SpawnableEntities", class, { PrintName = name, ClassName = class, Category = Category, NormalOffset = 32, DropToFloor = true, Author = "VALVe" } )
	duplicator.Allow( class )

end

Category = "Half-Life 2"
ADD_ITEM( "Flare Ammo", "item_flare_round" )
ADD_ITEM( "Flare Ammo (Large)", "item_box_flare_rounds" )
ADD_ITEM( "Sniper Ammo", "item_box_sniper_rounds" )

if CLIENT then
	surface.CreateFont( "HL2HUDFONT", {
		font = "HalfLife2",
		size = 120,
		weight = 500,
		blursize = 0,
		scanlines = 16,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = true,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = true,
		outline = false,
	} )
	surface.CreateFont( "CSKillIcons", {
		font = "csd",
		size = 120,
		weight = 500,
		blursize = 0,
		scanlines = 16,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = true,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = true,
		outline = true,
	} )
    language.Add( "GaussEnergy_ammo", "Depleted Uranium-235" )
    language.Add( "SniperRound_ammo", "Sniper Ammo" )
    language.Add( "Manhack_ammo", "Manhacks" )
    language.Add( "FlareRound_ammo", "Flares" )
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

