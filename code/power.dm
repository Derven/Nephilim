//ZAKON OMA
// R = U/I ### resistance = voltage / amperage
// U = IR ### voltage = ameperage * resistance
// I = U/R ### amperage = voltage / resistance

//емкость в ватт-часах (напряжение * емкость в ампер-часах) ### full_charge = charge * work_voltage

var/global/DERVENPOWER = 0
var/global/list/smes = list()
var/global/list/wires = list()
var/global/list/generators = list()

#define LENGTH 2 //длина тайла предположим метра 2, соответственно длина провода тоже 2 метра (константная величина, неизменяемая)

//алсо, при большом сопротивлении и высокой силе тока проводник должен нагреваться, но мне удобнее было кодить немного иначе. Вот.
//в общем, маленькое сопротивление это большое сопротивление, а большое это маленькое. Вот такая вот Дервенофизика

var/list/obj/machinery/machines = list()

/obj/electro/powerbox
	name = "powerbox"
	icon = 'power.dmi'
	icon_state = "apc"
	var/powernet = 0
	alpha = 128
	layer = 2.4
	anchored = 1

/atom
	var
		resistance = 1 //сопротивление, определяет материал
		amperage = 0 //сила тока
		voltage = 0 //напряжение
		conductivity = 1 //проводимость (проводник/диэлектрик)
		isolation = 1 //изоляция, нужна в общем-то проводам.
		my_temperature = 0 //температура будет повышаться от перегрузок
		power_limit //предел до првышения которого температура проводника не повышается
		temperature_limit = 100 //максимальная температура, которую способен выдержать проводник

/obj/machinery
	var/marker = 0

/obj/electro/cable
	var
		sq = 1 //площадь сечения

	anchored = 1
	name = "cable"
	icon = 'power.dmi'
	ru_name = "кабель"
	var/powernet = 0
	var/reset = 0
	var/zLevel = 0
	var/marker = 0
	layer = 1.5
	var/real_resistance
	var/on = 1

	switcher
		icon_state = "switcher_1"
		resistance = 50
		sq = 12
		layer = 5
		dir = 5

		attack_hand()
			if(istype(src, /obj/electro/cable/switcher))
				on = !on
				icon_state = "switcher_[on]"
				world << "[powernet];[voltage];[amperage]"
				allcablesreset()
				process()
				return

			if(!isolation)
				usr:powerdamage(voltage * amperage)

	output
		name = "out_cable"
		icon_state = "force"
		resistance = 50
		sq = 12

	Del()
		..()
		reset = 1

	proc/return_smes()
		for(var/obj/electro/battery/B in controlled)
			if(B.powernet == powernet)
				return B

	attackby(var/mob/M, var/obj/item/I)
		if(!istype(src, /obj/electro/cable/switcher))
			if(istype(I, /obj/item/tools/wirecutters))
				call_message(3, "[src.ru_name] [anchored ? "откусывается" : "скручивается"]")
				if(!M:check_isogloves())
					usr:powerdamage(voltage * amperage)
				anchored = !anchored
				layer = initial(layer)
				layer += !anchored
				allcablesreset()
				process()

	proc/allcablesreset()
		for(var/obj/electro/cable/B in controlled)
			if(B.powernet == powernet)
				B.voltage = 0
				B.amperage = 0
				B.reset = 1

		for(var/obj/machinery/M in controlled)
			if(M.powernet == powernet)
				M.powernet = 0

/obj/electro/cable/copper
	name = "copper_cable"
	icon_state = "copper"
	resistance = 20
	sq = 15
	layer = 3

/obj/electro/cable/iron
	name = "iron_cable"
	icon_state = "iron"
	resistance = 50
	sq = 12

/obj/electro/cable/alluminium
	name = "alluminium_cable"
	icon_state = "alluminium"
	resistance = 35
	sq = 12

