/mob/living/plant
	var/reagent_type
	var/state
	var/mob/living/plant/parent
	var/born_new = 25 //100
	icon = 'hydroponics.dmi'
	name = "plant"
	icon_state = "plant"
	var/init = 0
	var/obj/item/food/harvest
	var/harvestcolor
	var/begin = 0
	anchored = 1

	attack_hand() //////DEBUG
		world << ru_name
		for(var/datum/mutation/M in mutations)
			world << M.ru_name
		world << lifepower  ///////DEBUG

	New()
		..()
		init()

	proc/init()
		if(init)
			begin = world.time
			var/datum/reagents/R = new/datum/reagents(380)
			reagents = R
			R.my_atom = src
			if(!parent)
				ru_name = "[pick("ша", "пу", "аг", "рос", "ив")][pick("ша", "пу", "аг", "рос", "ив", "бим")][pick("ша", "пу", "аг", "рос", "ив", "лаг")]"
				reagent_type = "[pick("poison", "nutriments", "psilocybin", "caffeine")]"
				var/datum/mutation/mutation1 = pick(/datum/mutation/oxygen_photosynthesis, /datum/mutation/photophobia, /datum/mutation/fluorescent)
				var/datum/mutation/mutation2 = pick(/datum/mutation/phosphorus_metabolic, /datum/mutation/nitrogen_metabolic)
				mutations.Add(new mutation1(), new mutation2())
				harvestcolor = pick("red", "green", "violet", "green")
				for(var/datum/mutation/M in mutations)
					M.owner = src
				lifepower = 0
				state = pick("plant","grass","tree")
				icon_state = state
				tocontrol()
			else
				ru_name = parent.ru_name
				reagent_type = parent.reagent_type
				mutations = parent.mutations
				harvestcolor = parent.harvestcolor
				lifepower = 0
				state = parent.state
				icon_state = state
				tocontrol()
	process()
		if(prob(35))
			for(var/datum/mutation/M in mutations)
				M.process()
			if(health <= 0)
				nocontrol()
				sleep(2)
				src.loc = locate(1,1,1)
			if(lifepower >= 100)
				if(world.time - begin > 100)
					if(prob(70))
						health -= world.time - begin
				lifepower = 0
				if(prob(50))
					if(istype(src.loc, /turf/floor))
						var/list/turf/floor/FLIST = list()
						for(var/turf/floor/F in range(1, src))
							FLIST.Add(F)
						var/mob/living/plant/P = new /mob/living/plant(pick(FLIST))
						P.parent = src
						P.init = 1
						P.init()
						for(var/datum/mutation/M in mutations)
							var/datum/mutation/mutation = new M.type
							mutation.owner = P
							P.mutations.Add(P)
				else
					var/i = rand(1,5)
					var/g = 0
					while(g < i)
						g++
						harvest = new /obj/item/food(src.loc)
						harvest.reagents.add_reagent(reagent_type, 50)
						harvest.icon = 'hydroponics.dmi'
						harvest.icon_state = "harvest"
						harvest.ru_name = "плод [ru_name]"
						harvest.color = harvestcolor
						harvest.nutrition = rand(10, 50)
						var/mob/living/plant/P = new /mob/living/plant(harvest)
						P.parent = src
				if(prob(25))
					if(istype(src.loc, /turf/floor))
						src.loc:icon_state = pick("grass0", "grass1", "grass2", "grass3")
