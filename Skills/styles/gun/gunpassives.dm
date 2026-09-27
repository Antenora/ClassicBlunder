/mob/var/tmp/gun_thunder = 0
/mob/var/tmp/gun_thunder_hit = 0
/mob/var/tmp/gun_rhythm = 0
/mob/var/tmp/gun_rhythm_until = 0
/mob/var/tmp/gun_tension_pre = -1
/mob/var/tmp/mob/setup_mark_by
/mob/var/tmp/setup_mark_until = 0
/mob/var/tmp/setup_gun_mark = 0

/mob/proc/GunPassive(name)
	if(!passive_handler)
		return 0
	return passive_handler.Get(name)

/mob/proc/GunThunderDecay()
	if(gun_thunder && world.time - gun_thunder_hit > GUNP_THUNDER_WINDOW)
		gun_thunder = 0

/mob/proc/GunStyleSync()
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		return
	if(G.MagSize != G.GunMagFor())
		G.SyncMag(src)
		GunRefillSkill(G)

/mob/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	if(!S || !g || !passive_handler)
		return
	var/v = GunPassive("Living Turret")
	var/turret = v > 0 && world.time - gun_last_move >= GUNP_TURRET_IDLE
	if(turret && bloom > 0)
		GunStampShot(S, g, 0)
	if(turret)
		S.AccMult += GUNP_TURRET_ACC * v
	v = GunPassive("Cold Barrel")
	if(v > 0 && world.time - gun_last_fire >= GUNP_COLD_IDLE)
		S.DamageMult *= 1 + GUNP_COLD_DMG * v
		S.AccMult += GUNP_COLD_ACC * v
	v = GunPassive("Last Round")
	if(v > 0 && g.Loaded == 1)
		S.DamageMult *= 1 + GUNP_LAST_DMG * v
	v = GunPassive("Strafe")
	if(v > 0 && gun_last_move && world.time - gun_last_move <= GUNP_STRAFE_WINDOW)
		S.DamageMult *= 1 + GUNP_STRAFE_DMG * v
	v = GunPassive("Rolling Thunder")
	if(v > 0)
		GunThunderDecay()
		if(gun_thunder > 0)
			S.DamageMult *= 1 + GUNP_THUNDER_DMG * v * gun_thunder
	v = GunPassive("Point Blank")
	if(v > 0 && ismob(Target) && Target != src && Target.z == z && get_dist(src, Target) <= GUNP_POINTBLANK_RANGE)
		S.DamageMult *= 1 + GUNP_POINTBLANK_DMG * v
	v = GunPassive("Full Spread")
	if(v > 0 && g.GunClass == GUN_CLASS_SHOTGUN && S.Blasts > 1)
		S.Blasts += round(v)

/mob/GunHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	. = ..()
	gun_tension_pre = -1
	if(!victim || !passive_handler)
		return
	if(GunPassive("Trigger Happy") > 0)
		gun_tension_pre = Tension
	var/v = GunPassive("Marked for Death")
	if(v > 0 && (victim.IsTracerTagged() || victim.Bleed > 0))
		. *= 1 + GUNP_MARKED_DMG * v
	v = GunPassive("Headhunter")
	if(v > 0 && victim.HealthPct() < GUNP_HEADHUNTER_HP)
		. *= 1 + GUNP_HEADHUNTER_DMG * v
	v = GunPassive("Setup")
	if(v > 0 && victim.setup_mark_by == src && victim.setup_mark_until > world.time)
		. *= 1 + GUNP_SETUP_DMG * v
		victim.setup_mark_by = null
		victim.setup_mark_until = 0
		setup_gun_mark = world.time + GUNP_SETUP_TIME

/mob/GunOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P)
	..()
	if(!passive_handler)
		return
	var/v = GunPassive("Rolling Thunder")
	if(v > 0)
		GunThunderDecay()
		gun_thunder = min(gun_thunder + 1, GUNP_THUNDER_MAX)
		gun_thunder_hit = world.time
	v = GunPassive("Trigger Happy")
	if(v > 0 && gun_tension_pre >= 0)
		var/gained = Tension - gun_tension_pre
		if(gained > 0)
			addTension(gained * GUNP_TRIGGERHAPPY_MULT * v, getTensionCap())
	gun_tension_pre = -1
	v = GunPassive("Arcane Rhythm")
	if(v > 0)
		gun_rhythm++
		if(gun_rhythm >= GUNP_RHYTHM_HITS)
			gun_rhythm = 0
			gun_rhythm_until = world.time + GUNP_RHYTHM_TIME

