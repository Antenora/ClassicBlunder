mob/proc/warp_strike_restore_color()
	set waitfor = FALSE
	if(!src) return
	var/fade_ticks = 8
	var/list/color_list = islist(src.MobColor) ? src.MobColor : list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
	var/r_end = length(color_list) >= 10 ? color_list[10] : 0
	var/g_end = length(color_list) >= 11 ? color_list[11] : 0
	var/b_end = length(color_list) >= 12 ? color_list[12] : 0
	for(var/tick = 0 to fade_ticks - 1)
		if(!src) return
		var/t = (tick + 1) / fade_ticks
		var/r = 1 - t * (1 - r_end)
		var/g = 1 - t * (1 - g_end)
		var/b = 1 - t * (1 - b_end)
		animate(src, color=list(1,0,0, 0,1,0, 0,0,1, r, g, b), time=1)
		sleep(1)
	if(src)
		animate(src, color=color_list, time=1)

mob/proc/GrantCelestialWeapon(path)
	if(!path) return
	var/obj/Items/I = locate(path) in src.contents
	if(!I)
		I = new path
		I.Move(src)
		I.Ascended = src.AscensionsAcquired
		I.Owner = src.key
		src << "<font color='#ffe4b5'><b>[I.name]</b> materializes in a flash of divine light!</font>"
	else
		I.Ascended = src.AscensionsAcquired
		I.AlignEquip(src)
mob/proc/ReclaimCelestialWeapon(path)
	if(!path) return
	if(locate(path) in src.contents)
		src << "[path] is already in your possession."
		return
	var/obj/Items/I
	for(var/obj/Items/G in world)
		if(istype(G, path) && G.Owner == src.key)
			I = G
			break
	if(I)
		I.Move(src)
		I.Ascended = src.AscensionsAcquired
		src << "<font color='#ffe4b5'><b>[I.name]</b></font> returns to your side in a flash of light!"
		return
	I = new path(src)
	I.Owner = src.key
	I.Ascended = src.AscensionsAcquired
	I.AlignEquip(src)
	src << "<font color='#ffe4b5'><b>[I.name]</b></font> rematerializes from the heavens!"

mob/proc/ChooseCelestialWeapon()
	var/list/AllWeapons = list(\
		"Zephyr's Edge" = /obj/Items/Sword/Celestial/Light/Light_Celestial_Blade_I,\
		"Aurelius" = /obj/Items/Sword/Celestial/Light/Light_Celestial_Blade_II,\
		"Gemini Fang" = /obj/Items/Sword/Celestial/Light/Light_Celestial_Blade_III,\
		"Throne's Answer" = /obj/Items/Sword/Celestial/Medium/Medium_Celestial_Blade_I,\
		"Soulkeeper" = /obj/Items/Sword/Celestial/Medium/Medium_Celestial_Blade_II,\
		"Pillar of Dawn" = /obj/Items/Sword/Celestial/Medium/Medium_Celestial_Blade_III,\
		"Dawnbreaker" = /obj/Items/Sword/Celestial/Heavy/Heavy_Celestial_Blade_I,\
		"Longarm of Heaven" = /obj/Items/Sword/Celestial/Heavy/Heavy_Celestial_Blade_II,\
		"Wrath Incarnate" = /obj/Items/Sword/Celestial/Heavy/Heavy_Celestial_Blade_III,\
		"Starling's Quill" = /obj/Items/Enchantment/Staff/Celestial/Wand/Celestial_Wand_I,\
		"Wellspring Rod" = /obj/Items/Enchantment/Staff/Celestial/Wand/Celestial_Wand_II,\
		"Ember of Elysium" = /obj/Items/Enchantment/Staff/Celestial/Wand/Celestial_Wand_III,\
		"The Undercurrent" = /obj/Items/Enchantment/Staff/Celestial/Rod/Celestial_Rod_I,\
		"Siphon of Aethon" = /obj/Items/Enchantment/Staff/Celestial/Rod/Celestial_Rod_II,\
		"The Pale Axis" = /obj/Items/Enchantment/Staff/Celestial/Rod/Celestial_Rod_III,\
		"Voice of the Storm" = /obj/Items/Enchantment/Staff/Celestial/Staff_Class/Celestial_Staff_I,\
		"Rime Throne" = /obj/Items/Enchantment/Staff/Celestial/Staff_Class/Celestial_Staff_II,\
		"Pact of the Exalted" = /obj/Items/Enchantment/Staff/Celestial/Staff_Class/Celestial_Staff_III)
	while(src && src.client)
		var/list/available = list()
		for(var/wname in AllWeapons)
			var/path = AllWeapons[wname]
			if(!locate(path) in src.contents)
				available[wname] = path
		if(!available.len)
			src << "<font color='#ffe4b5'>You have already obtained all celestial armaments.</font>"
			return
		var/choice = input(src, "Choose a celestial weapon to manifest.", "Master of Arms") as null|anything in available
		if(!choice) return
		var/chosen_path = available[choice]
		if(!chosen_path) continue
		if(locate(chosen_path) in src.contents)
			src << "<font color='#ffe4b5'>You already possess that weapon. Choose another.</font>"
			continue
		src.GrantCelestialWeapon(chosen_path)
		return

