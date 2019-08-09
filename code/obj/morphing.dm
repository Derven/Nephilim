/obj/machinery/morphcamera_corpse
	icon = 'computer.dmi'
	icon_state = "morphcamera"
	name = "morphcameraC"
	density = 1
	var/mob/body

	verb/eject()
		set src in view()
		if(usr.loc == src)
			usr.loc = src.loc
			body = null

	New()
		..()
		tocontrol()

	attack_hand(var/mob/M)
		if(body)
			body = null
		for(var/atom/movable/A in contents)
			A.loc = src.loc


	mousedrop(var/atom/movable/over_object, var/atom/movable/over_location)
		if(!body)
			if(istype(over_object, /mob))
				over_object.Move(src)
				call_message(5, "[over_object] засовывается в камеру")
				body = over_object
		else
			call_message(5, "камера занята [over_object]")


/obj/machinery/morphcamera_newbody
	icon = 'computer.dmi'
	icon_state = "morphcamera"
	density = 1
	name = "morphcameraB"
	var/mob/body

	verb/eject()
		set src in view()
		if(usr.loc == src)
			usr.loc = src.loc
			body = null

	attack_hand(var/mob/M)
		if(body)
			body = null
		for(var/atom/movable/A in contents)
			A.loc = src.loc


	mousedrop(var/atom/movable/over_object, var/atom/movable/over_location)
		if(!body)
			if(istype(over_object, /mob))
				over_object.Move(src)
				call_message(5, "[over_object] засовывается в камеру")
				body = over_object
		else
			call_message(5, "камера занята [over_object]")

	New()
		..()
		tocontrol()