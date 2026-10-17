#define QUINCY_T_JUMP_RANGE 6
#define QUINCY_T_JUMP_MULT 0.3
#define QUINCY_T_JUMP_SHOCK 2
#define QUINCY_T_GALVANO_FATIGUE 1

mob/var/tmp/LightningJumpArmed = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/T_The_Thunderbolt/New()
	..()
	kit_skills = list(/obj/Skills/Projectile/Quincy/Galvano_Blast, /obj/Skills/Projectile/Quincy/Galvano_Javelin, /obj/Skills/Quincy/Lightning_Jump, /obj/Skills/Projectile/Quincy/Electrocution)

/proc/ThunderLineTurfs(turf/origin, turf/dest)
	var/list/out = list()
	if(!isturf(origin) || !isturf(dest) || origin.z != dest.z)
		return out
	var/turf/t = origin
	var/guard = 0
	while(t && t != dest && guard < 64)
		t = get_step_towards(t, dest)
		if(t)
			out += t
		guard++
	return out

/mob/proc/ThunderboltRedraw()
	var/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/W = locate() in src
	if(!W || !src.BuffOn(W))
		return 0
	W.Trigger(src, 1)
	if(src.BuffOn(W))
		return 0
	W.Trigger(src, 1)
	return src.BuffOn(W) ? 1 : 0

/mob/proc/GalvanoFatigue()
	if(!QuincyVollstandigOnNow())
		return 0
	src.TotalFatigue = min(100, src.TotalFatigue + QUINCY_T_GALVANO_FATIGUE)
	src.MaxEnergy()
	return 1

/mob/proc/GalvanoFire(obj/Skills/Projectile/P, needs_target = 0)
	if(!SchriftNeeded("T"))
		src << "Only the bearer of The Thunderbolt can call the lightning."
		return 0
	if(needs_target && !XAxisTarget())
		src << "[P] needs a target."
		return 0
	var/stamp = P.cooldown_start_wt
	src.UseProjectile(P)
	if(!P.Using || P.cooldown_start_wt == stamp)
		return 0
	GalvanoFatigue()
	return 1

/mob/proc/LightningJumpFoes(list/line)
	var/list/out = list()
	for(var/turf/t in line)
		for(var/mob/m in t)
			if(!(m in out) && QuincyAreaFoe(m, src))
				out += m
	return out

/mob/proc/QuincyLightningJump(turf/dest, obj/Skills/Quincy/Lightning_Jump/s)
	var/turf/origin = get_turf(src)
	if(!origin || !isturf(dest))
		return 0
	var/list/line = ThunderLineTurfs(origin, dest)
	var/list/foes = LightningJumpFoes(line)
	VanishImage(src)
	var/formerdir = src.dir
	src.Move(dest)
	src.dir = formerdir
	if(get_turf(src) != dest)
		return 0
	ShadowPrewarm(src)
	if(s)
		if(s.ManaCost)
			src.LoseMana(s.ManaCost)
		s.Cooldown(1, null, src)
	LightningStrike2(src)
	var/hits = 0
	for(var/mob/m in foes)
		if(!src)
			break
		if(!m || m.z != src.z)
			continue
		LightningStrike2(m)
		QuincyAreaHit(src, m, s ? s.line_mult : QUINCY_T_JUMP_MULT)
		if(m)
			m.AddShock(s ? s.line_shock : QUINCY_T_JUMP_SHOCK, src)
		hits++
	if(src)
		OMsg(src, "[src] tears across the ground as a bolt of lightning!")
	return hits

turf/Click(turf/T)
	if(!usr || !usr.client || !usr.LightningJumpArmed)
		return ..()
	var/obj/Skills/Quincy/Lightning_Jump/s = locate(/obj/Skills/Quincy/Lightning_Jump) in usr.contents
	if(!s || !usr.SchriftNeeded("T"))
		usr.LightningJumpArmed = 0
		return ..()
	if(usr.Admin >= 4 && usr.AdminOverwatchActive)
		return ..()
	if(usr.Target && istype(usr.Target, /obj/Others/Build))
		return ..()
	if(usr.client.macros && usr.client.macros.IsPressed("Ctrl"))
		return ..()
	if(!usr.Move_Requirements() || usr.KO)
		return ..()
	if(!T || !T.icon)
		return
	if(src == get_turf(usr))
		return
	if(!usr.QuincyWeaponDrawn())
		usr << "Draw your Spirit Weapon first."
		return
	if(get_dist(usr, src) > s.jump_range || usr.z != src.z)
		usr << "<font color='red'>Too far to strike there.</font>"
		return
	if(T.density || usr.icon_state == "Meditate" || usr.Observing || usr.Beaming == 2)
		return
	if(s.Charges <= 0)
		usr << "Lightning Jump has no charges left."
		return
	if(s.ManaCost && usr.ManaAmount < s.ManaCost)
		usr << "You need [s.ManaCost] Mana to leap as lightning."
		return
	usr.QuincyLightningJump(src, s)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig) && SchriftNeeded("T"))
		if(ThunderboltRedraw())
			OMsg(src, "Six wings of lightning split into blades in [src]'s hands!")

