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
		MAINBOARD = new defaultmainboard(src)
		sleep(5)
		tocontrol()

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
			if(use_power())
				ul_SetLuminosity(2, 3, 2)
			else
				ul_SetLuminosity(0, 0, 0)
		else
			overlays.Cut()
			nocontrol()
			ul_SetLuminosity(0, 0, 0)

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
			if(use_power())
				ul_SetLuminosity(2, 3, 2)
			else
				ul_SetLuminosity(0, 0, 0)
		else
			overlays.Cut()
			ul_SetLuminosity(0, 0, 0)
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
				special_browse(M, nterface(powerstat, hrefs))

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


/obj/machinery/computer/autolathe
	icon = 'computer.dmi'
	icon_state = "autolathe"
	ru_name = "�������"
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
	defaultmainboard = /obj/item/mainboard/autolathe
	var/reserves = 0
	var/metal = 0
	var/glass = 0
	var/list/required_metal = list(1,0,1,1,2,2,2)
	var/list/required_glass = list(0,1,0,0,0,0,0)
	var/list/obj/item/production = list(/obj/item/stack/metal, /obj/item/stack/glass, /obj/item/tools/wrench, /obj/item/staple, /obj/machinery/atmospherics/pipe/newpipe, \
	/obj/machinery/atmospherics/inner/newscrub, /obj/machinery/atmospherics/outer/newvent)
	var/list/production_names = list("���� �������", "���� ������", "��������� ����", "�����", "�����", "�����", "����������")

	robotech_fabricator
		defaultmainboard = /obj/item/mainboard/robotech
		ru_name = "����������"
		required_metal = list(1,0,1,1,1,1)
		required_glass = list(0,1,1,1,1,1)
		production = list(/obj/item/stack/metal, /obj/item/stack/glass, /obj/item/roboprothesis, /obj/item/roboprothesis/arml, /obj/item/roboprothesis/legl, /obj/item/roboprothesis/legr)
		production_names = list("���� �������", "���� ������", "������ ������ ����", "������ ����� ����", "������ ����� ����", "������ ������ ����")

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
		if(istype(I, /obj/item/stack/metal))
			metal += I:amount
			call_message(3, "[usr] ��������� [I:amount] ������ ������� � [ru_name]")
			M:drop()
			del(I)
		if(istype(I, /obj/item/stack/glass))
			glass += I:amount
			call_message(3, "[usr] ��������� [I:amount] ������ ������ � [ru_name]")
			M:drop()
			del(I)


	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(use_power())
			var/list/descr = list()
			var/list/myhrefs = list()
			var/i = 0
			for(var/d in production)
				i++
				descr.Add("[production_names[i]] - ������� [required_metal[i]] ������� � [required_glass[i]] ������")

			for(var/d in production)
				myhrefs.Add("production=[d]")

			descr.Add("������� [metal]; ������ [glass]")
			myhrefs.Add("null=null")
			special_browse(M, nterface(descr, myhrefs))

	Topic(href,href_list[])
		if(href_list["production"])
			var/mypath = text2path(href_list["production"])
			var/i = 0
			for(var/cr in production)
				i++
				if(cr == mypath && required_metal[i] <= metal && required_glass[i] <= glass && use_power())
					var/atom/A = new mypath(usr.loc)
					call_message(5, "[usr] ������ [A.ru_name]")
					metal -= required_metal[i]
					glass -= required_glass[i]

			attack_hand(usr)

