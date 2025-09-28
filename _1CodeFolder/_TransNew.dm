mob
	var
		BaseBase
		BaseBaseX
		BaseBaseY
		Form1Base
		Form1BaseX
		Form1BaseY
		Form2Base
		Form2BaseX
		Form2BaseY
		Form3Base
		Form3BaseX
		Form3BaseY
		Form4Base
		Form4BaseX
		Form4BaseY
		Form1Hair
		Form1HairX
		Form1HairY
		Form2Hair
		Form2HairX
		Form2HairY
		Form3Hair
		Form3HairX
		Form3HairY
		Form4Hair
		Form4HairX
		Form4HairY
		Form1Aura
		Form1AuraX
		Form1AuraY
		Form2Aura
		Form2AuraX
		Form2AuraY
		Form3Aura
		Form3AuraX
		Form3AuraY
		Form4Aura
		Form4AuraX
		Form4AuraY
		Form1Overlay
		Form1OverlayX
		Form1OverlayY
		Form2Overlay
		Form2OverlayX
		Form2OverlayY
		Form3Overlay
		Form3OverlayX
		Form3OverlayY
		Form4Overlay
		Form4OverlayX
		Form4OverlayY
		Form1TopOverlay
		Form1TopOverlayX
		Form1TopOverlayY
		Form2TopOverlay
		Form2TopOverlayX
		Form2TopOverlayY
		Form3TopOverlay
		Form3TopOverlayX
		Form3TopOverlayY
		Form4TopOverlay
		Form4TopOverlayX
		Form4TopOverlayY
		Form1ActiveText
		Form2ActiveText
		Form3ActiveText
		Form4ActiveText
		Form1RevertText
		Form2RevertText
		Form3RevertText
		Form4RevertText
		BaseProfile
		Form1Profile
		Form2Profile
		Form3Profile
		Form4Profile

		Form5Base//Basically only used by changeling and SSjG
		Form5BaseX
		Form5BaseY
		Form5Hair//For SSjG and SSjR
		Form5HairX
		Form5HairY
		Form5Profile
		Form5Aura
		Form5AuraX
		Form5AuraY

mob/Admin3/verb
	Flash(var/mob/m)
		DarknessFlash(m)

proc/DarknessFlash(var/mob/Z, var/SetTime=0)
	set background=1
	var/Time
	if(!SetTime)
		Time=60
	else
		Time=SetTime
	for(var/mob/Players/T in players)
		if(T.z==Z.z)
			animate(T.client, color=list(0.5,0,0, 0,0.5,0, 0,0,0.5, 0,0,0), time = Time*0.5)
			spawn(Time*1.5)
				animate(T.client, color=null, time = Time*0.5)
mob/proc/isSaiyanHalfie()
	if(isRace(HALFSAIYAN))
		if(race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/dominating)
			return 1
	return 0


mob/proc/CanTransform()
	if(src.CyberCancel&&!isRace(ANDROID))
		return 0
	if(src.TotalFatigue>=90)
		src<<"You are too tired to transform!"
		return 0
	if(src.ActiveBuff)
		if(src.ActiveBuff.NeedsSSJ)
			src<<"Your ascended super state uses too much power to enter another level!"
			return 0
		if(src.ActiveBuff.NeedsTrans)
			src<<"Your ascended transformation uses too much power to enter another level!"
			return 0
	if(src.SpecialBuff)
		if(src.SpecialBuff.NeedsSSJ)
			src<<"Your ascended super state uses too much power to enter another level!"
			return 0
	for(var/b in SlotlessBuffs)
		var/obj/Skills/Buffs/sb = SlotlessBuffs[b]
		if(sb)
			if(sb.CantTrans)
				src << "Your buff doesn't allow you to transform!"
				return 0
			if(sb.NeedsSSJ)
				src<<"Your ascended super state uses too much power to enter another level!"
				return 0
			if(sb.NeedsTrans)
				src<<"Your ascended transformation uses too much power to enter another level!"
				return 0
	if(isRace(SAIYAN) || isSaiyanHalfie())
		if(length(race.transformations) >= 4 && race.transformations[4].type == /transformation/saiyan/super_saiyan_god)
			if(transActive+1 == 4 && race.transformations[4].first_time)
				// first time super saiyan god has special conditions
				var/num_of_saiyans = 0
				for(var/mob/player in party)
					if(num_of_saiyans>=4) break
					if(player == src)
						continue
					if((player.isRace(SAIYAN) || player.isRace(HALFSAIYAN)))
						if(player.Transfering && player.Transfering == src)
							num_of_saiyans++
				if(num_of_saiyans<4)
					src << "You can't transform into this form like that."
					return 0
		if(length(race.transformations) >= 4 && race.transformations[4].type == /transformation/saiyan/super_saiyan_4 && transActive+1 == 4)
			src << "You can't transform into this form like that."
			return 0
	return 1

