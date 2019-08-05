/obj/machinery
	var/on = 0

/obj/machinery/airlock
	icon = 'icons/airlock.dmi'
	icon_state = "door_1"
	density = 1
	opacity = 1
	block_air = 1
	anchored = 1
	var/door_state = "door"
	var/open = 1

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
		call_message(3, "Дверь [open == 1 ? "открылась" : "закрылась"]")
		open()