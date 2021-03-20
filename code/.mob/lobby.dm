/mob/living/lobbyman
	icon = 'hydroponics.dmi'
	name = "justforlobby"
	icon_state = "plant"
	density = 0
	desc = "все мы отчасти овощи"

	New()
		var/atom/A = pick(PM)
		loc = A.loc
		spawn(5)
			if(!client)
				loc = initial(loc)
			else
				var/list/lobbystat = list()
				var/list/hrefs = list()
				lobbystat.Add(fix1103("Войти в игру"))
				lobbystat.Add(fix1103("Не входить в игру"))
				hrefs.Add("enter=1")
				hrefs.Add("enter=0")
				special_browse(usr, nterface(lobbystat, hrefs))
				special_browse(usr, nterface(lobbystat, hrefs))

	Topic(href,href_list[])
		if(href_list["enter"] == "1")
			usr << browse(null,"window=[name]")
			var/mob/living/human/gamer = new()
			gamer.client = usr.client
		if(href_list["enter"] != "1")
			return //да, здесь код делает ебаное ничего