

//Maybe sparring AI responds to cooldowns whe na player is facing them.
mob/var/tmp/list/ai_followers = list()

obj/Skills/Companion
	Mastery=0
	var

		//Appearance Variables
		companion_icon = 'Makyo1.dmi'
		companion_mimic = null //Set as 1 to copy a players icon/overlays. Set as a color or matrix to copy and set the color/mobcolor of these boiz
		companion_name = "???"
		companion_overlays=list()
		list/companion_unique_overlays=list()

		companion_bpm = -1
		ai_count = 1
		companion_strmod = -1
		companion_endmod = -1
		companion_formod = -1
		companion_offmod = -1
		companion_defmod = -1
		companion_spdmod = -1
		companion_recovmod = -1
		companion_regenmod = -1
		companion_angermax= -1
		companion_angerpoint= -1
		companion_potential = -1
		companion_techmastery = 20
		companion_skill_aggression = 1
		companion_ko_death = 1

		companion_team_fire = 1
		//Common Passives
		companion_intimidation = 1
		companion_godspeed = 0
		companion_sweeping_strike = 0
		companion_evil = 0
		companion_good = 0


		unrestricted_controls = 1 //This will be phased out soon because I'm going to setup an AI controller system.

		list/companion_techniques = list()
		tmp/list/active_ai = list()
		cooldown
		last_use

		//Toggles
		companion_focus_target //Companion will remain targeting whoever the players has targeted.
	verb
		Companion_Summon()
			set src in usr
			set category = "Companion"
			if(Using)
				return
			Using=1
			var has_f_out
			for(var/mob/Player/AI/a in active_ai)
				animate(a, alpha=0, time=10)
				usr.ai_followers-=a
				active_ai-=a
				spawn(10)
					del(a)
				has_f_out=1
			if(has_f_out)
				Using=0
				return

			if(!(world.realtime >= last_use + cooldown))
				usr << "You cannot summon any companions right now, it is still on cooldown. ([(world.realtime - last_use)/10] seconds)"
				return

			for(var/x = 1 to ai_count)
				var/mob/Player/AI/a = new
				ticking_ai.Remove(a)
				a.alpha=0
				a.loc = locate(usr.x,usr.y,usr.z)
				animate(a, alpha=255, time=10)
				a.ai_owner = usr
				a.ai_follow=1
				a.ai_hostility=0
				a.name = companion_name

				if(!companion_mimic)
					if(istype(companion_icon, /list))
						var/icon/i
						if(x <= length(companion_icon))
							i = companion_icon[x]
						else
							i = pick(companion_icon)
						if(istext(i))
							a.name = i
							i = companion_icon[i]
						a.icon = i
					else
						a.icon = companion_icon
					for(var/index in companion_overlays)
						a.overlays += companion_overlays[index]
					if(companion_unique_overlays.len>0)
						a.overlays += pick(companion_unique_overlays)
				else
					a.icon = usr.icon
					a.overlays = usr.overlays
					if(!isnum(companion_mimic))
						a.color = companion_mimic
						a.MobColor = companion_mimic
				a.ai_focus_owner_target = companion_focus_target
				a.StrMod = (companion_strmod == -1) ? usr.StrMod : companion_strmod
				a.ForMod = (companion_formod == -1) ? usr.ForMod : companion_formod
				a.EndMod = (companion_endmod == -1) ? usr.EndMod : companion_endmod
				a.SpdMod = (companion_spdmod == -1) ? usr.SpdMod : companion_spdmod
				a.OffMod = (companion_offmod == -1) ? usr.OffMod : companion_offmod
				a.DefMod = (companion_defmod == -1) ? usr.DefMod : companion_defmod
				a.RecovMod = (companion_recovmod == -1) ? usr.RecovMod : companion_recovmod
				a.AngerMax = (companion_angermax == -1) ? usr.AngerMax : companion_angermax
				a.AngerPoint = (companion_angerpoint == -1) ? usr.AngerPoint : companion_angerpoint
				a.Intimidation = (companion_intimidation == -1) ? usr.Intimidation : companion_intimidation
				a.ai_spammer = companion_skill_aggression
				a.ko_death = companion_ko_death
				a.Timeless = 1
				a.ai_team_fire=companion_team_fire
				a.ai_focus_owner_target = companion_focus_target
				a.potential_power_mult = companion_bpm == -1 ? ((usr.potential_power_mult*usr.RPPower*usr.PowerBoost) * 0.5*(1+(src.Mastery/4))) : companion_bpm
				a.Potential = (companion_potential == -1) ? (usr.Potential * 0.5*(1+(src.Mastery/4))) : companion_potential
				usr.ai_followers +=a
				a.ai_alliances = list()
				a.ai_alliances += "[usr.ckey]"
				active_ai+=a
				for(var/index in companion_techniques)
					var/path=text2path("[index]")
					var/obj/Skills/o =new path
					if(!locate(o, a))
						a.contents+=o
				a.aiGain()
			last_use = world.time
			Using=0

		Companion_Attack()
			set src in usr
			set category = "Companion"
			if(Using) return
			if(!usr.Target)
				usr << "You need a target to use this."
				return
			for(var/mob/Player/AI/a in usr.ai_followers)
				if(usr.Target.ai_followers.len)
					a.SetTarget(pick(usr.Target.ai_followers))
				else
					a.SetTarget(usr.Target)
				a.Chase()
				usr << "You order [a] to attack [usr.Target]!"

		Companion_Stop()
			set src in usr
			set category = "Companion"
			if(Using) return
			for(var/mob/Player/AI/a in usr.ai_followers)
				a.RemoveTarget()
				a.Idle()
				usr << "You order [a] stop fighting!"
		Companion_Follow()
			set src in usr
			set category = "Companion"
			if(Using) return
			for(var/mob/Player/AI/a in usr.ai_followers)
				a.ai_follow = !a.ai_follow
				a.Idle()
				usr << "You order [a.ai_follow ? "follow you!" : "hold position!"]"

		Companion_Focus_Target()
			set src in usr
			set category = "Companion"
			companion_focus_target = !companion_focus_target
			for(var/mob/Player/AI/a in usr.ai_followers)
				a.ai_focus_owner_target = companion_focus_target
			usr << "You order [companion_focus_target ? "focus same target!" : "attack whoever!"]"
		CustomizeCompanion()
			set category="Companion"
			set name = "Customize: Companion"
			switch(input("Customize") in list("Set Companion Icon","Set Companion Name","Cancel"))
				if("Set Companion Name")
					companion_name = null
					while(!companion_name)
						companion_name = input("Name?") as text
				if("Set Companion Icon")
					switch(input("Default Icon set or Custom?") in list("Default", "Custom"))
						if("Default")
							switch(input("Reset current companion icon?") in list("Yes","No"))
								if("Yes") companion_icon = null
							for()
								var/option
								if(!companion_icon) option = "Add"
								else option = input("Add another?") in list("Add","Cancel")
								switch(option)
									if("Add")
										var/icon/i = input("Which?") in ai_icon_database
										i = ai_icon_database[i]
										if(!companion_icon)
											companion_icon = i
										else
											if(IsList(companion_icon))
												companion_icon += i
											else
												var/save = companion_icon
												companion_icon = list()
												companion_icon += save
												companion_icon += i
								break
						if("Custom")
							switch(input("Reset current companion icon?") in list("Yes","No"))
								if("Yes") companion_icon = null
							for()
								var/option
								if(!companion_icon) option = "Add"
								else option = input("Add another?") in list("Add","Cancel")
								switch(option)
									if("Add")
										var/icon/i = input("Which?") as icon
										ai_icon_database[i]=i
										if(!companion_icon)
											companion_icon = i
										else
											if(IsList(companion_icon))
												companion_icon += i
											else
												var/save = companion_icon
												companion_icon = list()
												companion_icon += save
												companion_icon += i
								break








	AIController
		//Restricted verbs
		verb
			CompanionAggressionState()
				set src in usr
				set category = "Companion"
				set name = "Companion Aggression State"
				if(!usr.Admin && !unrestricted_controls) return
				var/hostility = 0
				for(var/mob/Player/AI/a in usr.ai_followers)
					switch(a.ai_hostility)
						if(0) a.ai_hostility = 1
						if(1) a.ai_hostility = 2
						if(2) a.ai_hostility = 0
					hostility = a.ai_hostility

				switch(hostility)
					if(0) usr << "Your followers will not respond to attacks."
					if(1) usr << "Your followers will respond to attacks."
					if(2) usr << "Your followers will attack enemy who nears them."
			CompanionRelease()
				set src in usr
				set category = "Companion"
				set name = "Companion Release"
				if(!usr.Admin && !unrestricted_controls) return


				switch(input("Are you should you would like to release all your followers from your control?") in list("Yes", "No"))
					if("No") return

				var force_hostility
				switch(input("Would you like to force AI hostility?") in list("Yes", "No"))
					if("Yes") force_hostility = 1
					if("No") force_hostility = 0
				switch(input("Would you like to force AIs to guard you position?") in list("Yes", "No"))
					if("Yes") CompanionGuardPosition()
				for(var/mob/Player/AI/a in usr.ai_followers)
					a.ai_owner = null
					var/list/targets = view(a.ai_vision, a)
					if(force_hostility)
						a.ai_hostility =2
						while(targets.len)
							var/target = pick(targets)
							if(!istype(target, /mob))
								targets -= target
							else if(target && !a.AllianceCheck(target))
								a.SetTarget(target)
								a.ai_state = "combat"
								break
							else
								targets-=target
				usr.ai_followers = list()
				active_ai=list()
				usr << "You have released all of your followers."

			CompanionGuardPosition()
				set src in usr
				set category = "Companion"
				set name = "Companion Guard Position"
				if(!usr.Admin && !unrestricted_controls) return

				var holding = 0
				for(var/mob/Player/AI/a in usr.ai_followers)
					if(a.hold_position)
						a.ai_follow = 1
						a.hold_position = null
						holding = 0
						a.ai_wander = 1
					else
						a.ai_follow = 0
						a.ai_wander = 0
						a.hold_position = locate(usr.x, usr.y, usr.z)
						holding = 1

				if(holding)
					holding = input("Scope?") as num
					if(holding >= 10) holding = 10
					if(holding < 1) holding = 1
					for(var/mob/Player/AI/a in usr.ai_followers) a.max_hold_distance = rand(1, holding)
					usr << "Your followers will hold this position."
				else usr << "Your AIs will return to following you."
			AddCompanionAlliance()
				set src in usr
				set category = "Companion"
				set name = "Add Companion Alliance"

				var/new_alliance = input("Who would you like your companion to ally with?") as text | null
				if(new_alliance)
					for(var/mob/Player/AI/a in usr.ai_followers) a.ai_alliances |= new_alliance
					usr << "You have added [new_alliance] to your companions alliances."
			RemoveCompanionAlliance()
				set src in usr
				set category = "Companion"
				set name = "Remove Companion Alliance"
				var/list/options = list()
				for(var/mob/Player/AI/a in usr.ai_followers)
					options = a.ai_alliances
					break
				var/remove_alliance = input("Which alliance would you like to remove?") in options | null
				if(remove_alliance)
					for(var/mob/Player/AI/a in usr.ai_followers) a.ai_alliances -= remove_alliance
					usr << "You have removed [remove_alliance] from your followers alliances."


