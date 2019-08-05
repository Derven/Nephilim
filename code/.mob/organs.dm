#define NO_DAMAGE 0
#define LIGHT_DAMAGE 1
#define MEDIUM_DAMAGE 2
#define HARD_DAMAGE 3

/datum/bone
	var/health = 100
	var/broken = 0
	name = "bone"

/datum/muscle
	var/health = 100
	name = "muscle"
	var/damagedstate = ""

/datum/organ
	var/health = 100
	name = "organ"
	proc/myfunc()
		return 0

/datum/skin
	name = "skin"
	var/health = 30
	var/damagedstate = ""

/obj/item/organ
	icon = 'human.dmi'
	name = "organ"
	var/datum/bone/bone
	var/datum/muscle/muscle
	var/datum/skin/skin
	var/damage_level = NO_DAMAGE
	var/mob/living/human/owner
	var/ru_name
	var/temp_factor = 0.2
	var/list/obj/hud/IHUD = list()

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
				skin.health -= rand(1,3) - owner.clothes_temperature_def
				muscle.health -= rand(5,10) - owner.clothes_temperature_def

			if( (owner.loc:temperature - owner.bodytemp >= 90 && owner.clothes_temperature_def < speed_of_zamerzanie + temp_factor) || owner.bodytemp > 50)
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

			if(istype(src, /obj/item/organ/lungs))
				if(istype(owner.loc, /turf/floor))
					if((owner.loc:oxygen < 20 || owner.loc:plasma > 20) && owner.oxyloss < 100)
						owner.oxyloss += 1
						if(prob(2))
							owner.call_message(5, "[owner] кашляет")
					else
						owner.oxyloss -= 1
				else
					owner.oxyloss += 1

				if(owner.oxyloss >= 100)
					if(prob(10))
						owner.call_message(5, "[owner] задыхается")
						owner.health -= rand(0,5)

				if(src:muscle.health <= 30)
					owner.call_message(5, "[owner] кашляет")
				if(src:muscle.health <= 0)
					del(src)

	proc/check_skin()
		var/image/oskin
		if(owner)
			switch(skin.health)
				if(15 to 30)
					oskin = image(icon = 'icons/human.dmi',icon_state = "[skin.istate]",layer = 4)
				if(5 to 15)
					oskin = image(icon = 'icons/human.dmi',icon_state = "[skin.damagedstate]",layer = 4)
				if(-999 to 5)
					oskin = image(icon = 'icons/human.dmi',icon_state = "null",layer = 4)

			return oskin

	proc/check_muscle()
		var/image/omuscle
		if(owner)
			switch(muscle.health)
				if(50 to 100)
					omuscle = image(icon = 'icons/human.dmi',icon_state = "[muscle.istate]",layer = 4)
				if(30 to 50)
					omuscle = image(icon = 'icons/human.dmi',icon_state = "[muscle.damagedstate]",layer = 4)
				if(-999 to 5)
					del_hud()
					omuscle = image(icon = 'icons/human.dmi',icon_state = "null",layer = 4)

			return omuscle

	proc/check_bone()
		var/image/obone
		if(owner)
			switch(bone.health)
				if(5 to 100)
					obone = image(icon = 'icons/human.dmi',icon_state = "[bone.istate]",layer = 4)
				if(-999 to 5)
					del_hud()
					obone = image(icon = 'icons/human.dmi',icon_state = "null",layer = 4)
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

	head
		name = "l_arm"
		ru_name = "голова"
		temp_factor = 0.3

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
			IHUD = list(/obj/hud/helmet)

	lungs
		name = "lungs"
		ru_name = "легкие"
		temp_factor = 0.0

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


	heart
		name = "heart"
		ru_name = "сердце"
		var/health = 100
		var/temp = 1
		temp_factor = 0.0

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
			IHUD = list(/obj/hud/uniform, /obj/hud/suit)

	rarm
		name = "r_arm"
		ru_name = "правая рука"
		temp_factor = 0.7

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

	rleg
		name = "r_leg"
		ru_name = "правая нога"
		temp_factor = 0.7

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
			IHUD = list(/obj/hud/shoes_right)

	lleg
		name = "l_leg"
		ru_name = "левая нога"
		temp_factor = 0.7

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
			IHUD = list(/obj/hud/shoes_left)