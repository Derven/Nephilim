/obj/structure/ladder_up
	icon = 'structure.dmi'
	icon_state = "ladder_up"

	attack_hand(var/mob/M)
		call_message(3, "[M] ����������� �� ��������")
		M.z++

/obj/structure/ladder_down
	icon = 'structure.dmi'
	icon_state = "ladder_down"

	attack_hand(var/mob/M)
		call_message(3, "[M] ���������� �� ��������")
		M.z--