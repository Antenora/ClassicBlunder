mob
	var
		passive/passive_handler
/*	verb
		GetAllPassives() //test verb, remove later
			usr << passive_handler.getAll() */

passive
	var
		list/passives //this list will track passives that are intended to stick to the character; racials/things sticking over relogs.
		tmp/list/tmp_passives //this list is for buffs, or things that should fall off naturally/on a relog.
		tmp/list/text_passive_restore_stack
		list/states

	New()
		passives = list()
		tmp_passives = list()
		states = list()
		text_passive_restore_stack = list()
	proc

		Get(passive) // returns value of passive if it exists/has anything
			var/list/L = plist(passive)
			return L[passive] ? L[passive] : 0
		operator[](passive)
			return Get(passive)
		plist(passive)
			var/list/SK = glob?.STATE_KEYS
			if(SK && SK[passive])
				if(!states) states = list()
				return states
			if(!passives) passives = list()
			return passives
		getAll() //outputs in text, will be used for some sort of psuedo-assess
			var/passiveText="Passives:"
			for(var/p in passives)
				passiveText+= "\n[p] = [passives[p]+tmp_passives[p]]"
			return "[passiveText]"

		Increase(passive, value = 1, temp = FALSE) // Used to specifically increment a passive upwards. If it doesn't exist, then it gets created and set to that value. passive can also be passed in as a list ofto increase.
			if(!isnum(value))
				CRASH("ERROR: [passive] was increased by [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							var/list/L = plist(passive)
							L[passive] += value
						if(TRUE)
							tmp_passives[passive] += value
				if(TRUE)
					increaseList(passive, temp)

		Set(passive, value = 0, temp = FALSE) // directly sets a passive
			if(isnull(value))
				CRASH("ERROR: [passive] was set to [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							var/list/L = plist(passive)
							L[passive] = value
						if(TRUE)
							tmp_passives[passive] = value
				if(TRUE)
					setList(passive, temp)

		Decrease(passive, value = 1, temp = FALSE)
			if(!isnum(value))
				CRASH("ERROR: [passive] was decreased by [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							var/list/L = plist(passive)
							L[passive] -= value
						if(TRUE)
							tmp_passives[passive] -= value
				if(TRUE)
					decreaseList(passive, temp)

		decreaseList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						var/list/L = plist(settingPassive)
						if(!isnum(value))
							if(istext(value))
								var/list/restore_stack = text_passive_restore_stack[settingPassive]
								if(islist(restore_stack) && restore_stack.len > 0)
									var/restore_value = restore_stack[restore_stack.len]
									restore_stack.Cut(restore_stack.len, restore_stack.len + 1)
									L[settingPassive] = restore_value
									if(restore_stack.len <= 0)
										text_passive_restore_stack -= settingPassive
								else
									L[settingPassive] = null
							else
								CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						else
							L[settingPassive] -= value
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was decreased by [value] which is not a number!")
						tmp_passives[settingPassive] -= value

		increaseList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						var/list/L = plist(settingPassive)
						if(!isnum(value))
							if(istext(value))
								if(!islist(text_passive_restore_stack[settingPassive]))
									text_passive_restore_stack[settingPassive] = list()
								var/list/restore_stack = text_passive_restore_stack[settingPassive]
								restore_stack += L[settingPassive]
								L[settingPassive] = value
							else
								CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						else
							L[settingPassive] += value
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						tmp_passives[settingPassive] += value

		setList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(settingPassiveList[settingPassive]))
							CRASH("ERROR: [settingPassive] was set to [value] which is not a number!")
						var/list/L = plist(settingPassive)
						L[settingPassive] = value
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was set to [value] which is not a number!")
						tmp_passives[settingPassive] = value
		operator|=(passive) // alternative way of checking passives. shorthand if(passive|="zornhau") returns the value of zornhau
			Get(passive)

globalTracker/var/list/STATE_KEYS = list(\
	"AbsoluteDespair" = 1, "AbsorbingDamage" = 1, "ActiveBuffLock" = 1, "AdminVision" = 1,\
	"AfterImages" = 1, "AllOutPU" = 1, "AlphainForce" = 1, "Alter the Future" = 1,\
	"ApathyFactor" = 1, "ArcaneBladework" = 1, "AshChoked" = 1, "Ashen One" = 1,\
	"BossStagger" = 1, "CapacityHeal" = 1, "CastingTime" = 1, "Certain Progress" = 1,\
	"Chaos Buster" = 1, "ChaosQueen" = 1, "ChaosRuler" = 1, "ChargeDelay" = 1,\
	"Cleansing" = 1, "Compassion" = 1, "Completely Obliterated" = 1, "ConfuseAffected" = 1,\
	"ContinuallyStun" = 1, "Controlled Chaos" = 1, "Controlled Darkness" = 1,\
	"CooldownDrag" = 1, "CoolingDown" = 1, "CorruptAffected" = 1, "Corruption" = 1,\
	"CreateTheHeavens" = 1, "CriticalParalyze" = 1, "CriticalSpark" = 1, "CursedSheath" = 1,\
	"DamageMult" = 1, "Death X-Antibody" = 1, "DeathDefied" = 1, "Defiance" = 1,\
	"DemonicInfluence" = 1, "Deport" = 1, "Desperation" = 1, "Deterioration" = 1,\
	"Determination" = 1, "Determination(Black)" = 1, "Determination(Green)" = 1, "Determination(Orange)" = 1,\
	"Determination(Purple)" = 1, "Determination(Red)" = 1, "Determination(White)" = 1, "Determination(Yellow)" = 1,\
	"Deus Ex Machina" = 1, "Dim Mak" = 1, "Disarmed" = 1, "Disconnected" = 1,\
	"Distance" = 1, "Divine Technique" = 1, "DivineArmory" = 1, "Don't Move" = 1,\
	"DormantDemon" = 1, "DoubleHelix" = 1, "Drained" = 1, "DrainlessPUSpike" = 1,\
	"Dream Within a Dream" = 1, "Dreamless Sleep" = 1, "Duren" = 1, "Emptiness" = 1,\
	"EmptyFlashStep" = 1, "EndEffectiveness" = 1, "EndlessAnger" = 1,\
	"EnergyExpenditure" = 1, "EnergyHeal" = 1, "Enshrine" = 1, "EnvyFactor" = 1,\
	"EruptingBlows" = 1, "Explode" = 1, "Extra Secret Knives" = 1, "Fabled King" = 1,\
	"FakePeace" = 1, "FatigueDrain" = 1, "FatigueLeak" = 1, "Field of Destruction" = 1,\
	"Fishman" = 1, "FlashDOT" = 1, "ForScaling" = 1,\
	"ForceField" = 1, "ForceFielded" = 1, "Fox Spirit" = 1, "FrenzyCarrier" = 1,\
	"Full Manifestation" = 1, "FullTensionLock" = 1, "FutureRewritten" = 1, "Gluttony" = 1,\
	"GluttonyFactor" = 1, "GodspeedDisabled" = 1, "GreedFactor" = 1, "Grit" = 1,\
	"Half Manifestation" = 1, "HealThroughTempHP" = 1, "HealingReverse" = 1, "HealthCost" = 1,\
	"HealthPU" = 1, "Heart of Darkness" = 1, "HeatingUp" = 1, "Heavy Attack" = 1,\
	"Heavy Strike" = 1, "Hidden Potential" = 1, "HighTension" = 1, "Holding Back" = 1,\
	"HopeFactor" = 1, "Hopes and Dreams" = 1, "HybridStyle" = 1, "ImbuedSoul" = 1,\
	"InBlueEvolved" = 1, "Incomplete" = 1, "Infatuated" = 1, "Innovation" = 1,\
	"InverseHealing" = 1, "Judged" = 1, "Justice" = 1, "Kaioken" = 1,\
	"Kaioken Blue" = 1, "Kindling" = 1, "Knight of the Empty Seat" = 1, "LegendarySaiyan" = 1,\
	"Life Fiber Rending" = 1, "LimitBroken" = 1, "Limited Rank-Up" = 1, "LimitlessMagic" = 1,\
	"AfterImageSkin" = 1, "LifeStealPierce" = 1, "Lion Spirit" = 1, "TrueBlue" = 1, "VoidBlade" = 1, "Longing" = 1, "LunarWrath" = 1,\
	"LustFactor" = 1, "MagmicInfusion" = 1, "MagnifiedDef" = 1, "MagnifiedEnd" = 1,\
	"MagnifiedFor" = 1, "MagnifiedOff" = 1, "MagnifiedSSJ1" = 1, "MagnifiedSpd" = 1,\
	"MagnifiedStr" = 1, "Maki" = 1, "ManaCapMult" = 1, "ManaDrain" = 1,\
	"ManaHeal" = 1, "ManaLeak" = 1, "ManaPU" = 1, "ManaSeal" = 1,\
	"Manic" = 1, "Masochist" = 1, "Masquerade" = 1, "Mechanized" = 1,\
	"MirrorStats" = 1, "MortalStacks" = 1, "Musubi" = 1, "Mystic" = 1,\
	"NameCurse" = 1, "NeedStaff" = 1, "NeedsSecondSword" = 1, "NeedsSword" = 1,\
	"NeedsThirdSword" = 1, "NerveOverload" = 1, "Nightmare" = 1, "Nimbus" = 1,\
	"NoAnger" = 1, "NoStaff" = 1, "NoSword" = 1, "Obfuscated Origin" = 1,\
	"Ocean Bringer" = 1, "OmegaPower" = 1, "Omnipotent" = 1, "Orange Namekian" = 1,\
	"Our Future" = 1, "Overwhelming" = 1, "PULock" = 1, "PainShare" = 1,\
	"Perfect Counter" = 1, "Piloting" = 1, "PowerAppearance" = 1, "PowerPole" = 1,\
	"PowerReplacement" = 1, "PowerStressed" = 1, "Powerhouse" = 1, "Pride" = 1,\
	"PrideFactor" = 1, "Primordial" = 1, "Prismatic" = 1, "Rebel Heart" = 1,\
	"Red Hot Rage" = 1, "RedPUSpike" = 1, "Reflected" = 1, "Reinforcement" = 1,\
	"Rekkaken" = 1, "ReturnToSender" = 1, "RoyalGuarding" = 1, "Rust" = 1,\
	"SSJ4" = 1, "SSJ4LimitBreaker" = 1, "SSJRose" = 1, "Sadist" = 1,\
	"SaiyanPower1" = 1, "SaiyanPower2" = 1, "SaiyanPower3" = 1, "SaiyanPower4" = 1,\
	"SaiyanPowerVoid" = 1, "Sajire Rush" = 1, "Sanctify" = 1, "Scarlet-Overdriven" = 1,\
	"Secret Knives" = 1, "Seki" = 1, "Sekizou" = 1, "Sense Replacement" = 1,\
	"Shameful Display" = 1, "Shatter Fate" = 1, "Shellshocked" = 1, "Shijima" = 1,\
	"ShiningBrightly" = 1, "Shirayuki" = 1, "ShockwaveBlows" = 1, "Shonen" = 1,\
	"Silenced" = 1, "SilentPoison" = 1, "SkillLeech" = 1, "SlothFactor" = 1,\
	"Smokin' Sick Style!!!" = 1, "Smokin'!" = 1, "Snared" = 1, "Song of Oblivion" = 1,\
	"Sparks of Black" = 1, "SpecialBuffLock" = 1, "SpecialStrike" = 1, "SpiralEngine" = 1,\
	"SpiralImpact" = 1, "SpiritForm" = 1, "Spiritual Tactician" = 1, "Staggered!" = 1,\
	"Staked" = 1, "Star Surge" = 1, "StarCrossed" = 1, "StarPower" = 1,\
	"StealsStats" = 1, "StrScaling" = 1, "Stylish" = 1,\
	"SunStricken" = 1, "Super Kaioken" = 1, "SuperHighTension" = 1, "SuperMode" = 1,\
	"SuperSaiyanSignature" = 1, "Sure-Strike Black Flash" = 1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1,\
	"TeamFighter" = 1, "TeamHater" = 1, "TensionLock" = 1, "TensionPowered" = 1,\
	"TestMode" = 1, "The Almighty" = 1, "The Clock Is Ticking" = 1, "The Immovable Object" = 1,\
	"The Inkstone" = 1, "The Legend of REBIRTH" = 1, "The Power of Stories" = 1, "The Roaring" = 1,\
	"Timeless" = 1, "To Govern Strength" = 1, "Touch of Death" = 1, "Tragedy" = 1,\
	"Transformation Power" = 1, "Triple Helix" = 1, "True Edit" = 1, "True Evolution" = 1,\
	"True Inheritor" = 1, "TrueAbsorb" = 1, "TrueDemon" = 1, "TrueToxic" = 1,\
	"TrueZenkai" = 1, "TrueZenkaiPower" = 1, "TurfBurn" = 1, "TurfMud" = 1,\
	"Twisted Sentimentality" = 1, "Two Become One" = 1, "Unbroken" = 1, "Undeterred" = 1,\
	"Undying Rage" = 1, "UnleashToggle" = 1, "UnlimitedHighTension" = 1, "Unreality" = 1,\
	"Unrelenting Wrath" = 1, "UnstableSpace" = 1, "Utterly Powerless" = 1, "VenomBlood" = 1,\
	"Void" = 1, "WalkThroughHell" = 1, "WarmingUp" = 1,\
	"WarpPoint" = 1, "WeaponBreakerQOL" = 1, "Whirlwind" = 1, "Wolf Spirit" = 1,\
	"WrathFactor" = 1, "Wrathful" = 1, "X-Antibody" = 1, "YataNoKagami" = 1,\
	"Yosuga" = 1, "You Thought" = 1, "Zeal" = 1, "ZenkaiPower" = 1,  "Health Obfuscation" = 1)
