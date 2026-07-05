/obj/Skills/Buffs/SlotlessBuffs
	RoyalGuard
		SignatureTechnique=2
		Cooldown = 45
		SuccessfulParry = 1
		PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
		KenWave=1
		Mastery=1
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
		WindUp=0.75
		IgnoreWindUpReduction=1
		WindupMessage="gathers all the stored power into a brutal strike..."
		DamageMult=1
		StrOffense=1
		ActiveMessage="releases all gathered might into a single blow!"
		Area="Circle"
		GuardBreak=1
		HitSparkX=-14
		HitSparkY=-12
		HitSparkSize=2
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

/client/var/tmp/obj/rgMeterHolderNorm = new()
/client/var/tmp/obj/rgMeterHolderOutlines = new()

/client/proc/updateRGMeter()
	var/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard/RG = locate(/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard) in mob.contents
	if(RG)
		if(rgMeterHolderNorm)
			if(!(rgMeterHolderNorm in screen))
				rgMeterHolderNorm.screen_loc = "RIGHT-0.72,BOTTOM+1.40"

				screen += rgMeterHolderNorm
				screen += rgMeterHolderOutlines
				rgMeterHolderOutlines.screen_loc = "RIGHT-0.70,BOTTOM+1.38"

			rgMeterHolderNorm.maptext = "<font color= 'red'>[round(RG.RoyalMeter,0.01)]/[100+RG.Mastery-1]</font>"
			rgMeterHolderOutlines.maptext = "<font color= 'white'>[round(RG.RoyalMeter,0.01)]/[100+RG.Mastery-1]</font>"
			rgMeterHolderNorm.maptext_width = 400
			rgMeterHolderOutlines.maptext_width = 400