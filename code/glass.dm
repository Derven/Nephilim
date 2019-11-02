/obj/item/weapon/reagent_containers/glass
	name = "glass"
	layer = 8
	icon = 'chemical.dmi'
	icon_state = "beaker"
	ru_name = "банка"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50

	phos
		New()
			..()
			reagents.add_reagent("phosphorus", 300)

	justattack(mob/user, atom/target)
		if(!target.reagents) return
		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue Вы выливаете содержимое [ru_name] на [target]."
			//for(var/mob/O in viewers(world.view, user))
				//O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.trans_to(target, reagents.total_volume)
			return

		else if(target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [ru_name] пуста."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [ru_name] полна."
				return

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue Вы выливаете [trans] единиц на(в) [target.ru_name]."

		//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.

		else if(reagents.total_volume)
			user << "\blue Вы выливаете содержимое [ru_name] на [target.ru_name]."
			src.reagents.reaction(target, TOUCH)
			return