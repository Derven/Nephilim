/mob/living/human
	proc/cry(var/time)
		while(time > 0)
			time--
			sleep(rand(1,2))
			for(var/obj/item/organ/O in src)
				if(istype(O, /obj/item/organ/eyes) && O.muscle.health >= 50)
					var/obj/hud/HUD = get_slot("blind", src)
					if(HUD)
						HUD.icon_state = pick("blind_1", "blind_2")
					call_message(5, "<font size='3' color='#696969'>глаза [src] слезятся ")

	proc/interact_withorgan(var/obj/item/I, var/zone, var/mob/M)
		var/obj/item/organ/O
		for(var/obj/item/organ/ORGAN in src)
			if(ORGAN.damagezone_to_organ(zone) != null)
				O = ORGAN.damagezone_to_organ(zone)
				O.attackby(M, I)

	proc/impactdamage(var/damage, var/zone)
		if(zone == null)
			for(var/obj/item/organ/O in src)
				if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
					if(istype(O, /obj/item/organ/eyes))
						continue
					if(O.skin.name)
						O.skin.physical_damage += round(damage / 2)
					if(O.bone.name)
						O.bone.physical_damage += round(damage)
					O.muscle.physical_damage += round(damage / 2)
				else
					O.muscle.physical_damage += round(damage / 2)
		else
			for(var/obj/item/organ/O in src)
				if(O.damagezone_to_organ(zone) != null)
					if(O.skin.name)
						O.skin.physical_damage += round(damage / 2)
					if(O.bone.name)
						O.bone.physical_damage += round(damage)
					O.muscle.physical_damage += round(damage / 2)

	collisionBumped(var/speeedwagon, var/zone)
		impactdamage(speeedwagon, zone)


	proc/chemdamage(var/damage)
		switch(damage)
			if(0 to LITE_CHEM)
				return 0
			if(LITE_CHEM to MEDIUM_CHEM)
				for(var/obj/item/organ/O in src)
					if(O.skin.name)
						O.skin.chem_damage += round(damage / 20)
					O.muscle.chem_damage += round(damage / 20)
				call_message(5, "[src] получает небольшой химический ожог")

			if(MEDIUM_CHEM to HARD_CHEM)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.chem_damage += round(damage / 15)
						O.muscle.chem_damage += round(damage / 15)
					else
						O.muscle.chem_damage += round(damage / 100)
						sleep(7)
						if(prob(99))
							O.muscle.chem_damage += 99
				call_message(5, "[src] получает серьезный химический ожог")

			if(HARD_CHEM to 999999999)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.chem_damage +=  round(damage / 10)
						O.muscle.chem_damage += round(damage / 10)
					else
						O.muscle.chem_damage += round(damage / 150)
						sleep(7)
						if(prob(99))
							O.muscle.chem_damage += 99
				call_message(5, "[src] получает невероятный химический ожог")

		return 0

	proc/powerdamage(var/damage)
		stuned += round(damage)
		switch(damage)
			if(0 to LITE_UDAR)
				return 0
			if(LITE_UDAR to MEDIUM_UDAR)
				for(var/obj/item/organ/O in src)
					if(O.skin.name)
						O.skin.temp_damage += round(damage / 20)
					O.muscle.temp_damage += round(damage / 20)
				call_message(5, "[src] бьет легкий удар тока")

			if(MEDIUM_UDAR to HARD_UDAR)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.temp_damage += round(damage / 15)
						O.muscle.temp_damage += round(damage / 15)
					else
						O.muscle.temp_damage += round(damage / 100)
						sleep(7)
						if(prob(99))
							O.muscle.temp_damage += 99
				call_message(5, "[src] бьет серьезный удар тока, возможно он уже мертв")

			if(HARD_UDAR to 999999999)
				for(var/obj/item/organ/O in src)
					if(!istype(O, /obj/item/organ/lungs) && !istype(O, /obj/item/organ/heart))
						if(O.skin.name)
							O.skin.temp_damage += round(damage / 10)
						O.muscle.temp_damage += round(damage / 10)
					else
						O.muscle.temp_damage += round(damage / 150)
						sleep(7)
						if(prob(99))
							O.muscle.temp_damage += 99
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
						O.bone.physical_damage += bonus + I.crushing * 1.5 - O.def * 0.8
				if(O.skin)
					if(attacker.punch_intent == PANCHSBOKY)
						bonus += 0.3
					if(I.crushing * 0.2 - O.def * 2 > 0)
						O.skin.physical_damage += bonus + I.crushing * 0.2 - O.def * 2

				if(O.muscle)
					if(attacker.punch_intent == PANCHSBOKY)
						bonus += 2
					if(attacker.punch_intent == PANCHSVERHU)
						bonus += 1
					if(I.crushing * 0.7 - O.def * 0.5 > 0)
						O.muscle.physical_damage += bonus + I.crushing * 0.7 - O.def * 0.5
						if(O.name == "thorax")
							if(I.crushing + bonus > 10)
								for(var/obj/item/organ/heart/H in src)
									H.muscle.physical_damage += round(I.crushing / 10)
								for(var/obj/item/organ/lungs/L in src)
									L.muscle.physical_damage += round(I.crushing / 8)
						if(O.name == "chest")
							for(var/obj/item/organ/stomach/H in src)
								H.muscle.physical_damage += round(I.crushing / 10)
						if(O.name == "head")
							if(prob(40))
								O.ARTERIAL.opened = 1
							if(prob(40))
								O.VENOS.opened = 1
				//режущий урон
				if(O.bone)
					if(I.cutting * 0.2 - O.def * 2 > 0)
						O.bone.physical_damage += bonus + I.cutting * 0.2 - O.def * 2
				if(O.skin)
					if(attacker.punch_intent == PANCHSBOKY)
						bonus += 2
					if(attacker.punch_intent == PANCHSNIZY)
						bonus += 3
					if(I.cutting * 2 - O.def * 0.2 > 0)
						O.skin.physical_damage += bonus + I.cutting * 2 - O.def * 0.2

				if(O.muscle)
					if(attacker.punch_intent == PANCHSBOKY)
						bonus += 4
					if(attacker.punch_intent == PANCHSNIZY)
						bonus += 5
					if(I.cutting * 1.2 - O.def * 0.3 > 0)
						O.skin.physical_damage += bonus + I.cutting * 1.2 - O.def * 0.3
						if(prob(25))
							O.ARTERIAL.opened = 1
						if(prob(25))
							O.VENOS.opened = 1
						if(O.name == "thorax")
							if(I.cutting + bonus > 10)
								for(var/obj/item/organ/heart/H in src)
									H.muscle.physical_damage += round(I.cutting / 12)
								for(var/obj/item/organ/lungs/L in src)
									L.muscle.physical_damage += round(I.cutting / 10)
						if(O.name == "head")
							for(var/obj/item/organ/tongue/T in src)
								T.muscle.physical_damage += round(I.cutting / 8)
						if(O.name == "chest")
							for(var/obj/item/organ/stomach/H in src)
								H.muscle.physical_damage += round(I.cutting / 10)
				//колющий урон
				if(O.skin)
					if(attacker.punch_intent == UKOL)
						bonus += 2
					if(I.stitching * 0.2 - O.def * 2 > 0)
						O.skin.physical_damage += bonus + I.stitching * 2 - O.def * 0.2

				if(O.muscle)
					if(attacker.punch_intent == UKOL)
						bonus += 8
					if(I.stitching * 3 - O.def * 0.3 > 0)
						O.skin.physical_damage += bonus + I.stitching * 3 - O.def * 0.3
						if(prob(5))
							O.VENOS.opened = 1
						if(prob(5))
							O.ARTERIAL.opened = 1
						if(O.name == "thorax")
							if(I.stitching + bonus > 10)
								for(var/obj/item/organ/heart/H in src)
									H.muscle.physical_damage += round(I.stitching / 4)
								for(var/obj/item/organ/lungs/L in src)
									L.muscle.physical_damage += round(I.stitching / 6)

						if(O.name == "head")
							if(I.stitching + bonus > 5)
								if(eyes)
									eyes.muscle.physical_damage += I.stitching + bonus
							for(var/obj/item/organ/tongue/T in src)
								T.muscle.physical_damage += round(I.stitching / 12)

						if(O.name == "chest")
							for(var/obj/item/organ/stomach/H in src)
								H.muscle.physical_damage += round(I.stitching / 10)