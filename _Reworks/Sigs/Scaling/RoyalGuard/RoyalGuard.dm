/obj/Skills/Buffs/SlotlessBuffs
	RoyalGuard
		SignatureTechnique=2
		Cooldown = 45
		SuccessfulParry = 1
		PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
		KenWave=1
		MenuIcon="RoyalGuard"
		Mastery=1
		UICustomDescription="Activate to put up a special guard that nullifies all damage for one second.<br>Damage cancelled this way adds to your Royal Meter, and consumed with Royal Release.<br>Cooldown on failure to parry is 45 seconds, 5 on a success.<br>Mastery increases the maximum of the gauge, from 100% to 200%."
		KenWaveBlend=2
		ActiveMessage="puts up their guard!!!"
		OffMessage="drops their guard."
		KenWaveIcon='KenShockwaveBloodlust.dmi'
		TimerLimit = 1
		passives = list("RoyalGuarding" = 1, "NoDodge" = 1)
		verb/Royal_Guard()
			set category = "Skills"
			SuccessfulParry = 1
			adjust(usr)
			src.Trigger(usr)
/obj/Skills/AutoHit
	RoyalRelease
		SignatureTechnique=2
		Distance=12
		MenuIcon="RoyalRelease"
		WindUp=0.75
		IgnoreWindUpReduction=1
		WindupMessage="gathers all the stored power into a brutal strike..."
		DamageMult=1
		StrScaling=1
		ActiveMessage="releases all gathered might into a single blow!"
		Area="Circle"
		GuardBreak=1
		HitSparkX=-14
		HitSparkY=-12
		HitSparkSize=2
		UICustomDescription="Expend all of your Royal Meter to deal damage.<br>Successfully parrying with Royal Guard, and then immediately using Royal Release before your Guard drops, procs a Perfect Release, which increase your damage by x1.5."
		Knockback=2
		HitSparkIcon='Black_Flash_Hitspark_1.dmi'
		HitSparkTurns=1
		HitSparkSize=4
		Earthshaking=2
		Cooldown=60
		EnergyCost=15
		Instinct=1
		adjust(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard/RG = locate(/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard) in p.contents
			if(RG)
				usr << "Using [RG.RoyalMeter] for Royal Release."
				if(RG.SuccessfulParry >= 2)
					WindupMessage="reverse the momentum of the opponent's strike, and-!!"
					ActiveMessage="lands a Perfect Release!!!!!!"
					Knockback=10
					Earthshaking=15
					if(RG.Mastery < 101)
						RG.Mastery+=1
						usr << "Your Mastery of Royal Guard increased to [RG.Mastery]!"
					DamageMult=((RG.RoyalMeter*1.5)*glob.ROYAL_GUARD_DMG_MULT)
					RG.RoyalMeter = 0
					usr.client.updateRGMeter()
				else
					WindupMessage="gathers all the stored power into a brutal strike..."
					ActiveMessage="releases all gathered might into a single blow!"
					DamageMult=RG.RoyalMeter*glob.ROYAL_GUARD_DMG_MULT
					Knockback=2
					Earthshaking=2
					RG.RoyalMeter = 0
					usr.client.updateRGMeter()


		verb/Royal_Release()
			set category="Skills"
			usr.Activate(src)


var/global/list/RGMeterIconCache = list()

proc/RGMeterFillIcon(percent, fill_state = "100")
	percent = min(max(round(percent), 0), 100)
	var/key = "[fill_state]-[percent]"
	if(RGMeterIconCache[key]) return RGMeterIconCache[key]
	var/icon/I = icon('RoyalGuardMeter.dmi', fill_state)
	var/w = I.Width()
	var/h = I.Height()
	var/cx = (w + 1) / 2
	var/cy = (h + 1) / 2
	if(percent <= 0)
		I.DrawBox(null, 1, 1, w, h)
	else if(percent < 100)
		var/fill_angle = percent * 3.6
		for(var/px = 1, px <= w, px++)
			for(var/py = 1, py <= h, py++)
				var/angle = 90 - arctan(px - cx, py - cy)
				if(angle < 0) angle += 360
				if(angle >= fill_angle)
					I.DrawBox(null, px, py)
	RGMeterIconCache[key] = I
	return I

obj/RGMeter
	Click()
		if(usr && usr.client)
			usr.client.updateRGMeter() //this was a debug thing to click the meter to update it, need mouse opacity to 2, setting it to 0

/client/var/tmp/obj/RGMeter/rgMeterHolderNorm = new()
/client/var/tmp/obj/RGMeter/rgMeterHolderOutlines = new()

/client/proc/updateRGMeter()
	if(!mob) return
	var/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard/RG = locate(/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard) in mob.contents
	if(!RG)
		screen -= rgMeterHolderNorm
		screen -= rgMeterHolderOutlines
		return
	if(!rgMeterHolderNorm) rgMeterHolderNorm = new()
	if(!rgMeterHolderOutlines) rgMeterHolderOutlines = new()
	if(!(rgMeterHolderNorm in screen))
		rgMeterHolderNorm.screen_loc = "CENTER+9,BOTTOM+0.7"
		rgMeterHolderOutlines.screen_loc = rgMeterHolderNorm.screen_loc
		rgMeterHolderNorm.plane = HUD_PLANE
		rgMeterHolderOutlines.plane = HUD_PLANE
		rgMeterHolderNorm.layer = 2
		rgMeterHolderOutlines.layer = 1
		rgMeterHolderNorm.mouse_opacity = 0
		rgMeterHolderOutlines.mouse_opacity = 0
		rgMeterHolderNorm.maptext = ""
		rgMeterHolderOutlines.maptext = ""
		rgMeterHolderOutlines.icon = 'RoyalGuardMeter.dmi'
		rgMeterHolderOutlines.icon_state = "Back"
		screen += rgMeterHolderOutlines
		screen += rgMeterHolderNorm
	var/meter = min(max(RG.RoyalMeter, 0), 200)
	rgMeterHolderOutlines.icon_state = "Back"
	rgMeterHolderNorm.overlays.Cut()
	rgMeterHolderNorm.icon = RGMeterFillIcon(min(meter, 100), "100")
	rgMeterHolderNorm.icon_state = ""
	if(meter > 100)
		var/image/overflow = image(icon = RGMeterFillIcon(meter - 100, "200"))
		rgMeterHolderNorm.overlays += overflow