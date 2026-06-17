//t1 path buffs
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Heart
	TooMuchHealth = 100
	NeedsHealth=99
	PowerMult=1.15
	StrMult=1.15
	ForMult = 1.15
	EndMult = 1.35
	Cooldown = 1
	adjust(mob/p)
		if(altered) return
		passives = list("Tenacity" = round(p.Potential/5,1), "Harden" = round(p.Potential/20,1))
		PowerMult=1.15
		StrMult=1.15
		ForMult = 1.15
		EndMult = 1.35
		EndMult += (p.Potential/200)
		StrMult += (p.Potential/300)
		ForMult += (p.Potential/300)
		PowerMult = 1.15 + (p.Potential/200)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Soul
	TooMuchHealth = 100
	NeedsHealth=99
	PowerMult=1.15
	StrMult=1.25
	ForMult = 1.15
	SpdMult=1.35
	RecovMult=1.25
	Cooldown = 1
	adjust(mob/p)
		if(altered) return
		passives = list("Instinct" = round(p.Potential/20,1), "Pursuer" = round(p.Potential/20,1))
		PowerMult=1.15
		StrMult=1.25
		ForMult = 1.15
		SpdMult=1.35
		RecovMult=1.25
		SpdMult += (p.Potential/150)
		StrMult += (p.Potential/250)
		ForMult += (p.Potential/250)
		PowerMult = 1.15 + (p.Potential/200)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Prismatic_Hero
	TooMuchHealth = 100
	NeedsHealth=99
	PowerMult=1.1
	StrMult=1.1
	EndMult = 1.1
	ForMult = 1.1
	SpdMult=1.15
	RecovMult=1.5
	Cooldown = 1
	adjust(mob/p)
		if(altered) return
		passives = list("FluidForm" = round(p.Potential/20,1), "LikeWater" = round(p.Potential/20,1)) //cat joke
		StrMult=1.1
		EndMult = 1.1
		ForMult = 1.1
		SpdMult=1.15
		SpdMult += (p.Potential/250)
		StrMult += (p.Potential/250)
		ForMult += (p.Potential/250)
		EndMult += (p.Potential/250)
		PowerMult = 1.1 + (p.Potential/230)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
//t2 path buffs. all one of them
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dont_Stop_Me_Now //first act
	PowerMult=1.15
	StrMult=1.15
	EndMult = 1.15
	ForMult=1.15
	SpdMult=1.15
	Cooldown = 1
	AwakeningRequired=1
	passives = list("BuffMastery" = 1,"KiControlMastery" =1, "TechniqueMastery"=1)