obj/Skills/Companion/Pet
	name = "Pet"
	companion_icon=null
	companion_name = "Pet"
	Mastery=1

	var
		text_color = rgb(150,150,150)

	CustomizeCompanion()
		set category="Companion"
		set name = "Customize: Companion"

		var/list/options = list("Set Pet Icon","Set Pet Name","Set IC Color")

		options += "Cancel"
		switch(input("What would you like to do?") in options)
			if("Set Pet Icon")
				var/icon/i = input("What would you like to set your companion's icon to?") as icon|null
				if(i)
					companion_icon = i
					usr << "Companion Icon Set"
			if("Set Pet Name")
				var new_name = input("What would you like to set your companion's name to?","Companion Name",companion_name) as text|null
				if(new_name)
					companion_name = new_name

			if("Set IC Color")
				var/new_color = input("What color?") as color | null
				if(new_color)
					text_color = new_color
					usr << "You've set your Companion's text color to [text_color]"



	verb/Companion_Say(var/message as text)
		set category = "Companion"
		set name = "Say Pet"
		if(message)
			var replace_name
			if(findtext(message, "/", 1,2))
				replace_name = copytext(message, 2, findtext(message, " "))
				message = replacetext(message, "/[replace_name]", "")
			for(var/mob/Player/AI/Pet/a in usr.ai_followers)
				var prev_name = a.name
				if(replace_name) a.name = replace_name
				a.AISay(message)
				a.name = prev_name
				return

	verb/Companion_Roleplay()
		set category = "Companion"
		set name = "Emote Pet"
		for(var/mob/Player/AI/Pet/a in usr.ai_followers)
			var/image/em=new('Emoting.dmi')
			em.appearance_flags=66
			em.layer=EFFECTS_LAYER
			a.overlays+=em
			var/T=input("Emotes here!")as message|null
			if(T==null)
				a.overlays-=em
				return
			for(var/mob/Players/E in (hearers(15,a) |  hearers(15,usr)))
				E << output("<font color=[text_color]>*[a.name]<font color=yellow>[E.Controlz(usr)] [html_decode(T)]*", "output")
				E << output("<font color=[text_color]>*[a.name]<font color=yellow>[E.Controlz(usr)] [html_decode(T)]*", "icchat")
				if(E.BeingObserved.len>0)
					for(var/mob/m in E.BeingObserved)
						m<<output("<b>(OBSERVE)</b><font color=[text_color]>*[a][E.Controlz(usr)]  [html_decode(T)]*", "icchat")
						m<<output("<b>(OBSERVE)</b><font color=[text_color]>*[a][E.Controlz(usr)]  [html_decode(T)]*", "output")
				if(E==usr)
					spawn()Log(E.ChatLog(),"<font color=#CC3300>*[a]([usr.key]) [html_decode(T)]*")
