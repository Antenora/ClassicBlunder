// Visual-only SlotlessBuff used to show a suspension overlay icon.
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SuspendedOverlay
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 9999
	passives = list()

// Applies the Suspended state to a mob for [duration] ticks, then clears it.
proc/applySuspend(mob/target, duration, overlay_icon = null)
	if(!target || !target.loc) return
	var/datum/token = new /datum
	target.Suspended = token
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SuspendedOverlay/ov = null
	if(overlay_icon)
		ov = target.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SuspendedOverlay)
		if(!target.BuffOn(ov))
			ov.IconLock = overlay_icon
			ov.TimerLimit = duration
			ov.Trigger(target, 1)
	spawn(duration * 10)
		if(target && target.Suspended == token)
			target.Suspended = null
		if(ov && target && target.BuffOn(ov))
			ov.Trigger(target, 1)
		del token

proc/applyBakudoSnare(mob/target, limit)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/BakudoSnare/s = target.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/BakudoSnare)
	if(!target.BuffOn(s))
		s.TimerLimit = limit
		s.Trigger(target, TRUE)

proc/hitApplyBakudoSnare(mob/target, obj/Skills/Projectile/_Projectile/proj)
	if(!target || !target.loc) return
	applyBakudoSnare(target, proj.Snaring || 3)

proc/hitApplyShitotsuSansen(mob/target, obj/Skills/Projectile/_Projectile/proj)
	if(!target || !target.loc) return
	applyBakudoSnare(target, 6)
	target.applySnare(6, 'ShitotsuSansen.dmi')

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/BakudoSnare
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 3
	passives = list()

// TIER 1

/obj/Skills/AutoHit/Bakudo/Sai
	name = "Sai"
	Area = "Target"
	Distance = 3
	DamageMult = 1
	ForOffense = 0.01
	Disarm = 1
	ManaCost = 5
	Cooldown = 30
	ActiveMessage = "binds their opponent's arms with Bakudō #1: Sai!"

	verb/Sai()
		set name = "Sai"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.Activate(src)

/obj/Skills/Bakudo/Hainawa
	name = "Hainawa"
	ManaCost = 5
	Cooldown = 30
	Distance = 5

	verb/Hainawa()
		set name = "Hainawa"
		set category = "Skills"
		var/mob/User = usr
		if(cooldown_remaining) return
		if(!User.Target || User.Target == User)
			User << "You need a target for Hainawa."
			return
		var/mob/T = User.Target
		if(get_dist(User, T) > Distance)
			User << "[T] is too far away."
			return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, User)
		if(src.ManaCost) User.LoseMana(src.ManaCost)
		OMsg(User, "<b>[User] ensnares [T] with a rope of energy with Bakudō #4: Hainawa!</b>")
		T.applySnare(3, 'Hainawa.dmi')
		applyBakudoSnare(T, 3)

/obj/Skills/Buffs/ActiveBuffs/Bakudo/Seki
	name = "Seki"
	ActiveSlot = 0
	Slotless = 1
	TimerLimit = 15
	Cooldown = 30
	ManaCost = 5
	passives = list("Blubber" = 4, "KBRes" = 2)
	ActiveMessage = "cloaks themselves in a repelling field with Bakudō #8: Seki!"
	OffMessage = "releases Seki."

	verb/Seki()
		set name = "Seki"
		set category = "Skills"
		src.Trigger(usr)

// TIER 2

/obj/Skills/Projectile/Bakudo/Shitotsu_Sansen
	name = "Shitotsu Sansen"
	DamageMult = 1
	Distance = 10
	Homing = 0
	IconLock = 'ShitotsuSansen.dmi'
	ManaCost = 10
	Cooldown = 45
	ActiveMessage = "fires the binding pins of Bakudō #30: Shitotsu Sansen!"
	OnMobHit = "/proc/hitApplyShitotsuSansen"

	verb/Shitotsu_Sansen()
		set name = "Shitotsu Sansen"
		set category = "Skills"
		var/mob/User = usr
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		usr.UseProjectile(src)

/obj/Skills/Buffs/ActiveBuffs/Bakudo/Enkousen
	name = "Enkousen"
	ActiveSlot = 0
	Slotless = 1
	TimerLimit = 15
	Cooldown = 45
	ManaCost = 10
	passives = list("Deflection" = 3)
	ActiveMessage = "raises a spinning shield of reiatsu — Bakudō #39: Enkousen!"
	OffMessage = "releases Enkousen."

	verb/Enkousen()
		set name = "Enkousen"
		set category = "Skills"
		src.Trigger(usr)

// TIER 3

