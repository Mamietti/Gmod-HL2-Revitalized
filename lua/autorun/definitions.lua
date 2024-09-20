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

	surface.CreateFont( "CSWeaponIconsLarge", {
		font = "csd",
		size = 150,
		weight = 0,
		additive = true,
        antialias = true,
        custom = true
	} )
    surface.CreateFont( "CSWeaponIconsSelectedLarge", {
		font = "csd",
		size = 150,
		weight = 0,
		blursize = 0,
		additive = true,
        blursize = 15,
        scanlines = 7
	} )
	surface.CreateFont( "CSKillIcons", {
		font = "csd",
		size = 70,
		weight = 0,
		additive = true,
        antialias = true,
        custom = true
	} )
    
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
	maxsplash = 5,
    maxcarry = 5
} )
game.AddAmmoType( {
	name = "FlareRound",
	dmgtype = DMG_BURN,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5,
    maxcarry = 20
} )
