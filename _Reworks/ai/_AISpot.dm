
/mob/Admin3/verb/ForceAISpawn(obj/AI_Spot/AI in world)
	set name = "Force AI Spawns"
	var/difference = AI.ai_limit-AI.ai_active.len
	var/i
	for(i = 0, i < difference, i++)
		AI.countdown_current = 0
		AI.generate_ai()

/mob/Admin3/verb/MakeAISpawner()
	set name = "AI Spawner"
	var/n = input(src, "What name") as text
	var/list/monsters = typesof(/monster_info)
	var/monster = input(src, "What monster") in monsters
	var/timer = input(src, "How often (30 seconds per whole number)") as num
	var/ai_limit = input(src, "How many can total exist?") as num
	var/spawn_range = input(src, "How far can they spawn from this spot?") as num
	var/boss = input(src, "Is this a boss?") in list("Yes", "No", "Giga?")
	var/power = 0
	var/potential = input(src, "What level should the monster be?") as num
	var/scaling = input(src, "Does the mosnter scale with potenial?") in list("Yes", "No")
	var/icon/i = input(src, "What icon do you want it to be?") as icon
	var/mins = input(src, "How gorked should the mineral mod be?") as num
	var/goon = input(src, "Is this a goon?") in list("Yes", "No")
	var/giga = input(src, "How large should they get?", "Enlarge") as num
	if(goon == "Yes")
		goon = input(src, "How much?") as num
	else
		goon = FALSE
	var/monster_info/mon = new monster
	mon.icon = i
	mon.potential = potential
	mon.name = n
	mon.og_name = n
	mon.enlarge = giga
	if(goon)
		mon.tank = -goon
	if(scaling == "Yes")
		mon.potentialScaling = TRUE
	else
		mon.potentialScaling = FALSE
	switch(boss)
		if("Giga?")
			power = 2
		if("Yes")
			power = 1
	var/obj/AI_Spot/ai_spot = new()
	ai_spot.name = "The [n] Spawner"
	ai_spot.monsters += list(mon)
	ai_spot.countdown_limit = timer
	ai_spot.powerModifier = power
	ai_spot.mineralModifier = mins
	ai_spot.ai_limit = ai_limit
	ai_spot.spawn_range = spawn_range
	ai_spot.loc = src.loc
	ai_spot.generate_ai()


