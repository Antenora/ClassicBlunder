/mob/Admin3/verb/MasteryUp(obj/Skills/x in world)
	if(x.vars["Mastery"])
		x.Mastery++
		src<<"[x] is now [x.Mastery]!"
	else
		src<<"[x] has no mastery variable!"

obj/Skills/Utility
//General

	Teachz
		desc="Teach a younger character how to develop themselves, or even pass on signature skills!"
		var/LastTeach//holds a realtime
		verb/Teach()
			set category="Utility"
			set name="Train Student"
			if(src.Using)
				return
			src.Using=1
			var/list/mob/Players/Students=list("Cancel")
			for(var/mob/Players/P in oview(1, usr))
				if(P.EraAge>usr.EraAge||usr.Timeless)
					Students.Add(P)
			if(Students.len<2)
				usr << "There's no one nearby to train!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "What person do you want to train?  This will help access their potential if they have any latent development, or give them knowledge directly if not.", "Train") in Students
			if(Choice=="Cancel")
				src.Using=0
				return
			if(world.realtime<Choice.LastTeach)
				usr << "It's too soon to train this person again!  (Wait [round((Choice.LastTeach-world.realtime)/Hour(1), 0.1)] hours)"
				src.Using=0
				return
			var/Amount=input(usr, "How much donate RPP are you using? You have [usr.RPPDonate].", "Train ([usr.RPPDonate] remaining RPP)") as num|null
			if(!Amount||Amount==null||Amount<0)
				src.Using=0
				return


			if(Amount>usr.RPPDonate)
				Amount=usr.RPPDonate
			if(Amount>50)
				Amount=50
			switch(input(Choice, "[usr] would like to donate [Amount] RPP to you.", "Teach Consent") in list("Allow","Deny"))
				if("Deny")
					src.Using=0
					return
			Choice.RPPSpendable+=(Amount*Choice.GetRPPMult())
			usr.RPPDonate-=Amount
			if(usr.isRace(SHINJIN)&&usr.ShinjinAscension=="Kai")
				usr.potential_gain(Amount/glob.progress.RPPDaily*50)//kais have a 0.1 potential rate so this is only x5 potential in reality and i really dont think the fuckers are gonna be out there slaying npcs
			OMsg(usr, "[usr] passes some of their knowledge to [Choice]!")
			Choice.LastTeach=world.realtime+Day(1)
			src.Using=0
		verb/Teach_Skill()
			set category="Utility"
			set name="Teach Student"
			if(src.Using)
				return
			var/list/mob/Players/Students=list("Cancel")
			for(var/mob/Players/P in oview(1, usr))
				if(P.EraAge>usr.EraAge||usr.Timeless)
					Students.Add(P)
			if(Students.len<2)
				usr << "There's no one nearby to teach!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "What person do you want to teach?  This will help them learn basic skills that you've already learned.", "Teach") in Students
			if(Choice=="Cancel")
				src.Using=0
				return

			var/list/obj/Skills/SkillsKnown=list("Cancel")
			for(var/obj/Skills/s in usr.contents)
				if(s.Copyable||!s:LockOut)
					var/NotFound=1
					for(var/obj/Skills/Known in Choice.contents)
						if(s.type==Known.type)
							NotFound=0
							break
					if(NotFound)
						SkillsKnown.Add(s)
			if(SkillsKnown.len<2)
				usr << "You don't know any skills [Choice] does not!"
				src.Using=0
				return

			if(world.realtime<Choice.LastTeach)
				usr << "It's too soon to teach this person again!  (Wait [round((Choice.LastTeach-world.realtime)/Hour(1), 0.1)] hours)"
				src.Using=0
				return

			var/obj/Skills/Choice2=input(usr, "What skill do you wish to teach?  This will share the costs of learning between you and the student.", "Teach") in SkillsKnown
			if(Choice2=="Cancel")
				src.Using=0
				return

			switch(input(Choice, "[usr] would like to teach you [Choice2] to you.", "Teach Consent") in list("Allow","Deny"))
				if("Deny")
					src.Using=0
					return

			if(usr.RPPDonate>=Choice2.SkillCost*0.5)
				if(Choice.SpendRPP((Choice2.SkillCost*0.5/Choice.GetRPPMult()), Choice2, Training=1))
					Choice.AddSkill( new Choice2.type )
					usr.RPPDonate-=Choice2.SkillCost*0.5
					if(usr.isRace(SHINJIN)&&usr.ShinjinAscension=="Kai")
						usr.potential_gain(Choice2.SkillCost*0.5/glob.progress.RPPDaily*50)//kai only have 0.1 potential rate so this is only x5
					OMsg(usr, "[usr] passes some of their knowledge to [Choice]!")
					Choice.LastTeach=world.realtime+Day(1)
					src.Using=0
					return
			else
				OMsg(usr, "[usr] fails to pass knowledge to [Choice]!")
				src.Using=0
				return

		//later
		verb/Teach_Signature()
			set category="Utility"
			set hidden=1


	Cooking
		var/recipes/savedRecipes = new()
		var/recipe/currentMeal
		Mastery = 1
		suffix="Meal"
		desc="Cook up a feast!"
		verb/Cooking()
			set category="Utility"
			var/option = input(usr, "What do you want to do? Your current meal is [currentMeal]", "Cooking") in list("Cook Meal", "Set Current Meal","Make Recipe", "Alter Recipe", "Delete Recipe", "Share Recipe", "Cancel")
			switch(option)
				if("Cook Meal")
					if(savedRecipes.savedRecipes.len==0)
						usr << "You don't have any recipes made!"
						return
					if(!currentMeal)
						usr << "You don't have a meal set!"
						return
					if(src.Using)
						usr << "You're already preparing a meal!"
						return
					if(usr.passive_handler.Get("Piloting")||usr.HasPossessive())
						usr << "You're not capable of necessary precision!"
						return
					if(usr.TotalFatigue>=90)
						usr << "You're too exhausted to cook more!"
						return
					if(usr.Grab)
						usr << "You need free hands!"
						return
					if(!usr.HasMoney(glob.progress.EconomyCost*0.02))
						usr << "You don't have enough money to make a single passable meal!"
						return
					src.Using=1


					var/Count=input(usr, "How many [currentMeal.name]s are you cooking?", "Count") as num
					if(Count == 0)
						Using = 0
						return
					if(Count<1)
						Count=1
					if(Count>9)
						Count=9
					var/rem=100-usr.TotalFatigue
					rem/=10
					rem=round(rem)
					if(Count>rem)
						Count=rem
					var/MatCost=Count*glob.progress.EconomyCost*0.02
					if(!usr.HasMoney(MatCost))
						usr << "You don't have enough money to make [Count] [currentMeal.name]!"
					for(var/c=0, c<Count, c++)
						var/obj/Items/Edibles/Food/M=new
						M.name=currentMeal.name
						M.icon=currentMeal.icon
						M.icon_state=currentMeal.icon_state
						M.pixel_x=currentMeal.pixel_x
						M.pixel_y=currentMeal.pixel_y
						M.EatText = currentMeal.eat_text
						M.desc = currentMeal.description
						usr.AddItem(M)
						if(currentMeal.drink)
							M.EatToxicity=rand(src.Mastery-1,5+src.Mastery)
							if(M.EatToxicity<0)
								M.EatToxicity=0
						M.EatNutrition=rand(src.Mastery-1,src.Mastery+1)
						if(M.EatNutrition<0)
							M.EatNutrition=0
						if(M.EatNutrition >= 6) M.EatNutrition = 5
						M.desc += "<br><br><b>Quality:<b> "
						switch(M.EatNutrition)
							if(0)
								M.desc+="Travesty ([M.EatNutrition])"
							if(1)
								M.desc+="Common ([M.EatNutrition])"
							if(2 to 9999)
								M.desc+="Delicious ([M.EatNutrition])"
						usr.GainFatigue(10/Mastery)

					usr.Frozen=2
					var/preppingtext=replacetext(currentMeal.prepare_text, "usrName", "[usr]")
					OMsg(usr, "[preppingtext]")
					usr.TakeMoney(MatCost)
					sleep(30)
					usr.Frozen=0
					src.Using=0
				if("Set Current Meal")
					if(savedRecipes.savedRecipes.len==0)
						usr << "You don't have any recipes made!"
						return
					var/list/recs = savedRecipes.listRecipes()
					recs += "Cancel"
					var/recipe = input(usr, "What recipe do you want to set as your current recipe?", "Current Recipe") in recs
					if(recipe == "Cancel")
						return
					usr << "Current Meal set to [recipe]!"
					currentMeal = savedRecipes.findByName(recipe)
				if("Make Recipe")
					var/mealType = input(usr, "Is the meal a drink, a food, or both?", "Cooking") in list("Drink", "Food")
					var/name = input(usr, "What's the name of the meal?", "Cooking") as text|null
					if(name == null || name == "")
						return
					var/selectedIcon = input("What icon for the meal?", "Cooking") as icon|null
					var/selectedIconState = input("What icon state for the meal?", "Cooking") as text|null
					var/selectedX = input("Pixel X of the meal?", "Cooking") as num|null
					var/selectedY = input("Pixel Y of the meal?", "Cooking") as num|null
					var/selectedeatText = input("What do you want the food to say when it's consumed? Typing usrName will macro it to replace with the eater's name.", "Cooking") as text|null
					var/selectedpreptext = input("What do you want the meal to say when you're cooking it? Typing usrName will macro it to replace with the maker's name.", "Cooking") as text|null
					var/selecteddescription = input("What do you want the description to be?", "Cooking") as text|null
					var/recipe/newRecipe = new(name,selectedIcon,selectedIconState,selectedX,selectedY,selectedeatText,selectedpreptext,selecteddescription, mealType)
					savedRecipes.addRecipe(newRecipe)
				if("Alter Recipe")
					if(savedRecipes.savedRecipes.len==0)
						usr << "You don't have any recipes made!"
						return
					var/list/recs = savedRecipes.listRecipes()
					recs += "Cancel"
					var/recipe = input(usr, "What recipe do you want to alter?", "Altering Recipe") in recs
					if(recipe=="Cancel")
						return
					var/recipe/actualRecipe = savedRecipes.findByName(recipe)
					if(currentMeal == actualRecipe)
						currentMeal = null
					var/altering = input("What do you want to alter?" ,"Altering Recipe") in list("Name", "Preperation Text", "Eat Text", "Icon", "Pixel_X", "Pixel_Y", "Description", "Meal Type")
					switch(altering)
						if("Name")
							var/newName = input("What's the new name? The current name is [actualRecipe.name]", "Altering Name") as text|null
							if(newName==null || newName == "")
								return
							actualRecipe.name = newName
						if("Preperation Text")
							var/newprep = input("What's the new prepare text? The current prepare text is [actualRecipe.prepare_text]", "Altering Prepare Text") as text|null
							if(newprep==null || newprep == "")
								return
							actualRecipe.prepare_text = newprep
						if("Eat Text")
							var/newprep = input("What's the new eat text? The current eat text is [actualRecipe.eat_text]", "Altering Eat Text") as text|null
							if(newprep==null || newprep == "")
								return
							actualRecipe.eat_text = newprep
						if("Icon")
							var/newprep = input("What's the new icon? The current icon is [actualRecipe.icon]", "Altering Icon") as icon|null
							if(newprep==null)
								return
							actualRecipe.icon = newprep
						if("Pixel_X")
							var/newprep = input("What's the new pixel x? The current pixel_x is [actualRecipe.pixel_x]", "Altering Pixel X") as num|null
							if(newprep==null || newprep == "")
								return
							actualRecipe.pixel_x = newprep
						if("Pixel_Y")
							var/newprep = input("What's the new prepare text? The current pixel_y is [actualRecipe.pixel_y]", "Altering Pixel Y") as num|null
							if(newprep==null || newprep == "")
								return
							actualRecipe.pixel_y = newprep
						if("Description")
							var/newprep = input("What's the new description? The current description is [actualRecipe.description]", "Altering Description") as text|null
							if(newprep==null || newprep == "")
								return
							actualRecipe.description = newprep
						if("Meal Type")
							var/typeing
							if(actualRecipe.meal)
								typeing = "Meal"
							if(actualRecipe.drink)
								typeing = "Drink"
							var/mealType = input("What's sort of meal is this? The type is currently [typeing]", "Altering Meal Type") in list("Drink", "Food")
							if(mealType=="Food")
								actualRecipe.meal = TRUE
								actualRecipe.drink = FALSE
							if(mealType == "Drink")
								actualRecipe.meal = FALSE
								actualRecipe.drink = TRUE

				if("Delete Recipe")
					if(savedRecipes.savedRecipes.len==0)
						usr << "You don't have any recipes made!"
						return
					var/list/recs = savedRecipes.listRecipes()
					recs += "Cancel"
					var/recipe = input(usr, "What recipe do you want to delete?", "Deleting Recipe") in recs
					if(recipe=="Cancel")
						return
					var/confirm = input("Are you sure you want to delete [recipe]?", "Delete Recipe") in list("Yes","No")
					if(confirm=="No")
						return
					var/recipe/recc = savedRecipes.findByName(recipe)
					if(currentMeal == recc)
						currentMeal = null
					savedRecipes.removeByName(recipe)
				if("Share Recipe")
					var/list/recs = savedRecipes.listRecipes()
					recs += "Cancel"
					var/recipe = input(usr, "What recipe do you want to share?", "Sharing Recipe") in recs
					if(recipe == "Cancel")
						return
					var/list/mobs = list()
					mobs += "Cancel"
					for(var/mob/Players/m in oview(5, usr))
						if(locate(/obj/Skills/Utility/Cooking,m))
							mobs += m
					if(mobs.len == 1)
						usr << "There's no valid targets near you!"
						return
					var/who = input(usr, "Who do you want to share it to?", "Sharing Recipe") in mobs
					if(who=="Cancel")
						return
					var/confirm = input(who, "Do you want to accept [recipe] from [usr]?", "Sharing Cooking Recipe") in list("Yes", "No")
					if(confirm=="No")
						return
					for(var/obj/Skills/Utility/Cooking/c in who)
						c.savedRecipes.addRecipe(savedRecipes.findByName(recipe))
				if("Cancel")
					return

	Brewing
		suffix="Booze"
		desc="Brew up a party!"
		var/NonAlcoholic=0
		verb/Toggle_Alcohol()
			set category="Utility"
			src.NonAlcoholic=!src.NonAlcoholic
			if(src.NonAlcoholic)
				usr << "You <font color='red'>WILL NOT</font color> make drinks with alcohol in them!"
			else if(!src.NonAlcoholic)
				usr << "You <font color='green'>WILL</font color> make drinks with alcohol in them!"
		verb/Set_Drink()
			set category="Utility"
			src.suffix=input(usr, "What are you brewing?", "Brewing") as text|null
			if(src.suffix==null || src.suffix=="")
				src.suffix="Booze"
			src.icon=input("What icon?") as icon|null
			src.icon_state=input("Icon state?") as text|null
			src.pixel_x=input("Pixel X?") as num|null
			src.pixel_y=input("Pixel Y?") as num|null
		verb/Brew_Drink()
			set category="Utility"
			if(src.Using)
				usr << "You're already preparing a meal!"
				return
			if(usr.HasPiloting()||usr.HasPossessive())
				usr << "You're not capable of necessary precision!"
				return
			if(usr.TotalFatigue>=90)
				usr << "You're too exhausted to cook more!"
				return
			if(usr.Grab)
				usr << "You need free hands!"
				return
			if(!usr.HasMoney(src.Mastery*glob.progress.EconomyCost*0.0625))
				usr << "You don't have enough money to make a single passable drink!"
				return
			src.Using=1

			var/Count=input(usr, "How many [src.suffix] are you brewing?", "Count") as num
			if(Count<1)
				Count=1
			if(Count>9)
				Count=9
			var/rem=100-usr.TotalFatigue
			rem/=10
			rem=round(rem)
			if(Count>rem)
				Count=rem
			var/MatCost=Count*src.Mastery*glob.progress.EconomyCost*0.0625
			if(!usr.HasMoney(MatCost))
				usr << "You don't have enough money to make [Count] [src.suffix]!"
			for(var/c=0, c<Count, c++)
				var/obj/Items/Edibles/Booze/M=new
				M.name=src.suffix
				M.icon=src.icon
				M.icon_state=src.icon_state
				if(!M.icon || M.icon==null)
					M.icon='Foods.dmi'
					M.icon_state="Booze"
				M.pixel_x=src.pixel_x
				M.pixel_y=src.pixel_y
				M.EatNutrition=rand(src.Mastery-1,max(src.Mastery+1,3))
				if(!src.NonAlcoholic)
					M.EatToxicity=rand(src.Mastery-1,5+src.Mastery)
					if(M.EatToxicity<0)
						M.EatToxicity=0
				if(M.EatNutrition<0)
					M.EatNutrition=0
				usr.GainFatigue(10/Mastery)
				usr.AddItem(M)
				if(M.EatNutrition>2)
					if(M.name=="Booze")
						M.name="High-Quality Alcohol"
					M.EatText="drinks [M.name] with a delighted expression!"
				else if(M.EatNutrition>0)
					if(M.name=="Booze")
						M.name="Alcohol"
					M.EatText="drinks [M.name]."
				else
					if(M.name=="Booze")
						M.name="Hooch"
					M.EatText="drinks [M.name] with a disgusted expression..."
				if(M.EatToxicity>1&&M.EatToxicity<4)
					M.EatText+=" The drink appears pretty strong..."
				else if(M.EatToxicity>=4)
					M.EatText+=" The drink appears incredibly strong..."
				if(src.NonAlcoholic)
					M.name="Virgin [M.name]"
			usr.Frozen=2
			OMsg(usr, "[usr] starts brewing...")
			usr.TakeMoney(MatCost)
			sleep(30)
			usr.Frozen=0
			src.Using=0


	Sense
		SkillCost=100
		Teachable=0
		Level=0
		Cooldown=5
		desc="Focus your thoughts to detect nearby entities."
		verb/Sense()
			set category="Utility"
			if(usr.Secret == "Heavenly Restriction" && usr.secretDatum?:hasRestriction("Senses"))
				return
			if(Using) return
			Cooldown()
			usr << "<font color=#FF0000>You focus your senses...</font>"
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sensing, usr))
				usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sensing)
			for(var/mob/Players/M in players)
				if(M==usr)
					continue
				if(M.z!=usr.z)
					continue
				if(!M.AdminInviso&&M.PowerControl>25)
					if((usr.Saga=="Unlimited Blade Works" && usr.SagaLevel >= 2)||(!M.HasGodKi()&&!M.HasVoid()&&!M.HasMechanized()))
						if((!locate(M.EnergySignature) in usr.EnergySignaturesKnown)&&!usr.passive_handler.Get("SpiritPower"))
							var/distancecalc=abs(M.x-usr.x)+abs(M.y-usr.y)
							if(distancecalc<16)
								if(usr.HasEmptyGrimoire())
									usr << "<b>[M.name]</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)] - ([M.x], [M.y], [M.z])"
								else
									usr << "<b>[M.name]</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)]"
								if(M.EnergySignature)
									usr.EnergySignaturesKnown.Add(M.EnergySignature)
							else
								if(usr.HasEmptyGrimoire())
									usr << "<b>???</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)] - ([M.x], [M.y], [M.z])"
								else
									usr << "<b>???</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)]"
						else
							if(usr.HasEmptyGrimoire())
								usr << "<b>[M.name]</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)] - ([M.x], [M.y], [M.z])"
							else
								usr << "<b>[M.name]</b> - [usr.Get_Sense_Reading(M)] - [usr.CheckDirection(M)]"

			if(usr.HasEmptyGrimoire())
				usr << "Location: ([usr.x], [usr.y], [usr.z])"

	Mind_Reading_Toggle
		desc="Ignore thoughts."
		verb/Filter_Thoughts()
			set category="Utility"
			if(usr.HearThoughts)
				usr.HearThoughts=0
				usr << "You toggle thought hearing <font color='red'>OFF</font color>."
			else
				usr.HearThoughts=1
				usr << "You toggle thought hearing <font color='green'>ON</FONT COLOR>."

	Telepathy
		Learn=list("energyreq"=1000)
		icon_state="Telepathy"
		desc="Allows you to send a telepathic message to someone."
		Level=100
		var/anonymous = FALSE
		verb/Toggle_Anonymous()
			set category = "Utility"
			if(src.anonymous)
				src.anonymous=0
				usr << "You toggle anonymous telepathy <font color='red'>OFF</font color>."
			else
				src.anonymous=1
				usr << "You toggle anonymous telepathy <font color='green'>ON</font color>."
