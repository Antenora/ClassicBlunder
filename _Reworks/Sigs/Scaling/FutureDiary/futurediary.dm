/** 
 * Plan. 
 * 4 Diaries. 
 * 
 * 4, murder diary
 * 3, detective diary
 * 2, yuno gasai,
 * 1, mc diary
 * 
 * murder gets a murder / maim based kit
 * get maimstrike based moves.. 
 * 
 * 
 * detective knows the target,
 * get detective esque moves.. 
 * i.e tazer etc.. 
 * HolyMod ttached to user vs murders abyss
 * 
 * yuno gasai
 * get t1 knife skills
 * and overall passives..
 * 
 * 
 * mc diary get random passives purely % chance.. (make a remake guard for rerolling..)
 * 
 * 
 * on picking it, you get the future diary object that acts as a pseudo buff. 
 * 1 flow, 1.1 speed, 1.1 str & for 
 * 
 */

////
// VARIABLES
/// 
var/list/randomPassives = list("PureDamage", 
"Godspeed", "Void", "NoWhiff", "HolyMod", "AbyssMod",
"VenomImmune", "CounterMaster", "TechniqueMastery",
"HybridStrike", "SpiritStrike", "Extend", "MovementMastery", "UnlimitedPU",
"CriticalBlock", "Unstoppable", "DebuffResistance")
mob/var/futureDiaryLevel = 0 // maxes out at 4.
mob/var/whichDiary = 0 /// 1, 2, 3, 4 look for above...


// PROCS

/////
///
/// 


obj/proc/getPassivesFutureDiary(mob/player) // MC Passives.. 
	var/list/passiveList = list()
	if(player.Potential > 85)
		if(prob(1))
			passiveList += list("GodKi")
			return passiveList
	passiveList = pick(randomPassives)				
	return passiveList

mob/proc/levelUpDiary(mob/M)
	M.futureDiaryLevel ++ 
	switch(M.futureDiaryLevel)
		if(1)
			if(!locate(/obj/Skills/Buffs/SpecialBuffs/FutureDiary, M))
				M.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/FutureDiary)
			M << "You feel a connection with your Diary.. It becomes special.. It feels empowered by the powers of the cosmos."
			switch(input(M, "It has came time to chose your Diary out of the four..", "Chose your Diary") in list("First","Second","Third","Fourth"))
				if("First")
					M.whichDiary = 1
				if("Second")
					M.whichDiary = 2
				if("Third")
					M.whichDiary = 3
				if("Fourth")
					M.whichDiary = 4

		if(2)
			M << "You feel your connection to your Diary improve..."
			switch(M.whichDiary)
				if(1)
					M << "You grow ever so dependant on your Diary! Growing in your cowardice!"
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/Desperation)
				if(2)
					M << "You grow ever so dependant on your Diary! Growing stronger with your LOVE."
					M.AddSkill(new/obj/Skills/Queue/HeartStab)
				if(3)
					M << "You grow ever so dependant on your Diary! The urge to MURDER grows stronger within your mind"
					M.AddSkill(new/obj/Skills/AutoHit/MurderGaze)
				if(4)
					M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/DetectivesHunch)


		if(3)
			M << "You feel yourself connect with the Cosmos further with your Diary"
			M << "You feel you are confident in reading the future!"
			M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/FutureRead)
			var/choice = input(M, "What sort of a Future do you wish to cleave?", "Future Awaits") in list ("Chaos", "Peace")
			if(choice == "Chaos")
				M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/FutureRead)
			else
				M.AddSkill(new/obj/Skills/Queue/PeaceRetreat)
		if(4)
			M << "You are nearing victory.. You can feel the <b>GOD</b> like powers.."
			M.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/PerfectReading)

