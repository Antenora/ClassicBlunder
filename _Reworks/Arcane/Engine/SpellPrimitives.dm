globalTracker/var
	MAGE_STOKE_REGEN = 0.5
	MAGE_STOKE_CAP = 100
	MANA_RETURN_CAP_PCT = 0.3
	MANA_RETURN_WINDOW = 100
	CINDER_TOLL_PCT = 0.1
	CINDER_TOLL_PER_RESET = 3
	CINDER_TOLL_MIN_BURN = 20
	KINDLED_COST_MULT = 0.75
	KINDLED_DAMAGE_MULT = 1.2
	KINDLED_BONUS_BURN = 10
	KINDLED_REACH = 1
	BURN_TICK_CAP = 0.25
	STILLNESS_TICKS = 25
	STILLNESS_MAX_ARRAYS = 2
	STILLNESS_EXPIRE = 80
	FIRE_GROUND_CAP = 40
	FIRE_GROUND_INTERVAL = 5
	EXHAUSTED_FREE_WINDOW = 50
	CONTACT_BURN_ICD = 10
	HEAT_EXCHANGE_ICD = 30
	HEAT_EXCHANGE_CAP = 3
	HEAT_EXCHANGE_WINDOW = 100
	FUEL_REFUND_CAP = 3
	SPELL_SELFHIT_WINDOW = 20

obj/Skills
	var
		PrimeThreshold = 1
		LitCostMult = 1
		ConsumeMinPool = 0
		ConsumeAmount = 0
		TitheRate = 0
		TitheCap = 0
		OwnRefund = 0
		StokeSecs = 6
		StokeMin = 30
		FinalStrikeMana = 0
		list/EventRefund
		list/EventRefundCap
		TrueDamagePerPoint = 0
		AmpVsPool
		AmpVsPoolMin = 1
		AmpVsPoolMult = 1
		AmpVsPoolStep = 0
		AmpVsPoolPerStep = 0
		AmpVsPoolCap = 0
		ShieldPierce = 0
		ConvertFrom
		ConvertTo
		ConvertAmount = 0
		ConvertRefund = 0
		BindBurn = 0
		BindBurnTicks = 0
		FacingPin = 0
		HoldTarget = 0
		GrabBreak = 0
		list/SelfCleansePools
		SelfCleanseAllies = 0
		DryBurnTicks = 0
		HeldDrain = 0
		HeldDrainGrace = 10
		HeldMoveMult = 1
		HeldFreeze = 0
		OverchargeManaPerStep = 0
		OverchargeMaxSteps = 0
		OverchargeStepTicks = 4
		ManaCostAll = 0
		ManaMinPct = 0
		PairCostMult = 1
		FireGroundTicks = 0
		FireGroundBurn = 4
		FireGroundDamage = 0
		FireGroundRadius = 0
		BurnSpreadMin = 0
		RevealHidden = 0
		DisarmIfSwordGuard = 0
		MeltConstructs = 0
		TargetBlind = 0
		EnemyManaDrainPct = 0
		RoundsFromPool = 0
		RoundsFromPoolMax = 0
		LastRoundStunAt = 0
		LastRoundStun = 0
		KindledOnly = 0
		SilentCast = 0
		tmp
			lit_cached = 0
			lit_cached_time = 0
			list/consumed_targets
			list/event_paid
			held_accrued = 0
			overcharge_steps = 0
			empowered_cast = 0
			consume_depth = 0
			last_consumed_total = 0
			rounds_pool_took = 0
			finale_pending = 0
			fire_slot = 0
			skip_prime_hit = 0
			free_cast = 0

obj/Skills/Projectile
	var
		BlinkBehind = 0
		BackStrike = 0
		SenseTell = 6
		SteerRate = 0
		ExtendTiles = 0
		SlamRefund = 0
		SlamShort = 2
		SelfScorchRange = 0
		SelfScorchBurn = 0
		AllyHitUnder = 0
		AllyDmgMult = 0.25
		AllyBurn = 0
		ExtendPool

obj/Skills/Projectile/_Projectile
	var/tmp
		obj/Skills/from_skill
		blinked = 0
		extended = 0

obj/Skills/Buffs
	var
		ManaRegenMult = 1
		SnuffOnDrench = 0
		ConsumeSelfCast = 0
		CrumbleBelowPct = 0
		AfterDebuffPath
		AfterDebuffSecs = 0
		ContactBurn = 0
		OwnFireImmune = 0
		RangedFalloff = 0

mob/var/tmp
	mana_stoke_until = 0
	list/mana_refund_stamps
	refund_bank = 0
	exhausted_free_until = 0
	cinder_tolls = 0
	burn_dry_until = 0
	still_since = 0
	still_arrays = 0
	still_array_expire = 0
	still_x = 0
	still_y = 0
	still_sx = 0
	still_sy = 0
	obj/fx_rider/castcircle/still_array_fx
	obj/Guardian/guardian
	heat_exchange_next = 0
	heat_exchange_window = 0
	heat_exchange_count = 0
	fuel_window = 0
	fuel_count = 0
	target_lock_block_until = 0
	list/hb_key_down_stamp
	list/hb_key_up_stamp
	last_fire_slot = 0
	mana_regen_mult = 1
	fire_ground_count = 0
	disable_break_armed = 0
	list/element_power
	spell_hit_gate = 0
	burn_boil = 0
	spirit_dive_on = 0
	bonus_burn = 0

