obj/Skills/Projectile
	RoaringCrescentWave
		Distance=40
		Cooldown=8
		ManaCost=2
		DamageMult=1.4
		Shearing=1
		StrScaling=0.5
		AccMult=100
		Piercing=1
		Dodgeable=-1
		ProjectileAfterimages=1
		Deflectable=-1
		IconLock='CrescentSlash.dmi'
		ActiveMessage="fires off a crescent wave!"
		IconSize=1
		NoGCD=1
		MaxCharges=3
		Charges=3
		ChargeRefresh=6
		adjust(mob/p)
			if(p.RoaringTempoCurrent >= 25)
				DamageMult=2.8
				Shearing=5
				StrScaling = 1.5
				p.RoaringTempoCurrent-=25
				p.RoaringTempoUpdate()
			else
				DamageMult=1.4
				Shearing=1
				StrScaling = 0.5
		verb/Roaring_Crescent_Wave()
			set category="Skills"
			set name="Roaring Crescent Wave"
			adjust(usr)
			usr.UseProjectile(src)




//Tempo Meter
#define RTEMPO_RSC 'RoaringTempo.dmi'


//Meters
obj/RoaringTempoMeterBase
	icon = RTEMPO_RSC
	screen_loc = "CENTER-0.8,BOTTOM+3.9"
	plane = FLOAT_PLANE
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE

	New()
		..()
		var/matrix/M = matrix()
		M.Scale(2, 2)
		transform = M

obj/RoaringTempoMeterBG
	parent_type = /obj/RoaringTempoMeterBase
	icon_state = "Background"
	layer = FLOAT_LAYER + 49


obj/RoaringTempoMeterStars
	parent_type = /obj/RoaringTempoMeterBase
	icon_state = "Star-1"
	layer = FLOAT_LAYER + 50


obj/RoaringTempoMeterFlames
	parent_type = /obj/RoaringTempoMeterBase
	icon_state = "Flames"
	layer = FLOAT_LAYER + 48


obj/RoaringTempoMeterSign
	parent_type = /obj/RoaringTempoMeterBase
	icon_state = "UseYourFuckingMeter"
	screen_loc = "CENTER+1.7,BOTTOM+3.2"
	layer = FLOAT_LAYER + 51





mob/var/tmp/obj/RoaringTempoMeterBG/MeterBG
mob/var/tmp/obj/RoaringTempoMeterStars/MeterStars
mob/var/tmp/obj/RoaringTempoMeterFlames/MeterFlames
mob/var/tmp/obj/RoaringTempoMeterSign/MeterSign



mob/proc/RoaringTempoCreate()
	if(src.client && !src.MeterBG)
		src.MeterBG = new
		src.client.screen += src.MeterBG

	if(src.client && !src.MeterStars)
		src.MeterStars = new
		src.client.screen += src.MeterStars

	if(src.client && !src.MeterFlames)
		src.MeterFlames = new
		src.client.screen += src.MeterFlames

	if(src.client && !src.MeterSign)
		src.MeterSign = new
		src.client.screen += src.MeterSign

mob/proc/RoaringTempoUpdate()
	if(!client)
		return

	if(!MeterBG || !MeterStars || !MeterSign || !MeterFlames)
		RoaringTempoCreate()

	MeterFlames.icon_state = "Flames"
	if(RoaringTempoCurrent <= 0)
		// Meter hidden
		MeterBG.alpha = 0
		MeterStars.alpha = 0
		MeterSign.alpha = 0
		MeterFlames.alpha = 0

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0

	else if(RoaringTempoCurrent < 25)
		MeterBG.alpha = 255
		MeterStars.alpha = 0
		MeterSign.alpha = 0
		MeterFlames.alpha = 0

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0

	else if(RoaringTempoCurrent < 50)
		MeterBG.alpha = 255
		MeterStars.alpha = 255
		MeterSign.alpha = 0
		MeterFlames.alpha = 0

		MeterStars.icon_state = "Star-1"

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0

	else if(RoaringTempoCurrent < 75)
		MeterBG.alpha = 255
		MeterStars.alpha = 255
		MeterSign.alpha = 0
		MeterFlames.alpha = 0

		MeterStars.icon_state = "Star-2"

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0

	else if(RoaringTempoCurrent < 100)
		MeterBG.alpha = 255
		MeterStars.alpha = 255
		MeterSign.alpha = 0
		MeterFlames.alpha = 255

		MeterStars.icon_state = "Star-3"

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0

	else
		MeterBG.alpha = 255
		MeterStars.alpha = 255
		MeterSign.alpha = 255
		MeterFlames.alpha = 255

		MeterStars.icon_state = "Star-4"
		MeterFlames.icon_state = "Flames2"

		MeterBG.invisibility = 0
		MeterStars.invisibility = 0
		MeterSign.invisibility = 0
		MeterFlames.invisibility = 0
		return


/strikeHook/roaringTempoAttacker
	stage = "post"
	fire(strike/S)
		var/mob/attacker = S.attacker
		var/val = S.defender.HPToPct(S.dealt)
		if((attacker.Saga=="Path of a Hero: Rebirth") && (attacker.FinalHeroChoice=="Roaring Knight"))
			var/meterGain = min(max(val*2,1), 5.0)
			attacker.RoaringTempoCurrent=min(attacker.RoaringTempoCurrent+meterGain, 100)
			attacker.RoaringTempoUpdate()
			attacker << "TempoAttacker Proc'd [attacker.RoaringTempoCurrent]/100"

/strikeHook/roaringTempoDefender
	stage = "post"
	fire(strike/S)
		var/mob/defender = S.defender
		var/val = S.defender.HPToPct(S.dealt)
		if((defender.Saga=="Path of a Hero: Rebirth") && (defender.FinalHeroChoice=="Roaring Knight"))
			var/meterGain = min(max(val*2,1), 5.0)
			defender.RoaringTempoCurrent=min(defender.RoaringTempoCurrent+meterGain, 100)
			defender.RoaringTempoUpdate()
