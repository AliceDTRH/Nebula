/datum/seed_pile
	var/name
	var/amount
	var/datum/seed/seed_type // Keeps track of what our seed is
	var/list/obj/item/seeds/seeds = list() // Tracks actual objects contained in the pile
	var/ID

/datum/seed_pile/New(var/obj/item/seeds/O, var/ID)
	name = O.name
	amount = 1
	seed_type = O.seed
	seeds += O
	src.ID = ID

/datum/seed_pile/proc/matches(var/obj/item/seeds/O)
	if (O.seed == seed_type)
		return 1
	return 0

/datum/seed_pile/Destroy()
	seeds = null
	. = ..()

/obj/machinery/seed_storage
	name = "Seed storage"
	desc = "It stores, sorts, and dispenses seeds."
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	obj_flags = OBJ_FLAG_ANCHORABLE

	base_type = /obj/machinery/seed_storage
	stat_immune = 0
	uncreated_component_parts = null
	construct_state = /decl/machine_construction/default/panel_closed

	var/list/datum/seed_pile/piles = list()
	var/list/starting_seeds = list()
	var/list/scanner = list() // What properties we can view

/obj/machinery/seed_storage/Initialize(var/mapload)
	. = ..()
	for(var/typepath in starting_seeds)
		var/amount = starting_seeds[typepath]
		if(isnull(amount))
			amount = 1
		for (var/i = 1 to amount)
			var/O = new typepath
			add(O)

/obj/machinery/seed_storage/Destroy()
	QDEL_NULL_LIST(piles)
	. = ..()

/obj/machinery/seed_storage/random // This is mostly for testing, but I guess admins could spawn it
	name = "Random seed storage"
	scanner = list("stats", "produce", "soil", "temperature", "light")
	starting_seeds = list(/obj/item/seeds/random = 50)

/obj/machinery/seed_storage/garden
	name = "Garden seed storage"
	scanner = list("stats")
	icon_state = "seeds_generic"
	starting_seeds = list(
		/obj/item/seeds/ambrosiavulgarisseed = 15,
		/obj/item/seeds/appleseed = 15,
		/obj/item/seeds/bananaseed = 15,
		/obj/item/seeds/berryseed = 15,
		/obj/item/seeds/blueberryseed = 15,
		/obj/item/seeds/cabbageseed = 15,
		/obj/item/seeds/carrotseed = 15,
		/obj/item/seeds/chantermycelium = 15,
		/obj/item/seeds/cherryseed = 15,
		/obj/item/seeds/chiliseed = 15,
		/obj/item/seeds/cocoapodseed = 15,
		/obj/item/seeds/cornseed = 15,
		/obj/item/seeds/peanutseed = 15,
		/obj/item/seeds/eggplantseed = 15,
		/obj/item/seeds/amanitamycelium = 15,
		/obj/item/seeds/glowbell = 15,
		/obj/item/seeds/grapeseed = 15,
		/obj/item/seeds/grassseed = 15,
		/obj/item/seeds/harebell = 15,
		/obj/item/seeds/lavenderseed = 15,
		/obj/item/seeds/lemonseed = 15,
		/obj/item/seeds/libertymycelium = 15,
		/obj/item/seeds/limeseed = 15,
		/obj/item/seeds/mtearseed = 15,
		/obj/item/seeds/nettleseed = 15,
		/obj/item/seeds/orangeseed = 15,
		/obj/item/seeds/plumpmycelium = 15,
		/obj/item/seeds/poppyseed = 15,
		/obj/item/seeds/potatoseed = 15,
		/obj/item/seeds/onionseed = 15,
		/obj/item/seeds/garlicseed = 15,
		/obj/item/seeds/pumpkinseed = 15,
		/obj/item/seeds/reishimycelium = 15,
		/obj/item/seeds/riceseed = 15,
		/obj/item/seeds/soyaseed = 15,
		/obj/item/seeds/peppercornseed = 15,
		/obj/item/seeds/sugarcaneseed = 15,
		/obj/item/seeds/sunflowerseed = 15,
		/obj/item/seeds/shandseed = 15,
		/obj/item/seeds/tobaccoseed = 15,
		/obj/item/seeds/tomatoseed = 15,
		/obj/item/seeds/bamboo = 15,
		/obj/item/seeds/watermelonseed = 15,
		/obj/item/seeds/wheatseed = 15,
		/obj/item/seeds/whitebeetseed = 15,
		/obj/item/seeds/algaeseed = 15,
		/obj/item/seeds/clam = 15,
		/obj/item/seeds/barnacle = 15,
		/obj/item/seeds/mollusc = 15
	)

