#define PLAYER_HOP_DELAY 25

//Huge, carnivorous toads that spit an immobilizing toxin at its victims before leaping onto them.
//It has no melee attack, and its damage comes from the toxin in its bubbles and its crushing leap.
//Its eyes will turn red to signal an imminent attack!
/mob/living/simple_animal/hostile/jungle/leaper
	name = "leaper"
	desc = "Commonly referred to as 'leapers', the Geron Toad is a massive beast that spits out highly pressurized bubbles containing a unique toxin, knocking down its prey and then crushing it with its girth."
	icon = 'icons/mob/jungle/leaper.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 300
	health = 300
	ranged = TRUE
	projectiletype = /obj/item/projectile/leaper
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged_cooldown_time = 30
	pixel_x = -16
	layer = LARGE_MOB_LAYER
	speed = 10
	robust_searching = 1
	var/hopping = FALSE
	var/hop_cooldown = 0 //Strictly for player controlled leapers
	var/projectile_ready = FALSE //Stopping AI leapers from firing whenever they want, and only doing it after a hop has finished instead

	footstep_type = FOOTSTEP_MOB_HEAVY

/obj/item/projectile/leaper
	name = "leaper bubble"
	icon_state = "leaper"
	knockdown = 50
	damage = 0
	range = 7
	hitsound = 'sound/effects/snap.ogg'
	nondirectional_sprite = TRUE
	impact_effect_type = /obj/effect/temp_visual/leaper_projectile_impact

/obj/item/projectile/leaper/on_hit(atom/target, blocked = FALSE)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
		return
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.adjustHealth(25)

/obj/item/projectile/leaper/on_range()
	var/turf/T = get_turf(src)
	..()
	new /obj/structure/leaper_bubble(T)

/obj/effect/temp_visual/leaper_projectile_impact
	name = "leaper bubble"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "leaper_bubble_pop"
	plane = MOB_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3

/obj/effect/temp_visual/leaper_projectile_impact/Initialize()
	. = ..()
	new /obj/effect/decal/cleanable/leaper_sludge(get_turf(src))

/obj/effect/decal/cleanable/leaper_sludge
	name = "leaper sludge"
	desc = "A small pool of sludge, containing trace amounts of leaper venom."
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "tomato_floor1"

/obj/structure/leaper_bubble
	name = "leaper bubble"
	desc = "A floating bubble containing leaper venom. The contents are under a surprising amount of pressure."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "leaper"
	max_integrity = 10
	density = FALSE

/obj/structure/leaper_bubble/Initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED =PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable,float), TRUE)
	QDEL_IN(src, 100)

/obj/structure/leaper_bubble/Destroy()
	new /obj/effect/temp_visual/leaper_projectile_impact(get_turf(src))
	playsound(src,'sound/effects/snap.ogg',50, 1, -1)
	return ..()

/obj/structure/leaper_bubble/proc/on_entered(atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/simple_animal/hostile/jungle/leaper))
			playsound(src,'sound/effects/snap.ogg',50, 1, -1)
			L.DefaultCombatKnockdown(50)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
			if(isanimal(L))
				var/mob/living/simple_animal/A = L
				A.adjustHealth(25)
			qdel(src)

/datum/reagent/toxin/leaper_venom
	name = "Leaper venom"
	description = "A toxin spat out by leapers that, while harmless in small doses, quickly creates a toxic reaction if too much is in the body."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0
	taste_description = "french cuisine"
	taste_mult = 1.3

/datum/reagent/toxin/leaper_venom/on_mob_life(mob/living/carbon/M)
	if(volume >= 10)
		M.adjustToxLoss(5, 0)
	..()

/obj/effect/temp_visual/leaper_crush
	name = "grim tidings"
	desc = "Incoming leaper!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lily_pad"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	duration = 30

/mob/living/simple_animal/hostile/jungle/leaper/Initialize()
	. = ..()
	remove_verb(src, /mob/living/verb/pulled)

/mob/living/simple_animal/hostile/jungle/leaper/CtrlClickOn(atom/A)
	face_atom(A)
	GiveTarget(A)
	if(!isturf(loc))
		return
	if(!CheckActionCooldown())
		return
	if(hopping)
		return
	if(isliving(A))
		var/mob/living/L = A
		if(L.incapacitated())
			BellyFlop()
			return
	if(hop_cooldown <= world.time)
		Hop(player_hop = TRUE)