mob/proc/ManaCap()
	var/KeyMana = src.ManaMax
	if(src.TotalCapacity && !src.HasMechanized())
		KeyMana -= src.TotalCapacity
	if(src.HasManaCapMult())
		KeyMana *= src.GetManaCapMult()
	KeyMana += src.MageManaBonus()
	if(src.ManaCut)
		KeyMana -= KeyMana * src.ManaCut
	return max(KeyMana, 1)

mob/proc/IsExhausted()
	return passive_handler && passive_handler.Get("Exhausted")

mob/proc/SelfHitRecently()
	if(grabbed) return 1
	if(world.time - last_damaged_time > glob.SPELL_SELFHIT_WINDOW) return 0
	if(!last_attacker || last_attacker == src) return 0
	return get_dist(src, last_attacker) <= 1

mob/proc/SpellLit(obj/Skills/Z)
	if(!Z) return 0
	if(Z.HeldSkill && Z.lit_cached_time && world.time - Z.lit_cached_time < 600)
		return Z.lit_cached
	return SpellPrimed(Z)

mob/proc/CacheSpellLit(obj/Skills/Z)
	if(!Z || !Z.IsSpell) return
	Z.lit_cached = SpellPrimed(Z)
	Z.lit_cached_time = world.time

mob/proc/PairBuffOn(obj/Skills/Z)
	if(!Z || !Z.PairBonusSkill) return 0
	var/p = text2path(Z.PairBonusSkill)
	if(!p) return 0
	var/obj/Skills/Buffs/B = locate(p) in src
	if(!B) return 0
	return BuffOn(B)

mob/proc/SpellCostMult(obj/Skills/Z)
	if(!Z || !Z.IsSpell) return 1
	var/base = max(Z.ManaCost, 0.01)
	if(Z.ManaCostAll) return max(ManaAmount, 0) / base
	. = 1
	if(Z.free_cast)
		. = 0
	else
		if(Z.LitCostMult != 1 && SpellLit(Z))
			. *= Z.LitCostMult
		if(Z.empowered_cast)
			. *= glob.KINDLED_COST_MULT
		if(Z.PairCostMult != 1 && PairBuffOn(Z))
			. *= Z.PairCostMult
	if(Z.held_accrued > 0)
		. += Z.held_accrued / base

mob/proc/SpellManaNeed(obj/Skills/Z)
	if(!Z) return 0
	return Z.ManaCost * ChakraCostMult(Z) * SpellCostMult(Z)

mob/proc/SpellPreCast(obj/Skills/Z, charge_start = 0)
	if(!Z || !Z.IsSpell) return 1
	if(Z.SilentCast)
		Z.consumed_targets = null
		return 1
	if(Z.HeldSkill && Z.lit_cached_time && !charge_start)
		return 1
	Z.SpellCastReset()
	ManaMethodRestore(Z)
	if(Z.ManaCostAll && !SpellAllManaGate(Z)) return 0
	var/free_restore = 0
	if(exhausted_free_until && world.time < exhausted_free_until && Z.SpellTier < 5 && !Z.ManaCostAll)
		free_restore = exhausted_free_until
		Z.free_cast = 1
		exhausted_free_until = 0
	var/arrays_spent = SpendStillnessArray(Z)
	if(arrays_spent)
		ManaMethodReach(Z)
	if(Z.ManaCost && !Z.ManaCostAll && !HasDrainlessMana() && ManaAmount < SpellManaNeed(Z))
		if(arrays_spent)
			ManaMethodRestore(Z)
			Z.empowered_cast = 0
			still_arrays += arrays_spent
			still_array_expire = max(still_array_expire, world.time + glob.STILLNESS_EXPIRE)
		if(free_restore)
			Z.free_cast = 0
			exhausted_free_until = free_restore
		src << "<font color=red>You don't have enough mana to cast [Z].</font>"
		return 0
	if(Z.HeldSkill)
		CacheSpellLit(Z)
	return 1

mob/proc/SpellAllManaGate(obj/Skills/Z)
	if(!Z || !Z.ManaCostAll) return 1
	if(ManaAmount < ManaCap() * Z.ManaMinPct)
		src << "<font color=red>[Z] needs at least [round(Z.ManaMinPct * 100)] percent of your mana.</font>"
		return 0
	return 1

mob/proc/Stoke(secs)
	if(!secs || secs <= 0) return
	if(IsExhausted()) return
	var/want = world.time + secs * 10
	mana_stoke_until = min(max(mana_stoke_until, want), world.time + glob.MAGE_STOKE_CAP)
	StokeEmbers(1)

mob/proc/IsStoked()
	return world.time < mana_stoke_until && !IsExhausted()

mob/proc/StokeRegen()
	if(!IsStoked()) return 0
	return glob.MAGE_STOKE_REGEN

mob/proc/StokeEmbers(on)
	for(var/obj/fx_tome/T in vis_contents)
		if(on)
			if(T.hd2d_embers) continue
			var/datum/lightsource/L = new
			L.lcolor = FxElementColor("Fire")
			L.radius = 2
			L.flicker = 1
			L.off_x = T.pixel_x
			L.off_y = T.pixel_y
			Hd2dEmberAttach(T, L)
		else
			Hd2dEmberClear(T)

mob/proc/StokeWatch()
	if(mana_stoke_until && world.time >= mana_stoke_until)
		mana_stoke_until = 0
		StokeEmbers(0)

