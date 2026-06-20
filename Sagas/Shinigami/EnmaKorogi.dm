proc/applyNearSighted(mob/target, mob/caster)
	if(!target || !target.client) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/ns = target.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted)
	if(!ns) return
	ns.source = caster
	if(!target.BuffOn(ns))
		ns.Trigger(target, 1)

// Reduces vision to a 1-tile radius using per-client overlay
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 9999
	BuffName = "Near-Sighted"
	ActiveMessage = "is rendered nearly blind; only what lies within arm's reach is visible!"
	OffMessage = "vision snaps back to full clarity."

	var/tmp/mob/source
	var/list/cover_images = list()
	var/tmp/ns_running = FALSE

	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			..()
			startNearSighted(User)
		else
			stopNearSighted(User)
			Timer = 0
			..()

	proc/startNearSighted(mob/affected)
		if(!affected || !affected.client) return
		ns_running = TRUE
		updateCovers(affected)
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/self = src
		spawn()
			var/last_loc = affected.loc
			while(self.ns_running && affected && affected.client)
				if(affected.loc != last_loc)
					last_loc = affected.loc
					self.updateCovers(affected)
				sleep(1)

	proc/updateCovers(mob/affected)
		if(!affected || !affected.client) return
		// Clear old covers first
		for(var/image/img in cover_images)
			affected.client.images -= img
		cover_images = list()
		var/outer = 15
		for(var/turf/T in range(outer, affected))
			if(get_dist(affected, T) <= 1) continue  // 1-tile radius stays clear
			var/image/img = image('space.dmi', T, "black")
			img.layer = MOB_LAYER + 100
			img.alpha = 255
			affected.client.images += img
			cover_images += img

	proc/stopNearSighted(mob/affected)
		ns_running = FALSE
		if(affected && affected.client)
			for(var/image/img in cover_images)
				affected.client.images -= img
		cover_images = list()

	Del()
		ns_running = FALSE
		..()

/obj/Effects/EnmaKorogiWall
	icon = 'space.dmi'
	icon_state = "black"
	density = 1
	opacity = 1
	layer = MOB_LAYER + 1
	Lifetime = -1

/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi
	name = "Suzumushi Tsuishiki: Enma Kōrōgi"
	Slotless = 1
	IsBankaiForm = 1
	ManaThreshold = 2

	var/tmp/list/domain_walls    = list()
	var/tmp/list/old_turf_icons  = list()
	var/tmp/list/old_density     = list()
	var/tmp/list/ns_targets      = list()
	var/tmp/list/ns_exempt       = list()
	var/tmp/list/old_atom_alpha  = list()  // movable non-mob → original alpha
	var/tmp/domain_active    = FALSE

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Harden"    = 1 + SL,
			"Steady"    = 1 + SL,
			"Flow"      = 3 + SL,
			"FluidForm" = 2.5 + (SL * 0.5),
			"Flicker"   = 3 + SL,
			"Pressure"  = 3 + SL,
			"LikeWater" = 1 + SL
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		EndMult = 1.4 + (0.15 * SL)
		StrMult = 1.4 + (0.15 * SL)
		SpdMult = 1.4 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			activateEnmaKorogi(user)
		else if(wasOn && !src.SlotlessOn)
			deactivateEnmaKorogi(user)

	proc/activateEnmaKorogi(mob/user)
		if(domain_active) return

		for(var/mob/m in world)
			if(m != user && m.Target == user)
				m.Target = null

		var/turf/center = get_turf(user)
		if(!center) return
		var/domain_range = 10
		for(var/turf/T in range(domain_range, center))
			var/dx   = T.x - center.x
			var/dy   = T.y - center.y
			var/dist = sqrt(dx*dx + dy*dy)
			if(dist > domain_range) continue

			old_turf_icons[T] = list("icon" = T.icon, "icon_state" = T.icon_state)
			T.icon       = 'space.dmi'
			T.icon_state = "black"

			// Strip density from the turf itself
			if(T.density)
				old_density[T] = T.density
				T.density = 0

			for(var/atom/movable/A in T)
				if(ismob(A)) continue
				if(A.density)
					old_density[A] = A.density
					A.density = 0
				old_atom_alpha[A] = A.alpha
				A.alpha = 0

			// Outer ring additionally gets a physical wall for movement blocking
			if(dist >= domain_range - 1)
				var/obj/Effects/EnmaKorogiWall/wall = new(T)
				domain_walls += wall

		// Apply NearSighted to all other players currently inside the domain
		for(var/mob/m in range(domain_range, center))
			if(m == user || !m.client) continue
			applyNearSighted(m, user)
			ns_targets += m

		domain_active = TRUE

		var/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi/self = src
		spawn()
			while(self.domain_active && user && user.loc)
				for(var/mob/m in players)
					if(!m.client || m == user) continue
					var/in_range = (get_dist(user, m) <= domain_range)
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/ns = m.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted)
					var/has_ns = (ns && m.BuffOn(ns) && ns.source == user)
					if(in_range && !has_ns && !(m in self.ns_exempt))
						applyNearSighted(m, user)
						if(!(m in self.ns_targets))
							self.ns_targets += m
					else if(!in_range && has_ns)
						ns.Trigger(m)
						self.ns_targets -= m
				sleep(5)

	proc/deactivateEnmaKorogi(mob/user)
		domain_active = FALSE

		for(var/obj/Effects/EnmaKorogiWall/wall in domain_walls)
			if(wall) del(wall)
		domain_walls = list()

		for(var/turf/T as anything in old_turf_icons)
			if(!T) continue
			var/list/saved = old_turf_icons[T]
			if(!islist(saved)) continue
			T.icon       = saved["icon"]
			T.icon_state = saved["icon_state"]
		old_turf_icons = list()

		for(var/atom/A as anything in old_density)
			if(A) A.density = old_density[A]
		old_density = list()

		for(var/atom/movable/A as anything in old_atom_alpha)
			if(A) A.alpha = old_atom_alpha[A]
		old_atom_alpha = list()

		for(var/mob/m in ns_targets)
			if(!m) continue
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted/ns = m.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/NearSighted)
			if(ns && m.BuffOn(ns) && (!user || ns.source == user))
				ns.Trigger(m)
		ns_targets = list()
		ns_exempt  = list()

	Del()
		deactivateEnmaKorogi(null)
		..()

	verb/Bankai()
		set name = "Bankai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Bankai."
				return
			if(usr.InShikai())
				usr << "You must end Shikai before entering Bankai."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Bankai."
				return
			adjust(usr)
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyBankaiIcon(usr)
			if(sf) sf.applyBankaiShihakushoIcon(usr)
			OMsg(usr, "<b>[usr] calls out, \"Bankai... [usr.AsauchiName] [usr.BankaiPrefix]!\"</b>")
		else
			src.Trigger(usr)
