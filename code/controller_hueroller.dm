var/list/atom/controlled = list()
/atom/var/control = 1

/atom/proc/process()
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
		while(on)
			if(checknhalt() == 1)
				for(var/atom/unit in controlled)
					if(unit)
						if(unit.control == 1 && on)
							spawn(ticktime)
								unit.process()
			else
				sleep(ticktime - rand(1,2))

	proc/checknhalt() //safety system
		if(world.cpu > 30)
			sleep(1)
			if(world.cpu > 45)
				sleep(2)
			if(world.cpu > 65)
				sleep(3)
			return 0

		if(world.cpu < 30)
			sleep(ticktime)
			return 1