/obj/item/device
	icon = 'computer.dmi'
	icon_state = "device_frame"
	ru_name = "����������"
	var/obj/item/devicemainboard/MAINBOARD
	var/obj/item/devicebattery/DEVICEBATTERY
	var/obj/item/deviceoutput/SPEAKER
	var/mainboardtype = /obj/item/devicemainboard
	var/mainboardov = 0
	var/batteryov = 0
	var/speakerov = 0
	var/need_voltage = 12
	var/need_amperage = 1
	var/maxVLTAMP = 15
	var/on = 0
	var/broken = 0
	layer = 3

	seed_extractor
		mainboardtype = /obj/item/devicemainboard/seed_extractor

	proc/init()
		MAINBOARD = new mainboardtype(src)
		DEVICEBATTERY = new(src)
		SPEAKER = new(src)
		tocontrol()

	proc/attack_device(var/mob/M, var/atom/A)
		if(MAINBOARD && DEVICEBATTERY && SPEAKER)
			if(DEVICEBATTERY.charge_level > 0 && on && !broken)
				MAINBOARD.activate(A)
		return

	New()
		..()
		init()

	attackby(var/mob/M, var/obj/item/I)
		if(MAINBOARD)
			if(istype(I, /obj/item/tools/screwdriver))
				MAINBOARD.loc = src.loc
				call_message(3, "[usr] ����������� [MAINBOARD.ru_name] �� [src.ru_name]")
				MAINBOARD = null
				return

		if(DEVICEBATTERY)
			if(istype(I, /obj/item/tools/screwdriver))
				DEVICEBATTERY.loc = src.loc
				call_message(3, "[usr] ����������� [SPEAKER.ru_name] �� [src.ru_name]")
				DEVICEBATTERY = null
				return

		if(SPEAKER)
			if(istype(I, /obj/item/tools/screwdriver))
				SPEAKER.loc = src.loc
				call_message(3, "[usr] ����������� [SPEAKER.ru_name] �� [src.ru_name]")
				SPEAKER = null
				return

		if(istype(I, /obj/item/devicemainboard))
			if(!MAINBOARD)
				var/obj/item/device/CM = new I:comptype(src.loc)
				call_message(3, "[usr] ��������� [I.ru_name] � [ru_name]")
				usr:drop()
				CM.MAINBOARD = I
				I.Move(CM)
				if(!DEVICEBATTERY)
					CM.DEVICEBATTERY = null
				if(!SPEAKER)
					CM.SPEAKER = null
				nocontrol()
				spawn(5)
					del(src)

		if(istype(I, /obj/item/devicebattery))
			if(!DEVICEBATTERY)
				DEVICEBATTERY = I
				M:drop()
				I.Move(src)
				call_message(3, "[usr] ��������� [I.ru_name] � [ru_name]")

		if(istype(I, /obj/item/deviceoutput))
			if(!SPEAKER)
				SPEAKER = I
				M:drop()
				I.Move(src)
				call_message(3, "[usr] ��������� [I.ru_name] � [ru_name]")

	process()
		if(MAINBOARD && !mainboardov)
			overlays.Add(MAINBOARD)
			mainboardov = 1

		if(DEVICEBATTERY && !batteryov)
			overlays.Add(DEVICEBATTERY)
			batteryov = 1

		if(SPEAKER && !speakerov)
			overlays.Add(SPEAKER)
			speakerov = 1

		if(!SPEAKER)
			overlays.Cut()
			speakerov = 0
			mainboardov = 0
			batteryov = 0
			if(MAINBOARD && !mainboardov)
				overlays.Add(MAINBOARD)
				mainboardov = 1
			if(DEVICEBATTERY && !batteryov)
				overlays.Add(DEVICEBATTERY)
				batteryov = 1


		if(!MAINBOARD)
			overlays.Cut()
			mainboardov = 0
			speakerov = 0
			batteryov = 0
			if(SPEAKER && !speakerov)
				overlays.Add(SPEAKER)
				speakerov = 1
			if(DEVICEBATTERY && !batteryov)
				overlays.Add(DEVICEBATTERY)
				batteryov = 1

		if(!DEVICEBATTERY)
			overlays.Cut()
			speakerov = 0
			mainboardov = 0
			batteryov = 0
			if(SPEAKER && !speakerov)
				overlays.Add(SPEAKER)
				speakerov = 1
			if(DEVICEBATTERY && !batteryov)
				overlays.Add(DEVICEBATTERY)
				batteryov = 1

		if(MAINBOARD && DEVICEBATTERY && SPEAKER)
			if(!broken && on)
				if(DEVICEBATTERY.charge_level > 0)
					if(DEVICEBATTERY.voltage * DEVICEBATTERY.amperage > maxVLTAMP)
						broken = 1
						loc.call_message(5, "[src.ru_name] ����� � ������. ������ ��� ���������� �������")
						return

					if(DEVICEBATTERY.charge_level < 100)
						loc.call_message(SPEAKER.power, "[src.ru_name] �����������. ������ ������� ������� �������!")

					DEVICEBATTERY.charge_level--
				else
					on = 0

	attackinhand(var/mob/M)
		if(MAINBOARD && DEVICEBATTERY && SPEAKER)
			if(!broken)
				if(DEVICEBATTERY.charge_level > 0)
					on = !on
					if(on)
						M.call_message(SPEAKER.power, "[src.ru_name] ������ ������� �����������!")
					if(!on)
						M.call_message(SPEAKER.power, "[src.ru_name] ������ ������� ��������!")

