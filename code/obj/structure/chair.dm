/obj/structure
	icon = 'structure.dmi'

/obj/structure/chair
	icon_state = "chair"
	anchored = 0

	attack_hand(var/mob/M)
		for(var/mob/M2 in src.loc)
			call_message(3, "[M2] [M2.buckled ? "отстегивается от" : "пристегивается к"] стулу(а).")
			if(transportid != -1)
				if(!M2.buckled)
					M2.transportid = transportid
				else
					M2.transportid = -1
			M2.buckled = !M2.buckled
			M2.dir = dir