/obj/item/attack_hand()
	if(istype(usr, /mob/living/human))
		usr:pickup(src)

/obj/item
	//damage system
	var/crushing = 0
	var/cutting = 0
	var/stitching = 0
	var/def_cf = 0
	var/temperature_def = 0
	var/weight = 0

/obj/item/baton
	icon = 'items.dmi'
	icon_state = "baton"
	name = "baton"
	ru_name = "дубинка"

	crushing = 5
	cutting = 0
	stitching = 0

	stunbaton
		icon = 'items.dmi'
		icon_state = "stunbaton"
		name = "stunbaton"
		ru_name = "электрическая дубинка"

		crushing = 5
		cutting = 0
		stitching = 0
		var/obj/item/devicebattery/DB = null //батарейка
		amperage = 1
		voltage = 1
		var/maxvltamp = 1700

		attackinhand(var/mob/M)
			M << browse(null,"window=[name]")
			var/list/powerstat = list()
			var/list/hrefs = list()
			powerstat.Add(fix1103("Вольтаж заряда: [voltage]"))
			powerstat.Add(fix1103("Сила тока заряда: [amperage]"))
			powerstat.Add(fix1103("Заряд батареи: [DB ? DB.charge_level : "батарея отсутствует"]"))
			hrefs.Add("voltage=1")
			hrefs.Add("amperage=1")
			hrefs.Add("battery=null")
			special_browse(M, nterface(powerstat, hrefs))

		Topic(href,href_list[])
			if(href_list["amperage"] == "1")
				amperage = input(usr, "Выставить силу тока","ваше значение",amperage) as num
				if(amperage <= 0)
					amperage = 1
			if(href_list["voltage"] == "1")
				voltage = input(usr, "Выставить напряжение","ваше значение",voltage) as num
				if(voltage <= 0)
					voltage = 1
			if(href_list["battery"] == "null")
				if(usr:get_slot("rhand"):SLOT == src || usr:get_slot("lhand"):SLOT == src)
					DB.loc = usr.loc
					DB = null
					icon = initial(icon)
					usr:get_slot("lhand", usr):refresh_slot()
					usr:get_slot("rhand", usr):refresh_slot()
			attackinhand(usr)

		attackby(var/mob/M, var/obj/item/I)
			if(istype(I, /obj/item/devicebattery))
				if(!DB)
					DB = I
					usr:drop()
					I.loc = src
					var/icon/I2 = new('items.dmi', "stunbaton")
					var/icon/J = new('computer.dmi', I.icon_state)
					I2.Blend(J, ICON_OVERLAY)
					icon = I2
					attackinhand(usr)

		proc/vzhvzh(var/mob/living/human/H)
			if(DB.charge_level > 0 && DB.charge_level > amperage * voltage)
				H.powerdamage(amperage * voltage)
				DB.charge_level -= amperage * voltage


/obj/item/roboprothesis
	icon = 'items.dmi'
	icon_state = "roboprothesis"
	name = "roboprothesis"
	ru_name = " заготовка протеза"
	var/type_of_prothesis = "rarm"

	crushing = 1
	cutting = 1
	stitching = 1

	arml
		type_of_prothesis = "larm"
	legl
		type_of_prothesis = "lleg"
	legr
		type_of_prothesis = "rleg"

