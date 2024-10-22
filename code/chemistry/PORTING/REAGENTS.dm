

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

datum
	reagent
		name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/data = null
		var/volume = 0
		var/toxin = 0

		proc
			reaction_mob(var/mob/living/human/M, var/volume) //By default we have a chance to transfer some
				..()
				var/datum/reagent/self = src
				src = null										  //of the reagent to the mob on TOUCHING it.

				var/chance = 1
				//for(var/obj/item/clothing/C in M.contents)
				//	if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
				//chance = chance * 100

				if(prob(chance))
					if(M.reagents)
						M.reagents.add_reagent(self.id,self.volume/2)
					return

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				for(var/atom/movable/M in T)
					if(istype(M, /mob/living/human))
						reaction_mob(M, volume)
					else
						reaction_obj(M, volume)
				//src = null
				return

			on_mob_life(var/mob/M)
				if(name != "blood" && name != "blood_ven")
					holder.remove_reagent(src.id, 0.4) //By default it slowly disappears.
					if(istype(M, /mob/living/human))
						if(toxin)
							if(M:oliver)
								holder.remove_reagent(src.id, round(holder.get_reagent_amount(name) / (M:oliver:muscle.health / 50)))
								M:oliver:muscle.health -= holder.get_reagent_amount(name) / (M:oliver:muscle.health / 100)
								if(prob(rand(15,25)))
									if(M:ostomach)
										M:ostomach:vomit()
							else
								M:health -= holder.get_reagent_amount(name)
								if(prob(45))
									if(M:ostomach)
										M:ostomach:vomit()
					return

		barium
			name = "barium"
			id = "barium"
			reagent_state = GAS

		calcium
			name = "calcium"
			id = "calcium"
			reagent_state = GAS

		chlorine
			name = "chlorine"
			id = "chlorine"
			reagent_state = GAS

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(prob(15))
							if(O.muscle.temp_damage > 0)
								O.muscle.temp_damage += rand(1,5)
							if(O.skin.temp_damage > 0)
								O.skin.temp_damage += rand(1,5)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		fluorine
			name = "fluorine"
			id = "fluorine"
			reagent_state = GAS

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(prob(15))
							if(O.muscle.temp_damage > 0)
								O.muscle.temp_damage += rand(1,5)
								O.muscle.chem_damage += rand(1,5)
							if(O.skin.temp_damage > 0)
								O.skin.temp_damage += rand(1,5)
								O.skin.chem_damage += rand(1,5)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		helium
			name = "helium"
			id = "helium"
			reagent_state = GAS

		iron
			name = "iron"
			id = "iron"
			reagent_state = GAS

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(prob(5))
							if(O.muscle.temp_damage > 0)
								O.muscle.chem_damage += rand(1,2)
							if(O.skin.temp_damage > 0)
								O.skin.chem_damage += rand(1,2)
						if(prob(35))
							if(M.reagents.get_reagent_amount("blood_ven") + M.reagents.get_reagent_amount("blood") < 300)
								M.reagents.add_reagent("blood", 1)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		lithium
			name = "lithium"
			id = "lithium"
			reagent_state = GAS

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(prob(5))
							if(O.muscle.temp_damage > 0)
								O.muscle.chem_damage += rand(1,2)
							if(O.skin.temp_damage > 0)
								O.skin.chem_damage += rand(1,2)
						if(prob(35))
							if(M.reagents.get_reagent_amount("blood_ven") + M.reagents.get_reagent_amount("blood") < 300)
								M.reagents.add_reagent("blood", 1)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		magnesium
			name = "magnesium"
			id = "magnesium"
			reagent_state = GAS

		mercury
			name = "mercury"
			id = "mercury"
			reagent_state = GAS

		potassium
			name = "potassium"
			id = "potassium"
			reagent_state = GAS

		radium
			name = "radium"
			id = "radium"
			reagent_state = GAS

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(prob(15))
						M:DNA.mutate_sector(rand(1,15))
					else
						for(var/obj/item/organ/O in M)
							if(prob(5))
								if(O.muscle.temp_damage > 0)
									O.muscle.chem_damage += rand(1,2)
								if(O.skin.temp_damage > 0)
									O.skin.chem_damage += rand(1,2)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		silver
			name = "silver"
			id = "silver"
			reagent_state = GAS

		sugar
			name = "sugar"
			id = "sugar"
			reagent_state = GAS

		acid
			name = "acid"
			id = "acid"
			reagent_state = GAS

		nothing
			name = "nothing"
			id = "nothing"
			reagent_state = GAS

		adrenalin
			name = "adrenalin"
			id = "adrenalin"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					holder.remove_reagent(src.id, round(holder.get_reagent_amount(name) / (M:oliver:muscle.health / 50)))
					M:oheart.bonus += round(holder.get_reagent_amount(name))
					if(prob(holder.get_reagent_amount(name)))
						for(var/obj/item/organ/O in M)
							if(M.get_slot("[O.name]_muscle", M))
								M.get_slot("[O.name]_muscle", M):icon_state = "[name]_muscle"
				return

		dyloven
			name = "dyloven"
			id = "dyloven"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(M:oliver)
						if(M:oliver:muscle.health < initial(M:oliver:muscle.health))
							M:oliver:muscle.health++
							holder.remove_reagent(src.id, round(holder.get_reagent_amount(name) / (M:oliver:muscle.health / 50)))
				return

		alkysin
			name = "alkysin"
			id = "alkysin"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(M:health > 0 && M:health < initial(M:health))
						M:health++
						holder.remove_reagent(src.id, 0.5)
						if(M.client)
							if(prob(5))
								M.client.shakecamera()
								M.message_to_usr("�� ���������� ��������������...")

		impedolinez
			name = "impedolinez"
			id = "impedolinez"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(M:eyes)
						if(M:eyes:muscle.health < initial(M:eyes:muscle.health))
							M:eyes:muscle.health++
							holder.remove_reagent(src.id, pick(0.5, 1, 2))

		bicardine
			name = "bicardine"
			id = "bicardine"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(O.muscle.physical_damage > 0)
							O.muscle.physical_damage -= rand(1,5)
						if(O.bone.physical_damage > 0)
							O.bone.physical_damage -= rand(1,5)
						if(O.skin.physical_damage > 0)
							O.skin.physical_damage -= rand(1,5)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))

		kelotane
			name = "kelotane"
			id = "kelotane"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					for(var/obj/item/organ/O in M)
						if(O.muscle.temp_damage > 0)
							O.muscle.temp_damage -= rand(1,5)
						if(O.skin.temp_damage > 0)
							O.skin.temp_damage -= rand(1,5)
					holder.remove_reagent(src.id, pick(0.5, 1, 2))


		inaprovaline
			name = "inaprovaline"
			id = "inaprovaline"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(M:oheart)
						if(M:oheart:muscle.health < initial(M:oheart:muscle.health))
							M:oheart:muscle.health++
						holder.remove_reagent(src.id, pick(0.5, 1, 2))
						holder.remove_reagent("adrenalin", pick(0.5, 1, 2))

		tricordracine
			name = "tricordracine"
			id = "tricordracine"
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(istype(M, /mob/living/human))
					if(M:health < initial(M:health))
						M:health++
					for(var/obj/item/organ/O in M)
						if(O.ARTERIAL.opened)
							if(prob(10))
								O.ARTERIAL.opened = 0
						if(O.VENOS.opened)
							if(prob(10))
								O.VENOS.opened = 0
						if(O.muscle.physical_damage > 0)
							O.muscle.physical_damage -= rand(1,5)
						if(O.bone.physical_damage > 0)
							O.bone.physical_damage -= rand(1,5)
						if(O.skin.physical_damage > 0)
							O.skin.physical_damage -= rand(1,5)
						if(O.muscle.temp_damage > 0)
							O.muscle.temp_damage -= rand(1,5)
						if(O.skin.temp_damage > 0)
							O.skin.temp_damage -= rand(1,5)
						if(O.muscle.chem_damage > 0)
							O.muscle.chem_damage -= rand(1,5)
						if(O.skin.chem_damage > 0)
							O.skin.chem_damage -= rand(1,5)
					holder.remove_reagent(src.id, pick(1, 2, 5, 7))
					if(prob(15))
						M.client.shakecamera()
						M.message_to_usr("�� ���������� ��������������...")
					if(prob(rand(15,25)))
						if(M:ostomach)
							M:ostomach:vomit()
					if(prob(10))
						M:cry(rand(5,10))

		poison
			name = "poison"
			id = "poison"
			reagent_state = LIQUID
			toxin = 1

			reaction_mob(var/mob/M)
				if(!M) M = holder.my_atom
				//usr << "\red �� ���������� ��������������"
				//for(var/obj/item/organs/O in M)
				//	O.hit_points -= 10
				..()
				return

		blood_arter
			name = "blood"
			id = "blood"

		blood_venoz
			name = "blood_ven"
			id = "blood_ven"

		ethanol
			toxin = 1
			name = "ethanol"
			id = "ethanol"

		cola
			name = "cola"
			id = "cola"

		oil
			toxin = 1
			name = "oil"
			id = "oil"

		nutriments
			name = "nutriments"
			id = "nutriments"

		lightgas
			name = "lightgas"
			id = "lightgas"

		mayonnaise //is spicy
			name = "mayonnaise"
			id = "mayonnaise"

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				if(istype(O, /obj/item))
					if(!O:eatable)
						O:eatable = 1
					O:nutrition += 5
					holder.remove_reagent(src.id, holder.get_reagent_amount(src.id))

		secgas //������������ ���
			name = "secgas"
			id = "secgas"
			toxin = 1

			reaction_mob(var/mob/living/human/M, var/volume) //By default we have a chance to transfer some
				M.cry(rand(1,3))
				return

			reaction_turf(var/turf/T, var/volume)
				if(prob(10))
					new /obj/effect/smoke(T)
				holder.remove_reagent(src.id, rand(0.1,0.4))
				for(var/atom/movable/M in T)
					if(istype(M, /mob/living/human))
						reaction_mob(M, volume)
					else
						reaction_obj(M, volume)
				//src = null
				return

		psilocybin
			name = "psilocybin"
			id = "psilocybin"
			toxin = 1

		palladium
			name = "palladium"
			id = "palladium"
			toxin = 1

		phosphorus
			name = "phosphorus"
			id = "phosphorus"
			toxin = 1

			reaction_mob(var/mob/living/human/M, var/volume) //By default we have a chance to transfer some
				for(var/datum/mutation/phosphorus_metabolic/PM in M.mutations)
					return
				M.chemdamage(rand(LITE_CHEM, MEDIUM_CHEM))
				return

		carbon
			name = "carbon"
			id = "carbon"

		water
			name = "water"
			id = "water"
			reagent_state = LIQUID

		plasma
			name = "plasma"
			id = "plasma"

		nitrogen
			name = "nitrogen"
			id = "nitrogen"

		oxygen
			name = "oxygen"
			id = "oxygen"

		hydrogen
			name = "hydrogen"
			id = "hydrogen"

		copper
			name = "copper"
			id = "copper"

		alluminium
			name = "alluminium"
			id = "alluminium"

		gold
			name = "gold"
			id = "gold"

		uranium
			name = "uranium"
			id = "uranium"

		silver
			name = "silver"
			id = "silver"

		silicon
			name = "silicon"
			id = "silicon"

		sewage_sample
			name = "sewage_sample"
			id = "sewage_sample"

		salt_water
			name = "salt_water"
			id = "salt_water"

		orange_juice
			name = "orange_juice"
			id = "orange_juice"

		apple_juice
			name = "apple_juice"
			id = "apple_juice"

		caffeine
			name = "caffeine"
			id = "caffeine"

		tea
			name = "tea"
			id = "tea"

		milk
			name = "milk"
			id = "milk"

		mutagen
			name = "mutagen"
			id = "mutagen"

		purifier
			name = "purifier"
			id = "purifier"

		adderal
			name = "adderal"
			id = "adderal"

		sleeping
			name = "sleeping"
			id = "sleeping"

		oxycodone
			name = "oxycodone"
			id = "oxycodone"

		tramadol
			name = "tramadol"
			id = "tramadol"

		xanax
			name = "xanax"
			id = "xanax"

		codeine //�� ����� code
			name = "codeine"
			id = "codeine"

		antibiotic
			name = "antibiotic"
			id = "antibiotic"

		metamphetamine
			name = "metamphetamine"
			id = "metamphetamine"
