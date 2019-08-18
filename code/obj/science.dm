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

//stock parts
/obj/item/stock_parts
	var/scilevel = 1
	var/scitype = "no"
	icon = 'sci.dmi'
	var/require_metal = 1
	var/require_glass = 1

	capacitor
		scilevel = 1
		scitype = "capacitor"
		icon_state = "capacitor_1"

	resistor
		scilevel = 1
		scitype = "resistor"
		icon_state = "resistor_1"

	chip
		scilevel = 1
		scitype = "chip"
		icon_state = "chip_1"