/obj/item/mainboard/sci
	icon = 'computer.dmi'
	icon_state = "mainboard_sciserver"
	ru_name = "главная плата научного компьютера"
	comptype = /obj/machinery/computer/sci

/obj/machinery/computer/sci
	icon = 'computer.dmi'
	icon_state = "computer_frame"
	ru_name = "научный сервер"
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
	var/list/production_names = list("простой конденсатор", "простой резистор", "простая микросхема")

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
	ru_name = "главная плата научного фабрикатора"
	comptype = /obj/machinery/computer/sci


/obj/machinery/computer/autolathe/sci
	icon = 'computer.dmi'
	ru_name = "научный фабрикатор"
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
	ru_name = "главная плата сборщика плат"
	comptype = /obj/machinery/computer/scieng

/obj/machinery/computer/scieng
	icon = 'computer.dmi'
	icon_state = "scicomp"
	ru_name = "cборщик плат"
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
		stats.Add("Собрать")
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
				call_message(3, "[src] производит [I2.ru_name]")
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

		if(istype(I, /obj/item/stock_parts))
			call_message(3, "[usr] вставляет [I.ru_name] в [ru_name]")
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
		ru_name = "простой конденсатор"

		advanced_capacitor
			scilevel = 2
			scitype = "capacitor"
			icon_state = "capacitor_2"
			ru_name = "продвинутый конденсатор"

	resistor
		scilevel = 1
		scitype = "resistor"
		icon_state = "resistor_1"
		ru_name = "простой резистор"

		advanced_resistor
			scilevel = 2
			scitype = "resistor"
			icon_state = "resistor_2"
			ru_name = "продвинутый резистор"

	chip
		scilevel = 1
		scitype = "chip"
		icon_state = "chip_1"
		ru_name = "простой чип"

		advanced_chip
			scilevel = 2
			scitype = "chip"
			icon_state = "chip_2"
			ru_name = "продвинутый чип"

proc/check_recipe(var/list/obj/item/list1)
	var/list/datum/sci_recipes/recipes = get_recipes()
	world << "debug"
	for(var/recipe in recipes)
		world << "debug2"
		var/datum/sci_recipes/SCI = new recipe()
		if(SCI:check_recipes(list1))
			return SCI


proc/get_recipes()
	return typesof(/datum/sci_recipes)

/datum/sci_recipes
	name = "рецепт"
	var/obj/item/result
	var/list/obj/item/parts = list(/area)
	var/quality = 0

	proc/check_recipes(var/list/LIST)
		var/ok = 0
		world << "debug4"
		var/list/obj/item/LIST2 = LIST.Copy()
		for(var/part in parts)
			for(var/unit in LIST)
				world << "[part]:[unit:type]"
				if(ispath(unit:type, part))
					ok++
					LIST.Remove(unit)
					world << ok
		LIST = LIST2.Copy()
		if(ok == length(parts))
			return src

/datum/sci_recipes/advanced_resistor
	name = "продвинутый резистор"
	result = /obj/item/stock_parts/resistor/advanced_resistor
	parts = list(/obj/item/stock_parts/resistor, /obj/item/stock_parts/resistor, /obj/item/stock_parts/resistor)

/datum/sci_recipes/advanced_capacitor
	name = "продвинутый конденсатор"
	result = /obj/item/stock_parts/capacitor/advanced_capacitor
	parts = list(/obj/item/stock_parts/capacitor, /obj/item/stock_parts/capacitor, /obj/item/stock_parts/capacitor)

/datum/sci_recipes/advanced_chip
	name = "продвинутый чип"
	result = /obj/item/stock_parts/chip/advanced_chip
	parts = list(/obj/item/stock_parts/resistor, /obj/item/stock_parts/capacitor, /obj/item/stock_parts/chip)

/datum/sci_recipes/battery
	name = "small custom battery"
	result = /obj/item/devicebattery/custom
	parts = list(/obj/item/stock_parts/capacitor/advanced_capacitor, /obj/item/stock_parts/capacitor/advanced_capacitor, /obj/item/stock_parts/chip)

/obj/item/devicebattery/custom
	icon = 'computer.dmi'
	icon_state = "battery_device"
	ru_name = "простая батарея"
	amperage = 1
	voltage = 12
	max_charge = 2000
	charge_level = 2000
	layer = 4

	New()
		..()
		spawn(30)
			max_charge = 100 * scilevel
			charge_level = 100 * scilevel
			if(max_charge < 2000)
				color = "red"
			else
				color = "green"