/obj/item/tools
	icon = 'items.dmi'

	wrench
		icon_state = "wrench"
		name = "wrench"
		ru_name = "ключ"

		crushing = 3
		cutting = 0
		stitching = 0

	screwdriver
		icon_state = "screwdriver"
		name = "screwdriver"
		ru_name = "отвертка"

		crushing = 0
		cutting = 0
		stitching = 6

	wirecutters
		icon_state = "wirecutters"
		name = "wirecutters"
		ru_name = "кусачки"

		crushing = 0
		cutting = 2
		stitching = 1

	welder
		icon_state = "welder"
		name = "welder"
		ru_name = "горелка"

		crushing = 1
		cutting = 1
		stitching = 1

	scalpel
		icon_state = "scalpel"
		name = "scalpel"
		ru_name = "скальпель"

		crushing = 0
		cutting = 7
		stitching = 5

	drill
		icon_state = "drill"
		name = "drill"
		ru_name = "дрель / шуруповерт"

		crushing = 0
		cutting = 0
		stitching = 5

	saw
		icon_state = "saw"
		name = "saw"
		ru_name = "пила"

		crushing = 3
		cutting = 3
		stitching = 0

	cauterizer
		icon_state = "cauterizer"
		name = "cauterizer"
		ru_name = "прижигатель"

		crushing = 0
		cutting = 2
		stitching = 0

	tankgun
		icon_state = "tankgun"
		name = "tankgun"
		ru_name = "пневмострел"
		var/obj/item/tank/ballon = null //баллон
		var/obj/item/bullet = null //снаряд

		attackby(var/mob/M, var/obj/item/I)
			if(istype(I, /obj/item/tank))
				if(!ballon)
					ballon = I
					usr:drop()
					I.loc = src
					var/icon/I2 = new('items.dmi', "tankgun")
					var/icon/J = new('items.dmi', "oxygen")
					I2.Blend(J, ICON_OVERLAY)
					icon = I2


				else
					if(!bullet)
						bullet = I
						usr:drop()
						I.loc = src
			else
				if(!bullet)
					bullet = I
					usr:drop()
					I.loc = src

		verb/detach_tank()
			set src in world
			if(usr:get_slot("rhand"):SLOT == src || usr:get_slot("lhand"):SLOT == src)
				ballon.loc = usr.loc
				ballon = null
				icon = initial(icon)
				usr:get_slot("lhand", usr):refresh_slot()
				usr:get_slot("rhand", usr):refresh_slot()

		verb/detach_bullet()
			set src in world
			if(usr:get_slot("rhand"):SLOT == src || usr:get_slot("lhand"):SLOT == src)
				bullet.loc = usr.loc
				bullet = null
				usr:get_slot("lhand", usr):refresh_slot()
				usr:get_slot("rhand", usr):refresh_slot()

		proc/pew()
			if(ballon.get_pressure() > 100)
				bullet.damage_zone = usr:damagezone
				bullet.speed = round(ballon.get_pressure() / 9)
				bullet.loc = get_step(usr.loc, get_dir(bullet.target, src))
				bullet.Move(get_step(src, get_dir(bullet.target, src)))
				ballon.minus_pressure(ballon.get_pressure() / 9)
				bullet = null
	tasergun
		icon_state = "taser"
		name = "taser"
		ru_name = "тазер"
		var/obj/item/devicebattery/DB = null //батарейка
		var/obj/energy_sphere/bullet
		amperage = 1
		voltage = 1
		var/maxvltamp = 1700

		attackinhand(var/mob/M)
			M << browse(null,"window=[name]")
			var/list/powerstat = list()
			var/list/hrefs = list()
			powerstat.Add(fix1103("Вольтаж заряда: [voltage]"))
			powerstat.Add(fix1103("Сила тока заряда: [amperage]"))
			powerstat.Add(fix1103("Заряд батареи: [DB ? DB.charge_level : "батарея отсутствует"]"))
			hrefs.Add("voltage=1")
			hrefs.Add("amperage=1")
			hrefs.Add("battery=null")
			special_browse(M, nterface(powerstat, hrefs))

		Topic(href,href_list[])
			if(href_list["amperage"] == "1")
				amperage = input(usr, "Выставить силу тока","ваше значение",amperage) as num
				if(amperage <= 0)
					amperage = 1
			if(href_list["voltage"] == "1")
				voltage = input(usr, "Выставить напряжение","ваше значение",voltage) as num
				if(voltage <= 0)
					voltage = 1
			if(href_list["battery"] == "null")
				if(usr:get_slot("rhand"):SLOT == src || usr:get_slot("lhand"):SLOT == src)
					DB.loc = usr.loc
					DB = null
					icon = initial(icon)
					usr:get_slot("lhand", usr):refresh_slot()
					usr:get_slot("rhand", usr):refresh_slot()
			attackinhand(usr)

		attackby(var/mob/M, var/obj/item/I)
			if(istype(I, /obj/item/devicebattery))
				if(!DB)
					DB = I
					usr:drop()
					I.loc = src
					var/icon/I2 = new('items.dmi', "taser")
					var/icon/J = new('computer.dmi', I.icon_state)
					I2.Blend(J, ICON_OVERLAY)
					icon = I2
					attackinhand(usr)


		proc/pew()
			if(DB)
				if(DB.charge_level > 0 && DB.charge_level > amperage * voltage)
					if(amperage * voltage > maxvltamp)
						usr:call_message(5, "На [ru_name] был подан большой ток, все вокруг искрит.")
						usr:drop()
						usr:powerdamage((amperage * voltage) / 2)
					DB.charge_level -= amperage * voltage
					bullet = new /obj/energy_sphere(get_step(usr.loc, get_dir(target, src)))
					bullet.target = target
					target = null
					bullet.speed = 50
					bullet.amperage = amperage
					bullet.voltage = voltage
					bullet.Move(get_step(src, get_dir(bullet.target, src)))
					bullet = null

/obj/energy_sphere
	icon = 'items.dmi'
	icon_state = "electrode"
	voltage = 1
	amperage = 1

/obj/item/impactgrenage
	icon = 'items.dmi'
	icon_state = "grenage"
	ru_name = "граната"

	proc/gimpact()
		call_message(5, "[ru_name] срабатывает")
		del(src)

	secgrenage
		ru_name = "граната со слезоточивым газом"
		gimpact()
			var/turf/T = src.loc
			T.reagents.add_reagent("secgas", 50)
			..()

/obj/item/unconnected_cable
	name = "copper_cable"
	ru_name = "неподключенный кабель"
	icon_state = "copper"
	icon = 'power.dmi'

	attackinhand(var/mob/M)
		dir = turn(dir, 45)
		M.message_to_usr("Вы вертите [ru_name] в руках")
