client
	Move()
		if(istype(mob, /mob/living/human))
			if(mob:rest)
				return
			var/turf/oldloc = mob.loc
			..()
			if(mob:pullmode)
				if(mob:pulling.anchored == 0)
					mob:pulling.Move(oldloc)
				else
					usr:get_slot("pull"):color = null
					mob:pullmode = !mob:pullmode
					mob:pulling = null
		else
			..()


	proc/shakecamera()
		eye = locate(mob.x + rand(-5,5), mob.y + rand(-5,5), mob.z)
		sleep(2)
		eye = locate(mob.x + rand(-5,5), mob.y + rand(-5,5), mob.z)
		sleep(2)
		eye = mob

	North()
		if(istype(mob.loc, /turf))
			..()
		else
			if(istype(mob.loc, /obj/machinery/atmospherics))
				for(var/obj/machinery/atmospherics/A in locate(mob.loc:x, mob.loc:y + 1, mob.loc:z))
					mob.loc = A

	South()
		if(istype(mob.loc, /turf))
			..()
		else
			if(istype(mob.loc, /obj/machinery/atmospherics))
				for(var/obj/machinery/atmospherics/A in locate(mob.loc:x, mob.loc:y - 1, mob.loc:z))
					mob.loc = A

	West()
		if(istype(mob.loc, /turf))
			..()
		else
			if(istype(mob.loc, /obj/machinery/atmospherics))
				for(var/obj/machinery/atmospherics/A in locate(mob.loc:x - 1, mob.loc:y, mob.loc:z))
					mob.loc = A

	East()
		if(istype(mob.loc, /turf))
			..()
		else
			if(istype(mob.loc, /obj/machinery/atmospherics))
				for(var/obj/machinery/atmospherics/A in locate(mob.loc:x + 1, mob.loc:y, mob.loc:z))
					mob.loc = A