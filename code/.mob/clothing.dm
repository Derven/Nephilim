/obj/item/clothing
	icon = 'items.dmi'

	uniform/basic
		ru_name = "одежда"
		icon_state = "uniform"
		def_cf = 0.5
		temperature_def = 0.3
		weight = 1

		engiform
			ru_name = "одежда инженера"
			icon_state = "engiform"
			def_cf = 0.7
			temperature_def = 0.5

	shoes
		ru_name = "тапок"
		icon_state = "blackshoes"
		def_cf = 0.1
		temperature_def = 0.1

	backpack/back
		ru_name = "рюкзак"
		icon_state = "backpack"
		def_cf = 0.1
		temperature_def = 0.1
		weight = 2

		attackby(var/mob/M, var/obj/item/I)
			call_message(3, "[usr] вставл€ет [I.ru_name] в [ru_name]")
			usr:drop()
			I.Move(src)

	gloves
		ru_name = "перчатка"
		icon_state = "yglove"
		def_cf = 0.1
		temperature_def = 0.1

		yglove
			ru_name = "изол€ционна€ перчатка"
			icon_state = "yglove"
			def_cf = 0.1
			temperature_def = 0.1

	socks
		ru_name = "носки"
		icon_state = "blacksocks"
		def_cf = 0.0
		temperature_def = 0.0

	boxers
		ru_name = "трусы"
		icon_state = "blackboxers"
		def_cf = 0.0
		temperature_def = 0.0

	mayka
		ru_name = "майка"
		icon_state = "mayka"
		def_cf = 0.0
		temperature_def = 0.0

	suit/spacesuit
		ru_name = "скафандр"
		icon_state = "spacesuit"
		def_cf = 0.7
		temperature_def = 2.7

	helmet/space
		ru_name = "космический шлем"
		icon_state = "spacehelm"
		def_cf = 0.7
		temperature_def = 2.7

/obj/item/storage