mob/proc/CanRevert()
	if(src.CyberCancel&&!isRace(ANDROID))
		return 0
	if(src.HasNoRevert())
		return 0
	if(src.ActiveBuff)
		if(src.ActiveBuff.NeedsTrans||src.ActiveBuff.NeedsSSJ)
			src.ActiveBuff.Trigger(src)
	if(src.SpecialBuff)
		if(src.SpecialBuff.NeedsTrans||src.SpecialBuff.NeedsSSJ)
			src.SpecialBuff.Trigger(src)
	for(var/b in SlotlessBuffs)
		var/obj/Skills/Buffs/sb = SlotlessBuffs[b]
		if(sb)
			if(sb.NeedsTrans||sb.NeedsSSJ)
				sb.Trigger(src)
	return 1


//High Tension
mob/proc/HighTension(var/x)
	for(var/obj/Skills/Buffs/SpecialBuffs/High_Tension/T in src)
		T.current_tension = x
	var/image/tensiona=image('HTAura.dmi',pixel_x=-16, pixel_y=-4)
	var/image/tension=image('HighTension.dmi',pixel_x=-32,pixel_y=-32)
	var/image/tensionh=image(src.Hair_HT, layer=FLOAT_LAYER-1)
	var/image/tensionhs=image(src.Hair_SHT, layer=FLOAT_LAYER-1)
	var/image/tensione=image('EyesHT.dmi', layer=FLOAT_LAYER-2)
	tensiona.blend_mode=BLEND_ADD
	tension.blend_mode=BLEND_ADD
	tensionh.blend_mode=BLEND_ADD
	tensionh.alpha=200
	tensionhs.blend_mode=BLEND_ADD
	tensionhs.alpha=130
	sleep()
	if(x >= 100) x = 100
	else if(x >= 50) x = 50
	else if(x >= 20) x = 20
	tension=x
	src.Hairz("Remove")
	if(x==20)
		src.PowerBoost+=0.25
		src.EnergyExpenditure+=0.5//1.25
	if(x==50)
		src.PowerBoost+=0.5
		src.EnergyExpenditure+=1//1.5
	if(x>=100)
		src.PowerBoost+=1
		src.EnergyExpenditure+=2//2
	src.StrMultTotal+=0.25
	src.EndMultTotal+=0.25
	src.ForMultTotal+=0.25
	src.SpdMultTotal+=0.25
	OMsg(src, "<font color='#FF00FF'>[src] spikes their tension - [x]%!</font color>")
	if(x==100)
		OMsg(src, "<b><font color='#FF00FF'>[src] activated Super High Tension!!!</font color></b>")
	if(src.tension==20)
		src.Hairz("Add")
		src.overlays+=tension
	if(src.tension==50)
		src.overlays+=tensione
		src.Hairz("Add")
		src.overlays+=tensionh
		src.overlays+=tension
	if(src.tension==100)
		src.overlays+=tensione
		src.Hairz("Add")
		src.overlays+=tensionhs
		src.overlays+=tension
	src.underlays+=tensiona
	spawn(50)
		if(!src.HasKiControl()&&!src.PoweringUp)
			src.Auraz("Remove")