//		verb/Telepathic_Message()
//			set category="Utility"
//			usr.SkillX("Telepath",src)
		verb/Telepathic_Link()
			set category="Utility"
			if(usr.Secret == "Heavenly Restriction" && usr.secretDatum?:hasRestriction("Senses"))
				return
			var/list/who=list("Cancel")
			for(var/mob/Players/A in players)
				who.Add(A)
			for(var/mob/Players/W in who)
				if(!usr.isRace(SHINJIN))
					if(!usr.passive_handler.Get("SpiritPower"))
						if(!(locate(W.EnergySignature) in usr.EnergySignaturesKnown))
							if(!(W in hearers(50,usr)))
								who.Remove(W)
						if(!W.EnergySignature)
							who.Remove(W)
						if(W.Dead)
							who.Remove(W)
					if(usr.Dead&&!usr.HasEnlightenment()&&(W.z!=usr.z))
						who.Remove(W)
			var/mob/Players/selector=input("Select a player to telepath.") in who||null
			if(selector=="Cancel")
				return
			usr.TwoWayTelepath(selector, anonymous)

	Send_Energy
		SignatureTechnique=1
		Teachable=0
		Level=100
		desc="Can continually transfer energy to someone at the cost of your own life force."
		verb/Share_Energy()
			set category="Utility"
			var/list/who=list("Cancel")
			for(var/mob/Players/M in oview(5,usr))
				who.Add(M)
			if(usr.Transfering)
				usr<<"You stop transfering your life force."
				usr.Transfering=null
				return
			var/mob/selector=input("Who do you want to transfer energy to?","Energy Transfer")in who||null
			if(selector=="Cancel")
				return
			else if(selector!="Cancel")
				usr.Transfering=selector

	Heal
		Cooldown=-1
		SignatureTechnique=2
		PreRequisite = list("/obj/Skills/Utility/Send_Energy")
		icon_state="Heal"
		desc="This allows you to heal people you are facing."
		verb/Heal()
			set category="Utility"
			usr.SkillX("Heal",src)
	Refresh
		Cooldown=-1
		icon_state="Heal"
		desc="This allows you to heal people you are facing."
		verb/Heal()
			set category="Utility"
			usr.SkillX("Refresh",src)

	Observe
		Learn=list("energyreq"=10000)
		icon_state="Observe"
		desc="Allows you to watch over someone."
		Level=100
		verb/Observe()
			set category="Utility"
			var/list/who=list("Cancel")
			for(var/mob/Players/M in players)
				who.Add(M)
			for(var/mob/Players/W in who)
				if(W.AdminInviso)
					who.Remove(W)
				if(usr.HasJagan()&&W.z==usr.z)
					continue
				if(W.z == ArcaneRealmZ)
					who.Remove(W)
				if(!usr.HasSpiritPower() && !usr.HasEmptyGrimoire())
					if(!(locate(W.EnergySignature) in usr.EnergySignaturesKnown))
						who.Remove(W)
					if(!W.EnergySignature)
						who.Remove(W)
					if(W.Dead)
						who.Remove(W)
					if(W.PowerControl<=25)
						who.Remove(W)
				if(W.HasGodKi() && !usr.HasGodKi())
					who.Remove(W)
				if(W.invisibility)
					who.Remove(W)
				if(usr.Dead&&!usr.HasEnlightenment()&&(W.z!=usr.z))
					who.Remove(W)
			var/mob/Players/selector=input("Who do you want to observe?","Observe")in who||null
			if(selector=="Cancel")
				Observify(usr,usr)
				usr.Observing=0
				return
			else
				Observify(usr,selector)
				if(usr.HasEmptyGrimoire())
					usr << "[selector] - ([selector.x], [selector.y], [selector.z])"
				if(selector!=usr && locate(/obj/Skills/Utility/Observe,selector.contents))
					selector << "You feel as if you're being watched."
				usr.Observing=1

	Grant_Jagan
		desc="Rip out your own eye to give to someone else."
		verb/Bestow_Jagan_Eye()
			set category="Utility"
			if(usr.Maimed)
				usr << "You are not sufficiently whole to bestow an eye."
				return
			if(src.Using)
				usr << "You are already bestowing an eye."
				return
			src.Using=1
			var/list/Bad_Boys=list("Cancel")
			for(var/mob/m in oview(1, usr))
				if(m.type in typesof(/mob/Player/AI))
					continue
				if(locate(/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye, m))
					continue
				if(m==usr)
					continue
				Bad_Boys.Add(m)
			if(Bad_Boys.len>1)
				var/mob/Choice=input(usr, "Who do you want to bestow your Jagan Eye to?", "Jagan Grant") in Bad_Boys
				if(Choice=="Cancel")
					usr << "You hoard your eye."
					src.Using=0
					return
				var/Consent
				if(Choice.KO)
					Consent="Yes"
				Consent=alert(Choice, "Do you want to accept [usr]'s Jagan Eye?", "Jagan Grant", "No", "Yes")
				if(Consent=="Yes")
					usr.Maimed++
					for(var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/r in usr)
						if(r.RegenerateLimbs)
							r.RegenerateLimbs=0
							usr << "You cannot regenerate your limbs anymore..."
					Choice.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye)
					Choice.JaganPowerNerf=0.5
					OMsg(usr, "[usr] bestows [Choice] with a powerful demonic eye, but it will leech [Choice]'s life until they learn to control it properly...")
					del src
				else
					OMsg(usr, "[Choice] refuses [usr]'s offer of power...")
					src.Using=0
					return
			else
				usr << "There's no one to shove your eye in..."
				src.Using=0
				return


	Keep_Body
		Cooldown=600
		desc="Pull a soul out of the cycle of reincarnation."
		verb/Keep_Body()
			set category="Utility"
			usr.SkillX("KeepBody", src)

	Travel_To_Plane
		Cooldown=600
		desc="Warp anywhere without cost."
		verb/Travel_To_Plane()
			set category="Utility"
			if(usr.Stasis)return
			var/blah=input("Options")in list("Person","Cordinates","Cancel")
			switch(blah)
				if("Person")
					var/list/people=list("Cancel")
					for(var/mob/Players/QQ in players)
						people.Add(QQ)
					var/mob/whoto=input("Teleport to who?")in people||null
					if(whoto=="Cancel")
						return
					for(var/mob/m in view(1, usr))
						m.loc=whoto.loc

				if("Cordinates")
					var/blahx=input("x")as num
					var/blahy=input("y")as num
					var/blahz=input("z")as num
					for(var/mob/m in view(1, usr))
						m.loc=locate(blahx+rand(-1,1), blahy+rand(-1,1), blahz)

	Bind_To_Plane
		Cooldown=600
		desc="Bind someone to a particular plane."
		verb/Bind_To_Plane()
			set category="Utility"
			var/list/mob/m=list("Cancel")
			for(var/mob/M in view(3, usr))
				if(M==usr)
					continue
				m+=M
			var/mob/Choice=input(usr, "Who do you wish to bind to this plane?", "Bind to Plane") in m
			if(Choice=="Cancel")
				return
			if(Choice.KO||(usr.Power>Choice.Power*3))//Either knock them out or be three times as powerful
				Choice.Binding=list(Choice.x,Choice.y,Choice.z)
				Choice.BindingTimer = Day(3)
				OMsg(usr, "[usr] has bound [Choice] to this plane of existence!!")
			else
				usr << "They aren't weak enough to bind!"
		verb/Call_To_Plane()
			set category="Skills"
			var/list/mob/m=list("Cancel")
			for(var/mob/M in view(10, usr))
				if(M.Binding)
					m+=M
			var/mob/Choice=input(usr, "Whose binding do you wish to call upon?", "Call to Plane") in m
			if(Choice=="Cancel")
				return
			OMsg(usr, "[usr] has forced [Choice]'s binding to take them back to their plane!")
			Choice.TriggerBinding()

