#define KIT_RESIST_TIME 30
#define KIT_BLEED_RESIST 2.5
#define KIT_SALVE_RESIST 2.5
#define KIT_AUTOINJECT_TIME 300
#define KIT_SPRAY_CD 30
#define KIT_AUTOINJECT_CD 30
#define KIT_DEFIB_CD 60

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Coagulated
	name = "Coagulated"
	BuffName = "Coagulated"
	AlwaysOn = 0
	NeedsPassword = 0
	MagicNeeded = 0
	Cooldown = 0
	TimerLimit = KIT_RESIST_TIME
	passives = list("BleedResist" = KIT_BLEED_RESIST)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Salved
	name = "Salved"
	BuffName = "Salved"
	AlwaysOn = 0
	NeedsPassword = 0
	MagicNeeded = 0
	Cooldown = 0
	TimerLimit = KIT_RESIST_TIME
	passives = list("ChillResist" = KIT_SALVE_RESIST, "CrippleResist" = KIT_SALVE_RESIST, "ShearResist" = KIT_SALVE_RESIST)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Autoinjector_Primed
	name = "Autoinjector Primed"
	BuffName = "Autoinjector Primed"
	AlwaysOn = 0
	NeedsPassword = 0
	MagicNeeded = 0
	Cooldown = 0
	TimerLimit = KIT_AUTOINJECT_TIME
	passives = list()

mob/proc/KitBuffOn(path)
	var/obj/Skills/Buffs/B = FindSkill(path)
	return (B && BuffOn(B)) ? B : null

mob/proc/KitApplyBuff(path)
	var/obj/Skills/Buffs/B = findOrAddSkill(path)
	if(!B) return 0
	if(BuffOn(B)) B.Trigger(src, TRUE)
	B.Timer = 0
	B.Trigger(src, TRUE)
	return BuffOn(B) ? 1 : 0

mob/proc/KitAlready(mob/user, what)
	if(user == src)
		user << "<font color='#ff6b6b'>You've already had [what] applied!</font>"
	else
		user << "<font color='#ff6b6b'>They've already had [what] applied!</font>"
	return 0

mob/proc/KitCoagulant(mob/user)
	if(KitBuffOn(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Coagulated)) return KitAlready(user, "coagulant")
	Bleed = 0
	KitApplyBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Coagulated)
	src << "<font color='#78eb78'>The bleeding stops.</font>"
	return 1

mob/proc/KitSalve(mob/user)
	if(KitBuffOn(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Salved)) return KitAlready(user, "salve")
	Slow = 0
	Crippled = 0
	Sheared = 0
	KitApplyBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Salved)
	src << "<font color='#78eb78'>The salve eases your limbs.</font>"
	return 1

mob/proc/KitAutoinjectFire()
	Bleed = 0
	if(KOTimer > 0) KOTimer = max(1, round(KOTimer / 2))
	src << "<font color='#78eb78'>A stimulant floods your system. You will come to sooner.</font>"

mob/proc/KitAutoinject(mob/user)
	if(KO)
		KitAutoinjectFire()
		if(user != src) user << "You drive the autoinjector into [src]."
		return 1
	if(KitBuffOn(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Autoinjector_Primed)) return KitAlready(user, "an autoinjector")
	KitApplyBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Autoinjector_Primed)
	src << "<font color='#78eb78'>An autoinjector is primed against your skin. It fires by itself if you go down.</font>"
	return 1

/strikeHook/Autoinjector
	stage = "ko"

	fire(strike/S)
		var/mob/M = S ? S.defender : null
		if(!M) return
		var/obj/Skills/Buffs/B = M.KitBuffOn(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Autoinjector_Primed)
		if(!B) return
		B.Trigger(M, TRUE)
		M.KitAutoinjectFire()

/obj/Items/Tech/Coagulant_Spray
	name = "Coagulant Spray"
	TechType = "Medicine"
	SubType = "Fast Acting Medicine"
	icon = 'device.dmi'
	icon_state = "health"
	desc = "Stops bleeding at once. For thirty seconds afterward, new wounds bleed less."
	Stackable = 1
	BeltUsable = 1
	BeltCooldown = KIT_SPRAY_CD
	BeltAlly = 1

	BeltUse(mob/user)
		if(!user) return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
		var/mob/T = user.belt_receiver ? user.belt_receiver : user
		return T.KitCoagulant(user)

/obj/Items/Tech/Restorative_Salve
	name = "Restorative Salve"
	TechType = "Medicine"
	SubType = "Fast Acting Medicine"
	icon = 'device.dmi'
	icon_state = "health2"
	desc = "Clears chill, cripple and shear at once. For thirty seconds afterward, new stacks of all three land lighter."
	Stackable = 1
	BeltUsable = 1
	BeltCooldown = KIT_SPRAY_CD
	BeltAlly = 1

	BeltUse(mob/user)
		if(!user) return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
		var/mob/T = user.belt_receiver ? user.belt_receiver : user
		return T.KitSalve(user)

/obj/Items/Tech/Emergency_Autoinjector
	name = "Emergency Autoinjector"
	TechType = "Medicine"
	SubType = "Trauma Care"
	icon = 'device.dmi'
	icon_state = "bloodinj"
	desc = "On someone knocked out, it stops their bleeding and halves the time until they get up. On anyone else, it stays primed for five minutes and fires by itself the moment they go down."
	Stackable = 1
	BeltUsable = 1
	BeltCooldown = KIT_AUTOINJECT_CD
	BeltAlly = 1

	BeltUse(mob/user)
		if(!user) return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
		var/mob/T = user.belt_receiver ? user.belt_receiver : user
		return T.KitAutoinject(user)

/obj/Items/Tech/Defibrillator
	name = "Defibrillator"
	TechType = "Medicine"
	SubType = "Medkits"
	icon = 'device.dmi'
	icon_state = "defib"
	desc = "A reusable device. On an ally who is knocked out, it halves the time until they get up."
	BeltUsable = 1
	BeltConsumes = 0
	BeltCooldown = KIT_DEFIB_CD
	BeltAlly = 1

	BeltUse(mob/user)
		if(!user) return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
		var/mob/T = user.belt_receiver ? user.belt_receiver : user
		if(T == user || !T.KO)
			user << "<font color='#ff6b6b'>The defibrillator only helps someone who is knocked out.</font>"
			return 0
		if(T.KOTimer > 0) T.KOTimer = max(1, round(T.KOTimer / 2))
		OMsg(user, "[user] shocks [T] with a defibrillator!")
		return 1
