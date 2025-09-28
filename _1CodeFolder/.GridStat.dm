mob
	var

		griddisplay="stats"

#define SYSTEMTEXT "<font face='courier'><font color='#color'>"
#define SYSTEMTEXTEND "</font color></font face>"
#define SYSTEM "<font face='courier'><font color='#color'>\[SYSTEM: "




mob/proc
	GridStat()
		return
		if(!src.client)return
		var/list/lol=list("butt3","butt4")
		for(var/x in lol)
			winshow(src,x,1)

		while(src)
			if(!src.client)return

			switch(src.griddisplay)
				if("Inventory")
					var/Stats = 0
					Stats++
					src.GridStatPlacement("-Inventory-",null,Stats)
					for(var/obj/x in usr.contents)
						Stats++

						winset(src,"gridstatx","current-cell=1x[Stats]")
						src << output(x,"gridstatx")
						winset(src,"gridstatx","current-cell=2x[Stats]")
						src << output(x.suffix,"gridstatx")
						//src.GridStatPlacement(x],"[x.suffix]",Stats)

					winset(src,"gridstatx","cells=2x[Stats]")

				if("Stats")
					var/Stats = 0
					Stats++
					src.GridStatPlacement("-Statistics-",null,Stats)
					Stats++
					src.GridStatPlacement("Race:","[race.name]",Stats)
					Stats++
					src.GridStatPlacement("Birth:","[src.Spawn]",Stats)
					Stats++
					src.GridStatPlacement("Current Power:","[(Get_Scouter_Reading(src))]",Stats)
					Stats++
					src.GridStatPlacement("Base Power:","[src.Base]([src.potential_power_mult])",Stats)

					if(src.Admin)
						Stats++
						src.GridStatPlacement("-Admin-",null,Stats)
						Stats++
						src.GridStatPlacement("CPU","[world.cpu]%",Stats)
						Stats++
						src.GridStatPlacement("Cords","[usr.x],[usr.y],[usr.z]",Stats)

			sleep(10)




mob/proc/GridStatPlacement(var/Lulz,var/Omg,var/Wut,var/Lol="gridstatx")
	winset(src,Lol,"current-cell=1x[Wut]")
	src << output("[Lulz]",Lol)
	winset(src,Lol,"current-cell=2x[Wut]")
	src << output("[Omg]",Lol)


mob/Players/verb
	togglegrid(var/blah as text)
		set hidden=1
		set name=".togglegrid"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		winset(usr,,"rpanewindow.left=gridwindow")
		if(blah in list("Stats","Inventory"))
			usr.griddisplay=blah


var/welcome="<center>Welcome to Roleplay Rebirth!"

var/basehtml=({"			<html>
	<style type="text/css">
	<!--
	body {
	     color:#449999;
	     background-color:black;
	     font-size:12;
	     face:cambria;
	//-->
	</style>"})




mob/verb/browsertoggle(var/blah as text)
	set name=".togglebrowser"
	if(blah=="Story")
		usr<<browse({"[basehtml][Story]"})
	if(blah=="Rules")
		usr<<browse("[basehtml][Rules]")
	if(blah=="Ranks")
		usr<<browse("[basehtml][Ranks]")
	if(blah=="Updates")
		usr<<browse("[Updates]")
	if(blah=="Guide")
		usr<<browse("[basehtml][Guide]")
	if(blah=="Credits")
		usr<<browse("[basehtml][Credits]")
	if(blah=="TransTiers")
		usr<<browse("[basehtml][TransTiers]")
	if(blah=="AdminNotes")
		if(!usr.Admin)return
		usr<<browse("[basehtml][AdminNotes]")


