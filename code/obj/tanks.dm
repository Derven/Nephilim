/obj/item/tank
	var/oxygen = 0
	var/plasma = 0
	var/co2 = 0
	icon = 'items.dmi'
	crushing = 4
	cutting = 0
	stitching = 0

	proc/get_pressure()
		return oxygen + plasma + co2

	proc/minus_pressure(var/num)
		if(oxygen > 0)
			oxygen -= num
		if(plasma > 0)
			plasma -= num
		if(co2 > 0)
			co2 -= num

	supertank
		icon_state = "oxygen"
		co2 = 9000
		name = "oxygentank"
		ru_name = "боевой баллон"

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