/obj/Skills/Queue/Finisher
	Grasp_Tomorrow
		Quaking=12
		DamageMult=T4_DMG_MULT;
		InstantStrikes=2
		InstantStrikesDelay = 1
		PushOut=1
		PushOutWaves=2
		HitSparkIcon='KenShockwaveGod.dmi'
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Promise_of_Tomorrow"
		HitSparkX=-32
		HitSparkY=-32
		HitMessage="grasps tomorrow within their hands!"
	The_Blade_of_Chaos
		HarderTheyFall=4
		Stunner=4
		Quaking=12
		DamageMult=T4_DMG_MULT/2;
		InstantStrikes=2
		InstantStrikesDelay = 1
		PushOut=1
		PushOutWaves=2
		HitSparkIcon='Slash - Zan.dmi'
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ghost_of_Sparta"
		HitSparkX=-32
		HitSparkY=-32
	Demonic_Nine_Flashes
		HitSparkIcon = 'Slash_Multi.dmi'
		InstantStrikes=9
		InstantStrikesDelay = 0.5
		DamageMult=T4_DMG_MULT/2/9;
		Stunner=4
		SpeedStrike=1
		FollowUp="/obj/Skills/AutoHit/Ashura_Bakkei"
		HitMessage="rushes forward, their aura manifesting six more blades, as they unleash a flurry of blows in the blink of an eye!"
	Jinzen_Senkei
		Stunner=1
		DamageMult=T4_DMG_MULT/2;
		HitSparkIcon='Slash_Multi.dmi'
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Jinzen_Enlightenment"
		FollowUp="/obj/Skills/AutoHit/Jinzen_Strike"
	The_Big_Bang_Punch
		Stunner=1
		DamageMult=T4_DMG_MULT/2;
		HitSparkIcon='fevExplosion.dmi'
		HitSparkX=-32
		HitSparkY=-32
		Explosive=10
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/The_Ultimate_Fist"
		FollowUp="/obj/Skills/AutoHit/Big_Bang_Followup"
	Hyakuretsu_Ken
		Combo=9
		InstantStrikes=3
		InstantStrikesDelay=0.1
		DamageMult=T4_DMG_MULT/2/9/3;
		Stunner=4
		SpeedStrike=1
		FollowUp="/obj/Skills/AutoHit/The_Tenth_Strike"
		HitMessage="unleashes a flurry of powerful blows, sealing their target's fate."
	Stone_Cold_Stunner
	Saigo_no_Kyukyoku_Tengenkotsu
		KBMult=20
		KBAdd = 20
		Quaking=12
		DamageMult=T4_DMG_MULT;
		HitSparkIcon='fevExplosion.dmi'
		HitSparkX=-32
		HitSparkY=-32
		Explosive=10
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Legendary_Exhaustion"
		HitMessage="unleashes their pent up legendary power, transcending the limits of reason. The sun they grasp within their hand explodes in a brilliant supernova, achieving the ultimate, supreme, final Tengenkotsu!!!!!"
	Stellar_Formation
		SpeedStrike = 2
		SweepStrike = 2
		Quaking=5
		PushOut=1
		DamageMult = T4_DMG_MULT/2;
		FollowUp="/obj/Skills/Queue/Finisher/Stellar_Evolution"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ionization"
		HitMessage = "breaks off into a relentless pursuit!"
	Stellar_Evolution
		Combo=10
		DamageMult = T4_DMG_MULT/2/10;
		BuffSelf=0
		HitSparkIcon = 'Slash_Multi.dmi'
	Hyper_Goner_Two
		FollowUp="/obj/Skills/Projectile/Zone_Attacks/Even_More_Super_Hyper_Goner_Attack"
		DamageMult = T4_DMG_MULT/2;
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Final_Boss_Form"
	Jackpot
		Combo=7
		InstantStrikes=7
		InstantStrikesDelay = 0.5
		Warp=10
		DamageMult=T4_DMG_MULT/2/7/7;
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Jackpot"
		FollowUp="/obj/Skills/Projectile/Zone_Attacks/Seven_Lucky_Flames"
		HitMessage = "hits the motherfuckin' jackpot!!!!"
/obj/Skills/Queue/Finisher
	Seiken_Gradalpha
		name = "Seiken Gradalpha"
		Warp = 5
		Combo = 3
		InstantStrikes = 2
		DamageMult = T4_DMG_MULT/2/3/2;
		Instinct = 3
		Shining = 3
		Explosive = 2
		FollowUp = "/obj/Skills/AutoHit/Seiken_Gradalpha2"
		HitMessage = "pierces their foe with converging light!"
	Shining_V_Force
		name = "Shining V Force"
		Warp = 10
		Combo = 5
		InstantStrikes = 5
		DamageMult = T4_DMG_MULT/5/5;
		Instinct = 5
		Shining = 3
		Explosive = 3
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Future_Mode"
		HitMessage = "delivers countless strikes against their foe in the blink of an eye, then fires off a V-shaped beam of light!"
/obj/Skills/AutoHit
	Big_Bang_Followup
		Area="Circle"
		DamageMult=T4_DMG_MULT/2;
		Knockback = 1
		ComboMaster=1
		Stunner=3
		Size=4
		StrOffense=1
		GuardBreak=1
		Rush=5
		PullIn=2
		ControlledRush=8
		TurfErupt=2
		TurfEruptOffset=3
		Instinct=1
		TurfStrike=4
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=1
		ChargeTech = 1
		ActiveMessage="kicks off the ground, turning their feet into rockets, as they launch forward and release the mother of all punches: Forbidden Technique: The Big Bang Punch!!!!"
	Jinzen_Strike
		Copyable=5
		NeedsSword=1
		Area="Wide Wave"
		StrOffense=1
		ForOffense=1
		Distance=10
		PassThrough=1
		PreShockwave=1
		PostShockwave=0
		Shockwave=2
		Shockwaves=2
		DamageMult=T4_DMG_MULT/2;
		PullIn=2
		ActiveMessage="becomes one with their blade, tearing through time and space in one fell swoop."
		HitSparkIcon='Slash - Vampire.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=1
		HitSparkDispersion=1
		TurfStrike=1
		TurfShift='StarPixel.dmi'
		TurfShiftDuration=3
		Instinct=1
/obj/Skills/Projectile
	Zone_Attacks
		ZoneAttack=1
		Even_More_Super_Hyper_Goner_Attack
			Blasts=25
			Charge=2
			DamageMult=T4_DMG_MULT/2;
			Instinct=1
			AccMult=2
			Explode=1
			Distance=100
			ZoneAttackX=1
			ZoneAttackY=3
			Hover=10
			Variation=0
			ComboMaster=1
			IconLock='ChaosBlast.dmi'
		Seven_Lucky_Flames
			Blasts=7
			Charge=2
			DamageMult=T4_DMG_MULT*1.5;
			Instinct=1
			AccMult=2
			Explode=1
			Distance=100
			ZoneAttackX=1
			ZoneAttackY=3
			Hover=10
			Variation=0
			ComboMaster=1
			IconLock='Hellzone.dmi'