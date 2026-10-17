/mob/proc/NamekIsAlly(mob/m)
	if(!ismob(m))
		return 0
	if(m == src)
		return 1
	if(islist(src.ai_followers) && (m in src.ai_followers))
		return 1
	if(src.party && src.party.members && (m in src.party.members))
		return 1
	return 0

/mob/proc/NamekAllies(range, includeKO = 0)
	var/list/out = list()
	if(!src.KO || includeKO)
		out += src
	var/list/pool = list()
	if(src.party && src.party.members)
		pool |= src.party.members
	if(islist(src.ai_followers))
		pool |= src.ai_followers
	if(!pool.len)
		return out
	var/list/seen = view(range, src)
	for(var/mob/m in pool)
		if(m == src || !m.loc || m.Dead || m.z != src.z)
			continue
		if(m.KO && !includeKO)
			continue
		if(get_dist(src, m) > range || !(m in seen))
			continue
		out |= m
	return out

/mob/proc/NamekSupportTarget(range)
	var/mob/T = src.Target
	if(ismob(T) && T != src && !T.KO && (T in NamekAllies(range)))
		return T
	return src

/mob/proc/NamekKnockedAlly(range)
	var/list/allies = NamekAllies(range, 1)
	var/mob/T = src.Target
	if(ismob(T) && T != src && T.KO && (T in allies))
		return T
	var/mob/best
	var/bestDist
	for(var/mob/m in allies)
		if(m == src || !m.KO)
			continue
		var/d = get_dist(src, m)
		if(!best || d < bestDist)
			best = m
			bestDist = d
	return best

/mob/proc/NamekAnyEvil(list/L)
	for(var/mob/m in L)
		if(m.IsEvil())
			return 1
	return 0

/mob/proc/NamekCastReady(obj/Skills/S)
	if(!S || S.Using || S.cooldown_remaining)
		return 0
	if(src.KO || src.Dead)
		return 0
	if(src.ccActive())
		src << "You cannot use [S] while you are held down."
		return 0
	if(src.passive_handler.Get("Silenced"))
		src << "You can't use [S], you are silenced!"
		return 0
	if(src.HeldSkillBlocksAction(S))
		return 0
	if(src.GCDBlocked(S))
		return 0
	return 1

/mob/proc/NamekManaDrain(obj/Skills/S, evil = 0)
	if(!S || !S.ManaCost || src.HasDrainlessMana())
		return 0
	var/drain = S.ManaCost * src.ChakraCostMult(S) * src.SpellCostMult(S)
	if(evil)
		drain *= 2
	return max(drain, 0.5)

/mob/proc/NamekHasMana(obj/Skills/S, drain)
	if(drain && src.ManaAmount < drain)
		src << "You don't have enough mana to use [S]. (It needs [round(drain, 0.1)].)"
		return 0
	return 1

/mob/proc/NamekSpendMana(drain)
	if(drain)
		src.LoseMana(drain)

/mob/proc/NamekCastTime(ds)
	var/q = src.GetQuickCast()
	if(q > 1)
		return ds / q
	return ds

/mob/proc/NamekChannelHolds(mob/T, range, needKO)
	if(!T || T == src)
		return 1
	if(!T.loc || T.Dead || T.z != src.z)
		return 0
	if(range && get_dist(src, T) > range)
		return 0
	if(needKO && !T.KO)
		return 0
	return 1

/mob/proc/NamekChannel(obj/Skills/S, ds, mob/T, range = 0, needKO = 0)
	ds = NamekCastTime(ds)
	S.Using = 1
	var/until = world.time + ds
	while(world.time < until)
		if(!S)
			return 0
		if(src.KO || src.Dead || src.ccActive())
			S.Using = 0
			src << "Your [S] is interrupted!"
			return 0
		if(!NamekChannelHolds(T, range, needKO))
			S.Using = 0
			src << "You lose your focus on [T]."
			return 0
		sleep(1)
	S.Using = 0
	if(!S || src.KO || src.Dead)
		return 0
	return NamekChannelHolds(T, range, needKO)

/proc/NamekEffect(path, timer, list/fxPassives)
	if(!ispath(path))
		return null
	var/obj/Skills/Buffs/B = new path
	if(timer)
		B.TimerLimit = timer
	if(fxPassives)
		B.passives = fxPassives
	return B

