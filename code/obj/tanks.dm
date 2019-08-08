/obj/item/tank
	var/oxygen = 0
	var/plasma = 0
	var/co2 = 0
	icon = 'items.dmi'
	crushing = 4
	cutting = 0
	stitching = 0

	oxygen
		icon_state = "oxygen"
		oxygen = 900
		name = "oxygentank"
		ru_name = "кислородный баллон"

	plasma
		icon_state = "plasma"
		oxygen = 0
		plasma = 900
		name = "plasmatank"
		ru_name = "баллон c плазмой"