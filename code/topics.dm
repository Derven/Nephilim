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
/atom/proc/nterface(var/desc, var/hrefs)
	var/msg = "<html><body>"
	var/i = 0
	for(var/d in desc)
		i++
		msg += "<a href='?src=\ref[src];[hrefs[i]]'>[d]</a><br>"
	msg += "</body></html>"
	return msg