/mob/Players/AllSkillsRemove(obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig) && SchriftNeeded("T"))
		ThunderboltRedraw()

/mob/Players/QuincySyncSkills()
	..()
	if(src.LightningJumpArmed && !SchriftNeeded("T"))
		src.LightningJumpArmed = 0

/obj/Skills/Quincy/Lightning_Jump
	name = "Lightning Jump"
	desc = "Toggle. While armed, click a tile within 6 tiles: you leap there as lightning, and every foe on the line you crossed is struck and shocked. 2 charges, one back every 12 seconds."
	MaxCharges = 2
	Charges = 2
	ChargeRefresh = 12
	ManaCost = 3
	Copyable = 0
	var/jump_range = QUINCY_T_JUMP_RANGE
	var/line_mult = QUINCY_T_JUMP_MULT
	var/line_shock = QUINCY_T_JUMP_SHOCK

	verb/Lightning_Jump()
		set name = "Lightning Jump"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		if(!User.SchriftNeeded("T"))
			User << "Only the bearer of The Thunderbolt can leap as lightning."
			User.LightningJumpArmed = 0
			return
		User.LightningJumpArmed = !User.LightningJumpArmed
		if(User.LightningJumpArmed)
			User << "Lightning Jump armed. ([src.Charges]/[src.MaxCharges] charges)"
		else
			User << "Lightning Jump disarmed."

/obj/Skills/Projectile/Quincy/Galvano_Blast
	name = "Galvano Blast"
	desc = "Bolts of lightning fall from the sky around your target and paralyze what they strike. In Barbarriel each use costs 1 Fatigue."
	ZoneAttack = 1
	ZoneAttackX = 12
	ZoneAttackY = 12
	FireFromEnemy = 1
	FireFromSelf = 0
	Blasts = 5
	Delay = 2
	Hover = 10
	StormFall = 1
	HyperHoming = 1
	ignoreBetterAim = TRUE
	Speed = 1
	Distance = 18
	DropDistance = 16
	DamageMult = 0.6
	Paralyzing = 1
	Cooldown = 20
	ManaCost = 6
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	LockX = -19
	LockY = -19
	Variation = 0
	ActiveMessage = "calls down Galvano Blast!"

	verb/Galvano_Blast()
		set name = "Galvano Blast"
		set category = "Skills"
		usr.GalvanoFire(src, 1)

/obj/Skills/Projectile/Quincy/Galvano_Javelin
	name = "Galvano Javelin"
	desc = "Hurl a wing-sword of lightning that pierces everything in its path and shocks what it hits. In Barbarriel each use costs 1 Fatigue."
	DamageMult = 1.5
	Piercing = 1
	Shocking = 2
	Speed = 0.2
	Distance = 12
	Cooldown = 15
	ManaCost = 5
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	ActiveMessage = "hurls a Galvano Javelin!"

	verb/Galvano_Javelin()
		set name = "Galvano Javelin"
		set category = "Skills"
		usr.GalvanoFire(src)

/obj/Skills/Projectile/Quincy/Electrocution
	name = "Electrocution"
	desc = "In Barbarriel only: a column of lightning thrown in a line, three fast bolts that paralyze."
	Blasts = 3
	Delay = 1
	DamageMult = 2
	Paralyzing = 2
	Speed = 0.1
	Distance = 12
	Cooldown = 45
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 0
	ActiveMessage = "throws a column of lightning!"

	verb/Electrocution()
		set name = "Electrocution"
		set category = "Skills"
		if(!usr.SchriftNeeded("T"))
			usr << "Only the bearer of The Thunderbolt can throw this."
			return
		if(!usr.QuincyVollstandigOnNow())
			usr << "Electrocution answers only in Barbarriel."
			return
		usr.UseProjectile(src)

/proc/QuincyTestStepsT()
	return list("Jump 4 tiles ahead", "Galvano Blast target", "Galvano Javelin", "Redraw the weapon", "Arm Lightning Jump")

/mob/proc/QuincyTestT(step, mob/t)
	switch(step)
		if("Jump 4 tiles ahead")
			var/turf/d = get_turf(src)
			for(var/i = 1 to 4)
				var/turf/n = get_step(d, src.dir)
				if(!n || n.density)
					break
				d = n
			var/obj/Skills/Quincy/Lightning_Jump/s = locate() in src
			if(!s)
				s = new
			return "struck [QuincyLightningJump(d, s)]"
		if("Galvano Blast target")
			if(!t)
				return "no target"
			var/obj/Skills/Projectile/Quincy/Galvano_Blast/S = locate() in src
			if(!S)
				S = new
			return "fired [GalvanoFire(S, 1)]"
		if("Galvano Javelin")
			var/obj/Skills/Projectile/Quincy/Galvano_Javelin/S = locate() in src
			if(!S)
				S = new
			return "fired [GalvanoFire(S)]"
		if("Redraw the weapon")
			return "redrawn [ThunderboltRedraw()]"
		if("Arm Lightning Jump")
			src.LightningJumpArmed = 1
			return "armed"
	return "unknown step"