/mob/GunSetupPunch(mob/victim)
	. = ..()
	if(setup_gun_mark <= world.time)
		return
	setup_gun_mark = 0
	var/v = GunPassive("Setup")
	if(v > 0)
		. *= 1 + GUNP_SETUP_DMG * v

/mob/GunIntercept(obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(. || !P || P.Owner == src || KO)
		return
	var/v = GunPassive("Intercept")
	if(v <= 0 || P.Area == "Beam" || P.Deflectable <= 0)
		return 0
	if(!istype(StyleBuff, /obj/Skills/Buffs/NuStyle/GunStyle))
		return 0
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || G.Loaded <= 0 || Reloading)
		return 0
	if((G.energy_gun || G.mech_only) && Overheated())
		return 0
	if(!prob(GUNP_INTERCEPT_CHANCE * v))
		return 0
	if(!GunArtSpend(1))
		return 0
	if(G.energy_gun || G.mech_only)
		G.EnergySync()
		HeatAdd(G.heat_per_shot)
	if(GunIsSuppressed())
		src << "<b>You shoot it down!</b>"
	else
		OMsg(src, "<b>[src] shoots it down!</b>")
	P.Killed = 1
	P.ProjectileFinish()
	return 1

/mob/proc/GunSpellCast(obj/Skills/S)
	var/v = GunPassive("Charged Rounds")
	if(v <= 0)
		return
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		return
	GunStyleSync()
	if(G.Loaded >= G.MagSize)
		return
	if(!ispath(G.LoadedType, /obj/Items/Ammo))
		G.LoadedType = text2path("/obj/Items/Ammo/[G.Caliber]/Standard")
	G.Loaded = min(G.Loaded + max(1, round(v)), G.MagSize)
	G.DryWarned = 0
	GunRefillSkill(G)

/mob/proc/GunSpellHitMult(obj/Skills/S, mob/m)
	if(gun_rhythm_until <= world.time)
		return 1
	gun_rhythm_until = 0
	var/v = GunPassive("Arcane Rhythm")
	if(v <= 0)
		return 1
	return 1 + GUNP_RHYTHM_DMG * v

/strikeHook/gunSetupMark
	stage = "post"
	fire(strike/S)
		if(!S || !S.unarmed || !S.attacker || !S.defender || S.attacker == S.defender)
			return
		var/mob/A = S.attacker
		if(!A.passive_handler || A.passive_handler.Get("Setup") <= 0)
			return
		S.defender.setup_mark_by = A
		S.defender.setup_mark_until = world.time + GUNP_SETUP_TIME

/strikeHook/gunMelee
	stage = "post"
	fire(strike/S)
		if(!S || !S.melee || !S.attacker || !S.defender || S.attacker == S.defender)
			return
		var/mob/A = S.attacker
		if(!A.gun_melee_at || world.time - A.gun_melee_at > GUNP_GUNMELEE_WINDOW)
			return
		A.gun_melee_at = 0
		if(S.defender.Knockbacked || S.defender.KO)
			return
		A.Knockback(GUNP_GUNMELEE_KB, S.defender, get_dir(A, S.defender) || A.dir)

passiveInfo/GunColdBarrel
	setLines()
		name = "Cold Barrel"
		lines = list("A gun shot fired after [GUNP_COLD_IDLE / 10] seconds without firing deals [GUNP_COLD_DMG * 100]% more damage and gains [GUNP_COLD_ACC] accuracy per point.")

passiveInfo/GunLastRound
	setLines()
		name = "Last Round"
		lines = list("The last round in your magazine deals [GUNP_LAST_DMG * 100]% more damage per point.")

