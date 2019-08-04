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

/turf/floor
	oxygen = 50
	co2 = 0
	plasma = 0
	temperature = 20
	pressure = 0

	proc/move_veterok(var/turf/destination)
		for(var/atom/movable/M in src)
			if(M.anchored == 0)
				M.Move(destination)

	process()
		control = 0
		for(var/turf/FLOOR in check_in_cardinal(1))
			if(istype(FLOOR, /turf/floor))
				FLOOR.pressure = round((FLOOR.oxygen + FLOOR.co2 + FLOOR.plasma) * FLOOR.temperature / 2)
				pressure = round((oxygen + co2 + plasma) * temperature / 2)

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

				if(temperature > min_temperature)
					temperature -= 50
		control = 1