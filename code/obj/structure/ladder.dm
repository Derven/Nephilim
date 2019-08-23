/obj/structure/ladder_up
	icon = 'structure.dmi'
	icon_state = "ladder_up"
	anchored = 1

	attack_hand(var/mob/M)
		call_message(3, "[M] поднимается по лестнице")
		M.z++

/obj/structure/ladder_down
	icon = 'structure.dmi'
	icon_state = "ladder_down"
	anchored = 1

	attack_hand(var/mob/M)
		call_message(3, "[M] опускается по лестнице")
		M.z--

/obj/structure/closet
	icon = 'structure.dmi'
	icon_state = "closet_1"
	var/state = "closet"
	ru_name = "шкаф"
	var/close = 1
	anchored = 0
	density = 1
	easy_deconstruct = 1
	construct_parts = list(/obj/item/stack/metal, /obj/item/stack/metal)

	oxycloset
		icon_state = "oxycloset_1"
		state = "oxycloset"

	cryopod
		ru_name = "криокамера"
		icon_state = "cryopod_1"
		state = "cryopod"
		anchored = 1

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)

	Del()
		..()
		for(var/atom/movable/M in src.loc)
			if(M.anchored == 0)
				M.loc = src

	New()
		..()
		spawn(5)
			for(var/atom/movable/M in src.loc)
				if(M.anchored == 0)
					M.loc = src

	attack_hand(var/mob/M)
		close = !close
		icon_state = "[state]_[close]"
		density = close
		if(!close)
			for(var/atom/movable/M2 in src)
				M2.loc = src.loc
		else
			for(var/atom/movable/M2 in src.loc)
				if(M.anchored == 0 && !istype(M2, /dz))
					M2.loc = src