/obj/item/deviceoutput
	icon = 'computer.dmi'
	icon_state = "speaker_device"
	ru_name = "������� �������"
	layer = 4
	var/power = 3

/obj/item/devicebattery
	icon = 'computer.dmi'
	icon_state = "battery_device"
	ru_name = "������� �������"
	amperage = 1
	voltage = 12
	var/max_charge = 2000
	var/charge_level = 2000
	layer = 4

/obj/item/devicemainboard
	icon = 'computer.dmi'
	icon_state = "mainboard_device"
	ru_name = "����������"
	var/comptype = /obj/item/device
	layer = 4

	proc/activate(var/atom/A)
		return

	seed_extractor
		icon_state = "mainboard_device_ext"
		ru_name = "���������� �����������"

		activate(var/atom/A)
			if(istype(A, /obj/item/food))
				if(istype(A.loc, /turf/floor))
					for(var/mob/living/plant/P in A)
						P.loc = A.loc
						P.init = 1
						P.init()
						A.loc:call_message(src.loc:SPEAKER.power, "[P.ru_name] ������������ �� [A.loc:ru_name]!")
						del(A)


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

	autolathe
		icon = 'computer.dmi'
		icon_state = "mainboard_autolathe"
		ru_name = "������� ����� ��������"
		comptype = /obj/machinery/computer/autolathe

	robotech
		icon = 'computer.dmi'
		icon_state = "mainboard_robotech"
		ru_name = "������� ����� �����������"
		comptype = /obj/machinery/computer/autolathe/robotech_fabricator
/*
	morph
		icon = 'computer.dmi'
		icon_state = "mainboard_morphcomputer"
		ru_name = "������� ����� ����������������"
		comptype = /obj/machinery/computer/morph


/obj/machinery/computer/morph
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "��������� ���������� ��������"
	name = "morph_comp"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 25
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 700
	var/ticks = 1
	var/reservedfortime = 0
	defaultmainboard = /obj/item/mainboard/morph
	var/reserves = 0
	var/obj/machinery/morphcamera_corpse/M_C
	var/obj/machinery/morphcamera_newbody/N_B

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		M_C = null
		N_B = null

		var/list/devices = list()
		var/list/hrefs = list()

		for(var/obj/machinery/morphcamera_corpse/MC in controlled)
			if(MC.powernet == powernet)
				M_C = MC

		for(var/obj/machinery/morphcamera_newbody/NB in controlled)
			if(NB.powernet == powernet)
				N_B = NB

		if(M_C)
			devices.Add("[M_C.ru_name]: [M_C.body]")
			hrefs.Add("mc=1")

		if(N_B)
			devices.Add("[N_B.ru_name]: [N_B.body]")
			hrefs.Add("nb=1")

		if(M_C && N_B)
			devices.Add("��������� �������� �� [M_C.ru_name] � [N_B.ru_name]")
			hrefs.Add("mctonb=1")

		M << browse(nterface(devices, hrefs),"window=[name]")


	Topic(href,href_list[])
		if(href_list["mctonb"] == "1")
			var/client/nbclient
			if(N_B.body.client)
				nbclient = N_B.body.client
			if(M_C.body.client)
				M_C.body.client = N_B.body.client
			if(nbclient)
				nbclient = M_C.body.client
			for(var/atom/movable/M in M_C)
				M.loc = M_C
				M_C.body = null
			for(var/atom/movable/M in N_B)
				M.loc = N_B
				N_B.body = null
*/

/obj/item/mainboard/gravity
	icon = 'computer.dmi'
	icon_state = "mainboard_gravity"
	ru_name = "������� ����� ��������������� ����������"
	comptype = /obj/machinery/computer/gravity

