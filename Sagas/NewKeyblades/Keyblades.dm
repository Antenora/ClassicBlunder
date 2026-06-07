mob/Admin3/verb
	Grant_Keychain()
		set category="Debug"
		usr.ChooseKeychain()
	//	Log("Admin", "[ExtractInfo(usr)] unlocked a keychain for [ExtractInfo(m)]!")
	Grant_Martial_Skill()
		set category="Debug"
		usr.ChooseMartialSkill(1)
	//	Log("Admin", "[ExtractInfo(usr)] unlocked a Martial Keyblade Skill for [ExtractInfo(m)]!")

mob/proc/
/*	Drive_Mastery(var/Form)
		var/DrivePassives=list()
		switch(Form)
			if("Valor")
			if("Wisdom")
			if("Limit")
			if("Master")*/
	ChooseMartialSkill(var/Level)
		var/list/Choices
		var/confirm
		var/choice
		var/list/LV1=list("Sonic Blade", "Strike Raid", "Magnet Burst")
		var/list/LV2=list("Ripple Drive", "Stun Impact", "Explosion")
		var/list/LV3=list("Fire Surge", "Thunder Surge", "Ars Arcanum")
		var/list/LV4=list("Ragnarok", "Salvation", "Raging Storm")
		switch(Level)
			if(1)
				Choices+=LV1
			if(2)
				Choices+=LV2
			if(3)
				Choices+=LV3
			if(4)
				Choices+=LV4
		while(confirm!="Yes")
			choice=input(src, "What skill do you want?", "Martial Keyblade Skill") in Choices
			switch(choice)
				if("Sonic Blade")
					confirm=alert(src, "Quickly dash towards your opponent three times.", "Choice","Yes", "No")
				if("Strike Raid")
					confirm=alert(src, "Throw your Keyblade at your opponent in the form of an autohit wave.", "Choice","Yes", "No")
				if("Magnet Burst")
					confirm=alert(src, "A weak Area-Of-Effect move that pulls in everyone nearby and stuns.", "Choice","Yes", "No")
				if("Ripple Drive")
					confirm=alert(src, "Release a powerful wave of energy with a strong knockback.", "Choice","Yes", "No")
				if("Stun Impact")
					confirm=alert(src, "Queues up a stunning attack.", "Choice", "Yes", "No")
				if("Explosion")
					confirm=alert(src, "Queue up a weak hit that follows up with a powerful explosive one.", "Choice","Yes", "No")
				if("Fire Surge")
					confirm=alert(src, "Dash forward surrounded by flames, burning everything in your path.", "Choice","Yes", "No")
				if("Thunder Surge")
					confirm=alert(src, "Dash forward surrounded by lightning, shocking everything in your path.", "Choice","Yes", "No")
				if("Ars Arcanum")
					confirm=alert(src, "Queues a multi-hit combo finisher.", "Choice","Yes", "No")
				if("Ragnarok")
					confirm=alert(src, "Unleash a flurry of strikes that ends in a magical blast.", "Choice","Yes", "No")
				if("Salvation")
					confirm=alert(src, "A bright flash of light that damages foes and heals the caster.", "Choice","Yes", "No")
				if("Raging Storm")
					confirm=alert(src, "Spin in place, surrounding yourself with a storm of strikes.", "Choice","Yes", "No")
			switch(choice)
				if("Sonic Blade")
					if(!locate(/obj/Skills/AutoHit/Sonic_Blade, src))
						src.AddSkill(new/obj/Skills/AutoHit/Sonic_Blade)
					else if(locate(/obj/Skills/AutoHit/Sonic_Blade, src))
						for(var/obj/Skills/AutoHit/Sonic_Blade/R in src)
							R.UpgradedKeybladeSkill=1
				if("Strike Raid")
					if(!locate(/obj/Skills/AutoHit/Strike_Raid, src))
						src.AddSkill(new/obj/Skills/AutoHit/Strike_Raid)
					else if(locate(/obj/Skills/AutoHit/Strike_Raid, src))
						for(var/obj/Skills/AutoHit/Strike_Raid/R in src)
							R.UpgradedKeybladeSkill=1
				if("Magnet Burst")
					if(!locate(/obj/Skills/AutoHit/Magnet_Burst, src))
						src.AddSkill(new/obj/Skills/AutoHit/Magnet_Burst)
					else if(locate(/obj/Skills/AutoHit/Magnet_Burst, src))
						for(var/obj/Skills/AutoHit/Magnet_Burst/R in src)
							R.UpgradedKeybladeSkill=1
				if("Ripple Drive")
					if(!locate(/obj/Skills/AutoHit/Ripple_Drive, src))
						src.AddSkill(new/obj/Skills/AutoHit/Ripple_Drive)
					else if(locate(/obj/Skills/AutoHit/Ripple_Drive, src))
						for(var/obj/Skills/AutoHit/Ripple_Drive/R in src)
							R.UpgradedKeybladeSkill=1
				if("Stun Impact")
					if(!locate(/obj/Skills/Queue/Stun_Impact, src))
						src.AddSkill(new/obj/Skills/Queue/Stun_Impact)
					else if(locate(/obj/Skills/Queue/Stun_Impact, src))
						for(var/obj/Skills/Queue/Stun_Impact/R in src)
							R.UpgradedKeybladeSkill=1
				if("Explosion")
					if(!locate(/obj/Skills/Queue/Explosion, src))
						src.AddSkill(new/obj/Skills/Queue/Explosion)
					else if(locate(/obj/Skills/Queue/Explosion, src))
						for(var/obj/Skills/Queue/Explosion/R in src)
							R.UpgradedKeybladeSkill=1
				if("Fire Surge")
					if(!locate(/obj/Skills/AutoHit/Fire_Surge, src))
						src.AddSkill(new/obj/Skills/AutoHit/Fire_Surge)
					else if(locate(/obj/Skills/AutoHit/Fire_Surge, src))
						for(var/obj/Skills/AutoHit/Fire_Surge/R in src)
							R.UpgradedKeybladeSkill=1
				if("Thunder Surge")
					if(!locate(/obj/Skills/AutoHit/Thunder_Surge, src))
						src.AddSkill(new/obj/Skills/AutoHit/Thunder_Surge)
					else if(locate(/obj/Skills/AutoHit/Thunder_Surge, src))
						for(var/obj/Skills/AutoHit/Thunder_Surge/R in src)
							R.UpgradedKeybladeSkill=1
				if("Ars Arcanum")
					if(!locate(/obj/Skills/Queue/Ars_Arcanum, src))
						src.AddSkill(new/obj/Skills/Queue/Ars_Arcanum)
					else if(locate(/obj/Skills/Queue/Ars_Arcanum, src))
						for(var/obj/Skills/Queue/Ars_Arcanum/R in src)
							R.UpgradedKeybladeSkill=1
				if("Ragnarok")
					if(!locate(/obj/Skills/AutoHit/Ragnarok, src))
						src.AddSkill(new/obj/Skills/AutoHit/Ragnarok)
					else if(locate(/obj/Skills/AutoHit/Ragnarok, src))
						for(var/obj/Skills/AutoHit/Ragnarok/R in src)
							R.UpgradedKeybladeSkill=1
				if("Salvation")
					if(!locate(/obj/Skills/AutoHit/Salvation, src))
						src.AddSkill(new/obj/Skills/AutoHit/Salvation)
					else if(locate(/obj/Skills/AutoHit/Salvation, src))
						for(var/obj/Skills/AutoHit/Salvation/R in src)
							R.UpgradedKeybladeSkill=1
				if("Raging Storm")
					if(!locate(/obj/Skills/AutoHit/Raging_Storm, src))
						src.AddSkill(new/obj/Skills/AutoHit/Raging_Storm)
					else if(locate(/obj/Skills/AutoHit/Raging_Storm, src))
						for(var/obj/Skills/AutoHit/Raging_Storm/R in src)
							R.UpgradedKeybladeSkill=1
	ChooseKeychain()
		var/list/Options=glob.Keychains
		var/keybladedecision
		var/Choice
		while(keybladedecision!="Yes")
			for(var/o in src.Keychains)
				Options.Remove(o)
			Choice=input(usr, "You've gained the ability to change your keychain.  Which one do you choose?", "Keychain Ascension") in Options
			var/list/KBPassives=GetKeybladePassives(Choice,src.SagaLevel)
			src<<"<b>Note, some of these passives may scale based on your SagaLevel. Most of the ones that would have scaling effects do.</b>"
			var/description= "Passives:"
			if(KBPassives.len>0)
				for(var/i in KBPassives)
					description += "[i] - [KBPassives[i]]\n"
			src<<"<b>Passives:</b>[description]"
			keybladedecision=alert(src, "Is [Choice] the keychain you want?", "Choice","Yes", "No")
		src.Keychains.Add(Choice)
		if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Attach_Keychain, src))
			src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Attach_Keychain)
