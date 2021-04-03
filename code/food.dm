/obj/item/weapon/reagent_containers/food
	name = "glass"
	layer = 8
	icon = 'chemical.dmi'
	icon_state = "beaker"
	ru_name = "банка"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50

	var/cooking_icon_state = ""
	var/nutriments_in_cooking = 0
	var/cooking_time = 5


	proc/cooking()
		if(icon_state != cooking_icon_state)
			if(do_after(usr, cooking_time))
				src.loc.call_message(3, "[src.ru_name] поджарился с румяной корочкой")
				icon_state = cooking_icon_state
				ru_name = "[ru_name] жареный(ая)"
				reagents.add_reagent("nutriments", nutriments_in_cooking)
				usr:drop()

	rybiy_zhir
		ru_name = "рыбий жир"
		cooking_icon_state = "bottle_syndicate"
		nutriments_in_cooking = 5
		New()
			..()
			reagents.add_reagent("phosphorus", 300)

	justattack(mob/user, atom/target)
		if(!target.reagents) return
		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue [target] кушает [ru_name]."
			//for(var/mob/O in viewers(world.view, user))
				//O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.trans_to(target, reagents.total_volume)
			return