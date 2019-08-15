/obj/machinery/computer
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "компьютер"
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
				call_message(3, "[usr] вытаскивает [MAINBOARD.ru_name] из [src.ru_name]")
				MAINBOARD = null
		if(istype(I, /obj/item/mainboard))
			if(!MAINBOARD)
				var/obj/machinery/computer/CM = new I:comptype(src.loc)
				call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")
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
	ru_name = "инженерный компьютер"
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
				data += fix1103("Текущий заряд СМЕС: [B.full_charge]")
				data += fix1103("В резерве: [B.charge]")
				data += fix1103("Вероятное напряжение: [B.full_charge / (20 * 15 * 2)]")
				data += fix1103("Вероятная сила тока: [(B.full_charge / (20 * 15 * 2)) / 20]")
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
				powerstat.Add(fix1103("Добавить в резерв"))
				powerstat.Add(fix1103("Взять из резерва"))
				powerstat.Add(fix1103("Автоматически откладывать в резерв"))
				powerstat.Add(fix1103("Время резервирования(промежутки)"))

				hrefs.Add("reserve=add")
				hrefs.Add("reserve=remove")
				hrefs.Add("reserve=fulltime")
				hrefs.Add("reserve=ticks")
				M << browse(nterface(powerstat, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["reserve"] == "add")
			reserves = input(usr, "Сколько перенести в резерв","ваше значение",reserves) as num
			for(var/obj/electro/battery/B in controlled)
				if(B.powernet == powernet)
					if(reserves < B.full_charge)
						B.full_charge -= reserves
						B.charge += reserves
			attack_hand(usr)
		if(href_list["reserve"] == "remove")
			reserves = input(usr, "Сколько использовать из резерва.","ваше значение",reserves) as num
			for(var/obj/electro/battery/B in controlled)
				if(B.powernet == powernet)
					if(reserves < B.charge)
						B.charge -= reserves
						B.full_charge += reserves
			attack_hand(usr)
		if(href_list["reserve"] == "fulltime")
			reservedfortime	= input(usr, "Сколько автоматически переносить в резерв.","ваше значение",reservedfortime) as num
			attack_hand(usr)
		if(href_list["reserve"] == "ticks")
			ticks = input(usr, "Как быстро переносить в резерв(в секундах).","ваше значение",ticks) as num
			if(ticks > 200)
				ticks = 200
			attack_hand(usr)


/obj/machinery/computer/autolathe
	icon = 'computer.dmi'
	icon_state = "autolathe"
	ru_name = "автолат"
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
	var/list/required_metal = list(1,0,1,1)
	var/list/required_glass = list(0,1,0,0)
	var/list/obj/item/production = list(/obj/item/stack/metal, /obj/item/stack/glass, /obj/item/tools/wrench, /obj/item/staple)
	var/list/production_names = list("лист металла", "лист стекла", "разводной ключ", "скоба")

	robotech_fabricator
		defaultmainboard = /obj/item/mainboard/robotech
		ru_name = "фабрикатор"
		required_metal = list(1,0,1,1,1,1)
		required_glass = list(0,1,1,1,1,1)
		production = list(/obj/item/stack/metal, /obj/item/stack/glass, /obj/item/roboprothesis, /obj/item/roboprothesis/arml, /obj/item/roboprothesis/legl, /obj/item/roboprothesis/legr)
		production_names = list("лист металла", "лист стекла", "протез правой руки", "протез левой руки", "протез левой ноги", "протез правой ноги")

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/screwdriver))
			if(MAINBOARD)
				MAINBOARD.loc = src.loc
				call_message(3, "[usr] вытаскивает [MAINBOARD.ru_name] из [src.ru_name]")
				MAINBOARD = null
		if(istype(I, /obj/item/mainboard))
			if(!MAINBOARD)
				var/obj/machinery/computer/CM = new I:comptype(src.loc)
				call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")
				usr:drop()
				CM.MAINBOARD = I
				I.Move(CM)
				del(src)
		if(istype(I, /obj/item/stack/metal))
			metal += I:amount
			call_message(3, "[usr] вставляет [I:amount] листов металла в [ru_name]")
			M:drop()
			del(I)
		if(istype(I, /obj/item/stack/glass))
			glass += I:amount
			call_message(3, "[usr] вставляет [I:amount] листов стекла в [ru_name]")
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
				descr.Add("[production_names[i]] - требует [required_metal[i]] металла и [required_glass[i]] стекла")

			for(var/d in production)
				myhrefs.Add("production=[d]")

			descr.Add("Металла [metal]; Стекла [glass]")
			myhrefs.Add("null=null")

			M << browse(nterface(descr, myhrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["production"])
			var/mypath = text2path(href_list["production"])
			var/i = 0
			for(var/cr in production)
				i++
				if(cr == mypath && required_metal[i] <= metal && required_glass[i] <= glass && use_power())
					var/atom/A = new mypath(usr.loc)
					call_message(5, "[usr] строит [A.ru_name]")
					metal -= required_metal[i]
					glass -= required_glass[i]

			attack_hand(usr)

/obj/item/device
	icon = 'computer.dmi'
	icon_state = "device_frame"
	ru_name = "устройство"
	var/obj/item/devicemainboard/MAINBOARD
	var/obj/item/devicebattery/DEVICEBATTERY
	var/obj/item/deviceoutput/SPEAKER
	var/mainboardov = 0
	var/batteryov = 0
	var/speakerov = 0
	var/need_voltage = 12
	var/need_amperage = 1
	var/maxVLTAMP = 15
	var/on = 0
	var/broken = 0
	layer = 3

	proc/init()
		MAINBOARD = new(src)
		DEVICEBATTERY = new(src)
		SPEAKER = new(src)
		tocontrol()

	New()
		..()
		init()

	attackby(var/mob/M, var/obj/item/I)
		if(MAINBOARD)
			if(istype(I, /obj/item/tools/screwdriver))
				MAINBOARD.loc = src.loc
				call_message(3, "[usr] вытаскивает [MAINBOARD.ru_name] из [src.ru_name]")
				MAINBOARD = null
				return

		if(DEVICEBATTERY)
			if(istype(I, /obj/item/tools/screwdriver))
				DEVICEBATTERY.loc = src.loc
				call_message(3, "[usr] вытаскивает [SPEAKER.ru_name] из [src.ru_name]")
				DEVICEBATTERY = null
				return

		if(SPEAKER)
			if(istype(I, /obj/item/tools/screwdriver))
				SPEAKER.loc = src.loc
				call_message(3, "[usr] вытаскивает [SPEAKER.ru_name] из [src.ru_name]")
				SPEAKER = null
				return

		if(istype(I, /obj/item/devicemainboard))
			if(!MAINBOARD)
				var/obj/item/device/CM = new I:comptype(src.loc)
				call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")
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
				call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")

		if(istype(I, /obj/item/deviceoutput))
			if(!SPEAKER)
				SPEAKER = I
				M:drop()
				I.Move(src)
				call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")

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
						loc.call_message(5, "[src.ru_name] дымит и искрит. Похоже это устройство сгорело")
						return

					if(DEVICEBATTERY.charge_level < 100)
						loc.call_message(SPEAKER.power, "[src.ru_name] разряжается. Срочно найдите станцию зарядки!")

					DEVICEBATTERY.charge_level--
				else
					on = 0

	attackinhand(var/mob/M)
		if(MAINBOARD && DEVICEBATTERY && SPEAKER)
			if(!broken)
				if(DEVICEBATTERY.charge_level > 0)
					on = !on
					if(on)
						M.call_message(SPEAKER.power, "[src.ru_name] играет мелодию приветствия!")
					if(!on)
						M.call_message(SPEAKER.power, "[src.ru_name] играет мелодию прощания!")

/obj/item/deviceoutput
	icon = 'computer.dmi'
	icon_state = "speaker_device"
	ru_name = "простой динамик"
	layer = 4
	var/power = 3

/obj/item/devicebattery
	icon = 'computer.dmi'
	icon_state = "battery_device"
	ru_name = "простая батарея"
	amperage = 1
	voltage = 12
	var/max_charge = 2000
	var/charge_level = 2000
	layer = 4

/obj/item/devicemainboard
	icon = 'computer.dmi'
	icon_state = "mainboard_device"
	ru_name = "микроплата"
	var/comptype = /obj/item/device
	layer = 4


/obj/item/mainboard
	icon = 'computer.dmi'
	icon_state = "mainboard_computer"
	ru_name = "главная плата"
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
		ru_name = "главная плата инженерного компьютера"
		comptype = /obj/machinery/computer/eng

	autolathe
		icon = 'computer.dmi'
		icon_state = "mainboard_autolathe"
		ru_name = "главная плата автолата"
		comptype = /obj/machinery/computer/autolathe

	robotech
		icon = 'computer.dmi'
		icon_state = "mainboard_robotech"
		ru_name = "главная плата фабрикатора"
		comptype = /obj/machinery/computer/autolathe/robotech_fabricator
/*
	morph
		icon = 'computer.dmi'
		icon_state = "mainboard_morphcomputer"
		ru_name = "главная плата морферкомпьютера"
		comptype = /obj/machinery/computer/morph


/obj/machinery/computer/morph
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "Компьютер управления морфером"
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
			devices.Add("Перенести сознание из [M_C.ru_name] в [N_B.ru_name]")
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
	ru_name = "главная плата гравитационного компьютера"
	comptype = /obj/machinery/computer/gravity

/obj/machinery/computer/gravity
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "гравитационный компьютер"
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
				powerstat.Add(fix1103("Включить/выключить гравитационные ловушки в сети"))
				hrefs.Add("gravity=ok")
				M << browse(nterface(powerstat, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["gravity"] == "ok")
			var/list/obj/machinery/gravity_shield/data = view_all_activity()
			for(var/obj/machinery/gravity_shield/SH in data)
				SH.on = !SH.on