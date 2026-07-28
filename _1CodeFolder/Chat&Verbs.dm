/*mob/Players/verb
	Self_Potential_Boost(var/val as num|null)
		set category="Test Server"
		set name="Self Potential Boost"
		if(val&&usr)
			usr.Potential+=val
			usr.PotentialCap+=val
			Log("Admin", "[ExtractInfo(src)] boosted [ExtractInfo(usr)]'s potential by [val].")
			usr << "You feel yourself grow more experienced!"
	Give_Self_Money(var/num as num)
		set category="Test Server"
		set name="Give Money"
		var/Highest=glob.progress.EconomyMult
		if(usr.EconomyMult>Highest)
			Highest=usr.EconomyMult
		usr.GiveMoney(num*Highest)
		Log("Admin","[ExtractInfo(usr)] increased [usr]'s money by [Commas(num)] (x[Highest] economy mult).")
	Self_RPP_Set()
		set category="Test Server"

		var/EMult=glob.progress.RPPBaseMult
		EMult*=usr.GetRPPMult()

		var/OldRPP=usr.RPPSpent+usr.GetRPPSpendable()
		var/NewRPP=input(usr,"Set the value that [usr]'s RPP should be at.  They currently have [Commas(usr.GetRPPSpendable())] with [Commas(usr.RPPSpent)] RPP spent for [Commas(OldRPP)] total. (x[EMult] RPP Mult)") as num|null
		NewRPP*=EMult

		NewRPP-=usr.RPPSpent
		if(NewRPP>=0)
			usr.RPPSpendable=NewRPP
			Log("Admin","[ExtractInfo(usr)] set [ExtractInfo(usr)]'s total RPP (Spent and Unused) from [Commas(OldRPP)] to [Commas(NewRPP)]. (RPP mult of x[EMult])")*/
mob
	proc/MultReset()
		if(!(world.time > src.verb_delay))
			return FALSE

		is_dashing = 0
		if(src.isRace(BEASTKIN) && src.race?:Racial == "Feather Knife")
			src.passive_handler.passives["Extra Secret Knives"] = "Feathers"
		if(src.isRace(BEASTKIN) && src.race?:Racial == "Fox Fire")
			src.passive_handler.passives["Heavy Strike"] = "Fox Fire"
		if(src.isRace(BEASTKIN) && src.race?:Racial == "Monkey King")
			var/obj/Skills/Buffs/s = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Never_Fall/)
			if(!s.Using)
				s.Trigger(src, TRUE)

		if(src.isRace(BEASTKIN) && src.race?:Racial == "Heart of The Beastkin")
			src.passive_handler.Set("Grit", 1)

		src.verb_delay=world.time+1
		for(var/b in src.SlotlessBuffs)
			var/obj/Skills/Buffs/x = src.SlotlessBuffs[b]
			if(x==null)
				src.SlotlessBuffs.Remove(null)
			if(x)
				if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament))
					x:Trigger(src)
				if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation))
					x:Trigger(src)
		if(src.Power_Multiplier==1&&src.StrMultTotal==1&&src.EndMultTotal==1&&src.SpdMultTotal==1&&src.ForMultTotal==1&&src.OffMultTotal==1&&src.DefMultTotal==1&&src.RecovMultTotal==1)
			return FALSE
		if(src.StanceBuff||src.StyleBuff||src.ActiveBuff||src.SpecialBuff||src.SlotlessBuffs.len>0)
			return FALSE
		if(src.transActive)
			return FALSE
		src<<"Reseting stat and power multipliers."
		src.Splits=new/list()
		src.Power_Multiplier=1
		src.StrMultTotal=1
		src.EndMultTotal=1
		src.SpdMultTotal=1
		src.ForMultTotal=1
		src.OffMultTotal=1
		src.DefMultTotal=1
		src.RecovMultTotal=1
		sleep(20)
		src<<"Stats and power successfully reset to normal."
		return TRUE

