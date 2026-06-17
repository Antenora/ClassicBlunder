/*
Mentor Angels will have 4 tiers of styles:
t1: Selfless State
t2: Ultra Instinct (In-Training)
t3: Perfected Ultra Instinct
t4: Permanent Ultra Instinct

Guardian Angels should gain buffs that equip them with the Armor of God:

t1: the Belt of Truth
t2: the Breastplate of Righteousness and the Sandals of the Gospel of Peace,
t3: the Helmet of Salvation and the Shield of Faith
t4: the Sword of the Spirit (the Word of God)


These will be considered Sagas for Angels but lack 6 tiers.
*/

mob/proc/GrantGuardianItem(path)
	if(!path) return
	var/obj/Items/I = locate(path) in src.contents
	if(!I)
		I = new path
		I.Move(src)
		I.AlignEquip(src)
		I.Owner = src.key
		src << "<font color='#bfefff'><b>[I.name]</b> manifests in radiant light!</font>"
	else
		I.AlignEquip(src)
mob/proc/ReclaimGuardianItem(path)
	if(!path) return
	if(locate(path) in src.contents)
		src << "[path] is already in your possession."
		return
	var/obj/Items/I
	for(var/obj/Items/G in world)
		if(istype(G, path) && G.Owner == src.key)
			I = G
			break
	if(I)
		I.Move(src)
		src << "<font color='#bfefff'><b>[I.name]</b></font> returns to your side in a flash of light!"
		return
	I = new path(src)
	I.Owner = src.key
	I.AlignEquip(src)
	src << "<font color='#bfefff'><b>[I.name]</b></font> rematerializes from the heavens!"
obj/Skills/Utility/Recall_Armaments
	verb/Recall_Armaments()
		set category="Utility"
		set name = "Recall Armaments"
		if(usr.Dead && !usr.KeepBody)
			usr << "You cannot summon divine artifacts while dead."
			return
		usr.ReclaimGuardianItem(/obj/Items/Sword/Guardian/Sword_of_the_Saint)
		if(usr.AscensionsAcquired >= 1)
			usr.ReclaimGuardianItem(/obj/Items/Wearables/Guardian/Belt_of_Truth)
		if(usr.AscensionsAcquired >= 2)
			usr.ReclaimGuardianItem(/obj/Items/Armor/Guardian/Breastplate_of_Righteousness)
			usr.ReclaimGuardianItem(/obj/Items/Wearables/Guardian/Sandals_of_Peace)
		if(usr.AscensionsAcquired >= 3)
			usr.ReclaimGuardianItem(/obj/Items/Wearables/Guardian/Helmet_of_Salvation)
			usr.ReclaimGuardianItem(/obj/Items/Wearables/Guardian/Shield_of_Faith)
		if(usr.AscensionsAcquired >= 4)
			usr.ReclaimGuardianItem(/obj/Items/Sword/Guardian/Sword_of_the_Spirit)
		OMsg(usr, "[usr] calls their sacred armaments home in a blaze of holy light!")

//no ascensions
/obj/Items/Sword/Guardian/Sword_of_the_Saint
	passives = list("SpiritSword" = 1)
	Class = "Medium"
	SubType = "Weapons"
	DamageEffectiveness=1.05
	AccuracyEffectiveness=0.85
	SpeedEffectiveness=1.15
	ShatterCounter=800
	ShatterMax=800
	Ascended = 6
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Sword of the Saint"
	desc = "The Saint’s dulled edge that keeps the peace."
	icon = 'Samurai_sword_3.dmi'
//ascension 1
/obj/Items/Wearables/Guardian/Belt_of_Truth
	passives = list("Persistence" = 4)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Belt of Truth"
	desc = "A radiant girdle that binds the wearer's soul to truth."
	icon = 'MachoBrace.dmi'
//ascension 2
/obj/Items/Armor/Guardian/Breastplate_of_Righteousness
	passives = list("Juggernaut" = 3, "GiantForm" = 1, "Steady" = 5)
	Ascended = 6
	Class = "Medium"
	SubType = "Armor"
	DamageEffectiveness=0.75
	AccuracyEffectiveness=0.95
	SpeedEffectiveness=0.85
	ShatterCounter=800
	ShatterMax=800
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Breastplate of Righteousness"
	desc = "A shining cuirass that shields the heart with virtue."
	icon = 'ArmorLight-White.dmi'
/obj/Items/Wearables/Guardian/Sandals_of_Peace
	passives = list("MovementMastery" = 10, "Purity" = 1, "BeyondPurity" = 1)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Sandals of the Gospel of Peace"
	desc = "Winged sandals that carry serenity wherever you tread."
	icon = 'shoes_mono.dmi'
