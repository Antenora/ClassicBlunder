#define HOLLOW_SPEC_REGEN_CALM 300
#define HOLLOW_SPEC_REGEN_EVERY 50
#define HOLLOW_SPEC_REGEN_PERCENT 0.5

/obj/Skills/Projectile/Arrancar/Bala
	name = "Bala"
	DamageMult = 0.8
	Distance = 6
	Speed = 0.25
	Knockback = 0
	Cooldown = 4
	ManaCost = 0.5
	CritEffectiveness = 0
	ActiveMessage = "fires a hardened bolt of pressure!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 8

	verb/Bala()
		set name = "Bala"
		set category = "Skills"
		usr.UseProjectile(src)

/mob/proc/HollowHierroValues()
	if(src.HollowSpec == "Hierro")
		return list("Harden" = 2, "Juggernaut" = 0.5)
	return list("Harden" = 1, "Juggernaut" = 0.25)

/mob/proc/HollowGrantHierro()
	if(!src.HollowArrancar)
		return
	var/list/want = src.HollowHierroValues()
	var/list/move = list()
	for(var/k in want)
		var/have = src.HollowHierroApplied ? src.HollowHierroApplied[k] : 0
		var/delta = want[k] - have
		if(delta)
			move[k] = delta
	if(move.len)
		src.passive_handler.increaseList(move)
	src.HollowHierroApplied = want.Copy()

mob/var/list/HollowHierroApplied

/obj/Skills/Buffs/SlotlessBuffs/Regeneration/High_Speed_Regeneration
	BuffName = "High-Speed Regeneration"
	ActiveMessage = "knits themself back together at high speed!"
	OffMessage = "stops regenerating."
	RegenerateLimbs = 1

	New()
		..()
		verbs -= /obj/Skills/Buffs/SlotlessBuffs/Regeneration/verb/Regenerate

	getRaceModifier(mob/p)
		if(p && p.HollowSpec == "Regeneration")
			return 1.25
		return 0.9

	verb/High_Speed_Regeneration()
		set name = "High-Speed Regeneration"
		set category = "Skills"
		src.Trigger(usr)

/obj/Skills/Hollow/Specialize
	name = "Specialize"
	desc = "Trade one half of your Hollow inheritance for the other."

	verb/Specialize()
		set name = "Specialize"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(!User.HollowIsHollow() || !User.HollowArrancar)
			return
		if(User.HollowSpec)
			User << "<font color=red>You have already chosen.</font>"
			return
		if(User.AscensionsAcquired < 4)
			User << "<font color=red>You are not developed enough to specialize yet.</font>"
			return
		var/list/options = list(
			"Hierro" = "Hierro: your skin hardens further. Harden 1 to 2, Juggernaut 0.25 to 0.5. Your regeneration stays where it is.",
			"Regeneration" = "Regeneration: you keep what most Arrancar trade away. A stronger burst heal and slow wound closing out of combat. Your Hierro stays where it is.")
		var/list/labels = list()
		for(var/k in options)
			labels["[k] - [options[k]]"] = k
		var/label = Ask(User, "Do you want to specialize in Hierro or High-Speed Regeneration?", "Specialize", null, "pick", labels, 1)
		if(isnull(label))
			return
		var/choice = labels[label]
		var/confirm = Ask(User, "Specialize into [choice]? This cannot be undone.", "Specialize", null, "confirm", null, 1, "Commit", "Cancel")
		if(confirm != "Commit")
			return
		spawn()
			if(!User || User.HollowSpec)
				return
			User.HollowSpec = choice
			User.HollowGrantHierro()
			User.HollowSyncSkills()
			OMsg(User, "<b><font color=#e8e8e8>[User] settles into the shape they will keep.</font></b>")

mob/var/tmp/HollowRegenNext = 0

/mob/proc/HollowRegenSpecTick()
	if(!src.HollowIsHollow() || !src.HollowArrancar || src.HollowSpec != "Regeneration")
		return
	if(src.KO || src.Dead || src.TotalInjury <= 0)
		return
	if(world.time <= src.lastHit + HOLLOW_SPEC_REGEN_CALM)
		return
	if(world.time < src.HollowRegenNext)
		return
	src.HollowRegenNext = world.time + HOLLOW_SPEC_REGEN_EVERY
	src.HealWounds(HOLLOW_SPEC_REGEN_PERCENT)

/mob/Players/GainLoop()
	..()
	HollowRegenSpecTick()