//					spawn()TempLog(E.ChatLog(),"<font color=#CC3300>*[a]([usr.key]) [html_decode(T)]*")
				else
					Log(E.ChatLog(),"<font color=red>*[usr]([usr.key]) [html_decode(T)]*")
				for(var/obj/Items/Enchantment/Arcane_Mask/EyeCheck in E)
					if(EyeCheck.suffix)
						for(var/mob/Players/OrbCheck in world)
							for(var/obj/Items/Enchantment/ArcanicOrb/FinalCheck in OrbCheck)
								if(EyeCheck.LinkTag in FinalCheck.LinkedMasks)
									if(FinalCheck.Active)
										OrbCheck << output("[FinalCheck](viewing [E]):<font color=[text_color]>*[a.name]<font color=yellow> [html_decode(T)]*", "output")
										OrbCheck << output("[FinalCheck](viewing [E]):<font color=[text_color]>*[a.name]<font color=yellow> [html_decode(T)]*", "icchat") //Outputs to the Orb owner the emote.
			a.Say_Spark()
			if(a.AFKTimer==0)
				a.overlays-=usr.AFKIcon

			a.overlays-=em
	Companion_Summon()
		set src in usr
		if(Using) return
		Using=1

		var has_f_out
		for(var/mob/Player/AI/Pet/a in usr.ai_followers)
			animate(a, alpha=0, time=10)
			usr.ai_followers-=a
			spawn(10)
				del(a)
			has_f_out=1
		if(has_f_out)
			Using=0
			return

		if(!companion_icon) companion_icon = pick('Icons/NPCS/Arcane/SpriteB.dmi','Icons/NPCS/Arcane/SpriteC.dmi','Icons/NPCS/Arcane/SpriteG.dmi','Icons/NPCS/Arcane/SpriteR.dmi','Icons/NPCS/Arcane/SpriteY.dmi')
		if(!companion_name) companion_name = "Pet"

		for(var/x = 1 to ai_count)
			var/mob/Player/AI/Pet/a = new
			ticking_ai.Remove(a)
			companion_ais += a
			a.alpha=0
			a.loc = locate(usr.x,usr.y,usr.z)
			animate(a, alpha=255, time=10)
			a.ai_owner = usr
			a.ai_follow=1
			a.ai_hostility=0
			a.icon = companion_icon
			a.name = companion_name

			a.StrMod = 1
			a.ForMod = 1
			a.EndMod = 1
			a.SpdMod = 5
			a.OffMod = 1
			a.DefMod = 1
			a.RecovMod = 1
			a.Intimidation = 1
			a.Timeless = 1
			a.Potential = usr.Potential
			a.Text_Color = text_color
			usr.ai_followers +=a
			a.ai_alliances = list()
			a.ai_alliances += usr.ckey
			a.density = 0


		Using=0



