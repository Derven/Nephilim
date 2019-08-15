/obj/structure/lattice
	icon = 'structure.dmi'
	icon_state = "lattice"
	name = "lattice"
	ru_name = "решетка"
	density = 0
	anchored = 1
	layer = 2

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