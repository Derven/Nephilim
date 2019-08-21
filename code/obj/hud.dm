/mob/proc/get_slot(var/slotname, var/mob/M)
	if(!M)
		for(var/obj/hud/H in usr.client.screen)
			if(H.name == slotname)
				return H
	else
		if(M.client)
			for(var/obj/hud/H in M.client.screen)
				if(H.name == slotname)
					return H

/mob/proc/change_slot_level(var/mob/M)
	if(!M)
		var/obj/hud/slot_level/SL = usr.get_slot("slot_level", usr)
		for(var/obj/hud/H in usr.client.screen)
			if(!H.slot_neutral && H.slot_level == SL.level)
				H.invisibility = 0

			if(!H.slot_neutral && H.slot_level != SL.level)
				H.invisibility = 101
	else
		var/obj/hud/slot_level/SL = M.get_slot("slot_level", M)
		for(var/obj/hud/H in M.client.screen)
			if(!H.slot_neutral && H.slot_level == SL.level)
				H.invisibility = 0

			if(!H.slot_neutral && H.slot_level != SL.level)
				H.invisibility = 101

var/list/obj/item/disacceptedtomount = list(/obj/item/stack, /obj/item/mainboard, /obj/item/tank, /obj/item/clothing, /obj/item/unconnected_cable, /obj/item/roboprothesis)


