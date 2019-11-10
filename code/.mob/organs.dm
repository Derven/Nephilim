#define NO_DAMAGE 0
#define LIGHT_DAMAGE 1
#define MEDIUM_DAMAGE 2
#define HARD_DAMAGE 3

/datum/bone
	var/health = 150
	var/broken = 0
	name = "bone"
	var/physical_damage = 0
	robo
		health = 300

/datum/muscle
	var/health = 100
	name = "muscle"
	var/damagedstate = ""
	var/physical_damage = 0
	var/temp_damage = 0
	var/chem_damage = 0

	robo
		health = 200

/datum/organ
	var/health = 120
	var/physical_damage = 0
	var/temp_damage = 0
	var/chem_damage = 0
	name = "organ"
	proc/myfunc()
		return 0

/datum/skin
	name = "skin"
	var/health = 60
	var/damagedstate = ""
	var/physical_damage = 0
	var/temp_damage = 0
	var/chem_damage = 0
	robo
		health = 120

/datum/atrerial
	var/opened = 0

/datum/venos
	var/opened = 0

/obj/item/organ
	icon = 'human.dmi'
	name = "organ"
	ru_name = ""
	icon = 'human.dmi'
	var/datum/bone/bone
	var/datum/muscle/muscle
	var/datum/skin/skin
	var/damage_level = NO_DAMAGE
	var/mob/living/human/owner
	var/temp_factor = 0.2
	var/def = 0 //защита одеждой и другими факторами
	var/scalped = 0
	var/silicon = 0
	var/datum/atrerial/ARTERIAL
	var/datum/venos/VENOS
	layer = 5

	var/list/obj/hud/IHUD = list()

	attackby(var/mob/M, var/obj/item/I)
		if(!istype(src, /obj/item/organ/chest) && !istype(src, /obj/item/organ/head))
			if(istype(I, /obj/item/tools/scalpel))
				scalped = 1
				loc.call_message(5, "на [ru_name] появляются надрезы")
			if(istype(I, /obj/item/tools/cauterizer))
				if(scalped)
					scalped = !scalped
					loc.call_message(5, "рана на [ru_name] прижигается")
			if(istype(I, /obj/item/tools/saw))
				if(scalped)
					var/obj/item/organ/O = new src.type(owner.loc)

					O.muscle.health = initial(muscle.health) - muscle.physical_damage - muscle.temp_damage - muscle.chem_damage
					O.skin.health = initial(skin.health) - skin.physical_damage - skin.temp_damage - skin.chem_damage
					O.bone.health = initial(bone.health) - bone.physical_damage

					O.transform = turn(src.transform, rand(0,170))
					del_hud()
					if(istype(src, /obj/item/organ/rleg) || istype(src, /obj/item/organ/lleg))
						if(!owner.rest)
							owner:rest()
					call_message(5, "[ru_name] отваливается и падает на пол")
					del(src)
		else
			if(istype(src, /obj/item/organ/chest))
				if(istype(I, /obj/item/roboprothesis))
					switch(I:type_of_prothesis)
						if("larm")
							if(!owner.left_arm)
								owner.left_arm = new /obj/item/organ/larm/roboarm(owner)
								M:drop()
								del(I)
						if("rarm")
							if(!owner.right_arm)
								owner.right_arm = new /obj/item/organ/rarm/roboarm(owner)
								M:drop()
								del(I)
						if("rleg")
							if(!owner.right_leg)
								owner.right_leg = new /obj/item/organ/rleg/roboleg(owner)
								M:drop()
								del(I)
						if("lleg")
							if(!owner.left_leg)
								owner.left_leg = new /obj/item/organ/lleg/roboleg(owner)
								M:drop()
								del(I)

	proc/damagezone_to_organ(var/zone)
		switch(zone)
			if("damage_chest")
				if(name == "chest")
					return src

			if("damage_thorax")
				if(name == "thorax")
					return src

			if("damage_head")
				if(name == "head")
					return src

			if("damage_rarm")
				if(name == "r_arm")
					return src

			if("damage_larm")
				if(name == "l_arm")
					return src

			if("damage_lleg")
				if(name == "l_leg")
					return src

			if("damage_rleg")
				if(name == "r_leg")
					return src
			else
				return null

	New()
		init()
		..()
		ARTERIAL = new /datum/atrerial()
		VENOS = new /datum/venos()
		if(length(IHUD) > 0)
			create_hud()

	proc/create_hud()
		if(owner)
			for(var/hud in IHUD)
				spawn(2)
					if(owner.client)
						new hud(owner.client)
	proc/del_hud()
		if(owner && owner.client)
			for(var/obj/hud/H in owner.client.screen)
				for(var/hud in IHUD)
					if(H.type == hud)
						if(H.SLOT != null)
							owner.call_message(3, "[H.SLOT.ru_name] падает с поврежденного(ой) [ru_name]")
							H.remove_from_slot(owner, owner.loc)
						owner.client.screen.Remove(H)
	proc/init()
		return 0

	proc/check_temperature()
		if(istype(owner.loc, /turf))
			var/obj/hud/temp/HUD = owner.get_slot("temp", owner)
			if(HUD)
				HUD.check_temp(owner.loc:temperature)
			if(owner.loc:temperature - owner.bodytemp > 40)
				if((speed_of_zamerzanie + temp_factor) - owner.clothes_temperature_def + owner:DNA.temp_defense > 0)
					owner.bodytemp += round(owner.loc:temperature - owner.bodytemp / (speed_of_zamerzanie + temp_factor)) - owner.clothes_temperature_def
			if(owner.loc:temperature - owner.bodytemp < -20)
				if((speed_of_zamerzanie + temp_factor) - owner.clothes_temperature_def + owner:DNA.temp_defense > 0)
					owner.bodytemp -= round(owner.loc:temperature - owner.bodytemp / (speed_of_zamerzanie + temp_factor)) + owner.clothes_temperature_def

			if( (owner.loc:temperature - owner.bodytemp < -30 && owner.clothes_temperature_def + owner:DNA.temp_defense < speed_of_zamerzanie + temp_factor))
				if(silicon == 0)
					muscle.temp_damage += rand(5,10) - owner.clothes_temperature_def
					skin.temp_damage += rand(1,3) - owner.clothes_temperature_def

			if( (owner.loc:temperature - owner.bodytemp >= 90 && owner.clothes_temperature_def + owner:DNA.temp_defense < speed_of_zamerzanie + temp_factor) || owner.bodytemp > 50)
				if(silicon == 0)
					muscle.temp_damage += rand(5,10) - owner.clothes_temperature_def
					skin.temp_damage += rand(1,3) - owner.clothes_temperature_def

	process(var/image/oskin, var/image/omuscle, var/image/obone)
		if(owner)

			muscle.health = initial(muscle.health) - (muscle.physical_damage + muscle.temp_damage + muscle.chem_damage)
			skin.health = initial(skin.health) - (skin.physical_damage + skin.temp_damage + skin.chem_damage)
			bone.health = initial(bone.health) - bone.physical_damage

			if(prob((rand(0,2) - owner:DNA.pain_sensitive) * 35))
				if(owner:oheart)
					if(owner:oheart.temp < 120)
						check_pain()

			check_temperature()

			if(ARTERIAL)
				if(ARTERIAL.opened)
					owner.reagents.remove_reagent("blood", 4)
					new /obj/effect/blood(owner.loc)

			if(VENOS)
				if(VENOS.opened)
					owner.reagents.remove_reagent("blood_ven", 2)
					new /obj/effect/blood(owner.loc)

			if(istype(src, /obj/item/organ/heart))
				if(src:muscle.health > 0)
					src:temp = ((100 - src:muscle.health) / 3) + rand(40,63) + src:bonus
					if(prob(25))
						src:bonus--
				else
					src:temp = 0
				spawn(src:temp)
					owner.reagents.remove_reagent("blood_ven", 2)
					owner.reagents.add_reagent("blood", 2)

				if(src:temp > 185)
					src:muscle.physical_damage += src:temp

			if(istype(src, /obj/item/organ/lleg) || istype(src, /obj/item/organ/rleg))
				if(src.bone.broken)
					src:speeding = rand(-1,0)
					if(prob(35))
						if(!owner:rest)
							owner:rest()

			if(istype(src, /obj/item/organ/chest))
				if(src.bone.broken)
					if(!owner:rest)
						owner:rest()

			if(istype(src, /obj/item/organ/thorax))
				if(src.bone.broken)
					if(prob(25))
						owner.oxyloss += rand(2,5)

			if(istype(src, /obj/item/organ/head))
				if(src.bone.broken)
					if(prob(35))
						if(!owner:rest)
							owner:rest()
					if(prob(25))
						if(owner.client)
							owner.client.shakecamera()
					if(prob(15))
						owner.health--

			if(istype(src, /obj/item/organ/eyes))
				if(muscle.health < 50 && owner:DNA.eyes < 2)
					var/obj/hud/HUD = owner.get_slot("blind", owner)
					if(HUD)
						HUD.icon_state = "blind_1"
				else
					var/obj/hud/HUD = owner.get_slot("blind", owner)
					if(HUD)
						HUD.icon_state = "blind_0"

			if(istype(src, /obj/item/organ/lungs))
				var/obj/hud/oxy/HUD = owner.get_slot("oxy", owner)
				if(HUD)
					HUD.check_oxy(owner.oxyloss)
				if(!owner.oxygen_tank)
					if(istype(owner.loc, /turf))
						if(istype(owner.loc, /turf/floor))
							if(prob(rand(1,3)))
								if(owner.reagents.get_reagent_amount("oxygen") > 0)
									owner.loc.reagents.add_reagent("hydrogen", 1)
									owner.reagents.remove_reagent("oxygen", 1)
							if(owner.loc:reagents.get_master_reagent_state() == LIQUID && !owner:DNA.jabre)
								owner.oxyloss = 300
								if(prob(10))
									owner.call_message(5, "[owner] захлебывается ")

						if((owner.loc:reagents.get_reagent_amount(owner:DNA.breath_type) < 20 || owner.loc:reagents.get_reagent_amount("plasma") > 20 || owner.loc:reagents.get_reagent_amount("water") > 50) && owner.oxyloss < 100)
							owner.oxyloss += 1
							if(prob(2))
								owner.call_message(5, "[owner] кашляет")
						else
							owner.oxyloss -= 1
					else
						owner.oxyloss += 1
				else
					if(owner)
						if(owner.get_slot("tank", owner))
							if(((owner.get_slot("tank", owner):SLOT:oxygen < 20 && owner:DNA.breath_type == "oxygen") || owner.get_slot("tank", owner):SLOT:plasma > 20) && owner.oxyloss < 100)
								owner.oxyloss += 1
								if(prob(2))
									owner.call_message(5, "[owner] кашляет")
							else
								var/obj/item/tank/T = owner.get_slot("tank", owner):SLOT
								T:oxygen -= 1
								owner.oxyloss -= 1


				if(owner.oxyloss >= 100)
					if(prob(owner.oxyloss / 5))
						owner.call_message(5, "[owner] задыхается ")
						owner.health -= rand(1,5)

				if(src:muscle.health <= 30)
					owner.call_message(5, "[owner] кашляет")

	proc/check_skin()
		var/image/oskin
		if(owner)
			switch(skin.health)
				if(15 to 3000)
					oskin = image(icon = 'icons/human.dmi',icon_state = "[skin.istate]",layer = owner.layer + 2)
				if(5 to 15)
					oskin = image(icon = 'icons/human.dmi',icon_state = "[skin.damagedstate]",layer = owner.layer + 2)
				if(-999 to 5)
					oskin = image(icon = 'icons/human.dmi',icon_state = "null",layer = owner.layer + 2)
			if(owner:DNA.metabolism > 0)
				if(skin.health < initial(skin.health))
					if(skin.physical_damage >= 5)
						skin.physical_damage -= owner:DNA.metabolism * rand(1,4) + round(owner:oheart.temp / 100)
					if(skin.temp_damage >= 5)
						skin.temp_damage -= owner:DNA.metabolism * rand(1,4) + round(owner:oheart.temp / 100)
					if(skin.chem_damage >= 5)
						skin.chem_damage -=  owner:DNA.metabolism * rand(1,4) + round(owner:oheart.temp / 100)
					if(owner:ostomach)
						owner:ostomach.hungry += owner:DNA.metabolism
					else
						owner.health--
			return oskin

	proc/check_muscle()
		var/image/omuscle
		if(owner)
			if(owner.get_slot("[name]_muscle", owner))
				owner.get_slot("[name]_muscle", owner):overlays.Cut()
				if(ARTERIAL.opened)
					owner.get_slot("[name]_muscle", owner):overlays.Add(image(icon = 'zone.dmi',icon_state = "[name]_arterial_damaged",layer = 28))
				if(VENOS.opened)
					owner.get_slot("[name]_muscle", owner):overlays.Add(image(icon = 'zone.dmi',icon_state = "[name]_venos_damaged",layer = 27))
			switch(muscle.health)
				if(50 to 10000)
					omuscle = image(icon = 'icons/human.dmi',icon_state = "[muscle.istate]",layer = owner.layer + 2)
				if(30 to 50)
					omuscle = image(icon = 'icons/human.dmi',icon_state = "[muscle.damagedstate]",layer = owner.layer + 2)
				if(-999 to 5)
					del_hud()
					if(name == "chest" || name == "l_leg" || name == "r_leg")
						if(!owner.rest)
							owner.rest()
					omuscle = image(icon = 'icons/human.dmi',icon_state = "null",layer = owner.layer + 2)
					var/obj/item/organ/O = new src.type(owner.loc)
					O.muscle.health = muscle.health
					O.skin.health = skin.health
					O.bone.health = bone.health
					O.transform = turn(src.transform, rand(0,170))
					call_message(5, "[ru_name] отваливается и падает на пол")
					if(istype(src, /obj/item/organ/head))
						owner.health = 0
					del(src)

			if(owner:DNA.metabolism > 0)
				if(muscle.health < initial(muscle.health))
					if(muscle.physical_damage >= 5)
						muscle.physical_damage -= owner:DNA.metabolism * rand(1,3) + round(owner:oheart.temp / 200)
					if(muscle.temp_damage >= 5)
						muscle.temp_damage -= owner:DNA.metabolism * rand(1,3) + round(owner:oheart.temp / 200)
					if(muscle.chem_damage >= 5)
						muscle.chem_damage -=  owner:DNA.metabolism * rand(1,3) + round(owner:oheart.temp / 200)
					if(owner:ostomach)
						owner:ostomach.hungry += owner:DNA.metabolism
					else
						owner.health--

			return omuscle

	proc/check_bone()
		var/image/obone
		if(owner)
			switch(bone.health)
				if(50 to 10000)
					obone = image(icon = 'icons/human.dmi',icon_state = "[bone.istate]",layer = owner.layer + 2)
					bone.broken = 0
					if(owner.get_slot("[name]_bone", owner))
						owner.get_slot("[name]_bone", owner):icon_state = "[name]_bone"
				if(5 to 50)
					bone.broken = 1
					if(owner.get_slot("[name]_bone", owner))
						owner.get_slot("[name]_bone", owner):icon_state = "[name]_bone_damaged"
				if(-999 to 5)
					if(name == "chest" || name == "l_leg" || name == "r_leg")
						if(!owner.rest)
							owner.rest()
					del_hud()
					obone = image(icon = 'icons/human.dmi',icon_state = "null",layer = owner.layer + 2)
			return obone
			if(prob(50))
				if(owner.reagents.get_reagent_amount("blood_ven") + owner.reagents.get_reagent_amount("blood") < 300)
					owner.reagents.add_reagent("blood", 1 + owner:DNA.metabolism)
			if(owner:DNA.metabolism > 1)
				if(bone.health < initial(bone.health))
					if(bone.physical_damage >= 5)
						bone.physical_damage -= owner:DNA.metabolism * rand(1,2)
					if(owner:ostomach)
						owner:ostomach.hungry += owner:DNA.metabolism
					else
						owner.health--
	proc/check_pain()
		if(owner)
			var/full_pain = 0
			if(skin.name != null)
				switch(skin.health)
					if(15 to 20)
						damage_level = LIGHT_DAMAGE
						owner.message_to_usr("<font size='3' color='red'>[skin.name] немного болит</font>")
					if(5 to 15)
						damage_level = LIGHT_DAMAGE
						owner.message_to_usr("<font size='4' color='red'>[skin.name] серьезно болит. Это очень плохо.</font>")
					if(-999 to 5)
						damage_level = MEDIUM_DAMAGE
						owner.message_to_usr("<font size='5' color='red'>[skin.name] практически отвалилась. Это адская боль</font>")
			full_pain += damage_level

			switch(muscle.health)
				if(50 to 70)
					if(bone.name != null)
						owner.message_to_usr("<font size='3' color='red'>[muscle.name] немного болит</font>")
					damage_level = MEDIUM_DAMAGE
				if(30 to 50)
					if(bone.name != null)
						owner.message_to_usr("<font size='4' color='red'>[muscle.name] серьезно болит. Это очень плохо.</font>")
					damage_level = MEDIUM_DAMAGE
				if(-999 to 5)
					if(bone.name != null)
						owner.message_to_usr("<font size='5' color='red'>[muscle.name] практически отвалилась. Это адская боль! Использование [src.ru_name] затруднено</font>")
					damage_level = HARD_DAMAGE
			full_pain += damage_level

			if(bone.name != null)
				switch(bone.health)
					if(70 to 100)
						if(bone.broken)
							bone.broken = !bone.broken
					if(40 to 70)
						owner.message_to_usr("<font size='5' color='red'>[bone.name] сломана(ы), это очень больно. Использование [src.ru_name] затруднено</font>")
						damage_level = MEDIUM_DAMAGE
						bone.broken = 1
					if(-999 to 5)
						bone.broken = 1
						owner.message_to_usr("<font size='6' color='red'>[bone.name] раздроблена(ы) в мелкую крошку. Вам невыносимо больно. Использование или лечение [src.ru_name] невозможно</font>")
						damage_level = HARD_DAMAGE
						if(istype(src, /obj/item/organ/head))
							owner.death()
			full_pain += damage_level

			switch(full_pain)
				if(1 to 2)
					if(owner.get_slot("[name]_muscle", owner))
						owner.get_slot("[name]_muscle", owner):icon_state = "[name]_pain1"
				if(3 to 5)
					if(owner.get_slot("[name]_muscle", owner))
						owner.get_slot("[name]_muscle", owner):icon_state = "[name]_pain2"
				if(5 to 100)
					if(owner.get_slot("[name]_muscle", owner))
						owner.get_slot("[name]_muscle", owner):icon_state = "[name]_pain3"

			if(full_pain > 1)
				owner.reagents.add_reagent("adrenalin", round(full_pain / 2))


	thorax
		name = "thorax"
		ru_name = "грудная клетка"
		temp_factor = 0.7
		icon_state = "skin_thorax"
		crushing = 2
		cutting = 1
		stitching = 1

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin
			bone.name = "ребра"
			muscle.name = "мускулатура грудной клетки"
			skin.name = "кожа груди"
			skin.istate = "skin_thorax"
			skin.damagedstate = "skin_damaged_thorax"
			muscle.istate = "muscles_thorax"
			muscle.damagedstate = "muscles_damaged_thorax"
			bone.istate = "bone_thorax"
			if(istype(loc, /mob/living/human))
				owner = loc
				crushing += owner:DNA.strength
				cutting += owner:DNA.blades
				stitching += owner:DNA.kogti
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/damage/skin/skin_thorax, /obj/hud/damage/muscle/thorax, /obj/hud/damage/bone/thorax)

	larm
		name = "l_arm"
		ru_name = "левая рука"
		temp_factor = 0.7
		icon_state = "skin_arm_l"
		crushing = 2
		cutting = 1
		stitching = 1

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin
			bone.name = "кости в левой руке"
			muscle.name = "мускулатура левой руки"
			skin.name = "кожа на левой руке"
			skin.istate = "skin_arm_l"
			skin.damagedstate = "skin_damaged_arm_l"
			muscle.istate = "muscles_arm_l"
			muscle.damagedstate = "muscles_damaged_arm_l"
			bone.istate = "bone_arm_l"
			if(istype(loc, /mob/living/human))
				owner = loc
				crushing += owner:DNA.strength
				cutting += owner:DNA.blades
				stitching += owner:DNA.kogti
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/lhand, /obj/hud/glove_left, \
			/obj/hud/damage/skin/skin_l_arm, /obj/hud/damage/muscle/l_arm, /obj/hud/damage/bone/l_arm)

		roboarm
			name = "l_arm"
			ru_name = "левая рука (протез)"
			temp_factor = 0.7
			icon_state = "skin_roboarm_l"
			silicon = 1

			crushing = 5
			cutting = 2
			stitching = 1

			init()
				if(!bone) bone = new /datum/bone/robo
				if(!muscle) muscle = new /datum/muscle/robo
				if(!skin) skin = new /datum/skin/robo

				bone.name = "каркас в левой руке"
				muscle.name = "приводы левой руки"
				skin.name = "покрытие на левой руке"
				skin.istate = "skin_roboarm_l"
				skin.damagedstate = "skin_damaged_roboarm_l"
				muscle.istate = "muscles_roboarm_l"
				muscle.damagedstate = "muscles_damaged_roboarm_l"
				bone.istate = "bone_roboarm_l"
				if(istype(loc, /mob/living/human))
					owner = loc
				IHUD = list(/obj/hud/lhand/robohand)

	head
		name = "head"
		ru_name = "голова"
		temp_factor = 0.3
		icon_state = "skin_head"

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = "череп"
			muscle.name = "ткани на голове"
			skin.name = "кожа головы"
			skin.istate = "skin_head"
			skin.damagedstate = "skin_damaged_head"
			muscle.istate = "muscles_head"
			muscle.damagedstate = "muscles_damaged_head"
			bone.istate = "bone_head"
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/helmet, /obj/hud/drop, /obj/hud/punch_intent, \
			/obj/hud/damage/damage_lleg, /obj/hud/damage/damage_rleg, /obj/hud/damage/damage_larm, /obj/hud/damage/damage_thorax, /obj/hud/damage/damage_rarm, /obj/hud/damage/damage_chest, \
			/obj/hud/damage/damage_head, /obj/hud/say_intent, /obj/hud/harm_intent, /obj/hud/slot_level, /obj/hud/blind, /obj/hud/temp, \
			/obj/hud/damage/skin/skin_head, /obj/hud/damage/muscle/head, /obj/hud/damage/bone/head)

	lungs
		name = "lungs"
		ru_name = "легкие"
		temp_factor = 0.0
		icon_state = "lungs"

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = null
			muscle.name = "легкие"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = "lungs"
			muscle.damagedstate = "lungs"
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/oxygen, /obj/hud/oxy)

	liver
		name = "liver"
		ru_name = "печень"
		temp_factor = 0.0
		icon_state = "liver"

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = null
			muscle.name = "печень"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = "liver"
			muscle.damagedstate = "liver"
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list()

		process()
			if(owner)
				for(var/datum/reagent/R in owner.reagents.reagent_list)
					R.on_mob_life(owner)

	eyes
		name = "eyes"
		ru_name = "глаза"
		temp_factor = 0.0
		icon_state = ""

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = null
			muscle.name = "глаза"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = ""
			muscle.damagedstate = ""
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list()

	tongue
		name = "tongue"
		ru_name = "язык"
		temp_factor = 0.0
		icon_state = ""

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin
			bone.name = null
			muscle.name = "язык"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = ""
			muscle.damagedstate = ""
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
			IHUD = list()

	heart
		name = "heart"
		ru_name = "сердце"
		var/health = 100
		var/temp = 1
		temp_factor = 0.0
		icon_state = "heart"
		var/bonus = 0

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin
			bone.name = null
			muscle.name = "сердце"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = "heart"
			muscle.damagedstate = "heart"
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100

	stomach
		name = "stomach"
		ru_name = "желудок"
		temp_factor = 0.0
		var/hungry = 0
		var/obj/item/content

		verb/clear_stomach()
			set src in usr
			owner.message_to_usr("вы пытаетесь вызвать рвоту...")
			if(do_after(usr, 15))
				vomit()

		proc/vomit()
			owner.message_to_usr("вас серьезно мутит")
			hungry += rand(0,10)
			if(content)
				content.loc = owner.loc
				content = null
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				if(R.toxin)
					owner.reagents.remove_reagent(R.name, round(owner.reagents.get_reagent_amount(R.name)))
			new /obj/effect/vomit(owner.loc)
			owner.call_message(3, "<b>[owner.name] стошнило!</b>")
			owner.message_to_usr("вас стошнило!")

		process(var/image/oskin, var/image/omuscle, var/image/obone)
			if(owner)
				if(prob(rand(0,2)))
					check_pain()

				if(prob(3))
					hungry++

				var/obj/hud/nutrition/HUD = owner.get_slot("nutrition", owner)
				if(HUD)
					HUD.check_nutrtion(hungry)

				if(content)
					if(content.eatable)
						hungry -= content.nutrition
						content.reagents.trans_to(owner, content.reagents.get_total_amount())
						del(content)
					else
						if(prob(25))
							owner.message_to_usr("с вашим животом что-то не так")
						if(prob(2))
							vomit()

				if(hungry < -40)
					if(prob(round((hungry * -1)/2)))
						vomit()

				if(muscle.health < 50)
					if(prob(100 - muscle.health))
						vomit()

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = null
			muscle.name = "желудок"
			skin.name = null
			skin.istate = null
			skin.damagedstate = null
			muscle.istate = "stomach"
			muscle.damagedstate = "stomach"
			bone.istate = null
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/nutrition)

	chest
		name = "chest"
		ru_name = "тело"
		temp_factor = 1.5
		icon_state = "skin_chest"

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = "позвоночник и ребра"
			muscle.name = "мускулатура тела"
			skin.name = "кожа тела"
			skin.istate = "skin_chest"
			skin.damagedstate = "skin_damaged_chest"
			muscle.istate = "muscles_chset"
			muscle.damagedstate = "muscles_damaged_chest"
			bone.istate = "bone_chest"
			if(istype(loc, /mob/living/human))
				owner = loc
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/uniform, /obj/hud/suit, /obj/hud/tank, /obj/hud/mayka, /obj/hud/boxers, /obj/hud/throwbutton, /obj/hud/pullbutton, /obj/hud/backpack, \
			/obj/hud/damage/skin/skin_chest, /obj/hud/damage/muscle/chest, /obj/hud/damage/bone/chest)

	rarm
		name = "r_arm"
		ru_name = "правая рука"
		temp_factor = 0.7
		icon_state = "skin_arm_l"

		crushing = 2
		cutting = 1
		stitching = 1

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = "кости в правой руке"
			muscle.name = "мускулатура правой руки"
			skin.name = "кожа на правой руке"
			skin.istate = "skin_arm_r"
			skin.damagedstate = "skin_damaged_arm_r"
			muscle.istate = "muscles_arm_r"
			muscle.damagedstate = "muscles_damaged_arm_r"
			bone.istate = "bone_arm_r"
			if(istype(loc, /mob/living/human))
				owner = loc
				crushing += owner:DNA.strength
				cutting += owner:DNA.blades
				stitching += owner:DNA.kogti
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/rhand, /obj/hud/glove_right, \
			/obj/hud/damage/skin/skin_r_arm, /obj/hud/damage/muscle/r_arm, /obj/hud/damage/bone/r_arm)

		roboarm
			name = "r_arm"
			ru_name = "правая рука (протез)"
			temp_factor = 0.7
			icon_state = "skin_roboarm_r"
			silicon = 1

			crushing = 5
			cutting = 2
			stitching = 1

			init()
				if(!bone) bone = new /datum/bone/robo
				if(!muscle) muscle = new /datum/muscle/robo
				if(!skin) skin = new /datum/skin/robo
				bone.name = "каркас в правой руке"
				muscle.name = "приводы правой руки"
				skin.name = "покрытие на правой руке"
				skin.istate = "skin_roboarm_r"
				skin.damagedstate = "skin_damaged_roboarm_r"
				muscle.istate = "muscles_roboarm_r"
				muscle.damagedstate = "muscles_damaged_roboarm_r"
				bone.istate = "bone_roboarm_r"
				if(istype(loc, /mob/living/human))
					owner = loc
				IHUD = list(/obj/hud/rhand/robohand)

	rleg
		name = "r_leg"
		ru_name = "правая нога"
		temp_factor = 0.7
		icon_state = "skin_leg_r"
		var/speeding = 1

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin
			bone.name = "кости в правой ноге"
			muscle.name = "мускулатура правой ноги"
			skin.name = "кожа на правой ноге"
			skin.istate = "skin_leg_r"
			skin.damagedstate = "skin_damaged_leg_r"
			muscle.istate = "muscles_leg_r"
			muscle.damagedstate = "muscles_damaged_leg_r"
			bone.istate = "bone_leg_r"
			if(istype(loc, /mob/living/human))
				owner = loc
				speeding += owner:DNA.speeding
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/shoes_right, /obj/hud/socks_right, \
			/obj/hud/damage/skin/skin_r_leg, /obj/hud/damage/muscle/r_leg, /obj/hud/damage/bone/r_leg)

		roboleg
			name = "r_leg"
			ru_name = "правая нога (протез)"
			temp_factor = 0.7
			icon_state = "skin_roboleg_r"
			silicon = 1
			speeding = 2

			crushing = 5
			cutting = 2
			stitching = 1

			init()
				if(!bone) bone = new /datum/bone/robo
				if(!muscle) muscle = new /datum/muscle/robo
				if(!skin) skin = new /datum/skin/robo

				bone.name = "каркас в правой ноге"
				muscle.name = "приводы правой ноге"
				skin.name = "покрытие на правой ноге"
				skin.istate = "skin_roboleg_r"
				skin.damagedstate = "skin_damaged_roboleg_r"
				muscle.istate = "muscles_roboleg_r"
				muscle.damagedstate = "muscles_damaged_roboleg_r"
				bone.istate = "bone_roboleg_r"
				if(istype(loc, /mob/living/human))
					owner = loc
				IHUD = list()


	lleg
		name = "l_leg"
		ru_name = "левая нога"
		temp_factor = 0.7
		icon_state = "skin_leg_l"
		var/speeding = 1

		init()
			if(!bone) bone = new /datum/bone
			if(!muscle) muscle = new /datum/muscle
			if(!skin) skin = new /datum/skin

			bone.name = "кости в левой ноге"
			muscle.name = "мускулатура левой ноги"
			skin.name = "кожа на левой ноге"
			skin.istate = "skin_leg_l"
			skin.damagedstate = "skin_damaged_leg_l"
			muscle.istate = "muscles_leg_l"
			muscle.damagedstate = "muscles_damaged_leg_l"
			bone.istate = "bone_leg_l"
			if(istype(loc, /mob/living/human))
				owner = loc
				speeding += owner:DNA.speeding
				muscle.health += owner:DNA.muscles * 100
				skin.health += owner:DNA.skin * 100
				bone.health  += owner:DNA.bones * 100
			IHUD = list(/obj/hud/shoes_left, /obj/hud/socks_left, \
			/obj/hud/damage/skin/skin_l_leg, /obj/hud/damage/muscle/l_leg, /obj/hud/damage/bone/l_leg)

		roboleg
			name = "l_leg"
			ru_name = "левая нога (протез)"
			temp_factor = 0.7
			icon_state = "skin_roboleg_l"
			silicon = 1
			speeding = 2

			crushing = 5
			cutting = 2
			stitching = 1

			init()
				if(!bone) bone = new /datum/bone/robo
				if(!muscle) muscle = new /datum/muscle/robo
				if(!skin) skin = new /datum/skin/robo

				bone.name = "каркас в левой ноге"
				muscle.name = "приводы в левой ноге"
				skin.name = "покрытие на левой ноге"
				skin.istate = "skin_roboleg_l"
				skin.damagedstate = "skin_damaged_roboleg_'"
				muscle.istate = "muscles_roboleg_l"
				muscle.damagedstate = "muscles_damaged_roboleg_l"
				bone.istate = "bone_roboleg_l"
				if(istype(loc, /mob/living/human))
					owner = loc
				IHUD = list()