/*
essentially check if we are -on update x, if not, update to x, if so, do nothing
*/

// make it so on world load we make the current version datum and use it for all people
proc/generateVersionDatum()
	var/update/updateversion
	for(var/i in subtypesof(/update/))
		var/update/check = new i
		if(updateversion && check.version > updateversion.version)
			updateversion = check
		else if (!updateversion)
			updateversion = check
	if(updateversion)
		glob.currentUpdate = updateversion

globalTracker
	var/UPDATE_VERSION = 19
	var/tmp/update/currentUpdate

	proc/updatePlayer(mob/p)
		if(!p.updateVersion)
			var/updateversion = "/update/version[UPDATE_VERSION]"
			p.updateVersion = new updateversion
			p.updateVersion.updateMob(p)	
		if(UPDATE_VERSION == p.updateVersion.version)
			return
		if(p.updateVersion.version + 1 == UPDATE_VERSION)
			var/updateversion = "/update/version[p.updateVersion.version + 1]"
			var/update/update = new updateversion
			update.updateMob(p)
		else if(p.updateVersion.version + 1 < UPDATE_VERSION)
			for(var/x in 1 to abs(p.updateVersion.version - UPDATE_VERSION))
				// get the number of updates we are missing
				var/updateversion = "/update/version[p.updateVersion.version + 1]"
				var/update/update = new updateversion
				update.updateMob(p)


mob/var/update/updateVersion