proc/
	GetKeychainClass(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return "Light"
			if("Kingdom Key D")
				return "Light"
			if("Flame Liberator")
				return "Light"
			if("Wayward Wind")
				return "Light"
			if("Rainfell")
				return "Light"
			if("Oathkeeper")
				return "Light"
			if("Way To Dawn")
				return "Light"
			if("Bond of Flame")
				return "Light"
			if("Sweetstack")
				return "Light"
			if("Two Become One")
				return "Light"
			if("Blind Justice")
				return "Light"
//medium
			if("Oblivion")
				return "Medium"
			if("Fenrir")
				return "Medium"
			if("No Name")
				return "Medium"
			if("Lionheart")
				return "Medium"
			if("Spellbinder")
				return "Medium"
			if("Star Seeker")
				return "Medium"
			if("Lost Memory")
				return "Medium"
			if("Ultima Weapon")
				return "Medium"
//heavy
			if("Earthshaker")
				return "Heavy"
			if("Chaos Ripper")
				return "Heavy"
			if("One Winged Angel")
				return "Heavy"
			if("Moogle O Glory")
				return "Heavy"
			if("X-Blade")
				return "Heavy"
			if("Ebony Slumber")
				return "Heavy"
			if("Prismatic Dreams")
				return "Heavy"
	GetKeychainDamage(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 1.25
			if("Kingdom Key D")
				return 1.25
			if("Flame Liberator")
				return 1.25
			if("Wayward Wind")
				return 1.25
			if("Rainfell")
				return 1.25
			if("Oathkeeper")
				return 1.25
			if("Way To Dawn")
				return 1.25
			if("Bond of Flame")
				return 1.25
			if("Sweetstack")
				return 1.25
			if("Two Become One")
				return 1.25
			if("Blind Justice")
				return 1.25
//medium
			if("Oblivion")
				return 1.5
			if("Fenrir")
				return 1.5
			if("No Name")
				return 1.75
			if("Lionheart")
				return 1.5
			if("Spellbinder")
				return 1.5
			if("Star Seeker")
				return 1.5
			if("Lost Memory")
				return 1.5
			if("Ultima Weapon")
				return 2.5
//heavy
			if("Earthshaker")
				return 2
			if("Chaos Ripper")
				return 2
			if("One Winged Angel")
				return 2
			if("Moogle O Glory")
				return 2
			if("X-Blade")
				return 3
			if("Ebony Slumber")
				return 2.5
			if("Prismatic Dreams")
				return 2.5
	GetKeychainAccuracy(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 2
			if("Kingdom Key D")
				return 2
			if("Flame Liberator")
				return 2
			if("Wayward Wind")
				return 2
			if("Rainfell")
				return 2
			if("Oathkeeper")
				return 2
			if("Way To Dawn")
				return 2
			if("Bond of Flame")
				return 2
			if("Sweetstack")
				return 2
			if("Two Become One")
				return 2
			if("Blind Justice")
				return 2
//medium
			if("Oblivion")
				return 1.5
			if("Fenrir")
				return 1.5
			if("No Name")
				return 1.5
			if("Lionheart")
				return 1.5
			if("Spellbinder")
				return 1.5
			if("Star Seeker")
				return 1.5
			if("Lost Memory")
				return 1.5
			if("Ultima Weapon")
				return 1.5
//heavy
			if("Earthshaker")
				return 1
			if("Chaos Ripper")
				return 1
			if("One Winged Angel")
				return 1
			if("Moogle O Glory")
				return 1
			if("X-Blade")
				return 1
			if("Ebony Slumber")
				return 1.25
			if("Prismatic Dreams")
				return 1.25
	GetKeychainDelay(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 2.5
			if("Kingdom Key D")
				return 2.5
			if("Flame Liberator")
				return 2.5
			if("Wayward Wind")
				return 2.5
			if("Rainfell")
				return 2.5
			if("Oathkeeper")
				return 2.5
			if("Way To Dawn")
				return 2.5
			if("Bond of Flame")
				return 2.5
			if("Sweetstack")
				return 2.5
			if("Two Become One")
				return 2.5
			if("Blind Justice")
				return 2.5
//medium
			if("Oblivion")
				return 1.5
			if("Fenrir")
				return 1.5
			if("No Name")
				return 1.5
			if("Lionheart")
				return 1.5
			if("Spellbinder")
				return 1.5
			if("Star Seeker")
				return 1.5
			if("Lost Memory")
				return 1.5
			if("Ultima Weapon")
				return 1.5
//heavy
			if("Earthshaker")
				return 1
			if("Chaos Ripper")
				return 1
			if("One Winged Angel")
				return 1
			if("Moogle O Glory")
				return 1
			if("X-Blade")
				return 1
			if("Ebony Slumber")
				return 1
			if("Prismatic Dreams")
				return 1
	GetKeychainElement(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 0
			if("Kingdom Key D")
				return 0
			if("Flame Liberator")
				return "Fire"
			if("Wayward Wind")
				return "Wind"
			if("Rainfell")
				return "Water"
			if("Oathkeeper")
				return "Light"
			if("Way To Dawn")
				return "Dark"
			if("Bond of Flame")
				return "Fire"
			if("Sweetstack")
				return "Love"
			if("Two Become One")
				if(prob(50))
					return "Light"
				else
					return "Dark"
			if("Blind Justice")
				return "Truth"
//medium
			if("Oblivion")
				return "Dark"
			if("Fenrir")
				return "Wind"
			if("No Name")
				return "Void"
			if("Lionheart")
				return "Earth"
			if("Spellbinder")
				return "Water"
			if("Star Seeker")
				return "Truth"
			if("Lost Memory")
				return "Wind"
			if("Ultima Weapon")
				return "Ultima"
//heavy
			if("Earthshaker")
				return "Earth"
			if("Chaos Ripper")
				return "Dark"
			if("One Winged Angel")
				return "Fire"
			if("Moogle O Glory")
				return "Water"
			if("X-Blade")
				return "Ultima"
			if("Ebony Slumber")
				return "Dark"
			if("Prismatic Dreams")
				return "Light"
	GetKeychainIcon(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 'KingdomKey.dmi'
			if("Kingdom Key D")
				return 'KingdomKeyD.dmi'
			if("Flame Liberator")
				return 'Flame Liberator.dmi'
			if("Wayward Wind")
				return 'WaywardWind.dmi'
			if("Rainfell")
				return 'Rainfell.dmi'
			if("Oathkeeper")
				return 'OathkeeperRevamp.dmi'
			if("Way To Dawn")
				return 'WayToTheDawn.dmi'
			if("Bond of Flame")
				return 'Bond of Flame.dmi'
			if("Sweetstack")
				return 'Sweetstack.dmi'
			if("Two Become One")
				return 'Two Become One.dmi'
			if("Blind Justice")
				return 'Blind Justice.dmi'
//medium
			if("Oblivion")
				return 'OblivionRevamped.dmi'
			if("Fenrir")
				return 'Fenrir.dmi'
			if("No Name")
				return 'NoName.dmi'
			if("Lionheart")
				return 'Lionheart.dmi'
			if("Spellbinder")
				return 'Spellbinder.dmi'
			if("Star Seeker")
				return 'Star Seeker.dmi'
			if("Lost Memory")
				return 'Lost Memory.dmi'
			if("Ultima Weapon")
				return 'Ultima Keyblade.dmi'
//heavy
			if("Earthshaker")
				return 'Earthshaker.dmi'
			if("Chaos Ripper")
				return 'ChaosRipper.dmi'
			if("One Winged Angel")
				return 'One Winged Angel.dmi'
			if("Moogle O Glory")
				return 'Moogle O Glory.dmi'
			if("X-Blade")
				return 'X-Blade NEOBIG.dmi'
			if("Ebony Slumber")
				return 'Fusion Keyblade - Dark.dmi'
			if("Prismatic Dreams")
				return 'Fusion Keyblade - Light.dmi'
	GetKeychainIconReversed(var/KC)
		switch(KC)
//small
			if("Kingdom Key")
				return 'KingdomKeySync.dmi'
			if("Kingdom Key D")
				return 'KingdomKeyDSync.dmi'
			if("Flame Liberator")
				return 'Flame Liberator - Sync.dmi'
			if("Wayward Wind")
				return 'WaywardWindSync.dmi'
			if("Rainfell")
				return 'RainfellSync.dmi'
			if("Oathkeeper")
				return 'OathkeeperRevampSync.dmi'
			if("Way To Dawn")
				return 'WayToTheDawnSync.dmi'
			if("Bond of Flame")
				return 'Bond of Flame - Sync.dmi'
			if("Sweetstack")
				return 'Sweetstack - Sync.dmi'
			if("Two Become One")
				return 'Two Become One - Sync.dmi'
			if("Blind Justice")
				return 'Blind Justice - Sync.dmi'
//medium
			if("Oblivion")
				return 'OblivionRevampedSync.dmi'
			if("Fenrir")
				return 'FenrirSync.dmi'
			if("No Name")
				return 'NoNameSync.dmi'
			if("Lionheart")
				return 'Lionheart - Sync.dmi'
			if("Spellbinder")
				return 'Spellbinder - Sync.dmi'
			if("Star Seeker")
				return 'Starseeker - Sync.dmi'
			if("Lost Memory")
				return 'Lost Memory - Sync.dmi'
			if("Ultima Weapon")
				return 'Ultima Keyblade.dmi'
//heavy
			if("Earthshaker")
				return 'EarthshakerSync.dmi'
			if("Chaos Ripper")
				return 'ChaosRipperSync.dmi'
			if("One Winged Angel")
				return 'One Winged Angel - Sync.dmi'
			if("Moogle O Glory")
				return 'Moogle O Glory - Sync.dmi'
			if("X-Blade")
				return 'X-Blade NEOBIG.dmi'
			if("Ebony Slumber")
				return 'Fusion Keyblade - Dark Sync.dmi'
			if("Prismatic Dreams")
				return 'Fusion Keyblade - Light Sync.dmi'


	GetKeybladePassives(var/KC, var/Boost)
		var/KeybladePassives=list()
		switch(KC)
//small
			if("Kingdom Key")
				KeybladePassives=list("PULock" = 1)
				return KeybladePassives
			if("Kingdom Key D")
				KeybladePassives=list("PULock" = 1)
				return KeybladePassives
			if("Flame Liberator")
				KeybladePassives=list("PULock" = 1, "Combustion" = 60, "Scorching" = 2+Boost)
				return KeybladePassives
			if("Wayward Wind")
				KeybladePassives=list("PULock" = 1,"Skimming" = 1+(Boost/2), "Godspeed" = 1,"BlurringStrikes" = 3, "AttackSpeed" = 2+(Boost/2))
				return KeybladePassives
			if("Rainfell")
				KeybladePassives=list("PULock" = 1, "CriticalChance" = 30+(Boost*5), "ThunderHerald" = 1, "CriticalDamage"= 0.15)
				return KeybladePassives
			if("Oathkeeper")
				KeybladePassives=list("PULock" = 1, "ManaGeneration" = 2+Boost, "HolyMod" = 1+Boost, "QuickCast" = 1+Boost,"ManaStats" = 1+Boost)
				return KeybladePassives
			if("Way To Dawn")
				KeybladePassives=list("PULock" = 1, "AbyssMod" = 3+Boost,"HolyMod"=3+Boost,"Controlled Darkness" = 1)
				return KeybladePassives
			if("Bond of Flame")
				KeybladePassives=list("PULock" = 1, "Scorching" = 10+(Boost*2), "MeltyBlood" = 1)
				return KeybladePassives
			if("Sweetstack")
				KeybladePassives=list("PULock" = 1, "TechniqueMastery" = Boost, "BuffMastery" = Boost)
				return KeybladePassives
			if("Two Become One")
				KeybladePassives=list("PULock" = 1, "Two Become One" = 1, "BlurringStrikes" = 4, "ManaGeneration" = 2+(Boost/2))
				return KeybladePassives
			if("Blind Justice")
				KeybladePassives=list("PULock" = 1, "PureDamage" = 3+(Boost/2), "PureReduction" = -3+(Boost/2))
				return KeybladePassives
//medium
			if("Oblivion")
				KeybladePassives=list("PULock" = 1, "AbyssMod" = 1+Boost,"EnergyGeneration" = 3+Boost, "Momentum" = 2,"SpiritFlow" =1+round(Boost/2))
				return KeybladePassives
			if("Fenrir")
				KeybladePassives=list("PULock" = 1, "Steady" = 3, "Brutalize" = Boost/1.5, "Extend" = 1, "Conductor" = -50, "DemonicDurability" = Boost, "AngerAdaptiveForce" = 0.2*Boost)
				return KeybladePassives
			if("No Name")
				KeybladePassives=list("PULock" = 1, "HardStyle" = 1)
				return KeybladePassives
			if("Lionheart")
				KeybladePassives=list("PULock" = 1, "SpiritPower" = round(Boost/5), "Persistence" = 1+(Boost/2), "UnderDog" = 1+Boost)
				return KeybladePassives
			if("Spellbinder")
				KeybladePassives=list("PULock" = 1, "ManaCapMult" = (0.15*Boost),"ManaStats" = 0.5+(Boost/2), "ManaGeneration" = 5)
				return KeybladePassives
			if("Star Seeker")
				KeybladePassives=list("PULock" = 1, "UnderDog" = 1+Boost, "Tenacity" = 3+Boost)
				return KeybladePassives
			if("Lost Memory")
				KeybladePassives=list("PULock" = 1, "HybridStrike" = 1, "Flow" = 3, "Instinct" = 3)
				return KeybladePassives
			if("Ultima Weapon")
				KeybladePassives=list("PULock" = 1, "PureDamage" = 10, "PureReduction" = 10, "GodKi" = 0.25)
				return KeybladePassives
//heavy
			if("Earthshaker")
				KeybladePassives=list("PULock" = 1, "Harden" = 3, "CallousedHands" = Boost/10)
				return KeybladePassives
			if("Chaos Ripper")
				KeybladePassives=list("PULock" = 1, "Extend" = 2, "Half-Sword" = 5, "Zornhau" = 5, "HardStyle" = 1)
				return KeybladePassives
			if("One Winged Angel")
				KeybladePassives=list("PULock" = 1, "CriticalChance" = 5+(Boost*2), "CriticalDamage"= 0.3+(Boost/10))
				return KeybladePassives
			if("Moogle O Glory")
				KeybladePassives=list("PULock" = 1, "Extend" = 1, "CashCow" = 2, "SoftStyle" = 1, "Blubber" = Boost/4)
				return KeybladePassives
			if("Ebony Slumber")
				KeybladePassives=list("PULock" = 1, "Dreamless Sleep" = 1, "GodKi" = 0.25)
				return KeybladePassives
			if("Prismatic Dreams")
				KeybladePassives=list("PULock" = 1, "Dream Within a Dream" =1, "GodKi" = 0.25)
				return KeybladePassives
			if("X-Blade")
				KeybladePassives=list("PULock" = 1, "GodKi" = 0.5)
				return KeybladePassives
/*
		switch(KC)
//small
			if("Kingdom Key")
			if("Kingdom Key D")
			if("Flame Liberator")
			if("Wayward Wind")
			if("Rainfell")
			if("Oathkeeper")
			if("Way To Dawn")
			if("Bond of Flame")
			if("Sweetstack")
			if("Two Become One")
//medium
			if("Oblivion")
			if("Fenrir")
			if("No Name")
			if("Lionheart")
			if("Spellbinder")
			if("Star Seeker")
			if("Lost Memory")
			if("Ultima Weapon")
//heavy
			if("Earthshaker")
			if("Chaos Ripper")
			if("One Winged Angel")
			if("Moogle O' Glory")
			if("X-Blade")
			if("Ebony Slumber")
			if("Prismatic Dreams")
*/
/mob/proc/PickKeychain()
	var/list/Options=glob.Keychains
	for(var/o in src.Keychains)
		Options.Remove(o)
	var/Choice=input(usr, "What keychain do you want?", "Heart Share") in Options
	if(Choice=="Cancel")
		return
	src.Keychains.Add(Choice)
