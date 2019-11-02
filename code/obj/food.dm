/obj/item
	var/eatable = 0
	var/nutrition = 0

	verb/eat()
		set src in range(1, usr)
		if(istype(usr, /mob/living/human))
			if(src.loc != usr)
				if(usr:ostomach)
					if(usr:ostomach:content == null)
						usr:ostomach:content = src
						src.loc = usr
						usr.message_to_usr("גû סתוכט [ru_name]")

	food
		eatable = 1
		nutrition = 10

		New()
			..()
			var/datum/reagents/R = new/datum/reagents(50)
			reagents = R
			R.my_atom = src