update
	var/version = 1

	proc/updateMob(mob/p)
		p << "You have been updated to version [version]"
		p.updateVersion = src

	version1

	version2
		version = 2
		updateMob(mob/p)
			. = ..()
			if(p.isRace(BEASTMAN))
				switch(p.race?:Racial)
					if("Unseen Predator")
						p.passive_handler.passives["Heavy Strike"] = "Unseen Predator"
					if("Trickster")
						p.Imagination = 2
						p.Intelligence = 1
					if("Feather Knife")
						p.passive_handler.passives["SwordPunching"] = 1
					if("Feather Cowl")
						p.passive_handler.passives["SwordPunching"] = 1
		
	version3
		version = 3
		updateMob(mob/p)
			. = ..()
			for(var/obj/Skills/Buffs/NuStyle/ms in src)
				if(istype(ms, /obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker))
					ms.BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield")
				if(istype(ms, /obj/Skills/Buffs/NuStyle/SwordStyle/Sword_Savant))
					ms.passives = list("SwordPunching" = 1, "SwordDamage" = 1, "NeedsSword" = 0, "Sword Master" = 1)
				
				
			if(p.isRace(HUMAN))
				p.RPPMult = 1.25
	version4
		version = 4
		updateMob(mob/p)
			. = ..()
			if(p.isRace(BEASTMAN))
				switch(p.race?:Racial)
					if("Unseen Predator")
						p.passive_handler.passives["Heavy Strike"] = "Unseen Predator"
					if("Trickster")
						p.Imagination = 2
						p.Intelligence = 1
					if("Feather Knife")
						p.passive_handler.passives["SwordPunching"] = 1
					if("Feather Cowl")
						p.passive_handler.passives["SwordPunching"] = 1
			for(var/obj/Skills/Buffs/NuStyle/ms in src)
				if(istype(ms, /obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker))
					ms.BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield")
				if(istype(ms, /obj/Skills/Buffs/NuStyle/SwordStyle/Sword_Savant))
					ms.passives = list("SwordPunching" = 1, "SwordDamage" = 1, "NeedsSword" = 0, "Sword Master" = 1)
				
		
				
			if(p.isRace(HUMAN))
				p.RPPMult = 1.25
	version5
		version = 5
		updateMob(mob/p)
			. = ..()
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style/d in p)
				if(p.BuffOn(d))
					d.Trigger(p)
				d.passives["Disarm"] = 1.5
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Gladiator_Style/d in p)
				if(p.BuffOn(d))
					d.Trigger(p)
				d.passives["Disarm"] = 1
			p.information.resetRanking()
			p.information.title = list()

	version6
		version = 6
		updateMob(mob/p)
			. = ..()
			for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style/turtle in p)
				turtle.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shaolin_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style",\
		"/obj/Skills/Buffs/NuStyle/MysticStyle/Fire_Weaving"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Black_Leg_Style")
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Gladiator_Style/gladiator in p)
				gladiator.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fencing_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style",\
        "/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style")
			for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Black_Leg_Style/black_leg in p)
				black_leg.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Mantis_And_Crane_Style", \
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Magma_Walker"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ifrit_Jambe")
			for(var/obj/Skills/Buffs/NuStyle/MysticStyle/Plague_Bringer/pb in p)
				pb.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Circuit_Breaker_Style")
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style/is in p)
				is.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu")
			if(p.isRace(ANDROID))
				p.AddSkill(new/obj/Skills/Utility/Cybernetic_Augmentation)
	version7
		version = 7
		updateMob(mob/p)
			. = ..()
			if(p.information.rankingNumber==0)
				p.information.resetRanking()
			p.information.title = list()
			if(p.isRace(GAJALAKA))
				switch(p.Class)
					if("Acolyte")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Acolyte)
					if("Rebel")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Rebel)
					if("Nobility")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Noble)
						p.passive_handler.Set("MartialMagic", 1)
					if("Heart")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_Liberation)
			var/obj/Skills/Buffs/NuStyle/water = p.FindSkill(/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending)
			if(water)
				water.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/MysticStyle/Earth_Moving"="/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing",\
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Wind_Summoning"="/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer", \
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Plague_Bringer"="/obj/Skills/Buffs/NuStyle/MysticStyle/Bloodmancer")
			var/obj/Skills/Buffs/NuStyle/plague = p.FindSkill(/obj/Skills/Buffs/NuStyle/MysticStyle/Plague_Bringer)
			if(plague)
				plague.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Circuit_Breaker_Style", \
							"/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending"="/obj/Skills/Buffs/NuStyle/MysticStyle/Bloodmancer")
	version8
		version = 8
		updateMob(mob/p)
			. = ..()
			if(p.isRace(GAJALAKA))
				switch(p.Class)
					if("Acolyte")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Acolyte)
					if("Rebel")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Rebel)
					if("Nobility")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Noble)
						p.passive_handler.Set("MartialMagic", 1)
					if("Heart")
						p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_Liberation)
			if(p.isRace(NAMEKIAN))
				if(p.Class == "Dragon")
					p.AddSkill(new/obj/Skills/Utility/Send_Energy)
	version9
		version = 9
		updateMob(mob/p)
			. = ..()
			for(var/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing/id in p)
				id.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Blizzard_Bringer",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Hot_n_Cold")
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style/nis in p)
				nis.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu")
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style/ds in p)
				ds.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu"="/obj/Skills/Buffs/NuStyle/SwordStyle/Phalanx_Style")
			for(var/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu/fok in p)
				fok.StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Phalanx_Style", \
		"/obj/Skills/Buffs/NuStyle/SwordStyle/Kunst_des_Fechtens"="/obj/Skills/Buffs/NuStyle/SwordStyle/Witch_Hunter",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Divine_Arts_of_The_Heavenly_Demon",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Phoenix_Eye_Fist")
			for(var/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker/mw in p)
				mw.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Plasma_Style",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Hellfire")
			for(var/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer/sb in p)
				sb.StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Plasma_Style",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Blizzard_Bringer")

	version10
		version = 10
		updateMob(mob/p)
			. = ..()
			if(p.isRace(GAJALAKA))
				if(p.Class == "Rebel")
					p.passive_handler.Set("SwordPunching", 1)
			p.stat_redo()
			var/list/statMods = list("Str", "Spd", "End", "For", "Off","Def")
			switch(p.Saga)
				if("Keyblade")
					p.KeybladePath = input(p, "Keyblade magic path?") in list("Fire", "Ice", "Thunder")
					var/list/magicks2remove = list("/obj/Skills/Projectile/Magic/Fira","/obj/Skills/AutoHit/Magic/Blizzara", \
						"/obj/Skills/AutoHit/Magic/Thundara", "/obj/Skills/AutoHit/Magic/Stop", "/obj/Skills/AutoHit/Magic/Gravity", \
						"/obj/Skills/AutoHit/Magic/Magnet", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Blizzard", "/obj/Skills/Projectile/Magic/Thunder")

					for(var/x in magicks2remove)
						var/obj/Skills/s = p.FindSkill(x)
						p.contents -= s
						p << "[s] removed."
						del s
					switch(p.KeybladePath)
						if("Fire")
							p.AddSkill(new/obj/Skills/Projectile/Magic/Fira)
							p.AddSkill(new/obj/Skills/Projectile/Magic/Firaga)
						if("Ice")
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzara)
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzaga)
						if("Thunder")
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Thundara)
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Thundaga)
				if("Weapon Soul")
					if(p.BoundLegend == "Green Dragon Crescent Blade")
						p.passive_handler.Increase("Extend")
						
			for(var/x in statMods)
				p.vars["[x]Ascension"] = 0
	version11
		version = 11
		updateMob(mob/p)
			. = ..()
			if(p.isRace(HALFSAIYAN))
				p.stat_redo()
				p.race.fixAscensions()
			if(p.isRace(GAJALAKA))
				p.race.fixAscensions()
			var/obj/Skills/s = p.FindSkill(/obj/Skills/Queue/Larch_Dance)
			if(s)
				p << "Larch Dance removed."
				del s
				p.RPPSpendable += TIER_2_COST
				p.RPPSpent -= TIER_2_COST
	
	version12
		version = 12
		updateMob(mob/p)
			. = ..()
			if(p.isRace(GAJALAKA))
				p.race.fixAscensions()
	version13
		version = 13
		updateMob(mob/p)
			. = ..()
			switch(p.Saga)
				if("Keyblade")
					p.KeybladePath = input(p, "Keyblade magic path?") in list("Fire", "Ice", "Thunder")
					var/list/magicks2remove = list("/obj/Skills/Projectile/Magic/Fira","/obj/Skills/AutoHit/Magic/Blizzara", \
						"/obj/Skills/AutoHit/Magic/Thundara", "/obj/Skills/AutoHit/Magic/Stop", "/obj/Skills/AutoHit/Magic/Gravity", \
						"/obj/Skills/AutoHit/Magic/Magnet", "/obj/Skills/Projectile/Magic/Fire", "/obj/Skills/Projectile/Magic/Blizzard", "/obj/Skills/Projectile/Magic/Thunder")

					for(var/x in magicks2remove)
						var/obj/Skills/s = p.FindSkill(x)
						p.contents -= s
						p << "[s] removed."
						del s
					switch(p.KeybladePath)
						if("Fire")
							p.AddSkill(new/obj/Skills/Projectile/Magic/Fira)
							p.AddSkill(new/obj/Skills/Projectile/Magic/Firaga)
						if("Ice")
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzara)
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzaga)
						if("Thunder")
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Thundara)
							p.AddSkill(new/obj/Skills/AutoHit/Magic/Thundaga)
	version14
		version = 14
		updateMob(mob/p)
			. = ..()
			for(var/obj/Skills/Buffs/NuStyle/style in p)
				var/name = style.name
				if(style == p.StyleBuff)
					style.Trigger(p, TRUE)
				var/styletype = style.type
				del style
				p.AddSkill(new styletype)
				var/obj/Skills/Buffs/NuStyle/newstyle = p.FindSkill(styletype)
				newstyle.name = name
	version15
		version = 15
		updateMob(mob/o)
			. = ..()
			if(o.Saga == "King of Braves")
				var/obj/Skills/s = o.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Plasma_Hold)
				if(s)
					del s
				o.findOrAddSkill(new/obj/Skills/AutoHit/Plasma_Hold)
	version16
		version = 16
		updateMob(mob/o)
			. = ..()
			if(o.isRace(MAKYO))
				o.passive_handler.Set("ShonenPower", 0)
			if(o.isRace(HUMAN))
				if(o.passive_handler["ShonenPower"] < 0.3)
					o.passive_handler.Set("ShonenPower", 0.3)
	version17
		version = 17
		updateMob(mob/o)
			. = ..()
			o.SignatureStyles = list()
	version18
		version = 18
		updateMob(mob/o)
			. = ..()
			if(o.isRace(BEASTMAN))
				o.AngerMax+=0.15
				if(o.Class=="Undying Rage")
					o.AngerMax+=0.4
					o.passive_handler.Set("Wrathful Tenacity", 0.45)
			if(o.isRace(MAKYO))
				var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = o.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
				if(ki)
					ki.AngerStorage=0
				o.AngerMax = 1.5
			
			if(o.isRace(HUMAN))
				o.passive_handler.Decrease("TechniqueMastery", 1.5)
			if(o.isRace(HALFSAIYAN))
				o.passive_handler.Decrease("TechniqueMastery", 2)
	version19
		version = 19
		updateMob(mob/o)
			. = ..()
			if(o.isRace(YOKAI))
				o.passive_handler.Set("Touch of Death", 3)
				o.AddSkill(new/obj/Skills/AutoHit/Mist_Form)
	version20
		version = 20
		updateMob(mob/o)
			. = ..()
			if(o.isRace(BEASTMAN))
				o.AngerMax=1.65
				if(o.Class=="Undying Rage")
					o.AngerMax=2.05
			if(o.isRace(NAMEKIAN))
				o.stat_redo()
			o.passive_handler.Decrease("KiControlMastery",1)
	version21
		version = 21
		updateMob(mob/o)
			. = ..()
			if(o.isRace(BEASTMAN))
				o.AngerMax=1.65
				if(o.Class=="Undying Rage")
					o.AngerMax=2.05
/globalTracker/var/COOL_GAJA_PLAYERS = list("Thorgigamax", "Gemenilove" )
/globalTracker/var/GAJA_PER_ASC_CONVERSION = 0.25
/globalTracker/var/GAJA_MAX_EXCHANGE = 1

/mob/proc/gajaConversionCheck()
	if(key in glob.COOL_GAJA_PLAYERS)
		verbs += /mob/proc/ExchangeMinerals

/mob/proc/gajaConversionRateUpdate()
	if(isRace(GAJALAKA) && key in glob.COOL_GAJA_PLAYERS)
		var/asc = AscensionsAcquired
		var/ascRate = 0.5 + (glob.GAJA_PER_ASC_CONVERSION * asc) // 1.25 max
		for(var/obj/Money/moni in src)
			if(moni.Level >= 10000)
				var/boon = round(moni.Level * 0.00001, 0.1)
				if(boon > glob.GAJA_MAX_EXCHANGE) // so 1.75 total
					boon = glob.GAJA_MAX_EXCHANGE
				playerExchangeRate = ascRate + boon