/obj/hud
	icon = 'HUD.dmi'
	name = "hud"
	var/obj/item/SLOT
	var/type_of_slot
	var/image/slotimage
	var/slotname = ""
	var/silicon = 0
	var/slot_neutral = 1
	var/slot_level = 1

	proc/put_to_slot()
		if(istype(SLOT, type_of_slot))
			if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
				usr:clothes_temperature_def += SLOT:temperature_def
			slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 10)
			usr.overlays.Add(slotimage)
			if(silicon)
				var/no = 0
				for(var/p_a_t_h in disacceptedtomount)
					if(ispath(SLOT.type, p_a_t_h))
						no = 1

				if(no == 0)
					usr:message_to_usr("[SLOT.ru_name] вмонтировано в вашу конечность")
				else
					usr:message_to_usr("[SLOT.ru_name] не может быть вмонтировано в вашу конечность")
					SLOT = null
					return
			SLOT.loc = src
			SLOT.layer = 35
			src.overlays += SLOT
			usr:list_items["[slotname]"] = SLOT

	proc/remove_from_slot(var/mob/M, var/atom/aloc)
		if(!silicon)
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					if(usr)
						usr:clothes_temperature_def -= SLOT:temperature_def
					else
						M:clothes_temperature_def -= SLOT:temperature_def
				if(aloc)
					SLOT.loc = aloc
				else
					SLOT.loc = usr.loc
				src.overlays -= SLOT
				SLOT.layer = initial(SLOT.layer)
				SLOT = null
				if(usr)
					usr.overlays.Remove(slotimage)
					if(usr:list_items)
						usr:list_items["[slotname]"] = null
				if(M)
					M.overlays.Remove(slotimage)
					if(M:list_items)
						M:list_items["[slotname]"] = null

	attackby(var/mob/M, var/obj/item/I)
		if((!istype(src, /obj/hud/backpack) && !istype(src, /obj/hud/uniform)) || SLOT == null)
			SLOT = I
			if(istype(SLOT, type_of_slot))
				usr:drop()
				put_to_slot()
			else
				SLOT = null
		else
			if(SLOT)
				if(istype(SLOT, /obj/item/clothing/backpack/back))
					if(length(SLOT.contents) < 5 && I.weight < 2)
						usr:drop()
						I.Move(SLOT)
				if(istype(SLOT, /obj/item/clothing/uniform))
					if(length(SLOT.contents) < 2 && I.weight < 1)
						usr:drop()
						I.Move(SLOT)

	attack_hand()
		if(SLOT)
			remove_from_slot(usr, usr.loc)

	New(client/C)
		C.screen += src

	blind
		name = "blind"
		icon_state = "blind_1"
		layer = 24
		screen_loc = "1,1 to 13,13"
		type_of_slot = null
		mouse_opacity = 0

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

	say_intent
		name = "say_intent"
		icon_state = "say_intent_0"
		layer = 25
		screen_loc = "11,1"
		var/active = 0
		type_of_slot = null

		proc/check_say()
			switch(usr:say_intent)
				if(SAY)
					usr:message_to_usr("Вы готовитесь к разговору")
				if(WHISPER)
					usr:message_to_usr("Вы готовитесь шептать")
				if(KRIK)
					usr:message_to_usr("Вы готовитесь ОРАТЬ")
				if(ISTERIKA)
					usr:message_to_usr("ИСтЕРИкА")

		Click()
			if(usr:say_intent < ISTERIKA)
				usr:say_intent++
				icon_state = "say_intent_[usr:say_intent]"
				check_say()
			else
				usr:say_intent = SAY
				icon_state = "say_intent_[usr:say_intent]"
				check_say()

	harm_intent
		name = "harm_intent"
		icon_state = "harm_intent_0"
		layer = 25
		screen_loc = "12,1"
		var/active = 0
		type_of_slot = null

		Click()
			active = !active
			icon_state = "harm_intent_[active]"
			usr:harm_intent = active

	slot_level
		name = "slot_level"
		icon_state = "slot_level_1"
		layer = 25
		screen_loc = "13,1"
		var/level = 1
		type_of_slot = null

		Click()
			level = !level
			icon_state = "slot_level_[level]"
			usr.change_slot_level(usr)

	lhand
		name = "lhand"
		icon_state = "lhand_0"
		layer = 25
		screen_loc = "1,1"
		var/active = 0
		type_of_slot = /obj/item/

		Click()
			if(SLOT == null || silicon)
				active = !active
				icon_state = "lhand_[active]"
				for(var/obj/hud/rhand/RH in usr.client.screen)
					RH.active = !active
					RH.icon_state = "rhand_[!active]"
			else
				if(active)
					SLOT.attackinhand(usr)
				else
					if(usr:get_slot("rhand", usr))
						if(usr:get_slot("rhand", usr):SLOT)
							var/obj/item/I = usr:get_slot("rhand", usr):SLOT
							if(istype(SLOT, /obj/item/clothing/backpack/back) || istype(SLOT, /obj/item/storage))
								if(length(SLOT.contents) < 5 && I.weight < 2)
									usr:drop()
									I.Move(SLOT)
							if(istype(SLOT, /obj/item/clothing/uniform))
								if(length(SLOT.contents) < 2  && I.weight < 1)
									usr:drop()
									I.Move(SLOT)

		robohand
			name = "lhand"
			icon_state = "lhand_0"
			icon = 'silicon_hud.dmi'
			silicon = 1

	oxygen
		name = "oxygen_control"
		icon_state = "oxygen_0"
		layer = 25
		screen_loc = "14,12"
		var/active = 0

		Click()
			if(usr.get_slot("tank"))
				active = !active
				icon_state = "oxygen_[active]"
				if(usr.get_slot("tank"):SLOT)
					usr:message_to_usr("вы в режиме [active ? "подача воздуха из баллона" : "внешняя подача воздуха"]")
					usr:oxygen_tank = !usr:oxygen_tank
				else
					usr:oxygen_tank = 0
					icon_state = "oxygen_0"
					usr:message_to_usr("Нельзя переключить этот режим без баллона")

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
			usr:drop()

	throwbutton
		name = "throw"
		icon_state = "throw"
		layer = 25
		screen_loc = "6,2"

		Click()
			usr:throwmode = !usr:throwmode
			if(usr:throwmode == 1)
				color = "green"
			else
				color = null

	pullbutton
		name = "pull"
		icon_state = "pull"
		layer = 25
		screen_loc = "7,2"

		Click()
			if(usr:pullmode == 1)
				usr:pullmode = !usr:pullmode
				usr:pulling = null
				color = null

	glove_left
		name = "glove_left"
		icon_state = "glove"
		layer = 25
		screen_loc = "3,1"
		type_of_slot = /obj/item/clothing/gloves
		slotname = "larm"

	rhand
		name = "rhand"
		icon_state = "rhand_1"
		layer = 25
		screen_loc = "2,1"
		var/active = 1
		type_of_slot = /obj/item/

		Click()
			if(SLOT == null || silicon)
				active = !active
				icon_state = "rhand_[active]"
				for(var/obj/hud/lhand/LH in usr.client.screen)
					LH.active = !active
					LH.icon_state = "lhand_[!active]"
			else
				if(active)
					SLOT.attackinhand(usr)
				else
					if(usr:get_slot("lhand", usr))
						if(usr:get_slot("lhand", usr):SLOT)
							var/obj/item/I = usr:get_slot("lhand", usr):SLOT
							if(istype(SLOT, /obj/item/clothing/backpack/back) || istype(SLOT, /obj/item/storage))
								if(length(SLOT.contents) < 5 && I.weight < 2)
									usr:drop()
									I.Move(SLOT)
							if(istype(SLOT, /obj/item/clothing/uniform))
								if(length(SLOT.contents) < 2 &&  I.weight < 1)
									usr:drop()
									I.Move(SLOT)

		robohand
			name = "rhand"
			icon_state = "rhand_0"
			icon = 'silicon_hud.dmi'
			silicon = 1

	glove_right
		name = "glove_right"
		icon_state = "glove"
		layer = 25
		screen_loc = "4,1"
		type_of_slot = /obj/item/clothing/gloves
		slotname = "rarm"

	shoes_right
		name = "shoes_right"
		icon_state = "shoes"
		layer = 25
		screen_loc = "5,1"
		type_of_slot = /obj/item/clothing/shoes
		slotname = "rleg"
		slot_neutral = 0

	backpack
		name = "backpack"
		icon_state = "backpack"
		layer = 25
		screen_loc = "8,2"
		type_of_slot = /obj/item/clothing/backpack
		slotname = "chestback"
		slot_neutral = 0

	socks_right
		name = "socks_right"
		icon_state = "socks"
		layer = 25
		screen_loc = "5,1"
		invisibility = 101
		slot_level = 0
		type_of_slot = /obj/item/clothing/socks
		slotname = "rlegs"
		slot_neutral = 0

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 8)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT

	socks_left
		name = "socks_left"
		icon_state = "socks"
		layer = 25
		screen_loc = "6,1"
		invisibility = 101
		slot_level = 0
		type_of_slot = /obj/item/clothing/socks
		slotname = "llegs"
		slot_neutral = 0

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 8)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT

	shoes_left
		name = "shoes_left"
		icon_state = "shoes"
		layer = 25
		screen_loc = "6,1"
		type_of_slot = /obj/item/clothing/shoes
		slotname = "lleg"
		slot_neutral = 0

	helmet
		name = "helmet"
		icon_state = "helmet"
		layer = 25
		screen_loc = "7,1"
		slotname = "head"
		type_of_slot = /obj/item/clothing/helmet

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 15)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT
	uniform
		name = "uniform"
		icon_state = "uniform"
		layer = 25
		screen_loc = "8,1"
		slotname = "chestu"
		type_of_slot = /obj/item/clothing/uniform
		slot_neutral = 0

	mayka
		name = "mayka"
		icon_state = "mayka"
		layer = 25
		invisibility = 101
		screen_loc = "8,2"
		slotname = "chestm"
		type_of_slot = /obj/item/clothing/mayka
		slot_neutral = 0
		slot_level = 0

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 8)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT

	boxers
		name = "boxers"
		icon_state = "boxers"
		layer = 25
		invisibility = 101
		screen_loc = "8,1"
		slotname = "chestb"
		type_of_slot = /obj/item/clothing/boxers
		slot_neutral = 0
		slot_level = 0

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 8)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT

	tank
		name = "tank"
		icon_state = "oxygenslot"
		layer = 25
		screen_loc = "5,2"
		slotname = "tank"
		type_of_slot = /obj/item/tank

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 17)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT

		remove_from_slot(var/mob/M, var/atom/aloc)
			if(usr)
				if(usr.get_slot("oxygen_control", usr))
					usr.get_slot("oxygen_control", usr):active = 0
					usr.get_slot("oxygen_control", usr):icon_state = "oxygen_0"
					usr:oxygen_tank = 0
			else
				if(M.get_slot("oxygen_control", M))
					M.get_slot("oxygen_control", M):active = 0
					M.get_slot("oxygen_control", M):icon_state = "oxygen_0"
					M:oxygen_tank = 0
			if(istype(SLOT, type_of_slot))
				if(aloc)
					SLOT.loc = aloc
				else
					SLOT.loc = usr.loc
				src.overlays -= SLOT
				SLOT.layer = initial(SLOT.layer)
				SLOT = null
				if(usr)
					usr.overlays.Remove(slotimage)
					usr:list_items["[slotname]"] = null
				if(M)
					M.overlays.Remove(slotimage)
					M:list_items["[slotname]"] = null

	suit
		name = "suit"
		icon_state = "suit"
		layer = 25
		screen_loc = "9,1"
		slotname = "chests"
		type_of_slot = /obj/item/clothing/suit

		put_to_slot()
			if(istype(SLOT, type_of_slot))
				if(!istype(src, /obj/hud/lhand) && !istype(src, /obj/hud/rhand))
					usr:clothes_temperature_def += SLOT:temperature_def
				slotimage = image(icon = 'clothes_on_mob.dmi', icon_state = "[slotname]_[SLOT.icon_state]", layer = 15)
				usr.overlays.Add(slotimage)
				SLOT.loc = src
				SLOT.layer = 35
				src.overlays += SLOT
				usr:list_items["[slotname]"] = SLOT