mob/proc/RefundRoom()
	if(!mana_refund_stamps) mana_refund_stamps = list()
	var/sum = 0
	for(var/i = mana_refund_stamps.len, i >= 1, i--)
		var/list/e = mana_refund_stamps[i]
		if(world.time - e[1] > glob.MANA_RETURN_WINDOW)
			mana_refund_stamps.Cut(i, i + 1)
			continue
		sum += e[2]
	return max(0, ManaCap() * glob.MANA_RETURN_CAP_PCT - sum)

mob/proc/RefundManaNow(val)
	if(val <= 0) return 0
	var/room = RefundRoom()
	val = min(val, room)
	if(val <= 0) return 0
	mana_refund_stamps += list(list(world.time, val))
	ManaAmount += val
	MaxMana()
	AngerManaLast = ManaAmount
	return val

mob/proc/FlushRefundBank()
	if(refund_bank <= 0) return
	var/paid = RefundManaNow(refund_bank)
	refund_bank = max(0, refund_bank - paid)

mob/proc/PayEventRefund(obj/Skills/S, key, n = 1)
	if(!S || !S.EventRefund || !(key in S.EventRefund)) return 0
	var/per = S.EventRefund[key]
	if(!per) return 0
	if(!S.event_paid) S.event_paid = list()
	var/paid = S.event_paid[key]
	var/cap = (S.EventRefundCap && (key in S.EventRefundCap)) ? S.EventRefundCap[key] : 0
	var/amt = per * n
	if(cap)
		amt = min(amt, cap - paid)
	if(amt <= 0) return 0
	S.event_paid[key] = paid + amt
	return RefundMana(amt)

mob/proc/HeatExchange()
	if(!IsMage()) return
	if(world.time < heat_exchange_next) return
	if(world.time - heat_exchange_window > glob.HEAT_EXCHANGE_WINDOW)
		heat_exchange_window = world.time
		heat_exchange_count = 0
	if(heat_exchange_count >= glob.HEAT_EXCHANGE_CAP) return
	heat_exchange_count++
	heat_exchange_next = world.time + glob.HEAT_EXCHANGE_ICD
	RefundMana(1)

obj/Skills/proc/SpellCastReset()
	consumed_targets = null
	event_paid = null
	held_accrued = 0
	overcharge_steps = 0
	empowered_cast = 0
	last_consumed_total = 0
	rounds_pool_took = 0
	finale_pending = 0
	lit_cached_time = 0
	skip_prime_hit = 0
	free_cast = 0

mob/proc/TrueBurnDamage(mob/target, points, obj/Skills/S)
	if(!target || points <= 0 || !S) return 0
	var/rate = S.TrueDamagePerPoint
	if(!rate) return 0
	var/pct = points * rate
	if(target.Drenched > 0)
		pct *= 0.5
	var/strike/K = new(src, target, target.PctToHP(pct))
	K.element = "Fire"
	K.autohit = 1
	K.pierce = 1
	K.critEff = 0
	K.blockEff = 0
	K.trueDamage = 1
	return K.resolve()

mob/proc/SpellHitMult(obj/Skills/S, mob/m)
	. = 1
	if(!S || !S.IsSpell || !m) return
	if(S.AmpVsPool)
		var/pv = (S.AmpVsPool == "Fire" || S.AmpVsPool == "Burn") ? m.spell_hit_gate : m.PoolValue(S.AmpVsPool)
		if(S.AmpVsPoolStep > 0)
			var/steps = round(pv / S.AmpVsPoolStep)
			var/bonus = steps * S.AmpVsPoolPerStep
			if(S.AmpVsPoolCap) bonus = min(bonus, S.AmpVsPoolCap)
			. *= 1 + bonus
		else if(pv >= S.AmpVsPoolMin)
			. *= S.AmpVsPoolMult
	if(S.empowered_cast)
		. *= 1 + (glob.KINDLED_DAMAGE_MULT - 1) * S.empowered_cast
	if(S.SpellElement)
		. *= ElementPowerFor(S.SpellElement)

mob/proc/ElementPowerFor(el)
	if(!element_power || !el) return 1
	var/v = element_power[el]
	if(!v) return 1
	return 1 + v

mob/proc/AddElementPower(el, v)
	if(!element_power) element_power = list()
	element_power[el] = (element_power[el] ? element_power[el] : 0) + v
	if(element_power[el] <= 0.0001 && element_power[el] >= -0.0001) element_power -= el

mob/proc/ConvertPool(mob/target, fromPool, toPool, amt, obj/Skills/S)
	if(!target || !fromPool || !toPool || amt <= 0) return 0
	var/took = target.ConsumeStacks(fromPool, amt)
	if(took <= 0) return 0
	if(toPool == "Burn" || toPool == "Fire")
		target.AddBurn(took, src, 1)
	else if(toPool == "Drenched" || toPool == "Water")
		target.AddDrenched(took, src)
	else if(toPool == "Slow" || toPool == "Ice")
		target.AddSlow(took, src)
	if(S && S.ConvertRefund)
		PayEventRefund(S, "convert", 1)
	return took

obj/Skills/proc/OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
	return

mob/proc/CleanseSpellPools(list/pools)
	. = 0
	for(var/pool in pools)
		. += ConsumeStacks(pool)