obj
	AI_Spot
		Attackable=0
		Destructable=0
		Grabbable=0
		Savable=1
		invisibility=98
		icon='SparkleRed.dmi'
		var/countdown_current=0//how many minutes have passed?
		var/countdown_limit=3//how many minutes until respawn triggers?
		var/ai_limit=1//how many minions does this spot spawn?
		var/tmp/list/mob/ai_active=list()//a list of the monsters currently active who were spawned by this spot
		var/list/monsters=list()
		var/list/allied_ckeys=list()
		var/spawn_range=1
		var/mineralModifier = 1
		var/powerModifier = 0

		New()
			..()
			src.roll_tag()
			if(global.ai_tracker_loop)
				global.ai_tracker_loop.Add(src)
		Del()
			for(var/mob/Player/AI/ai in ai_active)
				ai.EndLife(0)
			if(global.ai_tracker_loop)
				global.ai_tracker_loop.Remove(src)
				src.loc=null
			..()

		proc
			EditAI(mob/p)
				if(p.Admin)
					if(length(monsters)>0)
						p?:Edit(monsters[1])

			roll_tag()
				src.name="#[rand(1000,9999)] [src.name]"
				for(var/obj/AI_Spot/ais in global.ai_tracker_loop)
					if(ais==src)
						continue
					if(ais.name==src.name)
						src.roll_tag()
						break
			minute_pass()//minutes only pass if one of the monsters is missing
				src.countdown_current++
				if(src.countdown_current>=src.countdown_limit)
					src.countdown_current=0
					src.generate_ai()
			generate_ai()
				var/list/turf/turfs=list()
				for(var/turf/t in range(5, src))
					if(t.density)
						continue
					turfs.Add(t)
				var/turf/t
				while(!t || t.density)
					var/neg_spawn=((-1)*src.spawn_range)
					t=locate(src.x+rand(neg_spawn, src.spawn_range), src.y+rand(neg_spawn, src.spawn_range), src.z)
					sleep(1)

				if(t && !t.density)
					var/mob/Player/AI/p=new
					p.loc=locate(t.x, t.y, t.z)
					p.ai_state="Idle"
					p.senpai=src
					src.initial_aize(p)
					src.ai_active.Add(p)
			initial_aize(var/mob/Player/AI/p)//set icon n such
				var/monster_info/mi = pick(monsters)
				if(!mi)
					world<<"[src] somehow doesn't have a monster info. This is a bug."
					return
				p.name=mi.name
				if(IsList(mi.icon))
					p.icon=pick(mi.icon)
				else
					p.icon=mi.icon
				if(IsList(mi.overlay))
					for(var/x in mi.overlay)
						p.overlays+=icon(x)
				else
					p.overlays+=icon(mi.overlay)
				p.pixel_x=mi.pixel_x
				p.pixel_y=mi.pixel_y
				p.ai_alliances.Add(src.allied_ckeys)
				p.ai_alliances.Add("AI Friends")
				if(mi.potentialScaling)
					p.Potential=glob.progress.DaysOfWipe
				else
					p.Potential=mi.potential
				if(powerModifier)
					p.Potential *= 1 + round((powerModifier / 2), 1)

				if(mi.apply_passives.len>=1)
					p.passive_handler.increaseList(mi.apply_passives)
				p.prioritize_players=1
				p.ai_wander=1
				p.ai_hostility=1
				p.passive_handler.Increase("SwordPunching")
				p.passive_handler.Increase("WaterWalk")
				if(mi.seek_destroy)
					p.ai_hostility=2
				if(mi.hostile>=2)
					p.hostile = 2
				p.WoundIntent=1
				p.passive_handler.Increase("PureReduction", mi.tank)
				p.ai_spammer = mi.spammer
				if(mi.metal)
					p.passive_handler.Set("PureReduction", 5)
				p.passive_handler.Increase("PureDamage", mi.dps)
				p.passive_handler.Increase("TechniqueMastery", mi.sin)
				if(mi.void)
					p.passive_handler.Increase("SoulFire", 0.5)
					p.passive_handler.Increase("Void")
					p.passive_handler.Increase("VoidField", 5)

				var/potBoon = 0.5 + p.Potential/200
				p.StrMod = round(mi.str_mod + potBoon, 0.05)
				p.EndMod = round(mi.end_mod + potBoon, 0.05)
				p.SpdMod = round(mi.spd_mod + potBoon, 0.05)
				p.ForMod = round(mi.for_mod + potBoon, 0.05)
				p.OffMod = round(mi.off_mod + potBoon, 0.05)
				p.DefMod = round(mi.def_mod + potBoon, 0.05)
				p.RecovMod = round(mi.recov_mod + potBoon, 0.05)

				p.Intimidation=mi.intimidation*(1+rand())
				if(p.Intimidation<p.Potential/10)
					p.Intimidation=p.Potential/10
				p.Intimidation=round(p.Intimidation, 0.05)
				p.HealthCut=1-min(1, mi.base_health/100)
				p.HealthCut=round(p.HealthCut, 0.05)
				p.AngerMax=1+p.HealthCut//lower health gives higher anger
				p.AngerMax=round(p.AngerMax, 0.05)

				for(var/x in mi.skilloptions)
					var/path=text2path(x)
					var/obj/Skills/s=new path
					p.AddSkill(s)
				p.name = "[p.name]"
				if(mi.attunement)
					p.Attunement=mi.attunement
					p.ElementalOffense=mi.attunement
					p.ElementalOffense=mi.attunement

					if(p.Attunement=="Wind")
						p.passive_handler.Increase("Skimming", 2)
					if(p.Attunement=="Water")
						p.passive_handler.Increase("Fishman")
					if(p.Attunement=="Chaos")
						p.passive_handler.Increase("PureDamage", 7)
						p.passive_handler.Increase("PureReduction", 7)
						p.passive_handler.Increase("DarknessFlame")
						p.passive_handler.Increase("AbsoluteZero")
						p.passive_handler.Increase("Godspeed", 4)
					if(p.Attunement=="Dark")
						p.HealthCut=0
						p.AngerMax=1.5

						p.ai_hostility=2
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heartless)
				if(mi.force_offense)
					p.ElementalOffense=mi.force_offense
				var/legen = powerModifier == 1 ? 100 : mi.legend_power
				if(prob(legen))
					p.passive_handler.Increase("Mythical", (p.Potential/100))

					p.EndMod*=1.5
					p.DefMod*=1.5
					p.HealthCut=0
					p.passive_handler.Increase("EndlessAnger", 1)
					p.shifts_target=1
					p.name="(FIELD BOSS) [p.name] (Potential: [p.Potential*1.25])"
				if(prob(mi.spirit_power))
					p.passive_handler.Increase("SpiritPower", (p.Potential/100))
					p.passive_handler.Increase("CalmAnger", 1)
					p.OffMod*=1.5
					p.SpdMod*=1.5
					p.HealthCut=0
					p.shifts_target=1
					p.name="Pure [p.name] (Potential: [p.Potential])"
				if(prob(mi.hell_power))
					p.passive_handler.Increase("HellPower", (p.Potential/100))
					p.AngerMax+=1

					p.StrMod*=1.5
					p.ForMod*=1.5
					p.HealthCut=0
					p.passive_handler.Increase("EndlessAnger", 1)
					p.shifts_target=1
					p.name="Demonic [p.name] (Potential: [p.Potential])"
				if(prob(mi.murder_chance))

					p.StrMod*=1.5
					p.ForMod*=1.5
					p.OffMod*=1.5
					p.HealthCut=0
					p.passive_handler.Increase("EndlessAnger", 1)
					p.AngerMax=2
					p.name="Rare [p.name] (Potential: [p.Potential])"
				if(p.ai_hostility==1 && prob(mi.hungry_chance))

					p.HealthCut=0.5
					p.AngerMax=2
					p.passive_handler.Increase("EndlessAnger", 1)
					p.EndMod/=2
					p.name="Starving [p.name] (Potential: [p.Potential])"
				var/epic = powerModifier > 1 ? 100 : mi.epic_power
				if(prob(epic))
					if(powerModifier >= 2)
						p.ai_hostility=1
						p.passive_handler.Increase("PureDamage", 3)
						p.passive_handler.Increase("PureReduction", 3)
						p.passive_handler.Increase("Godspeed", 3)
						p.passive_handler.Increase("GodKi", p.Potential/200)
						p.HealthCut=0
						p.Intimidation*=2
						p.AngerMax=2
						p.passive_handler.Increase("EndlessAnger", 1)
						p.PowerInvisible*=2
						p.transform*=2
						p.shifts_target=1
						p.StrMod*=2
						p.EndMod*=2
						p.SpdMod*=2
						p.ForMod*=2
						p.OffMod*=2
						p.DefMod*=2
						p.name="(GIGA BOSS) [p.name] (Potential: [p.Potential*3])"

					else
						p.ai_hostility=1

						p.HealthCut=0
						p.Intimidation*=2
						p.AngerMax=2
						p.passive_handler.Increase("EndlessAnger", 1)
						p.PowerInvisible*=2
						p.transform*=2
						p.shifts_target=1
						p.StrMod*=2
						p.EndMod*=2
						p.SpdMod*=2
						p.ForMod*=2
						p.OffMod*=2
						p.DefMod*=2
						p.name="(BOSS) [p.name] (Potential: [p.Potential*1.25])"
				if(mi.crazy_targets)
					p.shifts_target=mi.crazy_targets
				if(mi.void)
					p.AngerMax=1
					p.passive_handler.Increase("Void", 1)
				if(mi.enlarge != 1)
					p.appearance_flags |= PIXEL_SCALE
					p.transform = matrix()*mi.enlarge
				var/obj/Items/mineral/m = new()
				var/potExtra = p.Potential < 11 ? 0 : rand(35,50) * round(p.Potential/10,1)
				m.value = rand(8,21) + p.Potential + potExtra
				m.value *= 1 + (powerModifier / 2)
				m.value *= mineralModifier
				m.name = "[Commas(m.value)] Mana Bits"
				p.contents += m

		Slime_Zone
			monsters=list(new/monster_info/slime)
		Fishman_Zone
			monsters=list(new/monster_info/fishman)
		Kobold_Zone
			monsters=list(new/monster_info/kobold)
		Envy_Zone
			monsters=list(new/monster_info/oozaru_boss)
			countdown_limit=60
		Wasp_Zone
			monsters=list(new/monster_info/hell_wasp)
		Lust_Zone
			monsters=list(new/monster_info/tentacle_boss)
			countdown_limit=60
		Turtle_Zone
			monsters=list(new/monster_info/ice_turtle)
		Gluttony_Zone
			monsters=list(new/monster_info/gluttony_boss)
			countdown_limit=60
		Cactus_Zone
			monsters=list(new/monster_info/cactus_creature)
			ai_limit=3
		Shining_Zone
			monsters=list(new/monster_info/sunlight_swordsman)
			countdown_limit=60
		Sloth_Zone
			monsters=list(new/monster_info/sloth_shambler)
			countdown_limit=60
		Heartless_Zone
			monsters=list(new/monster_info/dark_spider, new/monster_info/dark_scorpion)
			countdown_limit=2
			ai_limit=3

		Colony_Zone

		Gajalaka_Bandits
			monsters=list(new/monster_info/gajalaka)

		Cave_Beasts
			monsters=list(new/monster_info/scorpion, new/monster_info/spider)

		Crystal_Cave_Heartless
			monsters=list(new/monster_info/dark_eye)

		Weapon_AIs_Level_1
			monsters=list(new/monster_info/weapon_ai_1)

		Heartless_Overflow
			monsters=list(new/monster_info/dark_eye, new/monster_info/dark_gajalaka)

		Jungle_Wasps
			monsters=list(new/monster_info/wasp)

		Fish_Beasts
			monsters=list(new/monster_info/fish_beast)

		Cave_Upper
			monsters=list(new/monster_info/cactus_beast)

		Rebel_Mushrooms
			monsters=list(new/monster_info/rebel_mushroom)

		Thief_Kappa
			monsters=list(new/monster_info/kappa)

		Elemental_Spirits
			ai_limit=3
			monsters=list(new/monster_info/wild_fire_spirits, new/monster_info/wild_water_spirits, new/monster_info/wild_earth_spirits)

		Waste_Flayer
			countdown_limit=60
			monsters=list(new/monster_info/waste_flayer)

		Fire_Spirit
			monsters=list(new/monster_info/fire_spirits)
		Water_Spirit
			monsters=list(new/monster_info/water_spirits)
		Earth_Spirit
			monsters=list(new/monster_info/earth_spirits)

		Jungle_Zone

		Jungle_Advanced_Zone

		Fire_Hell_Zone

		Fire_Hell_Advanced_Zone

		Water_Hell_Zone

		Water_Hell_Advanced_Zone

		Earth_Hell_Zone

		Earth_Hell_Advanced_Zone

		Wind_Hell_Zone

		Wind_Hell_Advanced_Zone

		Spiritworld_Zone

		Spiritworld_Advanced_Zone