/obj/machinery/seed_storage/xenobotany
	name = "Xenobotany seed storage"
	scanner = list("stats", "produce", "soil", "temperature", "light")
	base_type = /obj/machinery/seed_storage/xenobotany/buildable
	starting_seeds = list(
		/obj/item/seeds/appleseed = 15,
		/obj/item/seeds/bananaseed = 15,
		/obj/item/seeds/berryseed = 15,
		/obj/item/seeds/blueberryseed = 15,
		/obj/item/seeds/cabbageseed = 15,
		/obj/item/seeds/carrotseed = 15,
		/obj/item/seeds/chantermycelium = 15,
		/obj/item/seeds/cherryseed = 15,
		/obj/item/seeds/chiliseed = 15,
		/obj/item/seeds/cocoapodseed = 15,
		/obj/item/seeds/cornseed = 15,
		/obj/item/seeds/peanutseed = 15,
		/obj/item/seeds/eggplantseed = 15,
		/obj/item/seeds/amanitamycelium = 15,
		/obj/item/seeds/glowbell = 15,
		/obj/item/seeds/grapeseed = 15,
		/obj/item/seeds/grassseed = 15,
		/obj/item/seeds/harebell = 15,
		/obj/item/seeds/kudzuseed = 15,
		/obj/item/seeds/lavenderseed = 15,
		/obj/item/seeds/lemonseed = 15,
		/obj/item/seeds/libertymycelium = 15,
		/obj/item/seeds/limeseed = 15,
		/obj/item/seeds/mtearseed = 15,
		/obj/item/seeds/nettleseed = 15,
		/obj/item/seeds/orangeseed = 15,
		/obj/item/seeds/plastiseed = 15,
		/obj/item/seeds/plumpmycelium = 15,
		/obj/item/seeds/poppyseed = 15,
		/obj/item/seeds/potatoseed = 15,
		/obj/item/seeds/onionseed = 15,
		/obj/item/seeds/garlicseed = 15,
		/obj/item/seeds/pumpkinseed = 15,
		/obj/item/seeds/reishimycelium = 15,
		/obj/item/seeds/riceseed = 15,
		/obj/item/seeds/soyaseed = 15,
		/obj/item/seeds/peppercornseed = 15,
		/obj/item/seeds/sugarcaneseed = 15,
		/obj/item/seeds/sunflowerseed = 15,
		/obj/item/seeds/shandseed = 15,
		/obj/item/seeds/tobaccoseed = 15,
		/obj/item/seeds/tomatoseed = 15,
		/obj/item/seeds/towercap = 15,
		/obj/item/seeds/watermelonseed = 15,
		/obj/item/seeds/wheatseed = 15,
		/obj/item/seeds/whitebeetseed = 15,
		/obj/item/seeds/algaeseed = 15,
		/obj/item/seeds/random = 2
	)

/obj/machinery/seed_storage/xenobotany/buildable
	starting_seeds = list()