obj/Skills/Utility/Recall_Celestial_Armaments
	verb/Recall_Celestial_Armaments()
		set category="Utility"
		set name = "Recall Celestial Armaments"
		if(usr.Dead && !usr.KeepBody)
			usr << "You cannot summon divine artifacts while dead."
			return
		for(var/obj/Items/Sword/Celestial/S in world)
			if(S.Owner == usr.key && !(S in usr.contents))
				S.Move(usr)
				S.Ascended = usr.AscensionsAcquired
				usr << "<font color='#ffe4b5'><b>[S.name]</b></font> returns to your side in a flash of light!"
		for(var/obj/Items/Enchantment/Staff/Celestial/S in world)
			if(S.Owner == usr.key && !(S in usr.contents))
				S.Move(usr)
				S.Ascended = usr.AscensionsAcquired
				usr << "<font color='#ffe4b5'><b>[S.name]</b></font> returns to your side in a flash of light!"
		OMsg(usr, "[usr] calls their sacred armaments home in a blaze of divine light!")

// =============================================
// SWORDS - CELESTIAL BASE
// =============================================
/obj/Items/Sword/Celestial
	Stealable = 0
	Destructable = 0
	Augmented = 1
	ShatterCounter = 800
	ShatterMax = 800
	SubType = "Weapons"
	AlignEquip(mob/A, dontUnEquip = FALSE)
		src.Ascended = A.AscensionsAcquired
		..()
	ObjectUse(mob/Players/User=usr)
		if(src.suffix == "*Equipped (Armory)*")
			if(User.transActive && User.race && User.race.transformations && User.race.transformations[User.transActive] && User.race.transformations[User.transActive].type == /transformation/celestial/Master_of_Arms)
				User << "You cannot unequip armory weapons while Master of Arms is active!"
				return
			src.suffix = null
			if(current_passives)
				User.passive_handler.decreaseList(current_passives)
			return
		if(!src.suffix && User.passive_handler.Get("DivineArmory"))
			var/obj/Items/Sword/sord = User.EquippedSword()
			var/obj/Items/Enchantment/Staff/staf = User.EquippedStaff()
			if((sord && sord != src) || staf)
				src.Ascended = User.AscensionsAcquired
				src.suffix = "*Equipped (Armory)*"
				if(passives)
					current_passives = passives
					User.passive_handler.increaseList(passives)
				return
		..()

