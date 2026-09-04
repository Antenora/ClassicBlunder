obj/Skills/Fire/Crimson_Eruption
	name = "Crimson Eruption"
	SpellTier = 4
	SpellShape = "aoe"
	PageKey = "61"
	MenuIcon = "Supernova"
	Desc = "Plant your feet and etch a great circle of natural mana beneath your target; a stun or a shove while you draw wastes only your breath. When the circle closes, true flame erupts across it: everything inside is scorched and set alight, whatever hides there is dragged into the light, and the ground burns on. Every ember already on those inside is spent as searing true damage, and each enemy it consumes brings the next eruption closer."
	ManaCost = 14
	Cooldown = 35
	PrimedBy = list("Fire")
	PrimeThreshold = 30
	LitCostMult = 0.5
	var/tmp/consumed_count = 0
	var/tmp/casting = 0
	verb/Crimson_Eruption()
		set name = "Crimson Eruption"
		set category = "Skills"
		if(src.Using || src.cooldown_remaining || casting) return
		if(usr.KO || usr.Dead) return
		if(usr.HeldSkillBlocksAction(src) || usr.GCDBlocked(src)) return
		if(usr.passive_handler.Get("Silenced"))
			usr << "<font color=red>You can't use [src], you are silenced!</font>"
			return
		var/mob/T = usr.Target
		if(!ismob(T) || T == usr || T.KO || T.z != usr.z || get_dist(usr, T) > 6)
			usr << "<font color=red>You need a target within six tiles to plant the circle beneath.</font>"
			return
		if(!usr.SpellPreCast(src)) return
		var/need = usr.SpellManaNeed(src)
		if(usr.ManaAmount < need)
			usr << "<font color=red>You don't have enough mana to draw [src].</font>"
			return
		var/turf/center = get_turf(T)
		if(!center) return
		var/draw = max(5, 15 - 5 * src.empowered_cast)
		usr.StartGCD(src)
		casting = 1
		consumed_count = 0
		usr.Frozen = 1
		var/obj/fx_rider/castcircle/C = new(center, "Fire", 5, 1)
		C.caster = usr
		OMsg(usr, "[usr] plants their feet and etches a great circle of natural mana beneath [T]...")
		var/t = 0
		while(t < draw)
			sleep(1)
			t++
			if(usr.Stunned || usr.Launched || usr.KO || usr.Knockbacked)
				if(usr.Frozen == 1) usr.Frozen = 0
				casting = 0
				C.Close()
				src.Cooldown(0.5, null, usr)
				return
		var/obj/Skills/AutoHit/Fire/Crimson_Eruption_Blast/R = usr.findOrAddSkill(/obj/Skills/AutoHit/Fire/Crimson_Eruption_Blast)
		if(R && ismob(T))
			R.parent_page = src
			R.empowered_cast = src.empowered_cast
			R.DistanceAround = initial(R.DistanceAround) + glob.KINDLED_REACH * src.empowered_cast
			var/mob/was = usr.Target
			usr.Target = T
			OMsg(usr, "[usr] closes the circle and crimson flame erupts from the ground!")
			usr.Activate(R, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE)
			sleep(2)
			usr.Target = was
		usr.SpawnFireGround(center, 40, 5, 0, 3)
		C.Close()
		if(usr.Frozen == 1) usr.Frozen = 0
		casting = 0
		usr.LoseMana(need)
		src.Cooldown(1, null, usr)
		if(consumed_count > 0 && src.Using)
			var/refund = min(15, 3 * consumed_count) * 10
			var/remaining = max(0, src.cooldown_remaining - (world.time - src.cooldown_start_wt))
			if(remaining > 0) src.RefundCooldown(min(1, refund / remaining))
		if(consumed_count >= 2) usr.Stoke(6)

