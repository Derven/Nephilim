var/global/list/chemical_reactions_list = list(/datum/chemical_reaction/homunculinus)//list of all /datum/chemical_reaction datums. Used during chemical reactions

/atom
	var/datum/reagents/reagents

/atom/proc/on_reagent_change()
	return

/datum
	reagents
		var/list/datum/reagent/reagent_list = new/list()
		var/total_volume = 0
		var/maximum_volume = 100
		var/atom/my_atom = null

		New(maximum=100)
			maximum_volume = maximum

		proc

			remove_any(var/amount=1)
				var/total_transfered = 0
				var/current_list_element = 1

				current_list_element = rand(1,reagent_list.len)

				while(total_transfered != amount)
					if(total_transfered >= amount) break
					if(total_volume <= 0 || !reagent_list.len) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]

					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()

				handle_reactions()
				return total_transfered

			get_master_reagent_name()
				var/the_name = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_name = A.name

				return the_name

			trans_to(var/obj/target, var/amount=1, var/multiplier=1)
				var/total_transfered = 0
				var/current_list_element = 1
				var/datum/reagents/R = target.reagents
				//if(R.total_volume + amount > R.maximum_volume) return 0

				current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

				while(total_transfered != amount)
					if(total_transfered >= amount) break //Better safe than sorry.
					if(total_volume <= 0 || !reagent_list.len) break
					if(R.total_volume >= R.maximum_volume) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]

					R.add_reagent(current_reagent.id, (1 * multiplier) )
					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()
					R.update_total()

				R.handle_reactions()
				handle_reactions()

				return total_transfered

			metabolize(var/mob/M)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if(!istype(R, /datum/reagent/blood_arter) || !istype(R, /datum/reagent/blood_venoz))
						R.on_mob_life(M)
				update_total()

			handle_reactions()

				var/reaction_occured = 0
				do
					reaction_occured = 0
					for(var/datum/reagent/R in reagent_list) // Usually a small list
						for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id

							if(!reaction)
								continue

							var/datum/chemical_reaction/C = reaction
							var/total_required_reagents = C.required_reagents.len
							var/total_matching_reagents = 0
							var/total_required_catalysts = C.required_catalysts.len
							var/total_matching_catalysts= 0
							var/matching_container = 0
							var/matching_other = 0
							var/list/multipliers = new/list()

							for(var/B in C.required_reagents)
								if(!has_reagent(B, C.required_reagents[B]))	break
								total_matching_reagents++
								multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
							for(var/B in C.required_catalysts)
								if(!has_reagent(B, C.required_catalysts[B]))	break
								total_matching_catalysts++

							if(!C.required_container)
								matching_container = 1

							else
								if(my_atom.type == C.required_container)
									matching_container = 1

							if(!C.required_other)
								matching_other = 1


							if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
								var/multiplier = min(multipliers)
								for(var/B in C.required_reagents)
									remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

								var/created_volume = C.result_amount*multiplier
								if(C.result)
									multiplier = max(multiplier, 1) //this shouldnt happen ...
									add_reagent(C.result, C.result_amount*multiplier)

								var/list/seen = viewers(4, my_atom.loc)

								if(!istype(my_atom, /mob)) // No bubbling mobs
									for(var/mob/M in seen)
										M << "\blue \icon[my_atom] пузырит."

								C.on_reaction(src, created_volume)
								reaction_occured = 1
								break

				while(reaction_occured)
				update_total()
				return 0

			isolate_reagent(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id != reagent)
						del_reagent(R.id)
						update_total()

			del_reagent(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						reagent_list -= A
						del(A)
						update_total()
						my_atom.on_reagent_change()
						return 0


				return 1

			update_total()
				total_volume = 0
				for(var/datum/reagent/R in reagent_list)
					if(R.volume < 1)
						del_reagent(R.id)
					else
						total_volume += R.volume

				return 0

			clear_reagents()
				for(var/datum/reagent/R in reagent_list)
					del_reagent(R.id)
				return 0

			reaction(var/atom/A, var/volume_modifier=0)
				for(var/datum/reagent/R in reagent_list)
					if(ismob(A)) spawn(0) R.reaction_mob(A, R.volume+volume_modifier)
					if(isturf(A)) spawn(0) R.reaction_turf(A, R.volume+volume_modifier)
					if(isobj(A)) spawn(0) R.reaction_obj(A, R.volume+volume_modifier)

			add_reagent(var/reagent, var/amount)
				if(!isnum(amount)) return 1
				update_total()
				if(total_volume + amount > maximum_volume) amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						R.volume += amount
						update_total()
						my_atom.on_reagent_change()
						return 0

				for(var/A in typesof(/datum/reagent) - /datum/reagent)
					var/datum/reagent/R = new A()
					if (R.id == reagent)
						reagent_list += R
						R.holder = src
						R.volume = amount
						update_total()
						my_atom.on_reagent_change()
						return 0

				return 1

			remove_reagent(var/reagent, var/amount)

				if(!isnum(amount)) return 1

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						R.volume -= amount
						update_total()
						handle_reactions()
						my_atom.on_reagent_change()
						return 0

				return 1

			has_reagent(var/reagent, var/amount = -1)

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						if(!amount) return 1
						else
							if(R.volume >= amount) return 1
							else return 0

				return 0

			get_reagent_amount(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						return R.volume

				return 0

			get_total_amount()
				var/SUM = 0
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					SUM += R.volume
				return SUM

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(var/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
