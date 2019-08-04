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
			if(A.block_air == 1)
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
	process()
	tocontrol()


/obj/machinery/atmospherics/connector
	icon_state = "connector"
	anchored = 1
	on = 0

/obj/machinery/atmospherics/connector/process()
	for(var/obj/machinery/atmospherics/pipe/P in range(1, src)) //коннектор ищет трубы в радиусе 1 тайла от себя
		if(P.atmosnet != 0)
			atmosnet = P.atmosnet

/obj/machinery/atmospherics/outer
	icon_state = "vent"
	anchored = 1
	density = 0
	layer = 3

/obj/machinery/atmospherics/outer/process()
	atmosnet = 0
	icon_state = "vent"
	for(var/obj/machinery/atmospherics/pipe/P in range(1, src))
		atmosnet = P.atmosnet
	for(var/obj/machinery/portable_atmospherics/canister/C in world)
		if(C.connected == 1 && C.atmosnet == atmosnet)
			for(var/turf/floor/F in range(1, src))
				for(var/atom/movable/A in F)
					if(A.block_air == 0)
						if(C.oxygen > 0)
							icon_state = "vent_work"
							F.oxygen += 1
							C.oxygen -= 1

						if(C.plasma > 0)
							icon_state = "vent_work"
							F.plasma += 1
							C.plasma -= 1

/obj/machinery/atmospherics/outer/New()
	tocontrol()
	process()
	..()

/obj/machinery/atmospherics/outer/attack_hand()
	world << "[atmosnet]"

/obj/machinery/atmospherics/inner
	icon_state = "in"
	density = 0
	layer = 2.3

/obj/machinery/atmospherics/inner/New()
	process()


/obj/machinery/atmospherics/inner/process()
	atmosnet = 0
	icon_state = "in"
	for(var/obj/machinery/atmospherics/pipe/P in range(1, src))
		atmosnet = P.atmosnet
	for(var/obj/machinery/portable_atmospherics/canister/C in world)
		if(C.connected == 1 && C.atmosnet == atmosnet)
			for(var/turf/floor/F in range(1, src))
				for(var/atom/movable/A in F)
					if(A.block_air == 1)

						if(F.oxygen > 0)
							icon_state = "in_work"
							F.oxygen -= 1
							C.oxygen += 1

						if(F.plasma > 0)
							icon_state = "in_work"
							F.plasma -= 1
							C.plasma += 1