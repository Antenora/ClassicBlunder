/*
Mentor Angels will have 4 tiers of styles:
t1: Selfless State
t2: Ultra Instinct (In-Training)
t3: Perfected Ultra Instinct
t4: Permanent Ultra Instinct

Guardian Angels should gain buffs that equip them with the Armor of God:

t1: the Belt of Truth
t2: the Breastplate of Righteousness and the Sandals of the Gospel of Peace,
t3: the Helmet of Salvation and the Shield of Faith
t4: the Sword of the Spirit (the Word of God)


These will be considered Sagas for Angels but lack 6 tiers.
*/
/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles
	Selfless_State //placeholder because I might implement the Demon Slayer thing. basically baby UI
		Copyable=0
		passives = list("Flow" = 2, "Deflection" = 1, "Soft Style" = 1)
		NeedsSword=0
		StyleSpd=1.15
		StyleDef=1.15
		SignatureTechnique=1
		NoSword=1
		StyleActive="Selfless State"
		verb/Selfless_State()
			set hidden=1
			src.Trigger(usr)
	Incomplete_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "Soft Style" = 1, "Flow" = 3, "Instinct" = 1, "CounterMaster" = 1)
		NeedsSword=0
		StyleSpd=1.25
		StyleOff=1.15
		StyleDef=1.25
		SignatureTechnique=2
		NoSword=1
		StyleActive="Ultra Instinct (In-Training)"
		verb/Incomplete_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Ultra_Instinct
		Copyable=0
		passives = list("Flow" = 2, "Deflection" = 1, "Soft Style" = 1, "Flow" = 3, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1)
		NeedsSword=0
		StyleSpd=1.5
		StyleOff=1.5
		StyleDef=1.5
		SignatureTechnique=3
		NoSword=1
		StyleActive="Ultra Instinct (Complete)"
		verb/Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Perfected_Ultra_Instinct //I hope this is as gorked as I intend it on being.
		Copyable=0
		passives = list("Deflection" = 1, "Soft Style" = 1, "LikeWater" = 4, "Flow" = 4, "Instinct" = 4, "CounterMaster" = 5, "Godspeed" = 1)
		NeedsSword=0
		StyleSpd=1.75
		StyleOff=1.75
		StyleDef=1.75
		SignatureTechnique=4
		NoSword=1
		StyleActive="Perfected Ultra Instinct"
		verb/Perfected_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)