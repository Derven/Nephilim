/proc/check_handcuffed(var/mob/living/human/M)
	for(var/mob/living/human/H in controlled)
		if(H.handcuffed == M)
			return H

client
	var/inmove = 0

	Move()
		if(istype(mob, /mob/living/human))
			if(mob:handcuffed)
				if(mob:handcuffed.anchored == 1)
					return
				else
					mob:pullmode = 1
					mob:pulling = mob:handcuffed
			if(mob:rest || inmove == 1 || mob:stuned > 0)
				return
			var/turf/oldloc = mob.loc
			var/spd = 0
			if(mob:right_leg)
				spd += mob:right_leg:speeding
			if(mob:left_leg)
				spd += mob:left_leg:speeding
			inmove = 1
			if(spd < 0)
				spd = 0
			if(spd > 4)
				spd = 5
			sleep(4 - spd)
			if(mob:MACHINE)
				mob:machine_accelerate += 2
			inmove = 0
			..()
			var/mob/living/human/Han = check_handcuffed(mob)
			if(Han)
				Han.Move(oldloc)
			if(mob:pullmode)
				if(mob:pulling.anchored == 0 && istype(mob:pulling.loc, /turf))
					mob:pulling.Move(oldloc)
					if(get_dist(mob:pulling, mob) > 1)
						usr:get_slot("pull"):color = null
						mob:pullmode = !mob:pullmode
						mob:pulling = null
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