//HE'S GOTTA BE STRONG AND HE'S GOTTA BE FAST AND HE'S GOTTA BE FRESH FROM THE NIGHT
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Temporary_Hero_Heart
	ActiveMessage="awakens a heroic heart!"
	PowerMult=1.15
	StrMult=1.15
	ForMult = 1.15
	EndMult = 1.5
	Cooldown = 1
	TimerLimit = 30
	passives = list("Tenacity" = 1, "Harden" = 1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Temporary_Hero_Soul
	ActiveMessage="awakens a heroic soul!"
	PowerMult=1.15
	StrMult=1.25
	ForMult = 1.15
	SpdMult=1.35
	RecovMult=1.25
	Cooldown = 1
	TimerLimit = 30
	passives = list("Instinct" = 1, "Pursuer" = 1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Temporary_Hero_Heart
	ActiveMessage="awakens a heroic heart!"
	PowerMult=1.15
	StrMult=1.15
	ForMult = 1.15
	EndMult = 1.5
	AlwaysOn = 1
	TimerLimit = 30
	passives = list("Tenacity" = 1, "Harden" = 1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Temporary_Hero_Soul
	ActiveMessage="awakens a heroic soul!"
	PowerMult=1.15
	StrMult=1.25
	ForMult = 1.15
	SpdMult=1.35
	RecovMult=1.25
	AlwaysOn = 1
	TimerLimit = 30
	passives = list("Instinct" = 1, "Pursuer" = 1)
//t3 path buffs
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shining_Star
	TooMuchHealth = 100
	NeedsHealth=99
	StrMult=1.25
	SpdMult=1.15
	Cooldown = 1
	passives = list("Pursuer" = 1,"KiControlMastery" =1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Unwavering_Soul
	TooMuchHealth = 100
	NeedsHealth=99
	StrMult=1.35
	EndMult = 1.5
	Cooldown = 1
	passives = list("Unstoppable" =1)
	adjust(mob/p)
		BioArmor=0
		VaizardHealth = (50 * (p.Potential/100))
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Of_Chaos
	TooMuchHealth = 100
	NeedsHealth=99
	AngerPoint=65
	RecovMult=1.75
	Cooldown = 1
	passives = list("FluidForm" = 1, "Controlled Chaos" = 1)

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Axe_of_Justice
	TooMuchHealth = 100
	NeedsHealth=99
	EndMult = 1.25
	ForMult=1.5
	Cooldown = 1
	passives = list("Neverending Hope" = 1, "Unstoppable" =1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/We_Are_The_Champions //second act
	StrMult=1.1
	EndMult = 1.1
	ForMult=1.1
	SpdMult=1.15
	Cooldown = 1
	AwakeningRequired=2
	passives = list("BuffMastery" = 2,"KiControlMastery" =1, "TechniqueMastery"=1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/The_Blue_Experience //second act
	ActiveMessage="burns brighter than they should."
	SpdMult=1.5
	Cooldown = 1
	TimerLimit=300
	HealthDrain = 0.05
	passives = list("BuffMastery" = 3,"Pursuer" =2, "Godspeed"=2)
//t4 path buffs
obj/Skills/Buffs/SlotlessBuffs/Autonomous/The_Show_Must_Go_On //third act
	StrMult=1.25
	EndMult = 1.25
	ForMult=1.25
	SpdMult=1.25
	Cooldown = 1
	AwakeningRequired=3
	TimerLimit=300
	passives = list("BuffMastery" = 3,"KiControlMastery" =1, "TechniqueMastery"=1)
obj/Skills/Buffs/SlotlessBuffs/Autonomous/Burning_Soul
	ActiveMessage="transforms their passion into fury, their desire to win surpassing all."
	Cooldown = 1
	AwakeningRequired=1
	TimerLimit=300
	passives = list("Red Hot Rage" = 1, "Wrathful" = 1)
//debuffs
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Rebirth/Dissociation
	ActiveMessage="doesn't appear to be all there."
	passives = list("BuffMastery" = -1, "Flow" = -2, "Instinct" = -2)
	SlowAffected = 1
	TimerLimit = 6000
	Cooldown = 4
	AlwaysOn = 1
	IconLock = 'SweatDrop.dmi'
obj/Skills/AutoHit
	var/IsSnowgrave
	var/HahaWhoops
	var/RandomMult
	MakeItCount
		Area="Strike"
		AwakeningSkill=1
		Cooldown=-1
		ActNumber=3
		StrOffense=1
		Rush=10
		SpecialAttack=1
		CanBeDodged=0
		CanBeBlocked=1
		DamageMult=40
		Stunner=3
		Knockback=0
		WindUp=0.5
		ComboMaster=1
		WindupIcon='Chidori.dmi'
		WindupMessage="vibrates their hand quickly enough to create blue static electricity, all of which focusing into a tiny point within their palm."
		ActiveMessage="bets their future on this one attack!"
		Icon='Chidori.dmi'
		HitSparkIcon='Hit Effect Vampire.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkSize=1
		ControlledRush=1
		Instinct=1
		verb/Make_It_Count()
			set category="Skills"
			set name="Make It Count (Act 3)"
			usr.Activate(src)
			usr.TriggerAwakeningSkill(ActNumber)
	Snowgrave
		ElementalClass="Water"
		ForOffense=1.5
		SpecialAttack=1
		GuardBreak=1
		DamageMult=1500
		Chilling=150
		Stasis=5
		TurfShift='IceGround.dmi'
		Distance=15
		WindUp=0.5
		IsSnowgrave=1
		WindupMessage="casts a spell they don't know.."
	//	ActiveMessage="freezes the area with a destructive chill!"
		Cooldown=90
		Area="Target"
		verb/Snowgrave()
			set category="Skills"
			usr.RebirthHeroType="Yellow"
			if(!altered)
				DamageMult = 600
			usr.Activate(src)
	NeverSeeItComing
		SpecialAttack=1
		GuardBreak=1
		DamageMult=1
		StrOffense=1
		TurfShift='IceGround.dmi'
		Distance=15
		WindUp=0.5
		WindupMessage="casts a spell that nobody can see coming."
		HahaWhoops=1
		ActNumber=1
		Cooldown=-1
	//	Area="Target"
		adjust(mob/p)
			src.DamageMult=rand(1,10)
			Cooldown=-1
		verb/Never_See_It_Coming()
			set category="Skills"
			set name="Never See It Coming (Act 1)"
			adjust(usr)
			usr.Activate(src)
			usr.TriggerAwakeningSkill(ActNumber)
	PowerWordGenderDysphoria
		Area="Target"
		AdaptRate = 1
		Cooldown=-1
		DamageMult = 5
		Distance = 15
		DelayTime = 0
		HitSparkIcon = 'BLANK.dmi'
		TurfDirt = 1
		ShockIcon = 'Icons/NSE/spells/cast/KrysiaHitspark2.dmi'
		Shockwave = 4
		Shockwaves = 1
		PostShockwave = 1
		PreShockwave = 0
		ActNumber=2
		AwakeningSkill=1
		WindupMessage="foreshadows their imminent future, maybe."
		ActiveMessage = "gives the target a perspective on life that they didn't ask for."
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Rebirth/Dissociation"
		verb/GenderDysphoria()
			set category="Skills"
			set name="Power Word: Gender Dysphoria (Act 2)"
			usr.Activate(src)
			usr.TriggerAwakeningSkill(ActNumber)
	Unleash
		ManaCost=75
		StrOffense=0
		ForOffense=1
		HolyMod=40
		DamageMult=15
		Area="Circle"
		Distance=3
		TurfErupt=2
		TurfEruptOffset=3
//		Slow=1
//		WindUp=1
		WindupIcon='Ripple Radiance.dmi'
		WindupIconUnder=1
		WindupIconX=-32
		WindupIconY=-32
		WindupIconSize=1.3
		Divide=1
		PullIn=25
		WindupMessage="glows with a certain power..."
		ActiveMessage="unleashes a blinding flash of holy light!"
		HitSparkIcon='BLANK.dmi'
		HitSparkX=0
		HitSparkY=0
		adjust(mob/p)
			if(p.passive_handler.Get("Determination(White)"))
				src.ManaCost=40
		verb/Unleash()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)
	Banish
		ManaCost=100
		ElementalClass="Water"
		SagaSignature=1
		SignatureTechnique=2
		Cooldown=9000
		SignatureName="Banish"
		Area="Target"
		Distance=15
		HolyMod=2000
		DamageMult=30
		WindUp=1
		HitSparkIcon='Hit Effect Pearl.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=5
		HitSparkCount=10
		HitSparkDispersion=1
		ForOffense=1
		SpecialAttack=1
		adjust(mob/p)
			if(p.passive_handler.Get("Shatter Fate"))
				Cooldown=1
				ManaCost=20
		verb/Banish()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)
	Burning_Up_Everything
		StrOffense=0
		ForOffense=1
		DamageMult=14
		HealthCost=3
		Area="Circle"
		Distance=8
		TurfErupt=2
		TurfEruptOffset=3
		Scorching = 30
		Slow=1
		WindUp=1
		WindupIcon='Ripple Radiance.dmi'
		WindupIconUnder=1
		WindupIconX=-32
		WindupIconY=-32
		WindupIconSize=1.3
		Divide=1
		PullIn=25
		WindupMessage="sets their heart ablaze..."
		ActiveMessage="burns up everything around them!"
		HitSparkIcon='BLANK.dmi'
		HitSparkX=0
		HitSparkY=0
		Cooldown=3600

		Earthshaking=15
		PreQuake=1
		verb/Burning_Up_Everything()
			set category="Skills"
			usr.Activate(src)
	Scream_of_Fury
		Area="Circle"
		Distance=10
		RedTechnique=1
		AdaptRate = 1
		GuardBreak=1
		DamageMult=6
		PullIn=15
		Cooldown=120
		NeedsHealth=50
		Shockwaves=3
		Shockwave=4
		SpecialAttack=1
		Stunner=3
		HitSparkIcon='BLANK.dmi'
		HitSparkX=0
		HitSparkY=0
		ActiveMessage="lets loose a furious roar!"
		adjust(mob/p)
			if(altered) return
			if(p.passive_handler.Get("Red Hot Rage"))
				Cooldown=10
				RedPUSpike=pick(25, 50)
				DamageMult=5
				ActiveMessage="screams so fucking loud that you start to worry about their mental health. Are they okay?"
				p.passive_handler.Increase("RedPUSpike", RedPUSpike)
				p.WeirdAngerStuff()
			else
				Cooldown=150
				RedPUSpike=0
		verb/Scream_of_Fury()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)
	HorrifyingRoar
		Area="Circle"
		ManaCost=100
		Distance=10
		RedTechnique=1
		AdaptRate = 1
		GuardBreak=1
		DamageMult=15
		PullIn=15
		Cooldown=40
		Stunner=4
		ComboMaster=1
		Shockwaves=3
		Shockwave=4
		SpecialAttack=1
		Stunner=3
		HitSparkIcon='BLANK.dmi'
		HitSparkX=0
		HitSparkY=0
		ShockIcon='KenShockwave.dmi'
		ActiveMessage="lets loose a horrifying roar!"
		adjust(mob/p)
			if(altered) return
		verb/Horrifying_Roar()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)
	Platinum_Mad
		StrOffense=1
		ForOffense=1
		DamageMult=3
		Area="Circle"
		Distance=12
		TurfErupt=2
		TurfEruptOffset=3
		Scorching = 30
		Slow=1
		WindUp=4
		WindupIcon='Amazing SSj4 Aura.dmi'
		WindupIconX=-32
		WindupIconY=32
		WindupIconSize=2
		Divide=1
		PullIn=25
		WindupMessage="needs just a little more time!"
		ActiveMessage="burns up everything around them, including themselves!"
		HitSparkIcon='BLANK.dmi'
		HitSparkX=0
		HitSparkY=0
		Cooldown=-1
	//	Cooldown=30
		Earthshaking=15
		PreQuake=1
		PlatinumMad=1
		verb/Platinum_Mad()
			set category="Skills"
			set hidden=1
			src.RebirthLastUse=world.realtime
			usr.Activate(src)
mob/proc/TriggerAwakeningSkill(ActNumber)
	if(ActNumber>=1)
		src<< "<b>Fate turns its eye to you, watching with interest.</b>"
		src.AwakeningSkillUsed=1
		src.buffSelf(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dont_Stop_Me_Now)
	if(ActNumber>=2)
		src<< "<b>You hear the scratching of pen to paper, your story being recorded.</b>"
		src.AwakeningSkillUsed=2
		src.buffSelf(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/We_Are_The_Champions)
	if(ActNumber>=3)
		src<< "<b>The book closes on this chapter. Yet, surely, there is more to be told.</b>"
		src.AwakeningSkillUsed=3
		src.buffSelf(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/The_Show_Must_Go_On)
obj/Skills
	var/AwakeningSkill
	var/ActNumber
	var/RebirthLastUse
	var/RedTechnique
	var/RedPUSpike
	var/PlatinumMad
obj/Skills/Queue
	var/RandomMult
	HoldingOutForAHero
		ManaCost=100
		Cooldown=1
		var/buffpicked
		icon_state="Heal"
		Copyable=3
		HarderTheyFall=3
		Opener=1
		Duration=5
		ActiveMessage="strikes with a desire for heroism in her heart!"
		DamageMult=4
		AccuracyMult=1.1
		InstantStrikes=4
		InstantStrikesDelay=1.5
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Temporary_Hero_Heart"
		desc="Randomly cast Hero Heart or Hero Soul on yourself."
		adjust(mob/p)
			if(prob(50))
				src.BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Temporary_Hero_Heart"
			else
				src.BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Temporary_Hero_Soul"
		verb/HoldingOutForAHero()
			set name="Holding Out For a Hero"
			set category="Skills"
			adjust(usr)
			usr.SetQueue(src)
	NeverKnowsBest
		Copyable=0
		ActNumber=1
		AwakeningSkill=1
		HitMessage="asks for the strength to shatter fate..."
		DamageMult=0.1
		AccuracyMult =10000
		Duration=5
		KBMult=0.00001
		Cooldown=-1
		UnarmedOnly=1
		Launcher=2
		name="Never Knows Best"
		HitSparkIcon='fevExplosion.dmi'
		HitSparkX=-32
		HitSparkY=-32
		Cooldown=-1
		verb/NeverKnowsBest()
			set category="Skills"
			set name="Never Knows Best (Act 1)"
			RandomMult=rand(1,70)
			DamageMult=RandomMult/10
			usr.SetQueue(src)
			usr.TriggerAwakeningSkill(ActNumber)
	FistOfTheRedStar
		name="Fist Of The Red Star"
		DamageMult=7
		AccuracyMult = 1.75
		Duration=5
		Cooldown=-1
		Shattering=3
		ActNumber=2
		AwakeningSkill=1
		KBAdd=15
		HitMessage="asks for the strength to shatter fate..."
		PushOutIcon='DarkKiai.dmi'
		PushOutWaves=3
		PushOut=1
		Cooldown=01
		HitSparkIcon='BLANK.dmi'
		adjust(mob/p)
			if(altered) return
			if(p.passive_handler.Get("Red Hot Rage"))
				Cooldown=10
				RedPUSpike=pick(25, 50)
				p.passive_handler.Increase("RedPUSpike", RedPUSpike)
				p.WeirdAngerStuff()
			else
				Cooldown=-1
				RedPUSpike=0
		verb/FistOfTheRedStar()
			set category="Skills"
			set name="Fist Of The Red Star (Act 2)"
			adjust(usr)
			usr.SetQueue(src)
			usr.TriggerAwakeningSkill(ActNumber)

obj/Skills/Utility
	var/RandomMult
	NeverTooEarly
		Copyable=0
		Cooldown=-1
		desc="End your awakening."
		verb/NeverTooEarly()
			set category="Utility"
			set name="Never Too Early"
			if(!usr.AwakeningSkillUsed)
				usr<<"No need."
				return
			if(usr.AwakeningSkillUsed)
				usr.Unconscious()
				usr.Health=0
	NeverTooLate
		Copyable=0
		ActNumber=1
		icon_state="Heal"
		desc="You ask for a little more time."
		Cooldown=-1
		verb/NeverTooLate()
			set category="Skills"
			set name="Never Too Late (Act 1)"
			RandomMult=rand(1,25)
			usr.DoDamage(usr, 10)
			usr.HealHealth(RandomMult)
			usr.TriggerAwakeningSkill(ActNumber)
	TheBlueExperience
		Copyable=0
		ActNumber=2
		icon_state="Heal"
		Cooldown=-1
		desc="Shine brightly. Your awakening skill strengthens, but you burn out quicker."
		verb/TheBlueExperience()
			set category="Skills"
			set name="The Blue Experience (Act 2)"
			usr.TriggerAwakeningSkill(ActNumber)
			usr.buffSelf(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/The_Blue_Experience)
	Burning_Soul
		Copyable=0
		ActNumber=3
		icon_state="Heal"
		Cooldown=-1
		desc="Translate all your power into rage. Your Rebirth skills become faster, but make you more and more angrier. At 500% Fury, your rage explodes outwards, damaging yourself and everyone in view."
		verb/Burning_Soul()
			set category="Skills"
			set name="Red Hot Rage (Act 3)"
			usr.TriggerAwakeningSkill(ActNumber)
			usr.buffSelf(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Burning_Soul)
	SoulShift
		Copyable=0
		verb/SoulRed()
			set category="Utility"
			set name="SOUL Shift (Red)"
			usr.passive_handler.Set("Determination(Red)", 1)
			usr.passive_handler.Set("Determination(Yellow)", 0)
			usr.passive_handler.Set("Determination(Green)", 0)
			usr.passive_handler.Set("Determination(Purple)", 0)
			usr.passive_handler.Set("Determination(Orange)", 0)
			usr<<"You are now using the Red SOUL color."
		verb/SoulYellow()
			set category="Utility"
			set name="SOUL Shift (Yellow)"
			usr.passive_handler.Set("Determination(Red)", 0)
			usr.passive_handler.Set("Determination(Yellow)", 1)
			usr.passive_handler.Set("Determination(Green)", 0)
			usr.passive_handler.Set("Determination(Purple)", 0)
			usr.passive_handler.Set("Determination(Orange)", 0)
			usr<<"You are now using the Yellow SOUL color."
		verb/Toggle_Unleash()
			set category="Utility"
			if(usr.passive_handler.Get("UnleashToggle"))
				usr.passive_handler.Set("UnleashToggle", 0)
				usr<<"You will now use Unleash on crit."
			else
				usr.passive_handler.Set("UnleashToggle", 1)
				usr<<"You will no longer use Unleash on crit."
	SoulShiftGreen
		Copyable=0
		verb/SoulGreen()
			set category="Utility"
			set name="SOUL Shift (Green)"
			usr.passive_handler.Set("Determination(Red)", 0)
			usr.passive_handler.Set("Determination(Yellow)", 0)
			usr.passive_handler.Set("Determination(Green)", 1)
			usr.passive_handler.Set("Determination(Purple)", 0)
			usr.passive_handler.Set("Determination(Orange)", 0)
			usr<<"You are now using the Green SOUL color."
	SoulShiftPurple
		Copyable=0
		verb/SoulPurple()
			set category="Utility"
			set name="SOUL Shift (Purple)"
			usr.passive_handler.Set("Determination(Red)", 0)
			usr.passive_handler.Set("Determination(Yellow)", 0)
			usr.passive_handler.Set("Determination(Green)", 0)
			usr.passive_handler.Set("Determination(Purple)", 1)
			usr.passive_handler.Set("Determination(Orange)", 0)
			usr<<"You are now using the Purple SOUL color."
	SoulShiftOrange
		Copyable=0
		verb/SoulOrange()
			set category="Utility"
			set name="SOUL Shift (Orange)"
			usr.passive_handler.Set("Determination(Red)", 0)
			usr.passive_handler.Set("Determination(Yellow)", 0)
			usr.passive_handler.Set("Determination(Green)", 0)
			usr.passive_handler.Set("Determination(Purple)", 0)
			usr.passive_handler.Set("Determination(Orange)", 1)
			usr<<"You are now using the Orange SOUL color."
	UltimateHeal
		ManaCost=100
		Cooldown=-1
		icon_state="Heal"
		desc="This allows you to attempt to heal people you are facing. At least it clears their fatigue, right?"
		verb/Ultimate_Heal()
			set category="Utility"
			usr.SkillX("UltimateHeal",src)
	BetterHeal
		ManaCost=75
		Cooldown=-1
		icon_state="Heal"
		desc="A decent, costly heal."
		verb/Better_Heal()
			set category="Utility"
			usr.SkillX("BetterHeal",src)
	HoldingOutForAHero
		Cooldown=-1
		verb/HoldingOutForAHero()
			set name="Holding Out For a Hero"
			set category="Skill"
			usr.AddSkill(new/obj/Skills/Queue/HoldingOutForAHero)
			del src
	TheUndying
		Cooldown=-1
		verb/Undying()
			set name="RISE UP"
			set category="Skills"
			if(src.Using) return
			src.Using=1
		//	usr.loc=usr.UndyingLoc
			//usr.loc=usr.UndyingLoc
			usr.passive_handler.Decrease("Undying")
		//	usr.OMessage(15,"[usr] <b>shines brightly with everlasting Hope, refusing to allow their story to end!</b>","<font color=red>[usr]([usr.key]) used Undying.")
			var/image/GG=image('GodGlow.dmi',pixel_x=-32,pixel_y=-32, loc = usr, layer=MOB_LAYER-0.5)
			GG.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
			GG.color=list(1,0,0, 0,1,0, 0,0,1, 0.2,0.2,0.4)
			GG.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 37), size = 5)
			animate(GG, alpha=0, transform=matrix()*0.7)
			usr.loc=usr.UndyingLoc
			usr.OMessage(15,"[usr] <b>shines brightly with everlasting Hope, refusing to allow their story to end!</b>","<font color=red>[usr]([usr.key]) used Undying.")
			world << GG
			animate(GG, alpha=255, time=30, transform=matrix()*1)
			animate(usr, color = list(0.45,0.6,0.75, 0.64,0.88,1, 0.16,0.21,0.27, 0,0,0), pixel_y=32, time=30)
			sleep(40)

			var/image/GO=image('GodOrb.dmi',pixel_x=-16,pixel_y=-16, loc = usr, layer=EFFECTS_LAYER+0.5)
			GO.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
			GO.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 156), size = 3)
			animate(GO, alpha=0)
			world << GO
			animate(GO, alpha=255, time=40)
			for(var/mob/Players/T in view(31, usr))
				animate(T.client, color=list(0.5,0,0, 0,0.5,0, 0,0,0.5, 0,0,0.1), time = 40)
				spawn(40)
					animate(T.client, color=null, time = 40)
			spawn(10)
				KenShockwave(usr, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
				animate(GO, color=list(1,0,0, 0,1,0, 0,0,1, 0.8,0.8,0.8), time=30)
			spawn(20)
				KenShockwave(usr, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
			spawn(30)
				KenShockwave(usr, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
			spawn(40)
				KenShockwave(usr, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
			spawn(50)
				KenShockwave(usr, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
			sleep(50)
			animate(usr, color = null)
			sleep(30)
			GG.filters-=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 37), size = 5)
			GG.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(51, 220, 243), size = 1)

			animate(GO, alpha=0, time=10)
			sleep(10)
			animate(usr, pixel_y=0, time=30)
			animate(GG, alpha=0, time=50)
			usr.passive_handler.Increase("CalmAnger")
			usr.passive_handler.Increase("FutureRewritten")
			usr.passive_handler.Increase("Determination(Purple)")
			usr.OMessage(15,"[usr] <b>unlocks the full potential of the Axe of Justice!!!</b>","<font color=red>[usr]([usr.key]) used Undying.")
			spawn(50)
				GO.filters=null
				del GO
				GG.filters=null
				del GG
			del src
obj/Skills/Projectile
	var/PartyReq
	var/PartyReqType
	Rude_Buster
		Distance=40
		ManaCost=50
		DamageMult=4
		Shearing=1
		AccMult=100
		HyperHoming=1
		Dodgeable=-1
		Deflectable=-1
		IconLock='RudeBuster2.dmi'
		LockX=-16
		IconSize=1
		Radius=3
		Homing=1
		verb/Rude_Buster()
			set category="Skills"
			set name="Rude Buster"
			usr.UseProjectile(src)
	Red_Buster
		Distance=40
		Charge=0.25
		ManaCost=40
		DamageMult=8
		Shearing=1
		AccMult=100
		HyperHoming=1
		Dodgeable=-1
		Deflectable=-1
		IconLock='RudeBuster.dmi'
		LockX=-16
		IconSize=1
		Radius=3
		Homing=1
		verb/Red_Buster()
			set category="Skills"
			set name="Red Buster"
			usr.UseProjectile(src)
	Devilsbuster
		Distance=40
		Charge=0
		ManaCost=40
		DamageMult=6
		Shearing=1
		AccMult=50
		HyperHoming=1
		Dodgeable=-1
		Deflectable=-1
		IconLock='Burning Black.dmi'
		LockX=-16
		IconSize=1
		Radius=3
		Homing=1
		verb/Devilsbuster()
			set category="Skills"
			set name="Devilsbuster"
			usr.UseProjectile(src)
	Burning_Black
		Distance=40
		Charge=0.25
		ManaCost=100
		DamageMult=40
		Shearing=1
		AccMult=100
		HyperHoming=1
		Dodgeable=-1
		Deflectable=-1
		IconLock='Burning Black.dmi'
		TurfShift='OmegaLava.dmi'
		LockX=-16
		IconSize=1
		Radius=3
		Homing=1
		Cooldown=180
		adjust(mob/p)
			if(p.passive_handler.Get("Shatter Fate"))
				Cooldown=1
				ManaCost=20
		verb/Burning_Black()
			set category="Skills"
			set name="Burning Black"
			adjust(usr)
			usr.UseProjectile(src)
	Beams
		TasteTheRainbow //Nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan nyan
			AdaptRate=1
			DamageMult=12
			Immediate=1
			Dodgeable=0
			StrRate=1
			ForRate=1
			IconLock='carefully.dmi'
			Cooldown=120
			EnergyCost=5
			Instinct=1
			verb/Taste_The_Rainbow()
				set category="Skills"
				usr.UseProjectile(src)
		Unbelievable_Rage
			DamageMult=10
			Immediate=1
			Dodgeable=0
			IconLock='Pride Beam.dmi'
			Cooldown=30
			Instinct=1
			adjust(mob/p)
				if(altered) return
				if(p.passive_handler.Get("Red Hot Rage"))
					Cooldown=10
					RedPUSpike=pick(25, 50)
					DamageMult=12
					p.passive_handler.Increase("RedPUSpike", RedPUSpike)
					p.WeirdAngerStuff()
				else
					Cooldown=30
					RedPUSpike=0
			verb/Unbelievable_Rage()
				set category="Skills"
				adjust(usr)
				usr.UseProjectile(src)

	Zone_Attacks
		Final_Chaos
			Speed = 0.25
			Cooldown=-1
			Distance=20
			Blasts=15
			Charge=1
			DamageMult=1.3
			IconLock='Nyan2.dmi'
			Instinct=1
			AccMult=2
			Homing=3
			Explode=1
			ZoneAttackX=3
			ZoneAttackY=3
			Hover=7
			ActNumber=3
			AwakeningSkill=1
			Variation=0
			verb/Final_Chaos()
				set category="Skills"
				set name="Final Chaos (Act 3)"
				usr.TriggerAwakeningSkill(ActNumber)
				usr.UseProjectile(src)
obj/Skills/Buffs
	Slotless
		Rebirth
			RefractiveArmor
				MakesArmor=1
				DarkChange=1
				ArmorAscension=1
				ArmorElement="Mirror"
				IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
				ArmorClass="Light"
				ArmorIcon='BLANK.dmi'
				ActiveMessage="dons a refractive armor that turns their entire body black."
				OffMessage="disperses their armor."
				verb/Refractive_Armor()
					adjust(usr)
					src.Trigger(usr)
	Rebirth
		ActiveSlot=1
		CrownlessKing
			SpdMult=1.5
			HealthDrain=0.25
			HealthThreshold=0.1
			EnergyHeal=1
			ActiveMessage="shines brighter than ever before, their legend taking a life of its own. <b>All Hail the Crownless King</b>."
			OffMessage="casts aside the burden of the Crownless King."
			passives = list("Godspeed" = 3, "AfterImages" = 2, "ShiningBrightly" = 1, "KiControl" = 1)
			verb/Crownless_King()
				set category= "Skills"
				src.Trigger(usr)

		ComebackKing
			NeedsHealth=50
			TooMuchHealth=75
			EndMult=0.85
			EnergyHeal=1
			ActiveSlot=0
			Slotless=1
			ActiveMessage="casts aside their durability to call forth a miraculous turnaround. <b>All Hail the Comeback King</b>."
			OffMessage="casts aside the burden of the Comeback King."
			passives = list("Unstoppable" = -1, "HellPower"=0.5, "UnderDog"=5, "Rage" = 1, "KiControl" = 1)
			adjust(mob/p)
				if(p.isRace(MAKYO))
					AngerMult = 2
					passives = list("Unstoppable" = -1, "HellPower"=0.1, "UnderDog"=1, "Rage" = 1, "KiControl" = 1, "BleedHit" = 0,\
					 "ManaLeak" = 0, "GiantForm" = round(p.AscensionsAcquired/2), "Godspeed" = p.AscensionsAcquired, "PUSpike" = 75, "Pursuer" = 2*p.AscensionsAcquired)
				else
					AngerMult = 1
					passives = list("Unstoppable" = -1, "HellPower"=0.5, "UnderDog"=5, "Rage" = 5, "KiControl" = 1)
			verb/Comeback_King()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		ChaosQueen
			StrMult=1.1
			EndMult = 1.1
			ForMult = 1.1
			SpdMult=1.1
			OffMult=1.1
			DefMult=1.1
			EnergyHeal=1
			ManaGlow="Rainbow"
			passives = list("Flicker" = 1, "Pursuer"=1, "Instinct"=1, "ChaosQueen" = 1, "Prismatic" =1, "KiControl" = 1)
			ActiveMessage="casts aside certainty in the name of possibility, singing the <b>Song of the Chaos Queen!</b>"
			OffMessage="normalizes their outcomes, putting aside the mantle of the Chaos Queen."
			verb/Chaos_Queen()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		RemoveSOUL
			MakesSword=1
			KiControl=1
			SwordName="SOUL Sword"
			SwordIcon='PlaceholderBlackScythe.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Medium"
			PowerMult=3
			Cooldown = 1
			HealthCost = 50
			ActiveMessage="tears their heart from their chest."
			OffMessage="places their still-beating heart back into their chest."
			verb/RemoveSOUL()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		BlackKnife
			MakesSword=1
			SwordName="Black Knife"
			SwordIcon='BlackShard.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Heavy"
			StrMult=1.85
			SpdMult=1.5
			PowerMult=1.25
			Cooldown = 1
			SwordAscension=6
			passives = list("PUSpike"=50, "AbyssMod" = 3, "BlurringStrikes"=3, "HolyMod" = 3, "HellPower"=0.5, "Determination(Black)"=1, "KiControl" = 1)
			ActiveMessage="materializes the Black Knife."
			OffMessage="puts the black knife away."
			adjust(mob/p)
				passives = list("PUSpike"=50, "AbyssMod" = 3, "BlurringStrikes"=5, "HolyMod" = 3, "HellPower"=0.5, "Determination(Black)"=1, "KiControl" = 1)
				PowerMult=1.25
				StrMult=1.85
				SpdMult=1.5
				PowerMult=1.25
				EnergyHeal=1
				SwordUnbreakable=1
			verb/BlackKnife()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		BlackShard
			MakesSword=1
			SwordName="Black Shard"
			SwordIcon='BlackShard.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Light"
			StrMult=1.85
			SpdMult=1.5
			PowerMult=1.25
			Cooldown = 1
			SwordAscension=5
			OffMult=0.75
			passives = list("HolyMod" = 3,"KiControl" = 1)
			ActiveMessage="pulls out a small shard of glass that seems barely usable as a weapon."
			OffMessage="puts the black shard away."
			adjust(mob/p)
				passives = list("PUSpike"=50, "HolyMod" = 3, "BlurringStrikes"=5, "KiControl"=1)
				PowerMult=1.25
				StrMult=1.85
				SpdMult=1.5
				PowerMult=1.25
				OffMult=0.75
				EnergyHeal=1
				SwordUnbreakable=1
			verb/BlackShard()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		White_Pen_of_Hope
			MakesSword=1
			SwordName="White Pen of Hope"
			SwordIcon='KATANA SILVER.dmi'
			SwordX=-8
			SwordY=-4
			SwordClass="Light"
			StrMult=1.85
			SpdMult=1.5
			PowerMult=1.25
			Cooldown = 1
			SwordAscension=6
			passives = list("HolyMod" = 3,"KiControl" = 1)
			ActiveMessage="manifests their will to change fate, every determination color melding into one: White!"
			OffMessage="puts the pen away."
			adjust(mob/p)
				passives = list("PUSpike"=100, "HolyMod" = 5, "BlurringStrikes"=5, "KiControl"=1, "SpiritSword" = 0.5,"EndlessNine"=0.15)
				PowerMult=1.25
				StrMult=1.5
				ForMult=1.5
				SpdMult=1.5
				EnergyHeal=1
				SwordUnbreakable=1
				if(p.SagaLevel>=6)
					passives = list("PUSpike"=100, "HolyMod" = 5, "BlurringStrikes"=5, "KiControl"=1, "SpiritSword" = 1,"EndlessNine"=0.5,"MovementMastery"=6)
			verb/White_Pen_of_Hope()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		Devilsknife
			MakesSword=1
			SwordName="Devilsknife"
			SwordIcon='PlaceholderBlackScythe.dmi'
			BuffTechniques=list("/obj/Skills/Projectile/Rebirth/Devilsbuster")
			SwordClass="Medium"
			ForMult=1.15
			StrMult=1.3
			PowerMult=1.25
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="draws forth a skull emblazoned scythe-ax!"
			OffMessage="pockets the weap-... did it just smile at you?!"
			adjust(mob/p)
				passives = list("PUSpike"=50,"KiControl" = 1)
				PowerMult=1.25
				EnergyHeal=1
			verb/Devilsknife()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
				if(prob(2))
					OMsg(usr, "<b>MY HEARTS GO OUT TO ALL YOU SINNERS!</b>")
		JusticeAxe
			MakesSword=1
			SwordName="Axe of Justice"
			SwordIcon='PlaceholderBlackScythe.dmi'
			SwordClass="Heavy"
			StrMult=1.75
			SwordAscension=5
			Cooldown = 1
			PowerMult=1.25
			ActiveMessage="faces fate with the Axe of Justice."
			OffMessage="puts the Axe of Justice away."
			adjust(mob/p)
				if(!altered)
					passives = list("PUSpike"=50,"KiControl" = 1)
					PowerMult=1.25
					EnergyHeal=1
					SwordUnbreakable=1
					if(p.SagaLevel>=6)
						passives = list("PUSpike"=50,"KiControl" = 1,"CallousedHands"=0.25, "ManaGeneration"=2)
					if(p.passive_handler["FutureRewritten"])
						passives = list("PUSpike"=50, "SpiritSword" = 0.75, "ManaGeneration" = 1,"KiControl" = 1)
						if(p.SagaLevel>=6)
							passives = list("PUSpike"=50, "SpiritSword" = 0.75, "ManaGeneration" = 3,"KiControl" = 1,"CallousedHands"=0.25)
			verb/JusticeAxe()
				set category="Skills"
				set name="Axe of Justice"
				adjust(usr)
				src.Trigger(usr)
		Spookysword
			MakesSword=1
			SwordName="Spookysword"
			SwordIcon='Spookysword.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Medium"
			StrMult=1.25
			ForMult=1.25
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="draws forth a black and orange sword!"
			OffMessage="sheathes their spooky blade!"
			adjust(mob/p)
				passives = list("PUSpike"=50, "BlurringStrikes"=3,"KiControl" = 1)
				PowerMult=1.25
				EnergyHeal=1
				if(p.SagaLevel>=3)
					StrMult=1.5
					ForMult=1.5
			verb/Spookysword()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		ThornRing
			MakesSword=1
			SwordName="Spookysword"
			SwordIcon='PlaceholderBlackScythe.dmi'
			passives = list("DrainlessMana" = 1)
			BuffTechniques=list("/obj/Skills/Projectile/Rebirth/Devilsbuster")
			SwordX=-32
			SwordY=-32
			SwordClass="Small"
			HealthCost = 25
			Cooldown = 1
			ActiveMessage="receives pain to become stronger."
		//	OffMessage="sheathes their spooky blade!"
			verb/Thorn_Ring()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		//	JusticeAxe
obj/Skills/Grapple
	CHAOS_DUNK
		DamageMult=10
		StrRate=1
		TriggerMessage="comes on and slams"
		Effect="Lotus"
		EffectMult=4
		OneAndDone=1
		ThrowMult=0
		ThrowAdd=0
		Cooldown=120
		verb/CHAOS_DUNK()
			set category="Skills"
			src.Activate(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle //t3 scaled styles
	The_Roaring_Knight //cyan t5 evil path
		StyleActive="The Roaring Knight"
		passives = list("BlurringStrikes"=2, "Secret Knives" = "GodSlayer", "MagicSword"=1,"AfterImages" = 2,"Tossing"=2)
		StyleEnd=1.5
		StyleStr=1.5
		Finisher="/obj/Skills/Queue/Finisher/Twisted_Heartbeat"
		verb/The_Roaring_Knight()
			set hidden=1
			adjust(usr)
			Trigger(usr)
	White_Pen_Of_Hope //cyan t5 good path
		StyleActive="The White Pen of Hope"
		passives = list("ManaGeneration" = 2, "ManaStats"=2, "Determination(White)" = 1,"ManaCapMult"=1, "MagicSword"=1)
		StyleSpd=1.5
		StyleStr=1.25
		StyleFor=1.25
		Finisher="/obj/Skills/Queue/Finisher/Cross_Slash"
		adjust(mob/p)
			passives = list("ManaGeneration" = 2, "ManaStats"=2, "Determination(White)" = 1,"ManaCapMult"=1, "MagicSword"=1)
		verb/Pen_Of_Hope()
			set hidden=1
			adjust(usr)
			Trigger(usr)
	Justice_Incarnate
		StyleActive="Justice Incarnate"
		StyleStr=1.25
		StyleFor=1.25
		StyleEnd=1.5
		Finisher="/obj/Skills/Queue/Finisher/Your_Idea"
		passives = list("Deicide" = 10, "Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1)
		adjust(mob/p)
			passives = list("Deicide" = 10, "Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1, "EndlessNine"=0.25, "PureDamage"=4,"PureReduction"=4)
			if(p.SagaLevel>=6)
				passives = list("Deicide" = 10, "Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1, "EndlessNine"=0.5, "PureDamage"=6,"PureReduction"=6)
		verb/Justice_Incarnate()
			set hidden=1
			adjust(usr)
			Trigger(usr)
	Fate_Incarnate
		StyleActive="Fate Incarnate"
		StyleStr=1.25
		StyleFor=1.25
		StyleEnd=1.5
		Finisher="/obj/Skills/Queue/Finisher/Your_Idea"
		passives = list("Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1, "PureDamage"=3,"PureReduction"=3)
		adjust(mob/p)
			passives = list("Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1, "PureDamage"=2,"PureReduction"=2)
			if(p.SagaLevel>=6)
				passives = list("Rage" = 5, "Momentum" = 1, "Determination(Green)" = 1, "MagicSword"=1, "PureDamage"=3,"PureReduction"=3)
		verb/Fate_Incarnate()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Queue/Finisher
//t3
	Your_Idea // Justice Incarnate
		DamageMult = 4
		Grapple=1
		HitMessage="has a brilliant idea!"
		GrabTrigger="/obj/Skills/Grapple/Throw_Shit_At_The_Wall"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Hope_Crossed_On_Your_Heart"
	Cross_Slash //The White Pen of Hope
		DamageMult = 1
		HitMessage=""
		FollowUp="/obj/Skills/Queue/Finisher/Kris_Kross_Applesauce"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/The_Cage_With_Human_Soul_And_Parts"
	Kris_Kross_Applesauce
		Combo=2
		DamageMult = 5
		InstantStrikes = 2
		HitMessage="channels their SOUL into their blade, swinging twice with deadly force!"
		BuffSelf=0
		HitSparkIcon = 'Slash_Multi.dmi'
	Twisted_Heartbeat //The Roaring Knight
		DamageMult=10
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Blackened_Knife"
		HitMessage = "tears apart reality with one decisive swing."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Hope_Crossed_On_Your_Heart
		StrMult=1.3
		EndMult=1.3
		passives = list("CallousedHands"=0.5, "Harden"=3, "TensionLock" = 1, "Brutalize" = 1.5)
	The_Cage_With_Human_Soul_And_Parts
		StrMult=1.3
		ForMult=1.3
		passives = list("TensionLock" = 1, "Speed Force" = 1, "Iaijutsu" = 1, "Relentlessness" = 1, "Fury" = 3)
	Blackened_Knife
		StrMult=1.3
		SpdMult=1.3
		passives = list("AfterImages" = 4, "TensionLock" = 1, "Speed Force" = 1, "BlurringStrikes" = 3, "Relentlessness" = 1, "Fury" = 3)
