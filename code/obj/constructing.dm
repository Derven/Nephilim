/atom
	var/easy_deconstruct = 0
	var/list/atom/construct_parts = list()

	proc/easy_deconstruct(var/mob/M)
		if(easy_deconstruct)
			nocontrol()
			sleep(5)
			for(var/A in construct_parts)
				new A(src.loc)
			for(var/atom/movable/B in src)
				B.loc = src.loc
			call_message(3, "[M] разбирает [src.ru_name]")
			del(src)

/obj/frame
	icon = 'constructing.dmi'
	density = 1
	var/frame_type = /obj/machinery
	var/stage = 0

	proc/action_1()
		return 0
	proc/action_2()
		return 0
	proc/action_3()
		return 0

	proc/firststage()
		if(action_1())
			if(stage == 0)
				stage = 1

	proc/secondstage()
		if(action_2())
			if(stage == 1)
				stage = 2

	proc/completestage()
		if(action_3())
			if(stage == 2)
				stage = 3
				var/atom/A
				if(!ispath(frame_type,/turf))
					A = new frame_type(src.loc)
				else
					A = new frame_type( locate(src.x, src.y, src.z) )
				call_message(3, "[src.ru_name] превращаетс€ в [A.ru_name]")
				del(src)

	proc/check_stages()
		firststage()
		secondstage()
		completestage()

/obj/frame/wall
	icon_state = "wall_frame"
	ru_name = "рама стены"
	frame_type = /turf/wall
	var/bolts = 0
	var/tofloor = 0
	var/weld = 0

	action_1()
		if(bolts)
			call_message(3, "болты [src.ru_name] зат€нуты")
			return 1
		else
			return 0

		return 0
	action_2()
		if(tofloor)
			call_message(3, "[src.ru_name] прикручен к полу")
			return 1
		else
			return 0

	action_3()
		if(weld)
			call_message(3, "[src.ru_name] приварен")
			return 1
		else
			return 0

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			bolts = !bolts
			check_stages()
			return
		if(istype(I, /obj/item/tools/screwdriver))
			tofloor = !tofloor
			check_stages()
			return
		if(istype(I, /obj/item/tools/welder))
			weld = !weld
			check_stages()
			return

/obj/frame/computer
	icon_state = "computer_frame"
	ru_name = "корпус компьютера"
	frame_type = /obj/machinery/computer
	var/bolts = 0
	var/wired = 0
	var/glassed = 0

	action_1()
		if(bolts)
			call_message(3, "болты [src.ru_name] зат€нуты")
			return 1
		else
			return 0

		return 0
	action_2()
		if(wired)
			call_message(3, "внутри [src.ru_name] прот€нуты провода")
			return 1
		else
			return 0

	action_3()
		if(glassed)
			call_message(3, "к [src.ru_name] подключен дисплей")
			return 1
		else
			return 0

	completestage()
		if(action_3())
			if(stage == 2)
				stage = 3
				var/atom/A
				if(!ispath(frame_type,/turf))
					A = new frame_type(src.loc)
				else
					A = new frame_type( locate(src.x, src.y, src.z) )
				call_message(3, "[src.ru_name] превращаетс€ в [A.ru_name]")
				A:MAINBOARD = null
				del(src)

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/screwdriver))
			bolts = !bolts
			check_stages()
			return
		if(istype(I, /obj/item/unconnected_cable))
			if(wired == 0)
				wired = 1
				usr:drop()
				I.loc = src
			else
				call_message(3, "внутри [src.ru_name] уже прот€нуты провода")
			check_stages()
			return
		if(istype(I, /obj/item/stack/glass))
			if(glassed == 0)
				glassed = 1
				usr:drop()
				I.loc = src
			else
				call_message(3, "к [src.ru_name] уже подключен дисплей")
			check_stages()

/obj/frame/powerblock
	icon_state = "powerblock_frame"
	ru_name = "корпус блока питани€"
	frame_type = /obj/machinery/power_block
	var/bolts = 0
	var/wired = 0
	var/tofloor = 0

	action_1()
		if(bolts)
			call_message(3, "болты [src.ru_name] зат€нуты")
			return 1
		else
			return 0

		return 0
	action_2()
		if(wired)
			call_message(3, "внутри [src.ru_name] прот€нуты провода")
			return 1
		else
			return 0

	action_3()
		if(tofloor)
			call_message(3, "[src.ru_name] прикручен к полу")
			return 1
		else
			return 0

	completestage()
		if(action_3())
			if(stage == 2)
				stage = 3
				var/atom/A
				if(!ispath(frame_type,/turf))
					A = new frame_type(src.loc)
				else
					A = new frame_type( locate(src.x, src.y, src.z) )
				call_message(3, "[src.ru_name] превращаетс€ в [A.ru_name]")
				del(src)

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/screwdriver))
			bolts = !bolts
			check_stages()
			return
		if(istype(I, /obj/item/unconnected_cable))
			if(wired == 0)
				wired = 1
				usr:drop()
				I.loc = src
			else
				call_message(3, "внутри [src.ru_name] уже прот€нуты провода")
			check_stages()
			return
		if(istype(I, /obj/item/tools/wrench))
			if(tofloor == 0)
				tofloor = 1
			else
				call_message(3, "[src.ru_name] уже прикручен к полу")
			check_stages()

/obj/frame/gravityshield
	icon_state = "gravity_frame"
	ru_name = "корпус гравитационной ловушки"
	frame_type = /obj/machinery/gravity_shield
	var/bolts = 0
	var/wired = 0
	var/tofloor = 0

	action_1()
		if(bolts)
			call_message(3, "болты [src.ru_name] зат€нуты")
			return 1
		else
			return 0

		return 0
	action_2()
		if(wired)
			call_message(3, "внутри [src.ru_name] прот€нуты провода")
			return 1
		else
			return 0

	action_3()
		if(tofloor)
			call_message(3, "[src.ru_name] прикручен к полу")
			return 1
		else
			return 0

	completestage()
		if(action_3())
			if(stage == 2)
				stage = 3
				var/atom/A
				if(!ispath(frame_type,/turf))
					A = new frame_type(src.loc)
				else
					A = new frame_type( locate(src.x, src.y, src.z) )
				call_message(3, "[src.ru_name] превращаетс€ в [A.ru_name]")
				del(src)

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/screwdriver))
			bolts = !bolts
			check_stages()
			return
		if(istype(I, /obj/item/unconnected_cable))
			if(wired == 0)
				wired = 1
				usr:drop()
				I.loc = src
			else
				call_message(3, "внутри [src.ru_name] уже прот€нуты провода")
			check_stages()
			return
		if(istype(I, /obj/item/tools/wrench))
			if(tofloor == 0)
				tofloor = 1
			else
				call_message(3, "[src.ru_name] уже прикручен к полу")
			check_stages()