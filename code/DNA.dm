#define DEFAULT_BREATH_REAGENT "oxygen"
#define DEFAULT_METABOLISM_LEVEL 0
#define DEFAULT_TEMP_FACTOR 0.0

/datum/dna
	var/breath_type = DEFAULT_BREATH_REAGENT
	var/metabolism = DEFAULT_METABOLISM_LEVEL
	var/temp_defense = DEFAULT_TEMP_FACTOR
	var/mob/living/human/owner
	var/speeding = 0
	var/ears = 0
	var/strength = 0
	var/muscles = 0
	var/skin = 0
	var/bones = 0
	var/eyes = 0
	var/photosynthesis = 0
	var/jabre = 0 //жабры
	var/pain_sensitive = 0
	var/blades = 0
	var/kogti = 0

	proc/mutate()
		owner.message_to_usr("Вы мутируете!")
		for(var/obj/item/organ/O in owner)
			O.init()

	proc/alphabet_check(var/nume)
		if(!isnum(nume))
			switch(nume)
				if("oxygen"	)
					return "f"
				if("plasma")
					return "o"
				if("nitrogen")
					return "s"

		switch(nume)
			if(0)
				return pick("a", "h", "A")
			if(1)
				return pick("z", "b", "c", "B")
			if(2)
				return pick("x", "y", "L", "Z")
			else
				return pick("M", "m", "D", "d")

	proc/alphabet_revert(var/nume)
		if(nume == "f")
			return "oxygen"
		if(nume == "o")
			return "plasma"
		if(nume == "s")
			return "nitrogen"
		if(nume == "a" || nume ==  "h" || nume ==  "A")
			return 0
		if(nume == "z" || nume ==  "b" || nume ==  "c" || nume == "B")
			return 1
		if(nume == "x" || nume ==  "y" || nume ==  "L" || nume == "Z")
			return 2
		else
			return rand(-2,5)

	proc/encode()
		var/list/DNAcode = list(breath_type, metabolism, temp_defense, speeding, ears, strength, muscles, skin, eyes, photosynthesis, jabre, pain_sensitive, blades, kogti, bones)
		var/list/DNArecode = list()
		for(var/codefragment in DNAcode)
			DNArecode.Add(alphabet_check(codefragment))
		return DNArecode

	proc/encode2(var/list/DNAcode)
		var/list/DNArecode = list()
		for(var/codefragment in DNAcode)
			DNArecode.Add(alphabet_check(codefragment))
		return DNArecode

	proc/decode(var/list/DNAcode)
		var/list/DNArecode = list()
		for(var/codefragment in DNAcode)
			DNArecode.Add(alphabet_revert(codefragment))
		return DNArecode

	proc/encodedecodeme(var/list/iDNA)
		breath_type = iDNA[1]
		metabolism = iDNA[2]
		temp_defense = iDNA[3]
		speeding = iDNA[4]
		ears = iDNA[5]
		strength = iDNA[6]
		muscles = iDNA[7]
		skin = iDNA[8]
		eyes = iDNA[9]
		photosynthesis = iDNA[10]
		jabre = iDNA[11]
		pain_sensitive = iDNA[12]
		blades = iDNA[13]
		kogti = iDNA[14]
		bones = iDNA[15]

	proc/mutate_sector(var/num_of_sector)
		var/list/newdna = decode(encode())
		if(num_of_sector != 1)
			newdna[num_of_sector] = rand(-2,3)
		else
			newdna[num_of_sector] = pick("oxygen", "plasma", "nitrogen")
		encodedecodeme(newdna)
		mutate()

/mob/living/human/verb/check_encode()
	var/list/iDNA = DNA.encode()
	var/str = ""
	for(var/fragment in iDNA)
		str += fragment
	world << str


//////UNIVERSAL MUTATIONS

//*PLANTS

/mob/living
	var/list/datum/mutation/mutations = list()
	var/lifepower = 0

/datum/mutation
	var/datum/mutation/removekebab
	var/ru_name = "мутация"
	var/mob/living/owner

	proc/process()

	oxygen_photosynthesis
		ru_name = "фотосинтез кислорода"
		removekebab = /datum/mutation/photophobia
		process()
			if(owner)
				if(prob(50))
					if(istype(owner.loc, /turf/floor))
						if(owner.loc.luminosity > 0)
							if(owner.reagents.get_reagent_amount("hydrogen") > 0)
								owner.loc.reagents.add_reagent("oxygen", 1)
								owner.reagents.remove_reagent("hydrogen", 1)
							else
								if(istype(owner, /mob/living/human))
									owner:oxyloss++
								else
									owner.health--
	photophobia
		ru_name = "фотобоязнь"
		removekebab = /datum/mutation/oxygen_photosynthesis
		process()
			if(owner)
				if(prob(50))
					if(istype(owner.loc, /turf/floor))
						if(owner.loc.luminosity > 0)
							if(istype(owner, /mob/living/human))
								owner:chemdamage(rand(25,35))
							else
								if(prob(25))
									owner.health--
	fluorescent
		ru_name = "свечение"
		removekebab = /datum/mutation/photophobia

		process()
			if(owner)
				owner.ul_SetLuminosity(1, rand(1,2), rand(1,2))
		Del()
			..()
			owner.ul_SetLuminosity(0,0,0)

	phosphorus_metabolic
		ru_name = "фосфорный метаболизм"

		process()
			if(owner.reagents.get_reagent_amount("phosphorus") > 0)
				owner.reagents.remove_reagent("phosphorus", 1)
				if(istype(owner, /mob/living/human))
					for(var/obj/item/organ/O in owner)
						if(O.skin.health < 100)
							O.skin.health++
						if(O.muscle.health < 100)
							O.muscle.health++
						if(O.bone.health < 100)
							O.bone.health++
				else
					if(owner.health < 100)
						owner.health++
					owner.lifepower += rand(5,8)
			if(istype(owner.loc, /turf/floor))
				if(owner.loc:reagents.get_reagent_amount("phosphorus") > 0)
					owner.loc:reagents.remove_reagent("phosphorus", 1)
					if(istype(owner, /mob/living/human))
						for(var/obj/item/organ/O in owner)
							if(O.skin.health < 100)
								O.skin.health++
							if(O.muscle.health < 100)
								O.muscle.health++
							if(O.bone.health < 100)
								O.bone.health++
					else
						if(owner.health < 100)
							owner.health++
						owner.lifepower += rand(5,8)

	nitrogen_metabolic
		ru_name = "азотный метаболизм"

		process()
			if(owner.reagents.get_reagent_amount("nitrogen") > 0)
				owner.reagents.remove_reagent("nitrogen", 1)
				if(istype(owner, /mob/living/human))
					for(var/obj/item/organ/O in owner)
						if(O.skin.health < 100)
							O.skin.health++
						if(O.muscle.health < 100)
							O.muscle.health++
						if(O.bone.health < 100)
							O.bone.health++
				else
					if(owner.health < 100)
						owner.health++
					owner.lifepower += rand(5,8)
			if(istype(owner.loc, /turf/floor))
				if(owner.loc:reagents.get_reagent_amount("nitrogen") > 0)
					owner.loc:reagents.remove_reagent("nitrogen", 1)
					if(istype(owner, /mob/living/human))
						for(var/obj/item/organ/O in owner)
							if(O.skin.health < 100)
								O.skin.health++
							if(O.muscle.health < 100)
								O.muscle.health++
							if(O.bone.health < 100)
								O.bone.health++
					else
						if(owner.health < 100)
							owner.health++
						owner.lifepower += rand(5,8)
//*PLANTS