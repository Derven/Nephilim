//ZAKON OMA
// R = U/I ### resistance = voltage / amperage
// U = IR ### voltage = ameperage * resistance
// I = U/R ### amperage = voltage / resistance

//������� � ����-����� (���������� * ������� � �����-�����) ### full_charge = charge * work_voltage

var/global/DERVENPOWER = 0
var/global/list/smes = list()
var/global/list/wires = list()
var/global/list/generators = list()

#define LENGTH 2 //����� ����� ����������� ����� 2, �������������� ����� ������� ���� 2 ����� (����������� ��������, ������������)

//����, ��� ������� ������������� � ������� ���� ���� ��������� ������ �����������, �� ��� ������� ���� ������ ������� �����. ���.
//� �����, ��������� ������������� ��� ������� �������������, � ������� ��� ���������. ��� ����� ��� �������������

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
		resistance = 1 //�������������, ���������� ��������
		amperage = 0 //���� ����
		voltage = 0 //����������
		conductivity = 1 //������������ (���������/����������)
		isolation = 1 //��������, ����� � �����-�� ��������.
		my_temperature = 0 //����������� ����� ���������� �� ����������
		power_limit //������ �� ��������� �������� ����������� ���������� �� ����������
		temperature_limit = 100 //������������ �����������, ������� �������� ��������� ���������

/obj/machinery
	var/marker = 0

/obj/electro/cable
	var
		sq = 1 //������� �������

	anchored = 1
	name = "cable"
	icon = 'power.dmi'
	ru_name = "������"
	var/powernet = 0
	var/reset = 0
	var/zLevel = 0
	var/marker = 0
	layer = 2.4
	var/real_resistance

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

/obj/electro/cable/copper
	name = "copper_cable"
	icon_state = "copper"
	resistance = 20
	sq = 15

	attack_hand()
		if(!isolation)
			usr:powerdamage(voltage * amperage)

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
		call_message(5, "[src.ru_name] ����� � ������. ������ ��� ��������� �������")


	proc/use_power()
		if(use_power == 1)
			for(var/obj/electro/cable/C in src.loc)
				powernet = C.powernet
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
	..()

/obj/electro/battery
	var
		charge = 0 //������� � �����-�����(��� ��� ��� �� ����� ������������ �����, ���� ����� ��������)
		work_voltage = 0 //������� ����������
		//������� � ����-����� (���������� * ������� � �����-�����) ### full_charge = charge * work_voltage
		full_charge = 0
		powernet = 0
	smes
		name = "smes"
		icon = 'power.dmi'
		icon_state = "smes"
		work_voltage = 320
		full_charge = 50000
		anchored = 1

	process()
		for(var/obj/electro/cable/C in controlled)
			if(C.powernet == powernet)
				C.voltage = full_charge/(C.resistance * C.sq * LENGTH)
			if(full_charge < 0)
				full_charge = 0
	New()
		..()
		tocontrol()

/obj/electro/battery/attack_hand(usr)
	world << "[charge]"

/obj/electro/cable/proc/just_check(var/other_amperage)
	if(amperage == 0)
		amperage = other_amperage
		if(other_amperage > 0)
			if(amperage - resistance > 0)
				amperage -= resistance //������������
			else
				amperage = 0

		other_amperage = 0
			//world << "myloc ([x],[y])"

	if(amperage < other_amperage || (amperage == other_amperage && amperage != 0))
		amperage = other_amperage
		other_amperage = 0

		if(amperage - resistance > 0)
			amperage -= resistance //������������
		else
			amperage = 0

		//world << "myloc ([x],[y])"

/obj/electro/cable/process()
	amperage = voltage / resistance

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


	if(dir == 2 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		for(var/obj/electro/cable/A in get_step(src,NORTH))
			if(A.powernet != 0)
				powernet = A.powernet

		for(var/obj/electro/cable/A in get_step(src,SOUTH))
			if(A.powernet != 0)
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

	if(dir == 4 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		for(var/obj/electro/cable/A in get_step(src,EAST))
			if(A.powernet != 0)
				powernet = A.powernet

		for(var/obj/electro/cable/A in get_step(src,WEST))
			if(A.powernet != 0)
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

	if(reset == 1) // ��������
		powernet = 0
		reset = 0
		call_message(5, "�������� ������ �������� � ��� ����� ����� ������ ������")

/obj/effect/sparks
	name = "spaks"
	icon = 'power.dmi'
	icon_state = "sparks"

	New()
		..()
		spawn(rand(1,2))
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

/obj/machinery/generator/attack_hand(usr)
	for(var/obj/electro/battery/B in controlled)
		if(B.powernet == powernet)
			B.full_charge += 5000