obj/Skills/AutoHit/Fire/Crimson_Eruption_Blast
	name = "Crimson Eruption"
	Area = "Around Target"
	DistanceAround = 3
	Distance = 6
	Rounds = 1
	DamageMult = 6
	TurfBurn = 15
	RevealHidden = 4
	Consumes = list("Fire")
	TrueDamagePerPoint = 0.1
	TitheRate = 0.15
	TitheCap = 14
	StokeMin = 999
	SilentCast = 1
	NoGCD = 1
	ManaCost = 0
	Cooldown = 0
	IsSpell = 1
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkX = -16
	HitSparkY = -16
	var/tmp/obj/Skills/Fire/Crimson_Eruption/parent_page
	OnConsume(mob/caster, mob/target, pool, amount)
		if(parent_page) parent_page.consumed_count++

obj/Skills/Projectile/Fire/Exodus_Flame
	name = "Exodus Flame"
	SpellTier = 4
	SpellShape = "projectile"
	PageKey = "N7"
	MenuIcon = "DragonNova"
	Desc = "Hold and a sphere of fire gathers in your hand; keep holding past full to pour more mana into it and it swells, up to six pours. The sphere lobs over walls and pillars and bursts wide on the first enemy or at the end of its flight, spending every ember on those it catches as true damage and returning mana for each point burned away. Stand too close to the blast and it scorches you too; thrown half-charged it singes your allies."
	HeldSkill = TRUE
	ChargePeriod = 1.2
	NoFizzle = TRUE
	HeldFreeze = 1
	HeldVulnerability = 0.2
	OverchargeManaPerStep = 2
	OverchargeMaxSteps = 6
	OverchargeStepTicks = 4
	ArcShot = 1
	IconLock = 'Icons/NSE/Attacks/Medium Fireball.dmi'
	LockX = -16
	LockY = -16
	Explode = 2
	Speed = 1
	Distance = 6
	DamageMult = 5
	ManaCost = 12
	Cooldown = 30
	Consumes = list("Fire")
	TrueDamagePerPoint = 0.1
	OwnRefund = 1
	StokeMin = 30
	PrimedBy = list("Fire")
	PrimeThreshold = 30
	LitCostMult = 0.5
	SelfScorchRange = 2
	SelfScorchBurn = 15
	AllyHitUnder = 0.5
	AllyDmgMult = 0.25
	AllyBurn = 5
	ChargeOverlay = 'FlameGlowHades.dmi'
	OnConsume(mob/caster, mob/target, pool, amount)
		if(!event_paid) event_paid = list()
		var/paid = event_paid["refund"]
		if(!paid) paid = 0
		var/amt = min(amount * (0.06 + 0.01 * overcharge_steps), 15 - paid)
		if(amt <= 0) return
		event_paid["refund"] = paid + amt
		caster.RefundMana(amt)
	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		DamageMult = initial(DamageMult) * (0.5 + 0.5 * benefit) * (1 + 0.1 * overcharge_steps)
		Explode = (overcharge_steps >= 6 ? 3 : 2) + glob.KINDLED_REACH * empowered_cast
		p.UseProjectile(src, noGCD = TRUE)
		ResetHeldConfig()
	OnHeldFizzle(mob/p)
		ResetHeldConfig()
	verb/Exodus_Flame()
		set name = "Exodus Flame"
		set category = "Skills"
		if(!usr.held_skill && lit_cached_time) lit_cached_time = 0
		usr.BeginHeldSkill(src)