//Knowledge

	Make_Equipment
		Level=100
		Teachable=0
		desc="Forge a basic blade."
		proc/getDropDir()
			var/norSouth = 0
			if(usr.dir==SOUTH)
				norSouth=-1
			else if(usr.dir==NORTH)
				norSouth=1
			var/eastWest = 0
			if(usr.dir==EAST)
				eastWest=-1
			else if(usr.dir==WEST)
				eastWest=1
			return list(eastWest, norSouth)
		verb/Materialize_Equipment()
			set category="Utility"
			var/Choice=input(usr, "What kind of item will you make?", "Make Sword") in list("Weapon", "Armor", "Weights")
			if(Choice=="Weapon")
				if(usr.HasManaCapacity(5))
					usr.TakeManaCapacity(5)
					var/ChoiceW=input(usr, "What kind of blade will you make?", "Make Sword") in list("Wooden", "Light", "Medium", "Heavy")
					var/obj/Items/Sword/s
					switch(ChoiceW)
						if("Wooden")
							s=new/obj/Items/Sword/Wooden
						if("Light")
							s=new/obj/Items/Sword/Light
						if("Medium")
							s=new/obj/Items/Sword/Medium
						if("Heavy")
							s=new/obj/Items/Sword/Heavy
					s.ShatterTier=rand(1,4)
					s.ShatterCounter/=2
					s.ShatterMax/=2
					s.Cost=0
					s.Conjured=0
					var/list/dirs = getDropDir()
					s.loc = locate(usr.x+dirs[1], usr.y+dirs[2], usr.z)
					OMsg(usr, "[usr] creates a weapon!", "[usr] materialized some armaments.")
			else if(Choice=="Armor")
				if(usr.HasManaCapacity(5))
					usr.TakeManaCapacity(5)
					var/ChoiceA=input(usr, "What kind of armor will you make?", "Make Sword") in list("Light", "Medium", "Heavy")
					var/obj/Items/Armor/a
					switch(ChoiceA)
						if("Light")
							a=new/obj/Items/Armor/Mobile_Armor
						if("Medium")
							a=new/obj/Items/Armor/Balanced_Armor
						if("Heavy")
							a=new/obj/Items/Armor/Plated_Armor
					a.ShatterCounter/=2
					a.ShatterMax/=2
					a.Cost=0
					var/list/dirs = getDropDir()
					a.loc = locate(usr.x+dirs[1], usr.y+dirs[2], usr.z)
					OMsg(usr, "[usr] creates a set of armor!", "[usr] materialized some armor.")
			else
				if(usr.HasManaCapacity(25))
					usr.TakeManaCapacity(25)
					var/obj/Items/WeightedClothing/Weights/w=new
					w.Cost=0
					usr.contents+=w
					OMsg(usr, "[usr] creates a set of weighted clothing!", "[usr] materialized some weights.")
		verb/Clothes_Beam()
			set category="Skills"
			for(var/mob/Target in get_step(usr,usr.dir))
				var/obj/Items/Wearables/c=new
				var/Z=input(usr,"Choose an icon for the conjured clothes!","Clothes Beam")as icon|null
				if(Z==null)
					return
				if((length(Z) > 95000))
					usr <<"This file exceeds the limit of 50KB. It cannot be used."
					return
				c.LastIconChange=usr.key
				c.icon=Z
				c.icon_state=input("icon state") as text
				c.pixel_x=input("X adjustment.") as num
				c.pixel_y=input("Y adjustment.") as num
				Target.contents+=c
				c.AlignEquip(Target)
				OMsg(usr, "[usr] conjures clothing!", "[usr] materialized some clothes.")

	Upgrade_Equipment
		Level=100
		Teachable=0
		desc="A progressive knowledge of fine equipment leads to increasing quality."
		verb/Upgrade_Equipment()
			set category="Utility"
			var/list/swords=list("Cancel")
			var/list/staves=list("Cancel")
			var/list/armors=list("Cancel")
			var/Chosen
			if(usr.TotalFatigue>50)
				usr << "You're too tired to upgrade anything."
				return
			if(usr.TotalCapacity>90)
				usr << "You're too drained to upgrade anything."
				return
			for(var/obj/Items/Sword/S in usr.contents)
				if(!S.suffix)
					if(!S.LegendaryItem)
						if(!S.Conjured)
							swords.Add(S)
			for(var/obj/Items/Enchantment/Staff/S in usr.contents)
				if(!S.suffix)
					if(!S.LegendaryItem)
						if(!S.Conjured)
							staves.Add(S)
			for(var/obj/Items/Armor/A in usr.contents)
				if(!A.suffix)
					if(!A.LegendaryItem)
						if(!A.Conjured)
							armors.Add(A)
			var/Type=alert(usr, "What type of equipment do you wish to refine?", "Upgrade Equipment", "Sword", "Staff", "Armor")
			switch(Type)
				if("Sword")
					if(swords.len<2)
						usr << "You don't have any swords to upgrade!"
						return
					Chosen=input("What sword do you wish to upgrade?", "Upgrade Equipment")in swords
				if("Staff")
					if(staves.len<2)
						usr << "You don't have any staves to upgrade!"
						return
					Chosen=input("What staff do you wish to upgrade?", "Upgrade Equipment")in staves
				if("Armor")
					if(armors.len<2)
						usr << "You don't have any armors to upgrade!"
						return
					Chosen=input("What armor do you wish to upgrade?", "Upgrade Equipment")in armors
			var/Cost=glob.progress.EconomyCost

			var/list/Upgrades=list("Cancel")
			if(Type=="Sword"||Type=="Staff")//armors don't get reinforced
				Upgrades.Add("Reinforce")
			if(usr.ArmamentEnchantmentUnlocked>=4||usr.ForgingUnlocked>=5)
				if(Type=="Sword"&&Chosen:Class!="Wooden"&&!Chosen:ExtraClass)
					Upgrades.Add("Refine")
			if(usr.ArmamentEnchantmentUnlocked>=1||usr.RepairAndConversionUnlocked>=3)
				Upgrades.Add("Fire")
				Upgrades.Add("Water")
				Upgrades.Add("Earth")
				Upgrades.Add("Wind")
			if(usr.ArmamentEnchantmentUnlocked>=2||usr.RepairAndConversionUnlocked>=1)
				if(Type=="Sword"||Type=="Staff")
					Upgrades.Add("Poison")
					Upgrades.Add("Silver")
			if(usr.ArmamentEnchantmentUnlocked>=3)
				Upgrades.Add("Light")
				Upgrades.Add("Dark")
			if(usr.ArmamentEnchantmentUnlocked>=5)
				if(Type=="Sword"||Type=="Staff")
					Upgrades.Add("Ultima!?")
			if(usr.ArmamentEnchantmentUnlocked==5&&usr.ForgingUnlocked==5&&usr.RepairAndConversionUnlocked==5&&usr.AlchemyUnlocked==5&&usr.ImprovedAlchemyUnlocked==5&&usr.ToolEnchantmentUnlocked==5)
				if(Type=="Sword"||Type=="Staff")
					Upgrades.Add("Ultima (True)")
			var/Choice2=input("What type of Enchantment will you apply? Mind, the process is extremely exhausting.") in Upgrades
			switch(Choice2)
				//T1
				if("Reinforce")
					var/enchantmentType = usr.ArmamentEnchantmentUnlocked > usr.ForgingUnlocked ? usr.ArmamentEnchantmentUnlocked : usr.ForgingUnlocked
					// if they have master crafts left, they can upgrade to 6
					// if not they can only upgrade to their max enchantment type level
					// the cost is 5* base and 4 ** ascended
					if(!usr.MasterCrafts)
						if(Chosen:Ascended>=5||Chosen:Ascended>round(enchantmentType,1))
							usr<<"Ascending [Chosen] is beyond your abilities."
							return
					if(Chosen:Ascended + 1 > glob.progress.maxAscension && !usr.MasterCrafts)
						usr<<"Ascending [Chosen] is beyond your abilities."
						return
					Cost*=5*(4**Chosen:Ascended)

				//T2
				if("Poison")
					Cost*=5
				if("Silver")
					Cost*=5
				//T3
				if("Dark")
					Cost*=10
				if("Light")
					Cost*=10
				//T4
				if("Refine")
					Cost*=10
				//T5
				if("Ultima!?")
					Cost*=100
				//T6?!
				if("Ultima (True)")
					Cost*=400
				if("Cancel")
					return
			if(!usr.HasMoney(Cost))
				usr<<"You need at least [Cost] to upgrade equipment!"
				return
			if(Choice2!="Cancel")
				var/Confirm2=alert(usr, "It will cost [Cost] to ascend [Chosen].  Do you wish to ascend the weapon?", "Ascend Weapon", "Yes", "No")
				switch(Confirm2)
					if("No")
						OMsg(usr, "[usr] decided to not ascend [Chosen].")
						return
					if("Yes")
						switch(Choice2)
							if("Reinforce")
								usr<<"[Chosen] ascends under your careful effort."
								Chosen:Ascended++
								if(usr.MasterCrafts && Chosen:Ascended > 5)
									usr.MasterCrafts--
									if(usr.MasterCrafts<0)
										usr.MasterCrafts=0
									Chosen:name = "Master Crafted [Chosen:name]"
									Chosen:name = input(usr, "You have worked tirelessly to create a Mythical grade item, you must name it.") as text
							if("Fire")
								usr<<"[Chosen] glows a vibrant red for a few moments, and now feels eternally warm to the touch."
								Chosen:Element="Fire"
							if("Wind")
								usr<<"[Chosen] glows a bright green for a few moments. It feels like wind is slowly swirling around it."
								Chosen:Element="Wind"
							if("Earth")
								usr<<"[Chosen] glows a dull yellow for a few moments. It feels heavier for some reason."
								Chosen:Element="Earth"
							if("Water")
								usr<<"[Chosen] glows a deep blue for a few moments. Moisture seems to gather about [Chosen]."
								Chosen:Element="Water"
							if("Poison")
								usr << "[Chosen] glows with a dark green for a few moments.  It feels nauseating to hold..."
								Chosen:Element="Poison"
							if("Silver")
								usr << "[Chosen] is reforged with a pure silver edge.  It feels heavier and more brittle..."
								Chosen:Element="Silver"
								Chosen:ShatterTier+=1
								if(Chosen:ShatterTier>4)
									Chosen:ShatterTier=4
							if("Dark")
								usr<<"[Chosen] glows a deep purple for a few moments. Grasping [Chosen] seems to fill you with anger..."
								Chosen:Element="Dark"
							if("Light")
								usr<<"[Chosen] glows a bright silver for a few moments. Grasping [Chosen] seems to calm you down..."
								Chosen:Element="Light"
							if("Refine")
								usr<<"[Chosen] has its class traits magnified through steady effort..."
								Chosen:ExtraClass=1
							if("Ultima!?")
								usr << "[Chosen] glows a chaotic rainbow for a few moments.  Grasping [Chosen] makes you feel unstoppable..."
								Chosen:Element="Chaos"
								if(Type=="Sword")
									usr << "...yet the blade itself seems to become painfully brittle under the powerful infusion..."
									Chosen:ShatterTier+=rand(1,4)
									if(Chosen:ShatterTier>4)
										Chosen:ShatterTier=4
									Chosen:ShatterMax/=2
									if(Chosen:ShatterCounter>Chosen:ShatterMax)
										Chosen:ShatterCounter=Chosen:ShatterMax
								if(Type=="Staff")
									usr << "...yet it becomes much harder to properly channel power through it..."
									Chosen:SpeedEffectiveness/=5//Lower drain mult means higher cost
							if("Ultima (True)")
								if(Chosen:Ascended>=5&&!Chosen:Glass)
									if(Chosen:Element=="Chaos")
										usr << "[Chosen] glows a flourescent rainbow for a few moments.  Grasping [Chosen] makes you feel like a force of nature..."
										Chosen:Element="Ultima"
										Chosen:Destructable=0
										Chosen:ShatterTier=0
										Chosen:Ascended=6
									else
										usr << "[Chosen] glows a diminished rainbow for a few moments.  Grasping [Chosen] makes you feel somewhat restrained..."
										Chosen:Element="Chaos"
								else
									usr << "[Chosen] cannot handle the strain of power being infused into it and explodes into million pieces!"
									del Chosen
							//:o
						usr.TakeMoney(Cost)
			if(Choice2!="Ultima (True)"||Choice2!="Ultima!?")
				usr << "You feel exhausted."
				usr.GainFatigue(50/max(1,usr.ArmamentEnchantmentUnlocked))
			if(Choice2=="Ultima!?")
				usr << "You feel physically and mentally drained."
				usr.GainFatigue(200/max(1,usr.ArmamentEnchantmentUnlocked))
				usr.LoseCapacity(200/max(1,usr.ArmamentEnchantmentUnlocked))
			if(Choice2=="Ultima (True)")
				usr << "You sacrificed part of your soul for the sake of this project..."
				usr.EconomyMult/=2
				usr.Intelligence/=2
				usr.Imagination/=2
				if(prob(50))
					for(var/obj/Items/i in usr)
						i.loc=usr.loc
					var/obj/Money/m=new
					m.loc=usr.loc
					m.Level=usr.GetMoney()
					usr.TakeMoney(m.Level)
					usr.NoSoul=1
					usr.DeathKilled=1
					usr.Death(null, "sacrificing everything for their final project!!", SuperDead=99)
			if(Type=="Sword"&&Choice2!="Reinforce"&&Choice2!="Refine")
				if(Chosen:Class=="Light")
					Chosen:name="[Chosen:Element] Bastard Sword"
				if(Chosen:Class=="Medium")
					Chosen:name="[Chosen:Element] Longsword"
				if(Chosen:Class=="Heavy")
					Chosen:name="[Chosen:Element] Greatsword"
			if(Type=="Sword"&&Choice2=="Refine")
				if(Chosen:Class=="Light")
					Chosen:name="Extra-Light Bastard Sword"
				if(Chosen:Class=="Medium")
					Chosen:name="Perfectly-Balanced Longsword"
				if(Chosen:Class=="Heavy")
					Chosen:name="Ultra-Heavy Greatsword"
			if(Type=="Staff"&&Choice2!="Reinforce")
				if(Chosen:Class=="Wand")
					Chosen:name="[Chosen:Element] Wand"
				if(Chosen:Class=="Rod")
					Chosen:name="[Chosen:Element] Rod"
				if(Chosen:Class=="Staff")
					Chosen:name="[Chosen:Element] Staff"
			if(Type=="Armor")
				if(Chosen:Class=="Light")
					Chosen:name="[Chosen:Element] Armored Vest"
				if(Chosen:Class=="Medium")
					Chosen:name="[Chosen:Element] Standard Armor"
				if(Chosen:Class=="Heavy")
					Chosen:name="[Chosen:Element] Plated Armor"
			Chosen:Update_Description()
	Transmute//PHILOSTONES
		desc="Rip out the mana circuits of an incapacitated individual to forge them into a stone of mana."
		var/LastTransmute//holds realtime
		verb/Transmute()
			set category="Utility"
			if(src.Using)
				return
			if(src.LastTransmute)
				if(world.realtime<src.LastTransmute)
					usr << "It's too soon to transmute someone again!  ([(src.LastTransmute-world.realtime)/Hour()] hours remaining)"
					return
			var/list/mob/Targets=list()
			for(var/mob/m in get_step(usr, usr.dir))
				if(m.KO&&!m.isRace(ANDROID)&&!m.ManaSealed&&!istype(m, /mob/Player/FevaSplits)&&!istype(m, /mob/Player/AI))
					if(m.client&&m.client.address!=usr.client.address)//lol no u can not make alts to eat...
						Targets.Add(m)
			if(Targets.len>0)
				src.Using=1
				var/mob/Choice=input(usr, "Who will you transmute into a Philosopher's Stone?", "Transmute") in Targets
				Choice.ManaSealed = 1
				OMsg(usr, "<font color='red'>[usr] begins the transmutation process on [Choice]!  Red lightning encompasses their form!</font color>")
				usr.Frozen=2
				Choice.Frozen=2
				Choice.KOTimer+=10
				Choice.overlays+=icon('PhilosopherSparks.dmi')
				sleep(10)
				usr.Frozen=0
				Choice.Frozen=0
				Choice.overlays-=icon('PhilosopherSparks.dmi')
				animate(Choice, color=list(1,0,0, 1,0,0, 1,0,0, 0,0,0), time=5)
				sleep(5)
				animate(Choice, alpha=0, time=10)
				sleep(10)
				var/Chance = Choice.getExtraVoidChance()
				var/rolls = 1 + Choice.getVoidRolls()
				var/voided = FALSE
				while(rolls>0)
					var/roll = rand(Chance, 100)
					if(roll >= 100-glob.VoidChance)
						voided = TRUE
						break
					else
						rolls--
						voided = FALSE
					if(rolls<0)
						rolls = 0

				if(!voided)
					var/obj/Items/Enchantment/PhilosopherStone/True/f=new
					f.SoulStrength = round(Choice.Potential/10,1)
					f.SoulIdentity = Choice?:UniqueID
					f.loc = Choice.loc
					Choice.Death(null, "having their body and soul converted into a Philosopher's Stone!", NoRemains=3)
				else
					OMsg(usr, "[usr] loses control of their forbidden spell and has a core part of their being claimed by the transmutation!")
					OMsg(usr, "The magic chaotically lashes out and sends [Choice] hurtling into the void!")
					usr.Maimed++
					var/obj/Items/Enchantment/PhilosopherStone/Fake/f = new
					f.SoulStrength = round(Choice.Potential/20,1)
					f.SoulIdentity = Choice?:UniqueID
					f.loc = Choice.loc
					Choice.loc = locate(glob.VOID_LOCATION[1], glob.VOID_LOCATION[2], glob.VOID_LOCATION[3])

				src.Using=0
				src.LastTransmute=world.realtime+Day(2)
			else
				usr << "You must have an incapacitated person in front of you in order to transmute them into a Philosopher's Stone."
				src.Using=0

// 	Summon_Spirit
// 		desc="Summon a spirit!  Doesn't work on those with contracts already established."
// 		var/SpiritSummonCD//holds a realtime
// 		verb/Summon_Spirit()
// 			set category="Utility"
// 			if(src.Using)
// 				return
// 			if(!usr.Move_Requirements()||usr.KO)
// 				return
// 			if(world.realtime<src.SpiritSummonCD)
// 				usr << "It's too soon to use this!  ([round((src.SpiritSummonCD-world.realtime)/Hour(1), 0.1)] hours)"
// 				return
// 			src.Using=1
// 			var/obj/Skills/Utility/Summon_Absurdity/s = locate(/obj/Skills/Utility/Summon_Absurdity) in usr
// 			if(s)
// 				switch(input("Would you like to try summoning an entity using their true name?") in list("Yes","No"))
// 					if("Yes")
// 						s.Summon_Absurdity()
// 						Using=0
// 						return
// 			var/list/mob/Players/Options=list()
// 			for(var/mob/Players/P in world)
// 				if(P.Spiritual&&!P.SummonContract&&!locate(/obj/Skills/Soul_Contract, P)&&P!=usr)
// 					Options.Add(P)
// 				if(P.Dead&&!P.HasEnlightenment()&&!usr.SpiritPower)
// 					Options.Remove(P)
// 				if(P.z in ArcaneRealmZ && 2 > usr.Imagination)
// 					Options.Remove(P)
// 			if(Options.len<1)
// 				usr << "There are no available spirits to summon!"
// 				src.Using=0
// 				return
// 			//var/Cost=0.75*global.EconomyMana//75 capacity
// 			var/Cost=0.25*global.EconomyMana

// 			if(!usr.HasManaCapacity(Cost))
// 				usr << "You don't have enough capacity to summon a spirit!  It takes [Commas(Cost)] capacity."
// 				src.Using=0
// 				return
// 			var/mob/Players/Choice=pick(Options)
// //			if(Choice=="Cancel")
// //				src.Using=0
// //				return

// 			//Distance handling
// 			if(Choice.z != src.z)
// 				Cost = min(0.99*global.EconomyMana, (1+abs(src.z - Choice.z)) * Cost)
// 				switch(input(usr, "Summoning this spirit will cost [Cost] mana. Are you sure you want to do it?", "Summon Spirit") in list("Yes","No"))
// 					if("No")
// 						src.Using=0
// 						return
// 			var/FailChance=20*((Choice.Power*Choice.EnergyUniqueness)/(usr.Power*usr.EnergyUniqueness))/(usr.SummoningMagicUnlocked+1)

// 			usr.TakeManaCapacity(Cost)
// 			if(prob(FailChance)&&!usr.HasSpiritPower())
// 				OMsg(usr, "[usr] fails their ritual!")
// 				src.Using=0
// 				return
// 			else
// 				Choice.PrevX=Choice.x
// 				Choice.PrevY=Choice.y
// 				Choice.PrevZ=Choice.z
// 				OMsg(Choice, "[Choice] is whisked away!")
// 				Choice.loc=locate(usr.x, usr.y-1, usr.z)
// 				OMsg(usr, "[usr] summons forth a spirit!")
// 				spawn()
// 					LightningBolt(Choice)
// 				Choice.SummonReturnTimer=RawMinutes(5)
// 				if(!Choice.SummonContract)
// 					Choice.SummonContract=1
// 				src.SpiritSummonCD=world.realtime+Hour(1)
// 				src.Using=0
// 				return

// 	Summon_Absurdity
// 		desc="Summon something otherworldly if you know its True Name. Can summon through contracts!"
// 		var/AbsurdSummonCD
// 		proc/Summon_Absurdity()
// 			set category="Utility"
// 			var/mob/Choice
// 			if(src.Using)
// 				return
// 			if(!usr.Move_Requirements()||usr.KO)
// 				return
// 			if(world.realtime<src.AbsurdSummonCD)
// 				usr << "It's too soon to use this!  ([round((src.AbsurdSummonCD-world.realtime)/Hour(1), 0.1)] hours)"
// 				return
// 			src.Using=1

// 			var/Cost=5*global.EconomyMana

// 			if(!usr.HasManaCapacity(Cost))
// 				usr << "You don't have enough capacity to summon an otherworldly entity!  It takes [Commas(Cost)] capacity."
// 				src.Using=0
// 				return

// 			switch(input(usr, "Summoning this otherworldly entity will cost [Cost] mana. Are you sure you want to do it?", "Summon Absurdity") in list("Yes","No"))
// 				if("No")
// 					src.Using=0
// 					return

// 			var/Failure=0
// 			var/Invocation=input(usr, "What True Name do you attempt to invoke?", "Summon Absurdity") as text
// 			if(Invocation in global.TrueNames)
// 				var/Found=0
// 				for(var/mob/Players/m in world)
// 					if(m.TrueName==Invocation)
// 						Found=1
// 						Choice=m
// 						break

// 				if(!Found)
// 					OMsg(usr, "[usr] invoked a True Name properly, but the being slumbers currently...")
// 					src.Using=0
// 					return

// 			else
// 				Failure=1
// 				OMsg(usr, "[usr] attempted to invoke a True Name of no existing being!")

// 			var/PerfectRitual=0+(usr.SummoningMagicUnlocked*10)

// 			usr.TakeManaCapacity(Cost/(1+Failure))//if you fuck the name up you only pay half

// 			if(!Failure)