/obj/machinery/computer/gravity
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "�������������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/ticks = 1
	defaultmainboard = /obj/item/mainboard/gravity

	proc/view_all_activity()
		var/list/obj/machinery/gravity_shield/data = list()
		for(var/obj/machinery/gravity_shield/B in controlled)
			if(B.powernet == powernet)
				data.Add(B)
		return data

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			if(view_all_activity())
				var/list/powerstat = list()
				var/list/hrefs = list()
				powerstat.Add(fix1103("��������/��������� �������������� ������� � ����"))
				hrefs.Add("gravity=ok")
				special_browse(M, nterface(powerstat, hrefs))

	Topic(href,href_list[])
		if(href_list["gravity"] == "ok")
			var/list/obj/machinery/gravity_shield/data = view_all_activity()
			for(var/obj/machinery/gravity_shield/SH in data)
				SH.on = !SH.on


/obj/item/mainboard/atmos
	icon = 'computer.dmi'
	icon_state = "mainboard_atmos"
	ru_name = "������� ����� ������������ ����������"
	comptype = /obj/machinery/computer/atmos

/obj/machinery/computer/atmos
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "����������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/freq = 15
	defaultmainboard = /obj/item/mainboard/atmos

	proc/view_all_activity()
		var/list/obj/machinery/atmospherics/data = list()
		for(var/obj/machinery/atmospherics/outer/B in controlled)
			if(B.freq == freq)
				data.Add(B)
		for(var/obj/machinery/atmospherics/inner/A in controlled)
			if(A.freq == freq)
				data.Add(A)
		return data

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			if(use_power())
				ul_SetLuminosity(2, 3, 2)
			else
				ul_SetLuminosity(0, 0, 0)
		else
			overlays.Cut()
			ul_SetLuminosity(0, 0, 0)
			//nocontrol()

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			if(view_all_activity())
				var/list/stats = list()
				var/list/hrefs = list()
				var/list/obj/machinery/M2 = view_all_activity()
				for(var/obj/machinery/atmospherics/A in M2)
					stats.Add(fix1103("[A.ru_name] ��������/��������� ([A.on ? "��������" : "���������"])"))
					hrefs.Add("amachine=\ref[A]")
				stats.Add("������� ������� ([freq])")
				hrefs.Add("freq=input")
				special_browse(M, nterface(stats, hrefs))

	Topic(href,href_list[])
		if(href_list["amachine"])
			var/obj/machinery/M = locate(href_list["amachine"])
			M.on = !M.on
			attack_hand(usr)
		if(href_list["freq"] == "input")
			freq = input("������� ������� ����������.","���� �������",freq)
			if(freq > 100)
				freq = 100
			if(freq < 0)
				freq = 0
			attack_hand(usr)

////SHUTTLE

/obj/machinery/computer/shuttle
	icon = 'computer.dmi'
	icon_state = "computer_shuttle"
	ru_name = "������������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/freq = 15
	defaultmainboard = /obj/item/mainboard/shuttle

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

/obj/item/mainboard/shuttle
	icon = 'computer.dmi'
	icon_state = "mainboard_shuttle"
	ru_name = "������� ����� �������������� ����������"
	comptype = /obj/machinery/computer/shuttle

/obj/machinery/engine
	icon = 'computer.dmi'
	icon_state = "engine"
	ru_name = "������ ���������"

	process()
		if(transportid != -1)
			for(var/dz/DZ in world)
				if(DZ.id == transportid && DZ.center == 1)
					dir = DZ.dir

