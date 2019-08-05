/turf
	icon='icons/turfs.dmi'

	floor
		icon_state = "floor"

		cool
			temperature = 0

		hot
			temperature = 800

		attack_hand()
			world << "[oxygen];[temperature];[pressure]"

		New()
			tocontrol()
			..()

		plating
			icon_state = "plating"

	wall
		icon_state = "wall"
		density = 1
		opacity = 1

		window
			opacity = 0
			icon_state = "window"

	space
		icon_state = "space"