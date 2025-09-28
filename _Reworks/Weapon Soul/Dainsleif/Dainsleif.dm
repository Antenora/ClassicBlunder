mob/var/dainsleifDrawn = FALSE

obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin//Dainsleif
	name="Blade of Ruin"
	icon='Dainsleif.dmi'
	passives = list("Shearing" = 1, "CursedWounds" = 1, "MortalStrike" = 0.5)
	var/hasKilled = FALSE
	proc/drawDainsleif(mob/p)
		hasKilled = FALSE
		if(!p.dainsleifDrawn)
			p << "You draw the blade from it sheathe and are barely able to contain its immense bloodlust. The sword cries out, waning for blood."
			OMsg(p, "[p.name] draws their blade from its sheathe and they can barely contain it. The Sword of Ruin wans for blood...")
		p.dainsleifDrawn = TRUE
		spawn(20) dainsleifDrain(p)
	proc/onKill(mob/atk, mob/defend)
		hasKilled = TRUE
		OMsg(atk, "The Sword of Ruin's blood lust has been sated by [defend.name]'s death!")

	proc/putAway(mob/p)
		if(!hasKilled)
			if(p.HealthCut >=0.3)
				p << "The blade refuses to be sheathed."
				return FALSE
			else
				var/choice = input(p, "The blade resists your attempts to sheathe it. Do you wish to sheathe it anyway?") in list("Yes", "No")
				switch(choice)
					if("Yes")
						p << "The blade forces itself into your body and you feel your life force being drained away."
						OMsg(p, "The blade shoves itself into [p.name]'s body, absorbing their life force!")
						p.HealthCut += 0.1
						p.dainsleifDrawn = FALSE
						return TRUE
					if("No")
						p << "You decide to keep the blade out."
						return FALSE
		else
			hasKilled = FALSE
			p.dainsleifDrawn = TRUE
			return TRUE

	proc/dainsleifDrain(mob/p)
		if(glob.DainsleifDrain && p.dainsleifDrawn)
			while(p.dainsleifDrawn)
				sleep(10)
				if(!p.KO)
					p.DoDamage(p, glob.DainsleifDrainAmount / p.SagaLevel)
		else
			return .

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Dainsleif
	name = "Heavenly Regalia: Ruined World"
	StrMult=1.5
	OffMult=1.5
	passives = list("Instinct" = 3, "LifeStealTrue" = 1, "PureDamage" = -1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="soaks the world in blood: Heavenly Regalia!"
	OffMessage="'s treasure loses its ruinous luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
	
obj/Skills/Queue
	Blood_Craving
		HitMessage="upward slash rends their target! The trickles of ichor form into a red barrier!"
		ActiveMessage="sword gleams blood red!"
		ABuffNeeded="Soul Resonance"
		DamageMult=0.75
		FollowUp="/obj/Skills/AutoHit/Bloody_CravingEnhanced" 
		FollowUpDelay=1
		Duration=5
		KBMult=0.00001
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/We_Dine"
		Cooldown=30
		NeedsSword=1
		EnergyCost=2
		name="Blood Craving"
		verb/Blood_Craving()
			set category="Skills"
			set name="Blood Craving"
			usr.SetQueue(src)

obj/Skills/AutoHit/Bloody_CravingEnhanced
	NeedsSword=1
	Area="Wave"
	ComboMaster=1
	GuardBreak=1
	StrOffense=1
	PassThrough=1
	PreShockwave=1
	PostShockwave=0
	Shockwave=2
	Shockwaves=2
	DamageMult=5
	Knockback=0
	Distance=8
	HitSparkIcon='Hit Effect Vampire.dmi'
	ActiveMessage="is followed by some piercing trickles of ichor! "
	Cooldown=1
	EnergyCost=3

obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/We_Dine
	passives = list("SwordAscension" = 1,"HardStyle" = 0.5, "Deflection" = 1)
	VaizardHealth=2
	TimerLimit=10
	IconLock='Blood Shield.dmi'
	LockX=0
	LockY=0
obj/Skills/AutoHit/Destined_Death
	NeedsSword=1
	Area="Circle"
	StrOffense=1
	EndDefense=1
	DamageMult=2
	Shearing=10
	CursedWounds=1
	ComboMaster=1
	DelayTime=6
	Cooldown=90
	Knockback=2
	Size=1
	Distance=12
	Rounds=5
	Rush=0
	ControlledRush=0
	RoundMovement=0
	Shockwaves=1
	Shockwave=1
	ShockIcon='KenShockwaveBloodlust.dmi'
	ShockBlend=1
	ShockDiminish=2
	ShockTime=12
	PostShockwave=1
	Icon='BloodGather.dmi'
	IconX=-0
	IconY=-0
	ABuffNeeded="Soul Resonance"
	BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Blood_Lusted"
	HitSparkIcon='BloodGather.dmi'
	HitSparkX=0
	HitSparkY=0
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	TurfShift='BloodGather.dmi'
	TurfShiftDuration=1
	TurfShiftDurationSpawn=1
	TurfShiftDurationDespawn=1
	EnergyCost=3
	Quaking=10
	Earthshaking=10
	ActiveMessage="raises Dainslief as ichor pulls from the area and gathers within it!"
	verb/Destined_Death()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Blood_Lusted
	passives = list("Maki" = 1,"Steady" = 1,"HardStyle" = 1, "Duelist" = 1, "KillerInstinct" = 0.10, "SuperDash" = 1,)
	TimerLimit=20
	ManaGlow=rgb(165,0,0)
	ManaGlowSize=3
	LockX=0
	LockY=0