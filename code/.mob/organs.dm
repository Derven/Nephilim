#define NO_DAMAGE 0
#define LIGHT_DAMAGE 1
#define MEDIUM_DAMAGE 2
#define HARD_DAMAGE 3

/datum/bone
	var/health = 100
	var/broken = 0
	name = "bone"

	robo
		health = 300

/datum/muscle
	var/health = 100
	name = "muscle"
	var/damagedstate = ""

	robo
		health = 200

/datum/organ
	var/health = 100
	name = "organ"
	proc/myfunc()
		return 0

/datum/skin
	name = "skin"
	var/health = 30
	var/damagedstate = ""

	robo
		health = 120

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
					O.muscle.health = muscle.health
					O.skin.health = skin.health
					O.bone.health = bone.health
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
			if(owner.loc:temperature - owner.bodytemp > 40)
				if((speed_of_zamerzanie + temp_factor) - owner.clothes_temperature_def > 0)
					owner.bodytemp += round(owner.loc:temperature - owner.bodytemp / (speed_of_zamerzanie + temp_factor)) - owner.clothes_temperature_def
			if(owner.loc:temperature - owner.bodytemp < -20)
				if((speed_of_zamerzanie + temp_factor) - owner.clothes_temperature_def > 0)
					owner.bodytemp -= round(owner.loc:temperature - owner.bodytemp / (speed_of_zamerzanie + temp_factor)) + owner.clothes_temperature_def

			if( (owner.loc:temperature - owner.bodytemp < -30 && owner.clothes_temperature_def < speed_of_zamerzanie + temp_factor))
				if(silicon == 0)
					skin.health -= rand(1,3) - owner.clothes_temperature_def
					muscle.health -= rand(5,10) - owner.clothes_temperature_def

			if( (owner.loc:temperature - owner.bodytemp >= 90 && owner.clothes_temperature_def < speed_of_zamerzanie + temp_factor) || owner.bodytemp > 50)
				if(silicon == 0)
					skin.health -= rand(1,3) - owner.clothes_temperature_def
					muscle.health -= rand(5,10) - owner.clothes_temperature_def

	process(var/image/oskin, var/image/omuscle, var/image/obone)
		if(owner)
			if(prob(rand(0,2)))
				check_pain()

			check_temperature()

			if(istype(src, /obj/item/organ/heart))
				if(src:muscle.health > 0)
					src:temp = ((100 - src:muscle.health) / 3) + rand(40,63)
				else
					owner.death()
				spawn(src:temp)
					owner.reagents.remove_reagent("blood_ven", 2)
					owner.reagents.add_reagent("blood", 2)

			if(istype(src, /obj/item/organ/eyes))
				if(muscle.health < 50)
					var/obj/hud/HUD = owner.get_slot("blind", owner)
					if(HUD)
						HUD.icon_state = "blind_1"
				else
					var/obj/hud/HUD = owner.get_slot("blind", owner)
					if(HUD)
						HUD.icon_state = "blind_0"

			if(istype(src, /obj/item/organ/lungs))
				if(!owner.oxygen_tank)
					if(istype(owner.loc, /turf))
						if(istype(owner.loc, /turf/floor))
							if(owner.loc:reagents.get_master_reagent_state() == LIQUID)
								owner.oxyloss = 300
								if(prob(10))
									owner.call_message(5, "[owner] захлебывается ")

						if((owner.loc:reagents.get_reagent_amount("oxygen") < 20 || owner.loc:reagents.get_reagent_amount("plasma") > 20 || owner.loc:reagents.get_reagent_amount("water") > 50) && owner.oxyloss < 100)
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
							if((owner.get_slot("tank", owner):SLOT:oxygen < 20 || owner.get_slot("tank", owner):SLOT:plasma > 20) && owner.oxyloss < 100)
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

			return oskin

	proc/check_muscle()
		var/image/omuscle
		if(owner)
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

			return omuscle

	proc/check_bone()
		var/image/obone
		if(owner)
			switch(bone.health)
				if(5 to 10000)
					obone = image(icon = 'icons/human.dmi',icon_state = "[bone.istate]",layer = owner.layer + 2)
				if(-999 to 5)
					if(name == "chest" || name == "l_leg" || name == "r_leg")
						if(!owner.rest)
							owner.rest()
					del_hud()
					obone = image(icon = 'icons/human.dmi',icon_state = "null",layer = owner.layer + 2)
			return obone

	proc/check_pain()
		if(owner)
			if(skin.name != null)
				switch(skin.health)
					if(15 to 20)
						damage_level = LIGHT_DAMAGE
						owner.message_to_usr("[skin.name] немного болит")
					if(5 to 15)
						damage_level = LIGHT_DAMAGE
						owner.message_to_usr("[skin.name] серьезно болит. Это очень плохо.")
					if(-999 to 5)
						damage_level = MEDIUM_DAMAGE
						owner.message_to_usr("[skin.name] практически отвалилась. Это адская боль")

			switch(muscle.health)
				if(50 to 70)
					if(bone.name != null)
						owner.message_to_usr("[muscle.name] немного болит")
					damage_level = MEDIUM_DAMAGE
				if(30 to 50)
					if(bone.name != null)
						owner.message_to_usr("[muscle.name] серьезно болит. Это очень плохо.")
					damage_level = MEDIUM_DAMAGE
				if(-999 to 5)
					if(bone.name != null)
						owner.message_to_usr("[muscle.name] практически отвалилась. Это адская боль! Использование [src.ru_name] затруднено")
					damage_level = HARD_DAMAGE

			if(bone.name != null)
				switch(bone.health)
					if(70 to 100)
						if(bone.broken)
							bone.broken = !bone.broken
					if(40 to 70)
						owner.message_to_usr("[bone.name] сломана(ы), это очень больно. Использование [src.ru_name] затруднено")
						damage_level = MEDIUM_DAMAGE
						bone.broken = 1
					if(-999 to 5)
						bone.broken = 1
						owner.message_to_usr("[bone.name] раздроблена(ы) в мелкую крошку. Вам невыносимо больно. Использование или лечение [src.ru_name] невозможно")
						damage_level = HARD_DAMAGE
						if(istype(src, /obj/item/organ/head))
							owner.death()
	larm
		name = "l_arm"
		ru_name = "левая рука"
		temp_factor = 0.7
		icon_state = "skin_arm_l"

		crushing = 2
		cutting = 1
		stitching = 1

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/lhand, /obj/hud/glove_left)

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
				bone = new /datum/bone/robo
				muscle = new /datum/muscle/robo
				skin = new /datum/skin/robo

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
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/helmet, /obj/hud/drop, /obj/hud/punch_intent, \
			/obj/hud/damage/damage_lleg, /obj/hud/damage/damage_rleg, /obj/hud/damage/damage_larm, /obj/hud/damage/damage_rarm, /obj/hud/damage/damage_chest, \
			/obj/hud/damage/damage_head, /obj/hud/say_intent, /obj/hud/harm_intent, /obj/hud/slot_level, /obj/hud/blind)

	lungs
		name = "lungs"
		ru_name = "легкие"
		temp_factor = 0.0
		icon_state = "lungs"

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/oxygen)

	eyes
		name = "eyes"
		ru_name = "глаза"
		temp_factor = 0.0
		icon_state = ""

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list()


	heart
		name = "heart"
		ru_name = "сердце"
		var/health = 100
		var/temp = 1
		temp_factor = 0.0
		icon_state = "heart"

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin
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

	stomach
		name = "stomach"
		ru_name = "желудок"
		temp_factor = 0.0

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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

	chest
		name = "chest"
		ru_name = "тело"
		temp_factor = 1.5
		icon_state = "skin_chest"

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/uniform, /obj/hud/suit, /obj/hud/tank, /obj/hud/mayka, /obj/hud/boxers, /obj/hud/throwbutton, /obj/hud/pullbutton, /obj/hud/backpack)

	rarm
		name = "r_arm"
		ru_name = "правая рука"
		temp_factor = 0.7
		icon_state = "skin_arm_l"

		crushing = 2
		cutting = 1
		stitching = 1

		init()
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/rhand, /obj/hud/glove_right)

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
				bone = new /datum/bone/robo
				muscle = new /datum/muscle/robo
				skin = new /datum/skin/robo

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
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/shoes_right, /obj/hud/socks_right)

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
				bone = new /datum/bone/robo
				muscle = new /datum/muscle/robo
				skin = new /datum/skin/robo

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
			bone = new /datum/bone
			muscle = new /datum/muscle
			skin = new /datum/skin

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
			IHUD = list(/obj/hud/shoes_left, /obj/hud/socks_left)

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
				bone = new /datum/bone/robo
				muscle = new /datum/muscle/robo
				skin = new /datum/skin/robo

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