// 				OMsg(Choice, "[Choice] is compelled to appear elsewhere!")
// 				Choice.loc=locate(usr.x, usr.y-1, usr.z)
// 				spawn()
// 					for(var/x=0, x<5, x++)
// 						LightningBolt(Choice)
// 						sleep(3)

// 				if(prob(PerfectRitual)||usr.SpiritPower)
// 					OMsg(usr, "[usr] invokes the True Name of [Choice] to compel them to appear!")
// 					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shackled/S=new
// 					S.Password=usr.name
// 					S.Infatuated=3
// 					S.ActiveMessage="is forced to appear by an invocation of their True Name! They cannot hurt their summoner!"
// 					S.OffMessage="feels the effects of the ritual summoning fade away..."
// 					S.TimerLimit=3600
// 					Choice.AddSkill(S)
// 				else
// 					OMsg(usr, "[usr] does not invoke the True Name of [Choice] properly! They are offered no protection against the otherworldly entity...")

// 			src.AbsurdSummonCD=world.realtime+Day(1)
// 			src.Using=0
// 			return


	Seal_Turf
		desc="Seal a turf so that only you can move through it!"
		verb/Seal_Turf()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Cost=0.2*glob.progress.EconomyMana
			var/Confirm=alert(usr, "Do you wish to seal your CURRENT LOCATION?  It will cost [Commas(Cost)] capacity.", "Seal Turf", "No", "Yes")
			if(Confirm=="No")
				src.Using=0
				return
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity.  It requires [Commas(Cost)]."
				src.Using=0
				return
			usr.TakeManaCapacity(Cost)
			var/obj/Seal/S=new
			if(usr.SealPersonal)
				S.icon=usr.SealPersonal
			S.Creator=usr.ckey
			S.Level=(usr.Intelligence*usr.Imagination*usr.SealingMagicUnlocked)
			if(usr.Saga=="Keyblade")
				S.Level*=1.5
			S.loc=usr.loc
			S.Savable=1
			S.name="Turf Seal ([S.loc.name])"
			usr << "You create a new seal!"
			src.Using=0
			return

	Seal_Object
		desc="Seal an object so that only you can harm or pick it up!"
		verb/Seal_Object()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Cost=0.5*glob.progress.EconomyMana
			var/list/obj/Options=list("Cancel")
			for(var/obj/O in get_step(usr, usr.dir))
				Options.Add(O)
			if(Options.len<2)
				usr << "There are no objects to seal!"
				src.Using=0
				return
			var/obj/Choice=input(usr, "What object do you wish to seal?", "Seal Object") in Options
			if(Choice=="Cancel")
				src.Using=0
				return
			var/Confirm=alert(usr, "Do you wish to seal [Choice]?  It will cost [Commas(Cost)] capacity.", "Seal Object", "No", "Yes")
			if(Confirm=="No")
				src.Using=0
				return
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity.  It requires [Commas(Cost)]."
				src.Using=0
				return
			usr.TakeManaCapacity(Cost)
			var/obj/Seal/S=new
			if(usr.SealPersonal)
				S.icon=usr.SealPersonal
			S.Creator=usr.ckey
			S.Level=(usr.Intelligence*usr.Imagination*usr.SealingMagicUnlocked)
			if(usr.Saga=="Keyblade")
				S.Level*=1.5
			Choice.contents += S
			S.name="Object Seal ([Choice.name])"
			Choice.overlays+=S.icon
			usr << "You create a new seal on [Choice]!"
			src.Using=0
			return

	Seal_Power
		desc="Seal a fallen foe's power!!"
		verb/Seal_Power()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Cost=1*glob.progress.EconomyMana
			var/list/mob/Players/Options=list("Cancel")
			for(var/mob/Players/P in get_step(usr, usr.dir))
				if(locate(/obj/Seal/Power_Seal, P))
					continue
				if(P.KO)
					Options.Add(P)
			if(Options.len<2)
				usr << "There are no fallen people to seal!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "What person do you wish to seal?", "Seal Power") in Options
			if(Choice=="Cancel")
				src.Using=0
				return
			var/Confirm=alert(usr, "Do you wish to seal [Choice]'s power?  It will cost [Commas(Cost)] capacity.", "Seal Power", "No", "Yes")
			if(Confirm=="No")
				src.Using=0
				return
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity.  It requires [Commas(Cost)]."
				src.Using=0
				return
			usr.TakeManaCapacity(Cost)
			OMsg(usr, "[usr] begins the ritual to seal [Choice]'s power...")
			var/image/Circle=image(icon='Demon Gate.dmi', loc=Choice, pixel_x=-96, pixel_y=-96, layer=2)
			Circle.alpha=0
			world << Circle
			spawn()
				animate(Circle, alpha=255, time=100)
			Choice.overlays+='SparksCoolRed.dmi'
			sleep(100)
			if(Choice.KO)
				var/obj/Seal/Power_Seal/S=new/obj/Seal/Power_Seal
				if(usr.SealPersonal)
					S.icon=usr.SealPersonal
				S.Creator=usr.ckey
				S.Level=(usr.Intelligence*usr.Imagination*usr.SealingMagicUnlocked)
				if(usr.Saga=="Keyblade")
					S.Level*=1.5
				Choice.contents+=S
				S.name="Power Seal ([Choice.name])"
				usr << "You have sealed [Choice]'s power!"
			else
				usr << "[Choice] arose before the ritual was complete!  Your magic is wasted!"
			Choice.overlays-='SparksCoolRed.dmi'
			src.Using=0
			del Circle

	Seal_Movement
		desc="Seal a fallen foe's ability to leave a particular area!"
		verb/Seal_Movement()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Cost=0.5*glob.progress.EconomyMana
			var/list/mob/Players/Options=list("Cancel")
			for(var/mob/Players/P in get_step(usr, usr.dir))
				if(locate(/obj/Seal, P))
					continue
				if(P.KO)
					Options.Add(P)
			if(Options.len<2)
				usr << "There are no fallen people to seal!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "What person do you wish to seal?", "Seal Movement") in Options
			if(Choice=="Cancel")
				src.Using=0
				return
			var/Confirm=alert(usr, "Do you wish to seal [Choice]'s movement?  It will cost [Commas(Cost)] capacity.", "Seal Movement", "No", "Yes")
			if(Confirm=="No")
				src.Using=0
				return
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity.  It requires [Commas(Cost)]."
				src.Using=0
				return
			usr.TakeManaCapacity(Cost)
			OMsg(usr, "[usr] begins the ritual to seal [Choice]'s movement...")
			var/image/Circle=image(icon='Demon Gate.dmi', loc=Choice, pixel_x=-96, pixel_y=-96, layer=2)
			Circle.alpha=0
			world << Circle
			spawn()
				animate(Circle, alpha=255, time=100)
			Choice.overlays+='SparksCoolRed.dmi'
			sleep(100)
			if(Choice.KO)
				var/obj/Seal/S=new/obj/Seal
				if(usr.SealPersonal)
					S.icon=usr.SealPersonal
				S.Creator=usr.ckey
				S.Level=(usr.Intelligence*usr.Imagination*usr.SealingMagicUnlocked)
				if(usr.Saga=="Keyblade")
					S.Level*=1.5
				S.ZPlaneBind=Choice.z
				S.XBind=Choice.x
				S.YBind=Choice.y
				Choice.contents+=S
				Choice.movementSealed = TRUE
				S.name="Movement Seal ([Choice.name])"
				usr << "You have sealed [Choice]'s movement!"
			else
				usr << "[Choice] arose before the ritual was complete!  Your magic is wasted!"
			Choice.overlays-='SparksCoolRed.dmi'
			src.Using=0
			del Circle

	Crystalize_Command_Seal
		desc="Crystalize an absolute order in form of a Seal! They'll provide additional options of interacting with your contracts."
		verb/Crystalize_Command_Seal()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Cost=glob.progress.EconomyMana
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity to try to form a seal!  It takes [Commas(Cost)] capacity."
				src.Using=0
				return
			var/Confirm=alert(usr, "Are you SURE you want to create a Command Seal? You can only do so once.", "Create Command Seal", "No", "Yes")
			if(Confirm=="Yes")
				usr.TakeManaCapacity(Cost)
				var/obj/Seal/Command_Seal/CS=new
				if(usr.SealPersonal)
					CS.icon=usr.SealPersonal
				CS.Orders=3
				usr.contents+=CS
				usr << "You've successfully crystallized three powerful commands!"
				del src
			src.Using=0

	Seal_Break
		desc="Test your imagination, intelligence, and ability at seal magic against an existing seal to try to break it!"
		verb/Seal_Break()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/list/obj/Seal/Seals=list("Cancel")
			for(var/obj/Seal/S in get_step(usr, usr.dir))
				Seals.Add(S)
			for(var/obj/O in get_step(usr, usr.dir))
				for(var/obj/Seal/S in O.contents)
					Seals.Add(S)
			for(var/mob/Players/P in get_step(usr, usr.dir))
				for(var/obj/Seal/S in P.contents)
					Seals.Add(S)
			if(Seals.len<2)
				usr << "There are no seals in front of you to break!"
				src.Using=0
				return
			var/obj/Seal/Choice=input(usr, "What seal do you wish to attempt to break?", "Seal Break") in Seals
			if(Choice=="Cancel")
				src.Using=0
				return
			var/Cost=0.25*glob.progress.EconomyMana
			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity to try to break a seal!  It takes [Commas(Cost)] capacity."
				src.Using=0
				return
			usr.TakeManaCapacity(Cost)
			var/EnemyRoll=(round(Choice.Level)*5)
			if(Choice.Creator==usr.ckey)
				EnemyRoll=0
			var/YourRoll=usr.Intelligence*usr.Imagination*usr.SealingMagicUnlocked
			if(usr.Saga=="Keyblade")
				YourRoll*=2
			var/YourRoll2=roll("[round(YourRoll)]d11")
			if(YourRoll2>=EnemyRoll)
				OMsg(usr, "[usr] manages to break [Choice]!")
				Choice.loc.overlays = null
				if(Choice.ZPlaneBind)
					var/mob/m = Choice.loc
					m.movementSealed = FALSE
				del Choice
			else
				OMsg(usr, "[usr] tries to unweave [Choice], but they can't figure out how to break it!")
			src.Using=0
			return

	Create_Magic_Circle
		desc="Deployment of a magical circle which will cut all capacity costs by 25%."
		verb/Create_Magic_Circle()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/Confirm=alert(usr, "Are you SURE you want to place your magic circle where you are CURRENTLY STANDING?", "Create Magic Circle", "No", "Yes")
			if(Confirm=="Yes")
				var/obj/Magic_Circle/MC=new
				MC.Creator=usr.ckey
				MC.loc=usr.loc
				usr << "You've successfully drawn your magic circle!"
				del src
			src.Using=0

	Create_Magic_Crest
		desc="Forge a collection of magical circuits that can be passed down and teaches the skills possessed within it."
		verb/Create_Magic_Crest()
			set category="Utility"
			if(src.Using)
				return
			if(usr.EquippedCrest())
				usr << "You're already carrying a legacy of magic."
				src.Using=0
				return
			src.Using=1
			var/Confirm=alert(usr, "Do you want to create your very own Magic Crest now?  You will only ever be able to make one.", "Make Magic Crest", "No", "Yes")
			if(Confirm=="Yes")
				var/obj/Items/Enchantment/Magic_Crest/MC=new
				MC.Wielder=usr.ckey
				usr.contents+=MC
				MC.ObjectUse(usr)
				usr << "You've created your own Magic Crest!  After filling it with knowledge of your spells, pass it on to a worthy successor to let them to do the same."
				del src
			src.Using=0

	Pocket_Dimension
		desc="Conjure your very own pocket dimension!"
		var
			LastX
			LastY
			LastZ
			PortalID//this will determine where it leads to...
		verb/Pocket_Dimension()
			set category="Utility"
			if(usr.KO)return
			if(usr.InMagitekRestrictedRegion())
				usr << "The pocket dimensons refuses to function."
				return
			if(src.LastX&&src.LastY&&src.LastZ)
				usr << "Don't open a Pocket Dimension in a Pocket Dimension!  That's how you break things."
				return
			src.LastX=usr.x
			src.LastY=usr.y
			src.LastZ=usr.z
			for(var/obj/Effects/PocketExit/PE in world)
				if(PE.Password==src.PortalID)
					OMsg(usr, "[usr] warps space and teleports sideways!")
					usr.loc=locate(PE.x, PE.y-1, PE.z)

	Grimoire_Arcana
		var/Operating//Don't spam this.
		verb/Grimoire_Arcana()
			set category="Utility"
			var/Economy=glob.progress.EconomyMana//Now based on MANA!
			var/mob/M//Who's getting the grimgrim?
			var/GrimoireChoice//What grim is m getting grimmed?
			var/Consent//PLEASE DO NOT RAPE THE GRIMGRIM.
			var/Cost//Grims are expensive.
			var/Confirm//Make sure you want to install that grimgrim.
			var/list/mob/Targets=list("Cancel")//The list of grimmable people.
			var/list/GrimoireChoices=list("Cancel")//Which grims have you grimmed?
			var/GrimoireDesc//Explains how to grim the grim.
			// global.PureMade=0
			// global.BlueMade=0
			// global.RedMade=0
			// global.ChainMade=0
			// global.BloodMade=0
			// global.SealMade=0
			// global.NobleMade=0
			// global.RagnaMade=0
			// global.EmptyMade=0
			// global.RelativityMade=0

			if(src.Operating)
				usr << "You're already running a project!"
				return
			src.Operating=1
			// if(global.PureMade<3)//Made less than 3 pure grimoires?
			// 	if(usr.GrimoiresMade<GrimoireLimit&&(usr.AlchemyUnlocked>=5||usr.ImprovedAlchemyUnlocked>=3))//Made less than 3 types of grimoires?
			// 		GrimoireChoices.Add("Pure Grimoire: No Name")//Allow this to be selectable.
			// if(global.BlueMade<2&&usr.ImprovedAlchemyUnlocked>=5&&usr.TomeCreationUnlocked>=3)//Less than 2 blue grimoires of either type made?
			// 	if(usr.GrimoiresMade<GrimoireLimit)//Less than 3 types of grimoires?
			// 		GrimoireChoices.Add("Azure Grimoire: Blaze Blue")//Allow
			// 		if(usr.Intelligence*usr.Imagination>=2)
			// 			GrimoireChoices.Add("Azure Grimoire (True): Blaze Blue")
			// if(global.RedMade<1&&usr.TomeCreationUnlocked>=5&&usr.ImprovedAlchemyUnlocked>=3)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Crimson Grimoire: Burning Red")
			// if(global.ChainMade<2&&usr.SummoningMagicUnlocked>=5)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Chain Grimoire: Soul Contract")//Contract crafting
			// if(global.BloodMade<1&&usr.ToolEnchantmentUnlocked>=5)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Blood Grimoire: Demon-Blood Talismans")//Demon Blood Talismans
			// if(global.SealMade<1&&usr.SealingMagicUnlocked>=5)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Seal Grimoire: Evil-Containment Wave")//Mafuba
			// if(global.NobleMade<2&&usr.CrestCreationUnlocked>=5&&(usr.SummoningMagicUnlocked>=5||usr.SpaceMagicUnlocked>=3))
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Destruction Grimoire: Giga Slave")//Gravity bomb
			// if(global.RagnaMade<2&&usr.CrestCreationUnlocked>=5&&(usr.SummoningMagicUnlocked>=5||usr.SpaceMagicUnlocked>=3))
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Severance Grimoire: Ragna Blade")//Heeeeh
			// if(global.EmptyMade<2&&usr.SpaceMagicUnlocked>=5)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Empty Grimoire: Traverse Void")//Traverse Void
			// if(global.RelativityMade<1&&usr.TimeMagicUnlocked>=5)
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Relativity Grimoire: Time Alter")//Time Alter
			// if(global.StasisMade<1&&(usr.TimeMagicUnlocked>=5&&usr.SpaceMagicUnlocked>=5))
			// 	if(usr.GrimoiresMade<GrimoireLimit)
			// 		GrimoireChoices.Add("Stasis Grimoire: Time Stop")//THE WORLD
			// if(!global.YukianesaMade&&usr.GrimoiresMade<GrimoireLimit&&usr.ArmamentEnchantmentUnlocked>=5)
			// 	GrimoireChoices.Add("Arch-Enemy Grimoire: Ice Sword")
			// if(!global.BolverkMade&&usr.GrimoiresMade<GrimoireLimit&&usr.ArmamentEnchantmentUnlocked>=5)
			// 	GrimoireChoices.Add("Arch-Enemy Grimoire: Demon Guns")
			// if(!global.OokamiMade&&usr.GrimoiresMade<GrimoireLimit&&usr.ArmamentEnchantmentUnlocked>=5)
			// 	GrimoireChoices.Add("Arch-Enemy Grimoire: Slaying Demon")

			for(var/mob/m in view(usr, 1))
				Targets+=m
			M=input(usr, "Who do you want to lecture?", "Grimoire Arcana") in Targets

			if(M=="Cancel")
				OMsg(usr, "[usr] decides not to research.")
				src.Operating=0
				return
			if(M.Saga)
				OMsg(usr, "[M]'s soul rejects the knowlege!")
				src.Operating=0
				return
			if(M!=usr)
				Consent=alert(M, "[usr] wishes to lecture you on grimoire magic. Do you consent to the operation?", "Grimoire Arcana", "No", "Yes")
			if(Consent=="No")
				OMsg(usr, "[usr] offered [M] a grimoire and was refused!")
				src.Operating=0
				return

			GrimoireChoice=input(usr, "What grimoire would you like to study?", "Grimoire Arcana") in GrimoireChoices
			if(GrimoireChoice=="Cancel")
				OMsg(usr, "[usr] decides not to research.")
				src.Operating=0
				return
			if(GrimoireChoices.len<2)
				usr << "You don't know of any grimoires to decipher!"
				src.Operating=0
				return

			switch(GrimoireChoice)
				if("Pure Grimoire: No Name")
					Cost=Economy*25
					GrimoireDesc="The Pure Grimoire augment the sorcerer's strengths and allieviate their weaknesses, but they can only be active for a certain amount of time."
				if("Azure Grimoire: Blaze Blue")
					Cost=Economy*75
					GrimoireDesc="The Azure Grimoire can be used to replace a lost limb.  They grant the user fantastic mana capacity and augment their strength with that bolstered reserve.  However, it taxes the body to contain so much mana."
				if("Azure Grimoire (True): Blaze Blue")
					Cost=Economy*100
					GrimoireDesc="The Azure Grimoire can be used to replace a lost limb.  They grant the user increased mana capacity and augment their strength with that increased magical prowess.  It is a perfect Grimoire and does not tax the body to use."
				if("Crimson Grimoire: Burning Red")
					Cost=Economy*100
					GrimoireDesc="The Crimson Grimoire is not installed into the body and exists outside of it.  While active, it allows the sorcerer to use magic without mana."
				if("Chain Grimoire: Soul Contract")
					Cost=Economy*50
					GrimoireDesc="The Chain Grimoire is used to bind the souls of sapient beings together with esoteric contracts."
				if("Blood Grimoire: Demon-Blood Talismans")
					Cost=Economy*50
					GrimoireDesc="The Blood Grimoire is forged with the blood of potent beings and can be used to temporarily augment spellcasting."
				if("Seal Grimoire: Evil-Containment Wave")
					Cost=Economy*100
					GrimoireDesc="The Seal Grimoire is used to seal unholy presences away."
				if("Severance Grimoire: Ragna Blade")
					Cost=Economy*100
					GrimoireDesc="The Severance Grimoire allows the user to invoke the primal chaos and rend any enemy asunder."
				if("Destruction Grimoire: Giga Slave")
					Cost=Economy*200
					GrimoireDesc="The Destruction Grimoire allows the user to invoke the primal chaos and annihilate whatever stands against them."
				if("Empty Grimoire: Traverse Void")
					Cost=Economy*50
					GrimoireDesc="The Empty Grimoire allows traversal through emptiness of space."
				if("Stasis Grimoire: Time Stop")
					Cost=Economy*50
					GrimoireDesc="The Stasis Grimorie allows time to be stopped."
				if("Relativity Grimoire: Time Alter")
					Cost=Economy*25
					GrimoireDesc="The Relativity Grimoire allows the flow of time to be altered on a personal scale."
				if("Arch-Enemy Grimoire: Ice Sword")
					Cost=Economy*50
					GrimoireDesc="This Nox Nyctores controls the aspect of ice, hardening its wielder into a passionless hero."
				if("Arch-Enemy Grimoire: Demon Guns")
					Cost=Economy*50
					GrimoireDesc="This Nox Nyctores allows a wielder to shoot without regard for space, hollowing its wielder into a heartless doll."
				if("Arch-Enemy Grimoire: Slaying Demon")
					Cost=Economy*50
					GrimoireDesc="This Nox Nyctores deconstructs magical formulae, bleaching its wielder into a white void."
			GrimoireDesc="[GrimoireDesc]  It takes [Commas(Cost)] mana capacity to experiment with this grimoire.  Do you wish to continue?"
			Confirm=alert(usr, "[GrimoireDesc]", "Grimoire Arcana ([GrimoireChoice])", "Yes", "No")
			if(Confirm=="No")
				OMsg(usr, "[usr] decided to not research.")
				src.Operating=0
				return

			if(M!=usr)
				Consent=alert(M, "[usr] wishes to record a [GrimoireChoice] in you.  [GrimoireDesc]  Do you accept this?", "Grimoire Arcana ([GrimoireChoice])", "No", "Yes")
			if(Consent=="No")
				OMsg(usr, "[usr] tried to record a [GrimoireChoice] in [M], but [M] backed out at the last minute!")
				src.Operating=0
				return

			if(!usr.HasManaCapacity(Cost))
				OMsg(usr, "[usr] tried to record a [GrimoireChoice] in [M]...but they don't have enough mana!!")
				src.Operating=0
				return

			// switch(GrimoireChoice)
			// 	if("Pure Grimoire: No Name")
			// 		M.contents+=new/obj/Items/Gear/Pure_Grimoire
			// 		usr.GrimoiresMade++//Add grimoires made
			// 		global.PureMade++//Add one to the count
			// 	if("Azure Grimoire: Blaze Blue")
			// 		M.contents+=new/obj/Items/Gear/Prosthetic_Limb/Azure_Grimoire
			// 		usr.GrimoiresMade++
			// 		global.BlueMade++
			// 	if("Azure Grimoire (True): Blaze Blue")
			// 		M.contents+=new/obj/Items/Gear/Prosthetic_Limb/Blue_Grimoire
			// 		usr.GrimoiresMade++
			// 		global.BlueMade++
			// 	if("Crimson Grimoire: Burning Red")
			// 		M.contents+=new/obj/Items/Gear/Crimson_Grimoire
			// 		usr.GrimoiresMade++
			// 		global.RedMade++
			// 	if("Chain Grimoire: Soul Contract")
			// 		// if(locate(/obj/Skills/Utility/Contractor, M))
			// 		// 	OMsg(usr, "[M] already has a Chain Grimoire recorded in their memory!")
			// 		// 	src.Operating=0
			// 		// 	return
			// 		// M.AddSkill(new/obj/Skills/Utility/Contractor)
			// 		M.ContractPowered+=5
			// 		usr.GrimoiresMade++
			// 		global.ChainMade++
			// 	if("Blood Grimoire: Demon-Blood Talismans")
			// 		M.contents+=new/obj/Items/Gear/Blood_Grimoire
			// 		usr.GrimoiresMade++
			// 		global.BloodMade++
			// 	if("Seal Grimoire: Evil-Containment Wave")
			// 		if(locate(/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Mafuba, M))
			// 			OMsg(usr, "[M] already has a Seal Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Mafuba)
			// 		usr.GrimoiresMade++
			// 		global.SealMade++
			// 	if("Severance Grimoire: Ragna Blade")
			// 		if(locate(/obj/Skills/Queue/Ragna_Blade, M))
			// 			OMsg(usr, "[M] already has a Severance Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/Queue/Ragna_Blade)
			// 		usr.GrimoiresMade++
			// 		global.RagnaMade++
			// 	if("Destruction Grimoire: Giga Slave")
			// 		if(locate(/obj/Skills/AutoHit/Giga_Slave, M))
			// 			OMsg(usr, "[M] already has a Destruction Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/AutoHit/Giga_Slave)
			// 		usr.GrimoiresMade++
			// 		global.NobleMade++
			// 	if("Empty Grimoire: Traverse Void")
			// 		if(locate(/obj/Skills/Teleport/Traverse_Void, M))
			// 			OMsg(usr, "[M] already has an Empty Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/Teleport/Traverse_Void)
			// 		if(!locate(/obj/Skills/Utility/Observe, M))
			// 			M.AddSkill(new/obj/Skills/Utility/Observe)
			// 		usr.GrimoiresMade++
			// 		global.EmptyMade++
			// 	if("Stasis Grimoire: Time Stop")
			// 		if(locate(/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Time_Stop, M))
			// 			OMsg(usr, "[M] already has a Stasis Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Time_Stop)
			// 		usr.GrimoiresMade++
			// 		global.StasisMade++
			// 	if("Relativity Grimoire: Time Alter")
			// 		if(locate(/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Time_Alter, M))
			// 			OMsg(usr, "[M] already has a Relativity Grimoire recorded in their memory!")
			// 			src.Operating=0
			// 			return
			// 		M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Time_Alter)
			// 		usr.GrimoiresMade++
			// 		global.RelativityMade++
			// 	if("Arch-Enemy Grimoire: Ice Sword")
			// 		var/obj/Items/Sword/S=new/obj/Items/Sword/Light/Legendary/Yukianesa
			// 		S.TrueLegend=1
			// 		M.contents+=S
			// 		usr.GrimoiresMade++
			// 		global.YukianesaMade++
			// 	if("Arch-Enemy Grimoire: Demon Guns")
			// 		var/obj/Items/Enchantment/Staff/S=new/obj/Items/Enchantment/Staff/NonElemental/Rod/Legendary/Bolverk
			// 		S.TrueLegend=1
			// 		M.contents+=S
			// 		usr.GrimoiresMade++
			// 		global.BolverkMade++
			// 	if("Arch-Enemy Grimoire: Slaying Demon")
			// 		var/obj/Items/Sword/S=new/obj/Items/Sword/Heavy/Legendary/Ookami
			// 		S.TrueLegend=1
			// 		M.contents+=S
			// 		usr.GrimoiresMade++
			// 		global.OokamiMade++
			// //at the end
			// OMsg(usr, "[usr] experimented on [M], recording a [GrimoireChoice]!")
			// usr.TakeManaCapacity(Cost)
			// src.Operating=0

	// Contractor
	// 	NoTransplant=1
	// 	Level=100
	// 	desc="Allows you to contract souls and use them."
	// 	var
	// 		NeverContracted=1//for first pip of summoner power
	// 		//These are variables for the user to flag for themselves.
	// 		TeleportX=0
	// 		TeleportY=0
	// 		TeleportZ=0
	// 		SummonX=0
	// 		SummonY=0
	// 		SummonZ=0
	// 	verb/ContractSoul()
	// 		set category="Utility"
	// 		set name="Contract Soul"
	// 		var/list/PeopleX=new
	// 		for(var/mob/Players/M in get_step(usr,usr.dir))
	// 			PeopleX+=M
	// 		var/mob/A=input(usr,"Contract who?") in PeopleX||null
	// 		if(A)
	// 			var/Consent
	// 			Consent=alert(A, "[usr] wishes to link your souls together with a contract.  Do you accept this contract?", "Soul Contract", "Yes", "No")
	// 			if(Consent=="No")
	// 				OMsg(usr, "[A] refuses to be chained to [usr]!")
	// 				return
	// 			OMsg(usr, "<font color='red'>[A] signed their soul to [usr]!</font color>")
	// 			var/obj/L=new/obj/Skills/Soul_Contract
	// 			L:ContractKey=usr.key
	// 			A.AddSkill(L)
	// 			A.ContractPowered=1
	// 			if(src.NeverContracted)
	// 				src.NeverContracted=0
	// 				usr.ContractPowered=1
	// 	verb/UseContract()
	// 		set category="Utility"
	// 		set name="Use Contract"
	// 		if(!usr.Move_Requirements()||usr.KO)
	// 			return
	// 		var/list/ContractedPeople=list("Cancel")
	// 		var/ContractConfirmed=0
	// 		for(var/mob/Players/A in world)
	// 			if(locate(/obj/Skills/Soul_Contract,A.contents))
	// 				for(var/obj/Skills/Soul_Contract/B in A)
	// 					if(B.ContractKey==usr.key)
	// 						ContractedPeople+=A
	// 						ContractConfirmed=1

	// 		if(ContractConfirmed==0)
	// 			usr<<"You have no active contracts currently."
	// 			return
	// 		var/mob/C=input(usr,"Who would you like to invoke your Contract abilities on?") in ContractedPeople
	// 		if(C=="Cancel")
	// 			return
	// 		else
	// 			var/list/thelist=list("Summon","Dismiss","Transfer Power","Take Power","Communicate","Lifelink","Punish","Teleport","Unteleport","Cancel")

	// 			if(locate(/obj/Seal/Command_Seal,usr))
	// 				thelist.Add("Suicide")
	// 				thelist.Add("Miracle")
	// 				thelist.Add("Obedience")

	// 			var/Choice=input("What action would you like to do?") in thelist
	// 			switch(Choice)
	// 				if("Cancel")
	// 					return
	// 				if("Summon")
	// 					for(var/obj/Skills/Soul_Contract/D in C)
	// 						C.PrevX=C.x
	// 						C.PrevY=C.y
	// 						C.PrevZ=C.z
	// 						C.SummonReturnTimer=-1
	// 						D.SummonX=C.x
	// 						D.SummonY=C.y
	// 						D.SummonZ=C.z
	// 						C.loc=locate(usr.x,usr.y,usr.z)
	// 						if(usr.y==1)
	// 							C.y=usr.y
	// 						else
	// 							C.y=usr.y-1
	// 						OMsg(usr, "[usr] summons [C]!")
	// 				if("Dismiss")
	// 					for(var/obj/Skills/Soul_Contract/D in C)
	// 						if(D.SummonX==0||D.SummonY==0||D.SummonZ==0)
	// 							usr<<"You can't dismiss someone without summoning them first!"
	// 							return
	// 						C.loc=locate(D.SummonX,D.SummonY,D.SummonZ)
	// 						C.SummonReturnTimer=0
	// 						D.SummonX=0
	// 						D.SummonY=0
	// 						D.SummonZ=0
	// 						OMsg(usr, "[usr] dismisses [C]!")
	// 				if("Communicate")
	// 					usr.TwoWayTelepath(C)
	// 					return
	// 				if("Transfer Power")
	// 					if(usr.ContractPowered)
	// 						C.ContractPowered+=1
	// 						usr.ContractPowered-=1
	// 						usr << "You give [C] power through the contract!"
	// 						C << "[usr] imbues you with power via their contract!"
	// 					else
	// 						usr << "You don't have any contract power to spare!"
	// 					return
	// 				if("Take Power")
	// 					if(C.ContractPowered)
	// 						C.ContractPowered-=1
	// 						usr.ContractPowered+=1
	// 						usr << "You take [C]'s power, adding it to your own!"
	// 						C << "[usr] draws on your power via the contract!"
	// 					else
	// 						usr << "You've already taken their power, or they don't have any contract to you!"
	// 					return
	// 				if("Lifelink")
	// 					if(usr.Transfering)
	// 						usr<<"You stop lifelinking."
	// 						usr.Transfering=null
	// 						src.Using=0
	// 						return
	// 					else
	// 						usr.Transfering=C
	// 						usr<<"You begin sharing your lifeforce."
	// 						src.Using=0
	// 					return
	// 				if("Punish")
	// 					if(usr.ManaAmount>=30*max((C.Power/usr.Power),1))
	// 						usr.LoseMana(30*max((C.Power/usr.Power),1))
	// 						if(C.HellPower&&prob(50))
	// 							OMsg(usr, "[usr] failed to punish [C] using their contract!")
	// 							src.Using=0
	// 							return
	// 						C << "<font color=#FF0000>A jolt of pain goes through your body!</font>"
	// 						C.DamageSelf(TrueDamage(10))
	// 						Stun(C, 3)
	// 						OMsg(usr, "[usr] punishes [C] using their contract!")
	// 						src.Using=0
	// 						return
	// 					else
	// 						OMsg(usr, "[usr] lacks strength to punish [C].")
	// 						src.Using=0
	// 						return
	// 				if("Teleport")
	// 					if(usr.Grab)
	// 						usr << "You can't grab someone and teleport!"
	// 						src.Using=0
	// 						return
	// 					src.TeleportX=usr.x
	// 					src.TeleportY=usr.y
	// 					src.TeleportZ=usr.z
	// 					usr.loc=C.loc
	// 					OMsg(usr, "[usr] appears beside [C] by their contract!")
	// 					return
	// 				if("Unteleport")
	// 					if(usr.Grab)
	// 						usr << "You can't grab someone and unteleport!"
	// 						src.Using=0
	// 						return
	// 					if(!src.TeleportX||!src.TeleportY||!src.TeleportZ)
	// 						usr << "You don't have a previous location to return to."
	// 						src.Using=0
	// 						return
	// 					OMsg(usr, "[usr] returns to a previous location!")
	// 					usr.loc=locate(src.TeleportX, src.TeleportY, src.TeleportZ)
	// 					return
	// 				if("Suicide")
	// 					for(var/obj/Seal/Command_Seal/CS in usr)
	// 						if(CS.Orders>=3)
	// 							CS.Orders--
	// 							CS.Orders--
	// 							CS.Orders--
	// 							if(CS.Orders<=0)
	// 								OMsg(usr, "The Command Seal fades from [usr]!")
	// 								del CS
	// 							if(C.HellPower&&prob(50))
	// 								OMsg(usr, "[usr] failed to order [C] using their Command Seal!")
	// 								src.Using=0
	// 								return
	// 							C.CursedWounds=1
	// 							C.DamageSelf(TrueDamage(250))
	// 							C.CursedWounds=0
	// 							OMsg(usr, "[C] harms themselves grieviously under [usr]'s command!")
	// 					return
	// 				if("Miracle")
	// 					for(var/obj/Seal/Command_Seal/CS in usr)
	// 						if(CS.Orders>=2)
	// 							CS.Orders--
	// 							CS.Orders--
	// 							if(CS.Orders<=0)
	// 								OMsg(usr, "The Command Seal fades from [usr]!")
	// 								del CS
	// 							C.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Empowered)
	// 							OMsg(usr, "[C] becomes capable of miracles under [usr]'s command!")
	// 					return
	// 				if("Obedience")
	// 					for(var/obj/Seal/Command_Seal/CS in usr)
	// 						CS.Orders--
	// 						if(CS.Orders<=0)
	// 							OMsg(usr, "The Command Seal fades from [usr]!")
	// 							del CS
	// 						if(C.HellPower&&prob(50))
	// 							OMsg(usr, "[usr] failed to order [C] using their Command Seal!")
	// 							src.Using=0
	// 							return
	// 						var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shackled/S=new
	// 						S.Password=usr.name
	// 						C.AddSkill(S)
	// 						OMsg(usr, "[C] becomes incapable of harming [usr]!")
	// 					return

	Smelt
		desc="Smelt an item to refund 50% of its cost."
		verb/Recycle_Items()
			set category="Utility"
			if(src.Using)
				return
			src.Using=1
			var/list/obj/Items/Items=list("Cancel")
			for(var/obj/Items/SmeltYaLater in usr)
				if(SmeltYaLater.Cost>0&&SmeltYaLater.Destructable)
					if(!(istype(SmeltYaLater,/obj/Items/Enchantment)) && SmeltYaLater.Grabbable)
						Items.Add(SmeltYaLater)
			for(var/obj/Items/SmeltYaLater in get_step(usr, usr.dir))
				if(SmeltYaLater.Cost>0&&SmeltYaLater.Destructable)
					if(!(istype(SmeltYaLater,/obj/Items/Enchantment)) && SmeltYaLater.Grabbable)
						Items.Add(SmeltYaLater)
			var/obj/Items/Choice=input(usr, "Which item would you like to recycle?", "Smelt") in Items
			if(Choice=="Cancel")
				src.Using=0
				return
			if(Choice.Password)
				var/Pass=input(usr, "This item is protected by a password; you have to provide it before recycling.", "Remove Safety") as text
				if(Choice.Password!=Pass)
					usr << "That is not the correct password."
					src.Using=0
					return
			if(Choice)//make sure people can't spam a single item to get inf money
				var/enchantBoon = Choice:Element ? Choice:Element : "None"
				var/list/boonValues = list("None" = 1,"Poison" = 2.5, "Silver" = 2.5, "Dark" = 5, "Light" = 5, "Chaos" = 50, "Ultima" = 200)
				usr.GiveMoney((0.5*Technology_Price(usr,Choice)) * boonValues[enchantBoon])
				if(Choice.TotalStack)
					Choice.TotalStack--
					Choice.suffix="[Choice.TotalStack]"
					if(0 >= Choice.TotalStack) del Choice
				else
					del Choice
			src.Using=0
			return


	Copy_Key
		var/Copying //Don't spam this.
		verb
			Copy_Key()
				set category="Utility"
				var/obj/Items/Choice
				var/Confirm
				var/Cost

				if(src.Copying)
					usr << "You're already using this."
					return

				src.Copying=1

				var/list/obj/Items/Tech/Keys=list("Cancel")

				for(var/obj/Items/Tech/Door_Pass/k in usr)
					Keys.Add(k)

				if(Keys.len<2)
					usr << "You have no keys to copy!"
					src.Copying=0
					return
				else
					Choice=input(usr, "What key do you wish to copy?", "Locksmithing") in Keys

				if(Choice=="Cancel")
					src.Copying=0
					return

				Cost=Technology_Price(usr,Choice)

				Confirm=alert(usr, "It will cost [Commas(Cost)] to copy [Choice].  Do you wish to copy the key?", "Locksmithing", "No", "Yes")

				if(Confirm=="No")
					src.Copying=0
					return

				for(var/obj/Money/m in usr)
					if(m.Level<Cost)
						usr << "You don't have enough money to copy [Choice]. ([Commas(m.Level)] / [Commas(Cost)])"
						src.Copying=0
						return
					else
						m.Level-=Cost

				var/obj/Items/Tech/Door_Pass/kc=new
				kc.Password=Choice.Password
				usr.contents+=kc

	Reforge
		var/Repairing//Don't spam this.
		verb
			Reforge()
				set category="Utility"
				var/obj/Items/Choice
				var/Confirm
				var/Cost
				var/CostMultiplier=1

				if(src.Repairing)
					usr << "You're already using this."
					return

				src.Repairing=1
				var/Category=input(usr, "What category of item are you reforging?", "Reforge") in list("Cancel", "Weapon", "Armor", "Staff")
				if(Category=="Cancel")
					src.Repairing=0
					return

				var/list/obj/Items/Sword/Swords=list("Cancel")
				var/list/obj/Items/Armor/Armors=list("Cancel")
				var/list/obj/Items/Enchantment/Staff/Staves=list("Cancel")

				switch(Category)
					if("Weapon")
						for(var/obj/Items/Sword/s in usr)
							if(s.Broken&&s.Class!="Wooden"&&!s.Conjured)
								Swords.Add(s)
					if("Armor")
						for(var/obj/Items/Armor/a in usr)
							if(a.Broken&&!a.Conjured)
								Armors.Add(a)
					if("Staff")
						for(var/obj/Items/Enchantment/Staff/s in usr)
							if(s.Broken&&!s.Conjured)
								Staves.Add(s)

				if(Category=="Weapon"&&Swords.len<2)
					usr << "You have no broken swords to reforge!"
					src.Repairing=0
					return
				if(Category=="Armor"&&Armors.len<2)
					usr << "You have no broken armors to reforge!"
					Repairing=0
					return
				if(Category=="Staff"&&Staves.len<2)
					usr << "You have no broken staves to reforge!"
					src.Repairing=0
					return

				switch(Category)
					if("Weapon")
						Choice=input(usr, "What weapon do you wish to repair?", "Reforge") in Swords
					if("Armor")
						Choice=input(usr, "What armor do you wish to repair?", "Reforge") in Armors
					if("Staff")
						Choice=input(usr, "What staff do you wish to repair?", "Reforge") in Staves

				if(Choice=="Cancel")
					src.Repairing=0
					return

				Cost=0.5*Technology_Price(usr,Choice)

				if(Category=="Staff")
					Cost/=100

				if(Choice:Element)
					if(Choice:Element=="Silver"||Choice:Element=="Poison")
						CostMultiplier*=5
					if(Choice:Element=="Dark"||Choice:Element=="Light")
						CostMultiplier*=10
					if(Choice:Element=="Chaos")
						CostMultiplier*=15
					if(Choice:Element=="Ultima")
						CostMultiplier*=30

				if(Choice:ExtraClass)
					if(CostMultiplier>1)
						CostMultiplier+=10
					else
						CostMultiplier+=9

				if(Choice:Ascended)
					if(CostMultiplier>1)
						CostMultiplier+=3*(4**Choice:Ascended)
					else
						CostMultiplier+=(3*(4**Choice:Ascended))-1

				if(usr.ArmamentEnchantmentUnlocked)
					Cost/=max(usr.RepairAndConversionUnlocked+usr.ForgingUnlocked,1)

				Confirm=alert(usr, "It will cost [Commas(Cost*CostMultiplier)] to repair [Choice].  Do you wish to repair the [Category]?", "Reforge", "No", "Yes")

				if(Confirm=="No")
					src.Repairing=0
					return

				for(var/obj/Money/m in usr)
					if(m.Level<Cost*CostMultiplier)
						usr << "You don't have enough money to reforge [Choice]. ([Commas(m.Level)] / [Commas(Cost*CostMultiplier)])"
						src.Repairing=0
						return
					else
						m.Level-=Cost*CostMultiplier

				Choice:ShatterCounter=Choice:ShatterMax
				Choice:Broken=0
				Choice.suffix=0

				OMsg(usr, "[usr] has reforged [Choice]!")
				src.Repairing=0

	Surgery
		desc="Heal wounds at the cost of your own fatigue."
		var/Cost
		verb/Surgery()
			set category="Utility"
			if(src.Using)
				usr << "You're already preparing to perform surgery!"
				return
			if(usr.HasPiloting()||usr.HasPossessive())
				usr << "You're not capable of necessary precision!"
				return
			if(usr.TotalFatigue>=90)
				usr << "You're too exhausted to perform more surgery!"
				return
			src.Using=1
			var/list/mob/Players/Peeps=list("Cancel")
			for(var/mob/Players/P in oview(usr, 1))
				if(P.BPPoison<1||P.TotalInjury>10)
					Peeps.Add(P)
			if(usr.MedicineUnlocked+usr.ImprovedMedicalTechnologyUnlocked>=4)
				if(usr.BPPoison<1||usr.TotalInjury>10)
					Peeps.Add(usr)
			if(Peeps.len<2)
				usr << "There is no one nearby to perform surgery on!"
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "Who would you like to perform surgery on?", "Surgery") in Peeps
			if(Choice=="Cancel")
				src.Using=0
				return
			if(Choice.icon_state!="Meditate"&&Choice.icon_state!="KO")
				usr << "[Choice] isn't prepared to have surgery used on them!  Make them lay down."
				src.Using=0
				return
			Cost=0.25*glob.progress.EconomyCost
			if(usr.HasMoney(Cost))
				usr.TakeMoney(Cost)
			else
				usr << "You don't have enough resources to perform the operation! ([Commas(usr.GetMoney())] / [Commas(Cost)])"
				return
			usr.Frozen=2
			Choice.Frozen=1
			OMsg(usr, "[usr] performs surgery on [Choice] to patch up their injuries...")
			sleep(150)
			Choice.MortallyWounded=max(Choice.MortallyWounded-1,0)
			Choice.SenseRobbed=max(Choice.SenseRobbed-1,0)
			Choice.BPPoisonTimer/=1+0.2*(usr.MedicineUnlocked+(2*usr.ImprovedMedicalTechnologyUnlocked))
			Choice.HealWounds(Choice.TotalInjury*0.05*(usr.MedicineUnlocked+(2*usr.ImprovedMedicalTechnologyUnlocked)))
			usr.GainFatigue(20)
			Choice.Frozen=0
			usr.Frozen=0
			OMsg(usr, "[usr] finishes performing surgery on [Choice]!")
			src.Using=0

	Revival_Protocol
		desc="Inject a fresh corpse with a rejuvenating mixture. Outcome might vary."
		var/Cost
		verb/Revival_Protocol()
			set category="Utility"
			if(src.Using)
				usr << "You're already preparing to perform the recovery!"
				return
			if(usr.HasPiloting()||usr.HasPossessive())
				usr << "You're not capable of necessary precision!"
				return
			if(usr.TotalFatigue>=90)
				usr << "You're too exhausted to perform the recovery!"
				return
			src.Using=1
			var/list/valid=list("Cancel")
			var/list/Bodies=list()
			var/list/Souls=list()
			var/Degeneration=0
			for(var/mob/Body/m in view(usr, 1))
				if(world.realtime<m.DeathTime+Minute(30))
					Bodies+=m
			for(var/mob/m in players)
				if(m.Dead&&!m.DeathKilled)
					Souls+=m
			for(var/mob/m in Souls)
				for(var/mob/Body/b in Bodies)
					if(b.DeathKillerTargets==m.key)
						valid+=m
			if(valid.len <= 1)
				usr << "No valid targets..."
				src.Using=0
				return
			var/mob/Choice=input(usr, "Viable targets for the procedure.", "Revival Protocol") in valid
			if(Choice=="Cancel")
				src.Using=0
				return
			Cost=2.5*glob.progress.EconomyCost
			if(usr.HasMoney(Cost))
				usr.TakeMoney(Cost)
			else
				usr << "You don't have enough resources to perform the operation! ([Commas(usr.GetMoney())] / [Commas(Cost)])"
				src.Using=0
				return
			var/AlreadyAlive=0
			var/Chance=5*usr.MedicineUnlocked
			Chance+=7.5*usr.ImprovedMedicalTechnologyUnlocked
			Chance*=(1-(min(100, Choice.Potential)/100))
			if(prob(Chance))
				for(var/mob/Body/b in view(usr, 1))
					if(b.DeathTime<world.realtime)
						Degeneration=(world.realtime-b.DeathTime)/Minute(60)
					if(b.DeathKillerTargets==Choice.key)
						for(var/obj/Items/I in b)
							if(I.suffix=="*Equipped*")
								spawn(5) I.suffix=null
							I.loc = Choice
						Choice.loc=b.loc
						if(!b.TrulyDead)
							AlreadyAlive=1
						del b
				Choice.Revive()
				if(!AlreadyAlive)//dont nerf unless they were actually dead
					Choice.DeathKilled=1
					Choice.StrCut+=Degeneration*GoCrand(0,1)
					Choice.ForCut+=Degeneration*GoCrand(0,1)
					Choice.EndCut+=Degeneration*GoCrand(0,1)
					Choice.SpdCut+=Degeneration*GoCrand(0,1)
					OMsg(usr, "[usr] manages to bring [Choice] back to life...")
				else
					OMsg(usr, "[usr] forces [Choice] back to life immediately!")
				Log("Admin","<font color=green>([usr.name])([usr.key]) succeeded in bringing [Choice]([Choice.key]) back to life using revival protocol.")
				Log("Admin","<font color=green>([Choice.name])([Choice.key]) was brought back to life by [usr]([usr.key]) using revival protocol.")
			else
				if(!AlreadyAlive)
					Choice.DeathKilled=-1 //I did this so that if Revival Protocol fails, it cannot be used again. But the player can still be masamuned. Prevents this from cheesing them out of a 100% chance.
					OMsg(usr, "[usr] fails to bring [Choice] back to life...")
					Log("Admin","<font color=green>([usr.name])([usr.key]) failed in bringing [Choice]([Choice.key]) back to life using revival protocol.")
				else
					OMsg(usr, "[usr] seems to create a spark of life in [Choice]...but they're still unconscious...")
					Log("Admin","<font color=green>([usr.name])([usr.key]) failed in bringing [Choice]([Choice.key]) back to life using revival protocol...but they're voiding anyway.")

			src.Using=0

	Internal_Communicator
		var/ICFrequency=9999
		var/MonitoringFrequency=0
		var/Detecting=0
		var/Range=1
		desc="A internal communicator. Broadcasts on Scouter frequencies. It can also monitor a frequency you are not actively broadcasting on."
		verb/Toggle_Internal_Scouter()
			set category="Utility"
			if(usr.InternalScouter)
				usr.InternalScouter=0
				usr << "You deactivate your internal scouter."
			else
				usr.InternalScouter=1
				usr << "You activate your internal scouter."
		verb/CommunicatorTransmit(A as text)
			set category="Utility"
			set name="Communicator Transmit"
			set src in usr
			if(usr.CheckSlotless("Camouflage"))
				var/obj/Skills/Buffs/SlotlessBuffs/Camouflage/C = usr.GetSlotless("Camouflage")
				if(C.Invisible)
					C.Trigger(usr)
				usr << "Your camouflage is broken!"
			if(usr.CheckSlotless("Invisibility"))
				var/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Show/I = usr.GetSlotless("Magic Show")
				if(I.Invisible)
					I.Trigger(usr)
				usr << "You reveal yourself!"
			for(var/mob/Players/M in players)
				for(var/obj/Items/Tech/Communicator/Q in M)
					if(Q.Frequency==src.ICFrequency)
						M<<"<font color=green><b>([Q.name])</b> [usr.name]: [html_encode(A)]"
						Log(M.ChatLog(),"<font color=green>([src.name])[usr]([usr.key]) says: [html_encode(A)]")
				for(var/obj/Items/Tech/Scouter/Q in M)
					if(Q.Frequency==src.ICFrequency)
						M<<"<font color=green><b>(Scouter)</b> [usr.name]: [html_encode(A)]"
						Log(M.ChatLog(),"<font color=green>(Scouter)[usr]([usr.key]) says: [html_encode(A)]")
				for(var/obj/Skills/Utility/Internal_Communicator/B in M)
					if(B.ICFrequency==src.ICFrequency)
						M<<"<font color=green><b>(Internal Comms (Freq: [src.ICFrequency])):</b> [usr.name]: [html_encode(A)]"
						Log(M.ChatLog(),"<font color=green>(Internal Comms (Freq: [src.ICFrequency]))[usr]([usr.key]): [html_encode(A)]")
					if(B.MonitoringFrequency==src.ICFrequency)
						M<<"<font color=green><b>(Internal Comms (Monitor Freq: [src.MonitoringFrequency])):</b> [usr.name]: [html_encode(A)]"
			for(var/obj/Items/Tech/Speaker/X in world)
				if(X.Frequency==src.ICFrequency&&X.Active==1)
					for(var/mob/Y in hearers(X.AudioRange,X))
						Y<<"<font color=green><b>([X.name])</b> [usr.name]: [html_encode(A)]"
						Log(Y.ChatLog(),"<font color=green>([X.name])[usr]([usr.key]): [html_encode(A)]")
			for(var/obj/Items/Tech/Transmission_Tower/T in world)
				if(T.Frequency==src.ICFrequency)
					for(var/mob/Players/P in world)
						if(P.z==T.z)
							var/found=0
							for(var/obj/Items/Tech/Scouter/Q in P)
								found=1
								P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(A)]"
								Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(A)]")
								break
							if(!found)
								for(var/obj/Items/Tech/Communicator/Q in P)
									found=1
									P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(A)]"
									Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(A)]")
									break
							if(!found)
								for(var/obj/Skills/Utility/Internal_Communicator/B in P)
									P<<"<font color=red><b>(Long-Range Frequency)</b> [usr.name]: [html_encode(A)]"
									Log(P.ChatLog(),"<font color=red>(Long-Range Frequency)[usr]([usr.key]) says: [html_encode(A)]")
									break
		verb/ICFrequency()
			set category="Utility"
			set name="Communicator Frequency"
			set src in usr
			src.ICFrequency=input(usr,"Change your Internal Communicator frequency to what?","Frequency")as num
		verb/MonitorFrequency()
			set category="Utility"
			set name="Monitoring Frequency"
			set src in usr
			src.MonitoringFrequency=input(usr,"Change your Internal Communicator Monitoring frequency to what?","Monitoring Frequency")as num

		verb/Scan()
			set src in usr
			if(!src.suffix=="*Equipped*")
				usr << "You have to equip the scouter to use it!"
				return
			usr << "<b>Current Coordinates: ([usr.x], [usr.y], [usr.z])</b>"
			for(var/obj/Items/Tech/Beacon/B in world)
				if(B.BeaconState=="On"&&usr.z==B.z)
					usr << "<b><font color='green'>(BEACON)</font color></b> - ([B.x], [B.y], [B.z])"
			for(var/obj/Items/Enchantment/PocketDimensionGenerator/W in world)
				if(usr.z==W.z)
					usr << "<b><font color='red'>(DISTURBANCE)</font color></b> - ([W.x], [W.y], [W.z])"
			for(var/mob/Player/M in players)
				if(M.z==usr.z)
					var/D=abs(M.x-usr.x)+abs(M.y-usr.y)
					if(D<=src.Range*80)
						usr << "<b>!!!</b> - [usr.CheckDirection(M)] - [Commas(D)] tiles away"

	Espionage_Scan
		desc="Look someone over for wiretaps and remove them if desired."
		verb/Scan(var/mob/Players/p in view(1,usr))
			set category="Utility"
			var/found=0
			for(var/obj/Items/Tech/Planted_Wiretap/t in p)
				if(t.Revealed<=0)
					var/Chance=(10*usr.TelecommunicationsUnlocked)+(20*usr.AdvancedTransmissionTechnologyUnlocked)
					if(prob(Chance))
						t.Revealed++
					else
						t.Revealed--
					if(t.Revealed>0)
						usr << "You've discovered a wiretap planted on [p]!"
				if(t.CreatorKey==usr.ckey)
					t.Revealed=1
				if(t.Revealed>0)
					found=1
					del t
			if(found)
				OMsg(usr, "[usr] destroys all of the wiretaps on [p]!")
			else
				usr << "You don't find any wiretaps on [p]..."

	Satellite_Surveilance
		desc="Be a sneak in the sky."
		var/list/ZPlanes=list()
		verb/Satellite_Network()
			set category="Utility"
			usr << "Not this wipe, chief."
			return
			var/list/Choices=list("Cancel", "Launch", "Track")
			var/Choice=input(usr, "How do you manipulate your Satellite camera?", "Satellite Surveilance") in Choices
			switch(Choice)
				if("Launch")
					if(!(usr.z in src.ZPlanes))
						var/Cost=30*glob.progress.EconomyCost
						var/Confirm=alert(usr, "It will cost [Commas(Cost)] resources to build and launch a satellite camera.  Do you want to do this?", "Satellite Surveilance", "No", "Yes")
						if(Confirm=="Yes")
							if(usr.HasMoney(Cost))
								usr.TakeMoney(Cost)
								for(var/mob/Players/p in players)
									if(p.z==usr.z)
										p<<"<font color='red'><b>A jet stream rises to the sky to where a new star lingers...</b></font color>"
								src.ZPlanes.Add(usr.z)
							else
								usr << "You don't have enough money to launch a Satellite camera! ([Commas(usr.GetMoney())] / [Commas(Cost)])"
								return
					else
						usr << "You already have a Satellite camera for this area!"
						return
				if("Track")
					if(usr.Observing)
						Observify(usr, usr)
						usr.Observing=0
						return
					if(src.ZPlanes.len>0)
						var/list/mob/Players/Bugged=list("Cancel")
						var/SpyLand=input(usr, "What Z-section would you like to observe?", "Satellite Surveilance") in ZPlanes
						for(var/mob/Players/p in players)
							if(p.z==SpyLand)
								Bugged.Add(p)
							if(p.invisibility)
								Bugged.Remove(p)
						if(Bugged.len>1)
							var/mob/Players/Fly=input(usr, "Which person would you like to focus on?", "Satellite Surveilance") in Bugged
							Observify(usr,Fly)
							if(usr==Fly)
								usr.Observing=0
							else
								usr.Observing=1
						else
							usr << "There's no one to spy on there!"
							return


	Android_Integration
		desc="Integrate gear into yourself!"
		verb/Android_Integration()
			set category="Utility"
			if(src.Using)
				return
			if(usr.GetAndroidIntegrated()<2+usr.AscensionsAcquired)
				src.Using=1
				var/obj/Items/Gear/Choice
				var/list/obj/Items/Gear/IG=list("Cancel")
				for(var/obj/Items/Gear/g in usr)
					if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
						continue
					if(!g.Integrateable)
						continue
					IG.Add(g)
				if(IG.len<2)
					usr << "You don't have any gear capable of being integrated into your chasis."
					src.Using=0
					return
				Choice=input(usr, "What gear do you want to integrate into your chasis?", "Integrate") in IG
				if(Choice=="Cancel")
					src.Using=0
					return
				var/obj/Skills/NewS
				switch(Choice.type)
					if(/obj/Items/Gear/Deflector_Shield)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield
					if(/obj/Items/Gear/Bubble_Shield)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield
					if(/obj/Items/Gear/Jet_Boots)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots
					if(/obj/Items/Gear/Jet_Pack)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack
					if(/obj/Items/Gear/Plasma_Blaster)
						NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster
					if(/obj/Items/Gear/Plasma_Rifle)
						NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle
					if(/obj/Items/Gear/Plasma_Gatling)
						NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling
						NewS:Continuous=0
						NewS:Blasts=100
					if(/obj/Items/Gear/Missile_Launcher)
						NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher
					if(/obj/Items/Gear/Chemical_Mortar)
						NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar
					if(/obj/Items/Gear/Progressive_Blade)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade
					if(/obj/Items/Gear/Lightsaber)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber
					if(/obj/Items/Gear/Incinerator)
						NewS=new/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator
					if(/obj/Items/Gear/Freeze_Ray)
						NewS=new/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray
					if(/obj/Items/Gear/Pile_Bunker)
						NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker
					if(/obj/Items/Gear/Power_Fist)
						NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist
					if(/obj/Items/Gear/Blast_Fist)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist
					if(/obj/Items/Gear/Chainsaw)
						NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw
					if(/obj/Items/Gear/Power_Claw)
						NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw
					if(/obj/Items/Gear/Hook_Grip_Claw)
						NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw
					else
						usr << "Ruh roh.  Something went wrong.  Yell at Yan."
						src.Using=0
						return
				usr.AddSkill(NewS)
				del Choice
				usr << "You've integrated [Choice] into your chasis!"
				src.Using=0
				return

	Cybernetic_Augmentation
		desc="Modify your metal babies."
		verb/Augmentation()
			set category="Utility"

			if(usr.Secret=="Heavenly Restriction" && (usr.secretDatum?:hasRestriction("Science") || usr.secretDatum?:hasRestriction("Cybernetics")))
				return


			var/mob/M//Who's getting operated on?
			var/ModChoice//What's getting installed?
			var/Confirm//Are you sure you want to install this mod?
			var/Consent
			var/Cost//How much the mod costs.
			var/list/ModChoices=list("Cancel")//The list of choices available.
			var/ModDesc//Holds a description of the mod for the confirm prompt.

			if(src.Using)
				usr << "You're already running an operation!"
				return
			src.Using=1

			if("Cyber Augmentations" in usr.knowledgeTracker.learnedKnowledge || (usr.isRace(ANDROID)))
				ModChoices.Add("Enhanced Strength")
				ModChoices.Add("Enhanced Force")
				ModChoices.Add("Enhanced Endurance")
				ModChoices.Add("Enhanced Aggression")
				ModChoices.Add("Enhanced Reflexes")
				ModChoices.Add("Enhanced Speed")

			if("Neuron Manipulation" in usr.knowledgeTracker.learnedKnowledge || (usr.isRace(ANDROID)))
				ModChoices.Add("Internal Comms Suite")//talky in your heady
				ModChoices.Add("Blade Mode")//Cyberrush
				ModChoices.Add("Taser Strike")
				ModChoices.Add("Machine Gun Flurry")
				ModChoices.Add("Rocket Punch")
				ModChoices.Add("Stealth Systems")
				ModChoices.Add("Nano Boost")
				ModChoices.Add("Combat CPU")//autodoj
				ModChoices.Add("Reconstructive Nanobots")//autoheel
				ModChoices.Add("Internal Life Support")
				ModChoices.Add("Energy Assimilators")

			if("War Crimes" in usr.knowledgeTracker.learnedKnowledge || (usr.isRace(ANDROID)))
				ModChoices.Add("Punishment Chip")
				ModChoices.Add("Failsafe Circuit")
				ModChoices.Add("Explosive Implantation")

			//These are unlocked by default
			if("Singularity" in usr.knowledgeTracker.learnedKnowledge || (usr.isRace(ANDROID)))
				ModChoices.Add("Ripper Mode")
				ModChoices.Add("Armstrong Augmentation")
				ModChoices.Add("Ray Gear")
				ModChoices.Add("Overdrive")
				ModChoices.Add("Infinity Drive")

			var/list/Who=list("Cancel")
			if(usr.isRace(ANDROID))
				M = usr
			else
				for(var/mob/m in view(1, usr))
					/*if(m.isRace(ANDROID)&&!("Android Creation" in usr.knowledgeTracker.learnedKnowledge))
						continue*/
					if(m.Secret=="Heavenly Restriction" && (m.secretDatum?:hasRestriction("Science") || m.secretDatum?:hasRestriction("Cybernetics")))
						continue
					if(m==usr&&!(("Neuron Manipulation" in usr.knowledgeTracker.learnedKnowledge)||usr.isRace(ANDROID)))
						continue
					if(m.Saga && !(m.Saga in glob.CYBERIZESAGAS))
						continue
					Who+=m
				if(Who.len<1)
					usr << "You don't have any viable targets!"
					src.Using=0
					return
				
			if(!M)
				M=input(usr, "Who do you want to install cybernetics in?", "Cybernetic Augmentation") in Who
			if(M=="Cancel")
				OMsg(usr, "[usr] decides not to tinker.")
				src.Using=0
				return
			if(M!=usr)
				if(!("War Crimes" in usr.knowledgeTracker.learnedKnowledge)||!M.KO)
					Consent=alert(M, "Do you want to undergo the augmentation procedure?", "Cybernetic Augmentation", "No", "Yes")
					if(Consent!="Yes")
						OMsg(usr, "[usr] rejects the surgery.")
						src.Using=0
						return

			if(M.EnhanceChips>=M.EnhanceChipsMax)
				ModChoices.Remove("Enhanced Strength")
				ModChoices.Remove("Enhanced Force")
				ModChoices.Remove("Enhanced Endurance")
				ModChoices.Remove("Enhanced Aggression")
				ModChoices.Remove("Enhanced Reflexes")
				ModChoices.Remove("Enhanced Speed")

			if(M.NanoBoost)
				ModChoices.Remove("Nano Boost")
			if(M.BladeMode)
				ModChoices.Remove("Blade Mode")
			if(locate(/obj/Skills/Queue/Cyberize/Taser_Strike, M))
				ModChoices.Remove("Taser Strike")
			if(locate(/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry, M))
				ModChoices.Remove("Machine Gun Flurry")
			if(locate(/obj/Skills/Projectile/Cyberize/Rocket_Punch, M))
				ModChoices.Remove("Rocket Punch")
			if(M.StealthSystems)
				ModChoices.Remove("Stealth Systems")

			if(M.CombatCPU)
				ModChoices.Remove("Combat CPU")
			if(M.MeditateModule)
				ModChoices.Remove("Reconstructive Nanobots")
			if(M.StabilizeModule)
				ModChoices.Remove("Internal Life Support")
			if(locate(/obj/Skills/Utility/Internal_Communicator, M))
				ModChoices.Remove("Internal Comms Suite")
			if(!M.isRace(ANDROID) || M.EnergyAssimilators)
				ModChoices.Remove("Energy Assimilators")
			else
				ModChoices.Remove("Punishment Chip")
				ModChoices.Remove("Internal Life Support")

			if(!M.CyberCancel)
				ModChoices.Remove("Failsafe Circuit")

			if(M.HasMilitaryFrame()&&!M.isRace(ANDROID))
				ModChoices.Remove("Ripper Mode")
				ModChoices.Remove("Armstrong Augmentation")
				ModChoices.Remove("Ray Gear")
				ModChoices.Remove("Overdrive")

			if(M.isRace(ANDROID))
				if(M.Maimed||M.HealthCut)
					ModChoices.Add("Repair")

			ModChoice=input(usr, "What modification would you like to install?", "Cybernetic Augmentation") in ModChoices
			if(ModChoice=="Cancel")
				OMsg(usr, "[usr] decides not to tinker.")
				src.Using=0
				return

			switch(ModChoice)
				if("Enhanced Strength")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Strength increases Strength."
				if("Enhanced Force")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Force increases Force."
				if("Enhanced Endurance")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Endurance increases Endurance."
				if("Enhanced Aggression")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Aggression increases Offense."
				if("Enhanced Reflexes")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Reflexes increases Defense."
				if("Enhanced Speed")
					Cost=glob.progress.EconomyCost*2.5
					ModDesc="Enhanced Speed increases Speed."

				if("Internal Comms Suite")
					Cost=glob.progress.EconomyCost*2
					ModDesc="Internal Suite allows the augmented to use internal systems to scan precise power levels and access wireless communications."
				if("Blade Mode")
					Cost=glob.progress.EconomyCost*10
					ModDesc="Blade Mode allows high speed calculations improving accuracy and swiftness of delivered blows!"
				if("Taser Strike")
					Cost=glob.progress.EconomyCost*5
					ModDesc="Taser Strike delivers an electric shock to the opponent to allow for more openings!"
				if("Machine Gun Flurry")
					Cost=glob.progress.EconomyCost*5
					ModDesc="Machine Fun Flurry unleashes a rush of blows once enough momentum has been gathered!"
				if("Rocket Punch")
					Cost=glob.progress.EconomyCost*5
					ModDesc="Rocket Punch fires a mechanized appendage for an explosive assault!"
				if("Stealth Systems")
					Cost=glob.progress.EconomyCost*5
					ModDesc="Stealth Systems allow the augmented to visually disguise themselves when they lower their power!"
				if("Nano Boost")
					Cost=glob.progress.EconomyCost*20
					ModDesc="Nano Boost gives the subject a sudden surge of cybernetic power!"
				if("Combat CPU")
					Cost=glob.progress.EconomyCost*20
					ModDesc="Combat CPU allows the augmented to automatically burn some battery in order to constantly run simulations of the current engagement; bottom line: better evasion."
				if("Reconstructive Nanobots")
					Cost=glob.progress.EconomyCost*25
					ModDesc="Reconstructive Nanobots repair the augmented when they enter a rest cycle with precise efficiency."
				if("Internal Life Support")
					Cost=glob.progress.EconomyCost*10
					ModDesc="Internal Life Support prevent the augmented from perishing to mortal wounds."
				if("Energy Assimilators")
					Cost=glob.progress.EconomyCost*20
					ModDesc="Energy Assimilators are small, orb-like constructs fitted into the palm of a hand meant to consume energy on direct contact with source."


				if("Punishment Chip")
					Cost=glob.progress.EconomyCost*10
					ModDesc="Install a simple electric circuit inside your target's nervous system."
				if("Failsafe Circuit")
					Cost=glob.progress.EconomyCost*25
					ModDesc="Install a failsafe circuit inside your target to allow turning off its power in case of disobedience."
				if("Explosive Implantation")
					Cost=glob.progress.EconomyCost*100
					ModDesc="Install a powerful explosive device inside your target."

				if("Ripper Mode")
					Cost=glob.progress.EconomyCost*300
					ModDesc="Ripper Mode allows the augmented to present a facsimile of sadism to greatly bolster speed and offensive prowess."
				if("Armstrong Augmentation")
					Cost=glob.progress.EconomyCost*300
					ModDesc="Armstrong Augmentation allows the augmented to forge a powerful nanite shell in response to physical trauma; increases strength and endurance while forsaking defense. "
				if("Ray Gear")
					Cost=glob.progress.EconomyCost*300
					ModDesc="Ray Gear provides the augmented with unparalleled firepower and integrates ranged capabilities into their basic combat protocols while sapping their battery."
				if("Infinity Drive")
					Cost=glob.progress.EconomyCost*300
					ModDesc="Infinity Drive allows a fusion-powered augmented to constantly support their overall performance with their nigh-infinite energy outpour."
				if("Overdrive")
					Cost=glob.progress.EconomyCost*300
					ModDesc="Overdrive allows the augmented to overclock every cybernetically enhanced aspect in exchange for battery life."

				if("Repair")
					Cost=glob.progress.EconomyCost/2*(M.Maimed+(M.HealthCut*5))
					ModDesc="Attempts to repair a damaged android."

			if(M.isRace(ANDROID))
				Cost*=2

			ModDesc="[ModDesc]  It costs [Commas(Cost)] to install.  Do you wish to install this module into [M]?"
			Confirm=alert(usr, "[ModDesc]", "Cybernetic Augmentation ([ModChoice])", "No", "Yes")
			if(Confirm=="No")
				OMsg(usr, "[usr] decided to not operate.")
				src.Using=0
				return

			if(ModChoice=="Enhanced Strength"||ModChoice=="Enhanced Endurance"||ModChoice=="Enhanced Speed"||ModChoice=="Enhanced Force"||ModChoice=="Enhanced Aggression"||ModChoice=="Enhanced Reflexes")
				if(M.EnhanceChips>=M.EnhanceChipsMax)
					OMsg(usr, "[usr] attempted to install a performance boosting module into [M], but they already have max installed.")
					src.Using=0
					return

			for(var/obj/Money/Money in usr)
				if(Money.Level<Cost)
					OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but they don't have enough money!!")
					src.Using=0
					return

			//Everything checks out; install the mod
			switch(ModChoice)
				//These all check for enhance chips once again just in case of menu cheese.
				if("Enhanced Strength")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedStrength++
				if("Enhanced Endurance")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedEndurance++
				if("Enhanced Force")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedForce++
				if("Enhanced Speed")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedSpeed++
				if("Enhanced Aggression")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedAggression++
				if("Enhanced Reflexes")
					if(M.EnhanceChips<M.EnhanceChipsMax)
						M.EnhanceChips++
						M.EnhancedReflexes++

				if("Nano Boost")
					if(M.NanoBoost)
						OMsg(usr, "[usr] is a big fan of nanomachines, but [M] has enough already, thanks.")
						src.Using=0
						return
					M.NanoBoost=1
				if("Blade Mode")
					if(M.BladeMode)
						OMsg(usr, "[usr] tried to make [M] go faster but they can already Zandatsu.")
						src.Using=0
						return
					M.BladeMode=1
				if("Taser Strike")
					if(locate(/obj/Skills/Queue/Cyberize/Taser_Strike, M))
						OMsg(usr, "[usr] tried to give [M] the ability to taze you, bro...But they tazed them instead.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Queue/Cyberize/Taser_Strike)
				if("Machine Gun Flurry")
					if(locate(/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry, M))
						OMsg(usr, "[usr] tried to give [M] the rapidfire punchy module...But they already had it.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry)
				if("Rocket Punch")
					if(locate(/obj/Skills/Projectile/Cyberize/Rocket_Punch, M))
						OMsg(usr, "[usr] tried to give [M] the flying punt...But they already had it.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Projectile/Cyberize/Rocket_Punch)
				if("Stealth Systems")
					if(M.StealthSystems)
						OMsg(usr, "[usr] offered [M] some stealth systems...But they couldn't find them...cuz they already have stealth systems.")
						src.Using=0
						return
					M.StealthSystems=1
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Camouflage)
				if("Combat CPU")
					if(M.CombatCPU)
						OMsg(usr, "[usr] is a big fan of nanomachines, but [M] has enough already, thanks.")
						src.Using=0
						return
					M.CombatCPU=1
				if("Reconstructive Nanobots")
					if(M.MeditateModule)
						OMsg(usr, "[usr] tried to regenerate while they regenerated so they could do boss rush mode.")
						src.Using=0
						return
					M.MeditateModule=1
				if("Internal Life Support")
					if(M.StabilizeModule)
						OMsg(usr, "[usr] tried to stabilize while they stabilized so they could never do the die.")
						src.Using=0
						return
					M.StabilizeModule=1
				if("Energy Assimilators")
					if(M.EnergyAssimilators)
						OMsg(usr, "[usr] tried to stuff a energy assimilators into [M] but they already had them installed.")
						src.Using=0
						return
					M.EnergyAssimilators=1
					M.AddSkill(new/obj/Skills/Grapple/Energy_Drain)
				if("Internal Comms Suite")
					if(M.InternalScouter)
						OMsg(usr, "[usr] tried to make [M] become maximum overawareness, but it's not time for Skynet yet.")
						src.Using=0
						return
					M.InternalScouter=1
					M.AddSkill(new/obj/Skills/Utility/Internal_Communicator)

				if("Punishment Chip")
					if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip, M))
						OMsg(usr, "[usr] tried to force an implant inside [M], but they already had one of that type!")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip/A in M)
						A.Password=input("Input activation code.") as text|null
				if("Failsafe Circuit")
					if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip, M))
						OMsg(usr, "[usr] tried to force an implant inside [M], but they already had one of that type!")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip/A in M)
						A.Password=input("Input activation code.") as text|null
				if("Explosive Implantation")
					if(locate(/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive, M))
						OMsg(usr, "[usr] tried to force an implant inside [M], but they already had one of that type!")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive/A in M)
						A.Password=input("Input activation code.") as text|null

				if("Ripper Mode")
					if((M.HasMilitaryFrame()&&!M.isRace(ANDROID))||M.Saga)
						OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but their operating memory is already occupied.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode)
					M.FusionPowered=1
					M.ManaPU=1
				if("Armstrong Augmentation")
					if((M.HasMilitaryFrame()&&!M.isRace(ANDROID))||M.Saga)
						OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but their operating memory is already occupied.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Armstrong_Augmentation)
					M.FusionPowered=1
					M.ManaPU=1
				if("Ray Gear")
					if((M.HasMilitaryFrame()&&!M.isRace(ANDROID))||M.Saga)
						OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but their operating memory is already occupied.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ray_Gear)
					M.FusionPowered=1
					M.ManaPU=1
				if("Overdrive")
					if((M.HasMilitaryFrame()&&!M.isRace(ANDROID))||M.Saga)
						OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but their operating memory is already occupied.")
						src.Using=0
						return
					M.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive)
					M.FusionPowered=1
					M.ManaPU=1
				if("Infinity Drive")
					if((M.HasMilitaryFrame())||M.Saga)
						OMsg(usr, "[usr] tried to install a [ModChoice] into [M]...but their operating memory is already occupied.")
						src.Using=0
						return
					M.InfinityModule=1
					M.FusionPowered=1
					M.ManaPU=1

				if("Repair")
					M.Maimed=0
					M.HealthCut=0
					OMsg(usr, "[usr] repairs [M]!")
				if("Upgrade")
					if(M.Potential>5)
						M.Potential=5
					else
						M.Potential+=5
					OMsg(usr, "[usr] upgrades [M]!")

			//at the end
			if(ModChoice!="Repair"&&ModChoice!="Upgrade")
				OMsg(usr, "[usr] operated on [M], installing a [ModChoice] module!")
			usr.TakeMoney(Cost)
			M.SetCyberCancel()
			src.Using=0


