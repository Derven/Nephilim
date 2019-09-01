/atom/movable
	var/transportid = -1

	proc/rotate_(cx, cy)
		spawn(2)
			dir = turn(dir, 90)
			loc = locate(cx + (x - cx) * cos(90) - (y - cy) * sin(90), cy + (y - cy) * cos(90) + (x - cx) * sin(90), z)

	proc/MOVETO(var/cdir)
		if(cdir == NORTH)
			loc = locate(x, y + 1, z)

		if(cdir == SOUTH)
			loc = locate(x, y - 1, z)

		if(cdir == WEST)
			loc = locate(x - 1, y, z)

		if(cdir == EAST)
			loc = locate(x + 1, y, z)

proc/rotate_my_car(var/id)
	var/center_x
	var/center_y

	for(var/dz/DZ in world)
		if(DZ.id == id && DZ.center == 1)
			center_x = DZ.x
			center_y = DZ.y

	for(var/dz/DZ in world)
		if(DZ.id == id)
			DZ.rotate_me(center_x, center_y)

proc/SHUTTLEMOVE(var/id, var/cdir)
	for(var/dz/DZ in world)
		if(DZ.id == id)
			DZ.drive(cdir)

/dz
	parent_type = /obj //zone for moving multitile transport
	icon = 'turfs.dmi'
	icon_state = "shuttle"
	ru_name = "каркас транспорта"
	anchored = 1
	dir = WEST
	var
		id = 0 //id of transport
		center = 0
		list/obj/partslist = list()
	layer = 1

	Del()
		for(var/atom/movable/M in src.loc)
			M.anchored = 0
			M.dir = pick(NORTH, SOUTH, WEST, EAST)
			collision(M, rand(10,20))
			M.Move(get_step(src.loc, M.dir))
		for(var/turf/wall/W in src.loc)
			W.collision(src, rand(10,20))
		..()

	proc/rotate_me(cx, cy)
		var/turf/oldloc = src.loc
		rotate_(cx, cy)
		for(var/atom/movable/M in oldloc)
			if(!istype(M, /dz) && M.transportid == id)
				M.rotate_(cx, cy)
		for(var/atom/movable/M in src.loc)
			if((!istype(M, /dz) && M.transportid != id) && M.density == 1)
				call_message(5, "[src.ru_name] сталкивается с [M.ru_name]")
				if(M.hardness >= hardness)
					del(src)
				else
					M.dir = pick(NORTH, SOUTH, WEST, EAST)
					M.anchored = 0
					collision(M, rand(10,20))
					M.Move(get_step(src.loc, M.dir))

		if(istype(src.loc, /turf/wall))
			call_message(5, "[src.ru_name] сталкивается с чем-то твердым")
			del(src)

	proc/drive(var/cdir)
		for(var/atom/movable/M in src.loc)
			if(!istype(M, /dz) && M.transportid == id)
				M.MOVETO(cdir)
		MOVETO(cdir)
		for(var/atom/movable/M in src.loc)
			if((!istype(M, /dz) && M.transportid != id) && M.density == 1)
				call_message(5, "[src.ru_name] сталкивается с [M.ru_name]")
				if(M.hardness >= hardness)
					del(src)
				else
					M.dir = pick(NORTH, SOUTH, WEST, EAST)
					M.anchored = 0
					collision(M, rand(10,20))
					M.Move(get_step(src.loc, M.dir))

		if(istype(src.loc, /turf/wall))
			call_message(5, "[src.ru_name] сталкивается с чем-то твердым")
			del(src)

	verb/rotate_car()
		set src in usr.loc
		rotate_my_car(id)

	verb/driver()
		set src in usr.loc
		SHUTTLEMOVE(id, dir)