///TELEPOrTER
/obj/machinery/computer/teleporter
	icon = 'computer.dmi'
	icon_state = "telemachine"
	ru_name = "���������������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/tx = 0
	var/ty = 0
	defaultmainboard = /obj/item/mainboard/tele

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			var/list/stats = list()
			var/list/hrefs = list()
			for(var/obj/machinery/telepad/A in range(1, src))
				stats.Add(fix1103("[A.ru_name] - ��������"))
				hrefs.Add("amachine=\ref[A]")
			stats.Add("������ ���������� ([tx];[ty])")
			hrefs.Add("xy=input")
			stats.Add("��������� � ���������")
			hrefs.Add("send=ok")
			special_browse(M, nterface(stats, hrefs))

	Topic(href,href_list[])
		if(href_list["amachine"])
			attack_hand(usr)
		if(href_list["xy"] == "input")
			tx = input("������� ����� �� X c ������ �����������.","��� �����",tx)
			ty = input("������� ����� �� Y c ������ �����������.","��� �����",ty)
			if(tx > world.maxx)
				tx = 0
			if(ty > world.maxy)
				ty = 0
			attack_hand(usr)
		if(href_list["send"] == "ok")
			for(var/obj/machinery/telepad/A in range(1, src))
				for(var/atom/movable/M in A.loc)
					if(!M.anchored)
						M.loc = locate(x + tx + rand(1,5), y + ty + rand(1,5), 1)
						new /obj/effect/sparks(src.loc)
						if(istype(M, /mob/living/human))
							if(M.loc.density == 1)
								for(var/obj/item/organ/O in M)
									O.loc = locate(M.x + rand(-2,2), M.y + rand(-2,2), M.z)
								M:organsnull()
								M:death()
								del(M)


	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

/obj/machinery/telepad
	icon = 'computer.dmi'
	icon_state = "telepad"
	ru_name = "�������������"
	anchored = 1

/obj/item/mainboard/tele
	icon = 'computer.dmi'
	icon_state = "mainboard_telemachine"
	ru_name = "������� ����� ����������������� ����������"
	comptype = /obj/machinery/computer/shuttle

//genetics

/obj/machinery/computer/genetics
	icon = 'computer.dmi'
	ru_name = "������������ ���������"
	icon_state = "computer_frame"
	anchored = 1
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/tx = 1
	var/obj/structure/closet/genetic/GM
	defaultmainboard = /obj/item/mainboard/genetics
	var/instruction = ""

	New()
		..()
		MAINBOARD = new defaultmainboard(src)
		sleep(5)
		tocontrol()
		instruction += "1 - [pick("��� �������", "����������")];"
		instruction += "2 - [pick("�������� �����������", "����������")];"
		instruction += "3 - [pick("���������������� �����������", "����������")];"
		instruction += "4 - [pick("�������� �����������", "����������")];"
		instruction += "5 - [pick("����", "����������")];"
		instruction += "6 - [pick("����", "����������")];"
		instruction += "7 - [pick("��������", "����������")];"
		instruction += "8 - [pick("����", "����������")];"
		instruction += "9 - [pick("�����", "����������")];"
		instruction += "10 - [pick("����������", "����������")];"
		instruction += "11 - [pick("�����", "����������")];"
		instruction += "12 - [pick("���������������� � ����", "����������")];"
		instruction += "13 - [pick("������� ����", "����������")];"
		instruction += "14 - [pick("�����", "����������")];"
		instruction += "15 - [pick("�����", "����������")];"

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
		if(istype(I, /obj/item/DNAdisk))
			for(var/obj/structure/closet/genetic/A in range(1, src))
				for(var/mob/living/human/H in A)
					H.DNA.encodedecodeme(H.DNA.decode(H.DNA.encode2(I:DISKDNA)))

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			var/list/stats = list()
			var/list/hrefs = list()
			for(var/obj/structure/closet/genetic/A in range(1, src))
				stats.Add(fix1103("[A.ru_name] - ��������"))
				hrefs.Add("amachine=\ref[A]")
			stats.Add("������ ���������")
			hrefs.Add("xy=input")
			stats.Add("���������� ���������")
			hrefs.Add("send=ok")
			stats.Add("������� ����������")
			hrefs.Add("send=instruction")
			stats.Add("��������� �� ������")
			hrefs.Add("send=save")
			special_browse(M, nterface(stats, hrefs))

	Topic(href,href_list[])
		if(href_list["amachine"])
			attack_hand(usr)
		if(href_list["xy"] == "input")
			for(var/obj/structure/closet/genetic/A in range(1, src))
				for(var/mob/living/human/H in A)
					tx = input("������� ������� ������������� ����.","��� ������� �� 1 �� 15",tx)
					if(tx > 15)
						tx = 15
					if(tx < 1)
						tx = 1
					H.DNA.mutate_sector(tx)
					attack_hand(usr)
		if(href_list["send"] == "ok")
			for(var/obj/structure/closet/genetic/A in range(1, src))
				for(var/mob/living/human/H in A)
					var/list/iDNA = H.DNA.encode()
					var/str = ""
					for(var/fragment in iDNA)
						str += fragment
					usr.message_to_usr("[str]")
					attack_hand(usr)
		if(href_list["send"] == "instruction")
			usr.message_to_usr("[instruction]")
		if(href_list["send"] == "save")
			var/gename = ""
			gename = input("�������� ����������� ���.","������������",gename)
			for(var/obj/machinery/gserver/A in world)
				if(A.powernet == powernet)
					for(var/obj/structure/closet/genetic/A2 in range(1, src))
						for(var/mob/living/human/H in A2)
							var/list/iDNA = H.DNA.encode()
							var/str = ""
							for(var/fragment in iDNA)
								str += fragment
							A.DNA["[gename]"] = str
							A.mydna["[gename]"] = H.DNA.decode(H.DNA.encode())

