var/global/list/materials_by_gas_symbol = list()

/obj/effect/gas_overlay
	name = "gas"
	desc = "You shouldn't be clicking this."
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "generic"
	layer = FIRE_LAYER
	appearance_flags = RESET_COLOR
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	var/decl/material/material

INITIALIZE_IMMEDIATE(/obj/effect/gas_overlay)

/obj/effect/gas_overlay/proc/update_alpha_animation(var/new_alpha)
	animate(src, alpha = new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0.8 * new_alpha, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = new_alpha, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/obj/effect/gas_overlay/Initialize(mapload, gas)
	. = ..()
	material = GET_DECL(gas)
	if(!istype(material))
		return INITIALIZE_HINT_QDEL
	if(material.gas_tile_overlay)
		icon_state = material.gas_tile_overlay
	color = material.color

/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation.

	PATHS THAT USE DATUMS
		turf/simulated/wall
		obj/item
		obj/structure/barricade
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			cult
		DOORS
			stone
			metal
			plastic
			wood
*/

//Returns the material the object is made of, if applicable.
//Will we ever need to return more than one value here? Or should we just return the "dominant" material.
/obj/proc/get_material()
	return

//mostly for convenience
/obj/proc/get_material_type()
	var/decl/material/mat = get_material()
	. = mat && mat.type

// Material definition and procs follow.
/decl/material

	abstract_type = /decl/material
	decl_flags = DECL_FLAG_MANDATORY_UID

	var/name               // Prettier name for display.
	var/codex_name         // Override for the codex article name.
	var/adjective_name
	var/solid_name
	var/gas_name
	var/liquid_name
	var/use_name
	var/wall_name = "wall" // Name given to walls of this material
	var/flags = 0          // Various status modifiers.
	var/hidden_from_codex
	var/lore_text
	var/mechanics_text
	var/antag_text
	var/default_solid_form = /obj/item/stack/material/sheet

	var/affect_blood_on_ingest = TRUE
	var/affect_blood_on_inhale = TRUE

	var/narcosis = 0 // Not a great word for it. Constant for causing mild confusion when ingested.
	var/toxicity = 0 // Organ damage from ingestion.
	var/toxicity_targets_organ // Bypass liver/kidneys when ingested, harm this organ directly (using BP_FOO defines).

	// Shards/tables/structures
	var/shard_type = SHARD_SHRAPNEL       // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/list/recipes                      // Holder for all recipes usable with a sheet of this material.
	var/list/strut_recipes                // Holder for all the recipes you can build with the struct stack type.
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.

	// Icons
	var/icon_base = 'icons/turf/walls/solid.dmi'
	var/icon_base_natural = 'icons/turf/walls/natural.dmi'
	var/icon_reinf = 'icons/turf/walls/reinforced_metal.dmi'
	var/wall_flags = 0
	var/list/wall_blend_icons = list() // Which wall icon types walls of this material type will consider blending with. Assoc list (icon path = TRUE/FALSE)
	var/use_reinf_state = "full"

	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/table_icon_base = "metal"
	var/table_icon_reinforced = "reinf_metal"

	var/list/stack_origin_tech = "{'materials':1}" // Research level for stacks.

	// Attributes
	/// How rare is this material in exoplanet xenoflora?
	var/exoplanet_rarity_plant = MAT_RARITY_MUNDANE
	/// How rare is this material in exoplanet atmospheres?
	var/exoplanet_rarity_gas = MAT_RARITY_MUNDANE
	/// Delay in ticks when cutting through this wall.
	var/cut_delay = 0
	/// Radiation var. Used in wall and object processing to irradiate surroundings.
	var/radioactivity
	/// K, point at which the material catches on fire.
	var/ignition_point
	/// K, walls will take damage if they're next to a fire hotter than this
	var/melting_point = 1800
	/// K, point that material will become a gas.
	var/boiling_point = 3000
	/// kJ/kg, enthalpy of vaporization
	var/latent_heat = 7000
	/// kg/mol,
	var/molar_mass = 0.06
	/// Brute damage to a wall is divided by this value if the wall is reinforced by this material.
	var/brute_armor = 2
	/// Same as above, but for Burn damage type. If blank brute_armor's value is used.
	var/burn_armor
	/// General-use HP value for products.
	var/integrity = 150
	/// Is the material transparent? 0.5< makes transparent walls/doors.
	var/opacity = TRUE
	/// Only used by walls currently.
	var/explosion_resistance = 5
	/// Objects with this var add CONDUCTS to flags on spawn.
	var/conductive = 1
	/// Does this material glow?
	var/luminescence
	/// Used for checking if a material can function as a wall support.
	var/wall_support_value = 30
	/// Ore generation constant for rare materials.
	var/sparse_material_weight
	/// Ore generation constant for common materials.
	var/rich_material_weight
	/// How transparent can fluids be?
	var/min_fluid_opacity = FLUID_MIN_ALPHA
	/// How opaque can fluids be?
	var/max_fluid_opacity = FLUID_MAX_ALPHA
	/// Point at which the fluid will proc turf interaction logic. Workaround for mops being ruined forever by 1u of anything else being added.
	var/turf_touch_threshold = FLUID_QDEL_POINT

	// Damage values.
	var/hardness = MAT_VALUE_HARD            // Used for edge damage in weapons.
	var/reflectiveness = MAT_VALUE_DULL

	var/weight = MAT_VALUE_NORMAL             // Determines blunt damage/throwforce for weapons.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Noise made when you hit structure made of this material.
	var/hitsound = 'sound/weapons/genhit.ogg'
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"
	// Modifies skill checks when constructing with this material.
	var/construction_difficulty = MAT_VALUE_EASY_DIY
	// Determines what is used to remove or dismantle this material.
	var/removed_by_welder

	// Mining behavior.
	var/ore_name
	var/ore_desc
	var/ore_compresses_to
	var/ore_result_amount
	var/ore_spread_chance
	var/ore_scan_icon
	var/ore_icon_overlay
	var/ore_type_value
	var/ore_data_value

	var/value = 1

	// Xenoarch behavior.
	var/xarch_source_mineral = /decl/material/solid/metal/iron

	// Gas behavior.
	var/gas_overlay_limit
	var/gas_specific_heat = 20    // J/(mol*K)
	var/gas_symbol_html
	var/gas_symbol
	var/gas_flags = 0
	var/gas_tile_overlay = "generic"
	var/gas_condensation_point = null
	var/gas_metabolically_inert = FALSE // If false, material will move into the bloodstream when breathed.
	// Armor values generated from properties
	var/list/basic_armor
	var/armor_degradation_speed

	// Copied reagent values. Todo: integrate.
	var/taste_description = "old rotten bandaids"
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/metabolism = REM // This would be 0.2 normally
	var/ingest_met = 0
	var/touch_met = 0
	var/inhale_met = 0
	var/overdose = 0
	var/scannable = 0 // Shows up on health analyzers.
	var/color = COLOR_BEIGE
	var/color_weight = 1
	var/cocktail_ingredient
	var/defoliant
	var/fruit_descriptor // String added to fruit desc if this chemical is present.

	var/dirtiness = DIRTINESS_NEUTRAL // How dirty turfs are after being exposed to this material. Negative values cause a cleaning/sterilizing effect.
	var/solvent_power = MAT_SOLVENT_NONE
	var/solvent_melt_dose = 0
	var/solvent_max_damage  = 0
	var/slipperiness = 0
	var/euphoriant // If set, ingesting/injecting this material will cause the rainbow high overlay/behavior.

	var/glass_icon = DRINK_ICON_DEFAULT
	var/glass_name = "something"
	var/glass_desc = "It's a glass of... what, exactly?"
	var/list/glass_special = null // null equivalent to list()

	// Matter state data.
	var/dissolve_message = "dissolves in"
	var/dissolve_sound = 'sound/effects/bubbles.ogg'
	var/dissolves_in = MAT_SOLVENT_STRONG
	var/list/dissolves_into	// Used with the grinder and a solvent to extract other materials.

	var/chilling_point
	var/chilling_message = "crackles and freezes!"
	var/chilling_sound = 'sound/effects/bubbles.ogg'
	var/list/chilling_products
	var/bypass_cooling_products_for_root_type

	var/heating_point
	var/heating_message = "begins to boil!"
	var/heating_sound = 'sound/effects/bubbles.ogg'
	var/list/heating_products
	var/bypass_heating_products_for_root_type
	var/fuel_value = 0
	var/burn_product
	var/list/vapor_products // If splashed, releases these gasses in these proportions. // TODO add to unit test after solvent PR is merged

	var/scent //refer to _scent.dm
	var/scent_intensity = /decl/scent_intensity/normal
	var/scent_descriptor = SCENT_DESC_SMELL
	var/scent_range = 1

	var/list/neutron_interactions // Associative List of potential neutron interactions for the material to undergo, corresponding to the ideal
								  // neutron energy for that reaction to occur.

	var/neutron_cross_section	  // How broad the neutron interaction curve is, independent of temperature. Materials that are harder to react with will have lower values.
	var/absorption_products		  // Transmutes into these reagents following neutron absorption and/or subsequent beta decay. Generally forms heavier reagents.
	var/fission_products		  // Transmutes into these reagents following fission. Forms lighter reagents, and a lot of heat.
	var/neutron_production		  // How many neutrons are created per unit per fission event.
	var/neutron_absorption		  // How many neutrons are absorbed per unit per absorption event.
	var/fission_heat			  // How much thermal energy per unit per fission event this material releases.
	var/fission_energy			  // Energy of neutrons released by fission.
	var/moderation_target		  // The 'target' neutron energy value that the fission environment shifts towards after a moderation event.
								  // Neutron moderators can only slow down neutrons.

	var/sound_manipulate          //Default sound something like a material stack made of this material does when picked up
	var/sound_dropped             //Default sound something like a material stack made of this material does when hitting the ground or placed down

// Placeholders for light tiles and rglass.
/decl/material/proc/reinforce(var/mob/user, var/obj/item/stack/material/used_stack, var/obj/item/stack/material/target_stack, var/use_sheets = 1)
	if(!used_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need need at least one [used_stack.singular_name] to reinforce [target_stack]."))
		return

	var/decl/material/reinf_mat = used_stack.material
	if(reinf_mat.integrity <= integrity || reinf_mat.is_brittle())
		to_chat(user, SPAN_WARNING("The [reinf_mat.solid_name] is too structurally weak to reinforce the [name]."))
		return

	if(!target_stack.can_use(use_sheets))
		to_chat(user, SPAN_WARNING("You need need at least [use_sheets] [use_sheets == 1 ? target_stack.singular_name : target_stack.plural_name] for reinforcement with [used_stack]."))
		return

	to_chat(user, SPAN_NOTICE("You reinforce the [target_stack] with [reinf_mat.solid_name]."))
	used_stack.use(use_sheets)
	var/obj/item/stack/material/S = target_stack.split(1)
	S.reinf_material = reinf_mat
	S.update_strings()
	S.update_icon()
	if(!QDELETED(target_stack))
		S.dropInto(get_turf(target_stack))
	else if(user)
		S.dropInto(get_turf(user))
	else
		S.dropInto(get_turf(used_stack))
	S.add_to_stacks(user, TRUE)

// Make sure we have a use name and shard icon even if they aren't explicitly set.
/decl/material/Initialize()
	. = ..()
	if(!name)
		CRASH("Unnamed material /decl tried to initialize.")
	if(!use_name)
		use_name = name
	if(!liquid_name)
		liquid_name = name
	if(!solid_name)
		solid_name = name
	if(!gas_name)
		gas_name = name
	if(!adjective_name)
		adjective_name = name
	if(!shard_icon)
		shard_icon = shard_type
	if(!burn_armor)
		burn_armor = brute_armor
	if(!gas_symbol)
		gas_symbol = "[name]_[sequential_id(abstract_type)]"
	if(!gas_symbol_html)
		gas_symbol_html = gas_symbol
	global.materials_by_gas_symbol[gas_symbol] = type
	generate_armor_values()

	var/list/cocktails = decls_repository.get_decls_of_subtype(/decl/cocktail)
	for(var/ctype in cocktails)
		var/decl/cocktail/cocktail = cocktails[ctype]
		if(type in cocktail.ratios)
			cocktail_ingredient = TRUE
			break

#define FALSEWALL_STATE "fwall_open"
/decl/material/validate()
	. = ..()
	if(length(dissolves_into) && isnull(dissolves_in))
		. += "dissolves_into set but dissolves_in is undefined"
	if(length(heating_products) && isnull(heating_point))
		. += "heating_products set but heating_point is undefined"
	if(length(chilling_products) && isnull(chilling_point))
		. += "chilling_products set but chilling_point is undefined"
	var/list/checking = list(
		"dissolves" = dissolves_into,
		"heats" = heating_products,
		"chills" = chilling_products
	)
	for(var/field in checking)
		var/list/checking_list = checking[field]
		if(length(checking_list))
			var/total = 0
			for(var/chem in checking_list)
				total += checking_list[chem]
			if(total != 1)
				. += "[field] adds up to [total] (should be 1)"
	if(icon_base && !check_state_in_icon(FALSEWALL_STATE, icon_base))
		. += "[type] - '[icon_base]' - missing false wall opening animation '[FALSEWALL_STATE]'"

	for(var/i = 0 to 7)
		if(icon_base)
			if(!check_state_in_icon("[i]", icon_base))
				. += "'[icon_base]' - missing directional base icon state '[i]'"
			if(!check_state_in_icon("other[i]", icon_base))
				. += "'[icon_base]' - missing connective base icon state 'other[i]'"

		if(wall_flags & PAINT_PAINTABLE)
			if(!check_state_in_icon("paint[i]", icon_base))
				. += "'[icon_base]' - missing directional paint icon state '[i]'"
		if(wall_flags & PAINT_STRIPABLE)
			if(!check_state_in_icon("stripe[i]", icon_base))
				. += "'[icon_base]' - missing directional stripe icon state '[i]'"
		if(wall_flags & WALL_HAS_EDGES)
			if(!check_state_in_icon("other[i]", icon_base))
				. += "'[icon_base]' - missing directional edge icon state '[i]'"

		if(icon_base_natural)
			if(!check_state_in_icon("[i]", icon_base_natural))
				. += "'[icon_base_natural]' - missing directional natural icon state '[i]'"
			if(!check_state_in_icon("shine[i]", icon_base_natural))
				. += "'[icon_base_natural]' - missing natural shine icon state 'shine[i]'"

	if(icon_reinf)
		if(use_reinf_state)
			if(!check_state_in_icon(use_reinf_state, icon_reinf))
				. += "'[icon_reinf]' - missing reinf icon state '[use_reinf_state]'"
		else
			for(var/i = 0 to 7)
				if(!check_state_in_icon("[i]", icon_reinf))
					. += "'[icon_reinf]' - missing directional reinf icon state '[i]'"

	if(length(color) != 7)
		. += "invalid color (not #RRGGBB)"
#undef FALSEWALL_STATE

// Return the matter comprising this material.
/decl/material/proc/get_matter()
	var/list/temp_matter = list()
	temp_matter[type] = SHEET_MATERIAL_AMOUNT
	return temp_matter

// Weapons handle applying a divisor for this value locally.
/decl/material/proc/get_blunt_damage()
	return weight //todo

// As above.
/decl/material/proc/get_edge_damage()
	return hardness //todo

/decl/material/proc/get_attack_cooldown()
	if(weight <= MAT_VALUE_LIGHT)
		return FAST_WEAPON_COOLDOWN
	if(weight >= MAT_VALUE_HEAVY)
		return SLOW_WEAPON_COOLDOWN
	return DEFAULT_WEAPON_COOLDOWN

// Snowflakey, only checked for alien doors at the moment.
/decl/material/proc/can_open_material_door(var/mob/living/user)
	return 1

// Currently used for weapons and objects made of uranium to irradiate things.
/decl/material/proc/products_need_process()
	return (radioactivity>0) //todo


//Clausius–Clapeyron relation
/decl/material/proc/get_boiling_temp(var/pressure = ONE_ATMOSPHERE)
	var/pressure_ratio = (pressure > 0)? log(pressure / ONE_ATMOSPHERE) : 0
	return (1 / (1/max(boiling_point, TCMB)) - ((R_IDEAL_GAS_EQUATION * pressure_ratio) / (latent_heat * molar_mass)))

/// Returns the phase of the matterial at the given temperature and pressure
/// Defaults to standard temperature and pressure (20c at one atmosphere)
/decl/material/proc/phase_at_temperature(var/temperature = T20C, var/pressure = ONE_ATMOSPHERE)
	//#TODO: implement plasma temperature and do pressure checks
	if(!isnull(boiling_point) && temperature >= get_boiling_temp(pressure))
		return MAT_PHASE_GAS
	else if(!isnull(heating_point) && temperature >= heating_point || \
			!isnull(melting_point) && temperature >= melting_point)
		return MAT_PHASE_LIQUID
	return MAT_PHASE_SOLID

// Used by walls when qdel()ing to avoid neighbor merging.
/decl/material/placeholder
	name = "placeholder"
	uid = "mat_placeholder"
	hidden_from_codex = TRUE
	exoplanet_rarity_plant = MAT_RARITY_NOWHERE
	exoplanet_rarity_gas = MAT_RARITY_NOWHERE

/// Generic material product (sheets, bricks, etc). Used ALL THE TIME.
/// May return an instance list, a single instance, or nothing if there is no instance produced.
/decl/material/proc/create_object(var/atom/target, var/amount = 1, var/object_type, var/reinf_type)

	if(!object_type)
		object_type = default_solid_form

	if(!ispath(object_type, /atom/movable))
		CRASH("Non-movable path '[object_type || "NULL"]' supplied to [type] create_object()")

	if(ispath(object_type, /obj/item/stack))
		var/obj/item/stack/stack_type = object_type
		var/divisor = initial(stack_type.max_amount)
		while(amount >= divisor)
			LAZYADD(., new object_type(target, divisor, type, reinf_type))
			amount -= divisor
		if(amount >= 1)
			LAZYADD(., new object_type(target, amount, type, reinf_type))
	else
		for(var/i = 1 to amount)
			var/atom/movable/placed = new object_type(target, type, reinf_type)
			if(istype(placed))
				LAZYADD(., placed)

	if(istype(target) && LAZYLEN(.))
		for(var/atom/movable/placed in .)
			placed.dropInto(target)

// Places a girder object when a wall is dismantled, also applies reinforced material.
/decl/material/proc/place_dismantled_girder(var/turf/target, var/decl/material/reinf_material)
	return create_object(target, 1, /obj/structure/girder, ispath(reinf_material) ? reinf_material : reinf_material?.type)

// General wall debris product placement.
// Not particularly necessary aside from snowflakey cult girders.
/decl/material/proc/place_dismantled_product(var/turf/target, var/is_devastated, var/amount = 2, var/drop_type)
	amount = is_devastated ? FLOOR(amount * 0.5) : amount
	if(amount > 0)
		return create_object(target, amount, object_type = drop_type)

// As above.
/decl/material/proc/place_shards(var/turf/target, var/amount = 1)
	if(shard_type)
		return create_object(target, amount, /obj/item/shard)

/**Places downa as many shards as needed for the given amount of matter units. Returns a list of all the cuttings. */
/decl/material/proc/place_cuttings(var/turf/target, var/matter_units)
	if(!shard_type && matter_units <= 0)
		return
	var/list/shard_mat = atom_info_repository.get_matter_for(shard_type, type, 1)
	var/amount_per_shard = LAZYACCESS(shard_mat, type)
	if(amount_per_shard < 1)
		return

	//Make all the shards we can
	var/shard_amount = round(matter_units / amount_per_shard)
	var/matter_left  = round(matter_units % amount_per_shard)
	LAZYADD(., create_object(target, shard_amount, shard_type))

	//If we got more than expected, just make a shard with that amount
	if(matter_left > 0)
		var/list/O = create_object(target, 1, shard_type)
		var/obj/S = O[O.len]
		LAZYSET(S.matter, type, matter_left)
		LAZYADD(., S)

// Used by walls and weapons to determine if they break or not.
/decl/material/proc/is_brittle()
	return !!(flags & MAT_FLAG_BRITTLE)

/decl/material/proc/combustion_effect(var/turf/T, var/temperature)
	return

// Dumb overlay to apply over wall sprite for cheap texture effect
/decl/material/proc/get_wall_texture()
	return

/decl/material/proc/on_leaving_metabolism(datum/reagents/metabolism/holder)
	return

#define ACID_MELT_DOSE 10
/decl/material/proc/touch_obj(var/obj/O, var/amount, var/datum/reagents/holder) // Acid melting, cleaner cleaning, etc

	if(solvent_power >= MAT_SOLVENT_MILD)
		if(istype(O, /obj/item/paper))
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			to_chat(usr, SPAN_NOTICE("The solution dissolves the ink on the paper."))
		else if(istype(O, /obj/item/book) && REAGENT_VOLUME(holder, type) >= 5)
			if(istype(O, /obj/item/book/tome))
				to_chat(usr, SPAN_WARNING("The solution does nothing. Whatever this is, it isn't normal ink."))
			else
				var/obj/item/book/affectedbook = O
				affectedbook.dat = null
				to_chat(usr, SPAN_NOTICE("The solution dissolves the ink on the book."))

	if(solvent_power >= MAT_SOLVENT_STRONG && !O.unacidable && (istype(O, /obj/item) || istype(O, /obj/effect/vine)) && (REAGENT_VOLUME(holder, type) > solvent_melt_dose))
		var/obj/effect/decal/cleanable/molten_item/I = new(O.loc)
		I.visible_message(SPAN_DANGER("\The [O] dissolves!"))
		I.desc = "It looks like it was \a [O] some time ago."
		qdel(O)
		holder?.remove_reagent(type, solvent_melt_dose)

	if(dirtiness <= DIRTINESS_STERILE)
		O.germ_level -= min(REAGENT_VOLUME(holder, type)*20, O.germ_level)
		O.was_bloodied = null

	if(dirtiness <= DIRTINESS_CLEAN)
		O.clean_blood()

	if(defoliant && istype(O, /obj/effect/vine))
		qdel(O)

#define FLAMMABLE_LIQUID_DIVISOR 7
// This doesn't apply to skin contact - this is for, e.g. extinguishers and sprays. The difference is that reagent is not directly on the mob's skin - it might just be on their clothing.
/decl/material/proc/touch_mob(var/mob/living/M, var/amount, var/datum/reagents/holder)
	if(fuel_value && amount && istype(M))
		M.fire_stacks += FLOOR((amount * fuel_value)/FLAMMABLE_LIQUID_DIVISOR)
#undef FLAMMABLE_LIQUID_DIVISOR

/decl/material/proc/touch_turf(var/turf/T, var/amount, var/datum/reagents/holder) // Cleaner cleaning, lube lubbing, etc, all go here

	if(REAGENT_VOLUME(holder, type) < turf_touch_threshold)
		return

	if(istype(T, /turf/simulated))
		var/turf/simulated/wall/W = T
		if(defoliant)
			for(var/obj/effect/overlay/wallrot/E in W)
				W.visible_message(SPAN_NOTICE("\The [E] is completely dissolved by the solution!"))
				qdel(E)
		if(slipperiness != 0 && !T.check_fluid_depth()) // Don't make floors slippery if they have an active fluid on top of them please.
			if(slipperiness < 0)
				W.unwet_floor(TRUE)
			else
				W.wet_floor(slipperiness)

	if(length(vapor_products))
		var/volume = REAGENT_VOLUME(holder, type)
		var/temperature = holder?.my_atom?.temperature || T20C
		for(var/vapor in vapor_products)
			T.assume_gas(vapor, (volume * vapor_products[vapor]), temperature)
		holder.remove_reagent(type, volume)

/decl/material/proc/on_mob_life(var/mob/living/M, var/metabolism_class, var/datum/reagents/holder, var/list/life_dose_tracker)

	if(QDELETED(src))
		return // Something else removed us.
	if(!istype(M))
		return
	if(!(flags & AFFECTS_DEAD) && M.stat == DEAD && (world.time - M.timeofdeath > 150))
		return

	// Keep track of dosage of chems across holders for overdosing purposes
	if(overdose && metabolism_class != CHEM_TOUCH && islist(life_dose_tracker))
		life_dose_tracker[src] += REAGENT_VOLUME(holder, type)

	//determine the metabolism rate
	var/removed
	switch(metabolism_class)
		if(CHEM_INGEST)
			removed = ingest_met
		if(CHEM_TOUCH)
			removed = touch_met
		if(CHEM_INHALE)
			removed = inhale_met
	if(!removed)
		removed = metabolism
	if(!removed)
		removed = metabolism
	removed = M.get_adjusted_metabolism(removed)

	//adjust effective amounts - removed, dose, and max_dose - for mob size
	var/effective = removed
	if(!(flags & IGNORE_MOB_SIZE) && metabolism_class != CHEM_TOUCH)
		effective *= (MOB_SIZE_MEDIUM/M.mob_size)

	var/dose = LAZYACCESS(M.chem_doses, type) + effective
	LAZYSET(M.chem_doses, type, dose)
	if(effective >= (metabolism * 0.1) || effective >= 0.1) // If there's too little chemical, don't affect the mob, just remove it
		switch(metabolism_class)
			if(CHEM_INJECT)
				affect_blood(M, effective, holder)
			if(CHEM_INGEST)
				affect_ingest(M, effective, holder)
			if(CHEM_TOUCH)
				affect_touch(M, effective, holder)
			if(CHEM_INHALE)
				affect_inhale(M, effective, holder)
	holder.remove_reagent(type, removed)

/decl/material/proc/affect_blood(var/mob/living/M, var/removed, var/datum/reagents/holder)
	if(M.status_flags & GODMODE)
		return

	if(radioactivity)
		M.apply_damage(radioactivity * removed, IRRADIATE, armor_pen = 100)

	if(toxicity)
		M.add_chemical_effect(CE_TOXIN, toxicity)
		var/dam = (toxicity * removed)
		if(toxicity_targets_organ && ishuman(M))
			var/organ_damage = dam * M.get_toxin_resistance()
			if(organ_damage > 0)
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/internal/I = GET_INTERNAL_ORGAN(H, toxicity_targets_organ)
				if(I)
					var/can_damage = I.max_damage - I.damage
					if(can_damage > 0)
						if(organ_damage > can_damage)
							I.take_internal_damage(can_damage, silent=TRUE)
							dam -= can_damage
						else
							I.take_internal_damage(organ_damage, silent=TRUE)
							dam = 0
		if(dam > 0)
			M.adjustToxLoss(toxicity_targets_organ ? (dam * 0.75) : dam)

	if(solvent_power >= MAT_SOLVENT_STRONG)
		M.take_organ_damage(0, removed * solvent_power, override_droplimb = DISMEMBER_METHOD_ACID)

	if(narcosis)
		if(prob(10))
			M.SelfMove(pick(global.cardinal))
		if(prob(narcosis))
			M.emote(pick("twitch", "drool", "moan"))

	if(euphoriant)
		SET_STATUS_MAX(M, STAT_DRUGGY, euphoriant)

/decl/material/proc/affect_ingest(var/mob/living/M, var/removed, var/datum/reagents/holder)
	if(affect_blood_on_ingest)
		affect_blood(M, removed * 0.5, holder)

/decl/material/proc/affect_inhale(var/mob/living/M, var/removed, var/datum/reagents/holder)
	if(affect_blood_on_inhale)
		affect_blood(M, removed * 0.75, holder)

/decl/material/proc/affect_touch(var/mob/living/M, var/removed, var/datum/reagents/holder)

	if(!istype(M))
		return

	if(radioactivity)
		M.apply_damage((radioactivity / 2) * removed, IRRADIATE)

	if(dirtiness <= DIRTINESS_STERILE)
		if(M.germ_level < INFECTION_LEVEL_TWO) // rest and antibiotics is required to cure serious infections
			M.germ_level -= min(removed*20, M.germ_level)
		for(var/obj/item/I in M.contents)
			I.was_bloodied = null
		M.was_bloodied = null

	if(dirtiness <= DIRTINESS_CLEAN)
		for(var/obj/item/thing in M.get_held_items())
			thing.clean_blood()
		var/obj/item/mask = M.get_equipped_item(slot_wear_mask_str)
		if(mask)
			mask.clean_blood()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/head = H.get_equipped_item(slot_head_str)
			if(head)
				head.clean_blood()
			var/obj/item/suit = H.get_equipped_item(slot_wear_suit_str)
			if(suit)
				suit.clean_blood()
			else
				var/obj/item/uniform = H.get_equipped_item(slot_w_uniform_str)
				if(uniform)
					uniform.clean_blood()

			var/obj/item/shoes = H.get_equipped_item(slot_shoes_str)
			if(shoes)
				shoes.clean_blood()
			else
				H.clean_blood(1)
				return
		M.clean_blood()

	if(solvent_power >= MAT_SOLVENT_STRONG && removed >= solvent_melt_dose)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			for(var/slot in global.standard_headgear_slots)
				var/obj/item/thing = H.get_equipped_item(slot)
				if(!istype(thing))
					continue
				if(thing.unacidable || !H.try_unequip(thing))
					to_chat(H, SPAN_NOTICE("Your [thing] protects you from the acid."))
					holder.remove_reagent(type, REAGENT_VOLUME(holder, type))
					return
				to_chat(H, SPAN_DANGER("Your [thing] dissolves!"))
				qdel(thing)
				removed -= solvent_melt_dose
				if(removed <= 0)
					return

			if(!H.unacidable)
				var/screamed
				for(var/obj/item/organ/external/affecting in H.get_external_organs())
					if(!screamed && affecting.can_feel_pain())
						screamed = TRUE
						H.emote("scream")
					affecting.status |= ORGAN_DISFIGURED

		if(!M.unacidable)
			M.take_organ_damage(0, min(removed * solvent_power * ((removed < solvent_melt_dose) ? 0.1 : 0.2), solvent_max_damage), override_droplimb = DISMEMBER_METHOD_ACID)

/decl/material/proc/affect_overdose(var/mob/living/M) // Overdose effect. Doesn't happen instantly.
	M.add_chemical_effect(CE_TOXIN, 1)
	M.adjustToxLoss(REM)

/decl/material/proc/initialize_data(var/newdata) // Called when the reagent is created.
	if(newdata)
		. = newdata

/decl/material/proc/mix_data(var/datum/reagents/reagents, var/list/newdata, var/amount)
	. = REAGENT_DATA(reagents, type)

/decl/material/proc/explosion_act(obj/item/chems/holder, severity)
	SHOULD_CALL_PARENT(TRUE)
	. = TRUE

/decl/material/proc/get_value()
	. = value

/decl/material/proc/get_presentation_name(var/obj/item/prop)
	. = glass_name || liquid_name
	if(prop?.reagents?.total_volume)
		. = build_presentation_name_from_reagents(prop, .)

/decl/material/proc/build_presentation_name_from_reagents(var/obj/item/prop, var/supplied)
	. = supplied

	if(cocktail_ingredient)
		for(var/decl/cocktail/cocktail in SSmaterials.get_cocktails_by_primary_ingredient(type))
			if(cocktail.matches(prop))
				return cocktail.get_presentation_name(prop)

	if(prop.reagents.has_reagent(/decl/material/solid/ice))
		. = "iced [.]"

/decl/material/proc/get_presentation_desc(var/obj/item/prop)
	. = glass_desc
	if(prop?.reagents?.total_volume)
		. = build_presentation_desc_from_reagents(prop, .)

/decl/material/proc/build_presentation_desc_from_reagents(var/obj/item/prop, var/supplied)
	. = supplied

	if(cocktail_ingredient)
		for(var/decl/cocktail/cocktail in SSmaterials.get_cocktails_by_primary_ingredient(type))
			if(cocktail.matches(prop))
				return cocktail.get_presentation_desc(prop)

/decl/material/proc/neutron_interact(var/neutron_energy, var/total_interacted_units, var/total_units)
	. = list() // Returns associative list of interaction -> interacted units
	if(!length(neutron_interactions))
		return
	for(var/interaction in neutron_interactions)
		var/ideal_energy = neutron_interactions[interaction]
		var/interacted_units_ratio = (clamp(-((((neutron_energy-ideal_energy)**2)/(neutron_cross_section*1000)) - 100), 0, 100))/100
		var/interacted_units = round(interacted_units_ratio*total_interacted_units, 0.001)

		if(interacted_units > 0)
			.[interaction] = interacted_units
			total_interacted_units -= interacted_units
		if(total_interacted_units <= 0)
			return