/mob/proc/NamekGiveEffect(mob/m, obj/Skills/Buffs/B)
	if(!ismob(m) || !B)
		return null
	var/obj/Skills/Buffs/old = m.SlotlessBuffs["[B.BuffName]"]
	if(old)
		old.Trigger(m, Override = 1)
	B.Trigger(m, 1)
	return B

/mob/proc/NamekVigorFor(share)
	return share * (src.BaseVit() + glob.HP_STAT_BASE)

/mob/proc/NamekClearKnockout(pct)
	if(!src.KO)
		return 0
	src.MortallyWounded = 0
	src.TsukiyomiTime = 1
	src.KOTimer = 0
	src.KOBrutal = 0
	src.KO = 0
	src.icon_state = ""
	src.PortraitSync()
	FlashStandUp(src)
	src.SetHealthPct(pct)
	src.MaxHealth()
	src.Energy = max(src.Energy, src.EnergyMax / 5)
	if(isplayer(src))
		src:move_speed = MovementSpeed()
	return 1

/mob/proc/NamekCleanseGauges(full = 0)
	src.Bleed = 0
	src.Burn = 0
	src.SilentBurnAmount = 0
	src.Poison = 0
	src.Slow = 0
	src.Shock = 0
	if(full)
		src.Shatter = 0
		src.Drenched = 0
		src.Exposed = 0
	if(isplayer(src))
		src:move_speed = MovementSpeed()

/mob/proc/NamekNewestTimedBuff()
	if(!src.SlotlessBuffs || !src.SlotlessBuffs.len)
		return null
	for(var/i = src.SlotlessBuffs.len, i >= 1, i--)
		var/obj/Skills/Buffs/B = src.SlotlessBuffs[src.SlotlessBuffs[i]]
		if(!istype(B) || !B.TimerLimit || B.AlwaysOn)
			continue
		if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff))
			continue
		return B
	return null

/mob/proc/NamekSupportFX(mob/m)
	if(m)
		KenShockwave(m, Size = 0.4)

/proc/NamekHopeTick(mob/T, obj/Skills/Buffs/B, pct, ticks)
	set waitfor = 0
	for(var/i = 1, i <= ticks, i++)
		sleep(10)
		if(!T || !B || !B.SlotlessOn || T.KO || T.Dead)
			return
		T.HealHealth(pct)
	if(T && B && B.SlotlessOn)
		B.Trigger(T, Override = 1)

/mob/proc/NamekApplyPowerLock()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Power_Lock/s = src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Power_Lock)
	if(s && src.BuffOn(s))
		s.Timer = 0
		return
	s = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Power_Lock)
	if(s)
		s.Trigger(src, TRUE)

/proc/NamekPowerLockHit(mob/target, obj/Skills/Projectile/_Projectile/proj)
	if(!ismob(target) || target.KO || target.Dead)
		return
	if(proj && proj.Owner == target)
		return
	target.NamekApplyPowerLock()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Power_Lock
	name = "Power Lock"
	BuffName = "Power Lock"
	TimerLimit = 8
	passives = list("PULock" = 1)
	ActiveMessage = "has their power sealed and cannot power up!"
	OffMessage = "feels their power stir again."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Blessing_Effect
	name = "Kami's Blessing"
	BuffName = "Kami's Blessing"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 600
	ActiveMessage = "is wrapped in Kami's Blessing!"
	OffMessage = "feels Kami's Blessing fade."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Hope_Effect
	name = "Kami's Hope"
	BuffName = "Kami's Hope"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 10
	ActiveMessage = "is soothed by Kami's Hope."
	OffMessage = "feels Kami's Hope settle."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Barrier_Effect
	name = "Kami's Barrier"
	BuffName = "Kami's Barrier"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 30
	VaizardHealth = 15
	VaizardShatter = 1
	ActiveMessage = "is shielded by Kami's Barrier!"
	OffMessage = "loses the shelter of Kami's Barrier."

