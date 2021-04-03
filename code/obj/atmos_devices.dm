/datum/atmos_net
	var/list/canisters = list() //������ �������

var/global/datum/atmos_net/a_net = new() //����������

/obj/machinery/atmospherics //������������ ������ ��� �����, ��� ����� �� �����
	var/oxygen = 0
	var/nitrogen = 0
	var/plasma = 0
	var/water = 0
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
	var/water = 0
	var/temperature = 40

	var/list/datum/reagents/chemical = list()
	icon = 'pipes.dmi'
	density = 1

	var/atmosnet = 0 //���������, �����, ����� ��������� ����������� ���� �� ����� ������������������
	var/reset
	var/zLevel = 0

/obj/machinery/lighter
	density = 0
	icon_state = "lighter"


/obj/machinery/portable_atmospherics/canister
	var/open = 0
	var/connected = 0
	var/id // ������ ��������������
	var/reagent_name = null
	ru_name = "��������(������)"

	attackby(var/mob/M, var/obj/item/I)
		var/turf/T = src.loc
		if(istype(I, /obj/item/tools/wrench))
			if(connected == 0)
				for(var/obj/machinery/atmospherics/connector/C in T)
					if(T)
						atmosnet = C.atmosnet
						connected = 1
						usr << "�� �������� �������� � ����������"
						return

			if(connected == 1)
				for(var/obj/machinery/atmospherics/connector/C in T)
					if(T)
						atmosnet = C.atmosnet
						connected = 0
						usr << "�� ������� �������� �� ����������"
						return

/obj/machinery/portable_atmospherics/canister/oxygen
	//oxygen = 500
	//nitrogen = 0
	//plasma = 0
	reagent_name = "oxygen"
	icon_state = "canister_o"

	high_volume
		oxygen = 50000

/obj/machinery/portable_atmospherics/canister/secgas
	icon_state = "canister_p"
	reagent_name = "secgas"

/obj/machinery/portable_atmospherics/canister/plasma
	//oxygen = 0
	//nitrogen = 0
	//plasma = 500
	reagent_name = "plasma"
	icon_state = "canister_p"

	high_volume
		oxygen = 50000

/obj/machinery/portable_atmospherics/canister/phosphorus
	//oxygen = 0
	//nitrogen = 0
	//plasma = 500
	reagent_name = "phosphorus"
	icon_state = "canister_p"

	high_volume
		oxygen = 50000

/obj/machinery/portable_atmospherics/canister/water
	//oxygen = 0
	//nitrogen = 0
	//plasma = 0
	reagent_name = "water"
	water = 100000
	icon_state = "canister_bigwater"

/obj/machinery/portable_atmospherics/canister/nitrogen
	//oxygen = 0
	//nitrogen = 500
	//plasma = 0
	reagent_name = "nitrogen"
	icon_state = "canister_n"

/obj/machinery/portable_atmospherics/canister/empty
	//oxygen = 0
	//nitrogen = 0
	//plasma = 0
	icon_state = "canister_empty"

/obj/machinery/portable_atmospherics/canister/attack_hand()
	if(open == 0)
		open = 1
		usr << "�� ������ ��������"
		return

	if(open == 1)
		open = 0
		usr << "�� ������ ��������"
		return

/obj/machinery/portable_atmospherics/canister/New()
	//id = rand(1,999)
	a_net.canisters += src //��������� �������� � ������ ������� ��� ��������
	tocontrol()
	if(reagent_name != null)
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		R.add_reagent("[reagent_name]", 500)
	process()
	..()