mob/proc/RevertHT()
	var/tension_reversion
	for(var/obj/Skills/Buffs/SpecialBuffs/High_Tension/T in src)
		tension_reversion = T.current_tension
	var/image/tensiona=image('HTAura.dmi',pixel_x=-16, pixel_y=-4)
	var/image/tension=image('HighTension.dmi',pixel_x=-32,pixel_y=-32)
	var/image/tensionh=image(src.Hair_HT, layer=FLOAT_LAYER-1)
	var/image/tensionhs=image(src.Hair_SHT, layer=FLOAT_LAYER-1)
	var/image/tensione=image('EyesHT.dmi', layer=FLOAT_LAYER-2)
	tensiona.blend_mode=BLEND_ADD
	tension.blend_mode=BLEND_ADD
	tensionh.blend_mode=BLEND_ADD
	tensionh.alpha=200
	tensionhs.blend_mode=BLEND_ADD
	tensionhs.alpha=130
	src.overlays-=tension
	src.overlays-=tensionh
	src.overlays-=tensionhs
	src.overlays-=tensione
	src.underlays-=tensiona
	if(tension_reversion==20)
		src.PowerBoost-=0.25
		src.EnergyExpenditure-=0.5
	if(tension_reversion==50)
		src.PowerBoost-=0.5
		src.EnergyExpenditure-=1
	if(tension_reversion==100)
		src.PowerBoost-=1
		src.EnergyExpenditure-=2
	src.StrMultTotal-=0.25
	src.EndMultTotal-=0.25
	src.ForMultTotal-=0.25
	src.SpdMultTotal-=0.25
	src.tension=0
	for(var/obj/Skills/Buffs/SpecialBuffs/High_Tension/T in src)
		T.current_tension = 0
	src.Hairz("Add")
	src.Auraz("Remove")

mob/proc/ChooseSuperAlien()
	var/Choice
	var/Confirm
	while(Confirm!="Yes")
		Choice=input(src, "What class of alien do you want to be?", "Alien Class") in list ("Brutality", "Harmony", "Ferocity", "Tenacity", "Equanimity", "Sagacity")
		switch(Choice)
			if("Brutality")
				Confirm=alert(src, "Brute aliens gain increased strength and agility.  Do you want to transform into one?", "Alien Class", "Yes", "No")
			if("Harmony")
				Confirm=alert(src, "Harmony aliens gain increase spiritual strength and slight increase in speed.  Do you want to transform into one?", "Alien Class", "Yes", "No")
			if("Ferocity")
				Confirm=alert(src, "Ferocious aliens gain increased offensive power in strength, spirit and agility.  Do you want to transform into one?", "Alien Class", "Yes", "No")
			if("Tenacity")
				Confirm=alert(src, "Tenacious aliens gain increased endurance and slight increase in physical strength.  Do you want to transform into one?", "Alien Class", "Yes", "No")
			if("Equanimity")
				Confirm=alert(src, "Equanimous aliens gain increased endurance and slight increase in spiritual focus.  Do you want to transform into one?", "Alien Class", "Yes", "No")
			if("Sagacity")
				Confirm=alert(src, "Sagacious aliens gain increased offensive power in strength, spirit and extra endurance.  Do you want to transform into one?", "Alien Class", "Yes", "No")
	race.transformations[1].TransClass=Choice

mob/proc/SuperAlienBase(var/x)
	switch(x)
		if(1)
			if(src.Form1Base)
				if(!src.BaseBase)
					src.BaseBase=src.icon
					src.BaseBaseX=src.pixel_x
					src.BaseBaseY=src.pixel_y
				src.icon=src.Form1Base
				src.pixel_x=src.Form1BaseX
				src.pixel_y=src.Form1BaseY


