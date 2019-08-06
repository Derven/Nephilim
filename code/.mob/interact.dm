/atom/proc/attack_hand(var/mob, var/msg)
	return 0

/atom/proc/attackby(var/mob/M, var/item/I)
	return 0

/atom/var/block_air = 0

/atom/proc/check_in_cardinal(var/atmos_block)

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

/atom/Click()
	if(usr:get_slot("lhand") || usr:get_slot("rhand"))
		if(usr:get_slot("lhand"))
			if(usr:get_slot("lhand"):active)
				if(usr:get_slot("lhand"):SLOT != null)
					attackby(usr, usr:get_slot("lhand"):SLOT)
					return

		if(usr:get_slot("rhand"))
			if(usr:get_slot("rhand"):active)
				if(usr:get_slot("rhand"):SLOT != null)
					attackby(usr, usr:get_slot("rhand"):SLOT)
					return

	attack_hand(usr)

/atom/proc/call_message(var/myrange, var/msg)
	for(var/mob/HEAR in range(myrange, src))
		HEAR << fix255(msg)

/mob/proc/message_to_usr(var/msg)
	src << fix255(msg)

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