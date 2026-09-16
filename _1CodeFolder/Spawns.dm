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
		var/EconomyChange=1
		var/LearningChange=1
		var/IntelligenceChange=1
		var/ImaginationChange=1
		var/SpawnLocation="None"

		var/Afterlife=0 // decides if you start dead here or not


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
				Choice=Ask(src, "What spawn will you choose?", "", null, "pick", Choices, 0)
				if(Choices.len<2)
					Confirm="Yes"
				else
					Confirm=Ask(src, "[Choice] [Choice.desc] Is this where you want to hail from?", "Choose Spawn ([Choice])", null, "confirm", null, 1, "Yes", "No")

			if(Choice.EconomyChange!=1)
				src.EconomyMult*=Choice.EconomyChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.EconomyChange>1)
					src << "better at earning money."
				else
					src << "worse at earning money."
			if(Choice.LearningChange!=1)
				src.RPPMult*=Choice.LearningChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.LearningChange>1)
					src << "better at learning new skills."
				else
					src << "worse at learning new skills."
			if(Choice.IntelligenceChange!=1)
				src.Intelligence*=Choice.IntelligenceChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.IntelligenceChange>1)
					src << "better at thinking logically."
				else
					src << "worse at thinking logically."
			if(Choice.ImaginationChange!=1)
				src.Imagination*=Choice.ImaginationChange
				src << "Due to growing up in [Choice], you are \..."
				if(Choice.ImaginationChange>1)
					src << "better at understanding belief."
				else
					src << "worse at understanding belief."

			src.Spawn=Choice.name
			src << "Your native location is [src.Spawn]."
			src.SpawnArea = Choice.SpawnLocation
			src << "Your native location displays as [src.SpawnArea]."
			if(src.Spawn == "Soul Society" || src.Spawn == "Hueco Mundo" || Choice.Afterlife == 1)
				src.Dead = 1
				src.KeepBody = 1
				src << "Because you're spawning in an Afterlife, you are dead!"
			MoveToSpawn(src)
			src.loc = locate(Choice.gotoX, Choice.gotoY, Choice.gotoZ)


