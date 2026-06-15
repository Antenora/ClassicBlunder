/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Nobody/Lunar_Wrath
	passives = list("Unrelenting Wrath" = 1, "Godspeed" = 2, "Skimming" = 2,"ManaLeak"=1)
	TextColor=rgb(255, 0, 0)
	Cooldown=60
	LunarWrath=1
	ManaDrain=1
	PostBuffEff="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain"
	CustomActive="<b>The light of Kingdom Hearts fills the air, as the wrath of the moon coalesces into a single point!</b>"
	OffMessage="calms their fury..."
	StrMult=1.5
	ForMult=1.5
	SpdMult=1.5
	OffMult=1.5
	ManaGlow="#91C8FF"
	ManaGlowSize=3
	KenWaveIcon='KenShockwavePurple.dmi'
	adjust(mob/p)
		var/AscBonus=p.AscensionsAcquired*0.1
		StrMult=1.5+AscBonus
		ForMult=1.5+AscBonus
		SpdMult=1.5+AscBonus
		OffMult=1.5+AscBonus
		passives = list("Unrelenting Wrath" = 1, "Godspeed" = 2, "Skimming" = 2,"ManaLeak"=1-AscBonus)

/obj/Skills/Buffs/SlotlessBuffs/Racial
	Void_Blade
		MakesSword=3
		SpecialSlot=0
		Slotless=1
		SwordName="Void Blade"
		SwordIcon='KATANA SILVER.dmi'
		StealsStats=1
		SwordX=-8
		SwordY=-4
		SwordElement="Void"
		SwordUnbreakable=1
		passives = list("StealsStats" = 1,"VoidBlade" = 1)
		verb/Transfigure_Void_Blade()
			set category="Utility"
			var/Choice
			if(!usr.BuffOn(src))
				var/modify_sword_num = 1
				if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style) in src) || (locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in src))
					var/list/options = list("Primary","Secondary")
					if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in src)) options += "Tertiary"
					switch(input("Which sword would you like to modify?") in options)
						if("Secondary") modify_sword_num=2
						if("Tertiary") modify_sword_num=3
				var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
				if(Lock=="Yes")
					switch(modify_sword_num)
						if(1)
							src.SwordIcon=input(usr, "What icon will your Void Blade use?", "Void Blade Icon") as icon|null
							src.SwordX=input(usr, "Pixel X offset.", "Void Blade Icon") as num
							src.SwordY=input(usr, "Pixel Y offset.", "Void Blade Icon") as num
						if(2)
							src.SwordIconSecond=input(usr, "What icon will your Void Blade use?", "Void Blade Icon") as icon|null
							src.SwordXSecond=input(usr, "Pixel X offset.", "Void Blade Icon") as num
							src.SwordYSecond=input(usr, "Pixel Y offset.", "Void Blade Icon") as num
						if(3)
							src.SwordIconThird=input(usr, "What icon will your Void Blade use?", "Void Blade Icon") as icon|null
							src.SwordXThird=input(usr, "Pixel X offset.", "Void Blade Icon") as num
							src.SwordYThird=input(usr, "Pixel Y offset.", "Void Blade Icon") as num
				Choice=input(usr, "What class of blade do you want your Void Blade to be?", "Transfigure Void Blade") in list("Blunt", "Saber", "Longsword", "Greatsword")
				switch(Choice)
					if("Blunt")
						switch(modify_sword_num)
							if(1) src.SwordClass="Wooden"
							if(2) src.SwordClassSecond="Wooden"
							if(3) src.SwordClassThird="Wooden"
					if("Saber")
						switch(modify_sword_num)
							if(1) src.SwordClass="Light"
							if(2) src.SwordClassSecond="Light"
							if(3) src.SwordClassThird="Light"
					if("Longsword")
						switch(modify_sword_num)
							if(1) src.SwordClass="Medium"
							if(2) src.SwordClassSecond="Medium"
							if(3) src.SwordClassThird="Medium"
					if("Greatsword")
						switch(modify_sword_num)
							if(1) src.SwordClass="Heavy"
							if(2) src.SwordClassSecond="Heavy"
							if(3) src.SwordClassThird="Heavy"
				usr << "Void Blade class set as [Choice]!"
			else
				usr << "You can't set this while using Void Blade."
		verb/Void_Blade()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)
/obj/Skills/Buffs/SpecialBuffs/Nobody
	CyberSignature=1
	SagaSignature=1
	SignatureTechnique=4
	SpecialSlot=0
	Slotless=1
	Darkness_of_the_Unknown
		ForMult=1.35
		DefMult=1.35
		passives = list("Godspeed" = 2, "Skimming" = 2,"SweepingStrike"=1)
		ActiveMessage="draws from the darkness of the unknown, calling forth power that never was!"
		OffMessage="contains their superiority."
		verb/Darkness_of_the_Unknown()
			set category="Skills"
			src.Trigger(usr)
	Lord_of_the_Castle
		OffMult=1.35
		SpdMult=1.35
		passives = list()
		ActiveMessage="draws from their authority over oblivion, calling forth power over mortality!"
		OffMessage="contains their superiority."
		verb/Lord_of_the_Castle()
			set category="Skills"
			src.Trigger(usr)
	The_Other_Promise
		OffMult=1.35
		SpdMult=1.35
		passives = list("SwordAscension" = 1, "Flicker" = 3, "Brutalize" = 1, "Instinct" = 2)
		verb/The_Other_Promise()
			set category="Skills"
			src.Trigger(usr)
	The_13th_Dilemma
		EndMult=1.35
		StrMult=1.35
		passives = list()
		verb/The_13th_Dilemma()
			set category="Skills"
			src.Trigger(usr)
	Vector_to_the_Heavens
		StrMult=1.35
		ForMult=1.35
		passives = list()
		verb/Vector_to_the_Heavens()
			set category="Skills"
			src.Trigger(usr)