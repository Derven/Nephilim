/mob/living/human
	proc/powerdamage(var/damage)
		switch(damage)
			if(0 to LITE_UDAR)
				return 0
			if(LITE_UDAR to MEDIUM_UDAR)
				for(var/obj/item/organ/O in src)
					if(O.skin.name)
						O.skin.health -= round(damage / 20)
					O.muscle.health -= round(damage / 20)
				call_message(5, "[src] бьет легкий удар тока")

			if(MEDIUM_UDAR to HARD_UDAR)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.health -= round(damage / 15)
						O.muscle.health -= round(damage / 15)
					else
						O.muscle.health -= round(damage / 100)
						sleep(7)
						if(prob(99))
							O.muscle.health -= 99
				call_message(5, "[src] бьет серьезный удар тока, возможно он уже мертв")

			if(HARD_UDAR to 999999999)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.health -= round(damage / 10)
						O.muscle.health -= round(damage / 10)
					else
						O.muscle.health -= round(damage / 150)
						sleep(7)
						if(prob(99))
							O.muscle.health -= 99
				call_message(5, "[src] поджаривает на месте. С хрустящей корочкой")

		return 0

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