// =============================================
// SWORDS - LIGHT CLASS
// =============================================
	Light
		Light_Celestial_Blade_I
			name = "Zephyr's Edge"
			desc = "A sword so light that its blade is almost impossible to keep up with."
			icon = 'Lol_Sword_reg.dmi'
			Class = "Light"
			passives = list("Warping" = 1, "BlurringStrikes" = 1)
			spdAdd=1
			strAdd=1
			DamageEffectiveness = 1.025
			AccuracyEffectiveness = 0.9
			SpeedEffectiveness = 1.25
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Warping" = (User.Potential / 25), "BlurringStrikes" = 1 + (User.Potential / 25))
				..()
		Light_Celestial_Blade_II
			name = "Aurelius"
			desc = "Forged for the dance of single combat; never a blow wasted."
			icon = 'Lol_Sword_Red.dmi'
			Class = "Light"
			spdAdd=1
			strAdd=1
			passives = list("Duelist" = 1, "LikeWater" = 1)
			DamageEffectiveness = 1.025
			AccuracyEffectiveness = 0.9
			SpeedEffectiveness = 1.25
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Duelist" = 1 + (User.Potential / 25), "LikeWater" = 1 + (User.Potential / 25))
				..()

		Light_Celestial_Blade_III
			name = "Gemini Fang"
			desc = "Myriad strikes flow from its edge as naturally as breath."
			icon = 'willKnifev2.dmi'
			Class = "Light"
			spdAdd=1
			strAdd=1
			passives = list("DoubleStrike" = 1, "TripleStrike" = 1)
			DamageEffectiveness = 1.025
			AccuracyEffectiveness = 0.9
			SpeedEffectiveness = 1.25
			ObjectUse(mob/Players/User=usr)
				src.passives = list("DoubleStrike" = 1 + (User.Potential / 50), "TripleStrike" = (User.Potential / 50))
				..()

// =============================================
// SWORDS - MEDIUM CLASS
// =============================================
	Medium
		Medium_Celestial_Blade_I
			name = "Throne's Answer"
			desc = "A blade as reliable as judgment from on high."
			icon = 'Bone-Ish_Blade.dmi'
			Class = "Medium"
			strAdd=1
			offAdd=0.5
			defAdd=0.5
			passives = list("Half-Sword" = 1, "Zornhau" = 1)
			DamageEffectiveness = 1.05
			AccuracyEffectiveness = 0.875
			SpeedEffectiveness = 1
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Half-Sword" = 1 + (User.Potential / 50), "Zornhau" = 1 + (User.Potential / 50))
				..()
		Medium_Celestial_Blade_II
			name = "Soulkeeper"
			desc = "The spirit of its wielder flows through every strike."
			icon = 'Aestus_Estus.dmi'
			Class = "Medium"
			strAdd=1
			forAdd=1
			passives = list("SpiritSword" = 1, "HybridStrike" = 1)
			DamageEffectiveness = 1.05
			AccuracyEffectiveness = 0.875
			SpeedEffectiveness = 1
			ObjectUse(mob/Players/User=usr)
				src.passives = list("SpiritSword" = (User.Potential / 50), "HybridStrike" = 1 + (User.Potential/50))
				..()
		Medium_Celestial_Blade_III
			name = "Pillar of Dawn"
			desc = "Unyielding as heaven's will, steady as the morning sun."
			icon = 'Fanta-sword.dmi'
			Class = "Medium"
			strAdd=1
			endAdd=1
			passives = list("Steady" = 1, "Momentum" = 1)
			DamageEffectiveness = 1.05
			AccuracyEffectiveness = 0.875
			SpeedEffectiveness = 1
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Steady" = (User.Potential / 10), "Momentum" = 1 + (User.Potential / 25))
				..()