mob/proc/OnSpellHit(obj/Skills/S, mob/m, atom/hitter)
	if(!S || !S.IsSpell || !m || m == src) return 0
	if(m.KO || m.Dead) return 0
	m.spell_hit_gate = m.Burn
	if(S.ConvertFrom && S.ConvertTo && S.ConvertAmount)
		ConvertPool(m, S.ConvertFrom, S.ConvertTo, S.ConvertAmount, S)
	var/consumed = 0
	if(S.Consumes && S.Consumes.len)
		var/pool = S.Consumes[1]
		var/have = m.PoolValue(pool)
		var/minp = max(S.ConsumeMinPool, 1)
		if(have >= minp)
			if(!S.consumed_targets) S.consumed_targets = list()
			if(!(m in S.consumed_targets) || S.ConsumeAmount > 0)
				S.consumed_targets |= m
				var/took = SpendSpellPools(S, m)
				if(took > 0)
					consumed = 1
					if(S.TrueDamagePerPoint)
						TrueBurnDamage(m, took, S)
	if(S.BindBurn && S.BindBurnTicks)
		spawn() BindBurnLoop(m, S)
	if(S.HoldTarget && m.cc_immune_until <= world.time)
		m.Frozen = 1
		spawn(S.HoldTarget * 10)
			if(m && m.Frozen == 1) m.Frozen = 0
	if(S.FacingPin)
		m.dir = get_dir(m, src)
	if(S.DisarmIfSwordGuard && m.IsGuarding() && m.EquippedSword())
		DisarmTarget(m)
	if(S.RevealHidden && m.invisibility)
		var/inv = m.invisibility
		m.invisibility = 0
		spawn(S.RevealHidden * 10)
			if(m && !m.invisibility) m.invisibility = inv
	if(S.FireGroundTicks && hitter)
		var/turf/T = get_turf(hitter)
		if(!T) T = get_turf(m)
		SpawnFireGround(T, S.FireGroundTicks, S.FireGroundBurn, S.FireGroundDamage, S.FireGroundRadius, S.empowered_cast ? S.DryBurnTicks : 0)
	if(TrueFireOn() && !S.FireGroundTicks && (S.SpellShape == "aoe" || S.SpellShape == "line"))
		var/turf/T2 = get_turf(m)
		SpawnFireGround(T2, S.empowered_cast ? 40 : 20, 4, 0, 0, S.empowered_cast ? 30 : 0, 1)
	if(S.finale_pending && S.FinalStrikeMana)
		S.finale_pending = 0
		RefundMana(S.FinalStrikeMana)
	if(S.EnemyManaDrainPct)
		m.LoseMana(m.ManaAmount * S.EnemyManaDrainPct, 1)
	if(burn_boil && m.Drenched > 0)
		m.ConsumeStacks("Drenched", burn_boil)
	if(!consumed && !S.SilentCast)
		if(bonus_burn) m.AddBurn(bonus_burn, src, 1)
		if(S.empowered_cast) m.AddBurn(glob.KINDLED_BONUS_BURN * S.empowered_cast, src, 1)
	if(S.LastRoundStunAt && S.finale_pending && S.rounds_pool_took >= S.LastRoundStunAt && S.LastRoundStun)
		if(!S.event_paid) S.event_paid = list()
		if(!S.event_paid["laststun"])
			S.event_paid["laststun"] = 1
			Stun(m, S.LastRoundStun)
	S.OnSpellHitExtra(src, m, hitter)
	return consumed

mob/proc/TrueFireOn()
	return passive_handler && passive_handler.Get("TrueFire")

mob/proc/BindBurnLoop(mob/m, obj/Skills/S)
	var/ticks = S.BindBurnTicks
	while(ticks > 0 && m && !m.KO && !m.Dead && m.passive_handler && m.passive_handler.Get("Snared"))
		m.AddBurn(S.BindBurn, src, 1)
		if(S.FacingPin) m.dir = get_dir(m, src)
		if(get_dist(src, m) > 6)
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/sn = locate() in m
			if(sn && m.BuffOn(sn)) sn.Trigger(m, 1)
			break
		sleep(5)
		ticks -= 5

mob/proc/BurnSpread(list/mobs, minBurn, mob/exclude)
	var/best = 0
	var/mob/source
	for(var/mob/m in mobs)
		if(m == src || m.KO || m.Dead) continue
		if(m.Burn >= minBurn && m.Burn > best)
			best = m.Burn
			source = m
	if(!source) return 0
	. = 0
	for(var/mob/m in mobs)
		if(m == src || m == source || m.KO || m.Dead) continue
		if(m.Burn < best)
			m.AddBurn(best - m.Burn, src, 1)
			.++
	if(. > 0) Stoke(4)

mob/proc/TryDisableBreak(kind)
	if(KO || Dead || !InCombat()) return 0
	for(var/obj/Skills/Buffs/B in contents)
		if(B.IsSpell && B.PageKey == "SHELF_M2" && !B.Using && !BuffOn(B))
			B.Trigger(src, 1)
			return BuffOn(B)
	return 0

proc/applyExhausted(mob/target, secs)
	if(!target) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Exhausted/E = target.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Exhausted)
	E.TimerLimit = secs
	if(!target.BuffOn(E))
		E.Trigger(target, 1)

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Exhausted
	name = "Exhausted"
	BuffName = "Exhausted"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 6
	DefMult = 0.7
	passives = list("Silenced" = 1, "Exhausted" = 1)
	ActiveMessage = "sways, spent to the last drop of mana."
	OffMessage = "draws a full breath again."
	Trigger(mob/User, Override)
		var/was = User.BuffOn(src)
		..()
		if(was && !User.BuffOn(src))
			User.exhausted_free_until = world.time + glob.EXHAUSTED_FREE_WINDOW
			User.FlushRefundBank()
		else if(!was && User.BuffOn(src))
			User.mana_stoke_until = 0
			User.StokeEmbers(0)

