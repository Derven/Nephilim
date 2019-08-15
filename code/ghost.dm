/mob/dead/ghost
	icon = 'mob.dmi'
	icon_state = "ghost"
	invisibility = 90
	see_invisible = 91
	reality = 0
	density = 0

	verb/respawn()
		if(client)
			var/mob/living/human/respawner = new /mob/living/human()
			client.screen.Cut()
			client = null
			respawner.client = client

	verb/reboot()
		world.Reboot()