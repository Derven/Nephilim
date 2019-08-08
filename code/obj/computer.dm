/obj/machinery/computer
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "���������"
	var/obj/item/mainboard/MAINBOARD
	var/defaultmainboard = /obj/item/mainboard
	anchored = 1
	density = 1
	layer = 3
	var/checkoverlay = 0
	need_voltage = 15
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1

	New()
		..()
		tocontrol()
		MAINBOARD = new defaultmainboard(src)

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/screwdriver))
			if(MAINBOARD)
				MAINBOARD.loc = src.loc
				call_message(3, "[usr] ����������� [MAINBOARD.ru_name] �� [src.ru_name]")
				MAINBOARD = null
		if(istype(I, /obj/item/mainboard))
			if(!MAINBOARD)
				var/obj/machinery/computer/CM = new I:comptype(src.loc)
				call_message(3, "[usr] ��������� [I.ru_name] � [ru_name]")
				usr:drop()
				CM.MAINBOARD = I
				I.Move(CM)
				del(src)

		if(istype(I, /obj/item/tools/wrench))
			easy_deconstruct(usr)

	proc/okinterface()
		if(use_power() && MAINBOARD)
			return 1
		else
			return 0

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			nocontrol()

/obj/machinery/computer/eng
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "���������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/ticks = 1
	var/reservedfortime = 0
	defaultmainboard = /obj/item/mainboard/eng
	var/reserves = 0

	proc/view_all_activity()
		var/list/data = list()
		for(var/obj/electro/battery/B in controlled)
			if(B.powernet == powernet)
				data += fix1103("������� ����� ����: [B.full_charge]")
				data += fix1103("� �������: [B.charge]")
				data += fix1103("��������� ����������: [B.full_charge / (20 * 15 * 2)]")
				data += fix1103("��������� ���� ����: [(B.full_charge / (20 * 15 * 2)) / 20]")
		return data

	New()
		..()
		MAINBOARD = new defaultmainboard(src)
		sleep(5)
		tocontrol()

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			spawn(ticks)
				for(var/obj/electro/battery/B in controlled)
					if(B.powernet == powernet)
						if(reservedfortime < B.full_charge)
							B.full_charge -= reservedfortime
							B.charge += reservedfortime
			use_power()
		else
			overlays.Cut()
			//nocontrol()

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface())
			if(view_all_activity())
				var/list/powerstat = view_all_activity()
				var/list/hrefs = list()
				for(var/stat in powerstat)
					hrefs.Add("null=null")
				powerstat.Add(fix1103("�������� � ������"))
				powerstat.Add(fix1103("����� �� �������"))
				powerstat.Add(fix1103("������������� ����������� � ������"))
				powerstat.Add(fix1103("����� ��������������(����������)"))

				hrefs.Add("reserve=add")
				hrefs.Add("reserve=remove")
				hrefs.Add("reserve=fulltime")
				hrefs.Add("reserve=ticks")
				M << browse(nterface(powerstat, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["reserve"] == "add")
			reserves = input(usr, "������� ��������� � ������","���� ��������",reserves) as num
			for(var/obj/electro/battery/B in controlled)
				if(B.powernet == powernet)
					if(reserves < B.full_charge)
						B.full_charge -= reserves
						B.charge += reserves
			attack_hand(usr)
		if(href_list["reserve"] == "remove")
			reserves = input(usr, "������� ������������ �� �������.","���� ��������",reserves) as num
			for(var/obj/electro/battery/B in controlled)
				if(B.powernet == powernet)
					if(reserves < B.charge)
						B.charge -= reserves
						B.full_charge += reserves
			attack_hand(usr)
		if(href_list["reserve"] == "fulltime")
			reservedfortime	= input(usr, "������� ������������� ���������� � ������.","���� ��������",reservedfortime) as num
			attack_hand(usr)
		if(href_list["reserve"] == "ticks")
			ticks = input(usr, "��� ������ ���������� � ������(� ��������).","���� ��������",ticks) as num
			if(ticks > 200)
				ticks = 200
			attack_hand(usr)


/obj/item/mainboard
	icon = 'computer.dmi'
	icon_state = "mainboard_computer"
	ru_name = "������� �����"
	var/comptype = /obj/machinery/computer
	layer = 7

	proc/overlayscomp()
		var/atom/OWNER = loc
		if(istype(OWNER, /obj/machinery/computer))
			for(src in OWNER.overlays)
				return 0
			OWNER.overlays.Add(src)

	process()
		overlayscomp()
		return 0

	eng
		icon = 'computer.dmi'
		icon_state = "mainboard_engcomputer"
		ru_name = "������� ����� ����������� ����������"
		comptype = /obj/machinery/computer/eng
