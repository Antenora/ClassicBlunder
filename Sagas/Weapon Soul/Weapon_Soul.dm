mob/proc/gainWeaponSoul()
	src << "You feel your soul resonate with a weapon..."
	src.Saga="Weapon Soul"
	src.SagaLevel=1
	src.AddSkill(new/obj/Skills/Buffs/ActiveBuffs/Weapon_Soul)
	var/list/openSwords = glob.WeaponSoulNames
	if(!glob.infWeaponSoul)
		openSwords = glob.getOpen("WeaponSoul")
		if(openSwords.len<1)
			glob.ResetSwords()
	WeaponSoulType = input("Which sword resonates with your soul?") in openSwords
	BoundLegend = WeaponSoulType
	src << "[WeaponSoulType] manifests within your grip, peerless and refined..."
	switch(WeaponSoulType)
		if("Kusanagi")
			new/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith(src)
			src << "You feel your ability to strike with the force of the wind increase with the faint whisper of Gale Slash.."
			src.AddSkill(new/obj/Skills/AutoHit/Gale_Slash)

		if("Durendal")
			new/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope(src)
			src << "You feel your ability to strike with the force of fire increase with the faint whisper of Blazing Slash.."
			src.AddSkill(new/obj/Skills/Queue/Blazing_Slash)

		if("Dainsleif")
			new/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin(src)
			src << "You feel Dainsleif ebb in your hand, letting you unleash ruinous power with it's Cursed Blade..."
			src.AddSkill(new/obj/Skills/Queue/Cursed_Blade)
			AddSkill(new/obj/Skills/Queue/Blood_Craving)

		if("Caledfwlch")
			new/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory(src)
			src << "You feel the ability to invoke an almighty beam rise up, shooting through your veins with a cry of Excalibur!"
			AddSkill(new/obj/Skills/Queue/Excalibur)

		if("Muramasa")
			new/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades(src)
			src << "You feel your ability to bring anything's death to reality with Deathbringer..."
			AddSkill(new/obj/Skills/AutoHit/Deathbringer)

		if("Masamune")
			new/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity(src)
			src << "You feel Masamune whisper the secrets on how to dispel impurities from the body with Divine Cleansing..."
			AddSkill(new/obj/Skills/AutoHit/Divine_Cleansing)

		if("Soul Calibur")
			new/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order(src)
			src << "You feel the power of Order refine itself to allow you to envelop your opponent in a Crystal Tomb."
			AddSkill(new/obj/Skills/AutoHit/Crystal_Tomb)

		if("Soul Edge")
			new/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos(src)
			src << "You feel like you could rip at someone's very soul and drain it with Soul Drain."
			AddSkill(new/obj/Skills/AutoHit/Soul_Drain)

		if("Ryui Jingu Bang")
			new/obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang(src)

		if("Green Dragon Crescent Blade")
			new/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War(src)
			AddSkill(new/obj/Skills/AutoHit/War_God_Descent)

