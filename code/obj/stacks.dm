/obj/item/stack
	icon = 'items.dmi'
	var/amount = 1
	var/list/craft_table = list()
	var/list/amounts = list()
	var/list/rnames = list()

	attackby(var/mob/M, var/obj/item/I)
		if(istype(I, src.type))
			amount += I:amount
			M:drop()
			del(I)
			name = "[amount] ����(�) �������"

	proc/check_amount(var/mob/M)
		if(amount <= 0)
			M.message_to_usr("[ru_name] ��������!")
			M:drop()
			del(src)

	attackinhand(var/mob/M)
		var/list/descr = list()
		var/list/myhrefs = list()
		var/i = 0
		for(var/d in craft_table)
			i++
			descr.Add("[rnames[i]] - ������� [amounts[i]] ������� [ru_name]")

		for(var/d in craft_table)
			myhrefs.Add("craft=[d]")

		M << browse(nterface(descr, myhrefs),"window=[name]")

	Topic(href,href_list[])
		if(href_list["craft"])
			var/mypath = text2path(href_list["craft"])
			var/i = 0
			for(var/cr in craft_table)
				i++
				if(cr == mypath && amounts[i] <= amount)
					var/atom/A = new mypath(usr.loc)
					call_message(5, "[usr] ������ [A]")
					amount -= amounts[i]
					check_amount(usr)

	metal
		name = "metal"
		ru_name = "����(�) �������"
		icon_state = "metal"
		craft_table = list(/obj/frame/wall, /obj/frame/computer)
		amounts = list(2, 1)
		rnames = list("���������: �����", "���������: ���������")

	glass
		name = "glass"
		ru_name = "����(�) ������"
		icon_state = "glass"
		craft_table = list()
		amounts = list()
		rnames = list()