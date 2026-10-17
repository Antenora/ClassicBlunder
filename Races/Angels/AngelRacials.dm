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
		set hidden = 1
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
	passives = list("Juggernaut" = 3, "GiantForm" = 1)
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
	passives = list( "Purity" = 1)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Sandals of the Gospel of Peace"
	desc = "Winged sandals that carry serenity wherever you tread."
	icon = 'shoes_mono.dmi'
//ascension 3
/obj/Items/Wearables/Guardian/Helmet_of_Salvation
	passives = list("LifeGeneration" = 2, "Anaerobic" = 2)
	Augmented = 1
	Stealable = 0
	Destructable = 0
	name = "Helmet of Salvation"
	desc = "A helm of light that guards the mind with divine insight."
	icon = 'goldsaintlibra_helmet.dmi'
/obj/Items/Wearables/Guardian/Shield_of_Faith
	passives = list("CriticalBlock" = 0.2)
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
	passives = list("SweepingStrike" = 1,   "DoubleStrike" = 1, "TripleStrike" = 1)
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