mob/tierUpSaga(Path)
	..()
	if(Path == "Weapon Soul")
		switch(SagaLevel)
			if(2)
				switch(BoundLegend)
					if("Kusanagi")
						src << "Yata No Kagami lends it's mirrored frame to you, promising to reflect any attacks."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Protection)
						src.AddSkill(new/obj/Skills/Yata_no_Kagami/Mirror_Prison)
						src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Imperial_Heritage)

					if("Durendal")
						src << "A horn made of some unidentified substance manifests in your hand, an Oilphant."
						passive_handler.Increase("TeamFighter")
						src.AddSkill(new/obj/Skills/AutoHit/Blow_The_Horn)
						src.AddSkill(new/obj/Skills/Companion/PlayerCompanion/Squad/Oilphant)


					if("Dainsleif")
						src << "Dainsleif's sheath grows with the power of the damage you inflict on others. . ."
						passive_handler.Increase("CursedSheath")
						AddSkill(new/obj/Skills/AutoHit/Destined_Death)
						src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Might_of_Dainn)

					if("Caledfwlch")
						src << "A sheath manifests in your soul, capable of healing any injuries; Avalon."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Avalon)
						src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Knight_Of_Camelot)

					if("Muramasa")
						src << "The blade of assured Death whispers the arts of Death to you..."
						passive_handler.Increase("CriticalChance", 5)
						passive_handler.Increase("CriticalDamage", 0.2)
						AddSkill(new/obj/Skills/AutoHit/Masterful_Death)

					if("Masamune")
						src << "A sheath made of snow itself manifests by your side."
						for(var/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity/masamune in contents)
							masamune.Element = "Light"
						src.AddSkill(new/obj/Skills/AutoHit/Purifying_Frost)

					if("Soul Edge")
						src << "Soul Edge's chaotic power crawls up your frame...!"
						passive_handler.Increase("Reversal", 0.5)
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Symbiotic_Edge)
						src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Stained_Memories)

					if("Soul Calibur")
						src << "Soul Calibur's Order becomes far easier to sink into..."
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Defrost)
						src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Soul_Conviction)

					if("Ryui Jingu Bang")
						src << "Yeoui unveils the secrets to proper footwork..."
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Dadao)
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Huadong)
						passive_handler.Set("MonkeyKing", 1)

					if("Green Dragon Crescent Blade")
						src << "The Green Dragon Crescent Blade unveils the secrets to an unstoppable rush..."
						passive_handler.Increase("Flow")
						passive_handler.Increase("Extend")
						// SagaThreshold("Spd",2)


			if(3)
				switch(WeaponSoulType)
					if("Kusanagi")
						src << "Yasakani no Magatama manifests, a sacred bead capable of restraining your enemies..."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Yasakani_no_Magatama/Bead_Constraint)
						passive_handler.Increase("YataNoKagami")

					if("Durendal")
						src << "The relics embedded deep within Durendal's nature become apparent...!"
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Tooth)
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Blood)
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Raiment)
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Hair)

					if("Dainsleif")
						src << "Niohoggr's Chains offer themselves to your cause, capable of binding down even the quickest foes..."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Niohoggrs_Chains)

					if("Caledfwlch")
						src << "A set of Armor coats your frame, allowing you to weather the strongest of blows."
						src.contents += new/obj/Items/Armor/Plated_Armor/Noble_Armor
						AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Noble_Shield)
						AddSkill(new/obj/Skills/AutoHit/True_Excalibur)

					if("Muramasa")
						src << "Muramasa makes your body become a little closer to a demon's..."
						for(var/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades/muramasa in contents)
							muramasa.Element = "Dark"
							muramasa.passives = list("WeaponBreaker" = 2, "AbyssMod" = 4)
						passive_handler.Increase("PureDamage",2)
						// SagaThreshold("Spd",1)
						// SagaThreshold("Str",1)

					if("Masamune")
						src << "The hilt of Masamune glitters in the light, offering it's blessed nature to aid your attacks..."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Blessed_Guard)
						passive_handler.Increase("RefreshingBlows")

					if("Soul Edge")
						src << "An eye opens up on Soul Edge's hilt, peering out..."
						AddSkill(new/obj/Skills/AutoHit/Gaze_of_Despair)
						src << "Soul Edge trembles with an eager, dark hunger. Dark Reconquista beckons."
						AddSkill(new/obj/Skills/AutoHit/Dark_Reconquista)

					if("Soul Calibur")
						src << "The manipulation of Soul Calibur's crystals becomes second nature..."
						AddSkill(new/obj/Skills/AutoHit/Crystal_Luminescene)

					if("Ryui Jingu Bang")
						passive_handler.Increase("MonkeyKing",2) // lets get a little freaky

					if("Green Dragon Crescent Blade")
						src << "The Green Dragon Crescent Blade shows how to counter any attack..."
						passive_handler.Increase("Reversal", 0.25)
						passive_handler.Increase("Adaptation")
						// SagaThreshold("Spd",0.5)
						// SagaThreshold("Str",0.5)
						// SagaThreshold("End",0.5)

			if(4)
				src << "The power of Heavenly Regalia becomes avaliable to you by resonating your treasures!"
				switch(WeaponSoulType)
					if("Kusanagi")
						src << "The power of Heavenly Regalia: The Three Treasures resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Kusanagi)

					if("Durendal")
						src << "The power of Heavenly Regalia: The Saint resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Durendal)

					if("Dainsleif")
						src << "The power of Heavenly Regalia: Ruined World resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Dainsleif)

					if("Caledfwlch")
						src << "The power of Heavenly Regalia: The King resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Caledfwlch)

					if("Muramasa")
						src << "The power of Heavenly Regalia: The Death resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Muramasa)

					if("Masamune")
						src << "The power of Heavenly Regalia: Blessed Blade resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Masamune)

					if("Soul Edge")
						src << "The power of Heavenly Regalia: Chaos Armament resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Edge)

					if("Soul Calibur")
						src << "The power of Heavenly Regalia: Frozen Crystal resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Calibur)

					if("Ryui Jingu Bang")
						src << "The power of Heavenly Regalia: Monkey King resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Ryui_Jingu_Bang)

					if("Green Dragon Crescent Blade")
						src << "The power of Heavenly Regalia: War King resonates in your body."
						src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Guan_Yu)


			if(5)
				src << "The power of Heavenly Regalia grows even stronger...!"

				switch(WeaponSoulType)
					if("Kusanagi")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Kusanagi/kusa in src.Buffs)
							kusa.passives["Godspeed"] = 2
							kusa.passives["Skimming"] = 2
							kusa.passives["HybridStrike"] = 1
							kusa.passives["SwordAscension"] = 1
							kusa.passives["ManaGeneration"] = 15
							kusa.passives["GodKi"] = 0.25

					if("Durendal")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Durendal/dura in src.Buffs)
							dura.passives["Juggernaut"] = 1
							dura.passives["Adrenaline"] = 1
							dura.passives["HolyMod"] = 2
							dura.passives["SwordAscension"] = 1
							dura.passives["GodKi"] = 0.25

					if("Dainsleif")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Dainsleif/dainsleif in src.Buffs)
							dainsleif.passives["Instinct"] = 4
							dainsleif.passives["Adrenaline"] = 1
							dainsleif.passives["AbyssMod"] = 4
							dainsleif.passives["SwordAscension"] = 1
							dainsleif.passives["GodKi"] = 0.25

					if("Caledfwlch")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Caledfwlch/caled in src.Buffs)
							caled.passives["Xenobiology"] = 1
							caled.passives["CriticalChance"] = 10
							caled.passives["CriticalDamage"] = 0.5
							caled.passives["Pursuer"] = 2
							caled.passives["GodKi"] = 0.25

					if("Muramasa")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Muramasa/muramasa in src.Buffs)
							muramasa.passives["KillerInstinct"] = 0.3
							muramasa.passives["DemonicDurability"] = 2
							muramasa.passives["TechniqueMastery"] = 2
							muramasa.passives["GodKi"] = 0.25

					if("Masamune")
						src.AddSkill(new/obj/Skills/Utility/Death_Killer)
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Masamune/masamune in src.Buffs)
							masamune.passives["Unstoppable"] = 1
							masamune.passives["LifeSteal"] = 10
							masamune.passives["HolyMod"] = 2
							masamune.passives["GodKi"] = 0.25

					if("Soul Edge")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Edge/SE in src.Buffs)
							SE.passives["HellPower"] = 1
							SE.passives["Burning"] = 2
							SE.passives["BurningShot"] = 1
							SE.passives["BurnHit"] = 15
							SE.passives["AngerAdaptiveForce"] = 0.15
							SE.passives["GodKi"] = 0.25
						src << "Soul Edge's conquering chaos takes form as a wave of ruin, Dark Reconquista: Triumph."
						AddSkill(new/obj/Skills/AutoHit/Dark_Reconquista_Triumph)

					if("Soul Calibur")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Calibur/SC in src.Buffs)
							SC.passives["Chilling"] = 2
							SC.passives["SpiritPower"] = 1
							SC.passives["GodKi"] = 0.25

					if("Ryui Jingu Bang")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Ryui_Jingu_Bang/Ryui in src.Buffs)
							Ryui.passives["FluidForm"] = 1
							Ryui.passives["StunningStrike"] = 1
							Ryui.passives["GodKi"] = 0.25

					if("Green Dragon Crescent Blade")
						for(var/obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Guan_Yu/GuanYu in src.Buffs)
							GuanYu.passives["Zornhau"] = 2
							GuanYu.passives["Iaijutsu"] = 2
							GuanYu.passives["GodKi"] = 0.25
			if(6)
				if(!locate(/obj/Skills/Buffs/SpecialBuffs/OverSoul, src))
					src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/OverSoul)
					src << "You've learned to unseal the true form of your legendary weapon."
			if(7)
				switch(WeaponSoulType)
					if("Kusanagi")
						src << "The Fundament of Faith: Belief answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Belief)

					if("Dainsleif")
						src << "The Fundament of Ruin: Hatred answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Hatred)

					if("Caledfwlch")
						src << "The Fundament of Glory: Honour answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Honour)

					if("Muramasa")
						src << "The Fundament of Death: Entropy answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Entropy)

					if("Masamune")
						src << "The Fundament of Purity: Life answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Life)

					if("Soul Edge")
						src << "The Fundament of Chaos: Freedom answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Freedom)

					if("Soul Calibur")
						src << "The Fundament of Order: Oppression answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Oppression)

					if("Ryui Jingu Bang")
						src << "The Fundament of the Staff: the Ocean answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Ocean)

					if("Green Dragon Crescent Blade")
						src << "The Fundament of War: Scarcity answers your Call."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Fundament/Scarcity)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia
	NeedsSword = 1
