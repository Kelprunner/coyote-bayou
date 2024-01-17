/datum/keybinding/living/toggle_combat_mode
	hotkey_keys = list("C")
	name = "toggle_combat_mode"
	full_name = "Toggle combat mode"
	category = CATEGORY_COMBAT
	description = "Toggles whether or not you're in combat mode."

/datum/keybinding/living/toggle_combat_mode/down(client/user)
	SEND_SIGNAL(user.mob, COMSIG_TOGGLE_COMBAT_MODE)
	return TRUE

/datum/keybinding/living/active_block
	hotkey_keys = list("Northwest", "F") // HOME
	name = "active_block"
	full_name = "Block (Hold)"
	category = CATEGORY_COMBAT
	description = "Hold down to actively block with your currently in-hand object."

/datum/keybinding/living/active_block/down(client/user)
	var/mob/living/L = user.mob
	L.keybind_start_active_blocking()
	return TRUE

/datum/keybinding/living/active_block/up(client/user)
	var/mob/living/L = user.mob
	L.keybind_stop_active_blocking()

/datum/keybinding/living/active_block_toggle
	hotkey_keys = list("Unbound")
	name = "active_block_toggle"
	full_name = "Block (Toggle)"
	category = CATEGORY_COMBAT
	description = "Toggles active blocking system using currenet in hand object, or any found object if applicable."

/datum/keybinding/living/active_block_toggle/down(client/user)
	var/mob/living/L = user.mob
	L.keybind_toggle_active_blocking()
	return TRUE

/datum/keybinding/living/active_parry
	hotkey_keys = list("Insert", "G")
	name = "active_parry"
	full_name = "Parry"
	category = CATEGORY_COMBAT
	description = "Press to initiate a parry sequence with your currently in-hand object."

/datum/keybinding/living/active_parry/down(client/user)
	var/mob/living/L = user.mob
	L.keybind_parry()
	return TRUE

/datum/keybinding/living/attack_north
	hotkey_keys = list("Unbound")
	name = "attack_north"
	full_name = "Attack North"
	category = CATEGORY_COMBAT
	description = "Press to enter harm intent and attack to the north."

/datum/keybinding/living/attack_north/down(client/user)
	harm_towards(user, NORTH)

/datum/keybinding/living/attack_south
	hotkey_keys = list("Unbound")
	name = "attack_south"
	full_name = "Attack South"
	category = CATEGORY_COMBAT
	description = "Press to enter harm intent and attack to the south."

/datum/keybinding/living/attack_south/down(client/user)
	harm_towards(user, SOUTH)

/datum/keybinding/living/attack_east
	hotkey_keys = list("Unbound")
	name = "attack_east"
	full_name = "Attack East"
	category = CATEGORY_COMBAT
	description = "Press to enter harm intent and attack to the east."

/datum/keybinding/living/attack_east/down(client/user)
	harm_towards(user, EAST)

/datum/keybinding/living/attack_west
	hotkey_keys = list("Unbound")
	name = "attack_west"
	full_name = "Attack West"
	category = CATEGORY_COMBAT
	description = "Press to enter harm intent and attack to the west."

/datum/keybinding/living/attack_west/down(client/user)
	harm_towards(user, WEST)

/proc/harm_towards(client/user, direction)
	var/mob/living/murderer = user.mob

	// [steve harvey voice]: KILL!!!
	murderer.a_intent_change(INTENT_HARM)
	murderer.setDir(direction)

	//get offsets from the direction
	var/xdiff = 0
	var/ydiff = 0
	switch(direction)
		if(NORTH)
			ydiff = 1
		if(SOUTH)
			ydiff = -1
		if(EAST)
			xdiff = 1
		if(WEST)
			xdiff = -1

	//let's find someone to kill.
	var/turf/crimescene = locate(murderer.x + xdiff, murderer.y + ydiff, murderer.z)
	var/mob/living/victim = locate(crimescene)
	if(!istype(victim))
		crimescene = locate(murderer.x + xdiff * 2, murderer.y + ydiff * 2, murderer.z)
		victim = locate(crimescene)

		//so no victim?
		if(!istype(victim))
			murderer.ClickOn(crimescene)
			return
	murderer.ClickOn(victim)
	return
