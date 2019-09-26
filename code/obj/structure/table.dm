/obj/structure/table
	name = "table"
	icon = 'table.dmi'
	icon_state = "0"
	anchored = 1
	density = 1
	var/auto_type = /obj/structure/table

	New()
		..()
		spawn(10)
			if (ispath(src.auto_type) && src.icon_state == "0") // if someone's set up a special icon state don't mess with it
				src.set_up()
				spawn(1)
					for (var/obj/structure/table/T in orange(1))
						T.set_up()

		var/bonus = 0
		for (var/obj/O in loc)
			if (istype(O, /obj/item))
				bonus += 4
			if (istype(O, /obj/structure/table) && O != src)
				return

	proc/set_up()
		if (!ispath(src.auto_type))
			return
		var/dirs = 0
		for (var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			if (locate(src.auto_type) in T)
				dirs |= direction
		icon_state = num2text(dirs)

		//christ this is ugly
		var/obj/structure/table/SWT = locate(src.auto_type) in get_step(src, SOUTHWEST)
		if (SWT)
			var/obj/structure/table/ST = locate(src.auto_type) in get_step(src, SOUTH)
			var/obj/structure/table/WT = locate(src.auto_type) in get_step(src, WEST)
			if (ST && WT)
				src.overlays += "SW"

		var/obj/structure/table/SET = locate(src.auto_type) in get_step(src, SOUTHEAST)
		if (SET)
			var/obj/structure/table/ST = locate(src.auto_type) in get_step(src, SOUTH)
			var/obj/structure/table/ET = locate(src.auto_type) in get_step(src, EAST)
			if (ST && ET)
				src.overlays += "SE"

		var/obj/structure/table/NWT = locate(src.auto_type) in get_step(src, NORTHWEST)
		if (NWT)
			var/obj/structure/table/NT = locate(src.auto_type) in get_step(src, NORTH)
			var/obj/structure/table/WT = locate(src.auto_type) in get_step(src, WEST)
			if (NT && WT)
				src.overlays += "NW"

		var/obj/structure/table/NET = locate(src.auto_type) in get_step(src, NORTHEAST)
		if (NET)
			var/obj/structure/table/NT = locate(src.auto_type) in get_step(src, NORTH)
			var/obj/structure/table/ET = locate(src.auto_type) in get_step(src, EAST)
			if (NT && ET)
				src.overlays += "NE"

	attackby(var/obj/item/W, var/mob/simulated/living/humanoid/user)
		if(!istype(W, /obj/item/tools/wrench))
			usr:drop()
			W.Move(src.loc)
		else
			call_message(3, "[usr] разбирает [ru_name ? ru_name : name]")
			new /obj/item/stack/metal(src.loc)
			del(src)