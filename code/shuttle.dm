var/area/SUPPLY_STATION_AREATYPE = "/area/nephilim_base" //Type of the supply shuttle area for station
var/area/SUPPLY_DOCK_AREATYPE = "/area/nephilim_out" //Type of the supply shuttle area for dock

/proc/get_area_turfs(var/areatype)
	//Takes: Area type as text string or as typepath OR an instance of the area.
	//Returns: A list of all turfs in areas of that type of that type in the world.
	//Notes: Simple!

	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

/area/proc/move_contents_to(var/area/A, var/turftoleave=null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					for(var/obj/O in T)
						if(!istype(O,/obj)) continue
						O.loc = X
					for(var/mob/M in T)
						if(!istype(M,/mob)) continue
						M.loc = X

					toupdate += X

					if(turftoleave)
						var/turf/ttl = new turftoleave(T)
						fromupdate += ttl

					refined_src -= T
					refined_trg -= B
					continue moving

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

var/supply_shuttle_moving = 0
var/supply_shuttle_at_station = 0

/proc/send_supply_shuttle()

	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE
	var/shuttleto = !supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/area/from = locate(text2path(shuttleat))
	var/area/dest = locate(text2path(shuttleto))

	if(!from || !dest) return

	from.move_contents_to(dest)
	supply_shuttle_at_station = !supply_shuttle_at_station