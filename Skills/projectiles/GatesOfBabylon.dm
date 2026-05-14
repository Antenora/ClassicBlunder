// Gates of Babylon Scaling Sig

// Mastery 1 : 8  projectiles
// Mastery 2 : 11 projectiles + 1 legendary guaranteed + 1 sentinel weapon
// Mastery 3 : 14 projectiles + 2 legendaries + 2 sentinels + Rapid Barrage mode
// Mastery 4 : 17 projectiles + Enkidu - Chains of Heaven granted
// Mastery 5 : 20 projectiles + Enuma Elish granted


// Cached weapon pool, built on first use
var/list/gob_weapon_pool = null


// Particle effect for Enuma Elish charge-up
/particles/ea_gathering
	icon      = 'particle.dmi'
	width     = 800
	height    = 800
	count     = 80
	spawning  = 4

	scale     = generator("num", 18.0, 36.0)
	// Spawn scattered below and around the user, wide horizontal spread
	position  = generator("box", list(-200, -120, 0), list(200, 60, 0))
	// pulls them toward the orb (center)
	gravity   = list(0, 2.0)
	// landing right at the orb center, then fade out
	friction  = 0.25
	lifespan  = 30
	fade      = 12
	drift     = generator("box", list(-0.8, -0.3, 0), list(0.8, 0.3, 0))

	color     = "#ff5522"

proc/BuildGoBWeaponPool()
	var/list/pool = list()

	for(var/C in typesof(/obj/Items/Sword))
		var/obj/Items/Sword/S = new C
		// Skip abstract/placeholder types with no icon or name
		if(!S.icon || !S.name)
			del S
			continue
		// No Ea for GoB summon
		if(istype(S, /obj/Items/Sword/Medium/Legendary/Ea))
			del S
			continue
		// Everything else is fair game

		pool += list(list(
			"icon"      = S.icon,
			"element"   = S.Element,
			"legendary" = S.LegendaryItem,
			"name"      = S.name,
			"px"        = S.pixel_x,
			"py"        = S.pixel_y
		))
		del S

	// --- Keychains (standard) ---
	for(var/KC in glob.Keychains)
		var/ico = GetKeychainIcon(KC)
		if(!ico) continue
		pool += list(list(
			"icon"      = ico,
			"element"   = GetKeychainElement(KC),
			"legendary" = FALSE,
			"name"      = KC,
			"px"        = -32,
			"py"        = -32
		))

	// --- Keychains (legendary / final) ---
	for(var/KC in glob.FinalKeychains)
		var/ico = GetKeychainIcon(KC)
		if(!ico) continue
		pool += list(list(
			"icon"      = ico,
			"element"   = GetKeychainElement(KC),
			"legendary" = TRUE,
			"name"      = KC,
			"px"        = -32,
			"py"        = -32
		))

	return pool


proc/SelectGoBWeapons(list/pool, count, mastery)
	var/list/selected = list()
	var/list/pool_copy = pool.Copy()

	for(var/i = 1 to count)
		if(!pool_copy.len) break
		var/idx = rand(1, pool_copy.len)
		var/entry = pool_copy[idx]
		selected += list(entry)
		pool_copy.Remove(entry)

	// Legendary guarantee
	var/needed_leg = 0
	if(mastery >= 2) needed_leg = 1
	if(mastery >= 3) needed_leg = 2

	if(needed_leg > 0)
		var/have_leg = 0
		for(var/e in selected)
			if(e["legendary"]) have_leg++

		if(have_leg < needed_leg)
			// Gather legendaries from full pool not already selected
			var/list/sel_names = list()
			for(var/e in selected) sel_names += e["name"]
			var/list/leg_pool = list()
			for(var/e in pool)
				if(e["legendary"] && !(e["name"] in sel_names))
					leg_pool += list(e)

			// Swap out non-legendary slots
			var/to_swap = min(needed_leg - have_leg, leg_pool.len)
			var/swap_done = 0
			for(var/j = 1 to selected.len)
				if(swap_done >= to_swap) break
				if(!selected[j]["legendary"])
					selected[j] = leg_pool[swap_done + 1]
					swap_done++

	return selected