/obj/Skills/Buffs/SlotlessBuffs/Fundament
	NeedsSword = 1

	Belief
		name = "Fundament: Belief"
		StrMult=1.25
		SpdMult=2
		ForMult=1.25
		passives= list("DualCast" = 1, "QuickCast" = 2, "DoubleStrike"= 2 , "TripleStrike"= 2 , "AsuraStrike" = 1)
		ActiveMessage= "invokes the Origin of Faith, embracing Primordial Belief!"
		OffMessage= "casts aside the Origin of Faith..."
		verb/Fundament_Belief()
			set category="Skills"
			src.Trigger(usr)

	Honour
		name = "Fundament: Honour"
		StrMult=1.25
		ForMult=1.25
		EndMult=1.5
		passives= list("PureReduction"=2)
		ActiveMessage= "invokes the Origin of Glory, embracing the Honour of a King!"
		OffMessage= "casts aside the Origin of Glory..."
		verb/Fundament_Honour()
			set category="Skills"
			src.Trigger(usr)

	Hatred
		name = "Fundament: Hatred"
		StrMult=1.25
		SpdMult=1.25
		OffMult=1.25
		ActiveMessage= "invokes the Origin of Ruin, stewing in Primordial Hate!"
		OffMessage= "casts aside the Origin of Ruin..."
		passives= list("DeathField" = 5, "MaimStrike" = 1, "Duelist" = 3)
		verb/Fundament_Hatred()
			set category="Skills"
			src.Trigger(usr)

	Ocean
		name = "Fundament: The Ocean"
		verb/Fundament_Ocean()
			set category="Skills"
			src.Trigger(usr)

	Life
		name = "Fundament: Life"
		OffMult=1.5
		DefMult=1.5
		SpdMult=1.5
		passives = list("HolyMod"= 4, "LifeGeneration" = 1)
		ActiveMessage= "invokes the Origin of Purity, putting Life in their Embrace!"
		OffMessage= "casts aside the Origin of Purity..."
		verb/Fundament_Life()
			set category="Skills"
			src.Trigger(usr)

	Entropy
		name = "Fundament: Entropy"
		StrMult=1.5
		EndMult=0.9
		SpdMult=1.5
		passives = list("Erosion" = 0.5, "DeathField" = 5, "AbyssMod" = 3, "Entropic"=1)
		ActiveMessage= "invokes the Foundation of Death, bringing the End with their blade..:"
		OffMessage="allows the Entropic energy to fade from their legendary weapon..."
		verb/Fundament_Entropy()
			set category="Skills"
			src.Trigger(usr)

	Oppression
		name = "Fundament: Oppression"
		verb/Fundament_Oppression()
			set category="Skills"
			src.Trigger(usr)

	Freedom
		name = "Fundament: Freedom"
		StrMult=1.75
		EndMult=0.8
		SpdMult=1.5
		passives = list("HardStyle" = 4, "Godspeed" = 4, "Juggernaut" = 5)
		ActiveMessage= "invokes the Origin of Chaos, attaining Freedom from all Constraint!"
		verb/Fundament_Freedom()
			set category="Skills"
			src.Trigger(usr)

	Scarcity
		name = "Fundament: Scarcity"
		verb/Fundament_Scarcity()
			set category="Skills"
			src.Trigger(usr)