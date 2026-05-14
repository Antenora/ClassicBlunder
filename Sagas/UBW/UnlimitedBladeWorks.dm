mob/var/usingUBW = FALSE

mob/var/tmp/domainExpansionActive = 0
mob/var/tmp/list/domainExpansionFloors = null
mob/var/tmp/list/domainExpansionBarriers = null
mob/var/tmp/domainBeingBreached = FALSE
turf/var/tmp/mob/domain_expansion_owner = null

obj/DomainExpansionBarrier
	name = "Domain Boundary"
	icon = 'Roofs.dmi'
	icon_state = "Roof1"
	color = "#000000"
	density = 1
	opacity = 1
	mouse_opacity = 0
	Savable = 0
	Attackable = 1
	Destructable = 0
	var/domain_hp = 3000
	Enter(atom/A)
		return 0
	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/proj = Obstacle
			var/mob/shooter = proj.Owner
			if(shooter)
				var/turf/bTurf = isturf(src.loc) ? src.loc : null
				var/mob/domainOwner = bTurf ? bTurf.domain_expansion_owner : null
				if(domainOwner && domainOwner.domainExpansionActive)
					var/turf/aTurf = isturf(shooter.loc) ? shooter.loc : null
					if(!aTurf || aTurf.domain_expansion_owner != domainOwner)
						var/projDamage = shooter.potential_power_mult * shooter.PowerBoost * shooter.Power_Multiplier * shooter.AngerMax * (shooter.GetStr() + shooter.GetFor())
						domain_hp -= projDamage
						if(domain_hp <= 0)
							domainOwner.domainExpansionBarriers -= src
							var/mob/capOwner = domainOwner
							spawn()
								del(src)
								capOwner.BreachDomain()
							return
		..()


obj/DomainExpansionRoof
	name = "Domain Shroud"
	icon = 'Roofs.dmi'
	icon_state = "Roof1"
	color = "#000000"
	alpha = 170
	density = 0
	opacity = 0
	mouse_opacity = 0
	Savable = 0
	// Visual overlay only. The default obj Attackable=1 was leaving the shroud
	// hittable by punches / AOE, which both broke immersion and let players
	// destructively interact with what is supposed to be a passive backdrop.
	Attackable = 0

/mob/Admin3/verb/GiveDomainExpansion()
	set category = "Admin"
	set name = "Give Domain Expansion"
	var/demonName = input(src, "What is the name of the Demon? (e.g. 'Malovent Imperium' -> activation says 'X says: Domain Expansion.. Malovent Imperium')", "Domain Expansion - Name") as text|null
	if(!demonName || !length(demonName))
		src << "Cancelled. No demon name provided."
		return
	var/icon/customTurfIcon = input(src, "Upload the custom floor icon for the Domain (32x32 .dmi, single state).", "Domain Expansion - Turf Icon") as icon|null
	if(!customTurfIcon)
		src << "Cancelled. No custom turf icon provided."
		return
	var/rawRange = input(src, "Range of the Domain Expansion (1 to 50).", "Domain Expansion - Range", 10) as num|null
	if(isnull(rawRange))
		src << "Cancelled. No range provided."
		return
	var/finalRange = round(rawRange)
	if(finalRange < 1) finalRange = 1
	if(finalRange > 50) finalRange = 50
	var/shroudChoice = input(src, "Should the Domain use a shroud overlay on top of the floor? (Selecting No leaves only the custom floor.)", "Domain Expansion - Shroud") in list("Yes","No")
	var/useShroud = (shroudChoice == "Yes")
	var/icon/customRoofIcon = null
	if(useShroud)
		customRoofIcon = input(src, "Upload the custom shroud icon for the Domain (32x32 .dmi, single state). Cancel to fall back to the default Roofs.dmi shroud.", "Domain Expansion - Shroud Icon") as icon|null
	var/mob/p = input(src, "Who to give this Domain Expansion to?", "Domain Expansion - Recipient") in players
	if(!p)
		src << "Cancelled. No recipient."
		return
	var/obj/Skills/Buffs/SlotlessBuffs/Domain_Expansion/d = new()
	d.demonName = demonName
	d.customTurfIcon = customTurfIcon
	d.customRoofIcon = customRoofIcon
	d.useShroud = useShroud
	d.range = finalRange
	d.ActiveMessage = "says: Domain Expansion.. [demonName]!"
	d.OffMessage = "conceals the domain of [demonName]..."
	p.AddSkill(d)
	src << "Gave [p] a Domain Expansion ([demonName], range [finalRange], shroud [useShroud ? "on" : "off"])."