proc/ApplyGoBElement(obj/Skills/Projectile/_Projectile/proj, element, forced)
	if(!element || element == 0) return
	switch(element)
		if("Fire")
			if(forced) proj.Scorching  = 15
			else       proj.Burning    = 15
		if("Water")
			if(forced) proj.Freezing   = 15
			else       proj.Chilling   = 15
		if("Earth")
			if(forced) proj.Shattering = 15
			else       proj.Crushing   = 15
		if("Wind")
			if(forced) proj.Paralyzing = 15
			else       proj.Shocking   = 15
		if("Poison")
			if(forced) proj.Toxic      = 15
			else       proj.Poisoning  = 15
		if("HellFire")
			proj.Scorching = 15
			proj.Toxic     = 15
		if("Ultima")
			proj.Scorching = 15
			proj.Freezing  = 15
			proj.Shattering = 15
			proj.Paralyzing = 15
			proj.Toxic     = 15
		if("Truth")
			if(prob(50))
				proj.Scorching  = 15
				proj.Toxic      = 15
			else
				proj.Freezing   = 15
				proj.Shattering = 15
				proj.Paralyzing = 15
		// Dark, Light, Void, Love, Death stuff later


//Actual skill
obj/Skills/Projectile/Gates_of_Babylon
	SignatureTechnique = 3
	name = "Gates of Babylon"
	Cooldown = 90
	CooldownStatic = 1

	Speed       = 0.5
	Distance    = 25
	DamageMult  = 2
	AccMult     = 1.5
	Homing      = 3
	HyperHoming = 1
	Instinct    = 1
	Striking    = 1

	ZoneAttack  = 1
	ZoneAttackX = 7
	ZoneAttackY = 7
	FireFromSelf  = 1
	FireFromEnemy = 0
	Hover   = 42   // (~4 seconds)
	Variation = 0

	ActiveMessage = "opens the Gates of Babylon, drawing forth weapons from the treasury of creation!"

	var/granted_enkidu      = FALSE
	var/granted_enuma_elish = FALSE

	proc/ProjCount()
		return 5 + (Mastery * 3)   // M1=8  M2=11  M3=14  M4=17  M5=20

	proc/CheckMasteryGrants(mob/p)
		if(Mastery >= 4 && !granted_enkidu)
			if(!locate(/obj/Skills/Projectile/Enkidu_Chains, p))
				p.AddSkill(new/obj/Skills/Projectile/Enkidu_Chains)
				p << "<font color='gold'><b>The Chains of Heaven, Enkidu, manifest within your treasury!</b></font>"
			granted_enkidu = TRUE

		if(Mastery >= 5 && !granted_enuma_elish)
			if(!locate(/obj/Skills/AutoHit/Enuma_Elish, p))
				p.AddSkill(new/obj/Skills/AutoHit/Enuma_Elish)
			if(!locate(/obj/Skills/Summon_Ea, p))
				p.AddSkill(new/obj/Skills/Summon_Ea)
			p << "<font color='gold'><b>The Sword of Rupturing Heaven, Ea, rests within your treasury — and with it, the power to shatter heaven itself.</b></font>"
			granted_enuma_elish = TRUE

	proc/FireGoBSalvo(mob/shooter, barrage_mode = FALSE)
		if(src.Using) return
		if(!shooter.Target || shooter.Target == shooter)
			shooter << "You need a target to use Gates of Babylon."
			return

		if(!gob_weapon_pool)
			gob_weapon_pool = BuildGoBWeaponPool()
		if(!gob_weapon_pool.len)
			shooter << "No weapons could be found in the treasury."
			return

		CheckMasteryGrants(shooter)

		var/count   = ProjCount()
		var/mastery = Mastery
		var/list/weapons = SelectGoBWeapons(gob_weapon_pool, count, mastery)
		var/forced  = (mastery >= 3)
		var/hover_t = barrage_mode ? 0 : Hover

		src.Cooldown(1, null, shooter)

		OMsg(shooter, "<b><font color='gold'>[shooter] [ActiveMessage]</font></b>")

		var/list/spawned_projs = list()

		for(var/entry in weapons)
			var/turf/spawn_t = locate(
				shooter.x + rand(-ZoneAttackX, ZoneAttackX),
				shooter.y + rand(-ZoneAttackY, ZoneAttackY),
				shooter.z
			)
			if(!istype(spawn_t, /turf)) spawn_t = shooter.loc

			var/old_lx = LockX
			var/old_ly = LockY
			var/px = entry["px"]
			var/py = entry["py"]
			LockX = px ? px : 0
			LockY = py ? py : 0

			var/old_hover = Hover
			if(barrage_mode) Hover = 0

			var/list/before = shooter.active_projectiles.Copy()
			shooter.Blast(src, spawn_t, 0, entry["icon"])

			LockX = old_lx
			LockY = old_ly
			if(barrage_mode) Hover = old_hover

			var/obj/Skills/Projectile/_Projectile/proj = null
			for(var/p in shooter.active_projectiles)
				if(!(p in before))
					proj = p
					break

			if(proj)
				if(!barrage_mode)
					proj.alpha = 0
					animate(proj, alpha = 128, time = max(1, hover_t - 6))
					proj.filters += filter(type="wave", x=2, y=2, size=1.5)
				else
					proj.filters += filter(type="wave", x=1, y=1, size=1.0)
					var/obj/Skills/Projectile/_Projectile/bf = proj
					spawn(8) if(bf) bf.filters = list()

				// Elemental debuff
				ApplyGoBElement(proj, entry["element"], forced)

				// Damage multiplier
				var/dmg = 1 + (mastery * 0.1)
				if(entry["legendary"]) dmg *= 1.5
				if(barrage_mode)       dmg *= 0.7   // barrage trades damage for speed
				proj.DamageMult *= dmg

				spawned_projs += proj

			if(barrage_mode)
				sleep(3)

		if(!barrage_mode)
			spawn(hover_t)
				for(var/obj/Skills/Projectile/_Projectile/p in spawned_projs)
					if(p && p.loc)
						p.filters = list()       // clear the hover ripple on launch
						animate(p, alpha = 255, time = 5)

			var/sentinel_count = 0
			if(mastery >= 2) sentinel_count = 1
			if(mastery >= 3) sentinel_count = 2
			if(sentinel_count > 0)
				spawn(hover_t + 8)
					SpawnGoBSentinels(shooter, sentinel_count, weapons, mastery)

	proc/SpawnGoBSentinels(mob/shooter, count, list/weapons, mastery)
		if(!shooter || !shooter.loc) return
		var/list/used_names = list()
		for(var/i = 1 to count)
			if(!shooter || !shooter.loc) return
			// Pick a weapon not already used as a sentinel this cast
			var/list/candidates = list()
			for(var/e in weapons)
				if(!(e["name"] in used_names))
					candidates += list(e)
			if(!candidates.len) break
			var/entry = candidates[rand(1, candidates.len)]
			used_names += entry["name"]

			var/obj/GoB_Sentinel/s = new(shooter.loc)
			s.icon      = entry["icon"]
			s.pixel_x   = entry["px"] ? entry["px"] : 0
			s.pixel_y   = entry["py"] ? entry["py"] : 0
			s.Owner     = shooter
			s.WeaponElement  = entry["element"]
			s.IsLegendary    = entry["legendary"]
			s.SentinelMastery = mastery
			s.OrbitOffset = (i - 1) * (360 / count)
			spawn()
				s.BeginOrbit()

	verb/Gates_of_Babylon()
		set category = "Skills"
		FireGoBSalvo(usr, FALSE)

	verb/Gates_of_Babylon_Barrage()
		set category = "Skills"
		if(Mastery < 3)
			usr << "<font color='red'>You haven't mastered the Gates of Babylon enough for Rapid Barrage.</font>"
			return
		FireGoBSalvo(usr, TRUE)