proc/applyCauterize(mob/target, ticks)
	if(!target || !target.passive_handler) return
	target.passive_handler.Increase("Cauterized", 1)
	spawn(ticks)
		if(target && target.passive_handler)
			target.passive_handler.Decrease("Cauterized", 1)

proc/applyHealCut(mob/target, ticks)
	if(!target || !target.passive_handler) return
	target.passive_handler.Increase("HealCut", 1)
	spawn(ticks)
		if(target && target.passive_handler)
			target.passive_handler.Decrease("HealCut", 1)

mob/proc/HealCutMult()
	if(!passive_handler) return 1
	if(passive_handler.Get("HealCut")) return 0
	if(passive_handler.Get("Cauterized")) return 0.5
	return 1

obj/leftOver/FireGround
	icon = 'fire.dmi'
	icon_state = "loop"
	density = 0
	Savable = 0
	gfx_transient_visual = 1
	layer = MOB_LAYER - 0.5
	alpha = 0
	var/burn_per_tick = 4
	var/dmg_pct = 0
	var/dry_ticks = 0
	var/reprime = 1
	var/next_tick = 0
	var/spread_min = 0
	var/expired = 0
	var/next_spread = 0
	var/tmp/list/last_hit = list()
	New(turf/T, mob/p, ticks, burn, dmg, dry, natural = 0)
		if(!T)
			loc = null
			return
		loc = T
		lifetime = ticks
		burn_per_tick = burn
		dmg_pct = dmg
		dry_ticks = dry
		if(natural) color = "#ffd090"
		init(p)
		owner = p
		animate(src, alpha = 230, time = 3)
		..()
	proc/apply_fire(mob/m)
		if(expired || !m || m == owner || m.KO || m.Dead) return
		if(owner && owner.inParty(m.ckey)) return
		if(owner && owner.ai_followers && (m in owner.ai_followers)) return
		if(m.passive_handler && m.passive_handler.Get("OwnFireImmune") && (m == owner || (owner && owner.inParty(m.ckey)))) return
		var/last = last_hit[m]
		if(last && world.time - last < glob.FIRE_GROUND_INTERVAL) return
		last_hit[m] = world.time
		var/had = m.Burn
		if(dmg_pct > 0)
			m.LoseHealth(m.PctToHP(dmg_pct))
		m.AddBurn(burn_per_tick, owner, 1)
		if(dry_ticks) m.burn_dry_until = max(m.burn_dry_until, world.time + dry_ticks)
		if(had <= 0 && m.Burn > 0 && owner)
			owner.PayFuel(m)
	on_tick()
		if(owner && owner.PureRPMode) return
		for(var/mob/m in loc)
			apply_fire(m)
		if(spread_min && owner && world.time >= next_spread)
			next_spread = world.time + glob.FIRE_GROUND_INTERVAL
			var/list/near = list()
			for(var/mob/sm in range(1, src))
				near += sm
			owner.BurnSpread(near, spread_min)
	Cross(atom/movable/O)
		if(expired) return 1
		. = ..()
		if(ismob(O)) apply_fire(O)
	Update()
		lifetime -= world.tick_lag
		if(lifetime <= 0)
			expired = 1
			ticking_generic -= src
			if(owner) owner.fire_ground_count = max(0, owner.fire_ground_count - 1)
			owner = null
			tick_on = null
			last_hit = null
			animate(src, alpha = 0, time = 3)
			spawn(3) loc = null
		else
			on_tick()

mob/var/tmp/list/fuel_paid_stamp

mob/proc/PayFuel(mob/m)
	if(!TrueFireOn()) return
	if(!fuel_paid_stamp) fuel_paid_stamp = list()
	var/k = "\ref[m]"
	if(fuel_paid_stamp[k] && world.time - fuel_paid_stamp[k] < 20) return
	if(world.time - fuel_window > glob.HEAT_EXCHANGE_WINDOW)
		fuel_window = world.time
		fuel_count = 0
	if(fuel_count >= glob.FUEL_REFUND_CAP) return
	fuel_count++
	fuel_paid_stamp[k] = world.time
	RefundMana(1)

mob/proc/SpawnFireGround(turf/T, ticks, burn = 4, dmg = 0, radius = 0, dry = 0, natural = 0, spread_min = 0)
	if(!T || !ticks) return null
	var/list/turfs = radius > 0 ? Turf_Circle(T, radius) : list(T)
	. = list()
	for(var/turf/G in turfs)
		if(istype(G, /turf/Waters)) continue
		if(G.density) continue
		var/obj/leftOver/FireGround/old = locate() in G
		if(old && old.owner == src)
			old.lifetime = max(old.lifetime, ticks)
			old.burn_per_tick = max(old.burn_per_tick, burn)
			if(spread_min) old.spread_min = spread_min
			. += old
			continue
		if(fire_ground_count >= glob.FIRE_GROUND_CAP) break
		var/obj/leftOver/FireGround/F = new(G, src, ticks, burn, dmg, dry, natural)
		if(!F.loc) continue
		F.spread_min = spread_min
		fire_ground_count++
		. += F