/obj/Skills/AutoHit/Bakudo/Rikujoukourou
	name = "Rikujoukourou"
	Area = "Target"
	Distance = 5
	DamageMult = 1
	ForOffense = 0.01
	Snaring = 5
	SnaringOverlay = 'rikujoukourou.dmi'
	ManaCost = 20
	Cooldown = 60
	ActiveMessage = "traps their opponent in pillars of light with Bakudō #61: Rikujōkōrō!"

	verb/Rikujoukourou()
		set name = "Rikujoukourou"
		set category = "Skills"
		var/mob/User = usr
		if(cooldown_remaining) return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		var/mob/T = User.Target
		if(T)
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/BakudoSnare/bs = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/BakudoSnare, T)
			if(bs && bs.SlotlessOn)
				// Upgrade if target was bound by Hainawa or Shitotsu Sansen
				src.Cooldown(1, null, User)
				if(src.ManaCost) User.LoseMana(src.ManaCost)
				OMsg(User, "<b>[User] completes the binding, [T] is suspended by Bakudō #61: Rikujōkōrō!</b>")
				applySuspend(T, 5, 'rikujoukourou.dmi')
				return
		src.Snaring = 5
		User.Activate(src)

/obj/Skills/Projectile/Bakudo/Hyapporankan
	name = "Hyapporankan"
	DamageMult = 0.5
	Knockback = 3
	Explode = 0
	Distance = 20
	Divide = 1
	Homing = 1
	ZoneAttack = 1
	ZoneAttackX=5
	ZoneAttackY=5
	Speed = 0.25
	Hover = 7
	Blasts = 15
	IconLock = 'Hyapporankan.dmi'
	ManaCost = 20
	Cooldown = 60
	ActiveMessage = "launches a wave of javelins with Bakudō #62: Hyapporankan!"

	verb/Hyapporankan()
		set name = "Hyapporankan"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Bakudo/Sajou_Sabaku
	name = "Sajou Sabaku"
	Area = "Target"
	Distance = 5
	DamageMult = 1
	ForOffense = 0.01
	Stunner = 5
	ManaCost = 20
	Cooldown = 60
	ActiveMessage = "crushes their opponent in binding ropes with Bakudō #63: Sajō Sabaku!"

	verb/Sajou_Sabaku()
		set name = "Sajou Sabaku"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.Activate(src)

// TIER 4

/obj/Skills/AutoHit/Bakudo/Touzanshou
	name = "Touzanshou"
	Area = "Target"
	Distance = 5
	DamageMult = 1
	ForOffense = 0.01
	Stasis = 100
	ManaCost = 30
	Cooldown = 90
	ActiveMessage = "seals their opponent inside an inverted mountain — Bakudō #73: Tōzanshō!"

	verb/Touzanshou()
		set name = "Touzanshou"
		set category = "Skills"
		var/mob/User = usr
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		// Self-cast
		if(!User.Target || User.Target == User)
			if(cooldown_remaining) return
			src.Cooldown(1, null, User)
			if(src.ManaCost) User.LoseMana(src.ManaCost)
			User.StasisFrozen = 1
			User.SetStasis(src.Stasis * world.tick_lag)
			OMsg(User, "<b>[User] seals themselves inside an inverted mountain with Bakudō #73: Tōzanshō!</b>")
			var/image/sov = image('Tozansho2.dmi', pixel_x=-32, pixel_y=-32, layer=EFFECTS_LAYER)
			sov.appearance_flags = KEEP_APART | RESET_ALPHA | RESET_COLOR
			User.overlays += sov
			spawn(100)
				if(User && User.loc)
					User.overlays -= sov
			return
		// Enemy-cast
		var/mob/T = User.Target
		T.StasisFrozen = 1
		User.Activate(src)
		spawn(0)
			if(!T || !T.loc) return
			if(T.Stasis > 0)
				var/image/tov = image('Tozansho2.dmi', pixel_x=-32, pixel_y=-32, layer=EFFECTS_LAYER)
				tov.appearance_flags = KEEP_APART | RESET_ALPHA | RESET_COLOR
				T.overlays += tov
				spawn(100)
					if(T && T.loc)
						T.overlays -= tov
			else
				T.StasisFrozen = 0

