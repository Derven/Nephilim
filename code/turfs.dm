/turf
	icon='icons/turfs.dmi'

	space
		hull
			icon_state = "hull"

	floor
		icon_state = "floor"

		cool
			temperature = 0

		hot
			temperature = 800

		water
			water = 10000

		attack_hand()
			world << "[oxygen];[temperature];[pressure]"

		attackby(var/mob/M, var/obj/item/I)
			if(istype(I, /obj/item/unconnected_cable))
				M:drop()
				call_message(3, "[M] прокладывает [I.ru_name] на полу")
				var/obj/electro/cable/copper/CBL = new /obj/electro/cable/copper(src)
				CBL.dir = I.dir
				del(I)

		New()
			tocontrol()
			..()

		plating
			icon_state = "plating"

	wall
		icon_state = "wall"
		density = 1
		opacity = 1
		ru_name = "стена"

		window
			opacity = 0
			icon_state = "window"

	space
		icon_state = "space"