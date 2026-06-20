/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi
	name = "Bankai"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1
	var/list/petals = list()
	var/mob/convergence_target = null

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Sniper"       = 5 + SL,
			"HardStyle"    = 2 + SL,
			"Brutalize"    = 1.5 + (0.5 * SL),
			"DeathField"   = 1.5 + (1.5 * SL),
			"Bloodletting" = 6 + (3 * SL),
			"Parry"        = 1.5 + (0.5 * SL),
			"IdealStrike"  = 1
		)
		if(SL < 3)
			passives["ManaLeak"] = 4
		ForMult = 1.3 + (0.1 * SL)
		OffMult = 1.3 + (0.1 * SL)
		DefMult = 1.3 + (0.1 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			deletePetals(user)
			convergence_target = null
			// End Senkei if active
			var/obj/Skills/SenbonzakuraSenkei/sk = locate(/obj/Skills/SenbonzakuraSenkei, user)
			if(sk && sk.senkei_active) sk.endSenkei(user)
			// Deactivate Hakuteiken if active
			var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hk = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
			if(hk && hk.SlotlessOn) hk.Trigger(user, Override=1)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(sf) sf.revertShihakushoIcon(user)

	proc/spawnPetals(mob/user)
		if(!user || !user.loc) return
		deletePetals(user)
		petals = list()
		for(var/i = 1 to 24)
			var/obj/Effects/Senbonzakura_Petal/p = new()
			p.owner = user
			p.wpx = user.x
			p.wpy = user.y
			p.alpha = 0
			updatePetalLocFromPixels(p)
			petals += p
		startPetalLoop(user)
		if(user.client)
			winset(user.client, "mapwindow.map", "right-click=1")
		spawn()
			for(var/obj/Effects/Senbonzakura_Petal/p in petals)
				if(!src.SlotlessOn) break
				animate(p, alpha=255, time=3)
				sleep(2)

	proc/deletePetals(mob/user)
		for(var/obj/Effects/Senbonzakura_Petal/p in petals)
			if(p) del p
		petals = list()
		if(user && user.client)
			user.client.senbonzakura_dragging = FALSE
			winset(user.client, "mapwindow.map", "right-click=0")
		if(user)
			user.AppearanceOff()
			for(var/obj/Items/i in user)
				if(i.IsZanpakuto && i.suffix)
					i.alpha = 255
					break
			user.AppearanceOn()

	proc/startPetalLoop(mob/user)
		// Inner ring, same cardinal/diagonal positions as Shikai
		// Outer ring, 5x5 perimeter surrounding the 3x3 inner grid
		var/list/offsets = list(
			list( 0, 1), list( 1, 1), list( 1, 0), list( 1,-1),
			list( 0,-1), list(-1,-1), list(-1, 0), list(-1, 1),
			list(-2, 2), list(-1, 2), list( 0, 2), list( 1, 2), list( 2, 2),
			list(-2, 1),                                         list( 2, 1),
			list(-2, 0),                                         list( 2, 0),
			list(-2,-1),                                         list( 2,-1),
			list(-2,-2), list(-1,-2), list( 0,-2), list( 1,-2), list( 2,-2)
		)
		var/ROWS = 8
		// Row centers for the rectangular drag chain (8 rows of 3 petals)
		var/list/row_cx = list()
		var/list/row_cy = list()
		for(var/r = 1 to ROWS)
			row_cx += user.x
			row_cy += user.y
		spawn()
			var/idle_ticks = 0
			while(src.SlotlessOn && user && user.loc && petals.len == 24)
				if(!user.client)
					deletePetals(user)
					return
				var/dragging = user.client.senbonzakura_dragging

				if(dragging)
					var/SEGMENT = 0.75
					var/SPREAD = 0.5

					// Row 0 center chases mouse target
					var/tx = user.client.petal_target_wx
					var/ty = user.client.petal_target_wy
					var/hdx = tx - row_cx[1]
					var/hdy = ty - row_cy[1]
					var/hdist = sqrt(hdx*hdx + hdy*hdy)
					var/ht = (hdist > 3) ? 0.4 : 0.2
					row_cx[1] += hdx * ht
					row_cy[1] += hdy * ht

					// Chain logic
					for(var/i = 2 to ROWS)
						var/pdx = row_cx[i] - row_cx[i-1]
						var/pdy = row_cy[i] - row_cy[i-1]
						var/pdist = sqrt(pdx*pdx + pdy*pdy)
						if(pdist < 0.001)
							row_cy[i] = row_cy[i-1] - SEGMENT
						else
							var/scale = SEGMENT / pdist
							row_cx[i] = row_cx[i-1] + pdx * scale
							row_cy[i] = row_cy[i-1] + pdy * scale

					// Spread the 3 petals in each row
					for(var/r = 1 to ROWS)
						var/cx = row_cx[r]
						var/cy = row_cy[r]
						var/dirx = 0
						var/diry = -1
						if(r == 1)
							var/ddx = row_cx[1] - row_cx[2]
							var/ddy = row_cy[1] - row_cy[2]
							var/dd = sqrt(ddx*ddx + ddy*ddy)
							if(dd > 0.001)
								dirx = ddx / dd
								diry = ddy / dd
						else
							var/ddx = row_cx[r-1] - row_cx[r]
							var/ddy = row_cy[r-1] - row_cy[r]
							var/dd = sqrt(ddx*ddx + ddy*ddy)
							if(dd > 0.001)
								dirx = ddx / dd
								diry = ddy / dd
						var/perpx = -diry
						var/perpy = dirx
						var/p1_idx = (r-1)*3 + 1
						var/p2_idx = (r-1)*3 + 2
						var/p3_idx = (r-1)*3 + 3
						if(p1_idx <= petals.len && petals[p1_idx])
							var/obj/Effects/Senbonzakura_Petal/pp1 = petals[p1_idx]
							pp1.wpx = cx + perpx * SPREAD
							pp1.wpy = cy + perpy * SPREAD
						if(p2_idx <= petals.len && petals[p2_idx])
							var/obj/Effects/Senbonzakura_Petal/pp2 = petals[p2_idx]
							pp2.wpx = cx
							pp2.wpy = cy
						if(p3_idx <= petals.len && petals[p3_idx])
							var/obj/Effects/Senbonzakura_Petal/pp3 = petals[p3_idx]
							pp3.wpx = cx - perpx * SPREAD
							pp3.wpy = cy - perpy * SPREAD
				else
					if(convergence_target && convergence_target.loc)
						// Converge all petals toward the target
						for(var/i = 1 to petals.len)
							var/obj/Effects/Senbonzakura_Petal/cur = petals[i]
							cur.wpx += (convergence_target.x - cur.wpx) * 0.5
							cur.wpy += (convergence_target.y - cur.wpy) * 0.5
					else
						// Return each petal to its formation position
						for(var/i = 1 to petals.len)
							var/obj/Effects/Senbonzakura_Petal/cur = petals[i]
							var/list/off = offsets[i]
							var/ftx = user.x + off[1]
							var/fty = user.y + off[2]
							var/fdx = ftx - cur.wpx
							var/fdy = fty - cur.wpy
							cur.wpx += fdx * 0.35
							cur.wpy += fdy * 0.35
					// Keep row centers updated from center petals so drag starts smoothly
					for(var/r = 1 to ROWS)
						var/ctr_idx = (r-1)*3 + 2
						if(ctr_idx <= petals.len && petals[ctr_idx])
							var/obj/Effects/Senbonzakura_Petal/ctr = petals[ctr_idx]
							row_cx[r] = ctr.wpx
							row_cy[r] = ctr.wpy
					idle_ticks++
					if(idle_ticks >= 10)
						idle_ticks = 0
						for(var/obj/Effects/Senbonzakura_Petal/p in petals)
							if(!p || !p.loc) continue
							if(p.inactive) continue
							for(var/mob/M in p.loc)
								if(M == user || M.Stasis) continue
								user.Target = M
								user.petal_attacking = TRUE
								user.Melee1(forcedTarget=M, BreakAttackRate=1)
								user.petal_attacking = FALSE
								var/obj/Effects/HE = new(null, 'Icons/Effects/Byakuya - Petals - Attacks.dmi', -40, -40)
								HE.icon_state = "4"
								HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
								HE.Target = M
								HE.pixel_z = M.pixel_z
								M.vis_contents += HE

				// Update tile positions and reset already_hit and check new tile hits
				for(var/obj/Effects/Senbonzakura_Petal/p in petals)
					var/old_loc = p.loc
					updatePetalLocFromPixels(p)
					if(p.loc != old_loc)
						p.already_hit = list()
						checkPetalHit(p, user)

				sleep(1)
			deletePetals(user)

	proc/updatePetalLocFromPixels(obj/Effects/Senbonzakura_Petal/p)
		if(!p || !p.owner || !p.owner.loc) return
		var/TSIZE = world.icon_size
		var/tx = clamp(round(p.wpx), 1, world.maxx)
		var/ty = clamp(round(p.wpy), 1, world.maxy)
		var/newloc = locate(tx, ty, p.owner.z)
		if(newloc)
			p.loc = newloc
		p.pixel_x = (p.wpx - tx) * TSIZE
		p.pixel_y = (p.wpy - ty) * TSIZE

	proc/checkPetalHit(obj/Effects/Senbonzakura_Petal/p, mob/user)
		if(!p || !p.loc || !user || !user.loc) return
		if(p.inactive) return
		for(var/mob/M in p.loc)
			if(M == user) continue
			if(M.ckey in p.already_hit) continue
			if(M.Stasis) continue
			p.already_hit += M.ckey
			user.Target = M
			user.petal_attacking = TRUE
			user.Melee1(forcedTarget=M, BreakAttackRate=1)
			user.petal_attacking = FALSE
			var/obj/Effects/HE = new(null, 'Icons/Effects/Byakuya - Petals - Attacks.dmi', -40, -40)
			HE.icon_state = "4"
			HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			HE.Target = M
			HE.pixel_z = M.pixel_z
			M.vis_contents += HE

	proc/setPetalsInactive(inactive_state, alpha_val)
		for(var/obj/Effects/Senbonzakura_Petal/p in petals)
			if(!p) continue
			p.inactive = inactive_state
			animate(p, alpha=alpha_val, time=3)

	Del()
		for(var/obj/Effects/Senbonzakura_Petal/p in petals)
			if(p) del p
		petals = list()
		..()

	proc/bankaiActivationSequence(mob/user)
		spawn()
			// Hide zanpakuto immediately (not working atm)
			user.AppearanceOff()
			for(var/obj/Items/i in user)
				if(i.IsZanpakuto && i.suffix)
					i.alpha = 0
					break
			user.AppearanceOn()

			// Track sword tile positions
			var/list/spx = list()
			var/list/spy = list()

			// Wave 1
			var/list/swords = list()
			for(var/xoff in list(-3, 3))
				var/obj/Effects/BankaiSword/sw = new(locate(user.x + xoff, user.y, user.z))
				sw.transform *= 3
				sw.pixel_y = -96
				sw.alpha = 255
				swords += sw
				spx += (user.x + xoff)
				spy += user.y
				animate(sw, pixel_y=0, time=20)
			sleep(10)

			// Wave 2
			for(var/pos2 in list(list(-3,2),list(3,2),list(-3,-2),list(3,-2)))
				var/obj/Effects/BankaiSword/sw2 = new(locate(user.x + pos2[1], user.y + pos2[2], user.z))
				sw2.transform *= 3
				sw2.pixel_y = -96
				sw2.alpha = 255
				swords += sw2
				spx += (user.x + pos2[1])
				spy += (user.y + pos2[2])
				animate(sw2, pixel_y=0, time=20)
			sleep(10)

			// Wave 3
			for(var/pos3 in list(list(-3,4),list(3,4),list(-3,-4),list(3,-4)))
				var/obj/Effects/BankaiSword/sw3 = new(locate(user.x + pos3[1], user.y + pos3[2], user.z))
				sw3.transform *= 3
				sw3.pixel_y = -96
				sw3.alpha = 255
				swords += sw3
				spx += (user.x + pos3[1])
				spy += (user.y + pos3[2])
				animate(sw3, pixel_y=0, time=20)
			sleep(10)

			// Transition swords to pink (kind of scuffed rn)
			for(var/obj/Effects/BankaiSword/swd in swords)
				animate(swd, color="#ffb0d0", time=15)
			sleep(20)

			// Swords fade out
			for(var/obj/Effects/BankaiSword/swd in swords)
				animate(swd, alpha=0, time=10)
			sleep(10) // wait for fade to complete

			// Spawn 24 petals at sword positions
			deletePetals(user)
			petals = list()
			var/nswords = spx.len
			for(var/pi = 1 to 24)
				var/obj/Effects/Senbonzakura_Petal/pp = new()
				pp.owner = user
				var/pidx = ((pi - 1) % nswords) + 1
				pp.wpx = spx[pidx]
				pp.wpy = spy[pidx]
				pp.alpha = 255
				updatePetalLocFromPixels(pp)
				petals += pp
			startPetalLoop(user)
			if(user.client)
				winset(user.client, "mapwindow.map", "right-click=1")

			sleep(5)
			for(var/obj/Effects/BankaiSword/swd in swords)
				if(swd) del swd

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
			OMsg(usr, "<b>[usr] calls out, \"Bankai... [usr.AsauchiName] [usr.BankaiPrefix]!\"</b>")
			src.Trigger(usr)
			bankaiActivationSequence(usr)
		else
			var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hkt = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
			if(hkt && hkt.SlotlessOn)
				usr << "You cannot end Bankai while Shukei: Hakuteiken is active."
				return
			src.Trigger(usr)
