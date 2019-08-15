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
				call_message(3, "[M] ������������ [I.ru_name] �� ����")
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
		ru_name = "�����"

		attackby(var/mob/M, var/obj/item/I)
			if(!istype(src, /turf/wall/window))
				if(istype(I, /obj/item/staple))
					M:drop()
					del(I)
					call_message(5, "� [ru_name] �������� �����")
					new /obj/structure/staple(src)


		window
			opacity = 0
			icon_state = "window"

	space
		icon_state = "space"