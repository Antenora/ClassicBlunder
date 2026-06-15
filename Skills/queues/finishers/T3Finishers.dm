/obj/Skills/Queue/Finisher
	Be_Water
		Stunner = 3
		HarderTheyFall = 4
		SweepStrike = 4
		Finisher = 2
		Combo = 20
		Instinct = 2
		InstantStrikes=2
		DamageMult = 0.2
		Quaking=25
		DamageMult = T3_DMG_MULT/2/20/2;
		FollowUp="/obj/Skills/AutoHit/True_One_Inch_Punch"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Intercepting_Fist"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark"
		HitMessage="looks <i>locked in</i>."
	Endless_Session // Heir of Grief
		Instinct=2
		Combo=25
		DamageMult = T3_DMG_MULT/2/20
		HitMessage="manifests the One who Completed Them-- and together, crushes through all obstacles!"
		BuffSelf=0
		HitSparkIcon = 'Slash_Multi.dmi'
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Final_Session"

	Big_Boot
		Instinct=2
		Grapple=1
		KBMult=0.001
		SweepStrike=6
		Crushing = 100
		Stunner = 2
		DamageMult = T3_DMG_MULT/2;
		UnarmedOnly=1
		GrabTrigger="/obj/Skills/Grapple/Tombstone_Piledriver"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/The_8th_Wonder_Of_The_World"
		HitMessage="places their foot to the face of their fellow wrestler!"
	Erupting_Mugen_Tengenkotsu
		KBMult=7
		KBAdd = 8
		Quaking=9
		DamageMult=T3_DMG_MULT;
		HitSparkIcon='fevExplosion.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Legendary_Exhaustion"
		HitMessage="unleashes their pent up legendary power, quaking all of reality with their might!"

	Soul_Seller
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/True_Form/Demon"
		FollowUp="/obj/Skills/AutoHit/Minor_Reality_Corruption"
		HitMessage = "sells their soul for a brief boost to power!"
	Atomic_Dismantling
		FollowUp="/obj/Skills/AutoHit/Atomic_Dismantling"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dismantled"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Magnetism"
		HitMessage = "takes apart their foe's defense atomically!"
		DamageMult=1
		Stunner=3

	Jumbled_Line_Up //Acrobat
		Combo=10
		DamageMult=T3_DMG_MULT/2/10;
		FollowUp="/obj/Skills/Projectile/ThreeShot_Path"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Infinite_Blades"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Super_Shredded"
		HitMessage = "hurls skyward a cascade of blades!"
	Clear_Water //Two Heavens as One
		DamageMult=T3_DMG_MULT;
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Kensei"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Enten"
		HitMessage = "ushers in absolute serenity with a humble slash..."
	Divine_Wrath //Fierce Diety
		HarderTheyFall=4
		Stunner=4
		KBMult = 0.0001
		FollowUp="/obj/Skills/AutoHit/Divine_Cleave"
		DamageMult = T3_DMG_MULT/10;
		Decider = 6
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Judge_of_Heaven"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Justice_of_Hell"
		HitMessage= "unleashes the Fury of the Heavens!"

		//Gamma Style finishers
	Sorblow //Betel
		DamageMult = T3_DMG_MULT
		Scorching = 100
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitMessage="amasses powerful flames in their hands and strikes true!"
	Urda_Impulse //Kaus
		DamageMult = T3_DMG_MULT/2
		FollowUp="/obj/Skills/AutoHit/Urda_Impulse"
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitMessage="leaps into the air and begins to glide..."
	Albion //Wezen
		DamageMult = T3_DMG_MULT/2
		FollowUp="/obj/Skills/AutoHit/Albion"
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitMessage="grounds themselves..."
	Desdemona //Gulus
		DamageMult = T3_DMG_MULT/2
		FollowUp="/obj/Skills/AutoHit/Desdemona"
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitMessage="gathers wicked flames within their hands..."
	Plasma_Formation
		SpeedStrike = 2
		SweepStrike = 2
		Quaking=5
		PushOut=1
		DamageMult = T3_DMG_MULT/2;
		FollowUp="/obj/Skills/Queue/Finisher/Plasma_Evolution"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Radioactive"
		HitMessage = "breaks off into a relentless pursuit!"
	Plasma_Evolution
		Combo=10
		DamageMult = T3_DMG_MULT/2/10;
		BuffSelf=0
		HitSparkIcon = 'Slash_Multi.dmi'
	Blood_Sacrifice
		Crippling=100
		Quaking=2
		PushOut=1
		DamageMult= T3_DMG_MULT / 2;
		FollowUp="/obj/Skills/AutoHit/Bloodruin"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Bloodfury"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Silence"