/mob/living/simple_animal/hostile/jungle/leaper/AttackingTarget()
	if(isliving(get_target()))
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/leaper/handle_automated_action()
	if(hopping || projectile_ready)
		return
	. = ..()
	var/atom/my_target = get_target()
	if(!my_target)
		return
	if(isliving(my_target))
		var/mob/living/L = my_target
		if(L.incapacitated())
			BellyFlop()
			return
	if(!hopping)
		Hop()

/mob/living/simple_animal/hostile/jungle/leaper/BiologicalLife(seconds, times_fired)
	if(!(. = ..()))
		return
	update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(prob(33) && !ckey)
		ranged_cooldown = 0 //Keeps em on their toes instead of a constant rotation
	..()

/mob/living/simple_animal/hostile/jungle/leaper/OpenFire()
	var/atom/my_target = get_target()
	face_atom(my_target)
	if(!ranged_cooldown <= world.time)
		return
	if(ckey)
		if(hopping)
			return
		if(isliving(my_target))
			var/mob/living/L = my_target
			if(L.incapacitated())
				return //No stunlocking. Hop on them after you stun them, you donk.
	if(AIStatus == AI_ON && !projectile_ready && !ckey)
		return
	. = ..(my_target)
	projectile_ready = FALSE
	update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/proc/Hop(player_hop = FALSE)
	var/atom/my_target = get_target()
	if(!my_target || z != my_target.z)
		return
	hopping = TRUE
	density = FALSE
	pass_flags |= PASSMOB
	mob_transforming = TRUE
	var/turf/new_turf = locate((my_target.x + rand(-3,3)),(my_target.y + rand(-3,3)),my_target.z)
	if(player_hop)
		new_turf = get_turf(my_target)
		hop_cooldown = world.time + PLAYER_HOP_DELAY
	if(AIStatus == AI_ON && ranged_cooldown <= world.time)
		projectile_ready = TRUE
		update_icons()
	throw_at(new_turf, max(3,get_dist(src,new_turf)), 1, src, FALSE, callback = CALLBACK(src,PROC_REF(FinishHop)))

/mob/living/simple_animal/hostile/jungle/leaper/proc/FinishHop()
	density = TRUE
	mob_transforming = FALSE
	pass_flags &= ~PASSMOB
	hopping = FALSE
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, 1)
	var/atom/my_target = get_target()
	if(my_target && AIStatus == AI_ON && projectile_ready && !ckey)
		face_atom(my_target)
		addtimer(CALLBACK(src,PROC_REF(OpenFire), my_target), 5)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlop()
	var/turf/new_turf = get_turf(get_target())
	hopping = TRUE
	mob_transforming = TRUE
	new /obj/effect/temp_visual/leaper_crush(new_turf)
	addtimer(CALLBACK(src,PROC_REF(BellyFlopHop), new_turf), 30)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlopHop(turf/T)
	density = FALSE
	throw_at(T, get_dist(src,T),1,src, FALSE, callback = CALLBACK(src,PROC_REF(Crush)))

/mob/living/simple_animal/hostile/jungle/leaper/proc/Crush()
	hopping = FALSE
	density = TRUE
	mob_transforming = FALSE
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in orange(1, src))
		L.adjustBruteLoss(35)
		if(!QDELETED(L)) // Some mobs are deleted on death
			var/throw_dir = get_dir(src, L)
			if(L.loc == loc)
				throw_dir = pick(GLOB.alldirs)
			var/throwtarget = get_edge_target_turf(src, throw_dir)
			L.throw_at(throwtarget, 3, 1)
			visible_message(span_warning("[L] is thrown clear of [src]!"))
	if(ckey)//Lessens ability to chain stun as a player
		ranged_cooldown = ranged_cooldown_time + world.time
		update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/Goto()
	return

/mob/living/simple_animal/hostile/jungle/leaper/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	return

/mob/living/simple_animal/hostile/jungle/leaper/update_icons()
	. = ..()
	if(stat)
		icon_state = "leaper_dead"
		return
	if(ranged_cooldown <= world.time)
		if(AIStatus == AI_ON && projectile_ready || ckey)
			icon_state = "leaper_alert"
			return
	icon_state = "leaper"

#undef PLAYER_HOP_DELAY
