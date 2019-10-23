var/list/atom/controlled = list()
var/difftime = 0
var/last_tick = 0
/atom/var/control = 1

/atom/proc/process()
	last_tick = world.time
	(.) = ..()
	return 0

/atom/proc/tocontrol()
	controlled.Add(src)

/atom/proc/nocontrol()
	controlled.Remove(src)

/datum/out_of_control
	var/ticktime = 5
	var/on = 1

	New()
		..()
		processingme()

	proc/processingme()
		var/ticker = 145
		while(on)
			sleep(difftime)
			var/i = 0
			for(var/atom/unit in controlled)
				i++
				if(unit)
					if(checknhalt() == 1)
						if(i >= ticker)
							sleep(1)
							i = 0
						if(unit.control == 1 && on)
							unit.process()

	proc/checknhalt() //safety system
		difftime = world.time - last_tick
		if(difftime > ticktime)
			if(prob(15))
				sleep(1)
				last_tick = world.time
		return 1