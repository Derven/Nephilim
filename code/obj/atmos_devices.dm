/datum/atmos_net
	var/list/canisters = list() //список канистр

var/global/datum/atmos_net/a_net = new() //атмососеть

/obj/machinery/atmospherics //родительский объект для всего, что кайнд оф атмос
	var/oxygen = 0
	var/nitrogen = 0
	var/plasma = 0
	var/list/datum/reagents/chemical = list()
	icon = 'pipes.dmi'
	density = 1

	Del()
		for(var/atom/movable/A in src)
			A.loc = src.loc
		..()

/obj/machinery/portable_atmospherics
	var/oxygen = 0
	var/nitrogen = 0
	var/plasma = 0
	var/list/datum/reagents/chemical = list()
	icon = 'pipes.dmi'
	density = 1

	var/atmosnet = 0 //трубосети, нужны, чтобы создавать независимые друг от друга атмосокоммуникации
	var/reset
	var/zLevel = 0

/obj/machinery/lighter
	density = 0
	icon_state = "lighter"


/obj/machinery/portable_atmospherics/canister
	var/open = 0
	var/connected = 0
	var/id // Плохое дервенорешение
	var/list/chemistry = list("blood")

/obj/machinery/portable_atmospherics/canister/oxygen
	oxygen = 500
	nitrogen = 0
	plasma = 0
	icon_state = "canister_o"

	high_volume
		oxygen = 50000

/obj/machinery/portable_atmospherics/canister/plasma
	oxygen = 0
	nitrogen = 0
	plasma = 500
	icon_state = "canister_p"

/obj/machinery/portable_atmospherics/canister/nitrogen
	oxygen = 0
	nitrogen = 500
	plasma = 0
	icon_state = "canister_n"

/obj/machinery/portable_atmospherics/canister/empty
	oxygen = 0
	nitrogen = 0
	plasma = 0
	icon_state = "canister_empty"

/obj/machinery/portable_atmospherics/canister/attack_hand()
	var/turf/T = src.loc
	world << "oxygen [oxygen]; plasma [plasma]; nitrogen [nitrogen]; atmosnet [atmosnet];"
	if(connected == 0 && open == 0)
		for(var/obj/machinery/atmospherics/connector/C in T)
			if(T)
				atmosnet = C.atmosnet
				connected = 1
				usr << "Ты подцепил канистру к коннектору"
				return

	if(connected == 1 && open == 1)
		for(var/obj/machinery/atmospherics/connector/C in T)
			if(T)
				atmosnet = C.atmosnet
				connected = 0
				usr << "Ты отцепил канистру от коннектора"
				return

	if(open == 0)
		open = 1
		usr << "Ты открыл канистру"
		return

	if(open == 1)
		open = 0
		usr << "Ты закрыл канистру"
		return

/obj/machinery/portable_atmospherics/canister/New()
	//id = rand(1,999)
	a_net.canisters += src //добавляем канистру в список канистр при создании
	tocontrol()
	process()
	..()

/obj/machinery/portable_atmospherics/canister/process()
	for(var/turf/floor/F in range(1, src))
		for(var/atom/movable/A in F)
			if(A.block_air == 0)
				if(open == 1)
					if(plasma > 0)
						F.plasma += 1
						plasma -= 1
					if(oxygen > 0)
						F.oxygen += 1
						oxygen -= 1

	for(var/obj/machinery/portable_atmospherics/canister/Z in a_net.canisters)
		if(Z.connected == 1 && Z.atmosnet == atmosnet) //если канистра подцеплена к какой-либо другой, то
			if(Z != src)
				//world << "Найдена канистра [Z.id]"
				if(oxygen > Z.oxygen)
					if(oxygen > 0)
						Z.oxygen += 1
						oxygen -= 1

				if(nitrogen > Z.nitrogen)
					if(nitrogen > 0)
						Z.nitrogen += 1
						nitrogen -= 1

				if(plasma > Z.plasma)
					if(plasma > 0)
						Z.plasma += 1
						plasma -= 1


				if(oxygen < Z.oxygen)
					if(Z.oxygen > 0)
						Z.oxygen -= 1
						oxygen += 1

				if(nitrogen < Z.nitrogen)
					if(Z.nitrogen > 0)
						Z.nitrogen -= 1
						nitrogen += 1

				if(plasma < Z.plasma)
					if(Z.plasma > 0)
						Z.plasma -= 1
						plasma += 1

					//for(var/datum/reagents/REG in chemical)
					//	move_one_unit(Z, REG)

