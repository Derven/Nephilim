////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
var/const/TOUCH = 1
var/const/INGEST = 2

/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'syringe.dmi'
	var/item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	var/mode = SYRINGE_DRAW
	crushing = 0
	cutting = 0
	stitching = 5

	on_reagent_change()
		update_icon()

	attackinhand(mob/user as mob)
/*
		switch(mode)
			if(SYRINGE_DRAW)
				mode = SYRINGE_INJECT
			if(SYRINGE_INJECT)
				mode = SYRINGE_DRAW
*/
		mode = !mode
		update_icon()

	attack_hand()
		..()
		update_icon()

	attackby(obj/item/I as obj, mob/user as mob)
		return

	justattack(mob/user, obj/target)
		if(!target.reagents) return

		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red Шприц полон."
					if(usr:get_slot("lhand", user))
						usr:get_slot("lhand", user):refresh_slot()
					if(usr:get_slot("rhand", user))
						usr:get_slot("rhand", user):refresh_slot()
					return

				else //if not mob
					if(!target.reagents.total_volume)
						user << "\red [target] пуст."
						if(usr:get_slot("lhand", user))
							usr:get_slot("lhand", user):refresh_slot()
						if(usr:get_slot("rhand", user))
							usr:get_slot("rhand", user):refresh_slot()
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "\blue Вы берете [trans] единиц вещества."
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()
					if(usr:get_slot("lhand", user))
						usr:get_slot("lhand", user):refresh_slot()
					if(usr:get_slot("rhand", user))
						usr:get_slot("rhand", user):refresh_slot()
					return

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "\red Шприц пуст."
					if(usr:get_slot("lhand", user))
						usr:get_slot("lhand", user):refresh_slot()
					if(usr:get_slot("rhand", user))
						usr:get_slot("rhand", user):refresh_slot()
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] шприц полон."
					if(usr:get_slot("lhand", user))
						usr:get_slot("lhand", user):refresh_slot()
					if(usr:get_slot("rhand", user))
						usr:get_slot("rhand", user):refresh_slot()
					return

				if(ismob(target) && target != user)
					target.call_message(5, "\red <B>[user] пытается что-то вколоть [target]!</B>")
					target.call_message(5, "\red [user] вкалывает [target] что-то при помощи шприца!")
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)
				spawn(5)
					var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "\blue Вы вкалываете [trans] единиц вещества. Сейчас шприц содержит [src.reagents.total_volume] единиц."
					if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()
					if(usr:get_slot("lhand", user))
						usr:get_slot("lhand", user):refresh_slot()
					if(usr:get_slot("rhand", user))
						usr:get_slot("rhand", user):refresh_slot()
					return
		if(usr:get_slot("lhand", user))
			usr:get_slot("lhand", user):refresh_slot()
		if(usr:get_slot("rhand", user))
			usr:get_slot("rhand", user):refresh_slot()
		return

	update_icon()
		var/rounded_vol = round(reagents.total_volume,5)
		if(ismob(loc))
			var/mode_t
			switch(mode)
				if (SYRINGE_DRAW)
					mode_t = "d"
				if (SYRINGE_INJECT)
					mode_t = "i"
			icon_state = "[mode_t][rounded_vol]"
		else
			icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"