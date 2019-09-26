

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

		proc
			reaction_mob(var/mob/living/human/M, var/volume) //By default we have a chance to transfer some
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
				holder.remove_reagent(src.id, 0.4) //By default it slowly disappears.
				return

		acid
			name = "acid"
			id = "acid"
			reagent_state = GAS

		nothing
			name = "nothing"
			id = "nothing"
			reagent_state = GAS

		poison
			name = "poison"
			id = "poison"
			reagent_state = LIQUID

			reaction_mob(var/mob/M)
				if(!M) M = holder.my_atom
				//usr << "\red Вы чувствуете головокружение"
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
			name = "ethanol"
			id = "ethanol"

		cola
			name = "cola"
			id = "cola"

		oil
			name = "oil"
			id = "oil"

		nutriments
			name = "nutriments"
			id = "nutriments"

		lightgas
			name = "lightgas"
			id = "lightgas"

		secgas //слезоточивый газ
			name = "secgas"
			id = "secgas"

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

		palladium
			name = "palladium"
			id = "palladium"

		phosphorus
			name = "phosphorus"
			id = "phosphorus"

			reaction_mob(var/mob/living/human/M, var/volume) //By default we have a chance to transfer some
				M.chemdamage(rand(LITE_CHEM, MEDIUM_CHEM))
				return

		potassium
			name = "potassium"
			id = "potassium"

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

		iron
			name = "iron"
			id = "iron"

		copper
			name = "copper"
			id = "copper"

		alluminium
			name = "alluminium"
			id = "alluminium"

		gold
			name = "gold"
			id = "gold"

		mercury
			name = "mercury"
			id = "mercury"

		chlorine
			name = "chlorine"
			id = "chlorine"

		fluorine
			name = "fluorine"
			id = "fluorine"

		radium
			name = "radium"
			id = "radium"

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

		codeine //от слова code
			name = "codeine"
			id = "codeine"

		antibiotic
			name = "antibiotic"
			id = "antibiotic"

		metamphetamine
			name = "metamphetamine"
			id = "metamphetamine"
