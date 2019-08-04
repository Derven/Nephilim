/mob/living/human
	icon = 'icons/human.dmi'
	icon_state = "brain"
	var/health = 100
	layer = 2


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

	proc/generate()
		bone_chest = image(icon = 'icons/human.dmi',icon_state = "bone_chest",layer = 2)
		bone_l_leg = image(icon = 'icons/human.dmi',icon_state = "bone_leg_l",layer = 2)
		bone_r_leg = image(icon = 'icons/human.dmi',icon_state = "bone_leg_r",layer = 2)
		bone_head = image(icon = 'icons/human.dmi',icon_state = "bone_head",layer = 3)
		bone_r_arm = image(icon = 'icons/human.dmi',icon_state = "bone_arm_r",layer = 2)
		bone_l_arm = image(icon = 'icons/human.dmi',icon_state = "bone_arm_l",layer = 2)

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

		humanparts.Add(bone_chest, bone_l_leg, bone_r_leg, bone_head, bone_r_arm, bone_l_arm, \
		muscle_chest, muscle_l_leg, muscle_r_leg, muscle_head, muscle_r_arm, muscle_l_arm, \
		skin_chest, skin_l_leg, skin_r_leg, skin_head, skin_r_arm, skin_l_arm)
		overlayupd()

	proc/humanupd()

	proc/overlayupd()
		for(var/image/A in humanparts)
			overlays.Remove(A)
		humanupd()
		for(var/image/A in humanparts)
			overlays.Add(A)

	process()

	New()
		tocontrol()
		generate()
		..()