/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'chemical.dmi'
	icon_state = null
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/New()
	..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	create_reagents(volume)

// this prevented pills, food, and other things from being picked up by bags.
// possibly intentional, but removing it allows us to not duplicate functionality.
// -Sayu (storage conslidation)
/*
/obj/item/weapon/reagent_containers/attackby(obj/item/I as obj, mob/user as mob)
	return
*/
/obj/item/weapon/reagent_containers/afterattack(obj/target, mob/user , flag)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(var/obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

//beep boop revertbot was here - proc remains to maximise compatibility
/obj/item/weapon/reagent_containers/proc/canconsume(mob/eater, mob/user)
/*	//Check for covering mask
	var/obj/item/clothing/cover = eater.get_item_by_slot(slot_wear_mask)

	if(isnull(cover)) // No mask, do we have any helmet?
		cover = eater.get_item_by_slot(slot_head)
	else
		var/obj/item/clothing/mask/covermask = cover
		if(covermask.alloweat) // Specific cases, clownmask for example.
			return 1

	if(!isnull(cover))
		if((cover.flags & HEADCOVERSMOUTH) || (cover.flags & MASKCOVERSMOUTH))
			var/who = (isnull(user) || eater == user) ? "your" : "their"

			if(istype(cover, /obj/item/clothing/mask/))
				user << "<span class='notice'>You have to remove [who] mask first!</span>"
			else
				user << "<span class='notice'>You have to remove [who] helmet first!</span>"

			return 0
*/
	return 1