var/list/obj/landmark/LM = list()
/obj/landmark
	icon = 'landmark.dmi'
	invisibility = 101
	anchored = 1

	New()
		..()
		LM.Add(src)
