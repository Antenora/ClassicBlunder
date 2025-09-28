obj/Special
	Spawn
		density=0
		Destructable=0
		Grabbable=0
		invisibility=98

		var/gotoX
		var/gotoY
		var/gotoZ

		var/list/DefaultRaces=list()
		var/list/SpecialPermissions=list()

		//These are all additions; they can be negative to lower the various attributes.
		var/EconomyChange=0
		var/LearningChange=0
		var/IntelligenceChange=0
		var/ImaginationChange=0


mob
	proc
		ChooseSpawn()
			var/list/obj/Special/Spawn/Choices=list()
			var/SpawnFound=0
			for(var/obj/Special/Spawn/S in glob.Spawns)
				if(src.race.name in S.DefaultRaces)
					SpawnFound=1
					Choices.Add(S)
				if(src.ckey in S.SpecialPermissions)
					SpawnFound=1
					Choices.Add(S)
			if(!SpawnFound)
				src << "There are no spawns found for [src.race.name] characters! Contact the admin team."
				return

			var/Confirm
			var/obj/Special/Spawn/Choice

			while(Confirm!="Yes")
				Choice=input(src, "What spawn will you choose?") in Choices
				if(Choices.len<2)
					Confirm="Yes"
				else
					Confirm=alert(src, "[Choice] [Choice.desc] Is this where you want to hail from?", "Choose Spawn ([Choice])", "Yes", "No")

			if(Choice.EconomyChange!=0)
				src.EconomyMult+=Choice.EconomyChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.EconomyChange>0)
					src << "better at earning money."
				else
					src << "worse at earning money."
			if(Choice.LearningChange!=0)
				src.RPPMult+=Choice.LearningChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.LearningChange>0)
					src << "better at learning new skills."
				else
					src << "worse at learning new skills."
			if(Choice.IntelligenceChange!=0)
				src.Intelligence+=Choice.IntelligenceChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.IntelligenceChange>0)
					src << "better at thinking logically."
				else
					src << "worse at thinking logically."
			if(Choice.ImaginationChange!=0)
				src.Imagination+=Choice.ImaginationChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.ImaginationChange>0)
					src << "better at understanding belief."
				else
					src << "worse at understanding belief."

			src.Spawn=Choice.name
			src << "Your native location is [src.Spawn]."
			MoveToSpawn(src)
			src.loc = locate(Choice.gotoX, Choice.gotoY, Choice.gotoZ)


proc
	MoveToSpawn(var/mob/m)
		var/obj/Special/Spawn/Found
		for(var/obj/Special/Spawn/S in glob.Spawns)
			if(S.name==m.Spawn)
				Found=S
				break
		if(!Found)
			m << "You do not have a spawn that exists in the world. The admins have been notified."
			Log("Admin", "[ExtractInfo(m)]'s currently listed spawn ([m.Spawn]) does not exist in the world! Assign a new spawn name to them.")
		else
			m.loc = locate(Found.gotoX, Found.gotoY, Found.gotoZ)

	AddRace(var/Race, var/obj/Special/Spawn/S)
		if(!(Race in S.DefaultRaces))
			S.DefaultRaces.Add(Race)
			Log("Admin", "[Race] has been added to spawn point [S]'s default races.")
		else
			Log("Admin", "ERROR: [Race] is already part of spawn point [S]'s default races.")
	RemoveRace(var/Race, var/obj/Special/Spawn/S)
		if((Race in S.DefaultRaces))
			S.DefaultRaces.Remove(Race)
			Log("Admin", "[Race] has been removed from spawn point [S]'s default races.")
		else
			Log("Admin", "ERROR: [Race] is not part of spawn point [S]'s default races.")
	AddPermission(var/CKEY, var/obj/Special/Spawn/S)
		if(!(CKEY in S.SpecialPermissions))
			S.SpecialPermissions.Add(CKEY)
			Log("Admin", "[CKEY] has been added to spawn point [S]'s special permissions.")
		else
			Log("Admin", "[CKEY] is already on [S]'s special permissions.")
	RemovePermission(var/CKEY, var/obj/Special/Spawn/S)
		if(!(CKEY in S.SpecialPermissions))
			S.SpecialPermissions.Remove(CKEY)
			Log("Admin", "[CKEY] has been removed from spawn point [S]'s special permissions.")
		else
			Log("Admin", "[CKEY] is not part of spawn point [S]'s special permissions.")

