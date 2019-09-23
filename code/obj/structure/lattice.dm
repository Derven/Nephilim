/obj/structure/lattice
	icon = 'structure.dmi'
	icon_state = "lattice"
	name = "lattice"
	ru_name = "решетка"
	density = 0
	anchored = 1
	layer = 2
	construct_parts = list(/obj/item/stack/metal)
	easy_deconstruct = 1

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)
		if(istype(I, /obj/item/stack/metal))
			if(I:amount > 0)
				new /turf/floor/plating( locate(src.x, src.y, src.z) )
				I:amount--
				I:check_amount(M)
				del(src)

/obj/structure/strange_machine
	icon = 'structure.dmi'
	name = "machinery"
	ru_name = "странное устройство"
	density = 1
	anchored = 1

/obj/structure/catwalk
	icon = 'structure.dmi'
	icon_state = "catwalk"
	layer = 8
	var/destroyed = 0
	anchored = 1

	New()
		..()
		spawn(5)
			for(var/atom/movable/M in src.loc)
				if(M != src)
					M.layer = M.layer + 10

	//attack_hand()
	//	destroy()

	proc/fall()
		..()
		if(istype(src.loc, /turf/floor/openspess))
			for(var/atom/movable/M in src.loc)
				if(M != src)
					M.collisionBumped(rand(10,20))
					call_message(3, "[M.ru_name ? M.ru_name : M.name] падает с навеса")
					if(z > 1)
						for(var/atom/movable/M2 in get_step(locate(x,y,z-1), pick(SOUTH, WEST, EAST, NORTH)))
							call_message(3, "[M.ru_name ? M.ru_name : M.name] падает на [M2.ru_name ? M2.ru_name : M2.name]")
							if(istype(M, /obj/item))
								M2.collisionBumped(rand(10,20))
							else
								M2.collisionBumped(rand(30,90))
						M.loc = get_step(locate(x,y,z-1), pick(SOUTH, WEST, EAST, NORTH))
						M.layer = initial(M.layer)
			if(z > 1)
				for(var/atom/movable/M in locate(x,y,z-1))
					M.collisionBumped(rand(20,80))
					call_message(3, "Навес падает на [M.ru_name ? M.ru_name : M.name]")
				new /obj/item/stack/metal(get_step(locate(x,y,z-1), pick(SOUTH, WEST, EAST, NORTH)))
		else
			new /obj/item/stack/metal(src.loc)
		//world << "[x];[y];[z]"

	proc/destroy()
		destroyed = 1
		fall()
		sleep(1)
		var/list/turf/TURFS = list()
		TURFS = check_in_cardinal(1)
		for(var/turf/T in TURFS)
			for(var/obj/structure/catwalk/CW in T)
				if(!CW.destroyed)
					CW.destroy()
		del(src)

	Crossed(atom/movable/O2)
		O2.layer = layer + 1

	Uncrossed(atom/movable/O2)
		..()
		for(var/obj/structure/catwalk/CW in O2.loc)
			return
		O2.layer = initial(O2.layer)

/obj/structure/staple
	icon = 'structure.dmi'
	icon_state = "staple"
	name = "staple"
	ru_name = "скоба"
	density = 0
	anchored = 1
	layer = 4
	construct_parts = list(/obj/item/staple)
	easy_deconstruct = 1

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)