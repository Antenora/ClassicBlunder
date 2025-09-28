obj
	Skills
		Buffs
			Stances
				StanceSlot=1
				UsesStance=1
				// Stance_Selector
				// 	var/tmp/Selecting//Don't spam this.
				// 	verb/Toggle_Stance()
				// 		set category="Skills"
				// 		if(src.Selecting)
				// 			usr << "Stop trying to spam set a stance."
				// 			return
				// 		if(!usr.StyleBuff)
				// 			usr << "You aren't using a style; you can't select a stance yet."
				// 			return
				// 		src.Selecting=1
				// 		var/list/Stances=usr.StyleBuff.UnlockedStances
				// 		if(Stances.len<3)
				// 			usr << "You don't have any alternate stances to use!"
				// 			src.Selecting=0
				// 			return
				// 		var/Selected=input(usr, "What stance would you like to use?", "Set Stance") in Stances
				// 		if(Selected=="Cancel")
				// 			src.Selecting=0
				// 			return
				// 		if(!usr.StyleBuff)
				// 			src.Selecting=0
				// 			return
				// 		usr.StanceActive="[Selected]"
				// 		OMsg(usr, "[usr] assumes the [usr.StanceActive] stance of [usr.StyleBuff]!")
				// 		src.Selecting=0
				// 	verb/Advancing_Stance()
				// 		set hidden=1
				// 		if(usr.StyleBuff)
				// 			if("Advancing" in usr.StyleBuff.UnlockedStances)
				// 				if(usr.StanceActive!="Advancing")
				// 					OMsg(usr, "[usr] assumes the Advancing stance of [usr.StyleBuff]!")
				// 					usr.StanceActive="Advancing"
				// 	verb/Striking_Stance()
				// 		set hidden=1
				// 		if(usr.StyleBuff)
				// 			if("Striking" in usr.StyleBuff.UnlockedStances)
				// 				if(usr.StanceActive!="Striking")
				// 					OMsg(usr, "[usr] assumes the Striking stance of [usr.StyleBuff]!")
				// 					usr.StanceActive="Striking"
				// 	verb/Defensive_Stance()
				// 		set hidden=1
				// 		if(usr.StyleBuff)
				// 			if("Defensive" in usr.StyleBuff.UnlockedStances)
				// 				if(usr.StanceActive!="Defensive")
				// 					OMsg(usr, "[usr] assumes the Defensive stance of [usr.StyleBuff]!")
				// 					usr.StanceActive="Defensive"
				// 	verb/Evasive_Stance()
				// 		set hidden=1
				// 		if(usr.StyleBuff)
				// 			if("Evasive" in usr.StyleBuff.UnlockedStances)
				// 				if(usr.StanceActive!="Evasive")
				// 					OMsg(usr, "[usr] assumes the Evasive stance of [usr.StyleBuff]!")
				// 					usr.StanceActive="Evasive"
			Styles
				StyleSlot=1
				Style_Selector
					var/tmp/Selecting//Don't spam this.
					verb/Toggle_Style()
						set category="Skills"
						if(usr.StyleBuff)
							usr.StyleBuff.Trigger(usr)
							return
						if(src.Selecting)
							usr << "Stop trying to spam set a style."
							return
						src.Selecting=1
						var/list/obj/Skills/Buffs/NuStyle/Styles=list("Cancel")
						var/obj/Skills/Buffs/Selected
						for(var/obj/Skills/Buffs/NuStyle/s in usr)
							if(s.type==src.type)
								continue
							Styles.Add(s)
						if(Styles.len<2)
							usr << "You have no styles to use!"
							src.Selecting=0
							return
						Selected=input(usr, "What style would you like to use?", "Set Style") in Styles
						if(Selected=="Cancel")
							src.Selecting=0
							return
						Selected.Trigger(usr)
						src.Selecting=0