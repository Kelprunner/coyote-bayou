//Fallout 13 decorative decals - the rest of pure decorative stuff is in decor.dm

/obj/effect/decal/waste
	name = "puddle of goo"
	desc = "A puddle of sticky, incredibly toxic and likely radioactive green goo."
	icon = 'icons/fallout/objects/decals.dmi'
	icon_state = "goo1"
	anchored = 1
	layer = 2.1
	light_color = LIGHT_COLOR_GREEN
	light_power = 3
	light_range = 3
	/// range of radiated tiles
	var/range = 2
	/// rads per 2 seconds to blast someone with per puddle
	var/intensity = 20
	/// coordinates to turfs we're irradiating
	var/list/rad_turfs = list()
	tastes = list("a flavor thats definitely not green apple" = 2, "a whole lot of regret" = 1)

/obj/effect/decal/waste/Initialize()
	. = ..()
	icon_state = "goo[rand(1,13)]"
//	AddComponent(/datum/component/radioactive, 200, src, 0, TRUE, TRUE) //half-life of 0 because we keep on going.
//NO BAD. The radiation component SUCKS ASS - these components self-propagate into 500+ "radiation waves"
	//START_PROCESSING(SSradiation,src) //Let's do this in a far more reasonable way- radiate players around us on a pulse. That's it.
	//turns out *that* way wasn't really reasonable either. Lets try something else!
	irradiate_turfs()

/obj/effect/decal/waste/Destroy()
	//STOP_PROCESSING(SSradiation,src)
	unirradiate_turfs()
	qdel(rad_turfs)
	..()

/// gets all the turfs in range, records its coordinates (like heck I'm making a million zillion weakrefs), 
/// and gives them a component, or ups the component's power
/obj/effect/decal/waste/proc/irradiate_turfs()
	if(QDELETED(src))
		return
	for(var/turf/rad_turf in view(range, get_turf(src)))
		if(SEND_SIGNAL(rad_turf, COMSIG_TURF_IRRADIATE, intensity, WEAKERREF(src))) // if we get something back from the turf, its already radioactive
			continue // and made more radioactive~
		rad_turf.AddComponent(/datum/component/radiation_turf, intensity, WEAKERREF(src)) // the component will handle the SSradiation stuff
		rad_turfs += turf2coords(rad_turf) // record what turfs are irradiated so we can remove them later

/// Asks all the turfs in range to reduce or remove the radiation
/obj/effect/decal/waste/proc/unirradiate_turfs()
	for(var/coor in rad_turfs)
		var/turf/radioturf = coords2turf(coor)
		if(!isturf(radioturf) || (QDELETED(radioturf)))
			continue
		SEND_SIGNAL(radioturf, COMSIG_TURF_IRRADIATE, -intensity, WEAKERREF(src))

/*
//Bing bang boom done
/obj/effect/decal/waste/process()
	if(QDELETED(src))
		return PROCESS_KILL

	for(var/mob/living/carbon/human/victim in view(src,range))
		if(victim.stat != DEAD)
			victim.rad_act(intensity)
	for(var/obj/item/geiger_counter/geiger in view(src,range))
		geiger.rad_act(intensity)
	for(var/obj/machinery/power/rad_collector in view(src,range))
		rad_collector.rad_act(intensity*10)
*/

/obj/effect/decal/waste/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crafting/abraxo))
		user.show_message(span_notice("You start sprinkling \the [I.name] onto the puddle of goo..."), MSG_VISUAL)
		if(do_after(user, 30, target = src))
			user.show_message(span_notice("You neutralize the radioactive goo!"), MSG_VISUAL)
			new /obj/effect/decal/cleanable/chem_pile(src.loc) //Leave behind some cleanable chemical powder
			qdel(src)
			qdel(I)
	else
		return ..()

/obj/effect/decal/marking
	name = "road marking"
	desc = "Road surface markings were used on paved roadways to provide guidance and information to drivers and pedestrians.<br>Nowadays, those wandering the wasteland commonly use them as directional landmarks."
	icon = 'icons/fallout/objects/decals.dmi'
	icon_state = "singlevertical" //See decals.dmi for different icon states of road markings.
	anchored = 1
	layer = 2.1
	resistance_flags = INDESTRUCTIBLE

/obj/effect/decal/riverbank
	name = "riverbank"
	desc = "try"
	icon = 'icons/fallout/objects/decals.dmi'
	icon_state = "riverbank"
	anchored = 1
	layer = 2.1
	resistance_flags = INDESTRUCTIBLE

/obj/effect/decal/riverbankcorner
	name = "riverbankcorner"
	desc = "try2"
	icon = 'icons/fallout/objects/decals.dmi'
	icon_state = "riverbank2"
	anchored = 1
	layer = 2.1
	resistance_flags = INDESTRUCTIBLE
