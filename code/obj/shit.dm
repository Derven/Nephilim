
	if(dir == 1 || dir == 2)
		for(var/obj/machinery/atmospherics/A in get_step(src,NORTH))
			if(A.dir == 1 || A.dir == 2 || A.dir == 9 || A.dir == 10)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

		for(var/obj/machinery/atmospherics/A in get_step(src,SOUTH))
			if(A.dir == 1 || A.dir == 2 || A.dir == 5 || A.dir == 6)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

	if(dir == 4 || dir == 8)
		for(var/obj/machinery/atmospherics/A in get_step(src,EAST))
			if(A.dir == 4 || A.dir == 8 || A.dir == 9 || A.dir == 10)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet
		for(var/obj/machinery/atmospherics/A in get_step(src,WEST))
			if(A.dir == 4 || A.dir == 8 || A.dir == 5 || A.dir == 6)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

	if(dir == 5 || dir == 9)
		for(var/obj/machinery/atmospherics/A in get_step(src,NORTH))
			if(A.dir == 1 || A.dir == 2 || A.dir == 9 || A.dir == 10)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

	if(dir == 9 || dir == 10)
		for(var/obj/machinery/atmospherics/A in get_step(src,WEST))
			if(A.dir == 4 || A.dir == 8 || A.dir == 5 || A.dir == 6)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

	if(dir == 5 || dir == 6)
		for(var/obj/machinery/atmospherics/A in get_step(src,EAST))
			if(A.dir == 4 || A.dir == 8 || A.dir == 9 || A.dir == 10)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet

	if(dir == 6 || dir == 10)
		for(var/obj/machinery/atmospherics/A in get_step(src,SOUTH))
			if(A.dir == 1 || A.dir == 2 || A.dir == 5 || A.dir == 6)
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet
				else
					A.atmosnet = atmosnet