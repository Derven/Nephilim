/atom/movable
	var/anchored = 0
	step_x = 0
	step_y = 0
	var/moving_vector
	var/speed = 0
	var/accelerate = 0
	var/structurehealth = 100
	var/reality = 1

	proc/atmosdeceleration()
		if(istype(src.loc, /turf))
			var/decelarated_atmos = src.loc:pressure / 100
			if(speed > decelarated_atmos)
				speed -= decelarated_atmos
				if(accelerate <= 0)
					accelerate++
				return 1
			if(decelarated_atmos > speed && speed > 1)
				speed--
				if(accelerate > 0)
					accelerate--
				if(accelerate < 0)
					accelerate = 0
			if(decelarated_atmos < 2)
				if(accelerate <= 0)
					accelerate++
				speed = 1

	Bump(atom/Obstacle)
		if(Obstacle.collision(src, 0) > 0)
			Obstacle.collisionBumped(Obstacle.collision(src, 1))
			collisionBumped(Obstacle.collision(src, 0))
			call_message(5, "[src.ru_name ? src.ru_name : src.name ] ������������ � [Obstacle.ru_name] ")
			if(istype(src, /mob/living))
				if(src:client)
					src:client.shakecamera()
		else
			bumpedzero()

	Move()
		moving_vector = dir
		if(reality)
			density = 1
		for(var/obj/gravity/GRAVITY in src.loc)
			speed = 0
			accelerate = 0
		for(var/obj/structure/staple/STAPLE in range(1,src))
			if(istype(src, /mob/living/human))
				if(src:throwmode)
					speed = 0
					accelerate = 0
		..()
		if(speed < 1)
			speed = 0
		speed += accelerate
		if(reality)
			if(atmosdeceleration() > 0)
				if(istype(src, /mob/living))
					if(src:client)
						src:client.dir = turn(src:client.dir, pick(90,-90,180,-180))
				sleep((src.loc:pressure / 1000) + 1)
				if(istype(src, /mob/living))
					if(src:client)
						src:client.dir = NORTH
				step(src,moving_vector,0)
				dir = moving_vector
		density = initial(density)

/atom
	var/ru_name
	var/hardness = 1

	proc/collision(var/atom/movable/M, var/impacted)
		if((M.speed + M.accelerate) * M.hardness > 0)
			var/damage = (M.speed + M.accelerate) * M.hardness + hardness
			if(impacted)
				M.speed = round(M.speed / 2)
				M.accelerate = round(M.accelerate / 2)
				M.moving_vector = turn(M.moving_vector, pick(90,-90, -45, 45, 180))
				M.dir = M.moving_vector
			if(istype(M, /mob/living/human))
				if(M:throwmode && damage < 200)
					var/staple = 0
					for(var/obj/structure/staple/STAPLE in range(1,M))
						staple = 50
					if(prob(40 + staple))
						M.speed = 0
						M.accelerate = 0
						call_message(5, "[M.ru_name ? M.ru_name : M.name ] ��������� � �������� �������� ������������ ")
						return 0
			return damage
		else
			return 0

	proc/bumpedzero()

	proc/collisionBumped(var/speeedwagon)
		..()