
/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if( (usr.client != src) || !src.holder )
		return
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_VAREDIT))	return

		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = sanitize(input(usr,"What would you like to name this mob?","Input a name",M.real_name) as text|null, MAX_NAME_LEN)
		if(!new_name || !M)	return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["dressup"])
		if(!check_rights(R_VAREDIT))	return

		var/mob/living/carbon/human/H = locate(href_list["dressup"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		var/decl/hierarchy/outfit/outfit = input("Select outfit.", "Select equipment.") as null|anything in outfits()
		if(!outfit)
			return

		dressup_human(H, outfit, TRUE)

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/A = locate(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])

	else if(href_list["datumwatch"] && href_list["varnamewatch"])
		var/datum/D = locate(href_list["datumwatch"])
		if(D)
			if(!watched_variables[D])
				watched_variables[D] = list()
			watched_variables[D] |= href_list["varnamewatch"]
			watched_variables()

			if(!watched_variables_window.is_processing)
				START_PROCESSING(SSprocessing, watched_variables_window)

	else if(href_list["datumunwatch"] && href_list["varnameunwatch"])
		var/datum/D = locate(href_list["datumunwatch"])
		if(D && watched_variables[D])
			watched_variables[D] -= href_list["varnameunwatch"]
			var/list/datums_watched_vars = watched_variables[D]
			if(!datums_watched_vars.len)
				watched_variables -= D
		if(!watched_variables.len && watched_variables_window.is_processing)
			STOP_PROCESSING(SSprocessing, watched_variables_window)

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/M = locate(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVENATE))	return

		var/mob/M = locate(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locate(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["delthis"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locate(href_list["delthis"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return
		cmd_admin_delete(O)

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted)")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted)</span>")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)</span>")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))	return

		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum_weak = weakref(D)
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["rotatedatum"])
		if(!check_rights(0))	return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.set_dir(turn(A.dir, -45))
			if("left")	A.set_dir(turn(A.dir, 45))
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["addailment"])

		var/mob/living/carbon/human/H = locate(href_list["addailment"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return
		var/obj/item/organ/O = input("Select a limb to add the ailment to.", "Add Ailment") as null|anything in H.get_organs()
		if(QDELETED(H) || QDELETED(O) || O.owner != H)
			return
		var/list/possible_ailments = list()
		for(var/atype in subtypesof(/datum/ailment))
			var/datum/ailment/ailment = get_ailment_reference(atype)
			if(ailment && ailment.category != ailment.type && ailment.can_apply_to(O))
				possible_ailments |= ailment

		var/datum/ailment/ailment = input("Select an ailment type to add.", "Add Ailment") as null|anything in possible_ailments
		if(!istype(ailment))
			return
		if(!QDELETED(H) && !QDELETED(O) && O.owner == H && O.add_ailment(ailment))
			to_chat(usr, SPAN_NOTICE("Added [ailment] to \the [H]."))
		else
			to_chat(usr, SPAN_WARNING("Failed to add [ailment] to \the [H]."))
		return

	else if(href_list["remailment"])

		var/mob/living/carbon/human/H = locate(href_list["remailment"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return
		var/list/all_ailments = list()
		for(var/obj/item/organ/O in H.get_organs())
			for(var/datum/ailment/ailment in O.ailments)
				all_ailments["[ailment.name] - [O.name]"] = ailment

		var/datum/ailment/ailment = input("Which ailment do you wish to remove?", "Removing Ailment") as null|anything in all_ailments
		if(!ailment)
			return
		ailment = all_ailments[ailment]
		if(istype(ailment) && ailment.organ && ailment.organ.owner == H && ailment.organ.remove_ailment(ailment))
			to_chat(usr, SPAN_NOTICE("Removed [ailment] from \the [H]."))
		else
			to_chat(usr, SPAN_WARNING("Failed to remove [ailment] from \the [H]."))
		return

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in get_all_species()

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.change_species(new_species))
			to_chat(usr, "Set species of [H] to [H.species].")
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/list/language_types = decls_repository.get_decls_of_subtype(/decl/language)
		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in language_types

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/decl/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/living/H = locate(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living")
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as null|anything in possibleverbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb || verb == "Cancel")
			return
		else
			H.verbs += verb

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/H = locate(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		var/verb = input("Please choose a verb to remove.","Verbs",null) as null|anything in H.verbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb)
			return
		else
			H.verbs -= verb

	else if(href_list["addorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["addorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/obj/item/organ/new_organ = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/obj/item/organ)
		if(!new_organ) return

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(locate(new_organ) in M.get_internal_organs())
			to_chat(usr, "Mob already has that organ.")
			return

		var/obj/item/organ/target_organ = M.get_organ(initial(new_organ.parent_organ))
		if(!target_organ)
			to_chat(usr, "Mob doesn't have \a [target_organ] to install that in.")
			return
		var/obj/item/organ/organ_instance = new new_organ(M)
		M.add_organ(organ_instance, target_organ)


	else if(href_list["remorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["remorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/obj/item/organ/rem_organ = input("Please choose an organ to remove.","Organ",null) as null|anything in M.get_internal_organs()

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!(locate(rem_organ) in M.get_internal_organs()))
			to_chat(usr, "Mob does not have that organ.")
			return

		to_chat(usr, "Removed [rem_organ] from [M].")
		M.remove_organ(rem_organ)
		if(!QDELETED(rem_organ))
			qdel(rem_organ)

	else if(href_list["fix_nano"])
		if(!check_rights(R_DEBUG)) return

		var/mob/H = locate(href_list["fix_nano"])

		if(!istype(H) || !H.client)
			to_chat(usr, "This can only be done on mobs with clients")
			return

		SSnano.close_uis(H)
		H.client.cache.Cut()
		var/datum/asset/assets = get_asset_datum(/datum/asset/nanoui)
		assets.send(H)

		to_chat(usr, "Resource files sent")
		to_chat(H, "Your NanoUI Resource files have been refreshed")

		log_admin("[key_name(usr)] resent the NanoUI resource files to [key_name(H)] ")

	else if(href_list["updateicon"])
		if(!check_rights(0))
			return
		var/mob/M = locate(href_list["updateicon"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.update_icon()

	else if(href_list["refreshoverlays"])
		if(!check_rights(0))
			return
		var/mob/living/carbon/human/H = locate(href_list["refreshoverlays"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return
		H.refresh_visible_overlays()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))	return

		var/mob/living/L = locate(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if(BRUTE)
				L.adjustBruteLoss(amount)
			if(BURN)
				L.adjustFireLoss(amount)
			if(TOX)
				L.adjustToxLoss(amount)
			if(OXY)
				L.adjustOxyLoss(amount)
			if(BP_BRAIN)
				L.adjustBrainLoss(amount)
			if(CLONE)
				L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L]")
			message_admins("<span class='notice'>[key_name(usr)] dealt [amount] amount of [Text] damage to [L]</span>")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	else if(href_list["call_proc"])
		var/datum/D = locate(href_list["call_proc"])
		if(istype(D) || istype(D, /client)) // can call on clients too, not just datums
			callproc_targetpicked(1, D)
	else if(href_list["addaura"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))	return
		var/mob/living/L = locate(href_list["addaura"])
		if(!istype(L))
			return
		var/choice = input("Please choose an aura to add", "Auras", null) as null|anything in typesof(/obj/aura)
		if(!choice || !L)
			return
		var/obj/o = new choice(L)
		log_and_message_admins("added \the [o] to \the [L]")
	else if(href_list["removeaura"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))	return
		var/mob/living/L = locate(href_list["removeaura"])
		if(!istype(L))
			return
		var/choice = input("Please choose an aura to remove", "Auras", null) as null|anything in L.auras
		if(!choice || !L)
			return
		log_and_message_admins("removed \the [choice] to \the [L]")
		qdel(choice)

	else if(href_list["addstressor"])
		if(!check_rights(R_DEBUG))
			return
		var/mob/living/L = locate(href_list["addstressor"])
		if(!istype(L))
			return
		var/static/list/_all_stressors
		if(!_all_stressors)
			_all_stressors = SSmanaged_instances.get_category(/datum/stressor)
		var/datum/stressor/stressor = input("Select a stressor to add or refresh.", "Add Stressor") as null|anything in _all_stressors
		if(!stressor)
			return
		var/duration = clamp(input("Enter a duration ([STRESSOR_DURATION_INDEFINITE] for permanent).", "Add Stressor") as num|null, STRESSOR_DURATION_INDEFINITE, INFINITY)
		if(duration && L.add_stressor(stressor, duration))
			log_and_message_admins("added [stressor] to \the [L] for duration [duration].")

	else if(href_list["removestressor"])
		if(!check_rights(R_DEBUG))
			return
		var/mob/living/L = locate(href_list["removestressor"])
		if(!istype(L))
			return
		if(!length(L.stressors))
			to_chat(usr, "Nothing to remove.")
			return
		var/datum/stressor/stressor = input("Select a stressor to remove.", "Remove Stressor") as null|anything in L.stressors
		if(L.remove_stressor(stressor))
			log_and_message_admins("removed [stressor] from \the [L].")

	else if(href_list["setstatuscond"])
		if(!check_rights(R_DEBUG))
			return
		var/mob/living/L = locate(href_list["setstatuscond"])
		if(!istype(L))
			return
		var/list/all_status_conditions = decls_repository.get_decls_of_subtype(/decl/status_condition)
		var/list/select_from_conditions = list()
		for(var/status_cond in all_status_conditions)
			select_from_conditions += all_status_conditions[status_cond]
		var/decl/status_condition/selected_condition = input("Select a status condition to set.", "Set Status Condition") as null|anything in select_from_conditions
		if(!selected_condition || QDELETED(L) || !check_rights(R_DEBUG))
			return
		var/amt = input("Enter an amount to set the condition to.", "Set Status Condition") as num|null
		if(isnull(amt) || QDELETED(L) || !check_rights(R_DEBUG))
			return
		if(amt < 0)
			amt += GET_STATUS(L, selected_condition.type)
		L.set_status(selected_condition.type, amt)
		log_and_message_admins("set [selected_condition.name] to [amt] on \the [L].")

	else if(href_list["setmaterial"])
		if(!check_rights(R_DEBUG))	return

		var/obj/item/I = locate(href_list["setmaterial"])
		if(!istype(I))
			to_chat(usr, "This can only be done to instances of type /obj/item")
			return

		var/new_material = input("Please choose a new material.","Materials",null) as null|anything in SSmaterials.materials_by_name
		if(!new_material)
			return
		if(QDELETED(I))
			to_chat(usr, "Item doesn't exist anymore")
			return

		var/decl/material/M = SSmaterials.materials_by_name[new_material]
		I.set_material(M.type)
		to_chat(usr, "Set material of [I] to [I.get_material()].")

	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(istype(DAT, /datum) || istype(DAT, /client))
			debug_variables(DAT)

	return