//  Sentinel Weapon Object
obj/GoB_Sentinel
	name      = "Treasury Weapon"
	icon      = 'SwordBlast2.dmi'
	density   = 0
	layer     = 4.5
	alpha     = 200
	Savable   = 0
	Buildable = 0
	mouse_opacity = 0
	animate_movement = 0

	Owner         = null
	var/WeaponElement     = null
	var/IsLegendary       = FALSE
	var/SentinelMastery   = 1
	var/OrbitOffset       = 0
	var/OrbitDuration     = 70

	proc/BeginOrbit()
		if(!Owner || !Owner.loc) { del src; return }

		var/R              = 22
		var/orbit_speed    = 15
		var/rotation_speed = 45
		var/step_delay     = 2

		var/orbit_angle    = OrbitOffset
		var/rotation_angle = 0
		var/list/orbit_images = list()
		var/elapsed = 0

		while(Owner && Owner.loc && elapsed < OrbitDuration)

			for(var/image/im in orbit_images)
				Owner.overlays -= im
			orbit_images = list()


			orbit_angle    = (orbit_angle    + orbit_speed)    % 360
			rotation_angle = (rotation_angle + rotation_speed) % 360


			var/px = round(cos(orbit_angle) * R)
			var/py = round(sin(orbit_angle) * R)
			var/image/im = image(icon = src.icon, pixel_x = px, pixel_y = py, layer = FLOAT_LAYER)
			im.transform = matrix().Turn(rotation_angle)
			Owner.overlays += im
			orbit_images   += im

			// Damage all enemies within 1 tile per tick
			for(var/mob/m in range(1, Owner))
				if(!istype(m, /mob/Player)) continue
				if(m == Owner) continue
				if(Owner.party && (m in Owner.party.members)) continue
				var/powerDif = Owner.getPower(m)
				var/statPower = Owner.getStatDmg2()
				var/endFactor = m.getEndStat(1)
				var/dmg = (clamp(powerDif,0.1,100000)**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.AUTOHIT_EFFECTIVNESS) ** -(endFactor**glob.DMG_END_EXPONENT / statPower**glob.DMG_STR_EXPONENT)
				dmg *= 0.5
				dmg *= Owner.GetDamageMod()
				if(IsLegendary) dmg *= 1.5
				dmg *= 1 + (SentinelMastery * 0.05)
				m.LoseHealth(dmg, Owner)
				if(WeaponElement)
					ElementalCheck(Owner, m, 0, bonusElements = list(WeaponElement))

			sleep(step_delay)
			elapsed += step_delay

		for(var/image/im in orbit_images)
			if(Owner) Owner.overlays -= im
		if(src) del src


