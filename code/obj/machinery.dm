#define SPACE 1
#define INNER 2

/obj/machinery
	var/on = 0
	layer = 3

/obj/machinery/airlock_initiator
	icon = 'icons/airlock.dmi'
	icon_state = "initiator"
	var/freq = 10
	var/outer = INNER

	attack_hand()
		for(var/obj/machinery/airlock_space_controller/C in controlled)
			if(C.freq == freq)
				C.on = !C.on
				C.outer = outer

/obj/machinery/airlock_space_controller
	var/freq = 10
	icon = 'icons/airlock.dmi'
	icon_state = "atmos_controller"
	on = 0
	var/outer = INNER
	anchored = 1

	New()
		..()
		tocontrol()

	process()
		if(on)
			if(outer == INNER)
				for(var/obj/machinery/airlock/space_shutter/SP in world)
					if(SP.outer == SPACE && SP.freq == freq)
						if(!SP.open)
							SP.open()

				if(src.loc:pressure < 500)
					for(var/obj/machinery/atmospherics/outer/O in controlled)
						if(O.freq == freq && !O.on)
							O.on = 1
					for(var/turf/floor/F in range(2, src))
						F.temperature = 20
				else
					for(var/obj/machinery/airlock/space_shutter/SP in world)
						if(SP.outer == INNER && SP.freq == freq)
							if(SP.open)
								SP.open()
							call_message(3, "Дверь на корабль открыта")
							on = 0
					for(var/obj/machinery/atmospherics/outer/O in controlled)
						if(O.freq == freq && O.on)
							O.on = 0

			if(outer == SPACE)
				for(var/obj/machinery/airlock/space_shutter/SP in world)
					if(SP.outer == INNER && SP.freq == freq)
						if(!SP.open)
							SP.open()

				if(src.loc:pressure > 50)
					for(var/obj/machinery/atmospherics/inner/O in controlled)
						if(O.freq == freq && !O.on)
							O.on = 1
				else
					for(var/obj/machinery/airlock/space_shutter/SP in world)
						if(SP.outer == SPACE && SP.freq == freq)
							if(SP.open)
								SP.open()
							call_message(3, "Дверь в безвоздушное пространство открыта")
							on = 0
					for(var/obj/machinery/atmospherics/inner/O in controlled)
						if(O.freq == freq && O.on)
							O.on = 0


/obj/machinery/airlock
	icon = 'icons/airlock.dmi'
	icon_state = "door_1"
	ru_name = "Дверная установка"
	density = 1
	opacity = 1
	block_air = 1
	anchored = 1
	var/door_state = "door"
	var/open = 1
	need_voltage = 25
	need_amperage = 3
	max_VLTAMP = 500
	construct_parts = list(/obj/item/stack/metal)
	easy_deconstruct = 1

	firedoor
		icon_state = "firedoor_0"
		door_state = "firedoor"
		density = 0
		opacity = 0
		block_air = 0
		open = 0

		attack_hand()
			call_message(3, "Активируется защитная гермодверь.")
			open()

		New()
			..()
			tocontrol()

		process()
			if(use_power() && !istype(src.loc, /turf/wall))
				if(src.loc:oxygen < 30 || src.loc:plasma > 20 || src.loc:water > 5 || src.loc:temperature > 70 || src.loc:temperature < 15)
					if(!open)
						open()
				else
					if(open)
						open()

	space_shutter
		icon_state = "shutter_1"
		door_state = "shutter"
		var/freq = 10
		var/outer = SPACE

		inner
			outer = INNER

		attack_hand()
			call_message(3, "Эта дверь открывается удаленно. В доступе отказано.")

	proc/open()
		open = !open
		density = open
		opacity = open
		block_air = open
		icon_state = "[door_state]_[open]"
		loc:process()
		var/i = 0
		var/g = rand(10,20)
		while(i < g)
			i++
			for(var/turf/floor/CARD in check_in_cardinal(1))
				CARD.process()

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)

	attack_hand()
		if(use_power())
			call_message(3, "Дверь [open == 1 ? "открылась" : "закрылась"]")
			open()
		else
			call_message(3, "Дверь обесточена")

/obj/machinery/shieldair
	icon = 'airlock.dmi'
	icon_state = "shieldair"
	anchored = 1
	need_voltage = 45
	need_amperage = 3
	max_VLTAMP = 500000


