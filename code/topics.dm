/*
	var/body = {"<html><body>Moneybag ATM ID:[swipeid.name] credits:[swipeid.credits] cubits:[swipeid.cubits]<hr>
	<a href='?src=\ref[src];action=refresh'>refresh</a></br>
	<a href='?src=\ref[src];action=ctoc'>cubits to credits</a></br>
	<a href='?src=\ref[src];action=g100'>give 100 credit</a></br>
	<a href='?src=\ref[src];action=g50'>give 50 credit</a></br>
	<a href='?src=\ref[src];action=g10'>give 10 credit</a></br>
	"}

	Topic(href,href_list[])
		if(href_list["yesorno"] == "y")
			restartN.Remove(usr.key)
			restartY.Add(usr.key)
			usr << "\red Yes, i want restart."
		if(href_list["yesorno"] == "n")
			restartY.Remove(usr.key)
			restartN.Add(usr.key)
			usr << "\blue Pls, no."
*/
/atom/proc/special_browse(var/mob/M, var/ibody)
	M << browse(ibody,"window=[name]")
	M << browse_rsc('zaebok.png',"space.png")
	winset(M, name, "alpha=225")

/atom/proc/nterface(var/desc, var/hrefs)
	var/msg = {"<html><body background=\"space.png\" vlink=\"#8FE8CA\" link=\"#8FE8CA\" alink=\"#8FE8CA\">
	<style>
	a{
    	text-decoration: none;
    }
    a:hover{
    	text-decoration: none;
    	color: #E0F9E6;
    }
    </style>"}
	var/i = 0
	for(var/d in desc)
		i++
		msg += "<b><a href='?src=\ref[src];[hrefs[i]]'>&#x203A; [d]</a></b><br>"
	msg += "</body></html>"
	return msg
