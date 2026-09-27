/obj/Skills/Grapple/Hollow

/obj/Skills/Grapple/Hollow/Bone_Crusher
	name = "Bone Crusher"
	DamageMult = 2.4
	StrScaling = 1
	ThrowAdd = 0
	ThrowMult = 0
	OneAndDone = 1
	Cooldown = 8
	EnergyCost = 1
	TriggerMessage = "clamps down and grinds the bones of"
	Effect = "MuscleBuster"
	EffectMult = 1

	verb/Bone_Crusher()
		set name = "Bone Crusher"
		set category = "Skills"
		src.Activate(usr)

/obj/Skills/AutoHit/Hollow

/obj/Skills/AutoHit/Hollow/Acid_Lash
	name = "Acid Lash"
	Area = "Wave"
	Distance = 3
	StrScaling = 1
	DamageMult = 3
	Toxic = 5
	Cooldown = 5
	EnergyCost = 1
	ActiveMessage = "whips an acid-slick tail across the ground!"
	HitSparkIcon = 'Slash - Venom.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 1.5
	HitSparkTurns = 1
	HitSparkDispersion = 1
	TurfStrike = 1

	verb/Acid_Lash()
		set name = "Acid Lash"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Hollow/Hair_Spears
	name = "Hair Spears"
	Area = "Wave"
	Distance = 8
	StrScaling = 1
	DamageMult = 2.8
	Bloodletting = 3
	Cooldown = 5
	EnergyCost = 1
	ActiveMessage = "drives a bristling row of hardened hair forward!"
	HitSparkIcon = 'Slash.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 1
	HitSparkTurns = 1
	HitSparkDispersion = 1
	TurfStrike = 1

	verb/Hair_Spears()
		set name = "Hair Spears"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Hollow/Pounce
	name = "Pounce"
	Area = "Strike"
	Distance = 1
	Rush = 4
	ControlledRush = 1
	StrScaling = 1
	DamageMult = 2.5
	Launcher = 1
	Cooldown = 6
	EnergyCost = 1
	ActiveMessage = "springs off six legs and comes down on top of its prey!"
	Icon = 'roundhouse.dmi'
	IconX = -16
	IconY = -16
	Size = 1
	HitSparkIcon = 'Hit Effect.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 1.5
	HitSparkTurns = 0
	TurfStrike = 1

	verb/Pounce()
		set name = "Pounce"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Hollow/Burrow_Strike
	name = "Burrow Strike"
	Area = "Target"
	Distance = 6
	StrScaling = 1
	DamageMult = 3.2
	WindUp = 1
	Stunner = 0.8
	Cooldown = 6
	EnergyCost = 1
	WindupMessage = "sinks into the ground and disappears!"
	ActiveMessage = "erupts out of the ground underneath its prey!"
	TurfErupt = 2
	TurfEruptOffset = 3
	Earthshaking = 8
	HitSparkIcon = 'Hit Effect.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 2
	HitSparkTurns = 0
	TurfStrike = 2
	TurfShift = 'Dirt1.dmi'
	TurfShiftDuration = 3

	verb/Burrow_Strike()
		set name = "Burrow Strike"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Projectile/Hollow

/obj/Skills/Projectile/Hollow/Leech_Bombs
	name = "Leech Bombs"
	Blasts = 3
	Delay = 2
	Speed = 1
	Homing = 1
	Explode = 1
	Distance = 12
	DamageMult = 0.6
	Knockback = 0
	Cooldown = 8
	EnergyCost = 2
	ActiveMessage = "spits a string of clinging leeches!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 8

	verb/Leech_Bombs()
		set name = "Leech Bombs"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Hollow

/obj/Skills/Hollow/Devour
	name = "Devour"
	Cooldown = 300
	var
		DevourHealPercent = 15
		DevourInjury = 5

	verb/Devour()
		set name = "Devour"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(src.Using || src.cooldown_remaining > 0)
			User << "<font color=red>[src] is not ready yet.</font>"
			return
		if(User.Dead || User.KO)
			User << "<font color=red>You are in no state to feed.</font>"
			return
		var/list/prey = list()
		for(var/mob/Players/P in oview(1, User))
			if(P == User)
				continue
			if(P.Dead)
				continue
			if(!P.KO)
				continue
			prey += P
		if(!prey.len)
			User << "<font color=red>Nothing beside you is helpless enough to eat.</font>"
			return
		var/mob/Players/victim
		if(prey.len == 1)
			victim = prey[1]
		else
			var/list/labeled = PromptLabelAtoms(prey, 1)
			var/choice = Ask(User, "What do you sink your teeth into?", "Devour", null, "pick", labeled, 1)
			if(isnull(choice))
				return
			victim = labeled[choice]
		if(!victim)
			return
		if(victim.Dead || !victim.KO || get_dist(User, victim) > 1)
			User << "<font color=red>[victim] is no longer easy prey.</font>"
			return
		User.HealHealth(DevourHealPercent)
		victim.WoundSelf(DevourInjury)
		OMsg(User, "<b><font color=#8fbf3f>[User] tears a mouthful out of [victim]!</font></b>")
		User.HollowOnDevour(victim)
		src.Cooldown(1, null, User)

/mob/proc/HollowOnDevour(mob/victim)
	return

/proc/HollowPackageSkillTypes()
	var/list/out = list()
	var/list/abstract = list(/obj/Skills/Grapple/Hollow, /obj/Skills/AutoHit/Hollow, /obj/Skills/Projectile/Hollow, /obj/Skills/Projectile/Beams/Big/Hollow)
	for(var/T in typesof(/obj/Skills/Grapple/Hollow, /obj/Skills/AutoHit/Hollow, /obj/Skills/Projectile/Hollow, /obj/Skills/Projectile/Beams/Big/Hollow))
		if(T in abstract)
			continue
		out += T
	out |= /obj/Skills/Hollow/Devour
	return out

mob/Admin3/verb/Give_Hollow_Skills()
	set category = "Admin"
	set name = "Give Hollow Skills"
	var/list/paths = HollowPackageSkillTypes()
	var/added = 0
	for(var/T in paths)
		if(locate(T, usr))
			continue
		usr.AddSkill(new T)
		added++
	if(usr.client)
		usr.client.RefreshHotbar()
	usr << "<font color=yellow>Hollow skills: [added] granted, [paths.len] in the set.</font>"
	Log("Admin", "[ExtractInfo(usr)] granted themselves the Hollow skill set.")

mob/Admin3/verb/Clear_Hollow_Skills()
	set category = "Admin"
	set name = "Clear Hollow Skills"
	var/list/paths = HollowPackageSkillTypes()
	var/removed = 0
	for(var/T in paths)
		var/obj/Skills/S = locate(T, usr)
		while(S)
			usr.DeleteSkill(S)
			removed++
			S = locate(T, usr)
	if(usr.client)
		usr.client.RefreshHotbar()
	usr << "<font color=yellow>Hollow skills: [removed] removed.</font>"
	Log("Admin", "[ExtractInfo(usr)] cleared their Hollow skill set.")