/obj/Skills/Projectile/Namekian/Energy_Cannon
	name = "Energy Cannon"
	desc = "Fire a solid blast of ki straight at your foe."
	Copyable = 0
	DamageMult = 1
	Distance = 15
	Cooldown = 6
	EnergyCost = 1
	Knockback = 0
	IconLock = 'Blast - Charged.dmi'
	ActiveMessage = "fires a solid blast of ki!"

	verb/Energy_Cannon()
		set name = "Energy Cannon"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Energy_Bullets
	name = "Energy Bullets"
	desc = "Fire up to four quick ki bullets in a row before the technique cools down."
	Copyable = 0
	DamageMult = 0.3
	MultiShot = 4
	Distance = 15
	Cooldown = 10
	EnergyCost = 2
	Knockback = 0
	IconLock = 'Blast - Basic.dmi'
	ActiveMessage = "fires a stream of ki bullets!"

	verb/Energy_Bullets()
		set name = "Energy Bullets"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Ignite
	name = "Ignite"
	desc = "Hurl an orb of ki that bursts on impact, striking everyone within a tile of it."
	Copyable = 0
	DamageMult = 1.2
	Radius = 1
	Explode = 1
	Distance = 12
	Cooldown = 12
	EnergyCost = 2
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Charged.dmi'
	ActiveMessage = "hurls a bursting orb of ki!"

	verb/Ignite()
		set name = "Ignite"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Super_Energy_Bullets
	name = "Super Energy Bullets"
	desc = "Fire up to four heavy ki bullets in a row. Every bullet that hits seals the target's power, so they cannot power up for eight seconds."
	Copyable = 0
	DamageMult = 0.35
	MultiShot = 4
	Distance = 15
	Cooldown = 14
	EnergyCost = 3
	Knockback = 0
	IconLock = 'Blast - Basic.dmi'
	OnMobHit = "/proc/NamekPowerLockHit"
	ActiveMessage = "fires a stream of power-sealing bullets!"

	verb/Super_Energy_Bullets()
		set name = "Super Energy Bullets"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Utility/Namekian/Healing_Wave
	name = "Healing Wave"
	desc = "Focus for one second, then heal your targeted party member for 20 percent of their health, or yourself if you target no ally. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 3
	Cooldown = 8
	var/HealAmount = 20
	var/CastTime = 10
	var/SupportRange = 10

	verb/Healing_Wave()
		set name = "Healing Wave"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekTargetHealStart(src, src.HealAmount, src.CastTime, src.SupportRange)

/mob/proc/NamekTargetHealStart(obj/Skills/S, amount, ds, range)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(range)
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	S.Using = 1
	spawn()
		NamekTargetHealCast(S, T, amount, ds, range)

/mob/proc/NamekTargetHealCast(obj/Skills/S, mob/T, amount, ds, range)
	src.OMessage(10, "[src] gathers a wave of healing ki...", "<font color=green>[src]([src.key]) begins [S] on [T].")
	if(!NamekChannel(S, ds, T, range))
		return
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	T.HealHealth(amount)
	NamekSupportFX(T)
	src.OMessage(10, "[src] washes [T == src ? "themselves" : T] in a wave of healing ki!", "<font color=green>[src]([src.key]) heals [T] with [S].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Blessing
	name = "Kami's Blessing"
	desc = "Bless every party member in view, yourself included: their maximum health rises by 10 percent for ten minutes. Costs double mana if any of them has an evil heart."
	Copyable = 0
	ManaCost = 5
	Cooldown = 60
	var/BlessingShare = 0.1
	var/BlessingTime = 600
	var/PartyRange = 10

	verb/Kamis_Blessing()
		set name = "Kamis Blessing"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisBlessing(src)

/mob/proc/NamekKamisBlessing(obj/Skills/Utility/Namekian/Kamis_Blessing/S)
	if(!NamekCastReady(S))
		return
	var/list/allies = NamekAllies(S.PartyRange)
	var/drain = NamekManaDrain(S, NamekAnyEvil(allies))
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	for(var/mob/m in allies)
		NamekGiveEffect(m, NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Blessing_Effect, S.BlessingTime, list("Vigor" = m.NamekVigorFor(S.BlessingShare))))
		NamekSupportFX(m)
	src.OMessage(10, "[src] calls Kami's Blessing down upon their allies!", "<font color=green>[src]([src.key]) casts Kami's Blessing on [allies.len] allies.")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Hope
	name = "Kami's Hope"
	desc = "Mend your targeted party member, or yourself, for 2 percent of their health every second for ten seconds. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 4
	Cooldown = 12
	var/HopePct = 2
	var/HopeTicks = 10
	var/SupportRange = 10

	verb/Kamis_Hope()
		set name = "Kamis Hope"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisHope(src)

