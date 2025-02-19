/datum
	/// Tracks how many event registrations are listening to us. Used in cleanup to prevent dangling references.
	var/event_source_count = 0
	/// Tracks how many event registrations we are listening to. Used in cleanup to prevent dangling references.
	var/event_listen_count = 0
	/// Tracks how many global event registrations we are listening to. Used in cleanup to prevent dangling references.
	var/global_listen_count = 0

/proc/cleanup_events(var/datum/source)
	if(source?.global_listen_count > 0)
		cleanup_global_listener(source, source.global_listen_count)
	if(source?.event_source_count > 0)
		cleanup_source_listeners(source, source.event_source_count)
	if(source?.event_listen_count > 0)
		cleanup_event_listener(source, source.event_listen_count)

/decl/observ/register(var/datum/event_source, var/datum/listener, var/proc_call)
	. = ..()
	if(.)
		event_source.event_source_count++
		listener.event_listen_count++

/decl/observ/unregister(var/datum/event_source, var/datum/listener, var/proc_call)
	. = ..() // returns the number of events removed
	if(.)
		event_source.event_source_count -= .
		listener.event_listen_count -= .

/decl/observ/register_global(var/datum/listener, var/proc_call)
	. = ..()
	if(.)
		listener.global_listen_count += 1

/decl/observ/unregister_global(var/datum/listener, var/proc_call)
	. = ..()
	if(.)
		listener.global_listen_count -= .

/proc/cleanup_global_listener(listener, listen_count)
	var/events_removed
	for(var/decl/observ/event in decls_repository.get_decls_of_subtype_unassociated(/decl/observ))
		if((events_removed = event.unregister_global(listener)))
			log_debug("[event] ([event.type]) - [log_info_line(listener)] was deleted while still globally registered to an event.")
			listen_count -= events_removed
			if(!listen_count)
				return
	if(listen_count > 0)
		CRASH("Failed to clean up all global listener entries!")

// This might actually be fast enough now that there's no point in logging it?
/proc/cleanup_source_listeners(datum/event_source, source_listener_count)
	event_source.event_source_count = 0
	var/events_removed
	for(var/event_type in event_source.event_listeners)
		var/list/list/proc_owners = event_source.event_listeners[event_type]
		if(proc_owners)
			var/decl/observ/event = GET_DECL(event_type)
			for(var/proc_owner in proc_owners)
				var/list/callbacks_cached = proc_owners[proc_owner]?.Copy()
				if((events_removed = event.unregister(event_source, proc_owner)))
					log_debug("[event] ([event.type]) - [log_info_line(event_source)] was deleted while still being listened to by [log_info_line(proc_owner)]. Callbacks: [json_encode(callbacks_cached)]")
					source_listener_count -= events_removed
					if(!source_listener_count)
						return
	if(source_listener_count > 0)
		CRASH("Failed to clean up all event source entries!")

/proc/cleanup_event_listener(datum/listener, listener_count)
	listener.event_listen_count = 0
	var/events_removed
	for(var/event_type in listener._listening_to)
		var/list/listened_sources = listener._listening_to[event_type]
		if(listened_sources)
			for(var/datum/event_source in listened_sources)
				var/list/callbacks_cached = event_source.event_listeners[event_type]?[listener]?.Copy()
				var/decl/observ/event = GET_DECL(event_type)
				if((events_removed = event.unregister(event_source, listener)))
					log_debug("[event] ([event.type]) - [log_info_line(listener)] was deleted while still listening to [log_info_line(event_source)]. Callbacks: [json_encode(callbacks_cached)]")
					listener_count -= events_removed
					if(!listener_count)
						return
	if(listener_count > 0)
		CRASH("Failed to clean up all listener entries!")
