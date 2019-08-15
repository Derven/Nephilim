/obj/machinery
	var/on = 0
	layer = 3

/obj/machinery/airlock
	icon = 'icons/airlock.dmi'
	icon_state = "door_1"
	ru_name = "������� ���������"
	density = 1
	opacity = 1
	block_air = 1
	anchored = 1
	var/door_state = "door"
	var/open = 1
	need_voltage = 25
	need_amperage = 3
	max_VLTAMP = 500

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

	attack_hand()
		if(use_power())
			call_message(3, "����� [open == 1 ? "���������" : "���������"]")
			open()
		else
			call_message(3, "����� ����������")

/obj/machinery/power_block
	icon = 'computer.dmi'
	icon_state = "power_block"
	ru_name = "���� �������"
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
			descr.Add(fix1103("���������� � ���� [CABEL.voltage]"))
			descr.Add("���� ���� � ���� [CABEL.amperage]")
			descr.Add(fix1103("������ �������� ���������� [ivoltage]"))
			descr.Add("������ �������� ���� ���� [iamperage]")

			hrefs.Add("null=null")
			hrefs.Add("null=null")
			hrefs.Add("voltage=ok")
			hrefs.Add("amperage=ok")

			M << browse(nterface(descr, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["voltage"]=="ok")
			ivoltage = input(usr, "���������� (��������).","���� ��������",ivoltage) as num
			attack_hand(usr)
		if(href_list["amperage"]=="ok")
			iamperage = input(usr, "���� ���� (��������).","���� ��������",iamperage) as num
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
	ru_name = "�������������� �������"
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