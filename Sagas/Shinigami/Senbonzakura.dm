/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura
	name = "Senbonzakura"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1
	var/list/petals = list()

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Sniper"       = 3 + SL,
			"HardStyle"    = 1 + SL,
			"Brutalize"    = 0.5 + (0.5 * SL),
			"DeathField"   = 0.5 + (1.5 * SL),
			"Bloodletting" = 4 + (3 * SL),
			"Parry"        = 0.5 + (0.5 * SL),
			"IdealStrike"  = 1
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		ForMult = 1.1 + (0.1 * SL)
		OffMult = 1.1 + (0.1 * SL)
		DefMult = 1.1 + (0.1 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			spawnPetals(user)
		else if(wasOn && !src.SlotlessOn)
			deletePetals(user)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)

	proc/spawnPetals(mob/user)
		if(!user || !user.loc) return
		deletePetals(user)
		petals = list()
		for(var/i = 1 to 8)
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
		var/list/offsets = list(
			list(0,1), list(1,1), list(1,0), list(1,-1),
			list(0,-1), list(-1,-1), list(-1,0), list(-1,1)
		)
		spawn()
			var/idle_ticks = 0
			while(src.SlotlessOn && user && user.loc && petals.len == 8)
				if(!user.client)
					deletePetals(user)
					return
				var/dragging = user.client.senbonzakura_dragging

				if(dragging)
					// Head petal chases the mouse target
					var/obj/Effects/Senbonzakura_Petal/head = petals[1]
					var/tx = user.client.petal_target_wx
					var/ty = user.client.petal_target_wy
					var/dx = tx - head.wpx
					var/dy = ty - head.wpy
					var/dist = sqrt(dx*dx + dy*dy)
					var/t = (dist > 3) ? 0.4 : 0.2
					head.wpx += dx * t
					head.wpy += dy * t

					// Chain logic
					var/SEGMENT = 0.75
					for(var/i = 2 to petals.len)
						var/obj/Effects/Senbonzakura_Petal/cur = petals[i]
						var/obj/Effects/Senbonzakura_Petal/prev = petals[i-1]
						var/pdx = cur.wpx - prev.wpx
						var/pdy = cur.wpy - prev.wpy
						var/pdist = sqrt(pdx*pdx + pdy*pdy)
						if(pdist < 0.001)
							cur.wpy = prev.wpy - SEGMENT
						else
							var/scale = SEGMENT / pdist
							cur.wpx = prev.wpx + pdx * scale
							cur.wpy = prev.wpy + pdy * scale
				else
					// Return each petal to its formation position around user
					for(var/i = 1 to petals.len)
						var/obj/Effects/Senbonzakura_Petal/cur = petals[i]
						var/list/off = offsets[i]
						var/ftx = user.x + off[1]
						var/fty = user.y + off[2]
						var/fdx = ftx - cur.wpx
						var/fdy = fty - cur.wpy
						cur.wpx += fdx * 0.35
						cur.wpy += fdy * 0.35
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

				// Update tile positions
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

	verb/Shikai()
		set name = "Shikai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Shikai."
				return
			if(usr.InBankai())
				usr << "You cannot use Shikai while in Bankai."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Shikai."
				return
			adjust(usr)
			OMsg(usr, "<b>[usr] calls out, \"[usr.ShikaiCall], [usr.AsauchiName]!\"</b>")
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyShikaiIcon(usr)
			// Hide zanpakuto (not working)
			usr.AppearanceOff()
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					i.alpha = 0
					break
			usr.AppearanceOn()
		else
			src.Trigger(usr)

/obj/Skills/SenbonzakuraPetalWall
	name = "Petal Wall"
	Cooldown = 30
	ManaCost = 10
	var/wall_active = FALSE

	verb/Petal_Wall()
		set name = "Petal Wall"
		set category = "Skills"
		if(!usr.InShikai() && !usr.InBankai()) return
		if(Using || cooldown_remaining) return
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken/hkt = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
		if(hkt && hkt.SlotlessOn) return
		var/obj/Skills/SenbonzakuraGoukei/gk = usr.FindSkill(/obj/Skills/SenbonzakuraGoukei)
		if(gk && gk.goukei_active) return
		var/obj/Skills/SenbonzakuraSenkei/sk = usr.FindSkill(/obj/Skills/SenbonzakuraSenkei)
		if(sk && sk.senkei_active) return
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		if(src.ManaCost) usr.LoseMana(src.ManaCost)
		// Find whichever petal buff is currently active
		var/activeBuff = null
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura/shikai = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura)
		var/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi/bk = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
		if(shikai && shikai.SlotlessOn) activeBuff = shikai
		else if(bk && bk.SlotlessOn) activeBuff = bk
		if(!activeBuff) return
		activeBuff:setPetalsInactive(TRUE, 0)
		var/turf/front = get_step(usr, usr.dir)
		if(!front) front = usr.loc
		var/obj/Effects/PetalWall/wall = new(front)
		wall.owner = usr
		wall.dir = usr.dir
		src.wall_active = TRUE
		spawn()
			sleep(50)
			src.wall_active = FALSE
			if(!wall || !wall.loc) return
			animate(wall, alpha=0, time=5)
			var/wx = wall.loc.x
			var/wy = wall.loc.y
			for(var/obj/Effects/Senbonzakura_Petal/p in activeBuff:petals)
				if(!p) continue
				p.wpx = wx
				p.wpy = wy
				activeBuff:updatePetalLocFromPixels(p)
			activeBuff:setPetalsInactive(FALSE, 255)
			sleep(5)
			if(wall) del wall