proc
	MoveToSpawn(mob/m)
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
		verb/Spawn_Race_Add()
			set category="Admin"
			var/obj/Special/Spawn/s = PromptArgList(usr, args, 1, "Spawn Race Add", glob.Spawns)
			if(isnull(s)) return
			if(!src.Alert("Are you sure you want to add a race to spawns?")) return
			var/newrace=Ask(src, "What race do you want to add to [s]'s spawns?", "Spawn Race Add", null, "pick", races, 0)
			if(newrace)
				s.DefaultRaces.Add(newrace)
				Log("Admin", "[ExtractInfo(src)] added [newrace] to [s]'s default race spawns.")
		verb/Spawn_Race_Remove()
			set category="Admin"
			var/obj/Special/Spawn/s = PromptArgList(usr, args, 1, "Spawn Race Remove", glob.Spawns)
			if(isnull(s)) return
			if(!src.Alert("Are you sure you want to remove a race from spawns?")) return
			var/newrace=Ask(src, "What race do you want to remove from [s]'s spawns?", "Spawn Race Add", null, "pick", s.DefaultRaces, 0)
			if(newrace)
				s.DefaultRaces.Remove(newrace)
				Log("Admin", "[ExtractInfo(src)] removed [newrace] from [s]'s default race spawns.")
		verb/Spawn_Permission_Add()
			set category="Admin"
			var/obj/Special/Spawn/s = PromptArgList(usr, args, 1, "Spawn Permission Add", glob.Spawns)
			if(isnull(s)) return
			if(!src.Alert("Are you sure you want to add a key to spawns?")) return
			var/newrace=PromptKnownKey(src, "Spawn Ckey Add")
			if(newrace)
				s.SpecialPermissions.Add(newrace)
				Log("Admin", "[ExtractInfo(src)] added ckey [newrace] to [s]'s special permission spawns.")
		verb/Spawn_Permission_Remove()
			set category="Admin"
			var/obj/Special/Spawn/s = PromptArgList(usr, args, 1, "Spawn Permission Remove", glob.Spawns)
			if(isnull(s)) return
			if(!src.Alert("Are you sure you want to remove a key from spawnsr?")) return
			var/newrace=Ask(src, "What ckey do you want to remove from [s]'s spawns?", "Spwn Ckey Remove", null, "pick", s.SpecialPermissions, 0)
			if(newrace)
				s.SpecialPermissions.Remove(newrace)
				Log("Admin", "[ExtractInfo(src)] removed [newrace] from [s]'s special permission spawns.")
		verb/Spawn_Swap()
			set category="Admin"
			var/mob/m = PromptArg(usr, args, 1, "Spawn Swap", "players")
			if(isnull(m)) return
			if(!src.Alert("Are you sure you want to swap spawns?")) return
			var/obj/Special/Spawn/s=Ask(src, "What spawn do you want to change [m] to? They are currently from [m.Spawn].", "Spawn Swap", null, "pick", glob.Spawns, 0)

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
				switch(Ask(usr, "Are you sure you would like to wipe the errors log?", "", null, "pick", list("Yes","No"), 0))
					if("Yes")
						if(fexists("Saves/Errors.log"))
							fdel("Saves/Errors.log")
							usr << "Errors.log has been deleted."
			Spawn_New()
				set category="Admin"
				var/obj/Special/Spawn/NewS=new()
				var/SName=Ask(src, "What is the name of the new spawn?", "New Spawn", null, "text", null, 1)
				if(!SName)
					src << "ERROR: No name given."
					del NewS
					return
				NewS.name=SName
				var/SDesc=Ask(src, "What is the description presented when selecting this spawn?", "New Spawn", null, "text", null, 0)
				NewS.desc=SDesc

				var/lX=Ask(src, "What is the x coordinate of the new spawn?", "New Spawn", null, "num", null, 1)
				var/lY=Ask(src, "What is the y coordinate of the new spawn?", "New Spawn", null, "num", null, 1)
				var/lZ=Ask(src, "What is the z coordinate of the new spawn?", "New Spawn", null, "num", null, 1)
				if(!locate(lX, lY, lZ))
					src << "ERROR: Invalid location specified."
					del NewS
					return
				NewS.gotoX=lX
				NewS.gotoY=lY
				NewS.gotoZ=lZ

				var/eC=Ask(src, "What is the economy change of the new spawn?", "New Spawn", null, "num", null, 0)
				var/lC=Ask(src, "What is the learning change of the new spawn?", "New Spawn", null, "num", null, 0)
				var/tC=Ask(src, "What is the intelligence change of the new spawn?", "New Spawn", null, "num", null, 0)
				var/gC=Ask(src, "What is the imagination change of the new spawn?", "New Spawn", null, "num", null, 0)
				NewS.EconomyChange=eC
				NewS.LearningChange=lC
				NewS.IntelligenceChange=tC
				NewS.ImaginationChange=gC

				switch(Ask(src, "Is the new spawn going to be in an Afterlife?", "New Spawn", null, "pick", list("Yes","No"), 0))
					if("Yes")
						NewS.Afterlife=1
					if("No")
						NewS.Afterlife=0

				var/Enter
				var/list/raceList = races.Copy()
				raceList += "Cancel"
				while(Enter!="Cancel")
					Enter=Ask(src, "Enter the race that will be able to select this spawn. You may add additional races after entering. Enter Cancel to stop entering races.", "New Spawn", null, "pick", raceList, 0)
					if(Enter!="Cancel")
						var/racename = splittext("[Enter]", "/race/")
						NewS.DefaultRaces.Add(racename[1])
						raceList -= Enter
						src << "Added [racename[1]] to default races for [NewS]."

				glob.Spawns.Add(NewS)
				src << "Added [NewS] successfully to global list!"
			Spawn_Delete()
				set category="Admin"
				var/obj/Special/Spawn/Chois=Ask(src, "What spawn do you want to delete?", "Delete Spawn", null, "pick", glob.Spawns, 0)
				var/Confirm=Ask(src, "Are you sure you want to delete [Chois]?", "Delete Spawn", null, "confirm", null, 1, "No", "Yes")
				if(Confirm=="No")
					src << "You do not delete [Chois]."
					return
				glob.Spawns.Remove(Chois)
				Log("Admin", "[ExtractInfo(src)] has deleted spawn point [Chois].")
				del Chois


			Spawn_Edit()
				set category="Admin"
				var/obj/Special/Spawn/SC=Ask(usr, "What spawn are you editing?", "Edit Spawn", null, "pick", glob.Spawns, 0)
				var/list/B = list()
				for(var/C in SC.vars) B += C
				B.Remove("Package","bound_x","bound_y","step_x","step_y","Admin","Profile", "GimmickDesc", "NoVoid", "BaseProfile", "Form1Profile", "Form2Profile", "Form3Profile", "Form4Profile", "Form5Profile")
				usr.client?.SheetShow("edit:\ref[SC]", "EDIT", "[SC]", "[SC.type]", SheetVarRows(SC, B), "a name to edit")