/obj/Skills/Buffs/SpecialBuffs/FutureDiary
	OffMult = 1.1
	DefMult = 1.2
	SpecialSlot = 1
	Cooldown = 300
	name = "Future Diary"
	BuffName = "Future Diary"
	ActiveMessage = "begins to read the future!"
	OffMessage = "closes off their diary!"
	verb/Future_Diary()
		set category = "Skills"
		if(!usr.BuffOn(src))
			switch(usr.futureDiaryLevel)
				if(1)
					switch(usr.whichDiary)
						if(1)
							passives = list("Desperation" = 2, "Flow" = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							DefMult = 1.4
						if(2)
							passives = list("Flow" = 2, "Omnipotent" = 1)
							OffMult = 1.3
							SpdMult = 1.1
						if(3)
							passives = list("MortalStrike" = 1, "MaimStrike" = 2, "Maki" = 1)
							StrMult = 1.3
							OffMult = 1
						if(4)
							passives = list("HolyMod" = 1, "PUSpike" = 5, "Instinct" = 1)
							DefMult = 1.3 
							EndMult = 1.2
				if(2)
					switch(usr.whichDiary)
						if(1)
							passives = list("Desperation" = 3, "Flow" = 2)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							DefMult = 1.3
						if(2)
							passives = list("KillerInstinct" = 0.5 , "Flow" = 3, "Omnipotent" = 1)
							OffMult = 1.3
							SpdMult = 1.1
						if(3)
							passives = list("MortalStrike" = 2, "MaimStrike" = 4, "Maki" = 1)
							StrMult = 1.3
							OffMult = 1
						if(4)
							passives = list("HolyMod" = 2, "PUSpike" = 5, "Instinct" = 3)
							DefMult = 1.3 
							EndMult = 1.2

				if(3)
					switch(usr.whichDiary)
						if(1)
							passives = list("Desperation" = 3, "Flow" = 2)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)							
							DefMult = 1.2
						if(2)
							passives = list("Desperation" = 1, "KillerInstinct" = 2 , "Flow" = 4, "Omnipotent" = 1)
							OffMult = 1.4
							SpdMult = 1.2
						if(3)
							passives = list("VoidField" = 2, "MortalStrike" = 2, "MaimStrike" = 4, "Maki" = 1)
							StrMult = 1.4
							OffMult = 1
						if(4)
							passives = list("HolyMod" = 4, "PUSpike" = 5, "Instinct" = 3)
							DefMult = 1.4 
							EndMult = 1.2
				if(4)
					switch(usr.whichDiary)
						if(1)
							passives = list("GodKi" = 0.5,"Desperation" = 3, "Flow" = 2)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)		
							passives += list(getPassivesFutureDiary(usr) = 1)
							passives += list(getPassivesFutureDiary(usr) = 1)
							DefMult = 1.1
						if(2)
							passives = list("GodKi" = 1, "Desperation" = 1, "KillerInstinct" = 3 , "Flow" = 4, "Omnipotent" = 1)
							OffMult = 1.6
							SpdMult = 1.4
						if(3)
							passives = list("GodKi" = 1, "DeathField" = 4, "VoidField" = 3, "MortalStrike" = 2, "MaimStrike" = 4, "Maki" = 1)
							StrMult = 1.5
							OffMult = 1
						if(4)
							passives = list("HolyMod" = 4, "PUSpike" = 5, "Instinct" = 3)
							DefMult = 1.6 
							EndMult = 1.3
		src.Trigger(usr)
///
///	Skills
///
/obj/Skills/Queue/HeartStab
	NoWhiff=1
	Warp = 1
	DamageMult = 5
	SpeedStrike = 1
	Decider = 1
	AccuracyMult = 1.175	
	Cooldown=120
	EnergyCost=5
	verb/Heart_Stab()
		set category="Skills"
		usr.SetQueue(src)

/obj/Skills/AutoHit/MurderGaze
	PassThrough = 1
	Distance=4
	Area = "Circle"
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Afraid"
	Cooldown = 60
	StrOffense = 1
	DamageMult = 1.5
	verb/Murder_Gaze()
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Projectile/ChaosShot
	Dodgeable=0
	Immediate=1
	DamageMult=7
	Distance=20
	Paralyzing=2
	Cooldown=90
	StrRate=1.5
	ForRate=0
	IconLock='Icons/Blasts/Arrow - Bolt.dmi'
	verb/Chaos_Shot()
		set category="Skills"
		usr.UseProjectile(src)

/obj/Skills/Queue/PeaceRetreat
	Counter = 1
	Opener = 1
	DamageMult = 2
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/Buff/Retreat"

///
/// Slotless Buffs
///

/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/DetectivesHunch
	NeedsHealth = 50
	TooMuchHealth = 75
	SureDodgeTimerLimit	= 5
	passives = list("Godspeed" = 1, "Flow" = 1)


/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/FutureRead
	NeedsHealth = 25
	TooMuchHealth = 40
	SureDodgeTimerLimit = 10

/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/PerfectReading
	NeedsHealth = 40
	TooMuchHealth = 80
	SureDodgeTimerLimit = 50
	passives = list("Flow" = 5)



/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/Desperation
	TooMuchHealth = 50
	NeedsHealth = 25
	name = "Desperation"
	OffMult = 1.5
	DefMult = 1.5


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Afraid
	DefMult = 0.95
	EndMult = 0.85
	IconLock = 'SweatDrop.dmi'
	TimerLimit = 15

/obj/Skills/Buffs/SlotlessBuffs/FutureDiary/Buff/Retreat
	name = "Retreat"
	DefMult = 1.2


/// 					
/// Skills / buffs	
/// 

