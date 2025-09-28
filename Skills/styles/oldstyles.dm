
					Feral_Style
						StyleStr=1.3
						StyleEnd=1.5
						StyleSpd=1.2
						StyleActive="Feral"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Blitz_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Spirit_Style",\
						"/obj/Skills/Buffs/NuStyle/FreeStyle/Flow_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Yin_Yang_Style")
						passives = list("Instinct" = 1)
						Instinct=1
						Finisher="/obj/Skills/Queue/Finisher/Berserker_Claw"
						verb/Feral_Style()
							set hidden=1
							src.Trigger(usr)
					Flow_Style
						StyleEnd=1.4
						StyleFor=1.2
						StyleSpd=1.4
						StyleActive="Flow"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Breaker_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Soul_Crushing_Style",\
						"/obj/Skills/Buffs/NuStyle/FreeStyle/Feral_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Yin_Yang_Style")
						passives = list("Flow" = 1)
						Flow=1
						Finisher="/obj/Skills/Queue/Finisher/Evac_Toss"
						verb/Flow_Style()
							set hidden=1
							src.Trigger(usr)
					Breaker_Style
						StyleStr=1.3
						StyleEnd=1.4
						StyleFor=1.3
						StyleActive="Breaker"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Flow_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Soul_Crushing_Style",\
						"/obj/Skills/Buffs/NuStyle/FreeStyle/Blitz_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Resonance_Style")
						passives = list("WeaponBreaker" = 1)
						WeaponBreaker=1
						Finisher="/obj/Skills/Queue/Finisher/Armor_Piercer"
						verb/Breaker_Style()
							set hidden=1
							src.Trigger(usr)
					Blitz_Style
						StyleStr=1.3
						StyleEnd=1.3
						StyleSpd=1.4
						StyleActive="Blitz"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Feral_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Spirit_Style",\
						"/obj/Skills/Buffs/NuStyle/FreeStyle/Breaker_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Resonance_Style")
						passives = list("Flicker" = 1, "Pursuer" = 1)
						Flicker=1
						Pursuer=1
						Finisher="/obj/Skills/Queue/Finisher/Riot_Stamp"
						verb/Blitz_Style()
							set hidden=1
							src.Trigger(usr)
//Signature Style T1
					Soul_Crushing_Style
						SignatureTechnique=1
						Copyable=0
						StyleFor=1.5
						StyleEnd=1.5
						passives = list("SpiritStrike" = 1, "WeaponBreaker" = 1, "MovingCharge" = 1)
						SpiritStrike=1
						WeaponBreaker=1
						MovingCharge=1
						StyleActive="Soul Crushing"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Spirit_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Shunko_Style",\
						"/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Arcane_Bladework_Style")
						Finisher="/obj/Skills/Queue/Finisher/Impact_Palm"
						verb/Soul_Crushing_Style()
							set hidden=1
							src.Trigger(usr)
					Spirit_Style
						SignatureTechnique=1
						Copyable=0
						StyleFor=1.5
						StyleSpd=1.5
						passives = list("Flicker" = 1, "Pursuer" = 1)
						Flicker=1
						Pursuer=1
						StyleActive="Spirit"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Soul_Crushing_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Shunko_Style",\
						"/obj/Skills/Buffs/NuStyle/SwordStyle/Kendo_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Battle_Mage_Style")
						Finisher="/obj/Skills/Queue/Finisher/Superbia"
						verb/Spirit_Style()
							set hidden=1
							src.Trigger(usr)
					Yin_Yang_Style
						SignatureTechnique=1
						Copyable=0
						StyleOff=1.25
						StyleDef=1.25
						StyleEnd=1.5
						passives = list("Flow" = 0.5, "Instinct" = 0.5, "LikeWater" = 1, "CounterMaster" = 2)
						//adaptation passive
						StyleActive="Balance"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Resonance_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Metta_Sutra_Style",\
						"/obj/Skills/Buffs/NuStyle/SwordStyle/Champloo_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Shaolin_Style")
						Finisher="/obj/Skills/Queue/Finisher/Turn_of_Fortune"
						verb/Yin_Yang_Style()
							set hidden=1
							src.Trigger(usr)
					Resonance_Style
						SignatureTechnique=1
						Copyable=0
						StyleStr=1.5
						StyleFor=1.5
						passives = list("WeaponBreaker" = 2, "Pursuer" = 1, "Flicker" = 1)
						WeaponBreaker=2
						Pursuer=1
						Flicker=1
						StyleActive="Resonance"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Yin_Yang_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Metta_Sutra_Style",\
						"/obj/Skills/Buffs/NuStyle/SwordStyle/Secret_Knife_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Blade_Singing_Style")
						Finisher="/obj/Skills/Queue/Finisher/Chemical_Love"
						verb/Resonance_Style()
							set hidden=1
							src.Trigger(usr)


