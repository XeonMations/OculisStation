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
	var/list/active_players = list()
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(!player_mob?.client)
			continue
		if(isnewplayer(player_mob)) // exclude people in the lobby
			continue
		active_players += player_mob

	for(var/mob/player as anything in active_players)
		INVOKE_ASYNC(player, TYPE_PROC_REF(/mob, do_transmission), message, name_choice, color_choice)

/mob/proc/do_transmission(message, name_choice, color_choice)
	var/list/message_contents = splittext(message, "\n")
	hud_used.transmission_text.alpha = 0
	for(var/line_text as anything in message_contents)
		display_text(client, hud_used, TRANSMISSION_TEXT(line_text, name_choice, color_choice))
		sleep(5 SECONDS)
	end_transmission()

/mob/proc/end_transmission()
	animate(hud_used.transmission_text, alpha = 0, time = 1 SECONDS)

#undef TRANSMISSION_TEXT