obj/Guardian
	icon = 'Aura_Fire_Small.dmi'
	density = 0
	layer = MOB_LAYER + 0.3
	Savable = 0
	Buildable = 0
	Grabbable = 0
	Destructable = 0
	mouse_opacity = 0
	gfx_transient_visual = 1
	appearance_flags = PIXEL_SCALE | KEEP_APART
	var/tmp
		mob/Keeper
		duration = 120
		orbit_radius = 24
		dive_every = 20
		dive_range = 6
		dive_path
		intercept_every = 40
		break_hits = 3
		break_window = 80
		core_hits = 0
		core_first_hit = 0
		next_dive = 0
		next_intercept = 0
		dive_burn = 6
		dive_mult = 0.4
		expired_intact = 0
		alive = 1
		list/orbit_images
		command_next = 0
	New(mob/o, secs)
		..(null)
		loc = null
		Keeper = o
		if(secs) duration = secs * 10
		if(Keeper)
			if(Keeper.guardian && Keeper.guardian != src) Keeper.guardian.Dismiss(0)
			Keeper.guardian = src
			Keeper.vis_contents += src
		spawn() Orbit()
	proc/Orbit()
		var/ang = 0
		var/elapsed = 0
		while(alive && Keeper && Keeper.loc && elapsed < duration)
			ang = (ang + 12) % 360
			pixel_x = round(cos(ang) * orbit_radius)
			pixel_y = round(sin(ang) * orbit_radius * 0.5) + 16
			if(world.time >= next_dive && Keeper.InCombat())
				var/mob/T = Keeper.Target
				if(ismob(T) && T != Keeper && !T.KO && T.z == Keeper.z && get_dist(Keeper, T) <= dive_range)
					Dive(T)
			sleep(2)
			elapsed += 2
		if(alive)
			expired_intact = 1
			if(Keeper) Keeper.GuardianExpired(src)
		Dismiss(1)
	proc/Dive(mob/T)
		if(!alive || !Keeper || !T) return
		next_dive = world.time + dive_every
		flick("", src)
		var/obj/Skills/AutoHit/D = Keeper.findOrAddSkill(dive_path)
		if(!D) return
		D.DamageMult = dive_mult
		D.TurfBurn = dive_burn
		var/mob/was = Keeper.Target
		Keeper.Target = T
		Keeper.Activate(D, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE)
		Keeper.Target = was
	proc/CommandDive()
		if(!alive || !Keeper || world.time < command_next) return
		var/mob/T = Keeper.Target
		if(!ismob(T) || T == Keeper || T.KO || get_dist(Keeper, T) > dive_range) return
		command_next = world.time + 10
		Dive(T)
	proc/TryIntercept(obj/Skills/Projectile/_Projectile/P)
		if(!alive || !Keeper || !P || P.Owner == Keeper) return 0
		if(P.Area == "Beam") return 0
		if(world.time < next_intercept) return 0
		if(P.Owner && Keeper.inParty(P.Owner.ckey)) return 0
		next_intercept = world.time + intercept_every
		Keeper.PayEventRefund(Keeper.GuardianPage(), "intercept", 1)
		KenShockwave(Keeper, Size = 0.4, Time = 4)
		return 1
	proc/CoreHit()
		if(!alive) return
		if(world.time - core_first_hit > break_window)
			core_first_hit = world.time
			core_hits = 0
		core_hits++
		if(core_hits >= break_hits)
			Dismiss(1)
	proc/Dismiss(fade)
		if(!alive) return
		alive = 0
		if(Keeper)
			Keeper.vis_contents -= src
			if(Keeper.guardian == src) Keeper.guardian = null
		Keeper = null
		loc = null

mob/proc/GuardianPage()
	for(var/obj/Skills/Buffs/B in contents)
		if(B.IsSpell && B.PageKey == "N2") return B
	return null

mob/proc/GuardianExpired(obj/Guardian/G)
	Stoke(5)

mob/proc/GuardianCommand()
	if(guardian) guardian.CommandDive()

mob/proc/GuardianCarry()
	if(!guardian || !guardian.alive) return 0
	var/obj/Guardian/G = guardian
	var/steps = 4
	while(steps > 0)
		var/turf/T = get_step(src, dir)
		if(!T || T.density) break
		var/blocked = 0
		for(var/atom/movable/A in T)
			if(A.density && A != src && !istype(A, /obj/leftOver))
				blocked = 1
				break
		if(blocked) break
		loc = T
		step_x = 0
		step_y = 0
		steps--
		sleep(1)
	G.Dismiss(1)
	return 1

mob/proc/StillnessTick()
	if(!passive_handler || !passive_handler.Get("ManaMethod")) return
	if(!InCombat() || KO || Stunned || Suspended || grabbed || (passive_handler.Get("Snared")))
		still_since = 0
		StillnessFxClear()
		if(still_arrays && world.time > still_array_expire)
			still_arrays = 0
		return
	if(x != still_x || y != still_y || step_x != still_sx || step_y != still_sy)
		still_x = x
		still_y = y
		still_sx = step_x
		still_sy = step_y
		still_since = world.time
		StillnessFxClear()
		return
	if(still_arrays && world.time > still_array_expire)
		still_arrays = 0
	if(still_arrays >= glob.STILLNESS_MAX_ARRAYS) return
	if(!still_since) still_since = world.time
	if(world.time - still_since >= glob.STILLNESS_TICKS)
		still_since = world.time
		still_arrays++
		still_array_expire = world.time + glob.STILLNESS_EXPIRE
		StillnessFx()

mob/proc/StillnessFx()
	StillnessFxClear()
	var/obj/fx_rider/castcircle/C = new(null, "Fire", still_arrays >= 2 ? 4 : 2, 1)
	C.lock_layer = 1
	C.Plant(src, 64, 0)
	C.caster = src
	C.layer = MOB_LAYER - 0.2
	still_array_fx = C
	spawn(glob.STILLNESS_EXPIRE)
		if(still_array_fx == C) StillnessFxClear()

