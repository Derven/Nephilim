var/list/obj/landmark/LM = list()
var/list/obj/premark/PM = list()

/obj/landmark
	icon = 'landmark.dmi'
	invisibility = 101
	anchored = 1

	New()
		..()
		LM.Add(src)

/obj/premark
	icon = 'landmark.dmi'
	invisibility = 101
	anchored = 1

	New()
		..()
		PM.Add(src)