obj/Skills/Projectile/Enkidu_Chains
	SignatureTechnique = 3
	name = "Enkidu - Chains of Heaven"
	Cooldown = 120
	CooldownStatic = 1

	Speed      = 0.4
	Distance   = 20
	DamageMult = 10
	AccMult    = 1.3
	Homing     = 3
	HyperHoming = 1
	Instinct   = 2
	Striking   = 1
	Snaring    = 8

	ActiveMessage = "hurls the Chains of Heaven, Enkidu, to bind their target!"

	adjust(mob/p)
		var/obj/Skills/Projectile/Gates_of_Babylon/gob = locate(/obj/Skills/Projectile/Gates_of_Babylon, p)
		if(gob)
			Snaring    = 6 + (gob.Mastery * 2)
			DamageMult = 10 + (gob.Mastery * 1)

	verb/Enkidu_Chains()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)


proc/ApplyEnumaElishDomainLock(mob/m, duration_ticks)
	if(!m) return
	var/obj/Skills/Buffs/SlotlessBuffs/Domain_Lock/DL = locate() in m
	if(!DL)
		DL = new
		m.AddSkill(DL)
	if(DL.SlotlessOn)
		m.RemoveSlotlessBuff(DL)
	DL.TimerLimit = duration_ticks
	m.AddSlotlessBuff(DL)