mob/proc/StillnessFxClear()
	if(still_array_fx)
		var/obj/fx_rider/castcircle/C = still_array_fx
		still_array_fx = null
		C.Cut()

mob/proc/SpendStillnessArray(obj/Skills/S)
	if(!S || !S.IsSpell || S.SpellElement != "Fire") return 0
	if(!still_arrays || world.time > still_array_expire)
		still_arrays = 0
		return 0
	var/spend = 1
	if(still_arrays >= 2 && (S.SpellShape == "aoe" || S.SpellShape == "line")) spend = 2
	still_arrays -= spend
	if(still_arrays <= 0)
		still_arrays = 0
		StillnessFxClear()
	S.empowered_cast = spend
	return spend

mob/proc/ManaMethodReach(obj/Skills/S)
	if(!S || !S.empowered_cast) return
	var/r = glob.KINDLED_REACH * S.empowered_cast
	if(istype(S, /obj/Skills/AutoHit))
		var/obj/Skills/AutoHit/A = S
		if(A.Area == "Circle" || A.Area == "Around Target") A.DistanceAround += r
		A.Distance += r
	else if(istype(S, /obj/Skills/Projectile))
		var/obj/Skills/Projectile/P = S
		P.Distance += r
		if(P.Radius > 0) P.Radius += r
		if(P.Explode > 0) P.Explode += r
		if(!P.Homing && last_struck && !last_struck.KO) P.Homing = 1

mob/proc/ManaMethodRestore(obj/Skills/S)
	if(!S) return
	if(istype(S, /obj/Skills/AutoHit))
		var/obj/Skills/AutoHit/A = S
		A.Distance = initial(A.Distance)
		A.DistanceAround = initial(A.DistanceAround)
	else if(istype(S, /obj/Skills/Projectile))
		var/obj/Skills/Projectile/P = S
		P.Distance = initial(P.Distance)
		P.Radius = initial(P.Radius)
		P.Explode = initial(P.Explode)
		P.Homing = initial(P.Homing)

mob/proc/HotbarKeyStillDown(slot)
	if(!slot || !hb_key_down_stamp) return 0
	var/d = hb_key_down_stamp["[slot]"]
	if(!d) return 0
	var/u = hb_key_up_stamp ? hb_key_up_stamp["[slot]"] : 0
	return !u || u < d

mob/verb/Hotbar_Key_Up(n as num)
	set hidden = 1
	set instant = 1
	if(!hb_key_up_stamp) hb_key_up_stamp = list()
	hb_key_up_stamp["[n]"] = world.time

mob/proc/StampHotbarDown(n)
	if(!hb_key_down_stamp) hb_key_down_stamp = list()
	hb_key_down_stamp["[n]"] = world.time
	last_fire_slot = n

mob/proc/SlamMeasure(mob/target, obj/Skills/Projectile/S, tiles, paid)
	if(!target || !S || !S.SlamRefund) return
	var/turf/from = get_turf(target)
	spawn(8)
		if(!target || !from) return
		var/moved = get_dist(from, get_turf(target))
		if(tiles - moved >= S.SlamShort)
			RefundMana(max(0, paid - 0.5))
			for(var/mob/o in range(1, target))
				if(o == target || o == src || o.KO) continue
				if(inParty(o.ckey)) continue
				o.AddBurn(10, src, 1)
				break

mob/proc/CinderTollReset()
	cinder_tolls = 0

/strikeHook/cinderToll
	stage = "ko"
	fire(strike/S)
		if(!S || !S.defender) return
		var/mob/V = S.defender
		if(V.Burn < glob.CINDER_TOLL_MIN_BURN) return
		var/mob/M = S.attacker
		if(!M || M == V) M = V.last_struck_by
		if(!M || M == V || !M.IsMage()) return
		if(M.cinder_tolls >= glob.CINDER_TOLL_PER_RESET) return
		M.cinder_tolls++
		M.RefundMana(M.ManaCap() * glob.CINDER_TOLL_PCT)

/strikeHook/cinderTollKill
	stage = "kill"
	fire(strike/S)
		if(!S || !S.defender) return
		var/mob/V = S.defender
		if(V.Burn < glob.CINDER_TOLL_MIN_BURN) return
		var/mob/M = S.attacker
		if(!M || M == V) M = V.last_struck_by
		if(!M || M == V || !M.IsMage()) return
		if(M.cinder_tolls >= glob.CINDER_TOLL_PER_RESET) return
		M.cinder_tolls++
		M.RefundMana(M.ManaCap() * glob.CINDER_TOLL_PCT)

/strikeHook/guardianCore
	stage = "post"
	fire(strike/S)
		if(!S || !S.attacker || !S.defender || S.attacker == S.defender) return
		var/mob/D = S.defender
		if(!D.guardian || !D.guardian.alive) return
		if(D.inParty(S.attacker.ckey)) return
		D.guardian.CoreHit()

/strikeHook/contactBurn
	stage = "post"
	fire(strike/S)
		if(!S || !S.attacker || !S.defender || S.attacker == S.defender) return
		if(!S.melee && !S.unarmed && !S.sword) return
		var/mob/D = S.defender
		if(!D.passive_handler || !D.passive_handler.Get("ContactBurn")) return
		if(get_dist(S.attacker, D) > 1) return
		var/k = "\ref[S.attacker]"
		if(!D.fuel_paid_stamp) D.fuel_paid_stamp = list()
		var/stamp = D.fuel_paid_stamp["cb[k]"]
		if(stamp && world.time - stamp < glob.CONTACT_BURN_ICD) return
		D.fuel_paid_stamp["cb[k]"] = world.time
		S.attacker.AddBurn(D.passive_handler.Get("ContactBurn"), D, 1)
		D.HeatExchange()

