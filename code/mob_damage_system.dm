/mob/living/human
	proc/attack_organ(var/obj/item/I, var/zone, var/mob/living/human/attacker)
		var/obj/item/organ/O
		for(var/obj/item/organ/ORGAN in src)
			if(ORGAN.damagezone_to_organ(zone) != null)
				O = ORGAN.damagezone_to_organ(zone)

		var/bonus = 0
		//дробящий урон

		if(O.bone)
			if(attacker.punch_intent == PANCHSBOKY)
				bonus += 3
			if(attacker.punch_intent == PANCHSVERHU)
				bonus += 4
			if(I.crushing * 1.5 - O.def * 0.8 > 0)
				O.bone.health -= bonus + I.crushing * 1.5 - O.def * 0.8
		if(O.skin)
			if(attacker.punch_intent == PANCHSBOKY)
				bonus += 0.3
			if(I.crushing * 0.2 - O.def * 2 > 0)
				O.skin.health -= bonus + I.crushing * 0.2 - O.def * 2

		if(O.muscle)
			if(attacker.punch_intent == PANCHSBOKY)
				bonus += 2
			if(attacker.punch_intent == PANCHSVERHU)
				bonus += 1
			if(I.crushing * 0.7 - O.def * 0.5 > 0)
				O.muscle.health -= bonus + I.crushing * 0.7 - O.def * 0.5
				if(name == "chest")
					if(I.crushing + bonus > 10)
						for(var/obj/item/organ/heart/H in src)
							H.muscle.health -= round(I.crushing / 10)
						for(var/obj/item/organ/lungs/L in src)
							L.muscle.health -= round(I.crushing / 8)


		//режущий урон
		if(O.bone)
			if(I.cutting * 0.2 - O.def * 2 > 0)
				O.bone.health -= bonus + I.cutting * 0.2 - O.def * 2
		if(O.skin)
			if(attacker.punch_intent == PANCHSBOKY)
				bonus += 2
			if(attacker.punch_intent == PANCHSNIZY)
				bonus += 3
			if(I.cutting * 2 - O.def * 0.2 > 0)
				O.skin.health -= bonus + I.cutting * 2 - O.def * 0.2

		if(O.muscle)
			if(attacker.punch_intent == PANCHSBOKY)
				bonus += 4
			if(attacker.punch_intent == PANCHSNIZY)
				bonus += 5
			if(I.cutting * 1.2 - O.def * 0.3 > 0)
				O.skin.health -= bonus + I.cutting * 1.2 - O.def * 0.3

				if(name == "chest")
					if(I.cutting + bonus > 10)
						for(var/obj/item/organ/heart/H in src)
							H.muscle.health -= round(I.cutting / 12)
						for(var/obj/item/organ/lungs/L in src)
							L.muscle.health -= round(I.cutting / 10)

		//колющий урон
		if(O.skin)
			if(attacker.punch_intent == UKOL)
				bonus += 2
			if(I.stitching * 0.2 - O.def * 2 > 0)
				O.skin.health -= bonus + I.stitching * 2 - O.def * 0.2

		if(O.muscle)
			if(attacker.punch_intent == UKOL)
				bonus += 8
			if(I.stitching * 3 - O.def * 0.3 > 0)
				O.skin.health -= bonus + I.stitching * 3 - O.def * 0.3

				if(name == "chest")
					if(I.stitching + bonus > 10)
						for(var/obj/item/organ/heart/H in src)
							H.muscle.health -= round(I.stitching / 4)
						for(var/obj/item/organ/lungs/L in src)
							L.muscle.health -= round(I.stitching / 6)