/obj/machinery/portable_atmospherics/canister/process()
	for(var/turf/floor/F in range(1, src))
		for(var/atom/movable/A in F)
			if(A.block_air == 0)
				if(open == 1)
					/*
					if(plasma > 0)
						F.plasma += 1
						plasma -= 1

					if(oxygen > 0)
						F.oxygen += 1
						oxygen -= 1

					if(water > 0)
						F.water += 1
						water -= 1
					*/
					reagents.trans_to(F, 1, 1)

					if(temperature < F.temperature)
						temperature += F.temperature - temperature
						F.temperature -= abs(F.temperature - temperature) / 2

					if(F.temperature < temperature)
						F.temperature += temperature - F.temperature
						temperature -= abs(temperature - F.temperature) / 2

					if(temperature < -180)
						temperature = -180


	for(var/obj/machinery/portable_atmospherics/canister/Z in a_net.canisters)
		if(Z.connected == 1 && Z.atmosnet == atmosnet) //���� �������� ���������� � �����-���� ������, ��
			if(Z != src)
				//world << "������� �������� [Z.id]"
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

				if(water < Z.water)
					if(Z.water > 0)
						Z.water -= 1
						water += 1

				if(temperature < Z.temperature)
					temperature += Z.temperature - temperature
					Z.temperature -= abs(Z.temperature - temperature) / 2

				if(Z.temperature < temperature)
					Z.temperature += temperature - Z.temperature
					temperature -= abs(temperature - Z.temperature) / 2

				if(temperature < -180)
					temperature = -180

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
	density = 0
	on = 0
	var/true_initial = 0

	attack_hand(var/mob/M)
		M << atmosnet

/obj/machinery/atmospherics/connector/process()
	for(var/obj/machinery/atmospherics/pipe/P in range(1, src)) //��������� ���� ����� � ������� 1 ����� �� ����
		if(P.atmosnet != 0)
			atmosnet = P.atmosnet

/obj/machinery/atmospherics/outer
	icon_state = "vent"
	anchored = 1
	ru_name = "����������"
	density = 0
	layer = 3
	var/volume = 1
	var/freq = 30
	on = 0

	//oven and other flamethrower
	var/fire = 0

	kitchen_oven
		icon='oven.dmi'
		ru_name = "����������"
		density = 1
		anchored = 1

		verb/on_oven()
			set src in oview(1)
			on = !on
			if(on)
				call_message(5, "� [ru_name] ����������� �������")
			else
				call_message(5, "� [ru_name] ����������� �������")

		verb/fire_oven()
			set src in oview(1)
			fire = !fire
			if(fire)
				call_message(5, "� [ru_name] ������������ ���������")
			else
				call_message(5, "� [ru_name] �������������� ���������")

	newvent
		anchored = 0

	verb/rotate()
		set src in range(1, usr)
		if(!anchored)
			dir = turn(dir, 45)

	attackby(var/mob/M, var/obj/item/I)
		if(istype(src, /obj/machinery/atmospherics/outer/kitchen_oven))
			if(istype(I, /obj/item/weapon/reagent_containers/food))
				if(src.on == 1 && fire == 1)
					call_message(3, "[src.ru_name] �������� ���������")
					I:cooking()

		if(istype(I, /obj/item/tools/wrench))
			call_message(3, "[src.ru_name] [anchored ? "�������������" : "�������������"]")
			anchored = !anchored
			reset = 1
			if(!anchored)
				dir = turn(dir, 45)
			disconnect()
			process()
			sleep(25)
			refresh_connector()

	high_volume
		ru_name = "������ ����������"
		volume = 5

	verb/eject()
		set src in range(1,usr)
		if(src == usr.loc)
			usr.loc = src.loc

	mousedrop(var/atom/movable/over_object, var/atom/movable/over_location)
		if(!istype(src, /obj/machinery/atmospherics/outer/kitchen_oven))
			return
		if(istype(over_object, /mob/living/human))
			call_message(5, "[over_object] ������������� � [ru_name]")
			if(!over_object:rest)
				over_object:rest()
				over_object.loc = src
		if(istype(over_object, /obj/item))
			call_message(5, "[over_object] ����������� � [ru_name]")
			over_object.loc = src