obj/Skills/Fire/Dragos_Nowl
	name = "Dragos Nowl"
	SpellTier = 4
	SpellShape = "aoe"
	PageKey = "N3"
	MenuIcon = "MeteorStrike"
	Desc = "Six circles open in the sky over your target's ground and rain flame in three heavy pulses that alternate between the two halves of a checkerboard; those in the air take it harder. A clean enemy is set alight, while one already burning has a share of its fire spent as true damage and returns a little mana. You may keep moving, and a living Halcon Gardinas halves the cost and dives with every pulse."
	ManaCost = 14
	Cooldown = 30
	PrimedBy = list("Fire")
	PrimeThreshold = 10
	LitCostMult = 0.5
	PairBonusSkill = "/obj/Skills/Buffs/SlotlessBuffs/Fire/Halcon_Gardinas"
	PairCostMult = 0.5
	Consumes = list("Fire")
	ConsumeAmount = 20
	ConsumeMinPool = 20
	TrueDamagePerPoint = 0.1
	OwnRefund = 1
	var/tmp/casting = 0
	var/tmp/pulse_paid = 0
	OnConsume(mob/caster, mob/target, pool, amount)
		if(pulse_paid) return
		if(!event_paid) event_paid = list()
		var/paid = event_paid["drip"]
		if(!paid) paid = 0
		if(paid >= 6) return
		pulse_paid = 1
		event_paid["drip"] = paid + 2
		caster.RefundMana(2)
	proc/Pulse(mob/p, mob/m)
		var/powerDif = p.getPower(m)
		var/statPower = p.getStatDmg2(autohit = TRUE) + p.GetFor(1)
		var/endFactor = m.getEndStat(1)
		var/dmg = strikeCoreDamage(clamp(powerDif, 0.1, 100000), statPower, endFactor)
		dmg *= p.strikeJudgmentMult() * 0.9
		dmg *= p.SpellHitMult(src, m)
		if(m.Airborne) dmg *= 1.25
		p.MarkCombat(m)
		m.LoseHealth(dmg)
		var/consumed = p.OnSpellHit(src, m, null)
		if(!consumed) m.AddBurn(12, p, 1)
	verb/Dragos_Nowl()
		set name = "Dragos Nowl"
		set category = "Skills"
		if(src.Using || src.cooldown_remaining || casting) return
		if(usr.KO || usr.Dead) return
		if(usr.HeldSkillBlocksAction(src) || usr.GCDBlocked(src)) return
		if(usr.passive_handler.Get("Silenced"))
			usr << "<font color=red>You can't use [src], you are silenced!</font>"
			return
		if(!usr.SpellPreCast(src)) return
		var/need = usr.SpellManaNeed(src)
		if(usr.ManaAmount < need)
			usr << "<font color=red>You don't have enough mana to call down [src].</font>"
			return
		var/turf/center
		var/mob/T = usr.Target
		if(ismob(T) && T != usr && !T.KO && T.z == usr.z && get_dist(usr, T) <= 6)
			center = get_turf(T)
		else
			center = get_turf(usr)
			for(var/i = 1, i <= 4, i++)
				var/turf/n = get_step(center, usr.dir)
				if(!n) break
				center = n
		if(!center) return
		casting = 1
		usr.StartGCD(src)
		usr.LoseMana(need)
		var/half = 2 + glob.KINDLED_REACH * src.empowered_cast
		var/list/zone = list()
		for(var/dx = -half, dx <= half, dx++)
			for(var/dy = -half, dy <= half, dy++)
				var/turf/Z = locate(center.x + dx, center.y + dy, center.z)
				if(Z) zone += Z
		var/list/circles = list()
		var/list/offs = list(list(-1, 1), list(1, 1), list(-1, -1), list(1, -1), list(-2, 0), list(2, 0))
		for(var/list/o in offs)
			var/turf/S = locate(center.x + o[1], center.y + o[2], center.z)
			if(!S) continue
			var/obj/fx_rider/castcircle/C = new(S, "Fire", 1, 1)
			C.caster = usr
			C.pixel_y += 48
			C.layer = MOB_LAYER + 0.3
			circles += C
		OMsg(usr, "[usr] opens six circles of flame in the sky!")
		sleep(5)
		for(var/pulse = 0, pulse < 3, pulse++)
			if(usr.KO || usr.Dead) break
			src.consumed_targets = null
			pulse_paid = 0
			usr.GuardianCommand()
			for(var/turf/Z in zone)
				if((Z.x + Z.y + pulse) % 2) continue
				Bang(Z, Size = 1, color_override = FxElementColor("Fire"))
				for(var/mob/m in Z)
					if(m == usr || m.KO || m.Dead) continue
					if(usr.inParty(m.ckey)) continue
					Pulse(usr, m)
			if(pulse < 2) sleep(10)
		for(var/obj/fx_rider/castcircle/C in circles)
			C.Close()
		casting = 0
		src.Cooldown(1, null, usr)