mob/proc/WeaponSoul() // OverSoul Mechanic
	var/obj/Items/Sword/s=src.EquippedSword()
	var/placement=FLOAT_LAYER-3
	if(s.LayerPriority)
		placement-=s.LayerPriority
	if(src.SagaLevel<6)
		return
	else
		switch(src.BoundLegend)
			if("Green Dragon Crescent Blade")
				Attunement = "Fire"
				InfusionElement = "Water"
				ElementalDefense = "Void"
				passive_handler.Increase("CounterMaster", 10)
				passive_handler.Increase("Extend")
				passive_handler.Increase("TechniqueMastery", 5)
				passive_handler.Increase("MovementMastery", 5)
				passive_handler.Increase("Mythical")
				src.OMessage(10, "<b><font color=red><center>The very air shakes, as [src.name] shakes the world with their yell of potent, overwhelming power!!</center></font></b>")
				Quake(10)
				KenShockwave(src,icon='fevKiai.dmi',Size=4)
				KenShockwave(src,icon='fevKiai.dmi',Size=3)
				KenShockwave(src,icon='fevKiai.dmi',Size=2)
				KenShockwave(src,icon='fevKiai.dmi',Size=1)
				spawn(10)
					src.OMessage(10, "<b><font color=red><center>The tides of War may try to be oppressed by others, but they'll crush all opposition under a relentless spear with the power to kill the very Heavens.</center></font></b>")

			if("Ryui Jingu Bang")
				Attunement = "Wind"
				InfusionElement = "Earth"
				passive_handler.Increase("CalmAnger")
				passive_handler.Increase("SweepingStrike")
				passive_handler.Increase("TripleStrike")
				passive_handler.Increase("MonkeyKing",2)
				src.OMessage(10, "<b><font color=yellow><center>The seal on the golden headband has been broken!</center></font></b>")
				var/image/i=image(icon='AvalonLight.dmi', pixel_x=-67, pixel_y=-3, loc=src)
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				i.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				i.blend_mode=BLEND_ADD
				world << i
				world << w
				animate(i, alpha=0)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,0.2))
				animate(w, alpha=255, time=10)
				sleep(10)
				animate(i, alpha=255, time=20)
				sleep(10)
				KenShockwave(src,icon='KenShockwaveGold.dmi',Size=0.5, Blend=2, Time=3)
				del w
				sleep(10)
				animate(i, alpha=0, time=30)
				src.OMessage(10, "<b><font color=yellow><center>The Monkey King has been released!</center></font></b>")
				spawn(30)
					del i
			if("Caledfwlch")
				src.ElementalDefense="Ultima"
				passive_handler.Increase("InjuryImmune")
				passive_handler.Increase("FatigueImmune")
				passive_handler.Increase("Siphon")
				src.Sheared=0
				src.HealWounds(50)
				src.HealHealth(50)
				src.HealFatigue(50)
				src.HealEnergy(50)
				src.HealMana(50)
				var/image/i=image(icon='AvalonLight.dmi', pixel_x=-67, pixel_y=-3, loc=src)
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				i.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				i.blend_mode=BLEND_ADD
				world << i
				world << w
				animate(i, alpha=0)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,0.2))
				animate(w, alpha=255, time=10)
				sleep(10)
				src.OMessage(10,"<b>The sun, breaking through all darkness, illuminates [src]...</b>")
				animate(i, alpha=255, time=20)
				sleep(10)
				src.OMessage(10,"<b>Calling upon the name 'AVALON!', they summon forth a legendary lost sheath!!!</b>","<font color=red>[src]([src.key]) used Avalon Mode.")
				KenShockwave(src,icon='KenShockwaveGold.dmi',Size=0.5, Blend=2, Time=3)
				del w
				sleep(10)
				src.OMessage(10,"<b>[src] becomes infused with innate healing; though they falter, they cannot be stopped!</b>")
				animate(i, alpha=0, time=30)
				spawn(30)
					del i
			if("Kusanagi")
				src.ElementalOffense="Wind"
				passive_handler.Increase("Godspeed", 2)
				passive_handler.Increase("Flicker", 2)
				passive_handler.Increase("Pursuer", 2)
				passive_handler.Increase("FluidForm")
				passive_handler.Increase("SweepingStrike")
				passive_handler.Increase("DoubleStrike")
				passive_handler.Increase("TripleStrike")
				var/i='Dark.dmi'
				var/j='Rain.dmi'
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
				var/image/w2=image(icon='MurakumoMode.dmi', pixel_x=-16, pixel_y=-16, loc=src, layer=EFFECTS_LAYER)
				animate(w2, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				for(var/turf/t in Turf_Circle(src, 15))
					sleep(-1)
					TurfShift(i, t, 190, src, MOB_LAYER+1)
				sleep(10)
				src.OMessage(10,"<b>Clouds converge upon [src], darkening the skies...</b>")
				spawn(3)
					for(var/turf/t in Turf_Circle(src, 15))
						sleep(-1)
						TurfShift(j, t, 180, src, MOB_LAYER+0.5)
				src.overlays+=image(icon='MurakumoMode.dmi', pixel_x=-16, pixel_y=-16)
				world << w2
				animate(w2, alpha=255, time=5)
				sleep(5)
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				del w
				sleep(10)
				src.OMessage(10,"<b>Calling upon the name 'Ame no Murakumo no Tsurugi', they invoke a mighty rainstorm...</b>","<font color=red>[src]([src.key]) used Murakumo Mode.")
				KenShockwave(src,icon='KenShockwaveGod.dmi',Size=0.5, Blend=2, Time=3)
				del w2
				src.Hairz("Add")
				src.overlays+=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.OMessage(10,"<b>[src] becomes swift as the wind; their strikes become countless like falling raindrops!</b>")
			if("Masamune")
				src.ElementalOffense="Light"
				src.ElementalDefense="Light"
				passive_handler.Increase("HolyMod", 10)
				passive_handler.Increase("CalmAnger")
				passive_handler.Increase("SpiritPower")
				var/i='brightday2.dmi'
				sleep(10)
				for(var/turf/t in Turf_Circle(src, 10))
					sleep(-1)
					TurfShift(i, t, 190, src, MOB_LAYER+1)
				src.OMessage(10,"<b>[src] commits their heart fully to the duty that must be performed...</b>","<font color=red>[src]([src.key]) used Misogi Mode.")
				sleep(10)
				src.OMessage(10,"<b>Calling upon the absolute ideal of purity, they fill the area with overpowering brightness...</b>","<font color=red>[src]([src.key]) used Misogi Mode.")
				sleep(10)
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.overlays-=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.Hairz("Add")
				src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.overlays+=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.OMessage(10,"<b>[src] stands as a righteous warden against all that plagues humanity!</b>")
			if("Durendal")
				src.ElementalOffense="Earth"
				passive_handler.Increase("Juggernaut")
				passive_handler.Increase("GiantForm")
				passive_handler.Increase("SpecialStrike")
				passive_handler.Increase("Persistence", 3)
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
				sleep(10)
				Quake(15)
				src.OMessage(10,"<b>[src] stands firmly, lifting the heavy blade in their hand...</b>")
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				Quake(35)
				src.OMessage(10,"<b>Calling upon the name 'Durendal the Endurer', they cause the earth to tremble...</b>","<font color=red>[src]([src.key]) used Paladin Mode.")
				KenShockwave(src,icon='KenShockwaveDivine.dmi',Size=0.5, Blend=2, Time=2)
				del w
				animate(src, transform=src.transform*=1.5, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=10)
				sleep(10)
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.overlays-=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.overlays+='PaladinMode.dmi'
				src.Hairz("Add")
				src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.overlays+=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				Quake(75)
				animate(src, color=null, time=1)
				src.OMessage(10,"<b>[src] becomes clad in regal armor, a symbol of unbreakable hope!</b>")

			if("Moonlight Greatsword")
				src.ElementalOffense="Water"
				passive_handler.Increase("CyberStigma", 6)
				passive_handler.Increase("SoulFire", 6)
				passive_handler.Increase("SpiritPower", 5)
				src.OMessage(10,"<b>[src]calls upon the full power of the celestial moon, becoming it's chosen Knight!...</b>")

			//UNHOLYS
			if("Soul Calibur")
				src.ElementalOffense="Water"
				src.ElementalDefense="Void"
				passive_handler.Increase("PureReduction", 6)
				passive_handler.Increase("Unstoppable")
				passive_handler.Increase("NoWhiff")
				passive_handler.Increase("AbsoluteZero")
				passive_handler.Increase("Erosion", 0.5)
				var/i='IceGround.dmi'
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
				for(var/turf/t in Turf_Circle(src, 10))
					sleep(-1)
					TurfShift(i, t, 190, src)
				sleep(10)
				src.OMessage(10,"<b>[src] calls upon the power of order...</b>")
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				src.OMessage(10,"<b>Taking up the name 'Elysium the Virtuous', they invoke absolute stillness...</b>","<font color=red>[src]([src.key]) used Elysium Mode.")
				KenShockwave(src,icon='KenShockwaveGod.dmi',Size=0.5, Blend=2, Time=3)
				del w
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.overlays+=image(icon='ElysiumMode.dmi')
				src.Hairz("Add")
				src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				sleep(5)
				src.OMessage(10,"<b>[src] embodies the ideals of their blade, commiting their soul to law!</b>")
			if("Soul Edge")
				src.ElementalOffense="Void"//eat stats
				passive_handler.Increase("TechniqueMastery",5)
				passive_handler.Increase("MovementMastery",5)
				passive_handler.Increase("Flicker",2)
				passive_handler.Increase("HellPower")
				var/i='LavaTile.dmi'
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
				for(var/turf/t in Turf_Circle(src, 10))
					sleep(-1)
					TurfShift(i, t, 190, src)
				sleep(10)
				src.OMessage(10,"<b>[src] entwines their life force with that of their cursed blade...</b>")
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				src.OMessage(10,"<b>Taking up the name 'Inferno the Night Terror', they invoke a hellish landscape...</b>","<font color=red>[src]([src.key]) used Inferno Mode.")
				KenShockwave(src,icon='DarkKiai.dmi',Size=1)
				KenShockwave(src,icon='DarkKiai.dmi',Size=3)
				KenShockwave(src,icon='DarkKiai.dmi',Size=5)
				del w
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.Hairz("Add")
				sleep(5)
				src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				src.OMessage(10,"<b>[src] invokes the spirit of chaos through their own body!</b>")
			if("Muramasa")
				src.ElementalOffense="Fire"
				passive_handler.Increase("LifeSteal", 100)
				passive_handler.Increase("EnergySteal", 60)
				passive_handler.Increase("WeaponBreaker")
				passive_handler.Increase("CursedWounds")
				passive_handler.Increase("DarknessFlame")
				passive_handler.Increase("AbyssMod",2)
				var/i='amaterasu.dmi'
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
				for(var/turf/t in Turf_Circle(src, 5))
					sleep(-1)
					TurfShift(i, t, 190, src)
				sleep(10)
				src.OMessage(10,"<b>[src] cuts out what remaining restraint they have with their cursed sword...</b>")
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				src.OMessage(10,"<b>Calling upon their insatiable bloodlust, they fill the air with miasma of death...</b>","<font color=red>[src]([src.key]) used Deathbringer Mode.")
				KenShockwave(src,icon='KenShockwavePurple.dmi',Size=0.5, Blend=2, Time=3)
				del w
				src.overlays-=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.overlays+=image(icon='DeathbringerMode.dmi')
				src.Hairz("Add")
				src.overlays+=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.overlays+=image(icon='DarknessGlow.dmi', pixel_x=-32, pixel_y=-32)
				sleep(5)
				src.OMessage(10,"<b>[src] invokes the spirit of destruction through their blade!</b>")
			if("Dainsleif")
				src.ElementalOffense="Poison"//This already has cursed wounds, so it will become hyper murder poison.
				passive_handler.Increase("MortalStrike")
				passive_handler.Increase("HardStyle", 2)
				passive_handler.Increase("DeathField", 2)
				passive_handler.Increase("SoulSteal")
				var/i='Dark.dmi'
				var/j='BloodRain.dmi'
				var/image/w=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src, layer=EFFECTS_LAYER)
				animate(w, alpha=0, color=list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
				var/image/w2=image(icon='NibelungMode.dmi', pixel_x=-32, pixel_y=-32, loc=src, layer=EFFECTS_LAYER)
				animate(w2, alpha=0, color=list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
				world << w
				animate(w, alpha=255, time=10)
				sleep(10)
				for(var/turf/t in Turf_Circle(src, 15))
					sleep(-1)
					TurfShift(i, t, 190, src, MOB_LAYER+1)
				sleep(10)
				src.OMessage(10,"<b>The skies weep bloody tears as [src] takes upon the ultimate oath...</b>")
				spawn(3)
					for(var/turf/t in Turf_Circle(src, 15))
						sleep(-1)
						TurfShift(j, t, 180, src, MOB_LAYER+0.5)
				src.overlays+=image(icon='NibelungMode.dmi', pixel_x=-32, pixel_y=-32)
				world << w2
				animate(w2, alpha=255, time=5)
				sleep(5)
				src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
				del w
				sleep(10)
				src.OMessage(10,"<b>Calling upon the names of their ancestors, they vow a bloody vengance against the world...</b>","<font color=red>[src]([src.key]) used Nibelung Mode.")
				KenShockwave(src,icon='KenShockwaveBloodlust.dmi',Size=0.5, Blend=2, Time=3)
				del w2
				src.Hairz("Add")
				src.overlays+=image(icon=src.ActiveBuff.IconLock, pixel_x=src.ActiveBuff.LockX, pixel_y=src.ActiveBuff.LockY)
				src.OMessage(10,"<b>[src] becomes the incarnate of ruin, ready to slay all who oppose!</b>")
		src.Auraz("Add")
		spawn(50)
			if(!src.HasKiControl()&&!src.PoweringUp)
				src.Auraz("Remove")
		src.Stasis=0


mob/proc/RevertWS()
	var/obj/Items/Sword/s=src.EquippedSword()
	var/placement=FLOAT_LAYER-3
	if(s.LayerPriority)
		placement-=s.LayerPriority
	switch(src.BoundLegend)
		if("Ryui Jingu Bang")
			Attunement = null
			InfusionElement = null
			passive_handler.Decrease("CalmAnger")
			passive_handler.Decrease("SweepingStrike")
			passive_handler.Decrease("TripleStrike")
			passive_handler.Decrease("MonkeyKing",2)
		if("Green Dragon Crescent Blade")
			Attunement = null
			InfusionElement = null
			ElementalDefense = null
			passive_handler.Decrease("CounterMaster",10)
			passive_handler.Decrease("Extend")
			passive_handler.Decrease("TechniqueMastery", 5)
			passive_handler.Decrease("MovementMastery", 5)
			passive_handler.Decrease("Mythical")
		if("Caledfwlch")
			src.ElementalDefense=null
			passive_handler.Decrease("InjuryImmune")
			passive_handler.Decrease("FatigueImmune")
			passive_handler.Decrease("Siphon")
		if("Kusanagi")
			src.ElementalOffense=null
			passive_handler.Decrease("Godspeed",2)
			passive_handler.Decrease("Flicker", 2)
			passive_handler.Decrease("Pursuer", 2)
			passive_handler.Decrease("FluidForm")
			passive_handler.Decrease("SweepingStrike")
			passive_handler.Decrease("DoubleStrike")
			passive_handler.Decrease("TripleStrike")
			src.overlays-=image(icon='MurakumoMode.dmi', pixel_x=-16, pixel_y=-16)
			src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)
		if("Masamune")
			src.ElementalOffense=null
			src.ElementalDefense=null
			passive_handler.Decrease("HolyMod", 10)
			passive_handler.Decrease("CalmAnger")
			passive_handler.Decrease("SpiritPower")
		if("Durendal")
			src.ElementalOffense=null
			passive_handler.Decrease("Juggernaut")
			passive_handler.Decrease("GiantForm")
			passive_handler.Decrease("SpecialStrike")
			passive_handler.Decrease("Tenacity", 3)
			src.overlays-='PaladinMode.dmi'
			src.transform/=1.5
		if("Soul Calibur")
			src.ElementalOffense=null
			src.ElementalDefense=null
			passive_handler.Decrease("PureReduction", 6)
			passive_handler.Decrease("Unstoppable", 1)
			passive_handler.Decrease("NoWhiff")
			passive_handler.Decrease("AbsoluteZero")
			passive_handler.Decrease("Erosion", 0.5)
			src.overlays-=image(icon='ElysiumMode.dmi')
		if("Soul Edge")
			src.ElementalOffense=null
			src.ElementalDefense=null
			passive_handler.Decrease("TechniqueMastery", 5)
			passive_handler.Decrease("MovementMastery", 5)
			passive_handler.Decrease("Flicker", 2)
			passive_handler.Decrease("HellPower")
		if("Muramasa")
			src.ElementalOffense=null
			passive_handler.Decrease("LifeSteal", 100)
			passive_handler.Decrease("EnergySteal", 60)
			passive_handler.Decrease("WeaponBreaker", 1)
			passive_handler.Decrease("CursedWounds", 1)
			passive_handler.Decrease("AbyssMod", 2)
			src.overlays-=image(icon='DarknessGlow.dmi', pixel_x=-32, pixel_y=-32)
			src.overlays-=image(icon='DeathbringerMode.dmi')
		if("Dainsleif")
			src.ElementalOffense=null
			passive_handler.Decrease("MortalStrike")
			passive_handler.Decrease("HardStyle")
			passive_handler.Decrease("DeathField",2)
			passive_handler.Decrease("SoulSteal")
			src.overlays-=image(icon='NibelungMode.dmi', pixel_x=-32, pixel_y=-32)
			src.overlays+=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, layer=placement)


mob/proc/Jaganshi()
	src.JaganBase=src.JaganPowerNerf
	src.JaganPowerNerf=round(1.5**src.JaganPowerNerf,0.1)

mob/proc/RevertJaganshi()
	src.JaganPowerNerf=src.JaganBase

mob/proc/Shockwave(var/icon/E,var/Q=1, var/x1=0, var/y1=0)
	set waitfor=0
	set background=1
	spawn()new/shockwave(\
	locate(src.x-x1,src.y-y1,src.z),
	E,
	Ticks=10*sqrt(Q),
	Speed=20*Q,
	Amount=20*Q,
	StopAtObj=0,
	Source=src)