/obj/machinery
	var/use_power = 1
	var/powernet = 0
	var/need_voltage = 0
	var/need_amperage = 0
	var/max_VLTAMP = 0
	powernet = 0

	proc/burnmachine()
		call_message(5, "[src.ru_name] дымит и искрит. Похоже эта установка сгорела")

	proc/use_power()
		if(use_power == 1)
			for(var/obj/electro/cable/C in src.loc)
				powernet = C.powernet
				for(var/obj/machinery/power_block/PB in src.loc)
					if(PB.out_amperage >= need_amperage && PB.out_voltage >= need_voltage)
						if(PB.out_amperage * PB.out_voltage > max_VLTAMP)
							world << "[PB.out_amperage];[PB.out_voltage]"
							burnmachine()
							use_power = 0
							return 0
						else
							if(C.return_smes())
								C.return_smes():full_charge -= need_amperage * need_voltage
								return 1
					else
						return 0
					return 0

				if(C.amperage >= need_amperage && C.voltage >= need_voltage)
					if(C.amperage * C.voltage > max_VLTAMP)
						burnmachine()
						use_power = 0
						return 0
					else
						if(C.return_smes())
							C.return_smes():full_charge -= need_amperage * need_voltage
							return 1
			return 0
		else
			return 0

/obj/electro/cable/New()
	power_limit = resistance * LENGTH * sq
	real_resistance = resistance
	wires += src
	tocontrol()
	layer = 1.5
	..()

/obj/electro/battery
	var
		charge = 0 //емкость в ампер-часах(так как это не самая реалистичная штука, часы будем опускать)
		work_voltage = 0 //рабочее напряжение
		//емкость в ватт-часах (напряжение * емкость в ампер-часах) ### full_charge = charge * work_voltage
		full_charge = 0
		powernet = 0
		on = 1
	smes
		name = "smes"
		icon = 'power.dmi'
		icon_state = "smes"
		ru_name = "аккумуляторная установка"
		work_voltage = 320
		full_charge = 500000
		anchored = 1
		density = 1

	process()
		if(on)
			for(var/obj/electro/cable/C in controlled)
				if(C.powernet == powernet)
					C.voltage = full_charge/(C.resistance * C.sq * LENGTH)
				if(full_charge < 0)
					full_charge = 0
		else
			for(var/obj/electro/cable/C in controlled)
				if(C.powernet == powernet)
					C.voltage = 0
				if(full_charge < 0)
					full_charge = 0
	New()
		DERVENPOWER++
		powernet = DERVENPOWER
		..()
		tocontrol()

/obj/electro/battery/attack_hand(usr)
	on = !on
	call_message(5, "[src.ru_name] [on ? "включена" : "выключена"]")

/obj/electro/cable/proc/just_check(var/other_amperage)
	if(amperage == 0)
		amperage = other_amperage
		if(other_amperage > 0)
			if(amperage - resistance > 0)
				amperage -= resistance //энергопотери
			else
				amperage = 0

		other_amperage = 0
			//world << "myloc ([x],[y])"

	if(amperage < other_amperage || (amperage == other_amperage && amperage != 0))
		amperage = other_amperage
		other_amperage = 0

		if(amperage - resistance > 0)
			amperage -= resistance //энергопотери
		else
			amperage = 0

		//world << "myloc ([x],[y])"