//Saga


	Zodiac_Invocation
		desc="Call for assistance of your Zodiacal guardian."
		verb/Zodiac_Invocation()
			set category="Utility"
			if(!usr.ClothGold)
				usr.PickGoldCloth()
				if(!glob.infConstellations)
					glob.takeLimited("GoldConstellation", usr.ClothGold)
			if(!usr.ZodiacCharges)
				usr<<"You have no charges of Zodiac Invocation left!"
				return
			var/obj/Skills/Buffs/SpecialBuffs/Saint_Cloth/Gold_Cloth/goldCloth
			var/path = "/obj/Skills/Buffs/SpecialBuffs/Saint_Cloth/Gold_Cloth/[usr.ClothGold]_Cloth"
			goldCloth = new path
			usr.AddSkill(goldCloth)
			goldCloth.setRandomTime(usr)
			spawn()LightningBolt(usr,2)
			OMsg(usr, "[usr] summons forth their Zodiac Cloth!")
			usr.ZodiacCharges--
			if(usr.SagaLevel<5)
				usr.HealFatigue(30)
				usr.HealEnergy(30)


	Call_Blade
		Cooldown=10800
		desc="Return your legendary blade to where it belongs."
		verb/Call_Blade()
			set category="Utility"
			if(!usr.BoundLegend)
				return
			if(usr.Dead && !usr.KeepBody)
				usr << "You cannot call blade while dead."
				return
			switch(usr.BoundLegend)
				if("Green Dragon Crescent Blade")
					if(!locate(/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War, usr))
						for(var/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Ryui Jingu Bang")
					var/obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang/found = 0
					for(var/obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang/s in world)
						if(s)
							found = s
							break
					if(found)
						found.Move(usr)
					else
						if(!locate(/obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang, usr))
							new/obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang(usr)

				if("Masamune")
					if(!locate(/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity, usr))
						for(var/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Kusanagi")
					if(!locate(/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith, usr))
						for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Durendal")
					if(!locate(/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope, usr))
						for(var/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Caledfwlch")
					if(!locate(/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory, usr))
						for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Muramasa")
					if(!locate(/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades, usr))
						for(var/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Soul Calibur")
					if(!locate(/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order, usr))
						for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Soul Edge")
					if(!locate(/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos, usr))
						for(var/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Dainsleif")
					if(!locate(/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin, usr))
						for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
				if("Moonlight Greatsword")
					if(!locate(/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_the_Moon, usr))
						for(var/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_the_Moon/S in world)
							if(!S.LockedLegend)
								usr.contents+=S
								break
			OMsg(usr, "[usr] summons forth their legendary blade!")

	Death_Killer
		desc="Kill death."
		verb/Death_Killer()
			set category="Utility"
			if(src.Using)
				src << "You're already killing death."
				return
			src.Using=1
			var/list/valid=list("Cancel")
			var/list/Bodies=list()
			var/list/Souls=list()
			for(var/mob/Body/m in view(usr, 3))
				Bodies.Add(m)
			for(var/mob/Players/m in players)
				if(m.Dead&&m.DeathKilled<1)
					Souls+=m
			for(var/mob/Players/m in Souls)
				for(var/mob/Body/b in Bodies)
					if(b.DeathKillerTargets==m.key)
						valid+=m
				for(var/obj/Items/Enchantment/PhilosopherStone/True/ps in get_step(usr,usr.dir))
					if(ps.SoulIdentity==m.UniqueID)
						valid+=m
				for(m in get_step(usr,usr.dir))
					valid+=m
			if(valid.len <= 1)
				usr << "The bodies present don't belong to any wandering soul..."
				src.Using=0
				return
			var/mob/Choice=input(usr, "You can kill death for these people.", "Death Killer") in valid
			if(Choice=="Cancel")
				src.Using=0
				return
			Choice.Revive()
			Choice.DeathKilled=1
			OMsg(usr, "[usr] kills death's effects on [Choice], reviving their soul!")
			for(var/obj/Items/Enchantment/PhilosopherStone/True/ps in get_step(usr,usr.dir))
				if(ps)
					if(ps.SoulIdentity==Choice?:UniqueID)
						Choice.loc=ps.loc
						del ps
			for(var/mob/Body/b in view(usr, 3))
				if(b)
					if(b.DeathKillerTargets==Choice.key)
						for(var/obj/Items/I in b)
							if(I.suffix=="*Equipped*")
								spawn(5)
									I.suffix=null
							I.loc = Choice
						Choice.loc=b.loc
						if(!b.TrulyDead)
							Choice.DeathKilled=0
							OMsg(usr, "... but it feels like it was just an illusion anyway.")
						del b
			src.Using=0


	Necromancy
		desc="Commune with the dead."
		var/PenaltyCD//holds a realtime
		verb/Bind_Soul()
			set category="Utility"
			if(src.Using)
				return
			if(!usr.Move_Requirements()||usr.KO)
				return
			src.Using=1
			var/list/mob/Players/Options=list("Cancel")
			for(var/mob/Players/P in players)
				if(P.Dead&&!P.SummonContract&&!locate(/obj/Skills/Soul_Contract, P)&&P.z==glob.DEATH_LOCATION[3]&&P!=usr)
					Options.Add(P)
			if(Options.len<1)
				usr << "There are no available souls to invoke!"
				src.Using=0
				return
			//var/Cost=0.75*global.EconomyMana//75 capacity
			var/Cost=0.25*glob.progress.EconomyMana

			if(!usr.HasManaCapacity(Cost))
				usr << "You don't have enough capacity to summon a spirit!  It takes [Commas(Cost)] capacity."
				src.Using=0
				return
			var/mob/Players/Choice=input(usr, "What soul do you want to bind?  They won't necessarily be friendly!", "Bind Soul") in Options
			if(Choice=="Cancel")
				src.Using=0
				return

			if(Choice.z != src.z)
				switch(input(usr, "Bind this soul will cost [Cost] mana. Are you sure you want to do it?", "Bind Soul") in list("Yes","No"))
					if("No")
						src.Using=0
						return
			var/FailChance=20*((Choice.Power*Choice.EnergyUniqueness)/(usr.Power*usr.EnergyUniqueness))/(usr.SummoningMagicUnlocked+1)

			usr.TakeManaCapacity(Cost)
			if(prob(FailChance)&&!usr.passive_handler.Get("SpiritPower"))
				OMsg(usr, "[usr] fails their ritual!")
				src.Using=0
				return
			else
				Choice.PrevX=Choice.x
				Choice.PrevY=Choice.y
				Choice.PrevZ=Choice.z
				Choice.loc=locate(usr.x, usr.y-1, usr.z)
				OMsg(usr, "[usr] summons forth a dead soul!")
				spawn()
					LightningBolt(Choice,3)
				Choice.SummonReturnTimer=RawDays(1)
				Choice.Password=usr.ckey
				if(!Choice.SummonContract)
					Choice.SummonContract=1
				src.Using=0
				return
		verb/Raise_Dead()
			set category="Utility"
			if(src.Using)
				src << "You're already raising the dead."
				return
			if(!usr.Move_Requirements()||usr.KO)
				return
			src.Using=1
			var/list/valid=list("Cancel")
			var/list/Bodies=list()
			var/list/Souls=list()
			for(var/mob/Body/m in view(usr, 3))
				if(m.TrulyDead)
					Bodies+=m
			for(var/mob/m in players)
				if(m.Dead&&m!=usr)
					Souls+=m
			for(var/mob/m in Souls)
				for(var/mob/Body/b in Bodies)
					if(b.DeathKillerTargets==m.key)
						valid+=m
			if(valid.len <= 1)
				usr << "The bodies present don't belong to any wandering soul..."
				src.Using=0
				return
			var/mob/Choice=input(usr, "You can raise these people as zombies.", "Necromancy") in valid
			if(Choice=="Cancel")
				src.Using=0
				return
			Choice.Dead=0
			for(var/mob/Body/b in view(usr, 3))
				if(b.DeathKillerTargets==Choice.key)
					b.Unholy_Alive(Choice)
			Choice.Password=usr.ckey
			OMsg(usr, "[usr] raises [Choice] as a loyal zombie!")
			src.Using=0
		verb/Drop_Dead()
			set category="Utility"
			if(src.Using)
				src << "You're already punishing your servants."
				return
			if(!usr.Move_Requirements()||usr.KO)
				return
			src.Using=1
			var/list/Zombies=list("Cancel")
			for(var/mob/m in view(usr, 10))
				if((m.Secret=="Zombie"&&!m.KO))
					Zombies+=m
				if(m.Dead)
					Zombies+=m
			if(Zombies.len <= 1)
				usr << "There are no undead to punish."
				src.Using=0
				return
			var/mob/Choice=input(usr, "You can punish these undead.", "Necromancy") in Zombies
			if(Choice=="Cancel")
				src.Using=0
				return
			OMsg(usr, "[usr] focuses their necrotic energy to punish [Choice]!")
			sleep(10)
			if(Choice.Secret=="Zombie"&&Choice.Password==usr.ckey)
				if(!Choice.HasEnlightenment())
					Choice.Unconscious(usr)
					OMsg(usr, "[usr] punishes [Choice] with further degeneration!")
				else
					OMsg(usr, "[usr] is unable to punish [Choice]!")
			else if(Choice.Dead&&Choice.Password==usr.ckey)
				if(!Choice.HasEnlightenment())
					Choice.SummonReturnTimer=1
					OMsg(usr, "[usr] severs the [Choice]'s binding with the physical world!")
				else
					OMsg(usr, "[usr] is unable to punish [Choice]!")
			else
				if(!Choice.HasEnlightenment())
					if(world.realtime<src.PenaltyCD)
						usr << "It's too soon to use this!  ([round(src.PenaltyCD-world.realtime/Hour(1), 0.1)] hours)"
						src.Using=0
						return
					Choice.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Disturbed)
					OMsg(usr, "[usr] disturbs the necrotic energies animating [Choice]!")
					src.PenaltyCD=world.realtime+Hour(1)
				else
					OMsg(usr, "[usr] is unable to punish [Choice]!")
			src.Using=0