/obj/structure/preparing_table
	icon = 'structure.dmi'
	icon_state = "preparing_table"
	density = 1
	anchored = 1

	mousedrop(var/atom/movable/over_object, var/atom/movable/over_location)
		if(istype(over_object, /mob/living/human))
			call_message(5, "[usr] валит [over_object] на операционный стол")
			if(!over_object:rest)
				over_object:rest()
				over_object.loc = src.loc