obj/Skills/AutoHit/Fire/Calidus_Brachium_Barrage
	name = "Mana Zone: Calidus Brachium Barrage"
	SpellTier = 4
	SpellShape = "autohit"
	PageKey = "N4"
	MenuIcon = "RedHotHundred"
	Desc = "A ring of heat flares around you, then eight fists of fire strike a target within three tiles from every side, ignoring facing, guard and dodge, and holding them in place while the blows land; enemy shots near you crawl through the heat. The first fist spends all the fire on the target for extra fists, a heavy enough pool leaves the last blow as a stun, and landing the final fist returns mana."
	Area = "Around Target"
	Distance = 3
	DistanceAround = 1
	Rounds = 8
	DelayTime = 2
	RoundMovement = 1
	GuardBreak = 1
	HoldTarget = 1.6
	TurfBurn = 4
	DamageMult = 0.9
	StrScaling = 0.5
	ForScaling = 0.5
	RoundsFromPool = 15
	RoundsFromPoolMax = 12
	LastRoundStunAt = 60
	LastRoundStun = 1
	FinalStrikeMana = 4
	Consumes = list("Fire")
	PrimedBy = list("Fire")
	PrimeThreshold = 15
	LitCostMult = 0.5
	TitheRate = 0.15
	TitheCap = 12
	ManaCost = 12
	Cooldown = 30
	HitSparkIcon = 'FIRE_FIST.dmi'
	HitSparkX = -9
	HitSparkY = -9
	var/tmp/first_round = 0
	OnRound(mob/p, remaining)
		..()
		if(!first_round)
			first_round = remaining
			SlowMoZone(p, 3, 1.25, 20, p, 1)
	OnRoundsDone(mob/p)
		..()
		first_round = 0
	verb/Calidus_Brachium_Barrage()
		set name = "Calidus Brachium Barrage"
		set category = "Skills"
		var/mob/T = usr.Target
		if(!ismob(T) || T == usr || T.KO || T.z != usr.z || get_dist(usr, T) > Distance)
			usr << "<font color=red>You need a target within three tiles to close the mana zone around.</font>"
			return
		usr.Activate(src)

obj/Skills/AutoHit/Fire/Leo_Rugiens
	name = "Leo Rugiens"
	SpellTier = 4
	SpellShape = "line"
	PageKey = "62"
	MenuIcon = "NovaStrike"
	Desc = "A lion of fire gathers behind you for a breath, then roars a wide wave of flame ten tiles down the line: heavy damage, a two-tile shove, deep burns, and burning ground where it lands. It spends nothing and hits harder the more fire each target already carries, and every enemy caught beyond the first returns mana."
	Area = "Wider Wave"
	Distance = 10
	WindUp = 0.8
	WindupIcon = 'Fire VFX8.dmi'
	WindupIconX = -48
	WindupIconY = -48
	DamageMult = 5.5
	Knockback = 2
	TurfBurn = 20
	FireGroundTicks = 30
	FireGroundBurn = 4
	AmpVsPool = "Fire"
	AmpVsPoolStep = 20
	AmpVsPoolPerStep = 0.1
	AmpVsPoolCap = 0.5
	ManaCost = 14
	Cooldown = 30
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	EventRefund = list("crowd" = 2)
	EventRefundCap = list("crowd" = 8)
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkX = -16
	HitSparkY = -16
	var/tmp/list/crowd_hit
	OnRound(mob/p, remaining)
		..()
		crowd_hit = null
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		if(!crowd_hit) crowd_hit = list()
		if(m in crowd_hit) return
		crowd_hit += m
		if(crowd_hit.len >= 2) caster.PayEventRefund(src, "crowd", 1)
	OnRoundsDone(mob/p)
		..()
		crowd_hit = null
	verb/Leo_Rugiens()
		set name = "Leo Rugiens"
		set category = "Skills"
		usr.Activate(src)

