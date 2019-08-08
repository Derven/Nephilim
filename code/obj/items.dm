/obj/item/attack_hand()
	if(istype(usr, /mob/living/human))
		usr:pickup(src)

/obj/item
	//damage system
	var/crushing = 0
	var/cutting = 0
	var/stitching = 0
	var/def_cf = 0
	var/temperature_def = 0

/obj/item/baton
	icon = 'items.dmi'
	icon_state = "baton"
	name = "baton"
	ru_name = "дубинка"

	crushing = 5
	cutting = 0
	stitching = 0

/obj/item/tools
	icon = 'items.dmi'

	wrench
		icon_state = "wrench"
		name = "wrench"
		ru_name = "ключ"

		crushing = 3
		cutting = 0
		stitching = 0

	screwdriver
		icon_state = "screwdriver"
		name = "screwdriver"
		ru_name = "отвертка"

		crushing = 0
		cutting = 0
		stitching = 4

	welder
		icon_state = "welder"
		name = "welder"
		ru_name = "горелка"

		crushing = 1
		cutting = 1
		stitching = 1

/obj/item/unconnected_cable
	name = "copper_cable"
	ru_name = "неподключенный кабель"
	icon_state = "copper"
	icon = 'power.dmi'

	attackinhand(var/mob/M)
		dir = turn(dir, 45)
		M.message_to_usr("Вы вертите [ru_name] в руках")