/obj/item/mainboard/genetics
	icon = 'computer.dmi'
	icon_state = "mainboard_genetics"
	ru_name = "������� ����� ������������� ����������"
	comptype = /obj/machinery/computer/shuttle

/obj/structure/closet/genetic
	icon = 'computer.dmi'
	icon_state = "scanner_1"
	ru_name = "������������ �����������"
	state = "scanner"

/obj/machinery/gserver
	icon = 'computer.dmi'
	icon_state = "server"
	ru_name = "������ ������������� ����"
	anchored = 1
	density = 1
	var/list/DNA = list()
	var/list/mydna = list()

	New()
		..()
		sleep(5)
		tocontrol()

/obj/item/DNAdisk
	layer = 3
	icon = 'computer.dmi'
	icon_state = "disk"
	var/list/DISKDNA = list()

/obj/machinery/computer/genetics/floppybird
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "������� ������ ������������� ����"
	anchored = 1
	density = 1

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			var/list/stats = list()
			var/list/hrefs = list()
			for(var/obj/machinery/gserver/A in range(1, src))
				for(var/g in A.DNA)
					stats.Add(fix1103("[g] - [A.DNA[g]] (�� �������)"))
					hrefs.Add("dna=[g]")
			special_browse(M, nterface(stats, hrefs))

	Topic(href,href_list[])
		if(href_list["dna"])
			for(var/obj/machinery/gserver/A in range(1, src))
				var/obj/item/DNAdisk/DDISK = new /obj/item/DNAdisk(src.loc)
				DDISK.DISKDNA = A.mydna[href_list["dna"]]


///CHEMICAl
/obj/machinery/computer/chemical
	icon = 'computer.dmi'
	icon_state = "chemical_dispenser"
	ru_name = "��������� ���������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/obj/item/weapon/reagent_containers/RG
	defaultmainboard = /obj/item/mainboard/chemical
	var/list/chemical_names = list("chemical=barium", "chemical=calcium", "chemical=chlorine", "chemical=fluorine", "chemical=helium", "chemical=iron", "chemical=lithium", \
	"chemical=magnesium", "chemical=mercury", "chemical=potassium", "chemical=radium", "chemical=silver", "chemical=sugar", "container=out")
	var/list/chemical_ru_names = list("�����", "�������", "����", "����", "�����", "������", "������", "������", "�����", "�����", "�����", "�������", "�����", "\[������� ���������!\]")

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
		if(istype(I, /obj/item/weapon/reagent_containers))
			if(!RG)
				usr:drop()
				RG = I
				I.loc = src

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		if(okinterface() && use_power())
			special_browse(M, nterface(chemical_ru_names, chemical_names))

	Topic(href,href_list[])
		if(href_list["chemical"])
			if(RG)
				if(RG.volume - RG.reagents.get_total_amount() > 10)
					RG.reagents.add_reagent(href_list["chemical"], 10)
					loc.call_message(5, "[src.ru_name] ������ 10 ������ [href_list["chemical"]]")
			attack_hand(usr)
		if(href_list["container"])
			if(RG)
				RG.loc = src.loc
				RG = null
	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

/obj/item/mainboard/chemical
	icon = 'computer.dmi'
	icon_state = "mainboard_chemical"
	ru_name = "������� ����� �������������� ����������"
	comptype = /obj/machinery/computer/chemical