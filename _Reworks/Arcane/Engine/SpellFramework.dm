obj/Skills/var
	IsSpell = 0
	SpellTier = 0
	SpellShape
	PageKey
	Desc
	list/Primes
	list/Consumes
	list/PrimedBy

mob/var/tmp
	combat_until = 0
	mob/last_struck
	mob/last_struck_by

globalTracker/var
	COMBAT_WINDOW = 100

mob/proc/MarkCombat(mob/other)
	combat_until = world.time + glob.COMBAT_WINDOW
	if(other && other != src)
		last_struck = other
		other.combat_until = world.time + glob.COMBAT_WINDOW
		other.last_struck_by = src

mob/proc/InCombat()
	return world.time < combat_until

proc/PoolVarFor(pool)
	if(!pool) return null
	if(pool in ELEMENT_POOL) return ELEMENT_POOL[pool]
	return pool

mob/proc/PoolValue(pool)
	var/v = PoolVarFor(pool)
	if(!v) return 0
	. = 0
	switch(v)
		if("Judged") . = passive_handler.Get("Judged") ? 100 : 0
		if("Burn") . = Burn
		if("Drenched") . = Drenched
		if("Slow") . = Slow
		if("Exposed") . = Exposed
		if("Shock") . = Shock
		if("Shatter") . = Shatter
		if("Poison") . = Poison
		if("Bleed") . = Bleed
		if("Doomed") . = Doomed
		if("Sheared") . = Sheared
	if(!.) . = 0

mob/proc/SetPool(v, amount)
	switch(v)
		if("Burn") Burn = amount
		if("Drenched") Drenched = amount
		if("Slow") Slow = amount
		if("Exposed") Exposed = amount
		if("Shock") Shock = amount
		if("Shatter") Shatter = amount
		if("Poison") Poison = amount
		if("Bleed") Bleed = amount
		if("Doomed") Doomed = amount
		if("Sheared") Sheared = amount

mob/proc/HasPool(pool, minimum = 1)
	return PoolValue(pool) >= minimum

mob/proc/ConsumeStacks(pool, amount = 0)
	var/v = PoolVarFor(pool)
	if(!v) return 0
	if(v == "Judged")
		if(!passive_handler.Get("Judged")) return 0
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Judged/J = locate() in src
		if(J && BuffOn(J))
			J.Trigger(src, 1)
		return 100
	var/cur = PoolValue(v)
	if(!cur || cur <= 0) return 0
	var/take = (amount > 0) ? min(amount, cur) : cur
	SetPool(v, cur - take)
	return take

obj/Skills/proc/OnConsume(mob/caster, mob/target, pool, amount)
	return

mob/proc/SpendSpellPools(obj/Skills/S, mob/target)
	if(!S || !target || !S.Consumes || !S.Consumes.len) return 0
	if(S.consume_depth > 0) return 0
	S.consume_depth++
	var/total = 0
	for(var/pool in S.Consumes)
		var/took = target.ConsumeStacks(pool, S.ConsumeAmount)
		if(took > 0)
			total += took
			S.OnConsume(src, target, pool, took)
	S.consume_depth = max(0, S.consume_depth - 1)
	if(total > 0)
		S.last_consumed_total += total
		if(!S.OwnRefund && S.TitheRate > 0)
			var/cap = S.TitheCap ? S.TitheCap : S.ManaCost
			var/mult = passive_handler ? (1 + passive_handler.Get("TitheDouble")) : 1
			if(!S.event_paid) S.event_paid = list()
			var/want = min(S.last_consumed_total * S.TitheRate, cap) * mult
			var/owed = want - S.event_paid["tithe"]
			if(owed > 0)
				S.event_paid["tithe"] = want
				RefundMana(owed)
		if(total >= S.StokeMin && S.StokeSecs)
			Stoke(S.StokeSecs)
		for(var/obj/Skills/Buffs/B in contents)
			if(B.IsSpell && B.PageKey == "SHELF_P" && BuffOn(B))
				RefundMana(5)
				break
	return total

mob/proc/RefundMana(val)
	if(!val || val <= 0) return 0
	if(KO || Dead || PureRPMode || Transfering) return 0
	if(HasDrainlessMana()) return 0
	if(passive_handler && (passive_handler.Get("LunarWrath") || passive_handler.Get("Unrelenting Wrath"))) return 0
	if(IsExhausted())
		refund_bank += val
		return 0
	return RefundManaNow(val)

mob/proc/SpellPrimed(obj/Skills/S)
	if(!S || !S.PrimedBy || !S.PrimedBy.len) return 0
	for(var/pool in S.PrimedBy)
		if(pool == "SelfHit")
			if(SelfHitRecently()) return 1
			continue
		if(pool == "AfterExhausted")
			if(exhausted_free_until && world.time < exhausted_free_until) return 1
			continue
		if(pool == "Hawk")
			if(guardian && guardian.alive) return 1
			continue
	if(!InCombat()) return 0
	var/mob/T = last_struck
	if(!T || T.KO || T.Dead) return 0
	for(var/pool in S.PrimedBy)
		if(pool == "SelfHit" || pool == "AfterExhausted" || pool == "Hawk") continue
		if(T.HasPool(pool, max(1, S.PrimeThreshold))) return 1
	return 0

mob/proc/OnSpellCast(obj/Skills/S)
	if(!S) return
	MarkCombat()
	TomeFlip()
	CloseCastCircle()
	var/obj/fx_rider/castcircle/C = SpawnCastCircle(S, S.HeldSkill ? 1 : 0)
	if(S.HeldSkill) held_circle = C
	if(S.SpellElement == "Fire" && guardian && (S.SpellShape == "line" || S.SpellShape == "projectile"))
		GuardianCommand()

mob/proc/FireKOHook(mob/P)
	var/strike/S = new(P, src, 0)
	fireStrikeHooks("ko", S)

mob/proc/FireKillHook(mob/P)
	var/strike/S = new(P, src, 0)
	fireStrikeHooks("kill", S)