proc/PurgeEnumaElishSharedZones(mob/u, mob/v)
	if(!u || !v) return
	if(u.in_tmp_map && v.in_tmp_map && u.in_tmp_map == v.in_tmp_map)
		for(var/mob/Players/p in players)
			if(p.usingUBW && p.in_tmp_map == u.in_tmp_map)
				OMsg(u, "<b><font color='gold'>[u]'s Enuma Elish ruptures the bounded field — the Reality Marble collapses!</font></b>")
				p.stopUnlimitedBladeWorks()
				return
	var/turf/tu = u.loc
	var/turf/tv = v.loc
	if(istype(tu, /turf) && istype(tv, /turf) && tu.domain_expansion_owner && tu.domain_expansion_owner == tv.domain_expansion_owner)
		var/mob/DO = tu.domain_expansion_owner
		if(DO && DO.domainExpansionActive)
			var/list/escapees = list()
			if(DO.domainExpansionFloors)
				for(var/turf/TF in DO.domainExpansionFloors)
					if(!istype(TF, /turf)) continue
					for(var/mob/M in TF)
						escapees |= M
			if(istype(tu, /turf))
				for(var/mob/M in escapees)
					if(!M || !M.loc) continue
					var/iter
					for(iter = 1, iter <= 12, iter++)
						var/ox = tu.x + rand(-12, 12)
						var/oy = tu.y + rand(-12, 12)
						var/turf/out = locate(ox, oy, tu.z)
						if(out && !out.density)
							M.loc = out
							break
			OMsg(u, "<b><font color='gold'>[u]'s Enuma Elish shatters the Domain!</font></b>")
			DO.stopDomainExapansion()
			var/obj/Skills/Buffs/SlotlessBuffs/Domain_Expansion/dex = locate() in DO
			if(dex && dex.SlotlessOn)
				dex.Trigger(DO, Override=1)
			return
	for(var/mob/Players/p in players)
		if(!p.SlotlessBuffs || !p.SlotlessBuffs.len) continue
		for(var/k in p.SlotlessBuffs)
			var/obj/Skills/Buffs/bp = p.SlotlessBuffs[k]
			if(!bp || !bp.SlotlessOn) continue
			if(!bp.WarpZone || !bp.Duel) continue
			if(!bp.WarpTarget) continue
			if((p == u && bp.WarpTarget == v) || (p == v && bp.WarpTarget == u))
				OMsg(u, "<b><font color='gold'>[u]'s Enuma Elish smashes the barrier!</font></b>")
				bp.Trigger(p, Override=1)
				return