/obj/machinery/seed_storage/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/seed_storage/interact(mob/user)
	user.set_machine(src)

	var/dat = "<center><h1>Seed storage contents</h1></center>"
	if (piles.len == 0)
		dat += "<font color='red'>No seeds</font>"
	else
		dat += "<table style='text-align:center;border-style:solid;border-width:1px;padding:4px'><tr><td>Name</td>"
		dat += "<td>Variety</td>"
		if ("stats" in scanner)
			dat += "<td>E</td><td>Y</td><td>M</td><td>Pr</td><td>Pt</td><td>Harvest</td>"
		if ("temperature" in scanner)
			dat += "<td>Temp</td>"
		if ("light" in scanner)
			dat += "<td>Light</td>"
		if ("soil" in scanner)
			dat += "<td>Nutri</td><td>Water</td>"
		dat += "<td>Notes</td><td>Amount</td><td></td></tr>"
		for (var/datum/seed_pile/S in piles)
			var/datum/seed/seed = S.seed_type
			if(!seed)
				continue
			dat += "<tr>"
			dat += "<td>[seed.seed_name]</td>"
			dat += "<td>#[seed.uid]</td>"
			if ("stats" in scanner)
				dat += "<td>[seed.get_trait(TRAIT_ENDURANCE)]</td><td>[seed.get_trait(TRAIT_YIELD)]</td><td>[seed.get_trait(TRAIT_MATURATION)]</td><td>[seed.get_trait(TRAIT_PRODUCTION)]</td><td>[seed.get_trait(TRAIT_POTENCY)]</td>"
				if(seed.get_trait(TRAIT_HARVEST_REPEAT))
					dat += "<td>Multiple</td>"
				else
					dat += "<td>Single</td>"
			if ("temperature" in scanner)
				dat += "<td>[seed.get_trait(TRAIT_IDEAL_HEAT)] K</td>"
			if ("light" in scanner)
				dat += "<td>[seed.get_trait(TRAIT_IDEAL_LIGHT)] L</td>"
			if ("soil" in scanner)
				if(seed.get_trait(TRAIT_REQUIRES_NUTRIENTS))
					if(seed.get_trait(TRAIT_NUTRIENT_CONSUMPTION) < 0.05)
						dat += "<td>Low</td>"
					else if(seed.get_trait(TRAIT_NUTRIENT_CONSUMPTION) > 0.2)
						dat += "<td>High</td>"
					else
						dat += "<td>Norm</td>"
				else
					dat += "<td>No</td>"
				if(seed.get_trait(TRAIT_REQUIRES_WATER))
					if(seed.get_trait(TRAIT_WATER_CONSUMPTION) < 1)
						dat += "<td>Low</td>"
					else if(seed.get_trait(TRAIT_WATER_CONSUMPTION) > 5)
						dat += "<td>High</td>"
					else
						dat += "<td>Norm</td>"
				else
					dat += "<td>No</td>"

			dat += "<td>"
			switch(seed.get_trait(TRAIT_CARNIVOROUS))
				if(1)
					dat += "CARN "
				if(2)
					dat	+= "<font color='red'>CARN </font>"
			switch(seed.get_trait(TRAIT_SPREAD))
				if(1)
					dat += "VINE "
				if(2)
					dat	+= "<font color='red'>VINE </font>"
			if ("pressure" in scanner)
				if(seed.get_trait(TRAIT_LOWKPA_TOLERANCE) < 20)
					dat += "LP "
				if(seed.get_trait(TRAIT_HIGHKPA_TOLERANCE) > 220)
					dat += "HP "
			if ("temperature" in scanner)
				if(seed.get_trait(TRAIT_HEAT_TOLERANCE) > 30)
					dat += "TEMRES "
				else if(seed.get_trait(TRAIT_HEAT_TOLERANCE) < 10)
					dat += "TEMSEN "
			if ("light" in scanner)
				if(seed.get_trait(TRAIT_LIGHT_TOLERANCE) > 10)
					dat += "LIGRES "
				else if(seed.get_trait(TRAIT_LIGHT_TOLERANCE) < 3)
					dat += "LIGSEN "
			if(seed.get_trait(TRAIT_TOXINS_TOLERANCE) < 3)
				dat += "TOXSEN "
			else if(seed.get_trait(TRAIT_TOXINS_TOLERANCE) > 6)
				dat += "TOXRES "
			if(seed.get_trait(TRAIT_PEST_TOLERANCE) < 3)
				dat += "PESTSEN "
			else if(seed.get_trait(TRAIT_PEST_TOLERANCE) > 6)
				dat += "PESTRES "
			if(seed.get_trait(TRAIT_WEED_TOLERANCE) < 3)
				dat += "WEEDSEN "
			else if(seed.get_trait(TRAIT_WEED_TOLERANCE) > 6)
				dat += "WEEDRES "
			if(seed.get_trait(TRAIT_PARASITE))
				dat += "PAR "
			if ("temperature" in scanner)
				if(seed.get_trait(TRAIT_ALTER_TEMP) > 0)
					dat += "TEMP+ "
				if(seed.get_trait(TRAIT_ALTER_TEMP) < 0)
					dat += "TEMP- "
			if(seed.get_trait(TRAIT_BIOLUM))
				dat += "LUM "
			dat += "</td>"
			dat += "<td>[S.amount]</td>"
			dat += "<td><a href='byond://?src=\ref[src];task=vend;id=[S.ID]'>Vend</a> <a href='byond://?src=\ref[src];task=purge;id=[S.ID]'>Purge</a></td>"
			dat += "</tr>"
		dat += "</table>"

	show_browser(user, dat, "window=seedstorage;size=800x500")
	onclose(user, "seedstorage")

