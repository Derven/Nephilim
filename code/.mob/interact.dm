/atom/proc/attack_hand(var/mob, var/msg)
	return 0

/atom/proc/attackby(var/mob/M, var/item/I)
	return 0

/atom/proc/attackinhand(var/mob/M)
	return 0

/atom/proc/afterattack(var/mob/M, var/item/I)
	return 0

/atom/proc/justattack(var/mob/M, var/atom/A)
	return 0

/atom/var/block_air = 0

/atom/proc/check_in_cardinal_Z(var/atmos_block)

	if(atmos_block == 1)
		for(var/atom/movable/MOVABLE in src)
			if(MOVABLE.block_air == 1)
				return null
	var/atom/list/cardinal = list()
	cardinal.Add(get_step(src,NORTH))
	cardinal.Add(get_step(src,SOUTH))
	cardinal.Add(get_step(src,WEST))
	cardinal.Add(get_step(src,EAST))
	cardinal.Add(get_step(src,SOUTHWEST))
	cardinal.Add(get_step(src,NORTHWEST))
	cardinal.Add(get_step(src,NORTHEAST))
	cardinal.Add(get_step(src,SOUTHEAST))

	if(z < world.maxz)
		var/turf/z2 = locate(x, y, z+1)
		if(istype(2, /turf/floor/openspess))
			cardinal.Add(get_step(z2,NORTH))
			cardinal.Add(get_step(z2,SOUTH))
			cardinal.Add(get_step(z2,WEST))
			cardinal.Add(get_step(z2,EAST))
			cardinal.Add(get_step(z2,SOUTHWEST))
			cardinal.Add(get_step(z2,NORTHWEST))
			cardinal.Add(get_step(z2,NORTHEAST))
			cardinal.Add(get_step(z2,SOUTHEAST))

	if(z > 1)
		var/turf/z2 = locate(x, y, z-1)
		cardinal.Add(get_step(z2,NORTH))
		cardinal.Add(get_step(z2,SOUTH))
		cardinal.Add(get_step(z2,WEST))
		cardinal.Add(get_step(z2,EAST))
		cardinal.Add(get_step(z2,SOUTHWEST))
		cardinal.Add(get_step(z2,NORTHWEST))
		cardinal.Add(get_step(z2,NORTHEAST))
		cardinal.Add(get_step(z2,SOUTHEAST))

	if(atmos_block == 1)
		for(var/turf/floor/MYFLOOR in cardinal)
			for(var/atom/movable/MOVABLE in MYFLOOR)
				if(MOVABLE.block_air == 1)
					cardinal.Remove(MYFLOOR)

	return cardinal

/atom/proc/check_in_cardinal(var/atmos_block)


	if(atmos_block == 1)
		for(var/atom/movable/MOVABLE in src)
			if(MOVABLE.block_air == 1)
				return null
	var/atom/list/cardinal = list()

	if(z < world.maxz)
		var/turf/z2 = locate(x, y, z+1)
		if(istype(z2, /turf/floor/openspess))
			cardinal.Add(get_step(z2,NORTH))
			cardinal.Add(get_step(z2,SOUTH))
			cardinal.Add(get_step(z2,WEST))
			cardinal.Add(get_step(z2,EAST))
			cardinal.Add(get_step(z2,SOUTHWEST))
			cardinal.Add(get_step(z2,NORTHWEST))
			cardinal.Add(get_step(z2,NORTHEAST))
			cardinal.Add(get_step(z2,SOUTHEAST))

	cardinal.Add(get_step(src,NORTH))
	cardinal.Add(get_step(src,SOUTH))
	cardinal.Add(get_step(src,WEST))
	cardinal.Add(get_step(src,EAST))
	cardinal.Add(get_step(src,SOUTHWEST))
	cardinal.Add(get_step(src,NORTHWEST))
	cardinal.Add(get_step(src,NORTHEAST))
	cardinal.Add(get_step(src,SOUTHEAST))

	if(atmos_block == 1)
		for(var/turf/floor/MYFLOOR in cardinal)
			for(var/atom/movable/MOVABLE in MYFLOOR)
				if(MOVABLE.block_air == 1)
					cardinal.Remove(MYFLOOR)

	return cardinal

/atom/proc/check_in_minicardinal()
	var/atom/list/cardinal = list()
	cardinal.Add(get_step(src,NORTH))
	cardinal.Add(get_step(src,SOUTH))
	cardinal.Add(get_step(src,WEST))
	cardinal.Add(get_step(src,EAST))
	return cardinal

/atom/proc/mousedrop(var/atom/movable/A, var/atom/target)
	return 0

