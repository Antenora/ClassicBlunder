/obj/Effects/GoukeiOverlay
	icon = 'Icons/Effects/Gokei.dmi'
	Lifetime = -1
	pixel_x = -32
	pixel_y = -32
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/Effects/SenkeiSword
	icon = 'Icons/Effects/byakuyabankai.dmi'
	density = 1
	layer = EFFECTS_LAYER + 1
	Lifetime = -1
	var/tmp/mob/sword_owner
	var/launched = FALSE

	proc/launch(mob/user, mob/target)
		if(!src.loc || !target || !target.loc) return
		src.density = 0
		src.launched = TRUE
		// Rotate tip toward target
		var/angle = GetAngle(src, target)
		var/matrix/M = matrix()
		M.Turn(180 - angle)   // should make sword point at target
		src.transform = M
		spawn()
			for(var/step = 1 to 30)
				if(!src || !src.loc) return
				if(!target || !target.loc) break
				if(get_dist(src, target) <= 1)
					// 75% damage reduction
					user.Target = target
					user.petal_attacking = TRUE
					user.Melee1(forcedTarget=target, BreakAttackRate=1, dmgmulti=0.25)
					user.petal_attacking = FALSE
					del src
					return
				step_towards(src, target)
				sleep(1)
			if(src) del src

// Saga Level 4
/obj/Skills/SenbonzakuraGoukei
	name = "Goukei"
	Cooldown = 60
	ManaCost=10
	var/goukei_active = FALSE
	verb/Goukei()
		set name = "Goukei"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Goukei can only be used in Bankai."
			return
		if(Using || cooldown_remaining) return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hkt = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
		if(hkt && hkt.SlotlessOn) return
		var/obj/Skills/SenbonzakuraPetalWall/pw = usr.FindSkill(/obj/Skills/SenbonzakuraPetalWall)
		if(pw && pw.wall_active) return
		var/obj/Skills/SenbonzakuraSenkei/sk = usr.FindSkill(/obj/Skills/SenbonzakuraSenkei)
		if(sk && sk.senkei_active) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 8)
			usr << "Target is too far away."
			return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
		if(!bk || !bk.SlotlessOn) return
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		if(src.ManaCost) usr.LoseMana(src.ManaCost)
		var/mob/user = usr

		// Mark petals inactive and disable dragging while converging
		bk.setPetalsInactive(TRUE, 255)
		if(user.client)
			user.client.senbonzakura_dragging = FALSE
			winset(user.client, "mapwindow.map", "right-click=0")
		bk.convergence_target = target

		src.goukei_active = TRUE
		spawn()
			// Wait for petals to travel toward the target
			sleep(10)
			if(!target || !target.loc || !bk.SlotlessOn)
				src.goukei_active = FALSE
				bk.convergence_target = null
				bk.setPetalsInactive(FALSE, 255)
				if(user && user.client)
					winset(user.client, "mapwindow.map", "right-click=1")
				return

			// Hide petals now that they've converged
			bk.setPetalsInactive(TRUE, 0)

			var/obj/Effects/GoukeiOverlay/GE = new(null)
			GE.pixel_z = target.pixel_z
			target.vis_contents += GE

			// Snare target for 4 seconds
			target.applySnare(4)

			// Record where the target is standing
			var/turf/start_loc = target.loc

			// Melee1 every 0.5s for 4s, stop if target moves
			for(var/i = 1 to 8)
				if(!target || !target.loc || !user || !user.loc) break
				if(target.loc != start_loc) break
				user.Target = target
				user.petal_attacking = TRUE
				user.Melee1(forcedTarget=target, BreakAttackRate=1)
				user.petal_attacking = FALSE
				sleep(5)

			// Fade Gokei overlay and restore petals
			animate(GE, alpha=0, time=5)
			sleep(5)
			if(target && GE) target.vis_contents -= GE
			del GE
			src.goukei_active = FALSE
			bk.convergence_target = null
			// Snap petals to user before re-enabling.
			if(user && user.loc)
				for(var/obj/Effects/Senbonzakura_Petal/p in bk.petals)
					if(!p) continue
					p.wpx = user.x
					p.wpy = user.y
					bk.updatePetalLocFromPixels(p)
			bk.setPetalsInactive(FALSE, 255)
			if(user && user.client)
				winset(user.client, "mapwindow.map", "right-click=1")


