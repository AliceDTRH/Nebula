/decl/loadout_option/cane
	display_name = "cane"
	path = /obj/item/cane

/decl/loadout_option/dice
	display_name = "dice pack"
	path = /obj/item/storage/pill_bottle/dice

/decl/loadout_option/dice/nerd
	display_name = "dice pack (gaming)"
	path = /obj/item/storage/pill_bottle/dice_nerd

/decl/loadout_option/cards
	display_name = "deck of cards"
	path = /obj/item/deck/cards

/decl/loadout_option/tarot
	display_name = "deck of tarot cards"
	path = /obj/item/deck/tarot

/decl/loadout_option/holder
	display_name = "card holder"
	path = /obj/item/deck/holder

/decl/loadout_option/cardemon_pack
	display_name = "Cardemon booster pack"
	path = /obj/item/pack/cardemon

/decl/loadout_option/spaceball_pack
	display_name = "Spaceball booster pack"
	path = /obj/item/pack/spaceball

/decl/loadout_option/flask
	display_name = "flask"
	path = /obj/item/chems/food/drinks/flask/barflask

/decl/loadout_option/flask/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/reagents])
	.[/datum/gear_tweak/reagents] |= lunchables_ethanol_reagents()

/decl/loadout_option/vacflask
	display_name = "vacuum-flask"
	path = /obj/item/chems/food/drinks/flask/vacuumflask

/decl/loadout_option/vacflask/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/reagents])
	.[/datum/gear_tweak/reagents] |= lunchables_drink_reagents()

/decl/loadout_option/coffeecup
	display_name = "coffee cup"
	path = /obj/item/chems/food/drinks/glass2/coffeecup
	flags = GEAR_HAS_TYPE_SELECTION

/decl/loadout_option/towel
	display_name = "towel"
	path = /obj/item/towel
	flags = GEAR_HAS_COLOR_SELECTION

/decl/loadout_option/plush_toy
	display_name = "plush toy"
	description = "A plush toy."
	path = /obj/item/toy/plushie

/decl/loadout_option/plush_toy/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path])
	.[/datum/gear_tweak/path] |= list(
		"mouse plush" =  /obj/item/toy/plushie/mouse,
		"kitten plush" = /obj/item/toy/plushie/kitten,
		"lizard plush" = /obj/item/toy/plushie/lizard,
		"spider plush" = /obj/item/toy/plushie/spider
	)

/decl/loadout_option/mirror
	display_name = "handheld mirror"
	path = /obj/item/mirror

/decl/loadout_option/lipstick
	display_name = "lipstick selection"
	path = /obj/item/lipstick
	flags = GEAR_HAS_TYPE_SELECTION

/decl/loadout_option/comb
	display_name = "plastic comb"
	path = /obj/item/haircomb
	flags = GEAR_HAS_COLOR_SELECTION

/decl/loadout_option/mask
	display_name = "sterile mask"
	path = /obj/item/clothing/mask/surgical
	cost = 2

/decl/loadout_option/smokingpipe
	display_name = "pipe, smoking"
	path = /obj/item/clothing/mask/smokable/pipe

/decl/loadout_option/cornpipe
	display_name = "pipe, corn"
	path = /obj/item/clothing/mask/smokable/pipe/cobpipe

/decl/loadout_option/matchbook
	display_name = "matchbook"
	path = /obj/item/storage/box/matches

/decl/loadout_option/lighter
	display_name = "cheap lighter"
	path = /obj/item/flame/lighter

/decl/loadout_option/lighter/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path])
	.[/datum/gear_tweak/path] |= list(
		"random" = /obj/item/flame/lighter/random,
		"red" =    /obj/item/flame/lighter/red,
		"yellow" = /obj/item/flame/lighter/yellow,
		"cyan" =   /obj/item/flame/lighter/cyan,
		"green" =  /obj/item/flame/lighter/green,
		"pink" =   /obj/item/flame/lighter/pink
	)

/decl/loadout_option/ashtray
	display_name = "ashtray, plastic"
	path = /obj/item/ashtray/plastic

/decl/loadout_option/ecig
	display_name = "electronic cigarette"
	path = /obj/item/clothing/mask/smokable/ecig/util

/decl/loadout_option/ecig/deluxe
	display_name = "electronic cigarette, deluxe"
	path = /obj/item/clothing/mask/smokable/ecig/deluxe
	cost = 2

/decl/loadout_option/bible
	display_name = "holy book"
	path = /obj/item/storage/bible
	cost = 2

/decl/loadout_option/bible/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path])
	.[/datum/gear_tweak/path] |= list(
		"bible (adjustable)" = /obj/item/storage/bible,
		"Bible" =              /obj/item/storage/bible/bible,
		"Tanakh" =             /obj/item/storage/bible/tanakh,
		"Quran" =              /obj/item/storage/bible/quran,
		"Kitab-i-Aqdas" =      /obj/item/storage/bible/aqdas,
		"Kojiki" =             /obj/item/storage/bible/kojiki
	)

/decl/loadout_option/cross
	display_name = "cross"
	path = /obj/item/cross
	cost = 2

/decl/loadout_option/cross/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path])
	.[/datum/gear_tweak/path] |= list(
		"cross, wood"=    /obj/item/cross,
		"cross, silver" = /obj/item/cross/silver,
		"cross, gold" =   /obj/item/cross/gold
	)

/decl/loadout_option/wallet
	display_name = "wallet, colour select"
	path = /obj/item/storage/wallet
	flags = GEAR_HAS_COLOR_SELECTION

/decl/loadout_option/wallet_poly
	display_name = "wallet, polychromic"
	path = /obj/item/storage/wallet/poly
	cost = 2


/decl/loadout_option/swiss
	display_name = "multi-tool"
	path = /obj/item/knife/folding/swiss
	cost = 4
	flags = GEAR_HAS_COLOR_SELECTION
