/*
	These are simple defaults for your project.
 */
var/init = 0

world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	turf = /turf/space
	view = 6		// show up to 6 tiles outward from center (13x13 view)
	mob = /mob/living/human
	map_format = TILED_ICON_MAP
	loop_checks = 0

	New()
		..()
		init = 1
		init = !init
		new /datum/out_of_control

// Make objects move 8 pixels per tick when walking

mob
	step_size = 32


obj
	step_size = 32

/datum
	var/name = "datum"
	var/istate = "0"

#define SOLID 1
#define LIQUID 2
#define GAS 3