// Saga Level 5
/obj/Skills/SenbonzakuraSenkei
	name = "Senkei"
	ManaCost=15
	Cooldown = 120
	var/senkei_active = FALSE
	var/list/inner_swords
	var/list/outer_swords

	New()
		inner_swords = list()
		outer_swords = list()
		..()

	proc/spawnSwords(mob/user)
		if(!user || !user.loc) return
		deleteSwords()
		inner_swords = list()
		outer_swords = list()
		var/ux = user.x
		var/uy = user.y
		var/uz = user.z
		// Inner ring
		var/list/b_in = block(
			locate(clamp(ux-6, 1, world.maxx), clamp(uy-6, 1, world.maxy), uz),
			locate(clamp(ux+6, 1, world.maxx), clamp(uy+6, 1, world.maxy), uz)
		)
		var/list/b_in_fill = block(
			locate(clamp(ux-5, 1, world.maxx), clamp(uy-5, 1, world.maxy), uz),
			locate(clamp(ux+5, 1, world.maxx), clamp(uy+5, 1, world.maxy), uz)
		)
		// Outer ring
		var/list/b_out = block(
			locate(clamp(ux-7, 1, world.maxx), clamp(uy-7, 1, world.maxy), uz),
			locate(clamp(ux+7, 1, world.maxx), clamp(uy+7, 1, world.maxy), uz)
		)
		for(var/turf/T in b_in)
			if(T in b_in_fill) continue
			var/obj/Effects/SenkeiSword/sw = new(T)
			sw.sword_owner = user
			inner_swords += sw
		for(var/turf/T in b_out)
			if(T in b_in) continue
			var/obj/Effects/SenkeiSword/sw = new(T)
			sw.sword_owner = user
			outer_swords += sw

	proc/deleteSwords()
		var/list/to_del = inner_swords + outer_swords
		inner_swords = list()
		outer_swords = list()
		for(var/obj/Effects/SenkeiSword/sw in to_del)
			if(!sw || sw.launched) continue
			animate(sw, alpha=0, time=5)
		spawn()
			sleep(6)
			for(var/obj/Effects/SenkeiSword/sw in to_del)
				if(sw && !sw.launched) del sw

	proc/launchSword(obj/Effects/SenkeiSword/sw, mob/user, mob/target)
		if(!sw || !sw.loc || !target || !target.loc) return
		inner_swords -= sw
		outer_swords -= sw
		sw:launch(user, target)

	proc/endSenkei(mob/user, keep_swords = 0)
		senkei_active = FALSE
		if(!keep_swords)
			// Normal end restores petals and fade swords
			var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
			if(bk) bk.setPetalsInactive(FALSE, 255)
			deleteSwords()
		else
			// Ikka Senjinka path
			inner_swords = list()
			outer_swords = list()

	verb/Senkei()
		set name = "Senkei"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Senkei can only be used in Bankai."
			return
		if(senkei_active)
			usr << "Senkei is already active."
			return
		if(Using || cooldown_remaining) return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hkt = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
		if(hkt && hkt.SlotlessOn) return
		var/obj/Skills/SenbonzakuraPetalWall/pw = usr.FindSkill(/obj/Skills/SenbonzakuraPetalWall)
		if(pw && pw.wall_active) return
		var/obj/Skills/SenbonzakuraGoukei/gk = usr.FindSkill(/obj/Skills/SenbonzakuraGoukei)
		if(gk && gk.goukei_active) return
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		if(src.ManaCost) usr.LoseMana(src.ManaCost)
		senkei_active = TRUE
		var/mob/user = usr
		// disable petals for the duration of Senkei
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
		if(bk) bk.setPetalsInactive(TRUE, 0)
		OMsg(user, "<b>[user] extends a hand... \"Senkei.\"</b>")
		spawnSwords(user)
		spawn()
			var/tick_counter = 0
			var/total_ticks = 0
			while(senkei_active && user && user.loc && total_ticks < 300)
				sleep(1)
				tick_counter++
				total_ticks++
				if(tick_counter >= 30)
					tick_counter = 0
					var/mob/target = user.Target
					if(target && target.loc)
						var/list/available = list()
						for(var/obj/Effects/SenkeiSword/sw in inner_swords)
							if(sw && sw.loc && !sw.launched)
								available += sw
						if(available.len > 0)
							var/obj/Effects/SenkeiSword/chosen = available[rand(1, available.len)]
							launchSword(chosen, user, target)
			if(senkei_active)
				endSenkei(user)