// main gimbo
// /obj/Skills/Buffs/SpecialBuff/futureDiary
// 	ManaGlow="#e99cdf"
// 	ManaGlowSize = 1
// 	OffMult=1.1
// 	DefMult=1.1	
// 	SpecialSlot=1
// 	TextColor="#FE4B87"
// 	LockX=0
// 	LockY=0
// 	ActiveMessage="is filled with the future knowledge..!!"
// 	OffMessage="loses their control of the future..!!"
// 	name = "Future Diary"
// 	BuffName="Future Diary"
// 	Cooldown = 360
// 	verb/Future_Diary()
// 		set category="Skills"
// 		if(!usr.BuffOn(src))
// 			switch(usr.futureDiaryLevel)
// 				if(1)
// 					switch(usr.whichDiary)
// 						if(1)
// 							passives = list("Instinct" = 2, "Flow" = 2)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 						if(2)
// 							passives = list("Instinct" = 2, "Flow" = 3 )
// 						if(3)
// 							passives = list("Instinct" = 3, "Flow" = 2)
// 						if(4)
// 							passives = list("Instinct" = 2, "Flow" = 2, "Maimstrike" = 1)
// 				if(2)
// 					switch(usr.whichDiary)
// 						if(1)
// 							passives = list ("Instinct" = 2, "Flow" = 2)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 						if(2)
// 							passives += list("Flow" = 4, "Godspeed" = 1, "Instinct" = 3)
// 						if(3)
// 							passives += list("LikeWater" = 3, "Godspeed" = 3, "Instinct" = 3, "Flow" = 2)
// 						if(4)
// 							passives += list("Instinct" = 2, "Flow" = 2, "Maimstrike" = 1, "Unstoppable" = 1)
// 				if(3)
// 					switch(usr.whichDiary)
// 						if(1)
// 							passives = list("GodKi" = 1, "Instinct" = 5, "Flow" = 5)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)	
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 							passives += list(getPassivesFutureDiary() = 1)
// 						if(2)
// 							passives = list("GodKi" = 1,"Flow" = 4, "Godspeed" = 1, "Instinct" = 4,"CriticalChance" = 4, "TechniqueMastery" = 4)
// 						if(3)
// 							passives = list("GodKi" = 1, "LikeWater" = 4, "Godspeed" = 6, "Instinct" = 4, "Flow" = 4, "HolyMod" = 4)
// 						if(4)	
// 							passives = list("GodKi" = 1, "Instinct" = 4, "Flow" = 3, "Maimstrike" = 1, "Unstoppable" = 3, "AbyssMod" = 4)
// 		src.Trigger(usr)
// // maim strike knife move.
// /obj/Skills/AutoHit/HeartStab
// 	SignatureTechnique=1
// 	Area="Strike"
// 	NeedsSword = 1
// 	EnergyCost = 15	
// 	StrOffense = 1
// 	DamageMult = 4
// 	MaimStrike = 4
// 	Instinct = 1
// 	SpeedStrike = 1
// 	HitSparkIcon = 'Hit Effect Ripple.dmi'
// 	HitSparkIcon = 'Hit Effect Ripple.dmi'
// 	HitSparkX =- 32
// 	HitSparkY =- 32
// 	HitSparkTurns = 0
// 	HitSparkSize = 1
// 	Cooldown = 120
// 	ActiveMessage = "begins to stab their opponent constantly against their chest!"
// 	verb/Heart_Stab()
// 		set category="Skills"
// 		usr.Activate(src)

// // yuno gasai stuff.
// /obj/Skills/Queue/LoveStab
// 	SignatureTechnique=1
// 	NeedsSword = 1
// 	HitMessage="lunges at their love-interest, stabbing them over and over again...!!"
// 	DamageMult = 2.5
// 	AccuracyMult = 1.175
// 	NoWhiff = 1
// 	MultiHit = 5
// 	Duration=5
// 	Instinct=2
// 	Warp=2
// 	Cooldown=120
// 	EnergyCost=5
// 	verb/Love_Stab()
// 		set category="Skills"
// 		usr.SetQueue(src)

// // detective stuff here.
// /obj/Skills/Projectile/DetectivesShot
// 	SignatureTechnique=1
// 	IconLock='Blast20.dmi'
// 	DamageMult=8
// 	Knockback=1
// 	Radius=1
// 	FireFromSelf=1
// 	FireFromEnemy=0
// 	Explode=3
// 	StrRate=1
// 	ForRate=1
// 	Dodgeable=-1
// 	Deflectable=-1
// 	HolyMod=10
// 	Distance=100
// 	Cooldown = 90
// 	verb/Detectives_Shot()
// 		set category="Skills"
// 		usr.UseProjectile(src)


// ///
// /// Admin verbs..
// /// 

/mob/Admin3/verb/Give_FutureDiary()
	set category = "Admin"
	var/mob/P = input(src, "Give Future Diary to who?") in players
	if (P.futureDiaryLevel < 4)
		levelUpDiary(P)
	else 
		usr << "They are at the max level."