/obj/Skills/Bakudo/Tenteikura
	name = "Tenteikura"

	verb/Tenteikura()
		set name = "Tenteikura"
		set category = "Skills"
		var/mob/User = usr
		var/has_spirit_power = User.passive_handler.Get("SpiritPower")
		var/mode = input(User, "How would you like to use Tenteikura?", "Tenteikura") as null|anything in list("Direct", "Broadcast")
		if(!mode) return
		if(mode == "Direct")
			var/list/who = list()
			for(var/mob/Players/M in players)
				if(M == User) continue
				if(!has_spirit_power)
					if(!M.EnergySignature) continue
					if(!(M.EnergySignature in User.EnergySignaturesKnown)) continue
				who += M
			if(!who.len)
				User << "You have no known energy signatures to contact directly."
				return
			var/mob/Players/selector = input(User, "Choose a recipient:", "Tenteikura Direct") as null|anything in who
			if(!selector) return
			var/msg = input(User, "What do you want to say to [selector]?", "Tenteikura Direct") as text|null
			if(!msg || !length(msg)) return
			Log(selector.ChatLog(),"(Tenteikura from [User] to [selector]): [msg]")
			Log(User.ChatLog(),"(Tenteikura from [User] to [selector]): [msg]")
			Log("Telepath","(Tenteikura from [User] to [selector]): [msg]")
			User << output("<font color=#9999ff><b>(Tenteikura)</b></font>- To  <a href=?src=\ref[selector];action=MasterControl;do=TPM>[selector]</a href> :[msg]", "output")
			User << output("<font color=#9999ff><b>(Tenteikura)</b></font>- To  <a href=?src=\ref[selector];action=MasterControl;do=TPM>[selector]</a href> :[msg]", "icchat")
			if(selector.HearThoughts)
				selector << output("<font color=#9999ff><b>(Tenteikura)</b></font>- From  <a href=?src=\ref[User];action=MasterControl;do=TPM>[User]</a href> :[msg]", "output")
				selector << output("<font color=#9999ff><b>(Tenteikura)</b></font>- From  <a href=?src=\ref[User];action=MasterControl;do=TPM>[User]</a href> :[msg]", "icchat")
		else
			var/list/plane_targets = list()
			plane_targets += User
			for(var/mob/Players/M in players)
				if(M == User) continue
				if(M.AdminInviso) continue
				if(!has_spirit_power)
					if(!M.EnergySignature) continue
					if(!(M.EnergySignature in User.EnergySignaturesKnown)) continue
				plane_targets += M
			var/mob/Players/anchor = input(User, "Select a target to broadcast to their plane (select yourself for your own plane):", "Tenteikura Broadcast") as null|anything in plane_targets
			if(!anchor) return
			var/msg = input(User, "Transmit a message to all presences on that plane:", "Tenteikura Broadcast") as text|null
			if(!msg || !length(msg)) return
			OMsg(User, "<b>[User] broadcasts telepathically with Bakudō #77: Tenteikura!</b>")
			for(var/mob/Players/M in players)
				if(M == User) continue
				if(M.z != anchor.z) continue
				if(M.AdminInviso) continue
				if(!has_spirit_power)
					if(!M.EnergySignature) continue
					if(!(M.EnergySignature in User.EnergySignaturesKnown)) continue
				// Receivers must have SpiritPower or know the sender's signature to perceive the broadcast
				if(!M.passive_handler.Get("SpiritPower") && !(User.EnergySignature in M.EnergySignaturesKnown)) continue
				M << output("<font color=#9999ff><b>(Tenteikura)</b></font>- From  <a href=?src=\ref[User];action=MasterControl;do=TPM>[User]</a href> :[msg]", "output")
				M << output("<font color=#9999ff><b>(Tenteikura)</b></font>- From  <a href=?src=\ref[User];action=MasterControl;do=TPM>[User]</a href> :[msg]", "icchat")
			User << output("<font color=#9999ff><b>(Tenteikura)</b></font>: [msg]", "output")
			User << output("<font color=#9999ff><b>(Tenteikura)</b></font>: [msg]", "icchat")

// TIER 5

/obj/Skills/Bakudo/Kuyou_Shibari
	name = "Kuyou Shibari"
	ManaCost = 40
	Cooldown = 120
	Distance = 5

	verb/Kuyou_Shibari()
		set name = "Kuyou Shibari"
		set category = "Skills"
		var/mob/User = usr
		if(cooldown_remaining) return
		if(!User.Target || User.Target == User)
			User << "You need a target for Kuyou Shibari."
			return
		var/mob/T = User.Target
		if(get_dist(User, T) > Distance)
			User << "[T] is too far away."
			return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, User)
		if(src.ManaCost) User.LoseMana(src.ManaCost)
		OMsg(User, "<b>[User] binds [T] with nine spiritual orbs using Bakudō #79: Kuyō Shibari!</b>")
		applySuspend(T, 5, 'KuyoShibari.dmi')

/obj/Skills/Bakudo/Danku
	name = "Danku"
	ManaCost = 20
	Cooldown = 120
	var/wall_active = FALSE

	verb/Danku()
		set name = "Danku"
		set category = "Skills"
		var/mob/User = usr
		if(Using || cooldown_remaining) return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, User)
		if(src.ManaCost) User.LoseMana(src.ManaCost)
		var/turf/front = get_step(User, User.dir)
		if(!front) front = User.loc
		var/obj/Effects/DankuWall/wall = new(front)
		wall.owner = User
		wall.dir = User.dir
		src.wall_active = TRUE
		OMsg(User, "<b>[User] erects a wall of pure reiatsu with Bakudō #81: Dankū!</b>")
		spawn()
			sleep(50)
			src.wall_active = FALSE
			if(!wall || !wall.loc) return
			animate(wall, alpha=0, time=5)
			sleep(5)
			if(wall) del wall

/obj/Effects/DankuWall
	icon = 'Danku.dmi'
	density = 1
	layer = EFFECTS_LAYER + 1
	Lifetime = -1
	var/tmp/mob/owner

	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/proj = Obstacle
			proj.endLife()