// =============================================
// SWORDS - HEAVY CLASS
// =============================================
	Heavy
		Heavy_Celestial_Blade_I
			name = "Dawnbreaker"
			desc = "Its sweeping arc clears the field like the sun burns away shadow."
			icon = 'MONADO.dmi'
			Class = "Heavy"
			passives = list("SweepingStrike" = 1, "GiantForm" = 1)
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.8
			SpeedEffectiveness = 0.8
			strAdd=1
			endAdd=1
			ObjectUse(mob/Players/User=usr)
				src.passives = list("SweepingStrike" = 1, "GiantForm" = 1)
				..()
		Heavy_Celestial_Blade_II
			name = "Longarm of Heaven"
			desc = "Its reach extends Heaven's judgment."
			icon = 'Vile Hammer Vortigern.dmi'
			Class = "Heavy"
			strAdd=1
			endAdd=1
			passives = list("Extend" = 1, "Gum Gum" = 1)
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.8
			SpeedEffectiveness = 0.8
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Extend" = 1 + (User.Potential / 50), "Gum Gum" = 1 + (User.Potential / 50))
				..()
		Heavy_Celestial_Blade_III
			name = "Wrath Incarnate"
			desc = "Heaven's fury given an edge; mercy is not its purpose."
			icon = 'Ragnarok Blade Forme.dmi'
			Class = "Heavy"
			strAdd = 2
			passives = list("Brutalize" = 1, "KillerInstinct" = 0.1)
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.8
			SpeedEffectiveness = 0.8
			ObjectUse(mob/Players/User=usr)
				src.passives = list("Brutalize" = 1 + (User.Potential / 25), "KillerInstinct" = 0.1 + (User.Potential / 110))
				..()

// =============================================
// STAVES - CELESTIAL BASE
// =============================================
/obj/Items/Enchantment/Staff/Celestial
	Stealable = 0
	Destructable = 0
	Augmented = 1
	ShatterCounter = 800
	ShatterMax = 800
	SubType = "Spell Focii"
	AlignEquip(mob/A, dontUnEquip = FALSE)
		src.Ascended = A.AscensionsAcquired
		..()
	ObjectUse(mob/Players/User=usr)
		if(src.suffix == "*Equipped (Armory)*")
			if(User.transActive && User.race && User.race.transformations && User.race.transformations[User.transActive] && User.race.transformations[User.transActive].type == /transformation/celestial/Master_of_Arms)
				User << "You cannot unequip armory weapons while Master of Arms is active!"
				return
			src.suffix = null
			if(current_passives)
				User.passive_handler.decreaseList(current_passives)
			return
		if(!src.suffix && User.passive_handler.Get("DivineArmory"))
			var/has_weapon = User.EquippedSword() || User.EquippedStaff()
			if(has_weapon)
				src.Ascended = User.AscensionsAcquired
				src.suffix = "*Equipped (Armory)*"
				if(passives)
					current_passives = passives
					User.passive_handler.increaseList(passives)
				return
		..()

// =============================================
// STAVES - WAND CLASS
// =============================================
	Wand
		Celestial_Wand_I
			name = "Starling Blade"
			desc = "Spells leave it before the thought has finished forming."
			icon = 'Slaughter Demon LH.dmi'
			Class = "Wand"
			forAdd = 1
			spdAdd = 1
			passives = list("QuickCast" = 1, "Speed Force" = 1)
			DamageEffectiveness = 0.95
			AccuracyEffectiveness = 1.2
			SpeedEffectiveness = 1.2
			ObjectUse(mob/Players/User=usr)
				src.passives = list("QuickCast" = (User.Potential / 25), "Speed Force" = (User.Potential / 50))
				..()
		Celestial_Wand_II
			name = "Wellspring"
			desc = "Draws deeply from the divine current that flows through all things."
			icon = 'Playful Cloud.dmi'
			Class = "Wand"
			forAdd = 1
			offAdd = 0.5
			defAdd = 0.5
			passives = list("ManaStats" = 1, "ManaCapMult" = 0.1)
			DamageEffectiveness = 0.95
			AccuracyEffectiveness = 1.2
			SpeedEffectiveness = 1.2
			ObjectUse(mob/Players/User=usr)
				src.passives = list("ManaStats" = (User.Potential / 10), "ManaCapMult" = (User.Potential / 10))
				..()
		Celestial_Wand_III
			name = "Ember of Elysium"
			desc = "Burns with a sacred flame that consumes the unworthy."
			icon = 'Straw Doll - Hammer.dmi'
			Class = "Wand"
			passives = list("SoulFire" = 1, "DeathField" = 1)
			forAdd = 1
			endAdd = 1
			DamageEffectiveness = 0.95
			AccuracyEffectiveness = 1.2
			SpeedEffectiveness = 1.2
			ObjectUse(mob/Players/User=usr)
				src.passives = list("SoulFire" = 1 + (User.Potential / 25), "DeathField" = (User.Potential / 10))
				..()