mob/Player/AI/Pet //Pets get their own subtype because we strip away a lot of their functionality. There is a whole different system if you want them to fight.

	var/step_no = 0
	var/prev_location
	var/owner_prev_loc


	Update()
		set waitfor=0
		if(!ai_owner)
			EndLife(0)
			return
		ai_state = "Idle"
		Health=100
		switch(ai_state)
			if("Idle")
				//If the pet is told to hold position.
				if(return_position || (hold_position && get_dist(src, hold_position <= max_hold_distance)))
					if(hold_position) return_position = null

					if(!(next_move - world.time >= world.tick_lag / 10))

						ai_prev_position = loc
						step_to(src, (hold_position ? hold_position : return_position), max_hold_distance)
						var delay = MovementSpeed()
						next_move = world.time + delay
						glide_size = 32 / delay * world.tick_lag
						if(return_position && get_dist(src, return_position) <=3)
							return return_position = null
				else
					//Otherwise, stay with the player owner.
					ai_trapped_check = 0
					if(ai_follow && ai_owner && ai_owner.icon_state != "Meditate")
						if(icon_state == "Meditate")
							icon_state = ""
						if(!ai_owner)
							EndLife(0)
							return

						if(!(next_move - world.time >= world.tick_lag / 10))
							src.density=0
							if(ai_owner.z != src.z)
								loc = locate(ai_owner.x, ai_owner.y,ai_owner.z)
							var delay = ai_owner.MovementSpeed()/1.5
							next_move = world.time + delay
							glide_size = 32 / delay * world.tick_lag
							if(get_dist(src, src.ai_owner)>=10)
								step_to(src, src.ai_owner, 2)
								next_move = world.time+2
							step_to(src, src.ai_owner, 1)
							if(loc == ai_owner.loc) step_away(src, src.ai_owner)
							if(get_dist(src, ai_owner) <= 1) dir = ai_owner.dir

					else if(Health != 100 || (ai_owner && ai_owner.icon_state =="Meditate"))
						icon_state = "Meditate"
						if(ai_stall == 0)
							ai_stall = 10

			if("combat")
				ai_state = "Idle"
			if("wander")
				ai_state = "Idle"


		ai_state = "Idle"

	AIGain()
		set waitfor=0
		density=0
		Health = 100
		Energy = 100
		ManaAmount = 100
		TotalInjury = 0
		TotalInjury = 0
		density=0
		if(!ai_owner)
			EndLife()
			return
		else if(ai_owner.PureRPMode)
			return

		if(src.KO&&src.icon_state!="KO")
			src.icon_state="KO"

		if(world.time >= last_powercheck+9999)
			AIAvailablePower()

		if(src.KOTimer)
			src.Conscious()
			src.KOTimer=0



	AIAvailablePower()
		set waitfor=0
		usr = src
		Power = ai_owner.Power