passiveInfo/GunLivingTurret
	setLines()
		name = "Living Turret"
		lines = list("After [GUNP_TURRET_IDLE / 10] second of standing still, your gun shots ignore bloom and gain [GUNP_TURRET_ACC] accuracy per point.")

passiveInfo/GunStrafe
	setLines()
		name = "Strafe"
		lines = list("Gun shots fired within [GUNP_STRAFE_WINDOW / 10] seconds of moving deal [GUNP_STRAFE_DMG * 100]% more damage per point.")

passiveInfo/GunRollingThunder
	setLines()
		name = "Rolling Thunder"
		lines = list("Each gun hit adds a stack, up to [GUNP_THUNDER_MAX]. Each stack adds [GUNP_THUNDER_DMG * 100]% gun damage per point. Stacks clear after [GUNP_THUNDER_WINDOW / 10] seconds without a gun hit.")

passiveInfo/GunTriggerDiscipline
	setLines()
		name = "Trigger Discipline"
		lines = list("The bloom each shot adds is divided by 1 plus your points held.")

passiveInfo/GunBeltFed
	setLines()
		name = "Belt Fed"
		lines = list("Your magazine holds [GUN_BELTFED_STEP * 100]% more rounds per point, never more than [GUN_MAG_CAP].")

passiveInfo/GunPointBlank
	setLines()
		name = "Point Blank"
		lines = list("Gun shots fired while your target is within [GUNP_POINTBLANK_RANGE] tile deal [GUNP_POINTBLANK_DMG * 100]% more damage per point.")

passiveInfo/GunFullSpread
	setLines()
		name = "Full Spread"
		lines = list("Shotgun blasts fire one extra pellet per point. Slugs are unaffected.")

passiveInfo/GunMelee
	setLines()
		name = "Gun Melee"
		lines = list("Your pistol whip deals 100% more damage per point and knocks the target back a tile.")

passiveInfo/GunTriggerHappy
	setLines()
		name = "Trigger Happy"
		lines = list("Tension gained from gun hits is increased by [GUNP_TRIGGERHAPPY_MULT * 100]% per point.")

passiveInfo/GunRunAndGun
	setLines()
		name = "Run and Gun"
		lines = list("Reloading no longer slows you down. Does not stack.")

passiveInfo/GunQuickHands
	setLines()
		name = "Quick Hands"
		lines = list("Each reload step takes [GUN_QUICKHANDS_STEP * 100]% less time per point, never less than [GUN_QUICKHANDS_FLOOR * 100]% of the normal time.")

passiveInfo/GunIntercept
	setLines()
		name = "Intercept"
		lines = list("With a gun style active and a loaded gun, an enemy projectile about to hit you has a [GUNP_INTERCEPT_CHANCE]% chance per point to be shot down, spending one round. Beams and undeflectable projectiles cannot be shot down.")

passiveInfo/GunSetup
	setLines()
		name = "Setup"
		lines = list("An unarmed hit marks the target for [GUNP_SETUP_TIME / 10] seconds. Your next gun hit on it deals [GUNP_SETUP_DMG * 100]% more damage per point and readies your next unarmed hit within [GUNP_SETUP_TIME / 10] seconds for the same bonus.")

passiveInfo/GunHeadhunter
	setLines()
		name = "Headhunter"
		lines = list("Gun hits on a target below [GUNP_HEADHUNTER_HP]% Health deal [GUNP_HEADHUNTER_DMG * 100]% more damage per point.")

passiveInfo/GunMarkedForDeath
	setLines()
		name = "Marked for Death"
		lines = list("Gun hits on a target tagged by a Tracer round or bleeding deal [GUNP_MARKED_DMG * 100]% more damage per point.")

passiveInfo/GunChargedRounds
	setLines()
		name = "Charged Rounds"
		lines = list("Casting a spell loads one free round per point into your equipped gun, up to a full magazine.")

passiveInfo/GunArcaneRhythm
	setLines()
		name = "Arcane Rhythm"
		lines = list("Every [GUNP_RHYTHM_HITS] gun hits empower your next spell hit within [GUNP_RHYTHM_TIME / 10] seconds to deal [GUNP_RHYTHM_DMG * 100]% more damage per point.")