/strike/var/trueDamage = 0
/strike/var/shieldPierce = 0

obj/Skills/AutoHit/proc/OnRound(mob/p, remaining)
	if(remaining == 1 && FinalStrikeMana)
		finale_pending = 1
	if(SelfCleansePools && SelfCleansePools.len && !(event_paid && event_paid["cleanse"]))
		if(!event_paid) event_paid = list()
		event_paid["cleanse"] = 1
		var/n = p.CleanseSpellPools(SelfCleansePools)
		if(SelfCleanseAllies)
			for(var/mob/o in range(max(1, Distance), p))
				if(o == p || o.KO) continue
				if(!p.inParty(o.ckey)) continue
				n += o.CleanseSpellPools(SelfCleansePools)
		if(n > 0) p.Stoke(3)

obj/Skills/AutoHit/proc/OnRoundsDone(mob/p)
	finale_pending = 0

mob/proc/OnSpellImpact(obj/Skills/S, obj/Skills/Projectile/_Projectile/P)
	if(!S || !P || !P.loc) return
	var/obj/Skills/Projectile/PS = S
	if(!istype(PS)) return
	if(PS.SelfScorchRange && get_dist(src, P) <= PS.SelfScorchRange)
		AddBurn(PS.SelfScorchBurn, src, 1)
	if(PS.AllyHitUnder && S.ChargeBenefit < PS.AllyHitUnder)
		for(var/mob/m in view(max(1, P.Explode), P))
			if(m == src || m.KO) continue
			if(!inParty(m.ckey)) continue
			m.LoseHealth(m.PctToHP(PS.AllyDmgMult))
			m.AddBurn(PS.AllyBurn, src, 1)
	if(S.MeltConstructs)
		MeltConstructsAround(P, max(1, P.Explode), S)
	if(S.FireGroundTicks && S.FireGroundRadius)
		SpawnFireGround(get_turf(P), S.FireGroundTicks, S.FireGroundBurn, S.FireGroundDamage, S.FireGroundRadius, S.empowered_cast ? S.DryBurnTicks : 0)

obj/Skills/Projectile/_Projectile/proc/SpellFlightStep()
	if(!from_skill || !Owner) return
	var/obj/Skills/Projectile/PS = from_skill
	if(PS.SteerRate && !Homing && Owner.dir != dir)
		var/want = Owner.dir
		var/cw = turn(dir, -45)
		var/ccw = turn(dir, 45)
		if(cw == want || turn(cw, -45) == want || turn(cw, -90) == want)
			dir = cw
		else
			dir = ccw
	if(PS.BlinkBehind && !blinked)
		var/mob/T = Homing ? Homing : (Owner.Target && ismob(Owner.Target) ? Owner.Target : null)
		if(ismob(T) && T != Owner && !T.KO && T.z == z && get_dist(src, T) <= 1 && loc != T.loc)
			var/turf/behind = get_step(T, turn(T.dir, 180))
			if(behind && !behind.density)
				var/blocked = 0
				for(var/atom/movable/A in behind)
					if(A.density && A != T && A != src)
						blocked = 1
						break
				if(!blocked)
					blinked = 1
					alpha = 0
					animate(src, alpha = 255, time = 2)
					loc = behind
					step_x = 0
					step_y = 0
					dir = get_dir(src, T)
					if(T.SenseUnlocked >= PS.SenseTell)
						KenShockwave(T, Size = 0.4, Time = 3)

mob/proc/EnemyManaDrainAround(radius, pct)
	for(var/mob/m in range(radius, src))
		if(m == src || m.KO || m.Dead) continue
		if(inParty(m.ckey)) continue
		m.LoseMana(m.ManaAmount * pct, 1)

mob/proc/MeltConstructsAround(atom/center, radius, obj/Skills/S)
	. = 0
	for(var/obj/O in range(radius, center))
		if(!O.Meltable) continue
		if(O.loc)
			Bang(O.loc, Size = 1, color_override = FxElementColor("Fire"))
		O.loc = null
		.++
	if(. > 0 && S) PayEventRefund(S, "melt", .)

obj/var/Meltable = 0
obj/SkillPillar/Meltable = 1

mob/proc/TargetBlindAround(atom/center, radius, ticks)
	for(var/mob/m in range(radius, center))
		if(m == src || inParty(m.ckey)) continue
		m.target_lock_block_until = world.time + ticks
		if(m.Target == src) m.RemoveTarget()

mob/proc/AfterFormDebuff(path, secs)
	if(!path) return
	var/p = ispath(path) ? path : text2path("[path]")
	if(!p) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/D = findOrAddSkill(p)
	if(!D) return
	D.TimerLimit = secs
	if(!BuffOn(D)) D.Trigger(src, 1)

obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SpiritFatigue
	name = "Spirit Fatigue"
	BuffName = "Spirit Fatigue"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 10
	ActiveMessage = "sags as the spirit's fire leaves them."
	OffMessage = "recovers from the spirit's departure."
	Trigger(mob/User, Override)
		var/was = User.BuffOn(src)
		..()
		if(!was && User.BuffOn(src))
			User.ManaCut = min(0.9, User.ManaCut + 0.25)
			User.MaxMana()
		else if(was && !User.BuffOn(src))
			User.ManaCut = max(0, User.ManaCut - 0.25)
			User.MaxMana()