mob
	proc
		DomainExpansion(obj/Skills/Buffs/SlotlessBuffs/Domain_Expansion/buff)
			if(!buff)
				return
			if(HasDomainLock())
				src << "You cannot release a Domain while <b>Domain Lock</b> is active."
				return
			if(!buff.customTurfIcon)
				AdminMessage("[src] tried to use Domain Expansion but the buff has no custom turf icon set. Recreate the skill via Give Domain Expansion.")
				src << "Your Domain Expansion is not set up. Admins alerted."
				return
			if(src.domainExpansionActive)
				return
			var/useRange = buff.range
			if(useRange < 1) useRange = 1
			if(useRange > 50) useRange = 50
			var/centerX = src.x
			var/centerY = src.y
			var/centerZ = src.z
			var/list/floors = list()
			var/list/barriers = list()
			var/icon/floorIcon = buff.customTurfIcon
			var/icon/roofIcon = buff.customRoofIcon
			var/useShroud = buff.useShroud
			// Iterate the bounding square but gate on Euclidean distance so the
			// boundary forms a circle (canon Domain Expansion shape) rather than
			// the previous square.
			var/rangeSq = useRange * useRange
			var/innerSq = (useRange - 1) * (useRange - 1)
			for(var/turf/t in range(useRange, src))
				if(t.z != centerZ)
					continue
				if(t.domain_expansion_owner && t.domain_expansion_owner != src)
					continue
				var/dx = t.x - centerX
				var/dy = t.y - centerY
				var/distSq = dx*dx + dy*dy
				if(distSq > rangeSq)
					continue
				if(distSq > innerSq)
					var/obj/DomainExpansionBarrier/b = new(t)
					barriers += b
					t.domain_expansion_owner = src
					floors[t] = list(null, null)
				else
					var/list/backup = list(t.icon, t.icon_state)
					t.icon = floorIcon
					t.icon_state = ""
					if(useShroud)
						var/obj/DomainExpansionRoof/r = new(t)
						if(roofIcon)
							r.icon = roofIcon
							r.icon_state = ""
							r.color = null
						barriers += r
					t.domain_expansion_owner = src
					floors[t] = backup
			src.domainExpansionFloors = floors
			src.domainExpansionBarriers = barriers
			src.domainExpansionActive = 1


		stopDomainExapansion()
			if(!src.domainExpansionActive)
				return
			// Snapshot the lists, clear the flag synchronously, then chunk the
			// heavy teardown into spawn() so the verb returns immediately.
			// Range-50 domains hold ~7800 turfs/objs after the circle change;
			// del()-ing them and restoring icons in a single tick was locking
			// the world for several seconds and could run past world.tick_lag,
			// which is what users were calling a "freeze". 200 ops per yield
			// keeps each slice under a tick on typical hardware.
			var/list/oldBarriers = src.domainExpansionBarriers
			var/list/oldFloors = src.domainExpansionFloors
			src.domainExpansionFloors = null
			src.domainExpansionBarriers = null
			src.domainExpansionActive = 0
			src.domainBeingBreached = FALSE
			spawn()
				var/processed = 0
				if(oldBarriers)
					for(var/obj/b in oldBarriers)
						if(b)
							del(b)
						processed++
						if(processed >= 200)
							processed = 0
							sleep(1)
				if(oldFloors)
					for(var/turf/t in oldFloors)
						if(!t)
							continue
						if(t.domain_expansion_owner == src || t.domain_expansion_owner == null)
							var/list/backup = oldFloors[t]
							if(backup && backup.len >= 2 && backup[1] != null)
								t.icon = backup[1]
								t.icon_state = backup[2]
							t.domain_expansion_owner = null
						processed++
						if(processed >= 200)
							processed = 0
							sleep(1)


		BreachDomain()
			if(!src.domainExpansionActive || src.domainBeingBreached)
				return
			src.domainBeingBreached = TRUE
			for(var/turf/t in src.domainExpansionFloors)
				for(var/mob/m in t)
					m << "<b><font color='red'>The Domain boundary has been breached! The Domain will collapse in 60 seconds!</font></b>"
			src << "<b><font color='red'>Your Domain's boundary has been broken through! It will collapse in 60 seconds.</font></b>"
			spawn()
				var/steps = 12
				for(var/i = 1 to steps)
					sleep(50)
					if(!src.domainExpansionActive)
						return
					var/newAlpha = round(255 * (1 - (i / steps)))
					if(src.domainExpansionBarriers)
						for(var/obj/b in src.domainExpansionBarriers)
							if(b) b.alpha = newAlpha
				if(src.domainExpansionActive)
					stopDomainExapansion()
					var/obj/Skills/Buffs/SlotlessBuffs/Domain_Expansion/dex = locate() in src
					if(dex && dex.SlotlessOn)
						dex.Trigger(src, Override=1)


		UnlimitedBladeWorks()
			if(usingUBW) return
			if(HasDomainLock())
				src << "You cannot unfold Unlimited Blade Works while <b>Domain Lock</b> is active."
				return
			if(absorbedBy)
				src << "You cannot unfold Unlimited Blade Works while absorbed."
				return
			var/list/targets = list()
			for(var/mob/m in range(15))
				targets |= m
			if(!fexists("Maps/map_[src.UniqueID]_UBW.sav"))
				SwapMaps_SaveChunk("[src.UniqueID]_UBW", locate(1,71,1), locate(61, 121,1))
				SwapMaps_Save("[src.UniqueID]_UBW")

			var/swapmap/newMap = SwapMaps_CreateFromTemplate("[src.UniqueID]_UBW")
			var/turf/center = newMap.CenterTile()
			usingUBW = TRUE
			for(var/mob/teleportThese in targets)
				teleportThese.PrevX=teleportThese.x
				teleportThese.PrevY=teleportThese.y
				teleportThese.PrevZ=teleportThese.z
				teleportThese.in_tmp_map = newMap.id
				teleportThese.loc = locate(center.x+rand(-10,10), center.y+rand(-10,10), center.z)

		stopUnlimitedBladeWorks()
			if(!usingUBW) return
			var/swapmap/map = swapmaps_byname[in_tmp_map]
			usingUBW = FALSE
			if(!map)
				return
			for(var/turf/t in block(locate(map.x1, map.y1, map.z1), locate(map.x2, map.y2, map.z2)))
				for(var/mob/m in t)
					if(isnull(m.PrevX) || isnull(m.PrevY) || isnull(m.PrevZ))
						continue
					m.loc = locate(m.PrevX, m.PrevY, m.PrevZ)
					m.PrevX = null
					m.PrevY = null
					m.PrevZ = null
					m.in_tmp_map = null
			map.Del()