// =============================================
// STAVES - ROD CLASS
// =============================================
	Rod
		Celestial_Rod_I
			name = "The Undercurrent"
			desc = "Channels spiritual energies with effortless, flowing precision."
			icon = 'Gae Bolg.dmi'
			Class = "Rod"
			forAdd = 1
			endAdd = 0.5
			spdAdd = 0.5
			passives = list("SpiritFlow" = 1, "MovingCharge" = 1)
			DamageEffectiveness = 1
			AccuracyEffectiveness = 1
			SpeedEffectiveness = 0.85
			ObjectUse(mob/Players/User=usr)
				src.passives = list("SpiritFlow" = 1 + (User.Potential / 25), "MovingCharge" = 1)
				..()
		Celestial_Rod_II
			name = "Siphon of Aethon"
			desc = "Drinks the enemy's power and makes it your own."
			icon = 'Gungir Type.dmi'
			Class = "Rod"
			forAdd = 1
			endAdd = 1
			passives = list("ManaSteal" = 5, "Siphon" = 1)
			DamageEffectiveness = 1
			AccuracyEffectiveness = 1
			SpeedEffectiveness = 0.85
			ObjectUse(mob/Players/User=usr)
				src.passives = list("ManaSteal" = 5 + (User.Potential / 2), "Siphon" = 1 + (User.Potential / 25))
				..()
		Celestial_Rod_III
			name = "The Pale Axis"
			desc = "Bends the space around it, forming a field of null energy."
			icon = 'Murakumogiri .dmi'
			Class = "Rod"
			forAdd = 1
			endAdd = 1
			passives = list("VoidField" = 1, "SoftStyle" = 1)
			DamageEffectiveness = 1
			AccuracyEffectiveness = 1
			SpeedEffectiveness = 0.85
			ObjectUse(mob/Players/User=usr)
				src.passives = list("VoidField" = (User.Potential / 10), "SoftStyle" = 1 + (User.Potential / 25))
				..()

// =============================================
// STAVES - STAFF CLASS
// =============================================
	Staff_Class
		Celestial_Staff_I
			name = "Voice of the Storm"
			desc = "Those struck by its power hear thunder long after the blow."
			icon = 'Spirit Sword.dmi'
			Class = "Staff"
			passives = list("ThunderHerald" = 1, "CriticalChance" = 5, "CriticalDamage" = 0.05)
			forAdd = 1
			strAdd = 0.5
			spdAdd = 0.5
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.85
			SpeedEffectiveness = 0.65
			ObjectUse(mob/Players/User=usr)
				src.passives = list("ThunderHerald" = 1, "CriticalChance" = 5 + (User.Potential / 4), "CriticalDamage" = (User.Potential / 200))
				..()
		Celestial_Staff_II
			name = "Rime Throne"
			desc = "Carries the cold stillness of heaven's highest peaks."
			icon = 'MHLS.dmi'
			Class = "Staff"
			forAdd = 2
			passives = list("IceHerald" = 1, "Chilling" = 4, "IceAge" = 30)
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.85
			SpeedEffectiveness = 0.65
			ObjectUse(mob/Players/User=usr)
				src.passives = list("IceHerald" = 1, "Chilling" = 1 + (User.Potential / 20), "IceAge" = 30 + (User.Potential / 5))
				..()
		Celestial_Staff_III
			name = "Pact of the Exalted"
			desc = "Forged where divine power meets the abyss; dangerous to all."
			icon = 'Yoru.dmi'
			Class = "Staff"
			forAdd = 1
			strAdd = 1
			passives = list("DemonicInfusion" = 1, "AbyssMod" = 1)
			DamageEffectiveness = 1.1
			AccuracyEffectiveness = 0.85
			SpeedEffectiveness = 0.65
			ObjectUse(mob/Players/User=usr)
				src.passives = list("DemonicInfusion" = 1, "AbyssMod" = 1 + (User.Potential / 25))
				..()

