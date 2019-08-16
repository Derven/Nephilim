/turf
	icon='icons/turfs.dmi'
	var/atom/movable/CRATE
	var/crated = 0

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

		New()
			CRATE = new /atom/movable()
			tocontrol()
			..()

		plating
			icon_state = "plating"
			layer = 1

	wall
		icon_state = "wall"
		density = 1
		opacity = 1
		ru_name = "стена"

		attackby(var/mob/M, var/obj/item/I)
			if(!istype(src, /turf/wall/window))
				if(istype(I, /obj/item/staple))
					M:drop()
					del(I)
					call_message(5, "к [ru_name] крепится скоба")
					new /obj/structure/staple(src)


		window
			opacity = 0
			icon_state = "window"

	space
		icon_state = "space"