/obj/machinery/seed_storage/Topic(var/href, var/list/href_list)
	if (..())
		return
	var/task = href_list["task"]
	var/ID = text2num(href_list["id"])

	for (var/datum/seed_pile/N in piles)
		if (N.ID == ID)
			if (task == "vend")
				var/obj/O = pick(N.seeds)
				if (O)
					--N.amount
					N.seeds -= O
					if (N.amount <= 0 || N.seeds.len <= 0)
						piles -= N
						qdel(N)
					flick("[initial(icon_state)]-vend", src)
					O.dropInto(loc)
				else
					piles -= N
					qdel(N)
			else if (task == "purge")
				for (var/obj/O in N.seeds)
					qdel(O)
					piles -= N
					qdel(N)
			break
	updateUsrDialog()

/obj/machinery/seed_storage/attackby(var/obj/item/O, var/mob/user)

	if(istype(O, /obj/item/seeds))
		add(O)
		user.visible_message(SPAN_NOTICE("\The [user] puts \the [O] into \the [src]."))
		return TRUE

	if(istype(O, /obj/item/storage/plants))
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			++loaded
			P.remove_from_storage(G, src, 1)
			add(G, 1)
		P.finish_bulk_removal()
		if (loaded)
			user.visible_message(SPAN_NOTICE("\The [user] puts the seeds from \the [O] into \the [src]."))
		else
			to_chat(user, SPAN_WARNING("There are no seeds in \the [O.name]."))
		return TRUE

	return ..()

/obj/machinery/seed_storage/proc/add(var/obj/item/seeds/O, bypass_removal = 0)
	if(!bypass_removal)
		if (istype(O.loc, /mob))
			var/mob/user = O.loc
			if(!user.try_unequip(O, src))
				return
		else if(istype(O.loc,/obj/item/storage))
			var/obj/item/storage/S = O.loc
			S.remove_from_storage(O, src)

	O.forceMove(src)
	var/newID = 0

	for (var/datum/seed_pile/N in piles)
		if (N.matches(O))
			++N.amount
			N.seeds += (O)
			return
		else if(N.ID >= newID)
			newID = N.ID + 1

	piles += new /datum/seed_pile(O, newID)
	flick("[initial(icon_state)]-vend", src)
	return

/obj/machinery/seed_storage/cannot_transition_to(state_path, mob/user)
	if(state_path == /decl/machine_construction/default/deconstructed)
		var/alert = alert(user, "Are you certain you wish to deconstruct this? It will destroy all seeds stored inside!", "Deconstruct Warning", "Yes",  "No")
		if(alert != "Yes" || !CanPhysicallyInteract(user))
			return MCS_BLOCK
	return ..()

/obj/machinery/seed_storage/dismantle()
	for(var/obj/item/seeds/seed in src)
		qdel(seed) // ..() would dump them; this would cause lots of client lag. We did warn them above...
	return ..()