/obj/machinery/airlock/shielddoor
	icon_state = "shielddoor_1"
	door_state = "shielddoor"
	mouse_opacity = 0
	density = 0
	opacity = 0

	New()
		..()
		tocontrol()

	process()
		for(var/obj/machinery/shieldair/SHAIR in src.loc)
			if(SHAIR.use_power())
				if(!open)
					open()
			else
				if(open)
					open()

	open()
		open = !open
		block_air = open
		icon_state = "[door_state]_[open]"
		loc:process()
		var/i = 0
		var/g = rand(10,20)
		while(i < g)
			i++
			for(var/turf/floor/CARD in check_in_cardinal(1))
				CARD.process()

/obj/machinery/power_block
	icon = 'computer.dmi'
	icon_state = "power_block"
	ru_name = "блок питания"
	var/ivoltage = 45
	var/iamperage = 3
	var/out_voltage = 0
	var/out_amperage = 0
	max_VLTAMP = 500000

	anchored = 1
	layer = 2

	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/metal)
	easy_deconstruct = 1

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(use_power())
			var/list/descr = list()
			var/list/hrefs = list()
			var/obj/electro/cable/CABEL
			for(var/obj/electro/cable/C in src.loc)
				powernet = C.powernet
				CABEL = C
			descr.Add(fix1103("Напряжение в сети [CABEL.voltage]"))
			descr.Add("Сила тока в сети [CABEL.amperage]")
			descr.Add(fix1103("Задать выходное напряжение [ivoltage]"))
			descr.Add("Задать выходную силу тока [iamperage]")

			hrefs.Add("null=null")
			hrefs.Add("null=null")
			hrefs.Add("voltage=ok")
			hrefs.Add("amperage=ok")

			M << browse(nterface(descr, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["voltage"]=="ok")
			ivoltage = input(usr, "Напряжение (выходное).","ваше значение",ivoltage) as num
			attack_hand(usr)
		if(href_list["amperage"]=="ok")
			iamperage = input(usr, "Сила тока (выходная).","ваше значение",iamperage) as num
			attack_hand(usr)

	New()
		..()
		tocontrol()

	process()
		for(var/obj/electro/cable/C in src.loc)
			powernet = C.powernet
			if(C.voltage > ivoltage)
				out_voltage = ivoltage
			else
				out_voltage = 0

			if(C.amperage > iamperage)
				out_amperage = iamperage
			else
				out_amperage = 0

/obj/gravity
	icon = 'computer.dmi'
	icon_state = "gravity"
	mouse_opacity = 0
	reality = 0
	alpha = 128

/obj/machinery/gravity_shield
	icon = 'computer.dmi'
	icon_state = "gravity_shield"
	ru_name = "гравитационная ловушка"
	on = 1
	var/powerrange = 2
	need_voltage = 30
	need_amperage = 2
	max_VLTAMP = 1000000
	var/list/iterationgravity = list()

	anchored = 1
	layer = 2

	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/metal)
	easy_deconstruct = 1

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)

	New()
		..()
		tocontrol()

	process()
		for(var/obj/electro/cable/C in src.loc)
			powernet = C.powernet
		for(var/atom/A in iterationgravity)
			iterationgravity.Remove(A)
			del(A)
		if(on)
			need_amperage = 2
			need_voltage = powerrange * 7
			if(use_power())
				for(var/turf/T in range(powerrange, src))
					var/obj/gravity/G = new /obj/gravity(T)
					iterationgravity.Add(G)

/obj/machinery/sparkgenerator
	icon = 'pipes.dmi'
	icon_state = "sparkgenerator"
	ru_name = "генератор искр"
	anchored = 1

	New()
		..()
		tocontrol()

	process()
		for(var/obj/electro/cable/C in src.loc)
			powernet = C.powernet

	proc/generate_spark()
		call_message(5, "[ru_name] генерирует искры")
		new /obj/effect/sparks(src.loc)

/obj/machinery/sparkbutton
	icon = 'pipes.dmi'
	icon_state = "sparkbutton"
	ru_name = "активатор искр"
	anchored = 1

	proc/generate_spark()
		for(var/obj/electro/cable/C in src.loc)
			powernet = C.powernet
			if(powernet != 0)
				for(var/obj/machinery/sparkgenerator/SG in world)
					if(SG.powernet == powernet)
						SG.generate_spark()

	attack_hand(var/mob/M)
		generate_spark()