obj/Skills/AutoHit/Enuma_Elish
	SignatureTechnique = 3
	name = "Enuma Elish"
	Cooldown = 300
	CooldownStatic = 1
	Area = "Around Target"
	Distance = 35
	DistanceAround = 3
	DamageMult = 50
	StrOffense = 1
	ForOffense = 1
	EndDefense = 1
	CanBeBlocked = 0
	CanBeDodged = 0
	Scorching = 50
	Freezing = 50
	Shattering = 50
	Paralyzing = 50
	Toxic = 1
	Icon = 'Hellnova.dmi'
	Size = 1.2
	IconX = -158
	IconY = -169
	NeedsSword = 1
	ActiveMessage = "channels the Sword of Rupturing Heaven — Enuma Elish!"
	var/tmp/enuma_shatter_fired = 0
	var/tmp/charging_enuma = 0

	proc/EnumaElishOnHit(mob/owner, mob/m, damageDealt)
		if(!owner || !m || !damageDealt) return
		if(!enuma_shatter_fired)
			enuma_shatter_fired = 1
			for(var/mob/Players/P in view(12, m))
				spawn() ScreenShatter(P)
		if(m == owner.Target)
			var/ticks = round(Cooldown * 10)
			if(cooldown_remaining > 0)
				ticks = max(ticks, round(cooldown_remaining))
			ApplyEnumaElishDomainLock(m, ticks)

	proc/ChargeEnumaElish(mob/shooter, obj/Skills/AutoHit/Enuma_Elish/skill, mob/target)
		var/charge_start = world.time
		skill.enuma_shatter_fired = 0

		spawn()
			while(shooter && shooter.loc && (world.time - charge_start) < 150)
				LightningStrikeRed(shooter, Offset = 2)
				sleep(rand(12, 20))

		sleep(50)

		if(!shooter || !shooter.loc)
			skill.charging_enuma = 0
			return
		if(shooter.Target && shooter.Target != shooter) target = shooter.Target
		if(!target || !target.loc || target == shooter)
			skill.charging_enuma = 0
			return
		// EaVisual spawns at the shooter's tile and is shifted 2 tiles up
		var/obj/EaVisual/ev = new(shooter.loc)
		if(!ev)
			skill.charging_enuma = 0
			return

		ev.pixel_x = -158
		ev.pixel_y = 32
		ev.transform = matrix().Scale(0.2)

		var/obj/EaParticleEmitter/pe = new(shooter.loc)

		spawn()
			while(ev && ev.loc && shooter && shooter.loc)
				ev.loc = shooter.loc
				if(pe && pe.loc) pe.loc = shooter.loc
				sleep(1)

		for(var/step = 1 to 5)
			sleep(20)
			if(!ev || !ev.loc || !shooter || !shooter.loc) break
			animate(ev, transform = matrix().Scale(0.2 + (step * 0.2)), time = 18)

		if(pe) del pe
		if(ev)
			animate(ev, alpha = 0, time = 5)
			sleep(5)
			if(ev) del ev

		if(!shooter || !shooter.loc)
			skill.charging_enuma = 0
			return
		if(shooter.Target && shooter.Target != shooter) target = shooter.Target
		if(!target || !target.loc || target == shooter)
			skill.charging_enuma = 0
			return
		if(!skill.enuma_shatter_fired)
			skill.enuma_shatter_fired = 1
			for(var/mob/Players/P in view(12, target))
				spawn() ScreenShatter(P)
		skill.charging_enuma = 0
		PurgeEnumaElishSharedZones(shooter, target)
		OMsg(shooter, "<b><font color='gold'>[shooter] [skill.ActiveMessage]</font></b>")
		shooter.Activate(skill)

	verb/Enuma_Elish()
		set category = "Skills"
		if(charging_enuma) return
		if(cooldown_remaining) return
		if(usr.AutoHitting) return
		var/obj/Items/Sword/Medium/Legendary/Ea/ea = locate(/obj/Items/Sword/Medium/Legendary/Ea, usr)
		if(!ea || !ea.suffix)
			usr << "<font color='red'>Ea must be equipped to use Enuma Elish.</font>"
			return
		if(!usr.Target || usr.Target == usr)
			usr << "You need a target to use Enuma Elish."
			return
		charging_enuma = 1
		usr << "<font color='gold'><b>The air tears apart as Ea begins to rotate...</b></font>"
		var/mob/mtarget = usr.Target
		spawn() ChargeEnumaElish(usr, src, mtarget)


obj/Skills/Summon_Ea
	name = "Summon Ea"
	SignatureTechnique = 3

	verb/Summon_Ea()
		set category = "Skills"
		var/obj/Items/Sword/Medium/Legendary/Ea/ea = locate(/obj/Items/Sword/Medium/Legendary/Ea, usr)
		if(ea)

			if(ea.suffix) ea.UnEquip(usr)
			del ea
			usr << "<font color='#aaaaff'>You return Ea to the Gates of Babylon.</font>"
		else

			var/obj/Items/Sword/S = usr.EquippedSword()
			if(S)
				usr << "<font color='red'>You must unequip your weapon before summoning Ea.</font>"
				return

			ea = new/obj/Items/Sword/Medium/Legendary/Ea(usr)
			ea.Equip(usr)
			usr << "<font color='gold'><b>Ea, the Sword of Rupturing Heaven, descends from the treasury!</b></font>"


// Particle emitter for the Enuma Elish charge-up sequence
obj/EaParticleEmitter
	density       = 0
	layer         = 20
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	Savable       = 0
	Buildable     = 0
	particles     = new/particles/ea_gathering

	New()
		. = ..()
		// Black glow outline around each particle
		filters = list(filter(type="outline", size=6, color=rgb(0, 0, 0)))


obj/EaVisual
	name          = "Enuma Elish"
	icon          = 'Hellnova.dmi'
	density       = 0
	layer         = 20
	mouse_opacity = 0
	alpha         = 255
	Savable       = 0
	Buildable     = 0