monster_info
	var/og_name
	var/name
	var/icon
	var/overlay
	var/pixel_x
	var/pixel_y
	var/list/colors
	var/enlarge = 1
	var/potential=5
	var/hostile=1
	var/intimidation=1
	var/potentialScaling = FALSE
	var/str_mod=1
	var/end_mod=1
	var/spd_mod=2
	var/for_mod=1
	var/off_mod=5
	var/def_mod=0.25
	var/recov_mod=1
	var/spammer = 1

	var
		hell_power=0
		legend_power=1
		spirit_power=0
		epic_power=0
		murder_chance=0
		hungry_chance=0
		metal=0
		void=0
		crazy_targets=0

		lethal_chance=0//advanced areas will have rising lethal chances
		seek_destroy=0//if this is flagged then ai hunt for targets. jk that is not what

		tank=0//purereduction
		dps=0//puredamage
		sin=0//techniquemastery

		base_health=50

		skills=0//dumvar
		list/skilloptions=list()//brererk
		t1sigs=0//dumvar
		list/t1options=list()//list of sigs that they could spawn with
		t2sigs=0//dumvar
		list/t2options=list()
		t3sigs=0//dumvar
		list/t3options=list()

		attunement//fire/water/earth/wind/dark
		force_offense//force elemental offense to something

		list/apply_passives = list()
	knight_guard
		name="Knight Guard"
		icon='KnightGuard.dmi'
		pixel_x=0
		pixel_y=0
		colors=list(rgb(153, 0, 0),rgb(0, 153, 0),rgb(0,0,153),rgb(66,66,66),rgb(222,222,222))

	slime
		name="Slime"
		icon='Red_Slime.dmi'
		potential=5
		str_mod=2
		end_mod=2
		recov_mod=3
		skilloptions=list("/obj/Skills/AutoHit/Force_Stomp")
	kobold
		name="Kobold"
		icon='Komfty Kobold.dmi'
		potential=10
		str_mod=2.5
		end_mod=2
		for_mod=2.5
		skilloptions=list("/obj/Skills/AutoHit/Force_Stomp", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/AutoHit/Magic/Blizzard", "/obj/Skills/AutoHit/Magic/Thunder")
	fishman
		name="Fishman"
		icon='Blue_Zora.dmi'
		potential=7.5
		str_mod=1
		end_mod=2
		for_mod=3
		attunement="Water"
		skilloptions=list("/obj/Skills/Projectile/Crash_Burst", "/obj/Skills/Projectile/Rapid_Barrage", "/obj/Skills/AutoHit/Magic/Blizzara")


	gajalaka
		name="Gajalaka"
		icon='GajalakaWild.dmi'
		potential=5
		str_mod=1.5
		end_mod=2
		for_mod=1
		skilloptions=list("/obj/Skills/AutoHit/Force_Stomp")
	dark_gajalaka
		name="Cursed Gajalaka"
		icon='GajalakaWild.dmi'
		potential=5
		str_mod=2
		end_mod=2
		for_mod=2
		attunement="Dark"
		skilloptions=list("/obj/Skills/AutoHit/Clothesline")


	dark_eye
		name="Dark Eye"
		icon='TentaEye.dmi'
		str_mod=2
		end_mod=2
		for_mod=2
		attunement="Dark"
		intimidation=2
		skilloptions=list(
		"/obj/Skills/AutoHit/Stinger",\
		"/obj/Skills/AutoHit/Rising_Spire",\
		"/obj/Skills/AutoHit/Crowd_Cutter")

	weapon_ai_1
		name="Poorly Made Weapon Drone"
		metal=1
		icon=list('Android1.dmi', 'Android11.dmi', 'Android4.dmi')
		potential=5
		crazy_targets=0.3
		str_mod=1
		end_mod=0.5
		for_mod=1
		seek_destroy=1
		skilloptions=list(
		"/obj/Skills/Projectile/Blast",\
		"/obj/Skills/Queue/Uppercut")
		colors=list(rgb(153, 0, 0),rgb(0, 153, 0),rgb(0,0,153))

	spider
		name="Cave Spider"
		icon='Spider.dmi'
		hungry_chance=50
		potential=15
		str_mod=2
		end_mod=0.5
		for_mod=1.5
		skilloptions=list("/obj/Skills/AutoHit/Sticky_Spray")

	scorpion
		name="Cave Scorpion"
		icon='Scorpion.dmi'
		hungry_chance=50
		potential=15
		str_mod=1
		end_mod=3
		for_mod=0.5
		skilloptions=list("/obj/Skills/AutoHit/Venom_Sting")

	fish_beast
		name="Fishman"
		icon='Blue_Zora.dmi'
		potential=10
		str_mod=1
		end_mod=2
		for_mod=3
		attunement="Water"
		skilloptions=list("/obj/Skills/Projectile/Crash_Burst", "/obj/Skills/Projectile/Rapid_Barrage", "/obj/Skills/AutoHit/Magic/Blizzara")
	dire_penguin
		name="Dire Penguin"
		icon='Penguin.dmi'
		potential=10
		hungry_chance=100
		str_mod=3
		end_mod=2
		for_mod=3
		seek_destroy=1
		attunement="Water"
		skilloptions=list("/obj/Skills/AutoHit/Phantom_Strike", "/obj/Skills/AutoHit/Magic/Blizzard", "/obj/Skills/AutoHit/Magic/Blizzara")

	cactus_beast
		name="Cursed Cactus"
		icon='Green_Hanny.dmi'
		potential=10
		murder_chance=15
		str_mod=3
		end_mod=3
		for_mod=3
		seek_destroy=1
		attunement="Poison"
		skilloptions=list("/obj/Skills/Projectile/Straight_Siege", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/Projectile/Kienzan")

	wasp
		name="Magi-Wasps"
		icon='Wasp.dmi'
		potential=10
		murder_chance=15
		str_mod=1
		end_mod=1
		spd_mod=5
		for_mod=1
		attunement="Wind"
		force_offense="Poison"
		skilloptions=list("/obj/Skills/Projectile/Rapid_Barrage", "/obj/Skills/Projectile/Crash_Burst")

	rebel_mushroom
		name="Rebellious Mushroom"
		icon=list('MiniMushBlue.dmi', 'MiniMushPurple.dmi', 'MiniMushRed.dmi', 'MiniMushYellow.dmi')
		murder_chance=50
		potential=10
		intimidation=5
		str_mod=2
		end_mod=2
		for_mod=2
		attunement="Earth"
		skilloptions=list("/obj/Skills/AutoHit/Mush_Bonk", "/obj/Skills/Projectile/Energy_Minefield", "/obj/Skills/AutoHit/Helicopter_Kick")
	kappa
		name="Kappa"
		icon=list('KappaBlue.dmi', 'KappaBrown.dmi', 'KappaGreenDark.dmi', 'KappaGreenLight.dmi')
		hungry_chance=25
		potential=20
		intimidation=2
		str_mod=2
		end_mod=5
		spd_mod=1
		for_mod=3
		attunement="Water"
		skilloptions=list("/obj/Skills/AutoHit/Magic/Blizzard", "/obj/Skills/AutoHit/Magic/Blizzara", "/obj/Skills/AutoHit/Magic/Blizzaga", "/obj/Skills/Projectile/Spirit_Ball", "/obj/Skills/AutoHit/Force_Stomp")
	oozaru_boss
		name="Primate"
		icon='Oozonew.dmi'
		pixel_x=-32
		pixel_y=-32
		str_mod=3
		end_mod=5
		spd_mod=1
		for_mod=3
		attunement="Fire"
		sin=10
		skilloptions=list("/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Fira", "/obj/Skills/Projectile/Magic/Firaga", "/obj/Skills/Projectile/Magic/Meteor", "/obj/Skills/Projectile/Magic/Disintegrate", "/obj/Skills/Projectile/Magic/Flare", "/obj/Skills/AutoHit/Magic/Gravity", "/obj/Skills/AutoHit/Magic/Magnet")
	hell_wasp
		name="Wasp"
		icon='Wasp.dmi'
		colors=list(rgb(153, 0, 0),rgb(102, 0, 0),rgb(51,0,0),rgb(204,0,0),rgb(255,0,0))
		str_mod=2
		end_mod=0.25
		spd_mod=5
		for_mod=2
		attunement="Fire"
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Fira", "/obj/Skills/Projectile/Magic/Firaga", "/obj/Skills/Projectile/Crash_Burst", "/obj/Skills/Projectile/Rapid_Barrage")
	tentacle_boss
		name="Consentacles"
		icon='True Nightmare Fuel.dmi'
		colors=list(rgb(204, 204, 204))
		pixel_x=-48
		pixel_y=-48
		str_mod=3
		end_mod=5
		spd_mod=1
		for_mod=3
		attunement="Water"
		sin=10
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike")
	ice_turtle
		name="Ice Fiend"
		icon=list('AngryFishmanBlack.dmi', 'AngryFishmanBlue.dmi', 'AngryFishmanGreen.dmi', 'AngryFishmanGrey.dmi', 'AngryFishmanPurple.dmi', 'AngryFishmanRed.dmi', 'AngryFishmanYellow.dmi',\
		'Mindflayer.dmi', 'KappaBlue.dmi', 'KappaBrown.dmi', 'KappaGreenDark.dmi', 'KappaGreenLight.dmi', 'Frog.dmi', 'Penguin.dmi', 'TentaEye.dmi')
		murder_chance=25
		attunement="Water"
		str_mod=1.5
		end_mod=4
		spd_mod=1.5
		for_mod=1.5
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Magic/Blizzaga")
	cactus_creature
		name="Cactus"
		icon='Green_Hanny.dmi'
		str_mod=3
		end_mod=3
		spd_mod=1
		for_mod=3
		seek_destroy=1
		crazy_targets=1
		attunement="Poison"
		skilloptions=list("/obj/Skills/Projectile/Straight_Siege", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/Projectile/Kienzan")
	gluttony_boss
		name="Squid"
		icon='Mindflayer.dmi'
		potential=50
		intimidation=20
		str_mod=3
		end_mod=5
		spd_mod=5
		for_mod=3
		crazy_targets=1
		attunement="Water"
		sin=10
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike")
	dark_spider
		name="Heartless Spider"
		icon='Spider.dmi'
		potential=50
		intimidation=12.5
		str_mod=4
		end_mod=4
		for_mod=4
		attunement="Dark"
		sin=5
		skilloptions=list("/obj/Skills/AutoHit/Sticky_Spray", "/obj/Skills/AutoHit/Shadow_Tendril_Strike")
	dark_scorpion
		name="Heartless Scorpion"
		icon='Scorpion.dmi'
		potential=50
		intimidation=12.5
		str_mod=4
		end_mod=4
		for_mod=4
		attunement="Dark"
		sin=5
		skilloptions=list("/obj/Skills/AutoHit/Venom_Sting", "/obj/Skills/AutoHit/Shadow_Tendril_Strike")

	waste_flayer
		name="Flayer"
		icon='Mindflayer.dmi'
		murder_chance=100
		potential=95
		intimidation=20
		void=1
		str_mod=4
		end_mod=2
		spd_mod=3
		for_mod=4
		off_mod=4
		def_mod=2
		seek_destroy=1
		crazy_targets=1
		attunement="Chaos"
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave")

	wild_fire_spirits
		name="Fire Spirit"
		icon=list('CloudFire.dmi', 'HumanoidFire.dmi', 'SparkleFire.dmi')
		colors=list(rgb(153,0,0))
		murder_chance=25
		potential=50
		intimidation=20
		attunement="Fire"
		str_mod=4
		end_mod=0.5
		spd_mod=1
		for_mod=4
		off_mod=4
		def_mod=0.5
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Fira", "/obj/Skills/Projectile/Magic/Firaga", "/obj/Skills/Projectile/Magic/Uber_Shots/Hellfire_Nova")
	wild_water_spirits
		name="Water Spirit"
		icon=list('AngryFishmanBlack.dmi', 'AngryFishmanBlue.dmi', 'AngryFishmanGreen.dmi', 'AngryFishmanGrey.dmi', 'AngryFishmanPurple.dmi', 'AngryFishmanRed.dmi', 'AngryFishmanYellow.dmi',\
		'Mindflayer.dmi', 'KappaBlue.dmi', 'KappaBrown.dmi', 'KappaGreenDark.dmi', 'KappaGreenLight.dmi', 'Frog.dmi', 'Penguin.dmi', 'TentaEye.dmi')
		murder_chance=25
		potential=50
		intimidation=20
		attunement="Water"
		str_mod=1
		end_mod=3
		spd_mod=1
		for_mod=1
		off_mod=2
		def_mod=2
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/AutoHit/Magic/Blizzard", "/obj/Skills/AutoHit/Magic/Blizzara", "/obj/Skills/AutoHit/Magic/Blizzaga")
	wild_earth_spirits
		name="Earth Spirit"
		pixel_x=-16
		pixel_y=-8
		icon=list('DinoMonster.dmi', 'GiantFlower.dmi', 'StoneGolem.dmi')
		murder_chance=25
		potential=50
		intimidation=20
		epic_power=25
		attunement="Earth"
		str_mod=2
		end_mod=3
		spd_mod=1
		for_mod=2
		off_mod=2
		def_mod=3
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/AutoHit/Magic/Magnet", "/obj/Skills/AutoHit/Magic/Gravity", "/obj/Skills/AutoHit/Magic/Magnetga", "/obj/Skills/AutoHit/Magic/Graviga")

	fire_spirits
		name="Fire Spirit"
		icon=list('CloudFire.dmi', 'HumanoidFire.dmi', 'SparkleFire.dmi')
		colors=list(rgb(153,0,0))
		murder_chance=25
		potential=50
		intimidation=20
		attunement="Fire"
		str_mod=4
		end_mod=0.5
		spd_mod=1
		for_mod=4
		off_mod=4
		def_mod=0.5
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Fira", "/obj/Skills/Projectile/Magic/Firaga", "/obj/Skills/Projectile/Magic/Uber_Shots/Hellfire_Nova")
	water_spirits
		name="Water Spirit"
		icon=list('AngryFishmanBlack.dmi', 'AngryFishmanBlue.dmi', 'AngryFishmanGreen.dmi', 'AngryFishmanGrey.dmi', 'AngryFishmanPurple.dmi', 'AngryFishmanRed.dmi', 'AngryFishmanYellow.dmi',\
		'Mindflayer.dmi', 'KappaBlue.dmi', 'KappaBrown.dmi', 'KappaGreenDark.dmi', 'KappaGreenLight.dmi', 'Frog.dmi', 'Penguin.dmi', 'TentaEye.dmi')
		murder_chance=25
		potential=50
		intimidation=20
		attunement="Water"
		str_mod=1
		end_mod=3
		spd_mod=1
		for_mod=1
		off_mod=2
		def_mod=2
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/AutoHit/Magic/Blizzard", "/obj/Skills/AutoHit/Magic/Blizzara", "/obj/Skills/AutoHit/Magic/Blizzaga")
	earth_spirits
		name="Earth Spirit"
		pixel_x=-16
		pixel_y=-8
		icon=list('DinoMonster.dmi', 'GiantFlower.dmi', 'StoneGolem.dmi')
		murder_chance=25
		potential=50
		intimidation=20
		attunement="Earth"
		str_mod=2
		end_mod=3
		spd_mod=1
		for_mod=2
		off_mod=2
		def_mod=3
		seek_destroy=1
		crazy_targets=1
		skilloptions=list("/obj/Skills/AutoHit/Shadow_Tendril_Strike", "/obj/Skills/AutoHit/Destruction_Wave", "/obj/Skills/AutoHit/Magic/Magnet", "/obj/Skills/AutoHit/Magic/Gravity", "/obj/Skills/AutoHit/Magic/Magnetga", "/obj/Skills/AutoHit/Magic/Graviga")
	sunlight_swordsman
		name="Sunlight Swordsman"
		potential=50
		intimidation=20
		//icon='DemonHumanoidSunlight.dmi'
		str_mod=3
		end_mod=3
		for_mod=3
		spd_mod=3
		off_mod=3
		def_mod=0.25
		crazy_targets=1
		sin=10
		skilloptions=list("/obj/Skills/AutoHit/Shining_Sword_Slash","/obj/Skills/AutoHit/Massacre","/obj/Skills/AutoHit/Zantetsuken","/obj/Skills/AutoHit/Shadow_Cut","/obj/Skills/AutoHit/Ikki_Tousen")
	sloth_shambler
		name="Sloth Shambler"
		potential=50
		intimidation=20
		icon='Deep_One.dmi'
		str_mod=0.1
		end_mod=10
		for_mod=0.1
		off_mod=10
		attunement="Fire"
		force_offense="Poison"
		crazy_targets=1
		sin=10
		skilloptions=list("/obj/Skills/AutoHit/Fire_Breath","/obj/Skills/AutoHit/Poison_Gas","/obj/Skills/Projectile/Magic/Fire","/obj/Skills/Projectile/Magic/Fira","/obj/Skills/Projectile/Magic/Firaga","/obj/Skills/Projectile/Magic/Meteor")