// Master of Arms Warp Strike - Heavy Strike replacement that fires a homing weapon throw and teleports behind target on hit
obj/Skills/Projectile
	Warp_Strike_MasterOfArms
		name = "Divine Warp Strike"
		Homing = 1
		IconLock = 'Blast2.dmi'
		Variation = 4
		Distance = 25
		Deflectable = FALSE
		DamageMult = 6
		WarpUser = 1
		WarpUserBehind = 1
		WarpUserFlashChange = 1
		ProjectileSpin = 40
		Cooldown = 30
		EnergyCost = 5

// WarpPoint timed buff - granted when Divine Warp Strike projectile hits an enemy
// Provides the WarpPoint passive for 30 seconds. On expiry, clears the saved warp location.
obj/Skills/Buffs/SlotlessBuffs/Autonomous/WarpPoint_Buff
	name = "Warp Point"
	Cooldown = 1
	AlwaysOn = 1
	NeedsPassword = 1
	passives = list("WarpPoint" = 1)
	TimerLimit = 30
	ActiveMessage = "locks in a warp point!"
	OffMessage = "loses their warp point."
	HandleBuffDeactivation(mob/source)
		if(source)
			source.warp_strike_saved_loc = null
		..()

// Flashback - auto-triggered on a successful grab while the WarpPoint passive is active.
// Deals minor damage to the grabbed target and teleports the user back to their saved warp location.
obj/Skills/Grapple/Flashback
	name = "Flashback"
	Cooldown = 0
	DamageMult = 4
	StrRate = 1
	ThrowMult = 0
	ThrowAdd = 0
	UnarmedOnly = 0
	TriggerMessage = "flashes back to their warp point, leaving"
	proc/FlashbackTrigger(mob/User, mob/Target)
		if(!User || !Target || !User.warp_strike_saved_loc)
			return
		var/userPower = User.getPower(Target)
		var/statPower = User.getStatDmg2(unarmed=1) * StrRate
		var/endFactor = Target.getEndStat(1)
		var/Damage = (userPower**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.GRAPPLE_EFFECTIVNESS) ** -(endFactor**glob.DMG_END_EXPONENT / statPower**glob.DMG_STR_EXPONENT)
		Damage *= User.GetDamageMod()
		Damage *= DamageMult
		var/extra = User.passive_handler.Get("Muscle Power") / glob.MUSCLE_POWER_DIVISOR
		Damage *= (glob.GRAPPLE_MELEE_BOON + extra)
		Damage *= glob.GRAPPLE_DAMAGE_MULT
		User.DoDamage(Target, Damage, 1, 0)
		OMsg(User, "[User] [TriggerMessage] [Target] behind!")
		var/turf/dest = User.warp_strike_saved_loc
		if(Target.grabbed == User)
			Target.grabbed = null
		if(User.Grab == Target)
			User.Grab = null
		// Flash white, teleport, then fade the glow back out - mirroring WarpUserFlashChange
		animate(User, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=2)
		sleep(2)
		User.loc = dest
		User.warp_strike_restore_color()