/obj/machinery/atmospherics/connector/New()
	GASWAGEN_NET++
	atmosnet = GASWAGEN_NET
	true_initial = atmosnet
	process()
	tocontrol()


/obj/machinery/atmospherics/connector
	icon_state = "connector"
	anchored = 1
	on = 0
	var/true_initial = 0

	attack_hand(var/mob/M)
		M << atmosnet

/obj/machinery/atmospherics/connector/process()
	for(var/obj/machinery/atmospherics/pipe/P in range(1, src)) //коннектор ищет трубы в радиусе 1 тайла от себя
		if(P.atmosnet != 0)
			atmosnet = P.atmosnet

/obj/machinery/atmospherics/outer
	icon_state = "vent"
	anchored = 1
	ru_name = "вентиляция"
	density = 0
	layer = 3
	var/volume = 1
	var/freq = 30
	on = 0

	high_volume
		ru_name = "мощная вентиляция"
		volume = 5

	verb/eject()
		set src in range(1,usr)
		if(src == usr.loc)
			usr.loc = src.loc

	mousedrop(var/atom/movable/over_object, var/atom/movable/over_location)
		if(istype(over_object, /mob/living/human))
			call_message(5, "[over_object] заталкивается в [ru_name]")
			if(!over_object:rest)
				over_object:rest()
				over_object.loc = src
		if(istype(over_object, /obj/item))
			call_message(5, "[over_object] скидывается в [ru_name]")
			over_object.loc = src

/obj/machinery/atmospherics/outer/process()
	atmosnet = 0
	icon_state = "vent"
	if(on)
		for(var/obj/machinery/atmospherics/pipe/P in range(1, src))
			atmosnet = P.atmosnet
		for(var/obj/machinery/portable_atmospherics/canister/C in world)
			if(C.connected == 1 && C.atmosnet == atmosnet)
				if(C.oxygen + C.plasma > 30)
					for(var/obj/machinery/atmospherics/P in controlled)
						if(P.atmosnet == atmosnet)
							for(var/atom/movable/M in P)
								M.MoveToVent(src, C.oxygen + C.plasma)

				for(var/turf/floor/F in range(1, src))
					for(var/atom/movable/A in F)
						if(A.block_air == 0)
							if(C.oxygen > volume)
								icon_state = "vent_work"
								F.oxygen += volume
								C.oxygen -= volume

							if(C.plasma > 0)
								icon_state = "vent_work"
								F.plasma += volume
								C.plasma -= volume

/obj/machinery/atmospherics/outer/New()
	tocontrol()
	process()
	..()

/obj/machinery/atmospherics/outer/attack_hand()
	freq = input("Выбрать частоту устройства.","Ваша частота",freq)
	if(freq > 100)
		freq = 100
	if(freq < 0)
		freq = 0

/obj/machinery/atmospherics/inner
	icon_state = "in"
	density = 0
	layer = 2.3
	ru_name = "насос"
	anchored = 1
	var/volume = 1
	var/freq = 30
	on = 0

	high_volume
		ru_name = "мощный насос"
		volume = 5

/obj/machinery/atmospherics/inner/New()
	tocontrol()
	..()

/obj/machinery/atmospherics/inner/attack_hand()
	freq = input("Выбрать частоту устройства.","Ваша частота",freq)
	if(freq > 100)
		freq = 100
	if(freq < 0)
		freq = 0

/obj/machinery/atmospherics/inner/process()
	atmosnet = 0
	icon_state = "in"
	if(on)
		for(var/obj/machinery/atmospherics/pipe/P in range(1, src))
			atmosnet = P.atmosnet
		for(var/obj/machinery/portable_atmospherics/canister/C in controlled)
			if(C.connected == 1 && C.atmosnet == atmosnet)
				for(var/turf/floor/F in range(1, src))
					for(var/atom/movable/A in F)
						if(A.block_air == 0)
							if(F.oxygen >= volume)
								icon_state = "in_work"
								F.oxygen -= volume
								C.oxygen += volume

							if(F.plasma >= volume)
								icon_state = "in_work"
								F.plasma -= volume
								C.plasma += volume