//ascension 3
/obj/Items/Wearables/Guardian/Helmet_of_Salvation
	passives = list("DebuffResistance" = 3,  "LifeGeneration" = 2, "Anaerobic" = 2, "Pressure" = 5)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Helmet of Salvation"
	desc = "A helm of light that guards the mind with divine insight."
	icon = 'goldsaintlibra_helmet.dmi'
/obj/Items/Wearables/Guardian/Shield_of_Faith
	passives = list("BlockChance" = 25, "CriticalBlock" = 0.2)
	Techniques = list(new/obj/Skills/Buffs/SpecialBuffs/Aphotic_Shield)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Shield of Faith"
	desc = "A radiant shield forged from unwavering belief."
	icon = 'Shield of Faith.dmi'
//ascension 4
/obj/Items/Sword/Guardian/Sword_of_the_Spirit
	Techniques = list(new/obj/Skills/Buffs/SpecialBuffs/The_Ten_Commandments, new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/The_Word_Of_God)
	passives = list("SweepingStrike" = 1, "SpiritSword" = 1, "BlurringStrikes" = 3, "DoubleStrike" = 1, "TripleStrike" = 1)
	Class = "Medium"
	SubType = "Weapons"
	DamageEffectiveness=1.1
	AccuracyEffectiveness=0.95
	SpeedEffectiveness=1.25
	ShatterCounter=800
	ShatterMax=800
	Ascended = 6
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Sword of the Spirit (The Word of God)"
	desc = "The Word made blade - the Spirit’s edge that severs falsehood."
	icon = 'Samurai_sword_3.dmi'



//MENTOR ANGEL STUFF UNDER THIS POINT. DO NOT CALL FAVORITISM BECAUSE IT GOT DONE FIRST!!!! THIS WAS A COMMAND BY OUR DIVINE OVERLORD!
/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles
	Selfless_State //placeholder because I might implement the Demon Slayer thing. basically baby UI
		Copyable=0
		passives = list("Flow" = 2, "Deflection" = 1, "SoftStyle" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StyleSpd=1.15
		StyleDef=1.15
		Finisher = "/obj/Skills/Queue/Finisher/Instinct_Palm"
		IconLock='AuraMysticBig.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=1
		NoSword=1
		StyleActive="Selfless State"
		verb/Selfless_State()
			set hidden=1
			src.Trigger(usr)
	Incomplete_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StyleStr=1.15
		StyleFor=1.15
		StyleSpd=1.45
		StyleOff=1.45
		StyleDef=1.45
		Finisher = "/obj/Skills/Queue/Finisher/Instinct_Palm"
		IconLock='AuraMysticBig.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=2
		NoSword=1
		StyleActive="Ultra Instinct (In-Training)"
		verb/Incomplete_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Ultra_Instinct
		Copyable=0
		passives = list("Flow" = 3, "Deflection" = 1, "SoftStyle" = 1, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1, "UnarmedDamage"=4)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StyleStr=1.35
		StyleFor=1.35
		StyleSpd=1.75
		StyleOff=1.75
		StyleDef=1.75
		Finisher = "/obj/Skills/Queue/Finisher/Heavenly_Palm_Transcendence"
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=3
		NoSword=1
		StyleActive="Ultra Instinct (Complete)"
		adjust(mob/p)
			passives = list("Flow" = 3, "Deflection" = 1, "SoftStyle" = 1, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1, "BlurringStrikes"=4, "UnarmedDamage"=4)
			StyleStr=1.35
			StyleFor=1.35
			StyleSpd=1.75
			StyleOff=1.75
			StyleDef=1.75
		verb/Ultra_Instinct()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Perfected_Ultra_Instinct //I hope this is as gorked as I intend it on being.
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "LikeWater" = 4, "Flow" = 4, "Instinct" = 4, "CounterMaster" = 5, "Godspeed" = 1)
		NeedsSword=0
		NeedsStaff=0
		NoSword=0
		NoStaff=0
		StyleStr=1.45
		StyleFor=1.45
		StyleSpd=2
		StyleOff=2
		StyleDef=2
		Finisher = "/obj/Skills/Queue/Finisher/Heavenly_Palm_Transcendence"
		IconLock='GentleDivine.dmi'
		IconLockBlend=4
		LockX=-32
		LockY=-32
		SagaSignature = 1
		SignatureTechnique=4
		NoSword=1
		StyleActive="Perfected Ultra Instinct"
		adjust(mob/p)
			passives = list("Deflection" = 1, "SoftStyle" = 1, "LikeWater" = 4, "Flow" = 4, "Instinct" = 4, "CounterMaster" = 5, "Godspeed" = 1, "BlurringStrikes"=4)
			StyleStr=1.45
			StyleFor=1.45
			StyleSpd=2
			StyleOff=2
			StyleDef=2
		verb/Perfected_Ultra_Instinct()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