atom/proc/Examined(mob/user)
mob/Players/var/tmp/current_party_target_index = 1
mob/Players/verb
	Party_Target_Cycle()
		set category = "Party"
		if(!src.party)
			src << "You don't have a party to cycle target on!"
			return
		var/list/others = src.party.members - src
		if(!others.len)
			src << "You have no party members to target."
			return
		current_party_target_index += 1
		if(current_party_target_index > others.len)
			current_party_target_index = 1
		usr.SetTarget(others[current_party_target_index])
		usr << "You target [usr.Target]."

	Signature_Check()
		set category="Other"
		set hidden = 1
		src.SignatureCheck=!src.SignatureCheck
		if(src.SignatureCheck)
			src<<"You have <font color='green'>ENABLED</font color> signature check."
			src.SignatureSelecting=1
			src.PotentialSkillCheck()
			src.SignatureSelecting=0
		else src<<"You have <font color='red'>DISABLED</font color> signature check."

	WatchCombat()
		set name = "Watch"
		set category = "Other"
		set hidden = 1
		if(!(world.time > usr.verb_delay+4)) return
		usr.verb_delay=world.time+1

		if(GfxClientEyeIsMob(usr.client, usr)) usr.Observing=0

		var/mob/m

		if(src.Observing==4)
			usr << "You stop watching [usr.client.eye]."
			Observify(usr,usr)
			Observing=0
			return
		if(usr.Target)
			m = usr.Target
			if(!m.AllowObservers)
				usr << "You cannot view them."
				return
			if(m.z != usr.z)
				usr << "You cannot view people from other dimensions."
				return
		if(!m)
			var/list/options = list()
			for(var/mob/a in view(15))
				if(a.AllowObservers) options += a
			if(!options.len) return
			options += "Cancel"

			m = input("Who would you like to observe in combat?") in options
		if(ismob(m))
			if(!m.AllowObservers)
				usr << "[m] does not have combat watching enabled."
				return
			Observify(usr, m)
			usr.Observing=4
			usr << "You're now observing [m] in battle!"

	ToggleCombatWatchers()
		set name = "Toggle Combat Watchers"
		set category = "Other"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1

		AllowObservers = !AllowObservers

		if(AllowObservers)
			usr << "People may now watch you in combat."
			viewers(usr) << "[usr] has enabled combat observing!"
			winshow(src, "WatchersLabel",1)
		else
			usr << "People can no longer watch you in combat."
			for(var/mob/m in usr.BeingObserved)
				if(m.Observing==4)
					Observify(m,m)
					m << "[usr] has disabled your ability to watch them fight!"
			winshow(src, "WatchersLabel",0)

	Loot()
		set category=null
		set src in range(1, usr)
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(!src.KO && !istype(src, /mob/Body))
			usr << "You can only use this on unconscious opponents."
			return
		usr.Grid("Loot", Lootee=src)
		OMsg(usr, "[usr] begins to rifle through [src]'s belongings...")
	Examine(var/atom/A as mob|obj in view(15, usr))
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(istype(A,/obj))
			if(istype(A,/obj/Items))
				if(A:UpdatesDescription)
					A:Update_Description()
			if(A.desc)
				src<<A.desc
		else if(ismob(A))
			usr<<"This is: [A]"

			var/mob/person = A
			if(client.getPref("seePronouns"))
				usr<<person.information.getInformation(A, TRUE)
			else
				usr<<person.information.getInformation(A, FALSE)
			var/profileHTML = "<html>"
			if(A:transActive())
				profileHTML += person.ReturnProfile(person.transActive())
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form, person.contents))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/SF in person.contents)
					if(SF.SlotlessOn)
						profileHTML = person.ReturnProfile(1)
			if(profileHTML == "<html>")
				profileHTML += person.Profile

			profileHTML += "</html>"

			usr << browse(profileHTML, "window=[A];size=900x650")

			if(A:GimmickDesc!="")
				usr << browse(A:GimmickDesc, "window=Gimmick;size=325x325")

		A.Examined(src)

	Rename(var/atom/A as mob|obj in view(usr,5))
		set src=usr.client

		if(A.preventRename)
			usr << "You cannot rename this."
			return
		var/blah=input("") as text
		if(istype(A,/mob))
			if(A!=usr)
				usr<<"You cannot rename other people!"
				return
		if(blah&&blah!=""&&blah!=" ")
			A.name=copytext(blah,1,30)
			if(isplayer(A))
				glob.IDs[A:UniqueID] = "[A.name]"

	SaveVerb()
		set hidden=1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.Savable)
			if(!usr.SaveDelay)
				usr.SaveDelay=1
				usr<<"<b>Saving and backing up character...</b>"
				usr.client.SaveChar()
				usr.client.BackupSaveChar()
				usr<<"<b>Character saved! You can save again in 5 minutes!</b>"
				spawn(3000)usr.SaveDelay=null


	AFKToggle()
		set category="Other"
		set hidden = 1
		set name="AFK Toggle"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.AFKTimer>0)
			usr.AFKTimer=1
		else if(usr.AFKTimer==0)
			usr.AFKTimer=usr.AFKTimeLimit
			usr.overlays-=usr.AFKIcon
	AFKIcon()
		set category="Other"
		set hidden = 1
		set name="AFK Icon"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.AFKIcon!='afk.dmi')
			usr.AFKIcon='afk.dmi'
			usr<<"AFK icon reverted to default."
		else if(usr.AFKIcon=='afk.dmi')
			var/Z=input(usr,"Choose an icon for your AFK icon!","ChangeIcon")as icon|null
			if(Z==null)
				return
			if((length(Z) > 50000))
				usr <<"This file exceeds the limit of 50KB. It cannot be used."
				return
			usr.AFKIcon=Z
	AFKLimit()
		set category="Other"
		set hidden = 1
		set name="AFK Time Limit"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.AFKTimeLimit=input(usr,"Enter a time limit in seconds before you'll auto AFK. Minimum of 1000, maximum of 75000.","Timey wimey")as num
		if(usr.AFKTimeLimit<1000)
			usr.AFKTimeLimit=1000
		if(usr.AFKTimeLimit>75000)
			usr.AFKTimeLimit=75000
	Custom_Appearance_Skills()
		set category="Other"
		set hidden = 1
		set name="Customize: Skills"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/list/obj/Skills/Choices=list("Cancel")
		for(var/obj/Skills/Power_Control/b in src)
			Choices.Add(b)
		for(var/obj/Skills/Buffs/b in src)
			if(istype(b, /obj/Skills/Buffs/NuStyle))
				continue
			if(istype(b, /obj/Skills/Buffs/Stances))
				continue
			if(istype(b, /obj/Skills/Buffs/Styles))
				continue
			if(length(b.possible_skills) > 1)
				for(var/obj/Skills/Buffs/a in b.possible_skills)
					Choices.Add(a)
			Choices.Add(b)
		for(var/obj/Skills/Queue/b in src)
			Choices.Add(b)
		for(var/obj/Skills/Projectile/b in src)
			Choices.Add(b)
		for(var/obj/Skills/AutoHit/b in src)
			Choices.Add(b)
		var/obj/Skills/S=input(src, "What skill are you modifying?", "Customize Skill") in Choices
		if(S=="Cancel")
			return
		var/Mode
		var/list/PCOptions=list("Icon")
		var/list/BuffOptions=list("Active Message", "Off Message", "IconLock", "AuraLock", "HairLock", "TopOverlayLock", "TargetOverlay" )
		var/list/QueueOptions=list("Charge Message", "Miss Message", "Hit Message", "Icon")
		var/list/ProjectileOptions=list("Charge Message", "Fire Message", "Icon")
		var/list/AutohitOptions=list("Charge Message", "Fire Message", "Icon")
		if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Aria_Chant))
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in list("Aria Lines")
		else if(istype(S,/obj/Skills/Power_Control))
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in PCOptions
		else if(istype(S,/obj/Skills/Buffs))
			if(S:NameFake)
				BuffOptions += "NameFake"
			if(S:MakesSword)
				BuffOptions += "MakesSword"
			if(S:MakesStaff)
				BuffOptions += "MakesStaff"
			if(S:MakesSecondSword)
				BuffOptions += "MakesSecondSword"
			if(S:MakesArmor)
				BuffOptions += "MakesArmor"
			if(S:makSpace)
				BuffOptions += "Make Space Icon"
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in BuffOptions
		else if(istype(S,/obj/Skills/Queue))
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in QueueOptions
		else if(istype(S,/obj/Skills/Projectile))
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in ProjectileOptions
		else if(istype(S,/obj/Skills/AutoHit))
			Mode=input(src, "What aspect do you wish to customize on [S]?", "Customize Skill") in AutohitOptions
		else
			usr << "This skill can't be customized at this time!"
			return
		var/pre = Mode
		if(Mode in list("IconLock", "AuraLock", "HairLock", "TopOverlayLock" ))
			Mode = "Lock"
		switch(Mode)
			if("Make Space Icon")
				S:icon_to_use = input(src, "What icon?") as icon|null
			if("NameFake")
				S:NameFake  = input(src, "What fake name?") as text
			if("MakesSword")
				S:SwordIcon  = input(src, "What icon?") as icon|null
				S:SwordX  = input(src, "What x") as num
				S:SwordY  = input(src, "What y") as num
			if("MakesStaff")
				S:StaffIcon  = input(src, "What icon?") as icon|null
				S:StaffX  = input(src, "What x") as num
				S:StaffY  = input(src, "What y") as num


			if("MakesSecondSword")
				S:SwordIconSecond  = input(src, "What icon?") as icon|null
				S:SwordXSecond  = input(src, "What x") as num
				S:SwordYSecond  = input(src, "What y") as num

			if("MakesArmor")
				S:ArmorIcon  = input(src, "What icon?") as icon|null
				S:ArmorX  = input(src, "What x") as num
				S:ArmorY  = input(src, "What y") as num

			if("Lock")
				var/icon/choice = input("What icon?") as icon|null
				var/_x=input("Pixel X?") as num|null
				var/_y=input("Pixel Y?") as num|null
				S.vars["[pre]"] = choice
				if(pre != "TopOverLayLock")
					var/rawname = replacetext(pre, "Lock", "")
					S.vars["[rawname]X"] = _x
					S.vars["[rawname]Y"] = _y
				if(pre == "IconLock")
					var/blend = input(src, "What blend mode?") in list("ADD","SUB", "INSET_OVERLAY", "OVERLAY", "MULTIPLY")
					switch(blend)
						if("ADD")
							S.vars["IconLockBlend"] = BLEND_ADD
						if("SUB")
							S.vars["IconLockBlend"] = BLEND_SUBTRACT
						if("INSET_OVERLAY")
							S.vars["IconLockBlend"] = BLEND_INSET_OVERLAY
						if("OVERLAY")
							S.vars["IconLockBlend"] = BLEND_OVERLAY
						if("MULTIPLY")
							S.vars["IconLockBlend"] = BLEND_MULTIPLY


			if("Aria Lines")
				var/list/l = S:Aria
				l.Add("Cancel")
				var/LineNum = input(src, "What line do you want to change?") in l
				l.Remove("Cancel")
				if(LineNum=="Cancel") return
				var/linePos = S:Aria.Find(LineNum)
				var/newLine = input(src, "What would you like the new line to say?") as text|null
				if(!newLine) return
				S:Aria[linePos] = newLine

			if("Active Message")
				S.CustomActive=input(src, "What message do you want [S] to display when activated?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomActive=="")
					S.CustomActive=0
				if(S.CustomActive)
					src << "[S] [Mode] set to '[S.CustomActive]'"
				else
					src << "[S] custom active message cleared."
			if("Off Message")
				S.CustomOff=input(src, "What message do you want [S] to display when deactivated?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomOff=="")
					S.CustomOff=0
				if(S.CustomOff)
					src << "[S] [Mode] set to '[S.CustomOff]'"
				else
					src << "[S] custom off message cleared."
			if("Charge Message")
				S.CustomCharge=input(src, "What message do you want [S] to display when charging?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomCharge=="")
					S.CustomCharge=0
				if(S.CustomCharge)
					src << "[S] [Mode] set to '[S.CustomCharge]'"
				else
					src << "[S] custom charge message cleared."
			if("Fire Message")
				S.CustomActive=input(src, "What message do you want [S] to display when fired?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomActive=="")
					S.CustomActive=0
				if(S.CustomActive)
					src << "[S] [Mode] set to '[S.CustomActive]'"
				else
					src << "[S] custom fire message cleared."
			if("Hit Message")
				S.CustomActive=input(src, "What message do you want [S] to display when hit?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomActive=="")
					S.CustomActive=0
				if(S.CustomActive)
					src << "[S] [Mode] set to '[S.CustomActive]'"
				else
					src << "[S] custom hit message cleared."
			if("Miss Message")
				S.CustomOff=input(src, "What message do you want [S] to display when missed?  HTML is allowed.", "Set [Mode]") as text|null
				if(S.CustomOff=="")
					S.CustomOff=0
				if(S.CustomOff)
					src << "[S] [Mode] set to '[S.CustomOff]'"
				else
					src << "[S] custom miss message cleared."
			if("Icon")
				S.sicon=input("What icon?") as icon|null
				S.sicon_state=input("Icon state?") as text|null
				S.pixel_x=input("Pixel X?") as num|null
				S.pixel_y=input("Pixel Y?") as num|null
				if(S.type in typesof(/obj/Skills/Queue))
					S:IconLock=S.sicon
					S:LockX=S.pixel_x
					S:LockY=S.pixel_y
				if(S.type in typesof(/obj/Skills/Projectile))
					S:LockX=S.pixel_x
					S:LockY=S.pixel_y
					S:IconLock=S.sicon
				if(S.type in typesof(/obj/Skills/AutoHit))
					S:IconX=S.pixel_x
					S:IconY=S.pixel_y
					S:Icon=S.sicon
				usr<<"[S] icon is now changed to: [S.sicon] / [S.sicon_state]"
	Custom_Appearance_Hair(var/mob/A as mob in view(usr,5))
		set src=usr.client
		set category="Other"
		set hidden = 1
		set name="Customize: Hair"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(istype(A,/mob))
			if(usr.Alert("You sure you wanna change [A]'s hair icon?"))
				var/Z=input(usr,"Choose an icon for [A]!","ChangeIcon")as icon|null
				if(Z==null)
					return
				if((length(Z) > 102400))
					usr <<"This file exceeds the limit of 100KB. It cannot be used."
					return
				if(A!=usr)
					var/hm=input(A,"Do you want to change your hair icon into [Z] which [usr] presented?")in list("No","Yes")
					if(hm=="No")
						return
				var/Color=input(A,"Choose color if needed, otherwise hit cancel.") as color|null
				if(Color) Z+=Color
				A.Hair_Base=Z
				A.Hair_Color=Color
				A.Hairz("Add")
	Custom_Appearance_Hair_Details()
		set category="Other"
		set hidden = 1
		set name="Customize: Hair Details"
		src.Hairz("Remove")
		src.HairUnderlay=input(src, "Set a hair underlay.", "Hair Underlay") as file|null
		if(src.HairUnderlay)
			src.HairUnderlayX=input(src, "Pixel X for underlay?", "Hair Underlay X") as num|null
			src.HairUnderlayY=input(src, "Pixel Y for underlay?", "Hair Underlay Y") as num|null
		if(alert(src, "Do you want to set an x/y offset for your hair overlay?", "Hair Overlay Offset", "Yes", "No")=="Yes")
			src.HairX=input(src, "Pixel X for overlay?", "Hair Overlay X") as num|null
			src.HairY=input(src, "Pixel Y for overlay?", "Hair Overlay Y") as num|null
		src.Hairz("Add")
		src << "Done."
	Custom_Appearance_General(var/atom/A as mob|obj in view(usr,5))
		set src=usr.client
		set category="Other"
		set hidden = 1
		set name="Customize: Icon"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(istype(A,/obj))
			if(istype(A,/obj/Planets)||istype(A,/obj/Oozaru)||istype(A,/obj/Login))
				usr<<"You're not allowed to change these icons."
				return
			if(usr.Alert("You sure you wanna change [A]'s icon?"))
				var/Z=input(usr,"Choose an icon for [A]!","ChangeIcon")as icon|null
				if(Z==null)
					return
				if((length(Z) > 95000))
					usr <<"This file exceeds the limit of 50KB. It cannot be used."
					return
				A.LastIconChange=usr.key
				A.icon=Z
				A.icon_state=input("icon state") as text
				A.pixel_x=input("X adjustment.") as num
				A.pixel_y=input("Y adjustment.") as num
		if(istype(A,/mob))
			if(usr.Alert("You sure you wanna change [A]'s icon?"))
				var/Z=input(usr,"Choose an icon for [A]!","ChangeIcon")as icon|null
				if(Z==null)
					return
				if((length(Z) > 102400))
					usr <<"This file exceeds the limit of 100KB. It cannot be used."
					return
				if(A!=usr)
					var/hm=input(A,"Do you want to change your icon into [Z] which [usr] presented?")in list("No","Yes")
					if(hm=="No")
						return
				A.LastIconChange=usr.key
				A.icon=Z
				A.pixel_x=input("X adjustment.") as num
				A.pixel_y=input("Y adjustment.") as num
				A?:customPixelX= A.pixel_x
				A?:customPixelY= A.pixel_y
				A?:client.SaveChar()

	Custom_Appearance_Forms(var/atom/A as mob in view(usr,5))
		set src=usr.client
		set category="Other"
		set hidden = 1
		set name="Customize: Forms"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/list/Options=list("Cancel")
		var/list/transOptions = list("Cancel")
		if(istype(A,/mob))
			if(usr.isRace(MAKYO))
				Options.Add("Expanded State")
			else if(usr.race.transformations.len>0)
				for(var/transformation/t in usr.race.transformations)
					transOptions.Add("[t.type]")
			else if(locate(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form, usr))
				Options.Add("Spirit Form Base")
				Options.Add("Spirit Form Hair")
				Options.Add("Spirit Form Top Overlay")
				Options.Add("Spirit Form Overlay")
				Options.Add("Spirit Form Aura")
				Options.Add("Spirit Form Profile")
				Options.Add("Spirit Form Active Text")
				Options.Add("Spirit Form Revert Text")
			else
				usr << "Only certain races and classes can change their form icons."
				return

			if(transOptions.len>1)
				var/Choice = input(usr, "Which transformation do you want to edit?", "Change Form Icons") in transOptions
				if(Choice == "Cancel") goto SKIP
				Choice = text2path(Choice)
				var/transformation/transSelected
				for(var/transformation/t in usr.race.transformations)
					if(istype(t, Choice))
						transSelected = t
						break
				var/list/transVisualOptions = list("Cancel", "Base", "Hair", "Icon 1", "Underlay 1", "Icon 2", "Underlay 2", "Aura", "Aura Underlay", "Profile")
				var/aspectPicked=input(usr, "What aspect of your forms do you wish to edit?", "Change Form Icons") in transVisualOptions
				switch(aspectPicked)
					if("Base")
						transSelected.form_base = input(usr, "What base icon would you like to use in this form?", "Base Icon") as icon|null
						if(transSelected.form_base)
							transSelected.form_base_x = input(usr, "X offset?", "Base X") as num|null
							transSelected.form_base_y = input(usr, "Y offset?", "Base Y") as num|null
					if("Hair")
						transSelected.form_hair_icon = input(usr, "What hair would you like to use in this form?", "Hair") as icon|null
						if(transSelected.form_hair_icon)
							transSelected.form_hair_x = input(usr, "X offset?", "Hair X") as num|null
							transSelected.form_hair_y = input(usr, "Y offset?", "Hair Y") as num|null
					if("Icon 1")
						transSelected.form_icon_1_icon = input(usr, "What extra overlay icon would you like to use in this form?", "Icon 1") as icon|null
						if(transSelected.form_icon_1_icon)
							transSelected.form_icon_1_icon_state = input(usr, "State?", "State", transSelected.form_icon_1_icon_state) as message|null
							transSelected.form_icon_1_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_icon_1_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
							transSelected.form_icon_1_layer = input(usr, "Layer?", "Layer") as num|null
					if("Underlay 1")
						transSelected.form_underlay_1_icon = input(usr, "What extra underlay icon would you like to use in this form?", "Underlay 1") as icon|null
						if(transSelected.form_underlay_1_icon)
							transSelected.form_underlay_1_icon_state = input(usr, "State?", "State", transSelected.form_underlay_1_icon_state) as message|null
							transSelected.form_underlay_1_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_underlay_1_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
					if("Icon 2")
						transSelected.form_icon_2_icon = input(usr, "What extra overlay would you like to use in this form?", "Icon 2") as icon|null
						if(transSelected.form_aura_underlay_icon)
							transSelected.form_icon_2_icon_state = input(usr, "State?", "State", transSelected.form_icon_2_icon_state) as message|null
							transSelected.form_icon_2_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_icon_2_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
					if("Underlay 2")
						transSelected.form_underlay_2_icon = input(usr, "What extra underlay icon would you like to use in this form?", "Underlay 2") as icon|null
						if(transSelected.form_underlay_2_icon)
							transSelected.form_underlay_2_icon_state = input(usr, "State?", "State", transSelected.form_underlay_2_icon_state) as message|null
							transSelected.form_underlay_2_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_underlay_2_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
					if("Aura")
						transSelected.form_aura_icon = input(usr, "What aura would you like to use in this form?", "Aura") as icon|null
						if(transSelected.form_aura_icon)
							transSelected.form_aura_icon_state = input(usr, "State?", "State", transSelected.form_aura_icon_state) as message|null
							transSelected.form_aura_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_aura_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
					if("Aura Underlay")
						transSelected.form_aura_underlay_icon = input(usr, "What aura underlay would you like to use in this form?", "Aura Underlay") as icon|null
						if(transSelected.form_aura_underlay_icon)
							transSelected.form_aura_underlay_icon_state = input(usr, "State?", "State", transSelected.form_aura_underlay_icon_state) as message|null
							transSelected.form_aura_underlay_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_aura_underlay_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
					if("Profile")
						transSelected.form_profile=input(usr, "What profile would you like to display while in this form?", "Change Form Profile", transSelected.form_profile) as message|null

			SKIP
			if(Options.len>1)
				var/Choice=input(usr, "What aspect of your forms do you wish to edit?", "Change Form Icons") in Options
				switch(Choice)
					if("Expanded State")
						usr.ExpandBase=input(usr, "What base do you want to use for your Expanded State?", "Change Form Icon") as icon|null
					if("Spirit Form Base")
						usr.Form1Base=input(usr, "What base would you like to use while in Spirit Form?", "Change Form Icon") as icon|null
						if(usr.Form1Base)
							usr.Form1BaseX=input(usr, "X offset?", "Change Form Icon") as num|null
							usr.Form1BaseY=input(usr, "Y offset?", "Change Form Icon") as num|null
					if("Spirit Form Hair")
						usr.Form1Hair=input(usr, "What hair would you like to use while in Spirit Form?", "Change Form Icon") as icon|null
						if(usr.Form1Hair)
							usr.Form1HairX=input(usr, "X offset?", "Change Form Icon") as num|null
							usr.Form1HairY=input(usr, "Y offset?", "Change Form Icon") as num|null
					if("Spirit Form Overlay")
						usr.Form1Overlay=input(usr, "What overlay would you like to use while in Spirit Form?", "Change Form Icon") as icon|null
						if(usr.Form1Overlay)
							usr.Form1OverlayX=input(usr, "X offset?", "Change Form Icon") as num|null
							usr.Form1OverlayY=input(usr, "Y offset?", "Change Form Icon") as num|null
					if("Spirit Form Top Overlay")
						usr.Form1TopOverlay=input(usr, "What Top Overlay would you like to use while in Spirit Form?", "Change Form Icon") as icon|null
						if(usr.Form1TopOverlay)
							usr.Form1TopOverlayX=input(usr, "X offset?", "Change Form Icon") as num|null
							usr.Form1TopOverlayY=input(usr, "Y offset?", "Change Form Icon") as num|null
					if("Spirit Form Profile")
						usr.Form1Profile=input(usr, "What profile would you like to display while in Spirit Form?", "Change Form Icon", usr.Form1Profile) as message|null
					if("Spirit Form Aura")
						usr.Form1Aura=input(usr, "What aura would you like to use while in Spirit Form?", "Change Form Icon") as icon|null
						if(usr.Form1Aura)
							usr.Form1AuraX=input(usr, "X offset?", "Change Form Icon") as num|null
							usr.Form1AuraY=input(usr, "Y offset?", "Change Form Icon") as num|null
					if("Spirit Form Active Text")
						usr.Form1ActiveText=input(usr, "What text would you like to display while entering Spirit Form?  There is no default text.", "Change Form Icon") as text|null
					if("Spirit Form Revert Text")
						usr.Form1RevertText=input(usr, "What text would you like to display while entering Spirit Form?  There is no default text.", "Change Form Icon") as text|null

	Custom_Appearance_Charge()
		set category="Other"
		set hidden = 1
		set name="Customize: Ki Charge"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/Z=input(usr,"Choose an icon for your Charge effect, that shows when charging a beam or Charge skill. The icon must have a blank named icon state in the file.","ChangeIcon")as icon | null
		if(!Z) return
		usr.ChargeIcon=Z

	Reset_Multipliers()
		set category="Other"
		set hidden = 1
		set name="Reset Multipliers"
		if(src.Power_Multiplier==1&&src.StrMultTotal==1&&src.EndMultTotal==1&&src.SpdMultTotal==1&&src.ForMultTotal==1&&src.OffMultTotal==1&&src.DefMultTotal==1&&src.RecovMultTotal==1)
			src << "Your mults are already at 1!"
			return FALSE
		if(src.StanceBuff||src.StyleBuff||src.ActiveBuff||src.SpecialBuff||src.SlotlessBuffs.len>0)
			src << "You have a buff on! You can't reset your mults! (Yes, including Power Armor and similar!)"
			return FALSE
		if(src.transActive)
			src << "You're transformed, you can't reset your mults while transformed!"
			return FALSE
		src.MultReset()

	Reset_Overlays()
		set category="Other"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.PurgeHurtboxDebug()
		usr.AppearanceOff()
		usr.AppearanceOn()
	Customize_PoweredState_Menu()
		set category="Utility"
		set hidden = 1
		set name="Customize: Powered State"
		for(var/obj/O in usr)
			for(var/v in O.verbs)
				if("[v:name]" == "Customize Powered State")
					call(O, v)()
					return
		usr << "You need Ki Control (use Meditation first) to customize your powered state."
	Text_Color_Say()
		set category="Other"
		set hidden = 1
		set name="Text Color: IC"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.Text_Color=input(usr, "Choose a color for Say.") as color
	Emote_Color()
		set category="Other"
		set hidden = 1
		set name="Text Color: Emote"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.Emote_Color=input(usr, "Choose a color for Emote.") as color
	Text_Color_OOC()
		set category="Other"
		set hidden = 1
		set name="Text Color: OOC"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.OOC_Color=input(usr, "Choose a color for OOC.") as color
	Who()
		set category="Other"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/list/people=new
		for(var/mob/M in players)
			if(M.client)
				people.Add(M.key)
		var/list/sortedpeople=dd_sortedTextList(people,0)
		var/online=0
		var/View = {"<html><head><title>Who</title>
<style>
body{margin:0;background:#0d1730;color:#d8f6ff;font-family:Verdana,Arial,sans-serif;font-size:12px;}
.wrap{border:2px solid #45c7e0;margin:8px;padding:10px;background:#132447;}
h2{margin:0 0 8px 0;color:#8be9ff;font-size:16px;letter-spacing:1px;}
.summary{color:#55ee55;font-weight:bold;margin-top:8px;}
table{width:100%;border-collapse:collapse;}
th{color:#ffd76b;text-align:left;border-bottom:1px solid #45c7e0;padding:4px 6px;}
td{border-bottom:1px solid #2e6682;padding:4px 6px;vertical-align:top;}
.num{text-align:right;white-space:nowrap;}
.row{border-top:1px solid #2e6682;padding:5px 0;}
.row:first-of-type{border-top:0;}
a{color:#8be9ff;}
</style></head><body><div class='wrap'><h2>WHO</h2>"}
		if(usr.Admin)
			View+={"
					<table>
					<tr>
					<th>Key (IC Name)</th>
					<th>Race</th>
					<th>Location</th>
					<th class='num'>Base</th>
					<th>Age</th>
					<th class='num'>Spent</th>
					<th class='num'>Spendable</th>
					<th class='num'>Total</th>
					<th class='num'>Race Excl.</th>
					</tr>"}
			for(var/x in sortedpeople)
				for(var/mob/M in players)
					if(M.key==x)
						online++
						var/race_excluded = round((M.RPPSpent + M.RPPSpendable) / M.RPPMult, 1)
						View+={"<tr>
							<td>[M.key] ([M.name]) <a href=?src=\ref[M];action=MasterControl>x</a></td>
							<td>[M.race.name]</td>
							<td>[M.loc] ([M.x],[M.y],[M.z])</td>
							<td class='num'>[M.Base] ([M.potential_power_mult])</td>
							<td>[M.EraBody]</td>
							<td class='num'>[M.RPPSpent]</td>
							<td class='num'>[M.RPPSpendable]</td>
							<td class='num'>[M.RPPSpendable + M.RPPSpent]</td>
							<td class='num'>[race_excluded]</td>
							</tr>"}
						break
			View+={"</table>"}
		else

			for(var/x in sortedpeople)
				online++
				View+="<div class='row'>[x]</div>"
		View+="<div class='summary'>Online: [online]</div></div></body></html>"
		if(usr.Admin)
			usr<<browse("[View]","window=Logzk;size=900x450")
		else
			usr<<browse("[View]","window=Logzk;size=240x420")

	Toggle_Auto_Berserk()
		set category = "Other"
		set name = "Toggle Auto Berserk"
		if(usr.AutoBerserkOptOut)
			usr.AutoBerserkOptOut = 0
			usr << "Auto Berserk re-enabled. Buffs that force Anger (Jinchuuriki, Vaizard Mask, Wrathful, etc.) will trigger it normally."
		else
			usr.AutoBerserkOptOut = 1
			usr << "Auto Berserk disabled. Buffs with the Auto Anger flag will no longer force you into the Anger state on activation."

	GetPingSound()
		set category = "Other"
		set name = "Toggle Ping Sound"
		if(usr.PingSound)
			usr.PingSound = 0
			usr << "Ping Sound Disabled."
		else
			usr.PingSound = 1
			usr << "Ping Sound Enabled."

	SetPingVolume()
		set category = "Other"
		set name = "Set Ping Volume"
		var/n = input(src, "What volume?") as num
		if(n > 100 || n < 0)
			src << " too high or low "
		else
			PingVolume = n

	CustomizePU()
		set name = "Customize: PU Charging"
		set category = "Other"
		if(!src.client)
			return
		var/choice = input(src, "Change PU Charging", "PU Charging Style") as text
		if(length(choice)>200)
			return
		if(length(choice)<1)
			return
		custom_powerup = choice
		choice = input(src, "Do you want to include your name in the PU charging?") in list("Yes", "No")
		if(choice == "Yes")
			customPUnameInclude = TRUE
		else
			customPUnameInclude = FALSE

	Admins()
		set name = "Admins"
		set category = "Other"
		for(var/mob/p in players)
			if(p.Admin)
				src<<"[p.DisplayKey ? p.DisplayKey : p.key] (Admin [p.Admin])"

	Character_Description()
		set category="Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/CharProfile=input(src, "Please input a description for your character.", "Character Description", usr.Profile) as message
		while(sanitizeDesc(CharProfile))
			src<<"Your profile contains illegal tags. Please try again."
			return
		usr.Profile=CharProfile
	Countdown()
		set category="Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/time=30*10
		//TODO: make it so it alerts others that they r in a party, esp if they r namekian and have a counterpart.
		src.OMessage(30,"[src] is counting down! ([time/10] seconds)","<font color=silver>[src]([src.key]) used countdown.")
		spawn(time)	src.OMessage(30,"[src] ended counting down! (0 seconds)","<font color=silver>[src]([src.key]) ended using countdown.")
		spawn(time/2)	src.OMessage(30,"[src] counting down! ([time/2/10] seconds)")
		spawn(time/1.2)
			for(var/i=5, i>0, i--)
				src.OMessage(30,"[src] - [i]!")
				sleep(10)

	WoundIntent()
		set name="Intent to Injure"
		set category="Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.WoundIntent)
			usr.WoundIntent=0
			src.OMessage(10, "<font color='grey'>[src] will no longer fight with intent to injure.</font>", "[src]([src.key]) turned injury intent off.")
			if(src.HellspawnBerserk)
				src.OMessage(10, "<font color='grey'>But that <b>thing</b> using their body will not stand down so easily.</font>", "[src]([src.key]) toggled wound intent on.")
				src.WoundIntent=1
				return
		else
			usr.WoundIntent=1
			src.OMessage(10, "<font color='red'>[src] will now fight with intent to injure!!</font>", "[src]([src.key]) turned injury intent on.")
	LethalityToggle()
		set name="Intent to Kill"
		set category= "Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(src.Lethal)
			if(src.HellspawnBerserk||src.ForcedLethal)
				src.OMessage(10, "<font color='grey'Try as they might, [src] cannot quell their killing intent.</font>", "[src]([src.key]) toggled lethal on.")
				return
			src.Lethal=0
			src.OMessage(10, "<font color='grey'>[src] will no longer deal lethal damage!!</font>", "[src]([src.key]) toggled lethal off.")
			return
		if(!src.Lethal)
			src.OMessage(10, "<font color='red'>[src] will now deal lethal damage!!</font>", "[src]([src.key]) toggled lethal on.")
			src.Lethal=20
			return
	ToggleRPMode()
		set name="Intent to Roleplay"
		set category= "Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		RPModeSwitch()
	Force_Heavy_Strike()
		set name="Force Heavy Strike"
		set category= "Utility"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(src.ForceHeavyStrike)
			src.ForceHeavyStrike=0
			usr<< "You will now use your special Heavy Strike, if you have one."
			return
		if(!src.ForceHeavyStrike)
			src.ForceHeavyStrike=1
			usr<< "You will now use a normal Heavy Strike."
			return

// Demon (and Angel) combo spells
/mob/proc/RPMode_AdjustNestedComboSpellCooldowns(pausing = 1)
	for(var/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/dm in src)
		if(!dm.possible_skills) continue
		for(var/x in dm.possible_skills)
			var/obj/Skills/s = dm.possible_skills[x]
			if(!s || !s.cooldown_remaining) continue
			if(pausing)
				s.cooldown_remaining = SkillCDRemaining(s)
				s.cooldown_start = 0
				s.cooldown_start_wt = 0
			else
				s.Cooldown(modify=1,Time=s.cooldown_remaining, p=src)
	for(var/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/am in src)
		if(!am.possible_skills) continue
		for(var/x in am.possible_skills)
			var/obj/Skills/s = am.possible_skills[x]
			if(!s || !s.cooldown_remaining) continue
			if(pausing)
				s.cooldown_remaining = SkillCDRemaining(s)
				s.cooldown_start = 0
				s.cooldown_start_wt = 0
			else
				s.Cooldown(modify=1,Time=s.cooldown_remaining, p=src)

mob/proc/RPModeSwitch()
	if(src.PureRPMode)
		src.PureRPMode=0
		RPMode(src,"Off")
		src<< "You have toggled RP mode off. Regeneration and Recovery enabled. All of your Cooldowns are unpaused."
		src.OMessage(10,"[src] has disabled Pure RP Mode! Regen/Recovery reenabled!")
		for(var/mob/Player/AI/a in ai_followers)
			spawn(rand(1,6)) RPMode(a, "Off")
		for(var/obj/Skills/s in src)
			if(istype(s, /obj/Skills/Grab)) continue
			if(s.cooldown_remaining)
				s.Cooldown(modify=1,Time=s.cooldown_remaining)
		src.RPMode_AdjustNestedComboSpellCooldowns(0)
		src.resumeStyleRatingExpiryAfterRP()
		return
	if(!src.PureRPMode)
		RPMode(src,"On")
		src<< "You have toggled RP mode on. Regeneration and Recovery disabled. All of your Cooldowns are paused."
		src.PureRPMode=1
		src.NextAttack=0
		src.OMessage(10,"[src] has enabled Pure RP Mode! Regen/Recovery disabled!")
		for(var/mob/Player/AI/a in ai_followers)
			spawn(rand(1,6)) RPMode(a, "On")
		for(var/obj/Skills/s in src)
			if(istype(s, /obj/Skills/Grab)) continue
			if(s.cooldown_remaining)
				s.cooldown_remaining = SkillCDRemaining(s)
				s.cooldown_start = 0
				s.cooldown_start_wt = 0
		src.RPMode_AdjustNestedComboSpellCooldowns(1)
		src.pauseStyleRatingExpiryForRP()
		return

mob/proc/CutsceneMode()
	if(src.PureRPMode)
		src.PureRPMode=0
		src.CutsceneWatch=0
		for(var/mob/Player/AI/a in ai_followers)
			spawn(rand(1,6)) RPMode(a, "Off")
		for(var/obj/Skills/s in src)
			if(istype(s, /obj/Skills/Grab)) continue
			if(s.cooldown_remaining)
				s.Cooldown(modify=1,Time=s.cooldown_remaining)
		src.RPMode_AdjustNestedComboSpellCooldowns(0)
		src.resumeStyleRatingExpiryAfterRP()
		return
	if(!src.PureRPMode)
		src.PureRPMode=1
		src.CutsceneWatch=1
		src.NextAttack=0
		src.OMessage(10,"[src] is watching a cutscene, regen/recovery disabled!")
		for(var/mob/Player/AI/a in ai_followers)
			spawn(rand(1,6)) RPMode(a, "On")
		for(var/obj/Skills/s in src)
			if(istype(s, /obj/Skills/Grab)) continue
			if(s.cooldown_remaining)
				s.cooldown_remaining = SkillCDRemaining(s)
				s.cooldown_start = 0
				s.cooldown_start_wt = 0
		src.RPMode_AdjustNestedComboSpellCooldowns(1)
		src.pauseStyleRatingExpiryForRP()
		return

mob/Players/verb
	Roll_Dice()
		set category="Roleplay"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/textstring=""
		var/total=0
		var/dienumber=input("How many dice?") as num
		if(dienumber>10)
			dienumber=10
		var/diesides=input("How many sides?") as num
		if(diesides>100)
			diesides=100
		var/diemodifer=input("Modify the total?") as num
		if(diemodifer>100)
			diemodifer=100
		if(diemodifer<-100)
			diemodifer=-100
		var/decision=input("Seperate the dice rolls?") in list("Yes","No")
		if(decision=="Yes")
			var/oldnum = dienumber
			while(dienumber>0)
				var/die="1d[diesides]"
				var/dieroll=roll(die)
				textstring+="[dieroll] "
				total+=dieroll
				dienumber--
			total+=diemodifer
			var/msg = "<b><font color=red>DICE:</b></font> [usr] rolled a total of [total] ([oldnum]d[diesides]+[diemodifer]), rolls were [textstring]."
			usr.OMessage(10,msg)
			Log(usr.ChatLog(),msg)
			Log(usr.sanitizedChatLog(),msg)
			if(usr.BeingObserved.len>0)
				for(var/mob/m in usr.BeingObserved)
					m.client.outputToChat("[OBSERVE_HEADER] [msg]", ALL_OUTPUT)
		if(decision=="No")
			var/dice="[dienumber]d[diesides]+[diemodifer]"
			var/roll=roll(dice)
			var/msg = "<b><font color=red>DICE:</b></font> [usr] rolled [roll] ([dienumber]d[diesides]+[diemodifer])."
			usr.OMessage(10,msg)
			Log(usr.ChatLog(),msg)
			Log(usr.sanitizedChatLog(),msg)
			if(usr.BeingObserved.len>0)
				for(var/mob/m in usr.BeingObserved)
					m.client.outputToChat("[OBSERVE_HEADER] [msg]", ALL_OUTPUT)

	Pose()
		set category="Skills"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		//flourish: pose right after a guard break / wall splat / grab tech for a tension nod
		if(glob.POSE_FLOURISH && world.time <= src.flourish_until)
			src.flourish_until = 0
			if(src.canGainTension())
				src.gainTension(glob.FLOURISH_TENSION)
			KenShockwave(src, icon='KenShockwaveFocus.dmi', Size=0.5, Blend=2, Time=3)
			OMsg(src, "[src] strikes a pose!")
			return
		if(src.icon_state==""&&!src.PoseEnhancement)
			if(src.CheckSlotless("Half Moon Form")||src.CheckSlotless("Full Moon Form"))
				OMsg(src, "[src] radiates animalistic bloodlust as they prepare to pounce!")
			else if(src.Secret=="Hamon")
				OMsg(src, "[src] begins posing beautifully!")
			else if(src.Secret=="Vampire")
				OMsg(src, "[src] begins posing ominously!")
			else if(src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus")&&!src.CheckSlotless("Sage Mode"))
				OMsg(src, "[src] grows completely still!")
			else if(hasSecret("Eldritch")&&!CheckSlotless("True Form"))
				OMsg(src, "[src]'s body starts unraveling...!")
			else if(Secret == "Spiral")
				OMsg(src, "[src] clenches their fists!")
			else if(src.Secret=="Haki")
				if(src.CheckSlotless("Haki Armament"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
						H.Trigger(src)
				if(!src.CheckSlotless("Haki Observation"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
						H.Trigger(src)
				OMsg(src, "[src] relaxes, becoming a reed on the wind!")
				src.AddHaki("Observation")
				if(!src.CheckSlotless("Haki Relax")&&!src.CheckSlotless("Haki Relax Lite"))
					if(src.secretDatum.secretVariable["HakiSpecialization"]=="Observation")
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax/H in src)
							H.Trigger(src)
					else
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Relax_Lite/H in src)
							H.Trigger(src)
					src.PoseEnhancement=1
					spawn(Second(30))
						src.PoseEnhancement=0
				return
			if(world.time>usr.LastPose+20)
				usr.PoseTime+=1
				usr.LastPose=world.time
			src.icon_state="Train"
			return
		if(src.icon_state=="Train")
			src.icon_state=""
			if(!src.PoseEnhancement)
				if(!src.CheckSlotless("Half Moon Form")&&!src.CheckSlotless("Full Moon Form"))
					if(src.PoseTime>=5&&(src.RippleActive()||src.Secret=="Vampire"||src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus"))||Secret=="Eldritch"||Secret=="Spiral")
						src.PoseTime=0
						if(src.RippleActive())
							for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement/H in src)
								H.Trigger(src)
						if(src.Secret=="Vampire")
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Restraint_Release)
						if(src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus"))
							src.ManaAmount+=25

				else
					var/PoseBuff=(src.PoseTime/4)
					if(PoseBuff<1)
						PoseBuff=1
					src.PoseTime=0
					if(src.Target)
						src.Comboz(src.Target)
						src.Melee1(damagemulti=PoseBuff, accmulti=PoseBuff, NoKB=1)
					src.PoseEnhancement=1
					spawn(Second(30))
						src.PoseEnhancement=0
			return
	Skill_Sheet()
		set name="Skill Sheet"
		set hidden=1
		set category="Skills"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Grid("SkillSheet")

	Access_Technology()
		set category="Utility"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.client) usr.client.OpenTechMenu("craft")
	Access_Enchantment()
		set category="Utility"
		set hidden = 1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Grid("Enchant")



/*	Admins()
		set category="Other"
		set hidden = 1
		var/list/admins=new
		admins.Add(Admins,CodedAdmins)
		for(var/x in admins)
			for(var/mob/M in world)
				if(M.client)
					if(M.key==x)
						usr<<"[x] | [admins[x]]<font color=green> (Online)"
						admins.Remove(x)
		admins.Remove(CodedAdmins)
		for(var/y in admins)
			usr<<"[y] | [admins[y]]"*/


mob/var/tmp/Spam=0

proc/SpamCheck(var/mob/M,var/T)
	if(M.CheckPunishment("Mute"))
		return 1
	if(!M.Admin)
		M.Spam++
		spawn(20)if(M.Spam>0)M.Spam--
		if(findtext(T,"\n\n\n")||M.Spam>9)
			world<<"[M]([M.key]) was just muted for spamming!(Auto)"
			var/Duration=Value(world.realtime+(5000))
			var/Reason="You fucked up, nigga."
			Punishment("Action=Add&Punishment=Mute&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[Duration]&User=[M.key]&Reason=[Reason]&Time=[TimeStamp()]")
			Punishment("Action=Add&Punishment=Ban&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[world.realtime+((10*60*60*24)*7)]&User=Auto&Reason=Spamming&Time=[TimeStamp()]")
		return 0

proc/OOC_Check(T)
	if(!Allow_OOC&&!(CodedAdmins.Find(usr.key)))
		usr<<"OOC is disabled."

		return 0
	return 1
proc/sanitizeDesc(n)
	var/list/nonos = list("<script>", "<Script>")
	for(var/x in nonos)
		if(findtext(n, x))
			return 1
	return 0
