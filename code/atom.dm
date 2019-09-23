/atom/movable
	var/anchored = 0
	step_x = 0
	step_y = 0
	var/moving_vector
	var/speed = 0
	var/accelerate = 0
	var/structurehealth = 100
	var/reality = 1
	var/atom/target = null

	afterattack(var/mob/M, var/obj/item/I)
		if(istype(I, /obj/item/tools/drill))
			for(var/dz/DZ in src.loc)
				if(transportid != DZ.id)
					if(!istype(src, /mob))
						anchored = 1
						transportid = DZ.id
						call_message(5, "[src.ru_name ? src.ru_name : src.name ] �������������� � ������� �������")
						if(istype(src, /obj/structure/shuttle_wall))
							DZ.hardness += src.hardness
				else
					anchored = 0
					if(transportid == DZ.id)
						if(istype(src, /obj/structure/shuttle_wall))
							DZ.hardness = initial(DZ.hardness)
					transportid = -1
					call_message(5, "[src.ru_name ? src.ru_name : src.name ] ������������� �� ������� �������")


	verb/pull()
		set src in range(1, usr)
		if(istype(usr, /mob/living/human))
			usr:pullmode = 0
			usr:pulling = null

			usr:pullmode = 1
			usr:pulling = src
			usr:get_slot("pull"):color = "green"

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
			if(istype(Obstacle, /obj/energy_sphere))
				if(istype(src, /mob/living/human))
					src:powerdamage(Obstacle:amperage * Obstacle:voltage)
				if(Obstacle:target)
					Obstacle:target = null
				new /obj/effect/sparks(Obstacle.loc)
				del(Obstacle)
			if(istype(src, /obj/energy_sphere))
				if(istype(Obstacle, /mob/living/human))
					Obstacle:powerdamage(src:amperage * src:voltage)
				if(target)
					target = null
				new /obj/effect/sparks(src.loc)
				del(src)
			else
				Obstacle.collisionBumped(Obstacle.collision(src, 1), damage_zone)
				if(target)
					target = null
				collisionBumped(Obstacle.collision(src, 0), damage_zone)
				damage_zone = null
				call_message(5, "[src.ru_name ? src.ru_name : src.name ] ������������ � [Obstacle.ru_name] ")
				if(istype(src, /mob/living))
					if(src:client)
						src:client.shakecamera()
		else
			if(istype(Obstacle, /obj/energy_sphere))
				if(istype(src, /mob/living/human))
					src:powerdamage(Obstacle:amperage * Obstacle:voltage)
				if(Obstacle:target)
					Obstacle:target = null
				new /obj/effect/sparks(Obstacle.loc)
				del(Obstacle)
			if(istype(src, /obj/energy_sphere))
				if(istype(Obstacle, /mob/living/human))
					Obstacle:powerdamage(src:amperage * src:voltage)
				if(target)
					target = null
				new /obj/effect/sparks(src.loc)
				del(src)
			if(target)
				target = null
			bumpedzero(Obstacle)

	proc/MoveToVent(var/obj/target, var/pump_volume)
		src.loc = target.loc
		src:speed = pump_volume / 25
		src:accelerate = pump_volume / 50
		Move( get_step( src, pick(NORTH, SOUTH, WEST, EAST) ) )

	Move()
		if(init)
			return
		if(istype(src, /mob))
			if(src:buckled)
				return 0
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
		if(istype(src, /obj/machinery/atmospherics))
			src:disconnect()
			src:process()
			refresh_connector()
		if(istype(src, /obj/electro/cable))
			src:allcablesreset()

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
				if(!target)
					step(src,moving_vector,0)
					dir = moving_vector
				else
					step(src,get_dir(src, target),0)
					dir = get_dir(src, target)
					if(src.loc == target || src.loc == target.loc)
						target = null
						step(src,moving_vector,0)
						dir = moving_vector
		density = initial(density)



/atom
	var/ru_name
	var/hardness = 1
	var/damage_zone = null

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

	proc/bumpedzero(var/atom/movable/M)
		if(istype(src, /atom/movable) && istype(M, /atom/movable))
			if(!M.anchored)
				M.Move(get_step(M, src:dir))

	proc/collisionBumped(var/speeedwagon)
		..()