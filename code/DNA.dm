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
		for(var/obj/item/organ/O in owner)
			O.init()

/mob/living/human/verb
	DNA_bones_check()
		DNA.bones = -100
		DNA.mutate()

	DNA_breath_check()
		DNA.breath_type = "orange_juice"
		DNA.mutate()

	DNA_metabolism_check()
		DNA.metabolism = 2
		DNA.mutate()