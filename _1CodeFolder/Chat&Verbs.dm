
atom/proc/Examined(mob/user)
mob/Players/var/tmp/current_party_target_index = 1
mob/Players/verb
	Create_Party()
		set category="Party"
		if(src.Class in list("Dance", "Potara"))
			src << "You can't party with fused characters!"
			return
		if(src.party)
			src << "You are already in a party; you cannot create another one."
			return
		var/Party/p=new
		p.create_party(src)

	Party_Target_Cycle()
		set category = "Party"
		if(!src.party)
			src << "You don't have a party to cycle target on!"
			return
		current_party_target_index +=1
		if(current_party_target_index > party.members.len)
			current_party_target_index = 1
		usr.SetTarget(party.members[current_party_target_index])
		usr << "You target [usr.Target]."
	Manage_Party()
		set category="Party"
		if(!src.party)
			src << "You don't have a party to manage!"
			return
		var/list/options=list("Cancel", "Check Party", "Add Member", "Remove Member", "Pass Leader", "Leave Party")
		if(src.party.leader!=src)
			options.Remove("Add Member", "Remove Member", "Pass Leader")
		switch(input(src, "How do you want to manage your party?", "Manage Party") in options)
			if("Cancel")
				return
			if("Check Party")
				for(var/mob/m in src.party.members)
					if(m == src.party.leader)
						src << "\[LEADER\] - \..."
					src << "[m.name] - [round(m.Health, 10)]% / [round(m.Energy, 10)]%"
				return
			if("Add Member")
				if(src==src.party.leader)
					var/list/mob/the_boys=list("Cancel")
					for(var/mob/m in view(8, src))
						if(!m.party && !(m.Class in list("Dance", "Potara")))
							the_boys.Add(m)
					var/mob/my_boy=input(src, "Who do you want to add to your party?", "Add Member") in the_boys
					if(my_boy=="Cancel")
						return
					if(my_boy.party)
						return
					src.party.add_member(my_boy)
				return
			if("Remove Member")
				if(src==src.party.leader)
					var/list/mob/my_boys=list("Cancel")
					my_boys.Add(src.party.members)
					my_boys.Remove(src)
					var/mob/not_my_boy=input(src, "Who do you want to remove from your party?", "Remove Member") in my_boys
					if(not_my_boy=="Cancel")
						return
					if(src.party.members.Find(not_my_boy))
						src.party.remove_member(not_my_boy)
				return
			if("Pass Leader")
				if(src==src.party.leader)
					var/list/mob/my_boys=list("Cancel")
					my_boys.Add(src.party.members)
					my_boys.Remove(src)
					var/mob/the_best_boy=input(src, "Who do you want to pass your leadership to?", "Pass Leader") in my_boys
					if(the_best_boy=="Cancel")
						return
					if(src.party.members.Find(the_best_boy))
						src.party.pass_leader(src, the_best_boy)
				return
			if("Leave Party")
				if(src.party)
					src.party.remove_member(src)
				return

	Signature_Check()
		set category="Other"
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
		if(!(world.time > usr.verb_delay+4)) return
		usr.verb_delay=world.time+1

		if(usr.client.eye == usr) usr.Observing=0

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
				var/list/transVisualOptions = list("Cancel", "Base", "Hair", "Icon 1", "Icon 2", "Aura", "Aura Underlay", "Profile")
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
					if("Icon 2")
						transSelected.form_icon_2_icon = input(usr, "What extra overlay would you like to use in this form?", "Icon 2") as icon|null
						if(transSelected.form_aura_underlay_icon)
							transSelected.form_icon_2_icon_state = input(usr, "State?", "State", transSelected.form_icon_2_icon_state) as message|null
							transSelected.form_icon_2_x = input(usr, "X offset?", "Aura Underlay X") as num|null
							transSelected.form_icon_2_y = input(usr, "Y offset?", "Aura Underlay Y") as num|null
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
		set name="Customize: Ki Charge"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/Z=input(usr,"Choose an icon for your Charge effect, that shows when charging a beam or Charge skill. The icon must have a blank named icon state in the file.","ChangeIcon")as icon | null
		if(!Z) return
		usr.ChargeIcon=Z
	Reset_Multipliers()
		set category="Other"
		set name="Reset Multipliers"
		if(!(world.time > usr.verb_delay)) return
		is_dashing = 0
		if(isRace(BEASTMAN) && race?:Racial == "Feather Knife")
			passive_handler.passives["Secret Knives"] = "Feathers"
		if(isRace(BEASTMAN) && race?:Racial == "Fox Fire")
			passive_handler.passives["Heavy Strike"] = "Fox Fire"
		if(isRace(BEASTMAN) && race?:Racial == "Monkey King")
			var/obj/Skills/Buffs/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastman/Never_Fall/)
			if(!s.Using)
				s.Trigger(src, TRUE)
		if(isRace(BEASTMAN) && race?:Racial == "Heart of The Beastman")
			passive_handler.Set("Grit", 1)

		usr.verb_delay=world.time+1
		for(var/b in usr.SlotlessBuffs)
			var/obj/Skills/Buffs/x = usr.SlotlessBuffs[b]
			if(x==null)
				usr.SlotlessBuffs.Remove(null)
			if(x)
				if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament))
					x:Trigger(src)
				if(istype(x, /obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation))
					x:Trigger(src)
		if(usr.StanceBuff||usr.StyleBuff||usr.ActiveBuff||usr.SpecialBuff||usr.SlotlessBuffs.len>0)
			usr<<"You must disable all buffs before using this command."
			return
		if(usr.transActive)
			usr<<"You cannot do this while transed! Revert first!"
			return
		usr<<"Reseting stat and power multipliers."
		usr.Splits=new/list()
		usr.Power_Multiplier=1
		usr.StrMultTotal=1
		usr.EndMultTotal=1
		usr.SpdMultTotal=1
		usr.ForMultTotal=1
		usr.OffMultTotal=1
		usr.DefMultTotal=1
		usr.RecovMultTotal=1
		sleep(20)
		usr<<"Stats and power successfully reset to normal."
	Reset_Overlays()
		set category="Other"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.AppearanceOff()
		usr.AppearanceOn()
	Screen_Size()
		set category="Other"
		set hidden=1
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/screenmax = 31
		if(usr.Secret == "Heavenly Restriction" && usr.secretDatum?:hasImprovement("Senses"))
			screenmax = 71
		var/screenx=input("Enter the width of the screen, max is [screenmax].") as num
		screenx=min(max(1,screenx),screenmax)
		var/screeny=input("Enter the height of the screen, max is [screenmax].") as num
		screeny=min(max(1,screeny),screenmax)
		client.view="[screenx]x[screeny]"
		src.ScreenSize = "[screenx]x[screeny]"
	Text_Color_Say()
		set category="Other"
		set name="Text Color: IC"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.Text_Color=input(usr, "Choose a color for Say.") as color
	Emote_Color()
		set category="Other"
		set name="Text Color: Emote"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.Emote_Color=input(usr, "Choose a color for Emote.") as color
	Text_Color_OOC()
		set category="Other"
		set name="Text Color: OOC"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		src.OOC_Color=input(usr, "Choose a color for OOC.") as color
	Who()
		set category="Other"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		var/View={"<html><head><title>Who</title><body>
<font size=3><font color=red>Player Panel:<hr><font size=2><font color=black>"}
		var/list/people=new
		for(var/mob/M in players)
			if(M.client)
				people.Add(M.key)
		var/list/sortedpeople=dd_sortedTextList(people,0)
		var/online=0
		if(usr.Admin)
			View+={"
					<table border=1 cellspacing=6>
					<tr>
					<th><font size=2>Key (IC Name)</th>
					<th><font size=2>Race (Class)</th>
					<th><font size=2>Location</th>
					<th><font size=2>Base (BaseMod )/ Age Category</th>
					<th><font size=2>Reward Points: Spent, Spendable, Total (Race Excluded)</th>
					</tr>"}
			for(var/x in sortedpeople)
				for(var/mob/M in players)
					if(M.key==x)
						online++
						View+={"<tr>
							<td><font size=2>[M.key] ([M.name])/(<a href=?src=\ref[M];action=MasterControl>x</a href>)</td>
							<td><font size=2>[M.race.name]</td>
							<td><font size=2>[M.loc] ([M.x],[M.y],[M.z])</td>
							<td><font size=2>[M.Base]([M.potential_power_mult]) / [M.EraBody]</td>
							<td><font size=2>[M.RPPSpent], [M.RPPSpendable], [M.RPPSpendable+M.RPPSpent] ([round((M.RPPSpent+M.RPPSpendable)/M.RPPMult,1)])</td>
							</tr>"}
						break
			View+={"</table"><br>"}
		else

			for(var/x in sortedpeople)
				online++
				View+="[x]<br>"
		View+="<font color=green><b>Online:</b> [online]"
		if(usr.Admin)
			usr<<browse("[View]","window=Logzk;size=900x450")
		else
			usr<<browse("[View]","window=Logzk;size=150x400")


	Character_Description()
		set category="Roleplay"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Profile=input(src, "Please input a description for your character.", "Character Description", usr.Profile) as message
	Countdown()
		set category="Roleplay"
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
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.WoundIntent)
			usr.WoundIntent=0
			src.OMessage(10, "<font color='grey'>[src] will no longer fight with intent to injure.</font>", "[src]([src.key]) turned injury intent off.")
		else
			usr.WoundIntent=1
			src.OMessage(10, "<font color='red'>[src] will now fight with intent to injure!!</font>", "[src]([src.key]) turned injury intent on.")
	LethalityToggle()
		set name="Intent to Kill"
		set category= "Roleplay"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(src.Lethal)
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
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		RPModeSwitch()


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
				s.cooldown_remaining = s.cooldown_remaining - (world.realtime - s.cooldown_start)
				s.cooldown_start = 0
		return

mob/Players/verb
	Roll_Dice()
		set category="Roleplay"
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
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if(src.icon_state==""&&!src.PoseEnhancement)
			if(src.CheckSlotless("Half Moon Form")||src.CheckSlotless("Full Moon Form"))
				OMsg(src, "[src] radiates animalistic bloodlust as they prepare to pounce!")
			else if(src.Secret=="Ripple")
				OMsg(src, "[src] begins posing beautifully!")
			else if(src.Secret=="Vampire")
				OMsg(src, "[src] begins posing ominously!")
			else if(src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus")&&!src.CheckSlotless("Sage Mode"))
				OMsg(src, "[src] grows completely still!")
			else if(Secret == "Eldritch"&&!CheckSlotless("True Form"))
				OMsg(src, "[src]'s body starts unraveling...!")
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
			src.icon_state="Train"
			return
		if(src.icon_state=="Train")
			src.icon_state=""
			if(!src.PoseEnhancement)
				if(!src.CheckSlotless("Half Moon Form")&&!src.CheckSlotless("Full Moon Form"))
					if(src.PoseTime>=5&&(src.HasRipple()||src.Secret=="Vampire"||src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus"))||Secret=="Eldritch")
						src.PoseTime=0
						if(src.HasRipple())
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement)
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
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Grid("Tech")
	Access_Enchantment()
		set category="Utility"
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		usr.Grid("Enchant")



/*	Admins()
		set category="Other"
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