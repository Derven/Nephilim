/obj/item/mainboard/sci
	icon = 'computer.dmi'
	icon_state = "mainboard_sciserver"
	ru_name = "������� ����� �������� ����������"
	comptype = /obj/machinery/computer/sci

/obj/machinery/computer/sci
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "������� ������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/ticks = 1
	defaultmainboard = /obj/item/mainboard/sci
	var/list/required_metal = list(1,1,1)
	var/list/required_glass = list(1,1,1)
	var/list/obj/item/production = list(/obj/item/stock_parts/capacitor, /obj/item/stock_parts/resistor, /obj/item/stock_parts/chip)
	var/list/production_names = list("������� �����������", "������� ��������", "������� ����������")

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

/obj/item/mainboard/scisautholate
	icon = 'computer.dmi'
	icon_state = "mainboard_scisautholate"
	ru_name = "������� ����� �������� �����������"
	comptype = /obj/machinery/computer/sci


/obj/machinery/computer/autolathe/sci
	icon = 'computer.dmi'
	ru_name = "������� ����������"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	easy_deconstruct = 1
	max_VLTAMP = 5000
	defaultmainboard = /obj/item/mainboard/scisautholate

	process()
		for(var/obj/machinery/computer/sci/SCI in controlled)
			if(SCI.powernet == powernet)
				required_metal = SCI.required_metal
				required_glass = SCI.required_glass
				production = SCI.production
				production_names = SCI.production_names

		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()

/obj/item/mainboard/scieng
	icon = 'computer.dmi'
	icon_state = "mainboard_scieng"
	ru_name = "������� ����� �������� ����"
	comptype = /obj/machinery/computer/scieng

/obj/machinery/computer/scieng
	icon = 'computer.dmi'
	icon_state = "scicomp"
	ru_name = "c������ ����"
	anchored = 1
	density = 1
	layer = 3
	need_voltage = 10
	need_amperage = 2
	construct_parts = list(/obj/item/unconnected_cable, /obj/item/stack/glass, /obj/item/stack/metal)
	defaultmainboard = /obj/item/mainboard/scieng
	easy_deconstruct = 1
	max_VLTAMP = 5000
	var/ticks = 1
	var/list/obj/item/components = list()

	attack_hand(var/mob/M)
		M << browse(null,"window=[name]")
		var/list/hrefs = list()
		var/list/stats = list()
		for(var/obj/item/I in components)
			stats.Add("[I.ru_name]")
			hrefs.Add("remove=\ref[I]")
		stats.Add("�������")
		hrefs.Add("ok=build")
		if(okinterface() && use_power())
			M << browse(nterface(stats, hrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["remove"])
			var/obj/item/I = locate(href_list["remove"])
			I.loc = src.loc
			components.Remove(I)
		if(href_list["ok"] == "build")
			var/datum/sci_recipes/SCI = check_recipe(components)
			if(SCI)
				var/scilevel = 0
				for(var/obj/item/I in components)
					for(var/part in SCI.parts)
						if(ispath(I:type, part))
							scilevel += I.scilevel
							components.Remove(I)

				var/obj/item/I2 = new SCI.result(src.loc)
				call_message(3, "[src] ���������� [I2.ru_name]")
				if(SCI.quality)
					I2.scilevel += scilevel

				for(var/obj/machinery/computer/sci/SCICOMP in controlled)
					if(SCICOMP.powernet == powernet)
						if(!(I2.type in SCICOMP.production))
							SCICOMP.production.Add(I2.type)
							SCICOMP.required_metal.Add(I2.require_metal)
							SCICOMP.required_glass.Add(I2.require_glass)
							SCICOMP.production_names.Add(I2.ru_name)
			attack_hand(usr)

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

		if(istype(I, /obj/item/stock_parts))
			call_message(3, "[usr] ��������� [I.ru_name] � [ru_name]")
			usr:drop()
			components.Add(I)
			I.Move(src)

	process()
		if(MAINBOARD)
			if(checkoverlay == 0)
				overlays.Add(MAINBOARD)
				checkoverlay = 1
			use_power()
		else
			overlays.Cut()
			//nocontrol()


//stock parts
/obj/item
	var/scilevel = 0
	var/require_metal = 1
	var/require_glass = 1

/obj/item/stock_parts
	var/scitype = "no"
	icon = 'sci.dmi'

	capacitor
		scilevel = 1
		scitype = "capacitor"
		icon_state = "capacitor_1"
		ru_name = "������� �����������"

		advanced_capacitor
			scilevel = 2
			scitype = "capacitor"
			icon_state = "capacitor_2"
			ru_name = "����������� �����������"

	resistor
		scilevel = 1
		scitype = "resistor"
		icon_state = "resistor_1"
		ru_name = "������� ��������"

		advanced_resistor
			scilevel = 2
			scitype = "resistor"
			icon_state = "resistor_2"
			ru_name = "����������� ��������"

	chip
		scilevel = 1
		scitype = "chip"
		icon_state = "chip_1"
		ru_name = "������� ���"

		advanced_chip
			scilevel = 2
			scitype = "chip"
			icon_state = "chip_2"
			ru_name = "����������� ���"

proc/check_recipe(var/list/obj/item/list1)
	var/ok = 0
	for(var/SCI in typesof(/datum/sci_recipes))
		var/datum/sci_recipes/SCI1 = new SCI()
		var/list/LIST = list1.Copy()
		for(var/part in SCI1.parts)
			for(var/obj/item/l1 in list1)
				if(ispath(l1:type, part))
					ok++
					list1.Remove(l1)
					if(ok == length(SCI1.parts))
						list1 = LIST.Copy()
						return SCI1

/datum/sci_recipes
	name = "������"
	var/obj/item/result
	var/list/obj/item/parts = list()
	var/quality = 0

/datum/sci_recipes/advanced_resistor
	name = "����������� ��������"
	result = /obj/item/stock_parts/resistor/advanced_resistor
	parts = list(/obj/item/stock_parts/resistor, /obj/item/stock_parts/resistor, /obj/item/stock_parts/resistor)

/datum/sci_recipes/advanced_capacitor
	name = "����������� �����������"
	result = /obj/item/stock_parts/capacitor/advanced_capacitor
	parts = list(/obj/item/stock_parts/capacitor, /obj/item/stock_parts/capacitor, /obj/item/stock_parts/capacitor)

/datum/sci_recipes/advanced_chip
	name = "����������� ���"
	result = /obj/item/stock_parts/chip/advanced_chip
	parts = list(/obj/item/stock_parts/resistor, /obj/item/stock_parts/capacitor, /obj/item/stock_parts/chip)