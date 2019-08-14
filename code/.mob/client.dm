client
	Move()
		if(istype(mob, /mob/living/human))
			if(mob:rest)
				return
			..()


	proc/shakecamera()
		eye = locate(mob.x + rand(-5,5), mob.y + rand(-5,5), mob.z)
		sleep(2)
		eye = locate(mob.x + rand(-5,5), mob.y + rand(-5,5), mob.z)
		sleep(2)
		eye = mob