/mob/proc/NamekKamisHope(obj/Skills/Utility/Namekian/Kamis_Hope/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	var/obj/Skills/Buffs/B = NamekGiveEffect(T, NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Hope_Effect, S.HopeTicks + 1))
	NamekHopeTick(T, B, S.HopePct, S.HopeTicks)
	NamekSupportFX(T)
	src.OMessage(10, "[src] fills [T == src ? "themselves" : T] with Kami's Hope.", "<font color=green>[src]([src.key]) casts Kami's Hope on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Barrier
	name = "Kami's Barrier"
	desc = "Shield your targeted party member, or yourself, with a barrier worth 15 percent of their health for thirty seconds. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 6
	Cooldown = 30
	var/BarrierPct = 15
	var/BarrierTime = 30
	var/SupportRange = 10

	verb/Kamis_Barrier()
		set name = "Kamis Barrier"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisBarrier(src)

/mob/proc/NamekKamisBarrier(obj/Skills/Utility/Namekian/Kamis_Barrier/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Barrier_Effect, S.BarrierTime)
	B.VaizardHealth = S.BarrierPct
	NamekGiveEffect(T, B)
	NamekSupportFX(T)
	src.OMessage(10, "[src] raises Kami's Barrier around [T == src ? "themselves" : T]!", "<font color=green>[src]([src.key]) casts Kami's Barrier on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Desire
	name = "Kami's Desire"
	desc = "Tear the newest timed buff off your target and drain 5 percent of their health into yourself."
	Copyable = 0
	ManaCost = 5
	Cooldown = 20
	var/DrainPct = 5
	var/DesireRange = 10

	verb/Kamis_Desire()
		set name = "Kamis Desire"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisDesire(src)

/mob/proc/NamekKamisDesire(obj/Skills/Utility/Namekian/Kamis_Desire/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = src.Target
	if(!ismob(T) || T == src || T.KO || T.Dead || T.z != src.z)
		src << "You need a conscious foe targeted to use [S]."
		return
	if(NamekIsAlly(T))
		src << "You cannot turn [S] on an ally."
		return
	if(get_dist(src, T) > S.DesireRange || !(T in view(S.DesireRange, src)))
		src << "[T] is out of range."
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	S.Cooldown(1, null, src)
	var/obj/Skills/Buffs/B = T.NamekNewestTimedBuff()
	if(B)
		src.OMessage(10, "[src] tears [B] away from [T]!", "<font color=red>[src]([src.key]) strips [B] from [T]([T.key]) with Kami's Desire.")
		B.Trigger(T, Override = 1)
	else
		src.OMessage(10, "[src] reaches into [T] with Kami's Desire!", "<font color=red>[src]([src.key]) uses Kami's Desire on [T]([T.key]).")
	NamekSupportFX(T)
	src.DoDamage(T, T.PctToHP(S.DrainPct))
	if(!src.KO)
		src.HealHealth(S.DrainPct)

/obj/Skills/Utility/Namekian/Kamis_Will
	name = "Kami's Will"
	desc = "Channel for six seconds over a knocked-out party member in view: they rise with 25 percent health. Your target goes first, otherwise the nearest fallen ally. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 20
	Cooldown = 120
	var/ReviveHealthPct = 25
	var/CastTime = 60
	var/SupportRange = 10

	verb/Kamis_Will()
		set name = "Kamis Will"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekReviveStart(src, src.ReviveHealthPct, src.CastTime, src.SupportRange)

/mob/proc/NamekReviveStart(obj/Skills/S, S_Health, S_Time, S_Range)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekKnockedAlly(S_Range)
	if(!T)
		src << "There is no knocked-out ally in view to revive."
		return
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	S.Using = 1
	spawn()
		NamekReviveCast(S, T, S_Health, S_Time, S_Range)

/mob/proc/NamekReviveCast(obj/Skills/S, mob/T, S_Health, S_Time, S_Range)
	src.OMessage(10, "[src] kneels over [T] and pours out their life force...", "<font color=green>[src]([src.key]) begins [S] on [T].")
	if(!NamekChannel(S, S_Time, T, S_Range, 1))
		return
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	T.NamekClearKnockout(S_Health)
	NamekSupportFX(T)
	src.OMessage(15, "[T] rises again, restored by [src]'s [S]!", "<font color=green>[src]([src.key]) revives [T] with [S].")
	S.Cooldown(1, null, src)
