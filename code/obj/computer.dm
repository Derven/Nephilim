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