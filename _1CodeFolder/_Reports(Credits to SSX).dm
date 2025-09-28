var
	list/reports=new
	number = 0
proc/Reports(type)
	switch(type)
		if("Load") if(fexists("Saves/ReportFile"))
			var/savefile/E = new ("Saves/ReportFile")
			E["reports"] >> reports
			E["number"] >> number
			if(!reports) reports=new
		if("Save")
			var/savefile/E = new ("Saves/ReportFile")
			E["reports"] << reports
			E["number"] << number

/*
mob/Players
	verb
		Submit_Report()
			set category="Other"
			if(winget(client,"report","is-visible")=="false")
				winset(client,"report.key","text=\"[src.key]\"")
				winset(client,"report.ip","text=\"[src.client.address?src.client.address :(world.internet_address?world.internet_address :world.address)]\"")
				winset(client,"report.id","text=\"[src.client.computer_id]\"")
				winshow(client,"report",1)
		View()
			set name = ".view"
			var/br={"<html><body>"}
			var/dr={"</body></html>"}
			if(!reports.len)
				br+="Sorry! There are no reports!"
			else
				var/X=input("Which report would you like to Review?","Report Viewing") as null|anything in reports
				if(!X) return
				var/Reports/M = reports[X]
				for(var/x in M.vars -vars)
					br += "<br>[x] = [M.vars[x]]"
				winset(src, "reportview.viewing", "text=\"[M.NameID]\"")
			br+=dr
			src << browse(br,"window=reportbrowser")
			winset(src, "loadv", "text=")

		delete()
			set name = ".delete"
			var/m=winget(src,"reportview.viewing","text")
			if(m in reports)
				if(alert("Are you sure you want to Delete this report?","Delete this report","Yes","No")=="Yes")
					winset(src, "loadv", "text=\"Deleting [m]...\"")
					var/Reports/M = reports[m]
					reports -= m
					del M
					src << browse(null,"window=reportbrowser")
					winset(src, "reportview.viewing", "text=\"Report you were viewing has been deleted!\"")
					winset(src, "loadv", "text=\"Deleted [m]!\"")
		deleteall()
			set name = ".deleteall"
			if(alert("Are you sure you want to Delete every report?","Delete All Reports","Yes","No")=="Yes")
				winset(src, "loadv", "text=\"Deleting all reports...\"")
				for(var/x in reports)
					reports -= x
					global.number = 0
				src << browse(null,"window=reportbrowser")
				winset(src, "reportview.viewing", "text=\"Report you were viewing has been deleted!\"")
				winset(src, "loadv", "text=\"Deleted all reports!\"")
		submit()
			set name = ".submit"
			winset(src,"report.load","text=Submitting...;is-visible=true")
			if((src.Check(2))==FALSE)
				src.Check(1)
				return
			var/names = winget(src,"report.name","text")
			var/descs = winget(src,"report.desc","text")
			if(winget(src,"report.bug","is-checked")=="true")
				winset(src,"report.selected","text=Bug")
			else if(winget(src,"report.suggestion","is-checked")=="true")
				winset(src,"report.selected","text=Suggestion")
			else if(winget(src,"report.fix","is-checked")=="true")
				winset(src,"report.selected","text=Fix")
			var/types = winget(src,"report.selected","text")
			var/ip = "[src.client.address?src.client.address :(world.internet_address?world.internet_address :world.address)]"
			var/Reports/x = new(src.key,ip,src.client.computer_id,types,names,descs)
			if(x&&(x.NameID in reports))
				winset(src,"report.name","background-color=#fff")
				winset(src,"report.desc","background-color=#fff")
				winset(src,"report.load","text=Submitted!")
		clear()
			set name = ".clear"
			src.clearfields()
		clearv()
			set name = ".clearv"
			src.clearviewr()
	proc
		clearfields()
			winset(src,"report.bug","is-checked=true")
			winset(src,"report.Name","text=;background-color=#fff")
			winset(src,"report.desc","text=;background-color=#fff")
			winset(src,"report.selected","text=")
			winset(src,"report.load","text=")
		clearviewr()
			winset(src,"reportview.viewing","text =\"Click View Reports to see a list of reports!\"")
			src << browse(null,"window=reportbrowser")
			winset(src,"reportview.loadv","text=")
		Check(type)
			switch(type)
				if(1)
					if(!ckey(winget(src,"report.name","text")))
						winset(src,"report.load","text=\"Pink Box(es) contains error!\"")
						winset(src,"report.name","background-color=#ff69b4")
					if(!ckey(winget(src,"report.desc","text")))
						winset(src,"report.load","text=\"Pink Box(es) contains error!\"")
						winset(src,"report.desc","background-color=#ff69b4")
					for(var/X in reports)
						var/Reports/M = reports[X]
						if(M.Name == winget(src,"report.name","text"))
							winset(src,"report.desc","background-color=#ff69b4")
							winset(src,"report.load","text=\"Name is already in use!\"")
						if(M.Description == winget(src,"report.desc","text"))
							winset(src,"report.desc","background-color=#ff69b4")
							winset(src,"report.load","text=\"This bug has already been reported!!\"")
				if(2)
					if(!ckey(winget(src,"report.name","text"))) return FALSE
					if(!ckey(winget(src,"report.desc","text"))) return FALSE
					for(var/X in reports)
						var/Reports/M = reports[X]
						if(M.Name == winget(src,"report.name","text"))return FALSE
						if(M.Description == winget(src,"report.desc","text"))return FALSE
*/
Reports
	var
		Key
		IP_Address
		Computer_ID
		NameID
		Name
		Number = 0
		Type
		Description
	New(keys,ips,ids,type,names,descs)
		src.Key = keys
		src.IP_Address = ips
		src.Computer_ID = ids
		src.Type = type
		src.Description = descs
		src.Number = ++global.number
		src.Name = names
		global.number = Number
		src.NameID = "[names] ([Number])"
		reports[src.NameID] = src
