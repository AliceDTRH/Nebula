// Attached to a stock part for issuing commands to machinery via networks.
/datum/extension/network_device/stock_part
	has_commands = TRUE

// Network receivers check the access of the parent machine, and do not check for network administrator access.
/datum/extension/network_device/stock_part/has_access(mob/user)
	var/datum/computer_network/network = get_network()
	if(!network)
		return TRUE // If not on network, always TRUE for access, as there isn't anything to access.
	if(!user)
		return FALSE
	var/atom/H = holder
	var/obj/M = H.loc
	return M.allowed(user)

/datum/extension/network_device/stock_part/get_command_target()
	var/atom/A = holder
	var/obj/machinery/M = A.loc
	if(istype(M))
		return M