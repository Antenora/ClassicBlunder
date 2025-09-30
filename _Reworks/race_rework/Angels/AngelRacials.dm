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

*/
/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles
	Selfless_State //placeholder because I might implement the Demon Slayer thing. basically baby UI
		Copyable=0
		passives = list("Flow" = 2, "Deflection" = 1, "Soft Style" = 1)
		NeedsSword=0
		SignatureTechnique=1
		NoSword=1
		StyleActive="Selfless State"
		verb/Selfless_State()
			set hidden=1
			src.Trigger(usr)