/obj/electro/cable/process()
	amperage = voltage / resistance
	if(!on)
		return

	if(istype(src, /obj/electro/cable/switcher))
		layer = 5
		dir = 5
		if(!src:on)
			powernet = 0
			for(var/obj/electro/cable/C in range(1, src))
				C.powernet = 0
				C.on = 0
			return
		else
			for(var/obj/electro/cable/C in range(1, src))
				C.on = 1

		if(amperage > 20 || voltage > 500)
			if(src:on)
				src:on = !src:on
				icon_state = "switcher_[src:on]"
				call_message(5, "доносится щелчок")
				allcablesreset()
				process()
			return

	if(voltage > power_limit)
		my_temperature = amperage - resistance - sq - LENGTH
		if(my_temperature < 0)
			my_temperature = 0

	if(voltage < power_limit)
		my_temperature = 0

	if(resistance > real_resistance)
		resistance -= resistance - real_resistance

	if(resistance < real_resistance)
		resistance += resistance + real_resistance

	if(my_temperature > temperature_limit)
		for(var/obj/electro/cable/P in world)
			if(powernet == P.powernet)
				P.reset = 1
				P.my_temperature = 0
				P.voltage = 0

		for(var/obj/machinery/P in world)
			if(powernet == P.powernet)
				P.on = 0
				P.powernet = 0
		del(src)


	if(dir == 1 || dir == 2 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		for(var/obj/electro/cable/A in get_step(src,NORTH))
			if(A.powernet != 0 && A.on)
				powernet = A.powernet

		for(var/obj/electro/cable/A in get_step(src,SOUTH))
			if(A.powernet != 0 && A.on)
				powernet = A.powernet

		for(var/obj/electro/powerbox/A in get_step(src,NORTH))
			if(powernet != 0)
				A.powernet = powernet

		for(var/obj/electro/powerbox/A in get_step(src,SOUTH))
			if(powernet != 0)
				A.powernet = powernet

		for(var/obj/electro/battery/smes/S in get_step(src,SOUTH))
			powernet = S.powernet

		for(var/obj/electro/battery/smes/S in get_step(src,NORTH))
			powernet = S.powernet

		for(var/obj/machinery/generator/S in get_step(src,SOUTH))
			S.powernet = powernet

		for(var/obj/machinery/generator/S in get_step(src,NORTH))
			S.powernet = powernet

		for(var/obj/machinery/S in get_step(src,NORTH))
			S.powernet = powernet
				//world << "power[x];[y]"

		for(var/obj/machinery/S in get_step(src,SOUTH))
			S.powernet = powernet
				//world << "power[x];[y]"

	if(dir == 4 || dir == 6 || dir == 10 || dir == 9 || dir == 5 || dir == 8)

		for(var/obj/electro/cable/A in get_step(src,EAST))
			if(A.powernet != 0 && A.on)
				powernet = A.powernet

		for(var/obj/electro/cable/A in get_step(src,WEST))
			if(A.powernet != 0 && A.on)
				powernet = A.powernet

		for(var/obj/electro/powerbox/A in get_step(src,EAST))
			if(powernet != 0)
				A.powernet = powernet

		for(var/obj/electro/powerbox/A in get_step(src,WEST))
			if(powernet != 0)
				A.powernet = powernet

		for(var/obj/electro/battery/smes/S in get_step(src,EAST))
			powernet = S.powernet

		for(var/obj/electro/battery/smes/S in get_step(src,WEST))
			powernet = S.powernet

		for(var/obj/machinery/generator/S in get_step(src,WEST))
			S.powernet = powernet

		for(var/obj/machinery/generator/S in get_step(src,EAST))
			S.powernet = powernet

		for(var/obj/machinery/S in get_step(src,EAST))
			S.powernet = powernet
					//world << "power[x];[y]"

		for(var/obj/machinery/S in get_step(src,WEST))
			S.powernet = powernet
				//world << "power[x];[y]"

	if(zLevel == 1)
		for(var/obj/electro/cable/A in locate(x,y,z+1))
			if(A.powernet != 0)
				powernet = A.powernet

	if(zLevel == -1)
		for(var/obj/electro/cable/A in locate(x,y,z-1))
			if(A.powernet != 0)
				powernet = A.powernet

	if(reset == 1) //сброс
		powernet = 0
		reset = 0

/obj/effect/sparks
	name = "spaks"
	icon = 'power.dmi'
	icon_state = "sparks"

	New()
		..()
		if(istype(src.loc, /turf))
			src.loc:initiate_burning = 1
		spawn(rand(4,6))
			src.loc:initiate_burning = 0
			del(src)

/obj/decor/cable_part
	name = "cable"
	icon = 'power.dmi'
	icon_state = "cable_part"

/obj/electro/cable/Del()
	new /obj/effect/sparks(src.loc)
	new /obj/decor/cable_part(src.loc)
	..()

/obj/machinery/generator
	name = "generator"
	icon = 'power.dmi'
	icon_state = "generator"
	layer = 4

	solar
		icon_state = "solar"

		New()
			..()
			tocontrol()

		process()
			if(istype(src.loc, /turf/space))
				for(var/obj/electro/battery/B in controlled)
					if(B.powernet == powernet)
						if(prob(15))
							B.full_charge += rand(50, 100)

		attack_hand(usr)
			return 0
	TEG
		New()
			..()
			tocontrol()

		process()
			var/temp_1
			var/temp_2

			var/turf/F = get_step(src, EAST)
			temp_1 = F.temperature

			var/turf/F2 = get_step(src, WEST)
			temp_2 = F2.temperature

			if(abs(temp_2 - temp_1) > 0)
				for(var/obj/electro/battery/B in controlled)
					if(B.powernet == powernet)
						if(prob(50))
							B.full_charge += min(abs(temp_1 - temp_2), 500)
							icon_state = "generator_inwork"
						else
							icon_state = "generator"

		attack_hand(usr)
			return 0

/obj/machinery/generator/attack_hand(usr)
	for(var/obj/electro/battery/B in controlled)
		if(B.powernet == powernet)
			B.full_charge += 5000
