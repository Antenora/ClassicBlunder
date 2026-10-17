/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Zofiel
	form_name = "Zofiel"
	letter = "E"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Piskiel
	form_name = "Piskiel"
	letter = "J"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Barbarriel
	form_name = "Barbarriel"
	letter = "T"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Azhalbiora
	form_name = "Azhalbiora"
	letter = "Z"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Tatarforas
	form_name = "Tatarforas"
	letter = "F"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Pornipora
	form_name = "Pornipora"
	letter = "P"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Gagael
	form_name = "Gagael"
	letter = "G"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Gudoero
	form_name = "Gudoero"
	letter = "L"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Hasshein
	form_name = "Hasshein"
	letter = "D"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Jilliel
	form_name = "Jilliel"
	letter = "X"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Aschtonig
	form_name = "Aschtonig"
	letter = "M"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_A
	form_name = "Vollstandig"
	letter = "A"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_B
	form_name = "Vollstandig"
	letter = "B"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_C
	form_name = "Vollstandig"
	letter = "C"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_H
	form_name = "Vollstandig"
	letter = "H"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_I
	form_name = "Vollstandig"
	letter = "I"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_O
	form_name = "Vollstandig"
	letter = "O"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_Q
	form_name = "Vollstandig"
	letter = "Q"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_R
	form_name = "Vollstandig"
	letter = "R"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_S
	form_name = "Vollstandig"
	letter = "S"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_U
	form_name = "Vollstandig"
	letter = "U"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_V
	form_name = "Vollstandig"
	letter = "V"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_W
	form_name = "Vollstandig"
	letter = "W"

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_Y
	form_name = "Vollstandig"
	letter = "Y"

/proc/QuincyFormTypes()
	return list(\
		"A" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_A,\
		"B" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_B,\
		"C" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_C,\
		"D" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Hasshein,\
		"E" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Zofiel,\
		"F" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Tatarforas,\
		"G" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Gagael,\
		"H" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_H,\
		"I" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_I,\
		"J" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Piskiel,\
		"L" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Gudoero,\
		"M" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Aschtonig,\
		"O" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_O,\
		"P" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Pornipora,\
		"Q" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_Q,\
		"R" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_R,\
		"S" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_S,\
		"T" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Barbarriel,\
		"U" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_U,\
		"V" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_V,\
		"W" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_W,\
		"X" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Jilliel,\
		"Y" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Letter_Y,\
		"Z" = /obj/Skills/Buffs/SlotlessBuffs/Vollstandig/Azhalbiora)

/mob/Players/QuincyVollstandigType()
	if(src.QuincySchrift)
		var/list/forms = QuincyFormTypes()
		var/t = forms[src.QuincySchrift]
		if(ispath(t, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig))
			return t
	return ..()