/obj/machinery/atmospherics/outer/process()
	atmosnet = 0
	icon_state = "vent"

	if(fire == 1 && istype(src, /obj/machinery/atmospherics/outer/kitchen_oven)) //Wow kitchen
		icon_state = "vent_fire"
		for(var/turf/floor/F in range(1, src))
			F:initiate_burning = 1
	else
		for(var/turf/floor/F in range(1, src))
			F:initiate_burning = 0

	if(on)
		for(var/obj/machinery/atmospherics/pipe/P in range(1, src))
			atmosnet = P.atmosnet
		for(var/obj/machinery/portable_atmospherics/canister/C in world)
			if(C.connected == 1 && C.atmosnet == atmosnet)
				if(C.reagents.get_total_amount() > 30)
					for(var/obj/machinery/atmospherics/P in controlled)
						if(P.atmosnet == atmosnet)
							for(var/atom/movable/M in P)
								world << P
								M.MoveToVent(src, reagents.get_total_amount())

				for(var/turf/floor/F in range(1, src))
					if(!istype(src, /obj/machinery/atmospherics/outer/kitchen_oven) || (istype(src, /obj/machinery/atmospherics/outer/kitchen_oven) && fire == 0)) //kitchen check
						for(var/atom/movable/A in F)
							if(A.block_air == 0)
								/*
								if(C.oxygen > volume)
									icon_state = "vent_work"
									F.oxygen += volume
									C.oxygen -= volume

								if(C.plasma > 0)
									icon_state = "vent_work"
									F.plasma += volume
									C.plasma -= volume

								if(C.water > 0)
									icon_state = "vent_work"
									F.water += volume
									C.water -= volume
								*/
								C.reagents.trans_to(F, volume, 1)
								icon_state = "in_work"

								if(F.temperature < C.temperature)
									F.temperature += C.temperature - F.temperature
									C.temperature -= abs(C.temperature - F.temperature) / 2

								if(C.temperature < -180)
									C.temperature = -180

				if(istype(src, /obj/machinery/atmospherics/outer/kitchen_oven) && fire == 1) //flaming plasma (kitchen)
					if(C.reagents.has_reagent("plasma", 1))
						C.reagents.remove_reagent("plasma", 1)
						if(prob(rand(1,5)))
							call_message(5, "[ru_name] ������ ���������")




/obj/machinery/atmospherics/outer/New()
	tocontrol()
	process()
	..()

/obj/machinery/atmospherics/outer/attack_hand()
	freq = input("������� ������� ����������.","���� �������",freq)
	if(freq > 100)
		freq = 100
	if(freq < 0)
		freq = 0

/obj/machinery/atmospherics/inner
	icon_state = "in"
	density = 0
	layer = 2.3
	ru_name = "�����"
	anchored = 1
	var/volume = 1
	var/freq = 30
	on = 0

	high_volume
		ru_name = "������ �����"
		volume = 5

	newscrub
		anchored = 0

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/wrench))
			call_message(3, "[src.ru_name] [anchored ? "�������������" : "�������������"]")
			anchored = !anchored
			reset = 1
			if(!anchored)
				dir = turn(dir, 45)
			disconnect()
			process()
			sleep(25)
			refresh_connector()

	verb/rotate()
		set src in range(1, usr)
		if(!anchored)
			dir = turn(dir, 45)

/obj/machinery/atmospherics/inner/New()
	tocontrol()
	..()

/obj/machinery/atmospherics/inner/attack_hand()
	freq = input("������� ������� ����������.","���� �������",freq)
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
							/*
							if(F.oxygen >= volume)
								icon_state = "in_work"
								F.oxygen -= volume
								C.oxygen += volume

							if(F.plasma >= volume)
								icon_state = "in_work"
								F.plasma -= volume
								C.plasma += volume

							if(F.water > 0)
								icon_state = "in_work"
								F.water -= volume
								C.water += volume
							*/
							F.reagents.trans_to(C, volume, 1)
							icon_state = "in_work"

							if(C.temperature < F.temperature)
								C.temperature += F.temperature - C.temperature
								F.temperature -= abs(F.temperature - C.temperature) / 2

							if(C.temperature < -180)
								C.temperature = -180