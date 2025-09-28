

mob
	proc
		TargetSkillX(var/wut, var/obj/Skills/Z)
			switch(wut)
				if("TargetSwitch")
					var/NewTarget
					var/NewTgtDist=25
					for(var/mob/m in oview(15,usr))
						if(m.client || (istype(m, /mob/Player/AI) && !istype(m, /mob/Player/AI/Nympharum)))
							if(m in usr.ai_followers) continue
							if(usr.party)
								if(usr.party.members)
									if(usr.inParty(m.ckey)) continue
							if(get_dist(usr,m)<NewTgtDist)
								NewTgtDist=get_dist(usr,m)
								NewTarget=m
					for(var/sb in src.SlotlessBuffs)
						var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
						if(b)
							if(b.TargetOverlay)
								var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
								im.transform*=b.OverlaySize
								usr.overlays-=im
								if(usr.Target)
									usr.Target.overlays-=im
					usr.SetTarget(NewTarget)
					for(var/sb in src.SlotlessBuffs)
						var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
						if(b)
							if(b.TargetOverlay)
								var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
								im.transform*=b.OverlaySize
								usr.Target.overlays+=im
					usr<<"You target [NewTarget]."
					if(usr.SpecialBuff)
						if(usr.SpecialBuff.BuffName=="Kyoukaken")
							usr.Kyoukaken("On")
					usr.AdaptationCounter=0
					usr.AdaptationTarget=null
					usr.AdaptationAnnounce=null

					Z.Cooldown()