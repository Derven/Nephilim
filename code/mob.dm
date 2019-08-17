#define speed_of_zamerzanie 2
//punch intents
#define PANCHSBOKY 0
#define PANCHSVERHU 1
#define PANCHSNIZY 2
#define UKOL 3

//say intents
#define SAY 0
#define WHISPER 1
#define KRIK 2
#define ISTERIKA 3

//power damage
#define LITE_UDAR 300
#define MEDIUM_UDAR 700
#define HARD_UDAR 1000

/mob
	var/myears = 1
	var/blind = 0

/mob/living/human
	icon = 'icons/human.dmi'
	icon_state = "brain"
	var/rest = 0
	var/health = 100
	var/bodytemp = 36
	layer = 2
	var/death = 0
	var/oxyloss = 0
	var/clothes_temperature_def = 0
	var/damagezone = "damage_chest"
	var/harm_intent = 0

	var/pullmode = 0
	var/atom/movable/pulling

	var/image/list/humanparts = list()
	var/image/lungs
	var/image/heart
	var/image/stomach
	var/oxygen_tank = 0

	var/image/bone_chest
	var/image/bone_l_leg
	var/image/bone_r_leg
	var/image/bone_head
	var/image/bone_r_arm
	var/image/bone_l_arm

	var/image/muscle_chest
	var/image/muscle_l_leg
	var/image/muscle_r_leg
	var/image/muscle_head
	var/image/muscle_r_arm
	var/image/muscle_l_arm

	var/image/skin_chest
	var/image/skin_l_leg
	var/image/skin_r_leg
	var/image/skin_head
	var/image/skin_r_arm
	var/image/skin_l_arm

	var/obj/item/organ/larm/left_arm
	var/obj/item/organ/rarm/right_arm
	var/obj/item/organ/rleg/right_leg
	var/obj/item/organ/lleg/left_leg
	var/obj/item/organ/head/ohead
	var/obj/item/organ/chest/ochest
	var/obj/item/organ/lungs/olungs
	var/obj/item/organ/heart/oheart
	var/obj/item/organ/stomach/ostomach
	var/obj/item/organ/eyes/eyes
	var/throwmode = 0

	//panch
	var/punch_intent = PANCHSBOKY
	var/say_intent = SAY

	proc/check_isogloves()
		if(usr:get_slot("lhand"))
			if(usr:get_slot("lhand"):active)
				if(usr:get_slot("glove_left"):SLOT)
					if(istype(usr:get_slot("glove_left"):SLOT, /obj/item/clothing/gloves/yglove))
						return 1
					else
						return 0
				else
					return 0

		if(usr:get_slot("rhand"))
			if(usr:get_slot("rhand"):active)
				if(usr:get_slot("glove_right"):SLOT)
					if(istype(usr:get_slot("glove_right"):SLOT, /obj/item/clothing/gloves/yglove))
						return 1
					else
						return 0
				else
					return 0

		return 0


	verb/say(t as text)
		t = fix255(t)
		var/mysay = ""
		switch(say_intent)
			if(SAY)
				mysay = pick("говорит", "высказывает", "произносит")
				call_message(5, "[usr] [mysay], \"[t]\"")
			if(WHISPER)
				mysay = pick("шепчет", "нежно шепчет")
				call_message(1, "[usr] [mysay], \"[t]\"")
			if(KRIK)
				mysay = pick("орет", "кричит")
				call_message(7, "<h2>[usr] [mysay], \"[t]\"</h2>")
			if(ISTERIKA)
				mysay = pick("визжит", "бросается слюной", "истошно орет")
				call_message(7, "<b><i><h2>[usr] [mysay], \"[t]\"</h2></b></i>")

	attackby(var/mob/M, var/obj/item/I)
		var/damage_target = ""
		var/method = ""
		switch(M:punch_intent)
			if(PANCHSBOKY)
				method = "c бокового замаха"
			if(PANCHSNIZY)
				method = "с нижнего замаха"
			if(PANCHSVERHU)
				method = "с верхнего замаха"
			if(PANCHSVERHU)
				method = "уколом"

		if(M:harm_intent == 1)
			for(var/obj/item/organ/ORGAN in src)
				if(ORGAN.damagezone_to_organ(M:damagezone) != null)
					damage_target = ORGAN.damagezone_to_organ(M:damagezone):ru_name

			call_message(3, "[M] бьет [src] [I.ru_name] [method] в область [damage_target]")
			attack_organ(I, M:damagezone, M)
		else
			interact_withorgan(I, M:damagezone, M)

	attack_hand(usr)
		if(usr:get_slot("lhand") || usr:get_slot("rhand"))

			if(usr:get_slot("lhand"))
				if(usr:get_slot("lhand"):active)
					attackby(usr, usr:left_arm)

			if(usr:get_slot("rhand"))
				if(usr:get_slot("rhand"):active)
					attackby(usr, usr:right_arm)

	proc/death()
		control = 0
		sleep(2)
		//nocontrol()
		if(death == 0)
			death = 1
			if(client)
				var/mob/dead/ghost/deadly_ghost = new /mob/dead/ghost(src.loc)
				client.screen.Cut()
				client = null
				deadly_ghost.client = client
				deadly_ghost.client.dir = NORTH
				process()

		message_to_usr("Наступила смерть")
		nocontrol()

	proc/humanparts_upd()
		humanparts.Cut()
		humanparts.Add(bone_chest, bone_l_leg, bone_r_leg, bone_head, bone_r_arm, bone_l_arm, \
		lungs, heart, stomach, \
		muscle_chest, muscle_l_leg, muscle_r_leg, muscle_head, muscle_r_arm, muscle_l_arm, \
		skin_chest, skin_l_leg, skin_r_leg, skin_head, skin_r_arm, skin_l_arm)

	proc/generate()
		bone_chest = image(icon = 'icons/human.dmi',icon_state = "bone_chest",layer = 2)
		bone_l_leg = image(icon = 'icons/human.dmi',icon_state = "bone_leg_l",layer = 2)
		bone_r_leg = image(icon = 'icons/human.dmi',icon_state = "bone_leg_r",layer = 2)
		bone_head = image(icon = 'icons/human.dmi',icon_state = "bone_head",layer = 3)
		bone_r_arm = image(icon = 'icons/human.dmi',icon_state = "bone_arm_r",layer = 2)
		bone_l_arm = image(icon = 'icons/human.dmi',icon_state = "bone_arm_l",layer = 2)

		lungs = image(icon = 'icons/human.dmi',icon_state = "lungs",layer = 2)
		heart = image(icon = 'icons/human.dmi',icon_state = "heart",layer = 2)
		stomach = image(icon = 'icons/human.dmi',icon_state = "stomach",layer = 2)

		muscle_chest = image(icon = 'icons/human.dmi',icon_state = "muscles_chest",layer = 3)
		muscle_l_leg = image(icon = 'icons/human.dmi',icon_state = "muscles_leg_l",layer = 3)
		muscle_r_leg = image(icon = 'icons/human.dmi',icon_state = "muscles_leg_r",layer = 3)
		muscle_head = image(icon = 'icons/human.dmi',icon_state = "muscles_head",layer = 4)
		muscle_r_arm = image(icon = 'icons/human.dmi',icon_state = "muscles_arm_r",layer = 3)
		muscle_l_arm = image(icon = 'icons/human.dmi',icon_state = "muscles_arm_l",layer = 3)

		skin_chest = image(icon = 'icons/human.dmi',icon_state = "skin_chest",layer = 5)
		skin_l_leg = image(icon = 'icons/human.dmi',icon_state = "skin_leg_l",layer = 4)
		skin_r_leg = image(icon = 'icons/human.dmi',icon_state = "skin_leg_r",layer = 4)
		skin_head = image(icon = 'icons/human.dmi',icon_state = "skin_head",layer = 5)
		skin_r_arm = image(icon = 'icons/human.dmi',icon_state = "skin_arm_r",layer = 4)
		skin_l_arm = image(icon = 'icons/human.dmi',icon_state = "skin_arm_l",layer = 4)
		overlayupd()

		left_arm = new /obj/item/organ/larm(src)
		right_arm = new /obj/item/organ/rarm(src)
		right_leg = new /obj/item/organ/rleg(src)
		left_leg = new /obj/item/organ/lleg(src)
		olungs = new /obj/item/organ/lungs(src)
		oheart = new /obj/item/organ/heart(src)
		ostomach = new /obj/item/organ/stomach(src)
		ochest = new /obj/item/organ/chest(src)
		ohead = new /obj/item/organ/head(src)
		eyes = new /obj/item/organ/eyes(src)

	proc/humanupd()
		humanparts_upd()
		if(left_arm)
			left_arm.process()
			bone_l_arm = left_arm.check_bone()
			skin_l_arm = left_arm.check_skin()
			muscle_l_arm = left_arm.check_muscle()
		else
			bone_l_arm = null
			skin_l_arm = null
			muscle_l_arm = null

		if(right_arm)
			right_arm.process()
			bone_r_arm = right_arm.check_bone()
			skin_r_arm = right_arm.check_skin()
			muscle_r_arm = right_arm.check_muscle()
		else
			bone_r_arm = null
			skin_r_arm = null
			muscle_r_arm = null

		if(ochest)
			ochest.process()
			skin_chest = ochest.check_skin()
			bone_chest = ochest.check_bone()
			muscle_chest = ochest.check_muscle()
		else
			skin_chest = null
			bone_chest = null
			muscle_chest = null

		if(left_leg)
			left_leg.process()
			bone_l_leg = left_leg.check_bone()
			skin_l_leg = left_leg.check_skin()
			muscle_l_leg = left_leg.check_muscle()
		else
			bone_l_leg = null
			skin_l_leg = null
			muscle_l_leg = null

		if(eyes)
			eyes.process()
			eyes.check_muscle()
		else
			if(get_slot("blind", src))
				get_slot("blind", src):icon_state = "blind_2"

		if(right_leg)
			right_leg.process()
			skin_r_leg = right_leg.check_skin()
			bone_r_leg = right_leg.check_bone()
			muscle_r_leg = right_leg.check_muscle()
		else
			bone_r_leg = null
			skin_r_leg = null
			muscle_r_leg = null

		if(ohead)
			ohead.process()
			bone_head = ohead.check_bone()
			skin_head = ohead.check_skin()
			muscle_head = ohead.check_muscle()
		else
			death = 1
			bone_head = null
			skin_head = null
			muscle_head = null

		if(olungs)
			olungs.process()

		if(oheart)
			oheart.process()

		if(ostomach)
			ostomach.process()

	proc/overlayupd()
		for(var/image/A in humanparts)
			overlays.Remove(A)
		humanupd()
		for(var/image/A in humanparts)
			overlays.Add(A)

	process()
		overlayupd()
		blood_process()
		if(health <= 0)
			death()
			if(!rest)
				rest()

	proc/blood_process()
		reagents.remove_reagent("blood", 2)  //поглощение мозгом крови насыщенной кислородом
		reagents.add_reagent("blood_ven", 2) //возвращает обедненную кровь

		if(reagents.has_reagent("blood_ven", 150) || !reagents.has_reagent("blood", 150))
			death()

	New()
		var/datum/reagents/R = new/datum/reagents(380)
		reagents = R
		R.my_atom = src
		R.add_reagent("blood", 300)
		tocontrol()
		generate()
		..()
		var/atom/A = pick(LM)
		loc = A.loc
		spawn(5)
			if(!client)
				loc = initial(loc)

	verb/skin_damage()
		left_arm.skin.health -= 16
		right_arm.skin.health -= 16
		left_leg.skin.health -= 16
		right_leg.skin.health -= 16
		ochest.skin.health -= 16
		ohead.skin.health -= 16

	verb/muscles_damage()
		right_arm.muscle.health -= 10
		left_arm.muscle.health -= 10
		left_leg.muscle.health -= 10
		right_leg.muscle.health -= 10
		ochest.muscle.health -= 10
		ohead.muscle.health -= 10

	verb/check_blood()
		world << reagents.get_reagent_amount("blood")
		world << reagents.get_reagent_amount("blood_ven")

	verb/reboot()
		world.Reboot()

	verb/heart_damage()
		oheart.health -= 10

	verb/debug_ears()
		myears = !myears

	verb/damage_eyes()
		eyes.muscle.health -= 10

	verb/check_speed()
		speed += 100
		accelerate += 10

	proc/rest()
		spawn(5)
			if(rest == 0 || (left_leg != null && right_leg != null && ochest != null))
				if(rest == 0 || left_leg.muscle.health > 20 && right_leg.muscle.health > 20 && ochest.muscle.health > 20 \
				&& left_leg.bone.health > 20 && right_leg.bone.health > 20 && ochest.bone.health > 20)
					rest = !rest
					if(rest)
						src.transform = turn(src.transform, 90)
					else
						src.transform = turn(src.transform, -90)

	verb/resting()
		rest()

	proc/drop(var/vector, var/strength)
		if(!vector || !strength)
			for(var/obj/hud/rhand/RH in usr.client.screen)
				if(RH.SLOT != null)
					var/itemname = RH.SLOT.ru_name
					if(RH.active == 1)
						usr.call_message(3, "Бросает [itemname] на пол")
						RH.remove_from_slot()

			for(var/obj/hud/lhand/LH in usr.client.screen)
				if(LH.SLOT != null)
					var/itemname = LH.SLOT.ru_name
					if(LH.active == 1)
						usr.call_message(3, "Бросает [itemname] на пол")
						LH.remove_from_slot()
		else
			for(var/obj/hud/rhand/RH in usr.client.screen)
				if(RH.SLOT != null)
					var/itemname = RH.SLOT.ru_name
					if(RH.active == 1)
						usr.call_message(3, "Бросает [itemname] прочь")
						var/obj/item/I = RH.SLOT
						RH.remove_from_slot()
						I.speed = strength
						I.accelerate = strength
						I.Move(get_step(src, vector))

			for(var/obj/hud/lhand/LH in usr.client.screen)
				if(LH.SLOT != null)
					var/itemname = LH.SLOT.ru_name
					if(LH.active == 1)
						usr.call_message(3, "Бросает [itemname] прочь")
						var/obj/item/I = LH.SLOT
						LH.remove_from_slot()
						I.speed = strength
						I.accelerate = strength
						I.Move(get_step(src, vector))