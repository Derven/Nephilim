/obj/item/attack_hand()
	if(istype(usr, /mob/living/human))
		usr:pickup(src)

/obj/item
	//damage system
	var/crushing = 0
	var/cutting = 0
	var/stitching = 0

/obj/item/baton
	icon = 'items.dmi'
	icon_state = "baton"
	name = "baton"
	ru_name = "дубинка"

	crushing = 5
	cutting = 0
	stitching = 0

