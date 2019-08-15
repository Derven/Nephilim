//pipe's dir's
#define HORIZONTAL_PIPE 1
#define HORIZONTAL_PIPE_2 2
#define VERTICAL_PIPE 4
#define VERTICAL_PIPE_2 8

#define SOUTHEAST_PIPE 6
#define SOUTHWEST_PIPE 10
#define NORTHEAST_PIPE 5
#define NORTHWEST_PIPE 9
//pipe's dir's

//pressure damage
#define DAMAGE_PRESSURE 20

//atmos
var/pipenetid = 0
var/veterok_pressure = 30
var/min_temperature = -380

/turf
	var/oxygen = 0
	var/co2 = 0
	var/plasma = 0
	var/temperature = -380
	var/pressure = 0
	var/water = 0

/turf/floor
	oxygen = 50
	co2 = 0
	plasma = 0
	temperature = 20
	pressure = 0
	ru_name = "пол"

	attackby(var/mob/M, var/obj/item/I)
		if(!istype(src, /turf/floor/openspess))
			if(istype(I, /obj/item/staple))
				M:drop()
				del(I)
				call_message(5, "к [ru_name] крепится скоба")
				new /obj/structure/staple(src)

	proc/overlayupdate()
		overlays.Cut()
		if(water > 0)
			overlays.Add(image(icon = src.icon,icon_state = "wateroverlay_0",layer = 3))
		switch(water)
			if(1 to 10)
				overlays.Add(image(icon = src.icon,icon_state = "wateroverlay_1",layer = 7))
			if(11 to 30)
				overlays.Add(image(icon = src.icon,icon_state = "wateroverlay_2",layer = 7))
			if(31 to 50)
				overlays.Add(image(icon = src.icon,icon_state = "wateroverlay_3",layer = 7))
			if(51 to 99999999)
				overlays.Add(image(icon = src.icon,icon_state = "wateroverlay_4",layer = 7))


	openspess
		icon_state = "openspace"
		ru_name = "дыра в полу"
		layer = 8

		Crossed(atom/movable/O2)
			if(z > 1)
				if(istype(O2, /mob))
					O2:message_to_usr("Вы падаете вниз!")
					for(var/obj/item/organ/O in O2)
						if(!istype(O, /obj/item/organ/heart) && !istype(O, /obj/item/organ/lungs))
							if(prob(25))
								O.bone.health -= rand(5, 10)
								O.muscle.health -= rand(2, 5)
								O.skin.health -= rand(1, 5)
				O2.z -= 1

	proc/move_veterok(var/turf/destination)
		for(var/atom/movable/M in src)
			if(istype(M, /mob/living/human))
				if(prob(abs(pressure - destination.pressure) / 4))
					M:message_to_usr("Воздух под высоким давлением бьет вас о пол и стены")
					for(var/obj/item/organ/O in M)
						if(!istype(O, /obj/item/organ/heart) && !istype(O, /obj/item/organ/lungs))
							if(prob(15))
								O.bone.health -= rand(10, 25)
								O.muscle.health -= rand(5, 10)
								O.skin.health -= rand(1, 8)

			if(M.anchored == 0 && M.reality)
				M.Move(destination)

	process()
		control = 0
		var/list/turf/TURFS = list()
		if(istype(src, /turf/floor/openspess))
			TURFS = check_in_cardinal_Z(1)
			if(z > 1)
				underlays.Cut()
				for(var/atom/A in locate(x,y,z-1))
					if(!istype(A, /obj/electro/cable) && !istype(A, /obj/machinery/atmospherics))
						underlays.Add(A)

		else
			TURFS = check_in_cardinal(1)
			overlayupdate()

		for(var/turf/FLOOR in TURFS)
			if(istype(FLOOR, /turf/floor))
				FLOOR.pressure = round((FLOOR.oxygen + FLOOR.co2 + FLOOR.plasma + FLOOR.water) * FLOOR.temperature / 2)
				pressure = round((oxygen + co2 + plasma + water) * temperature / 2)

				if(pressure > FLOOR.pressure)
					if(abs(pressure - FLOOR.pressure) > veterok_pressure)
						move_veterok(FLOOR)
				if(FLOOR.pressure > pressure)
					if(abs(pressure - FLOOR.pressure) > veterok_pressure)
						FLOOR:move_veterok(src)

				if((FLOOR.oxygen > oxygen) && FLOOR.oxygen - oxygen > 1)
					oxygen += 1
					FLOOR.oxygen -= 1

				if((FLOOR.co2 > co2) && FLOOR.co2 - co2 > 1)
					co2 += 1
					FLOOR.co2 -= 1

				if((FLOOR.plasma > plasma) && FLOOR.plasma - plasma > 1)
					plasma += 1
					FLOOR.plasma -= 1

				if((FLOOR.temperature > temperature) && FLOOR.temperature - temperature > 1)
					temperature += 1
					FLOOR.temperature -= 1

				if((FLOOR.water > water) && FLOOR.water - water > 1)
					water += 1
					FLOOR.water -= 1

			if(istype(FLOOR, /turf/space))
				move_veterok(FLOOR)

				if(oxygen > 0)
					oxygen -= 5
					if(oxygen < 0)
						oxygen = 0

				if(co2 > 0)
					co2 -= 5
					if(co2 < 0)
						co2 = 0

				if(plasma > 0)
					plasma  -= 5
					if(plasma < 0)
						plasma = 0

				if(water > 0)
					water = 0

				if(temperature > min_temperature)
					temperature -= 50
		control = 1