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