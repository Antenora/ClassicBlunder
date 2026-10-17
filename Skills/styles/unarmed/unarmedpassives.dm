/mob/var/tmp/spell_edge_until = 0
/mob/var/tmp/spell_edge_element
/mob/var/tmp/spell_edge_power = 0
/mob/var/tmp/spell_edge_hits = 0
/mob/var/tmp/mob/pile_driver_mark
/mob/var/tmp/pile_driver_at = 0

/mob/proc/UnarmedPassive(name)
	if(!passive_handler)
		return 0
	return passive_handler.Get(name)

/mob/SpellEdgeStamp(obj/Skills/S)
	..()
	if(!S || !passive_handler)
		return
	var/v = max(UnarmedPassive("Spell Fist"), UnarmedPassive("Enchanted Edge"))
	if(v <= 0)
		return
	var/power = SpellEdgePower(S)
	if(power <= 0)
		return
	spell_edge_until = world.time + UNARMEDP_SPELLEDGE_TIME
	spell_edge_element = S.SpellElement
	spell_edge_power = power
	spell_edge_hits = max(1, round(v))

/mob/proc/SpellEdgePower(obj/Skills/S)
	if(S.SpellElement == "Fire")
		return S.TurfBurn
	return 0

/mob/SpellEdgeApply(mob/victim, sword_hit)
	..()
	if(spell_edge_hits <= 0)
		return
	if(spell_edge_until <= world.time)
		SpellEdgeClear()
		return
	if(!ismob(victim) || victim == src || !victim.loc || victim.KO || victim.Dead)
		return
	if(UnarmedPassive(sword_hit ? "Enchanted Edge" : "Spell Fist") <= 0)
		return
	switch(spell_edge_element)
		if("Fire")
			victim.AddBurn(spell_edge_power, src, 1)
	spell_edge_hits--
	if(spell_edge_hits <= 0)
		SpellEdgeClear()

/mob/proc/SpellEdgeClear()
	spell_edge_until = 0
	spell_edge_element = null
	spell_edge_power = 0
	spell_edge_hits = 0

/mob/ChainCastSkip(obj/Skills/S)
	. = ..()
	if(. || !S || !S.IsSpell || !last_melee_hit)
		return
	var/v = UnarmedPassive("Chain Cast")
	if(v <= 0 || world.time - last_melee_hit > UNARMEDP_CHAIN_WINDOW * v)
		return 0
	if(S.HeldSkill)
		return !S.InfiniteHold && !S.HeldBeam
	var/obj/Skills/AutoHit/A = S
	return istype(A) && A.WindUp > 0

/mob/GrabLanded(mob/target)
	..()
	pile_driver_mark = null
	pile_driver_at = 0
	if(!ismob(target) || target == src || target.KO || istype(target, /mob/Body))
		return
	if(UnarmedPassive("Pile Driver") <= 0)
		return
	pile_driver_mark = target
	pile_driver_at = GrabTime

/mob/GrabReleasing(atom/movable/G)
	..()
	if(!pile_driver_mark)
		return
	var/mob/target = pile_driver_mark
	var/armed_at = pile_driver_at
	pile_driver_mark = null
	pile_driver_at = 0
	if(target != G || armed_at != GrabTime || world.time <= GrabTime + glob.TIMING_WINDOW)
		return
	var/v = UnarmedPassive("Pile Driver")
	if(v <= 0 || KO || target.KO || istype(target, /mob/Body) || !target.loc || target.z != z || target.Knockbacked)
		return
	PileDriverSlam(target, v)

/mob/proc/PileDriverSlam(mob/target, v)
	Knockback(UNARMEDP_PILE_KB, target, dir)
	LaunchEffect(src, target, UNARMEDP_PILE_DOWN)
	if(v >= UNARMEDP_PILE_SHOCK_AT)
		PileDriverShockwave(target)

/mob/proc/PileDriverShockwave(mob/target)
	set waitfor = 0
	var/n = 0
	while(target && target.Knockbacked && n < UNARMEDP_PILE_LAND_WAIT)
		n++
		sleep(1)
	if(!target || !target.loc || KO)
		return
	for(var/mob/m in range(1, get_turf(target)))
		if(m == src || m == target || m.KO || m.Dead || m.Stasis || istype(m, /mob/Body) || istype(m, /mob/irlNPC) || inParty(m.ckey))
			continue
		PileDriverShock(m)

/mob/proc/PileDriverShock(mob/victim)
	var/powerDif = Power / victim.Power
	if(glob.CLAMP_POWER && !ignoresPowerClamp(victim))
		powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
	var/damage = strikeCoreDamage(powerDif, getStatDmg2(), victim.getEndStat(1) * MeleeEndMult(victim))
	damage *= UNARMEDP_PILE_SHOCK
	if(victim.HasGiantForm())
		damage *= glob.GIANT_FORM_DMG_MULT
	damage *= strikeJudgmentMult()
	if(HasUnarmedDamage())
		damage *= 1 + (GetUnarmedDamage() / glob.UNARMED_DAMAGE_DIVISOR)
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Normal Attack"))
		damage *= clamp(secretDatum?:getBoon(src, "Basic Attack"), 1, 10)
	damage *= victim.ccProrationMult(src)
	var/obj/Items/Armor/A = victim.EquippedArmor()
	if(A)
		var/eff = victim.GetArmorDamage(A)
		var/peel = passive_handler.Get("ArmorPeeling")
		if(peel)
			eff *= 1 - (glob.ARMOR_PEEL_CAP * peel / (peel + 2))
		damage -= damage * eff / 10
	damage *= glob.GLOBAL_MELEE_MULT
	damage *= victim.getMeleeResistValue()
	if(damage <= 0)
		return
	var/strike/S = new(src, victim, damage)
	S.unarmed = 1
	S.melee = 1
	S.resolve()

/mob/FaJinEmpowered(mob/target)
	..()
	if(!ismob(target) || target == src)
		return
	var/v = UnarmedPassive("Dim Mak")
	if(v <= 0)
		return
	Stun(target, UNARMEDP_DIMMAK_SECS + UNARMEDP_DIMMAK_STEP * (v - 1))
