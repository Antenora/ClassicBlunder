ascension
	nobody
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(!applied)
					switch(owner.NobodyOriginType)
						if("Pride")
							owner.race.transformations.Add(new/transformation/nobody/void_super_saiyan())
						if("Spirit")
							owner.race.transformations.Add(new/transformation/nobody/spectral_tension())
					if(owner.Class == "Imaginary")
						if(owner.SagaLevel < 2)
							owner.SagaLevel = 2
							owner.ChooseMartialSkill(1)
							owner.saga_up_self()
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "You're only everything you ever dreamed of... Don't think twice."
						if("Spirit")
							on_ascension_message = "Your sanctuary, where fears and lies melt away."
						if("Simple")
							SMod = 2.5
							on_ascension_message = "Inside, you feel simple and clean."
					switch(owner.Class)
						if("Samurai")
							speed=0.5 * SMod
							strength=1 * SMod
							endurance=0.5 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=0.5 * SMod
							force=0.5 * SMod
							offense=0.5 * SMod
							defense=0.5 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=0.5 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"= 1, "Juggernaut" = 0.5)
						if("Imaginary")
							force=0.5 * SMod
							strength=0.5 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							endurance=0.25 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1, "EnergyGeneration" = 2, "ManaGeneration" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							endurance=0.25 * SMod
							passives = list("SlayerMod" = 0.5, "CriticalChance" = 10, "Instinct" = 1)
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(!applied)
					if(owner.Class == "Imaginary")
						if(owner.SagaLevel < 3)
							owner.SagaLevel = 3
							owner.ChooseKeychain()
							owner.ChooseMartialSkill(2)
							owner.saga_up_self()
				if(owner.NobodyOriginType!="Simple")
					if(owner.transUnlocked<1)
						owner.transUnlocked=1
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "You want this for a lifetime... Don't think twice."
						if("Spirit")
							on_ascension_message = "What's left of you now, your sanctuary."
						if("Simple")
							SMod = 2.5
							on_ascension_message = "Whatever lies beyond this morning is a little later on..."
					switch(owner.Class)
						if("Samurai")
							speed=0.5 * SMod
							strength=1 * SMod
							endurance=0.5 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "PureDamage"=1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=0.5 * SMod
							force=0.5 * SMod
							offense=0.5 * SMod
							defense=0.5 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=0.5 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"=1, "Juggernaut" = 0.5)
						if("Imaginary")
							force=0.5 * SMod
							strength=0.5 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							endurance=0.25 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1, "EnergyGeneration" = 2, "ManaGeneration" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							endurance=0.25 * SMod
							passives = list("SlayerMod" = 0.5, "CriticalChance" = 10, "Instinct" = 1)
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(!applied)
					if(owner.Class == "Imaginary")
						if(owner.SagaLevel < 4)
							owner.SagaLevel = 4
							owner.saga_up_self()
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "Everything is just right, don't think twice!"
						if("Spirit")
							on_ascension_message = "Your heart is a battleground... Your sanctuary"
						if("Simple")
							SMod = 2.5
							on_ascension_message = "Regardless of warnings, the future doesn't scare you at all..."
					switch(owner.Class)
						if("Samurai")
							speed=0.5 * SMod
							strength=1 * SMod
							endurance=0.5 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "PureDamage"=1, "Steady" = 1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=0.5 * SMod
							force=0.5 * SMod
							offense=0.5 * SMod
							defense=0.5 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=0.5 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"=1, "Juggernaut" = 0.5)
						if("Imaginary")
							force=0.5 * SMod
							strength=0.5 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("SlayerMod" = 0.5, "CriticalChance" = 10, "Instinct" = 1)
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(!applied)
					if(owner.Class == "Imaginary")
						if(owner.SagaLevel < 5)
							owner.SagaLevel = 5
							owner.saga_up_self()
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "If you wanna make it happen, nothing is impossible! Don't think twice!"
							SMod = 1.5
						if("Spirit")
							on_ascension_message = "You need true emotions... Your sanctuary..."
							SMod = 1.5
						if("Simple")
							SMod = 3
							on_ascension_message = "Nothing is like before... Simple and clean..."
					switch(owner.Class)
						if("Samurai")
							speed=0.5 * SMod
							strength=1 * SMod
							endurance=0.5 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "PureDamage"=1, "Steady" = 1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=0.5 * SMod
							force=0.5 * SMod
							offense=0.5 * SMod
							defense=0.5 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=0.5 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"=1, "Juggernaut" = 0.5,  "Unstoppable" = 1)
						if("Imaginary")
							force=0.5 * SMod
							strength=0.5 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("SlayerMod" = 0.5, "Instinct" = 2, "PureDamage" = 1)
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(!applied)
					if(owner.Class == "Imaginary")
						if(owner.SagaLevel < 6)
							owner.SagaLevel = 6
							owner.saga_up_self()
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "You're only crying because you never dreamed it'd take this long... Don't. Think. Twice."
							SMod = 1.5
						if("Spirit")
							on_ascension_message = "Your fears, your lies, all melt away... Into your sanctuary!"
							SMod = 1.5
						if("Simple")
							SMod = 3
							on_ascension_message = "Maybe some things are that simple..."
					switch(owner.Class)
						if("Samurai")
							speed=0.5 * SMod
							strength=1 * SMod
							endurance=0.5 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "PureDamage"=1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=0.5 * SMod
							force=0.5 * SMod
							offense=0.5 * SMod
							defense=0.5 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=0.5 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"=1, "PridefulRage"=1, "Juggernaut" = 0.5)
						if("Imaginary")
							force=0.5 * SMod
							strength=0.5 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("SlayerMod" = 0.5,  "Instinct" = 2, "PureDamage" = 1, "Deicide" = 5)
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				var/type = owner.NobodyOriginType
				var/SMod = 1
				if(!applied)
					switch(type)
						if("Pride")
							on_ascension_message = "Lose, don't have nothing to... Let me face my fears."
							SMod = 1.5
						if("Spirit")
							on_ascension_message = "Faith, should I take a leap... Let me face my fears."
							SMod = 1.5
						if("Simple")
							SMod = 3
							on_ascension_message = "Space, this is what I choose... Let me face my fears."
					switch(owner.Class)
						if("Samurai")
							speed=1 * SMod
							strength=1 * SMod
							endurance=1 * SMod
							passives = list("SwordAscension" = 1, "Godspeed"=1, "PureDamage"=1, "Persistence"=1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1)
						if("Sorcerer")
							endurance=1 * SMod
							force=1 * SMod
							offense=1 * SMod
							defense=1 * SMod
							passives = list("MovementMastery" = 2, "QuickCast"=1,"TechniqueMastery" = 1, "ManaStats"=1)
						if("Berserker")
							strength=1 * SMod
							endurance=1 * SMod
							passives = list("ManaCapMult" = 0.25, "Brutalize"=1, "Juggernaut" = 0.5)
						if("Imaginary")
							force=1 * SMod
							strength=1 * SMod
							offense=1 * SMod
							speed=1 * SMod
							passives = list("Tenacity" = 1, "Persistence" = 1)
						if("Reaper")
							strength=0.75 * SMod
							force=0.25 * SMod
							offense=0.5 * SMod
							speed=0.5 * SMod
							passives = list("SlayerMod" = 0.5,  "Instinct" = 2, "PureDamage" = 1, "Deicide" = 5)
