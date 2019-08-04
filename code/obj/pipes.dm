//КАК ЖЕ Я НЕНАВИЖУ ТРУБЫ БЛЯДЬ И ПРОВОДА УЕБАНСКИЕ
var/global/GASWAGEN_NET = 0//


/obj/machinery/atmospherics
	var/atmosnet = 0 //трубосети, нужны, чтобы создавать независимые друг от друга атмосокоммуникации
	var/reset
	var/zLevel = 0

/obj/machinery/atmospherics/connector
	icon = 'icons/pipes.dmi'
	icon_state = "connector"

/obj/machinery/atmospherics/outer
	icon = 'icons/pipes.dmi'
	icon_state = "vent"

/obj/machinery/atmospherics/pipe
	icon = 'pipes.dmi'
	name = "pipe"
	icon_state = "pipe_atmos"
	density = 0
	anchored = 1

/obj/machinery/atmospherics/pipe/manifold
	icon = 'pipes.dmi'
	icon_state = "pipe_tr"
	atmosnet = 0

/obj/machinery/atmospherics/pipe/manifold/process() // используется для подключения дополнительного коннектора, также соединения атмососетей
	sleep(1)
	for(var/obj/machinery/atmospherics/A in range(1,src))
		if(!(istype(src, /obj/machinery/atmospherics/connector)))
			if(A.atmosnet != 0)
				atmosnet = A.atmosnet
	for(var/obj/machinery/atmospherics/connector/A in range(1,src))
		A.atmosnet = atmosnet
		if(A.atmosnet == 0)
			GASWAGEN_NET++
			A.atmosnet = GASWAGEN_NET
			atmosnet = A.atmosnet

/obj/machinery/atmospherics/pipe/manifold/New()
	tocontrol()
	process()
	..()

/obj/machinery/atmospherics/pipe/manifold/attack_hand()
	world << "[atmosnet]"

/obj/machinery/atmospherics/pipe/process()
	sleep(1)
	if(dir == 2 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		for(var/obj/machinery/atmospherics/A in get_step(src,NORTH)) //вертикальные трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
				else
					A.atmosnet = 0
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

		for(var/obj/machinery/atmospherics/A in get_step(src,SOUTH)) //вертикальные трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

	if(dir == 4 || dir == 6 || dir == 10 || dir == 9 || dir == 5)

		for(var/obj/machinery/atmospherics/A in get_step(src,EAST))  //горизонтальные трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

		for(var/obj/machinery/atmospherics/A in get_step(src,WEST)) //горизонтальные трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
				else
					A.atmosnet = 0
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

	if(zLevel == 1)
		for(var/obj/machinery/atmospherics/A in locate(x,y,z+1)) //Z трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
				else
					A.atmosnet = 0
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

	if(zLevel == -1)
		for(var/obj/machinery/atmospherics/A in locate(x,y,z-1)) //Z трубы
			if(istype(A,/obj/machinery/atmospherics/outer))
				if(atmosnet != 0)
					A.atmosnet = atmosnet
				else
					A.atmosnet = 0
			else
				if(A.atmosnet != 0)
					atmosnet = A.atmosnet

	if(reset == 1)
		atmosnet = 0
		reset = 0
		world << "ОБРЫВ ТРУБЫ"


/obj/machinery/atmospherics/pipe/New()
	tocontrol()
	process()
	..()

/obj/machinery/atmospherics/pipe/attack_hand()
	//world << "atmosnet №[atmosnet]"
	del(src)

/obj/machinery/atmospherics/pipe/Del()
	world << "atmosnet №[atmosnet]"
	var/how_much
	for(var/obj/machinery/atmospherics/connector/C in world)
		if(atmosnet == C.atmosnet)
			how_much = 0 //сколько сранных коннекторов в ебучей атмососети
			how_much += 1
	if(how_much > 1)
		for(var/obj/machinery/atmospherics/connector/C in world)
			GASWAGEN_NET++
			C.atmosnet = GASWAGEN_NET

	for(var/obj/machinery/atmospherics/pipe/P in world)
		if(atmosnet == P.atmosnet)
			P.reset = 1

	..()
