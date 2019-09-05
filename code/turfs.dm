/atom/proc/relative_wall()
	if(istype(src,/turf/wall/) && !src:wall_type) return

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/wall/W in orange(src,1))
		//if(istype(src,/turf/wall/) && src:wall_type != W.wall_type) continue
		if(abs(src.x-W.x)-abs(src.y-W.y)) junction |= get_dir(src,W) //doesn't count diagonal walls

	if(istype(src,/turf/wall/))
		var/turf/wall/W = src
		W.icon_state = "[W.wall_type][junction]"
	return

/atom/proc/relative_wall_neighbours()
	for(var/turf/wall/W in range(src,1)) W.relative_wall()
	return

/atom
	var/wall_type

/turf
	icon='icons/turfs.dmi'
	var/atom/movable/CRATE
	var/crated = 0

	space
		layer = 1
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
			if(z >= 1 && z < world.maxz)
				var/turf/T = locate(x,y,z+1)
				if(istype(T, /turf/space))
					T = new /turf/space/hull(locate(x,y,z+1))
			..()

		plating
			icon_state = "plating"
			layer = 1

	wall
		icon_state = "wall"
		density = 1
		opacity = 1
		ru_name = "стена"
		wall_type = "wall"
		construct_parts = list(/obj/item/stack/metal)
		easy_deconstruct = 1

		New()
			..()
			if(z >= 1 && z < world.maxz)
				var/turf/T = locate(x,y,z+1)
				if(istype(T, /turf/space))
					T = new /turf/space/hull(locate(x,y,z+1))
			relative_wall_neighbours()

		Del()
			..()
			if(z - 1 >= 1)
				src = new /turf/floor/openspess(locate(x,y,z))
			relative_wall_neighbours()

		attackby(var/mob/M, var/obj/item/I)
			if(!istype(src, /turf/wall/window))
				if(istype(I, /obj/item/staple))
					M:drop()
					del(I)
					call_message(5, "к [ru_name] крепится скоба")
					new /obj/structure/staple(src)
				if(istype(I, /obj/item/tools/welder))
					call_message(5, "[ru_name] разваривается")
					new /obj/structure/lattice( locate(src.x, src.y, src.z) )
					new /obj/frame/wall(locate(src.x, src.y, src.z))
					new /obj/item/stack/metal(locate(src.x, src.y, src.z))
					new /turf/floor/plating(locate(src.x, src.y, src.z))


		window
			opacity = 0
			icon_state = "window"
			wall_type = "window"

	space
		icon_state = "space"