/obj/structure/ladder_up
	icon = 'structure.dmi'
	icon_state = "ladder_up"
	anchored = 1

	attack_hand(var/mob/M)
		call_message(3, "[M] поднимается по лестнице")
		M.z++

/obj/structure/ladder_down
	icon = 'structure.dmi'
	icon_state = "ladder_down"
	anchored = 1

	attack_hand(var/mob/M)
		call_message(3, "[M] опускается по лестнице")
		M.z--