/atom/Click()
	if(istype(usr, /mob/living))
		if(get_dist(src, usr) <= 1 || istype(src, /obj/hud) || istype(src.loc, /obj/item/clothing/backpack) || istype(src.loc, /obj/item/clothing/uniform))
			if(usr:get_slot("lhand") || usr:get_slot("rhand"))
				if(usr:get_slot("lhand"))
					if(usr:get_slot("lhand"):active)
						if(usr:get_slot("lhand"):SLOT != null)
							afterattack(usr, usr:get_slot("lhand"):SLOT)
							usr:get_slot("lhand"):SLOT:justattack(usr, src)
							attackby(usr, usr:get_slot("lhand"):SLOT)
							return

				if(usr:get_slot("rhand"))
					if(usr:get_slot("rhand"):active)
						if(usr:get_slot("rhand"):SLOT != null)
							afterattack(usr, usr:get_slot("rhand"):SLOT)
							usr:get_slot("rhand"):SLOT:justattack(usr, src)
							attackby(usr, usr:get_slot("rhand"):SLOT)
							return
			if(usr.MACHINE)
				if(!usr.MACHINE.SLOT)
					if(istype(src, /atom/movable))
						if(!src:anchored && src != usr.MACHINE)
							usr.MACHINE.SLOT = src
							usr.MACHINE.overlays += src
							src:Move(usr.MACHINE)
						else
							attack_hand(usr)
					else
						attack_hand(usr)
				else
					attack_hand(usr)
			else
				attack_hand(usr)
		else
			if(usr:throwmode)
				usr:throwmode = !usr:throwmode
				usr:drop(turn(get_dir(src,usr), 180), rand(3,4))
				usr:get_slot("throw"):color = null
				if(usr:get_slot("rhand"))
					if(usr:get_slot("rhand"):active)
						usr:get_slot("rhand").overlays.Cut()
				if(usr:get_slot("lhand"))
					if(usr:get_slot("lhand"):active)
						usr:get_slot("lhand").overlays.Cut()
				return

		if(get_dist(src, usr) > 1 && get_dist(src, usr) < 127)

			if(usr:get_slot("rhand"))
				if(usr:get_slot("rhand"):active)
					if(istype(usr:get_slot("rhand"):SLOT, /obj/item/tools/tankgun))
						var/obj/item/tools/tankgun/tankgun = usr:get_slot("rhand"):SLOT
						if(tankgun.bullet)
							tankgun.bullet.target = src
							tankgun.pew()
					if(istype(usr:get_slot("rhand"):SLOT, /obj/item/tools/tasergun))
						var/obj/item/tools/tasergun/tasergun = usr:get_slot("rhand"):SLOT
						tasergun.target = src
						tasergun.pew()

			if(usr:get_slot("lhand"))
				if(usr:get_slot("lhand"):active)
					if(istype(usr:get_slot("lhand"):SLOT, /obj/item/tools/tankgun))
						var/obj/item/tools/tankgun/tankgun = usr:get_slot("rhand"):SLOT
						if(tankgun.bullet)
							tankgun.bullet.target = src
							tankgun.pew()
					if(istype(usr:get_slot("rhand"):SLOT, /obj/item/tools/tasergun))
						var/obj/item/tools/tasergun/tasergun = usr:get_slot("rhand"):SLOT
						tasergun.target = src
						tasergun.pew()

	if(usr:get_slot("lhand", usr))
		usr:get_slot("lhand", usr):refresh_slot()
	if(usr:get_slot("rhand", usr))
		usr:get_slot("rhand", usr):refresh_slot()

/atom/MouseDrop(atom/over_object as mob|obj|turf|area)
	if(get_dist(src, over_object) < 2)
		spawn( 0 )
			if (istype(over_object, /atom))
				over_object.mousedrop(src, usr)
			return
		..()
		return

/atom/proc/call_message(var/myrange, var/msg)
	for(var/mob/HEAR in range(myrange, src))
		if(HEAR.myears)
			HEAR << fix255(msg)
		else
			HEAR << "*шум*"

/mob/proc/message_to_usr(var/msg)
	usr << fix255(msg)

/mob/living/human/proc/pickup(var/obj/item/I)
	if(get_slot("lhand") || get_slot("rhand"))
		if(get_slot("lhand"))
			if(get_slot("lhand"):active)
				get_slot("lhand"):SLOT = I
				get_slot("lhand"):put_to_slot()
		if(get_slot("rhand"))
			if(get_slot("rhand"):active)
				get_slot("rhand"):SLOT = I
				get_slot("rhand"):put_to_slot()