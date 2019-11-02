/obj/structure
	icon = 'structure.dmi'

/obj/structure/chair
	icon_state = "chair"
	anchored = 0

	attack_hand(var/mob/M)
		if(istype(src, /obj/structure/chair/venicle))
			if(src:SLOT)
				overlays -= src:SLOT
				src:SLOT.loc = src.loc
				src:SLOT = null
				return
			if(!M.buckled)
				M.MACHINE = src
			else
				M.MACHINE = null
		for(var/mob/M2 in src.loc)
			call_message(3, "[M2] [M2.buckled ? "отстегивается от" : "пристегивается к"] стулу(а).")
			if(transportid != -1)
				if(!M2.buckled)
					M2.transportid = transportid
				else
					M2.transportid = -1
			M2.buckled = !M2.buckled
			M2.dir = dir

/obj/structure/chair/venicle
	icon = 'venicles.dmi'
	icon_state = "cargoboy"
	name = "cargoboy"
	ru_name = "погрузчик"
	layer = 10
	var/atom/movable/SLOT
