client
	Move()
		if(istype(mob, /mob/living/human))
			if(mob:rest)
				return
			..()