//Signature Style T2
					Shunko_Style
						SignatureTechnique=2
						Copyable=0
						StyleStr=1.4
						StyleFor=1.4
						StyleEnd=1.1
						StyleSpd=1.1
						passives = list("IdealStrike" = 1, "HybridStrike" = 0.5, "MartialMagic" = 1,\
						"TechniqueMastery" = 2.5,"MovingCharge" = 1)
						StyleActive="Shunko"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Blade_Singing_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/Rhythm_of_War_Style")
						Finisher="/obj/Skills/Queue/Finisher/Raioken"
						verb/Shunko_Style()
							set hidden=1
							src.Trigger(usr)
					Metta_Sutra_Style
						SignatureTechnique=2
						Copyable=0
						StyleStr=1.1
						StyleFor=1.1
						StyleEnd=1.4
						StyleSpd=1.4
						passives = list("WeaponBreaker" = 3, "Flow" = 1, "Instinct" = 1, "LikeWater" = 2, "Flicker" = 1, "Pursuer" = 1, "CounterMaster" = 4)
						WeaponBreaker=3
						Flow=2
						Instinct=2
						//adaptation
						Flicker=1
						Pursuer=1
						StyleActive="Metta Sutra"
						ElementalDefense="Mirror"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Shaolin_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/West_Star_Style")
						Finisher="/obj/Skills/Queue/Finisher/Karaniyam"
						verb/Metta_Sutra_Style()
							set hidden=1
							src.Trigger(usr)
					Shaolin_Style
						SignatureTechnique=2
						Copyable=0
						NoStaff=0
						StyleStr=1.5
						StyleFor=1.5
						passives = list("Flow" = 2, "Instinct" = 2, "SwordPunching" = 1)
						Flow=2
						Instinct=2
						//adaptation passive
						//champloo's sord punching
						SwordPunching=1
						StyleActive="Shaolin"
						ElementalOffense="Mirror"
						StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/FreeStyle/Metta_Sutra_Style"="/obj/Skills/Buffs/NuStyle/FreeStyle/West_Star_Style")
						Finisher="/obj/Skills/Queue/Finisher/Bicycle_Kick"
						verb/Shaolin_Style()
							set hidden=1
							src.Trigger(usr)

//Signature Style T3
					West_Star_Style
						SignatureTechnique=3
						Copyable=0
						NoStaff=0
						StyleEnd=1.5
						StyleSpd=1.5
						passives = list("WeaponBreaker" = 4, "Flow" = 3, "Instinct" = 3, "Flicker" = 2, "Pursuer" = 2, "SwordPunching" = 1)
						WeaponBreaker=4
						Flow=3
						Instinct=3
						Flicker=2
						Pursuer=2
						//adaptation
						//Champloo's sword punching
						SwordPunching=1
						ElementalOffense="Mirror"
						ElementalDefense="Mirror"
						ElementalClass="Water"
						StyleActive="West Star"
						Finisher="/obj/Skills/Queue/Finisher/Journey_End"
						verb/West_Star_Style()
							set hidden=1
							src.Trigger(usr)
					Rhythm_of_War_Style
						SignatureTechnique=3
						Copyable=0
						StyleStr=1.25
						StyleFor=1.25
						StyleSpd=1.5
						passives = list("IdealStrike" = 1, "WeaponBreaker" = 2, "Flicker" = 2, "Pursuer" = 3, "SuperDash" = 2, "SwordPunching" = 1, "TechniqueMastery" = 2, "MovementMastery" = 6, "MartialMagic" = 1, "MovingCharge" = 1)
						HybridStrike=1
						WeaponBreaker=3
						Flicker=3
						Pursuer=3
						SuperDash=2
						SwordPunching=1
						TechniqueMastery=10
						MovementMastery=8
						MartialMagic=1
						MovingCharge=1
						HitSpark='Hit Effect Vampire.dmi'
						HitX=-32
						HitY=-32
						HitTurn=0
						HitSize=1
						StyleActive="Rhythm of War"
						Finisher="/obj/Skills/Queue/Finisher/Death_Rattle"
						verb/Rhythm_of_War_Style()
							set hidden=1
							src.Trigger(usr)