obj/Skills/Buffs/SlotlessBuffs/Fire/Hellfire_Incarnate
	name = "Hellfire Incarnate"
	BuffName = "Hellfire Incarnate"
	SpellTier = 4
	SpellShape = "mage passive"
	PageKey = "SHELF_M2"
	MenuIcon = "EruptingBurningFinger"
	Desc = "Once per engagement, the first stun, root, freeze, suspension or grab that would take hold of you in combat is refused as your body ignites into a form of flame. For eight seconds mana floods back in, your fire spells burn hotter the longer the form lasts, and every ember your spells consume tithes double; in the final three seconds the flame consumes your own body and no healing reaches you. Meditating rekindles it."
	Cooldown = -1
	TimerLimit = 8
	MiscBindable = 0
	NeedsPassword = 0
	AlwaysOn = 0
	ManaCost = 0
	IconLock = 'DarknessFlameAura.dmi'
	LockX = -32
	LockY = -32
	IconLayer = -1
	AuraArt = 1
	passives = list("TitheDouble" = 1)
	ActiveMessage = "ignites into a body of flame!"
	OffMessage = "gutters out as the flames die down."
	var/tmp/power_added = 0
	var/tmp/ignite_id = 0
	Trigger(mob/User, Override)
		if(!User) return 0
		var/was = User.BuffOn(src)
		. = ..()
		var/now = User.BuffOn(src)
		if(!was && now)
			Ignite(User)
		else if(was && !now)
			Snuff(User)
	proc/Ignite(mob/User)
		ignite_id++
		var/id = ignite_id
		User.cc_immune_until = max(User.cc_immune_until, world.time + 80)
		User.RefundMana(0.15 * User.ManaCap())
		User.AddElementPower("Fire", 0.15)
		power_added += 0.15
		spawn(30)
			if(id == ignite_id && User && User.BuffOn(src))
				User.AddElementPower("Fire", 0.15)
				power_added += 0.15
		spawn(50)
			if(id == ignite_id && User && User.BuffOn(src))
				User.AddElementPower("Fire", 0.15)
				power_added += 0.15
				applyHealCut(User, 30)
				Dissolve(User, id)
	proc/Dissolve(mob/User, id)
		var/ticks = 0
		while(ticks < 30 && id == ignite_id && User && !User.KO && !User.Dead && User.BuffOn(src))
			var/dmg = min(User.PctToHP(1.5), User.Health - 1)
			if(dmg > 0) User.LoseHealth(dmg)
			sleep(5)
			ticks += 5
	proc/Snuff(mob/User)
		ignite_id++
		if(power_added)
			User.AddElementPower("Fire", -power_added)
			power_added = 0

obj/Skills/Buffs/SlotlessBuffs/Fire/True_Fire_Magic
	SilentCast = 1
	name = "True Fire Magic"
	BuffName = "True Fire Magic"
	SpellTier = 4
	SpellShape = "spell passive"
	PageKey = "SHELF_S2"
	MenuIcon = "BurningFinger"
	Desc = "Your area and line fire spells leave real fire on the ground they strike, burning whoever stands there for a moment after. Fire that finds fresh fuel returns a little mana, and kindled casts burn longer with flames that resist water."
	AlwaysOn = 1
	NeedsPassword = 0
	doNotDelete = 1
	TimerLimit = 0
	MiscBindable = 0
	ManaCost = 0
	Cooldown = 0
	passives = list("TrueFire" = 1)
	New()
		..()
		spawn() Watch()
	proc/Watch()
		while(src)
			if(ismob(loc))
				var/mob/M = loc
				if(!Using && !M.KO && !M.Dead && !M.BuffOn(src))
					Trigger(M, 1)
				sleep(50)
			else
				sleep(50)
