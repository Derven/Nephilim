/obj/structure/shuttle_wall
	density = 1
	opacity = 1
	ru_name = "������� �������"
	icon_state = "pwall"
	icon = 'turfs.dmi'

	New()
		..()
		spawn(5)
			if(transportid != -1)
				for(var/dz/DZ in src.loc)
					if(DZ.id == transportid)
						anchored = 1
						DZ.hardness += hardness

/obj/structure/shuttle_wall/window
	density = 1
	opacity = 0
	ru_name = "������� ������� (������)"
	icon_state = "pwindow"
	icon = 'turfs.dmi'