var/list/atom/controlled = list()
/atom/var/control = 1

/atom/proc/process()
	return 0

/atom/proc/tocontrol()
	controlled.Add(src)

/atom/proc/nocontrol()
	controlled.Remove(src)

/datum/out_of_control
	var/ticktime = 2
	var/on = 1

	New()
		..()
		processingme()

	proc/processingme()
		while(on)
			checknhalt()
			for(var/atom/unit in controlled)
				if(unit.control == 1)
					spawn(ticktime)
						unit.process()

	proc/checknhalt() //safety system
		while(world.cpu > 30)
			on = 0
			//sleep(ticktime)
		if(world.cpu < 30)
			sleep(ticktime)
			on = 1