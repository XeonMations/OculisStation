#define TRANSMISSION_TEXT(text, used_name, color) "<span class='context' style='text-align: center; color: [color]'>[used_name]</span><span class='context' style='text-align: center; color: [LIGHT_COLOR_FAINT_BLUE]'>[text]</span>"

ADMIN_VERB(cmd_admin_broadcast_transmission, R_ADMIN, "Broadcast Transmission", "Broadcast a global transmission to every player.", ADMIN_CATEGORY_EVENTS)
	var/message = tgui_input_text(user, "What are the message contents?", "Message Contents", null, multiline = TRUE, encode = FALSE)
	if(!message)
		return
	var/name_choice = tgui_input_text(user, "Who is the speaker?", "Speaker Name", "John Syndicate", encode = FALSE)
	if(!name_choice)
		return
	var/color_choice = tgui_color_picker(user, "What color is the speaker?", "Speaker Color", LIGHT_COLOR_FAINT_BLUE)
	if(!color_choice)
		return
	user.broadcast_transmission(message, name_choice, color_choice)

/client/proc/broadcast_transmission(message, name_choice, color_choice)
	var/list/active_clients = list()
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(!player_mob?.client)
			continue
		if(isnewplayer(player_mob))
			continue
		active_clients += player_mob.client

	for(var/client/player_client as anything in active_clients)
		INVOKE_ASYNC(player_client, TYPE_PROC_REF(/client, do_transmission), message, name_choice, color_choice)

/client/proc/do_transmission(message, name_choice, color_choice)
	var/list/message_contents = splittext(message, "\n")
	mob.hud_used.transmission_text.alpha = 0
	for(var/line_text as anything in message_contents)
		display_text(mob.hud_used, TRANSMISSION_TEXT(line_text, name_choice, color_choice))
		sleep(1.5 SECONDS * length(splittext(line_text, " ")))
	end_transmission()

/client/proc/end_transmission()
	animate(mob.hud_used.transmission_text, alpha = 0, time = 1 SECONDS)

#undef TRANSMISSION_TEXT