// Saga Level 6
/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken
	name = "Shukei: Hakuteiken"
	Slotless = 1
	TimerLimit = 60
	Cooldown = -1
	ManaGlow = "#FFFFFF"
	ManaGlowSize = 3
	StrMult = 1.5
	EndMult = 1.5
	ForMult = 1.5
	SpdMult = 1.5
	OffMult = 1.5
	DefMult = 1.5
	passives = list("BleedHit" = 1, "BulletKill" = 1, "SpiritSword" = 2, "HybridStrike" = 3, "SpiritFlow" = 4, "Duelist" = 5, "CriticalChance" = 25, "CriticalDamage" = 0.25)
	ActiveMessage = "murmurs quietly... \"Shukei: Hakuteiken.\""
	OffMessage = "lets the white glow of Hakuteiken fade..."

	Trigger(mob/user, Override=0)
		var/wasOn = src.SlotlessOn
		..()
		if(!user) return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
		if(!wasOn && src.SlotlessOn)
			// hide and disable petals for the duration
			if(bk) bk.setPetalsInactive(TRUE, 0)
		else if(wasOn && !src.SlotlessOn)
			// restore petals if Bankai still active
			if(bk && bk.SlotlessOn) bk.setPetalsInactive(FALSE, 255)

	verb/Hakuteiken()
		set name = "Shukei: Hakuteiken"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Shukei: Hakuteiken can only be used in Bankai."
			return
		if(Using || cooldown_remaining) return
		if(src.SlotlessOn) return
		src.Trigger(usr)
		src.Cooldown(1, null, usr)


// Saga Level 7
/obj/Skills/SenbonzakuraIkkaSenjinka
	name = "Ikka Senjinka"
	Cooldown = 180
	ManaCost=20
	verb/Ikka_Senjinka()
		set name = "Ikka Senjinka"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Ikka Senjinka can only be used in Bankai."
			return
		if(Using || cooldown_remaining) return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hkt = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
		if(hkt && hkt.SlotlessOn) return
		var/obj/Skills/SenbonzakuraPetalWall/pw = usr.FindSkill(/obj/Skills/SenbonzakuraPetalWall)
		if(pw && pw.wall_active) return
		var/obj/Skills/SenbonzakuraGoukei/gk = usr.FindSkill(/obj/Skills/SenbonzakuraGoukei)
		if(gk && gk.goukei_active) return
		var/obj/Skills/SenbonzakuraSenkei/sk = locate(/obj/Skills/SenbonzakuraSenkei, usr)
		if(!sk || !sk.senkei_active)
			usr << "Senkei must be active to use Ikka Senjinka."
			return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		if(src.ManaCost) usr.LoseMana(src.ManaCost)
		var/mob/user = usr
		var/list/all_swords = sk.inner_swords.Copy()
		all_swords += sk.outer_swords.Copy()
		// End Senkei without deleting swords or restoring petals yet
		sk:endSenkei(user, 1)
		OMsg(user, "<b>[user] sweeps a hand forward... \"Ikka Senjinka.\"</b>")
		// Launch every sword simultaneously
		for(var/obj/Effects/SenkeiSword/sw in all_swords)
			if(!sw || !sw.loc || sw.launched) continue
			sw:launch(user, target)
		// Restore petals after swords have had time to travel
		spawn()
			sleep(25)
			var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
			if(bk) bk.setPetalsInactive(FALSE, 255)
