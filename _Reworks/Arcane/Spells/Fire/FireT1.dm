obj/Skills/AutoHit/Fire
	IsSpell = 1
	SpellElement = "Fire"
	ForScaling = 1
	CritEffectiveness = 0

obj/Skills/Projectile/Fire
	IsSpell = 1
	SpellElement = "Fire"
	CritEffectiveness = 0

obj/Skills/Buffs/SlotlessBuffs/Fire
	IsSpell = 1
	SpellElement = "Fire"
	Slotless = 1

obj/Skills/AutoHit/Fire/Spiral_Flame
	name = "Spiral Flame"
	SpellTier = 1
	SpellShape = "autohit"
	PageKey = "ENTRY"
	MenuIcon = "BlazingStorm"
	Desc = "Flames pour from your palms in three quick spirals that each burn. Keep the key held through the first two and the third is thrown with both arms, wider and hotter, for two more mana. Landing the last spiral returns mana."
	Area = "Arc"
	Distance = 2
	Rounds = 3
	DelayTime = 3
	DamageMult = 0.6
	TurfBurn = 4
	ManaCost = 3
	Cooldown = 5
	FinalStrikeMana = 2
	RoundMovement = 0
	RecoveryLock = 7
	CircleSide = 19
	CircleScale = 0.6
	HitSparkIcon = 'BLANK.dmi'
	var/tmp/finale_armed = 0
	var/tmp/cast_open = 0
	var/tmp/list/live_arts
	var/tmp/icon/art_spiral
	var/tmp/icon/art_cone
	New()
		..()
		art_spiral = icon('Icons/PerditionMagic/Spells/SpiralFlame_spiral.dmi', "spiral")
		art_cone = icon('Icons/PerditionMagic/Spells/SpiralFlame_cone.dmi', "cone")

	proc/ThrowArt(mob/p, icon/art, size, fwd, life, split)
		if(live_arts)
			for(var/obj/fx_rider/spellart/A in live_arts)
				A.Kill()
		live_arts = list()
		live_arts += new /obj/fx_rider/spellart(null, p, art, size, fwd, life, MOB_LAYER + 0.3, split, 1)
		live_arts += new /obj/fx_rider/spellart(null, p, art, size, fwd, life, MOB_LAYER + 0.3, -split, -1)
	OnRound(mob/p, remaining)
		..()
		if(!cast_open)
			cast_open = 1
			p.ScrubSpellArt()
			live_arts = null
		if(remaining == 1 && p.HotbarKeyStillDown(fire_slot) && p.ManaAmount >= 2)
			finale_armed = 1
			Distance = 4
			DamageMult = initial(DamageMult) * 1.5
			TurfBurn = 8
			FinalStrikeMana = 3
			RecoveryLock = 10
			p.LoseMana(2)
			p.RetargetCastCircles(glob.SPELL_EMIT_FWD, 31, 1, 2, 10)
			KenShockwave(p, Size = 0.6, Time = 5)
		if(finale_armed && remaining == 1)
			ThrowArt(p, art_cone, 160, glob.SPELL_EMIT_FWD + 34, 10, 13)
		else
			ThrowArt(p, art_spiral, 96, glob.SPELL_EMIT_FWD + 11, 7, 6)
	OnRoundsDone(mob/p)
		..()
		cast_open = 0
		live_arts = null
		if(finale_armed)
			finale_armed = 0
			Distance = initial(Distance)
			DamageMult = initial(DamageMult)
			TurfBurn = initial(TurfBurn)
			FinalStrikeMana = initial(FinalStrikeMana)
			RecoveryLock = initial(RecoveryLock)
	verb/Spiral_Flame()
		set name = "Spiral Flame"
		set category = "Skills"
		fire_slot = usr.last_fire_slot
		usr.Activate(src)

obj/Skills/Projectile/Fire/Fireball
	name = "Fireball"
	SpellTier = 1
	SpellShape = "projectile"
	PageKey = "N1"
	MenuIcon = "HellfireNova"
	Desc = "A pitched ball of fire that bursts on contact and burns. Two charges. Against a target that already burns hard it leaves your hand larger, hits half again as hard and splashes fire onto everything beside them."
	IconLock = 'Fireball.dmi'
	Explode = 1
	Distance = 8
	DamageMult = 1.35
	ManaCost = 3
	MaxCharges = 2
	Charges = 2
	ChargeRefresh = 4
	Cooldown = 4
	TurfBurn = 10
	AmpVsPool = "Fire"
	AmpVsPoolMin = 20
	AmpVsPoolMult = 1.5
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		if(m.spell_hit_gate < 20) return
		for(var/mob/o in range(1, m))
			if(o == m || o == caster || o.KO || o.Dead) continue
			if(caster.inParty(o.ckey)) continue
			o.AddBurn(5, caster, 1)
	verb/Fireball()
		set name = "Fireball"
		set category = "Skills"
		IconSize = usr.SpellLit(src) ? 1.3 : 1
		usr.UseProjectile(src)

obj/Skills/Projectile/Fire/Flame_Slice
	name = "Flame Slice"
	SpellTier = 1
	SpellShape = "line"
	PageKey = "22"
	MenuIcon = "FlareWave"
	Desc = "A crescent blade of flame that flies down a line and slices everything on it, biting through armor. If the first enemy it meets is already burning it runs further, and any chill on a struck target is boiled into fire with steam, returning a little mana."
	IconLock = 'Fire Slash.dmi'
	Piercing = 1
	Variation = 0
	Distance = 6
	Speed = 0.3
	DamageMult = 1.1
	EndEffectiveness = 0.8
	TurfBurn = 8
	ExtendTiles = 2
	ConvertFrom = "Slow"
	ConvertTo = "Burn"
	ConvertAmount = 10
	ConvertRefund = 1
	EventRefund = list("convert" = 1)
	EventRefundCap = list("convert" = 3)
	ManaCost = 4
	Cooldown = 6
	verb/Flame_Slice()
		set name = "Flame Slice"
		set category = "Skills"
		usr.UseProjectile(src)

obj/Skills/AutoHit/Fire/Burning_Place
	name = "Burning Place"
	SpellTier = 1
	SpellShape = "aoe"
	PageKey = "21"
	MenuIcon = "SuperExplosiveWave"
	Desc = "Your feet ignite, then a wreath of flame bursts off your body: everything beside you is thrown back and set alight, and water or chill is burned off you and any ally in the ring. Costs nothing when you were just struck in melee or are being held, and it breaks a grab."
	Area = "Circle"
	Distance = 1
	WindUp = 0.3
	DamageMult = 1.2
	Knockback = 2
	TurfBurn = 10
	ManaCost = 4
	Cooldown = 10
	LitCostMult = 0
	PrimedBy = list("SelfHit")
	SelfCleansePools = list("Drenched", "Slow")
	SelfCleanseAllies = 1
	HitSparkIcon = 'Explosion - Fire.dmi'
	verb/Burning_Place()
		set name = "Burning Place"
		set category = "Skills"
		var/broke = 0
		if(usr.grabbed && ismob(usr.grabbed))
			var/mob/G = usr.grabbed
			if(G.Grab == usr)
				G.Grab_Release()
				usr.Knockback(2, G, get_dir(usr, G), 1)
				broke = 1
		usr.Activate(src, ignoreCuck = TRUE, ignoreAttackLock = broke)
		if(broke) usr.Stoke(3)