mob
	Admin3
		verb/Spawn_Race_Add(var/obj/Special/Spawn/s in glob.Spawns)
			set category="Admin"
			var/newrace=input(src, "What race do you want to add to [s]'s spawns?", "Spawn Race Add") in races
			if(newrace)
				s.DefaultRaces.Add(newrace)
				Log("Admin", "[ExtractInfo(src)] added [newrace] to [s]'s default race spawns.")
		verb/Spawn_Race_Remove(var/obj/Special/Spawn/s in glob.Spawns)
			set category="Admin"
			var/newrace=input(src, "What race do you want to remove from [s]'s spawns?", "Spawn Race Add") in s.DefaultRaces
			if(newrace)
				s.DefaultRaces.Remove(newrace)
				Log("Admin", "[ExtractInfo(src)] removed [newrace] from [s]'s default race spawns.")
		verb/Spawn_Permission_Add(var/obj/Special/Spawn/s in glob.Spawns)
			set category="Admin"
			var/newrace=input(src, "What ckey do you want to add to [s]'s spawns?", "Spawn Ckey Add") as text|null
			if(newrace)
				s.SpecialPermissions.Add(newrace)
				Log("Admin", "[ExtractInfo(src)] added ckey [newrace] to [s]'s special permission spawns.")
		verb/Spawn_Permission_Remove(var/obj/Special/Spawn/s in glob.Spawns)
			set category="Admin"
			var/newrace=input(src, "What ckey do you want to remove from [s]'s spawns?", "Spwn Ckey Remove") in s.SpecialPermissions
			if(newrace)
				s.SpecialPermissions.Remove(newrace)
				Log("Admin", "[ExtractInfo(src)] removed [newrace] from [s]'s special permission spawns.")
		verb/Spawn_Swap(var/mob/m in players)
			set category="Admin"
			var/obj/Special/Spawn/s=input(src, "What spawn do you want to change [m] to? They are currently from [m.Spawn].", "Spawn Swap") in glob.Spawns

			Log("Admin", "[ExtractInfo(src)] swapped [ExtractInfo(m)]'s spawn from [m.Spawn] to [s]!")

			var/obj/Special/Spawn/os
			for(var/obj/Special/Spawn/gs in glob.Spawns)
				if(gs.name==src.Spawn)
					os=gs
					break

			m.RPPMult-=os.LearningChange
			m.EconomyMult-=os.EconomyChange
			m.Intelligence-=os.IntelligenceChange
			m.Imagination-=os.ImaginationChange

			m.Spawn=s.name

			m.RPPMult+=s.LearningChange
			m.EconomyMult+=s.EconomyChange
			m.Intelligence+=s.IntelligenceChange
			m.Imagination+=s.ImaginationChange

			if(m.Intelligence<0.25)
				m.Intelligence=0.25
			if(m.Imagination<0.25)
				m.Imagination=0.25


	Admin4
		verb
			Clear_Error_Log()
				set category="Admin"
				switch(input("Are you sure you would like to wipe the errors log?") in list("Yes","No"))
					if("Yes")
						if(fexists("Saves/Errors.log"))
							fdel("Saves/Errors.log")
							usr << "Errors.log has been deleted."
			Spawn_New()
				set category="Admin"
				var/obj/Special/Spawn/NewS=new()
				var/SName=input(src, "What is the name of the new spawn?", "New Spawn") as text|null
				if(!SName)
					src << "ERROR: No name given."
					del NewS
					return
				NewS.name=SName
				var/SDesc=input(src, "What is the description presented when selecting this spawn?", "New Spawn") as text
				NewS.desc=SDesc

				var/lX=input(src, "What is the x coordinate of the new spawn?", "New Spawn") as num|null
				var/lY=input(src, "What is the y coordinate of the new spawn?", "New Spawn") as num|null
				var/lZ=input(src, "What is the z coordinate of the new spawn?", "New Spawn") as num|null
				if(!locate(lX, lY, lZ))
					src << "ERROR: Invalid location specified."
					del NewS
					return
				NewS.gotoX=lX
				NewS.gotoY=lY
				NewS.gotoZ=lZ

				var/eC=input(src, "What is the economy change of the new spawn? This can be negative.", "New Spawn") as num
				var/lC=input(src, "What is the learning change of the new spawn? This can be negative.", "New Spawn") as num
				var/tC=input(src, "What is the intelligence change of the new spawn? This can be negative.", "New Spawn") as num
				var/gC=input(src, "What is the imagination change of the new spawn? This can be negative.", "New Spawn") as num
				NewS.EconomyChange=eC
				NewS.LearningChange=lC
				NewS.IntelligenceChange=tC
				NewS.ImaginationChange=gC

				var/Enter
				var/list/raceList = races.Copy()
				raceList += "Cancel"
				while(Enter!="Cancel")
					Enter=input(src, "Enter the race that will be able to select this spawn. You may add additional races after entering. Enter Cancel to stop entering races.", "New Spawn") in raceList
					if(Enter!="Cancel")
						var/racename = splittext("[Enter]", "/race/")
						NewS.DefaultRaces.Add(racename[1])
						raceList -= Enter
						src << "Added [racename[1]] to default races for [NewS]."

				glob.Spawns.Add(NewS)
				src << "Added [NewS] successfully to global list!"
			Set_Midgar_Spawn()
				set category="Admin"
				var/obj/Special/Spawn/NewS=new()
				NewS.name="The World"
				NewS.desc="Our miraculous homeland. A small, livable pocket in an otherwise vast, empty(?) universe, and the only piece of the Old World that remains."


				NewS.gotoX=307
				NewS.gotoY=139
				NewS.gotoZ=1

				var/eC=input(src, "What is the economy change of the new spawn? This can be negative.", "New Spawn") as num
				var/lC=input(src, "What is the learning change of the new spawn? This can be negative.", "New Spawn") as num
				var/tC=input(src, "What is the intelligence change of the new spawn? This can be negative.", "New Spawn") as num
				var/gC=input(src, "What is the imagination change of the new spawn? This can be negative.", "New Spawn") as num
				NewS.EconomyChange=eC
				NewS.LearningChange=lC
				NewS.IntelligenceChange=tC
				NewS.ImaginationChange=gC

				var/Enter
				var/list/raceList = races.Copy()
				raceList += "Cancel"
				while(Enter!="Cancel")
					Enter=input(src, "Enter the race that will be able to select this spawn. You may add additional races after entering. Enter Cancel to stop entering races.", "New Spawn") in raceList
					if(Enter!="Cancel")
						var/racename = splittext("[Enter]", "/race/")
						NewS.DefaultRaces.Add(racename[1])
						raceList -= Enter
						src << "Added [racename[1]] to default races for [NewS]."

				glob.Spawns.Add(NewS)
				src << "Added [NewS] successfully to global list!"

			Spawn_Delete()
				set category="Admin"
				var/obj/Special/Spawn/Chois=input(src, "What spawn do you want to delete?", "Delete Spawn") in glob.Spawns
				var/Confirm=alert(src, "Are you sure you want to delete [Chois]?", "Delete Spawn", "No", "Yes")
				if(Confirm=="No")
					src << "You do not delete [Chois]."
					return
				glob.Spawns.Remove(Chois)
				Log("Admin", "[ExtractInfo(src)] has deleted spawn point [Chois].")
				del Chois


			Spawn_Edit()
				set category="Admin"
				var/obj/Special/Spawn/SC=input("What spawn are you editing?", "Edit Spawn") in glob.Spawns
				var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
				var/list/B=new
				Edit+="[SC]<br>[SC.type]"
				Edit+="<table width=10%>"
				for(var/C in SC.vars) B+=C
				B.Remove("Package","bound_x","bound_y","step_x","step_y","Admin","Profile", "GimmickDesc", "NoVoid", "BaseProfile", "Form1Profile", "Form2Profile", "Form3Profile", "Form4Profile", "Form5Profile")
				for(var/C in B)
					Edit+="<td><a href=byond://?src=\ref[SC];action=edit;var=[C]>"
					Edit+=C
					Edit+="<td>[Value(SC.vars[C])]</td></tr>"
				Edit += "</html>"
				usr<<browse(Edit,"window=[SC];size=450x600")