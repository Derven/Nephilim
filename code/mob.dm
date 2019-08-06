#define speed_of_zamerzanie 2
//punch intents
#define PANCHSBOKY 0
#define PANCHSVERHU 1
#define PANCHSNIZY 2
#define UKOL 3


/mob/living/human
	icon = 'icons/human.dmi'
	icon_state = "brain"
	var/health = 100
	var/bodytemp = 36
	layer = 2
	var/death = 0
	var/oxyloss = 0
	var/clothes_temperature_def = 0
	var/damagezone = "damage_chest"

	var/image/list/humanparts = list()
	var/image/lungs
	var/image/heart
	var/image/stomach

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

	//panch
	var/punch_intent = PANCHSBOKY

	attackby(var/mob/M, var/obj/item/I)
		var/damage_target = ""
		var/method = ""
		switch(M:punch_intent)
			if(PANCHSBOKY)
				method = "c �������� ������"
			if(PANCHSNIZY)
				method = "� ������� ������"
			if(PANCHSVERHU)
				method = "� �������� ������"
			if(PANCHSVERHU)
				method = "������"

		for(var/obj/item/organ/ORGAN in src)
			if(ORGAN.damagezone_to_organ(M:damagezone) != null)
				damage_target = ORGAN.damagezone_to_organ(M:damagezone):ru_name

		call_message(3, "\red [M] ���� [src] [I.ru_name] [method] � ������� [damage_target]")
		attack_organ(I, M:damagezone, M)

	proc/death()
		control = 0
		//nocontrol()
		death = 1
		message_to_usr("��������� ������")

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

	proc/humanupd()
		humanparts_upd()

		skin_l_arm = left_arm.check_skin()
		muscle_l_arm = left_arm.check_muscle()
		bone_l_arm = left_arm.check_bone()

		skin_r_arm = right_arm.check_skin()
		muscle_r_arm = right_arm.check_muscle()
		bone_r_arm = right_arm.check_bone()

		skin_l_leg = left_leg.check_skin()
		muscle_l_leg = left_leg.check_muscle()
		bone_l_leg = left_leg.check_bone()

		skin_r_leg = right_leg.check_skin()
		muscle_r_leg = right_leg.check_muscle()
		bone_r_leg = right_leg.check_bone()

		skin_chest = ochest.check_skin()
		muscle_chest = ochest.check_muscle()
		bone_chest = ochest.check_bone()

		skin_head = ohead.check_skin()
		muscle_head = ohead.check_muscle()
		bone_head = ohead.check_bone()

		left_arm.process()
		right_arm.process()
		left_leg.process()
		right_leg.process()
		olungs.process()
		oheart.process()
		ostomach.process()
		ohead.process()
		ochest.process()

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

	proc/blood_process()
		reagents.remove_reagent("blood", 2)  //���������� ������ ����� ���������� ����������
		reagents.add_reagent("blood_ven", 2) //���������� ���������� �����

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

	verb/heart_damage()
		oheart.health -= 10
