/mob/proc/NamekDemonMarkOn(mob/T)
	return ismob(T) && T.mark_vuln_by == src && T.mark_vuln_until > world.time

/obj/Skills/Utility/Namekian/Demon_Mark
	name = "Demon Mark"
	desc = "Brand your target with the demon mark for ten seconds: they take 10 percent more damage from you, and your Finger Beam homes in on them."
	Copyable = 0
	Cooldown = 20
	EnergyCost = 1
	var/MarkRange = 10
	var/MarkDuration = 100
	var/MarkAmp = 0.1

	verb/Demon_Mark()
		set name = "Demon Mark"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekCastDemonMark(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Demon_Mark
	name = "Demon Mark"
	BuffName = "Demon Mark"
	AlwaysOn = 0
	NeedsPassword = 0
	Cooldown = 0
	TimerLimit = 10
	Copyable = 0
	ActiveMessage = "is branded with the demon mark!"
	OffMessage = "is no longer branded."

/mob/proc/NamekCastDemonMark(obj/Skills/Utility/Namekian/Demon_Mark/M)
	if(!M || !src.CanUseSkill(M))
		return
	var/mob/T = src.Target
	if(!NamekFoeInReach(T, M.MarkRange, M))
		return
	M.Cooldown(1, null, src)
	NamekPayEnergy(M)
	T.mark_vuln_by = src
	T.mark_vuln_until = world.time + M.MarkDuration
	T.mark_vuln_amp = M.MarkAmp
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Demon_Mark/D = T.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Demon_Mark)
	if(D)
		D.TimerLimit = M.MarkDuration / 10
		if(T.BuffOn(D))
			D.Timer = 0
		else
			D.Trigger(T, TRUE)
	src.OMessage(10, "[src] brands [T] with the demon mark!", "<font color=red>[src]([src.key]) uses Demon Mark on [T]([T.key]).")

/obj/Skills/Projectile/Namekian/Makosen
	name = "Makosen"
	desc = "Fire a decoy demon wave, then the real one 0.7 seconds later along the same line."
	Copyable = 0
	SignatureTechnique = 0
	Distance = 50
	DamageMult = 1.9
	AccMult = 1.15
	Blasts = 1
	MenuIcon = "Makosen"
	EnergyCost = 3
	Cooldown = 12
	Radius = 2
	Explode = 1
	Knockback = 1
	LosesHoming = 0
	Speed = 1
	LaunchForward = 11.5
	LaunchUp = 0.5
	IconLock = ENERGYFX_HIT_MAKOSEN
	IconSize = 3.4
	ActiveMessage = "fires a staggered double wave of demon light!"
	var/MakosenDecoy = 0.95
	var/MakosenReal = 2.85
	var/MakosenGap = 7

	proc/NamekMakosenWave(mob/caster, turf/o, d, dmg)
		var/obj/Skills/Projectile/Namekian/Makosen/W = new
		W.TempDamage = dmg
		W.SpawnPosition = o
		new /obj/Skills/Projectile/_Projectile(caster, W, o, 0.5, 0, 0, d)

	verb/Makosen()
		set name = "Makosen"
		set category = "Skills"
		var/mob/caster = usr
		if(!caster.CanUseSkill(src))
			return
		src.Cooldown(1, null, caster)
		caster.NamekPayEnergy(src)
		OMsg(caster, "<b><font color='[ActiveColor]'>[caster] [ActiveMessage]</font color></b>")
		var/turf/o = get_turf(caster)
		var/d = caster.dir
		if(!o || !d)
			return
		NamekMakosenWave(caster, o, d, MakosenDecoy)
		spawn(MakosenGap)
			if(caster && !caster.KO)
				NamekMakosenWave(caster, o, d, MakosenReal)

/obj/Skills/AutoHit/Namekian/Dont_Get_Cocky
	name = "Don't Get Cocky"
	desc = "A furious kiai that blasts your target back two tiles and dazes them for half a second."
	Copyable = 0
	Area = "Target"
	Distance = 3
	ForScaling = 1
	DamageMult = 0.6
	Knockback = 5
	Stunner = 0.5
	Cooldown = 12
	EnergyCost = 1
	Shockwave = 1
	Shockwaves = 1
	PostShockwave = 1
	ActiveMessage = "roars and blasts their foe back!"

	verb/Dont_Get_Cocky()
		set name = "Don't Get Cocky"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Utility/Namekian/Dragon_Ball_Sense
	name = "Dragon Ball Sense"
	desc = "Feel for the nearest Dragon Ball lying on this world, any set: its direction and distance."
	Copyable = 0
	Cooldown = 60

	verb/Dragon_Ball_Sense()
		set name = "Dragon Ball Sense"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekSenseDragonBall(src)

/proc/NamekDragonSetMaker(obj/Items/DragonBall/B)
	if(!B || !glob || !("NamekDragonSets" in glob.vars))
		return null
	var/list/sets = glob.vars["NamekDragonSets"]
	if(!islist(sets) || !(B.set_id in sets))
		return null
	var/list/entry = sets[B.set_id]
	if(!islist(entry))
		return null
	return entry["maker_name"]

/mob/proc/NamekSenseText()
	var/turf/here = get_turf(src)
	var/obj/Items/DragonBall/B = NearestDragonBall(here)
	if(!B)
		return "You reach out, but sense no Dragon Ball on this world."
	var/maker = NamekDragonSetMaker(B)
	var/d = get_dist(here, B)
	var/where = d ? "to the [src.CheckDirection(B)], [Commas(d)] tiles away" : "right where you stand"
	return "You sense a Dragon Ball[maker ? " of [maker]'s set" : ""] [where]."

/mob/proc/NamekSenseDragonBall(obj/Skills/Utility/Namekian/Dragon_Ball_Sense/S)
	if(!S || S.Using || S.cooldown_remaining)
		src << "[S] is on cooldown."
		return
	S.Cooldown(1, null, src)
	src << "<font color=#77cc77>[NamekSenseText()]</font>"

/obj/Skills/Projectile/Namekian/Soumasen
	name = "Soumasen"
	desc = "Spray a scatter of five finger beams."
	Copyable = 0
	DamageMult = 0.5
	Blasts = 5
	Delay = 1
	Variation = 24
	Cooldown = 18
	EnergyCost = 3
	Knockback = 0
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "sprays a scatter of finger beams!"

	verb/Soumasen()
		set name = "Soumasen"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Utility/Namekian/Regrow
	var/EternalYouthMult = 0.5

	adjust(mob/p)
		if(p && p.NamekPath == NAMEK_PATH_DEMON_KING && p.AscensionsAcquired >= 4)
			Cooldown = initial(Cooldown) * EternalYouthMult
		else
			Cooldown = initial(Cooldown)
