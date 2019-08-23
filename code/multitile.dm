/atom/movable
	var/transportid = -1

	proc/rotate_(cx, cy)
		dir = turn(dir, 90)
		loc = locate(cx + (x - cx) * cos(90) - (y - cy) * sin(90), cy + (y - cy) * cos(90) + (x - cx) * sin(90), z)

	proc/MOVETO(var/curdir)
		if(curdir == "north")
			loc = locate(x, y + 1, z)

		if(curdir == "south")
			loc = locate(x, y - 1, z)

		if(curdir == "west")
			loc = locate(x - 1, y, z)

		if(curdir == "east")
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

/dz
	parent_type = /obj //zone for moving multitile transport
	icon = 'turfs.dmi'
	icon_state = "shuttle"
	anchored = 1
	dir = EAST
	var
		id = 0 //id of transport
		center = 0
		curdir = "east" //west, south, east
		list/obj/partslist = list()
	layer = 1

	proc/rotate_me(cx, cy)
		for(var/atom/movable/M in src.loc)
			if(!istype(M, /dz) && M.transportid == id)
				M.rotate_(cx, cy)
		rotate_(cx, cy)

	verb/rotate_car()
		set src in usr.loc
		rotate_my_car(id)