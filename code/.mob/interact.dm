/atom/proc/attack_hand(var/mob, var/msg)
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
	attack_hand(usr)

/atom/proc/call_message(var/myrange, var/msg)
	for(var/mob/HEAR in range(myrange, src))
		HEAR << msg