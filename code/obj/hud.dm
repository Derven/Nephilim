/mob/proc/get_slot(var/slotname)
	for(var/obj/hud/H in usr.client.screen)
		if(H.name == slotname)
			return H

/obj/hud
	icon = 'HUD.dmi'
	name = "hud"
	var/obj/item/SLOT
	var/type_of_slot

	proc/put_to_slot()
		if(istype(SLOT, type_of_slot))
			SLOT.loc = src
			SLOT.layer = 35
			src.overlays += SLOT

	proc/remove_from_slot(var/atom/aloc)
		if(istype(SLOT, type_of_slot))
			if(aloc)
				SLOT.loc = aloc
			else
				SLOT.loc = usr.loc
			src.overlays -= SLOT
			SLOT.layer = initial(SLOT.layer)
			SLOT = null

	New(client/C)
		C.screen += src

	punch_intent
		name = "punch_intent"
		icon_state = "punch_intent_0"
		layer = 25
		screen_loc = "10,1"
		var/active = 0
		type_of_slot = null

		proc/check_punch()
			switch(usr:punch_intent)
				if(PANCHSBOKY)
					usr:message_to_usr("Вы готовитесь к боковому удару")
				if(PANCHSNIZY)
					usr:message_to_usr("Вы готовитесь к удару снизу")
				if(PANCHSVERHU)
					usr:message_to_usr("Вы готовитесь к удару сверху")
				if(UKOL)
					usr:message_to_usr("Вы готовитесь к уколу")

		Click()
			if(usr:punch_intent < UKOL)
				usr:punch_intent++
				icon_state = "punch_intent_[usr:punch_intent]"
				check_punch()
			else
				usr:punch_intent = PANCHSBOKY
				icon_state = "punch_intent_[usr:punch_intent]"
				check_punch()

	lhand
		name = "lhand"
		icon_state = "lhand_0"
		layer = 25
		screen_loc = "1,1"
		var/active = 0
		type_of_slot = /obj/item/

		Click()
			for(var/obj/hud/rhand/RH in usr.client.screen)
				RH.active = !RH.active
				RH.icon_state = "rhand_[RH.active]"
			active = !active
			icon_state = "lhand_[active]"

	damage
		name = "damage"
		var/activezone = 0
		layer = 26

		Click()
			for(var/obj/hud/damage/DAMN in usr.client.screen)
				DAMN.activezone = 0
				DAMN.color = null

			usr:damagezone = name
			activezone = 1
			color = "red"

		damage_lleg
			icon_state = "damage_lleg"
			name = "damage_lleg"
			screen_loc = "14,13"

		damage_rleg
			icon_state = "damage_rleg"
			name = "damage_rleg"
			screen_loc = "14,13"

		damage_rarm
			icon_state = "damage_rarm"
			name = "damage_rarm"
			screen_loc = "14,13"

		damage_larm
			icon_state = "damage_larm"
			name = "damage_larm"
			screen_loc = "14,13"

		damage_chest
			icon_state = "damage_chest"
			name = "damage_chest"
			activezone = 1
			color = "red"
			screen_loc = "14,13"

		damage_head
			icon_state = "damage_head"
			name = "damage_head"
			screen_loc = "14,13"


	drop
		name = "drop"
		icon_state = "drop"
		layer = 25
		screen_loc = "4,2"

		Click()
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

	glove_left
		name = "glove_left"
		icon_state = "glove"
		layer = 25
		screen_loc = "3,1"

	rhand
		name = "rhand"
		icon_state = "rhand_1"
		layer = 25
		screen_loc = "2,1"
		var/active = 1
		type_of_slot = /obj/item/

		Click()
			for(var/obj/hud/lhand/LH in usr.client.screen)
				LH.active = !LH.active
				LH.icon_state = "lhand_[LH.active]"
			active = !active
			icon_state = "rhand_[active]"

	glove_right
		name = "glove_right"
		icon_state = "glove"
		layer = 25
		screen_loc = "4,1"

	shoes_right
		name = "shoes_right"
		icon_state = "shoes"
		layer = 25
		screen_loc = "5,1"

	shoes_left
		name = "shoes_left"
		icon_state = "shoes"
		layer = 25
		screen_loc = "6,1"

	helmet
		name = "helmet"
		icon_state = "helmet"
		layer = 25
		screen_loc = "7,1"

	uniform
		name = "uniform"
		icon_state = "uniform"
		layer = 25
		screen_loc = "8,1"

	suit
		name = "suit"
		icon_state = "suit"
		layer = 25
		screen_loc = "9,1"