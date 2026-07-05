/proc/InitDemonDatabase()
	// Build into a local list first to avoid BYOND 516 quirks where assigning to a
	// global list and immediately indexing it on the next line fails with "bad index".
	var/list/db = list()
	// Heqet (Avatar, Lv 13)
	var/datum/demon_data/_dd0 = new /datum/demon_data()
	_dd0.demon_name = "Heqet"
	_dd0.demon_race = "Avatar"
	_dd0.demon_lvl = 13
	_dd0.demon_str = 8
	_dd0.demon_for = 10
	_dd0.demon_end = 7
	_dd0.demon_spd = 4
	_dd0.demon_off = 4
	_dd0.demon_def = 4
	_dd0.demon_skills = list("Bufu")
	_dd0.demon_passives = list("Knight Soul")
	_dd0.demon_unique = FALSE
	_dd0.demon_icon = 'Icons/DevilSummoner/Demons/Heqet.dmi'
	_dd0.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Heqet128.dmi'
	_dd0.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Heqet32.dmi'
	db["Heqet"] = _dd0

	// Apis (Avatar, Lv 21)
	var/datum/demon_data/_dd1 = new /datum/demon_data()
	_dd1.demon_name = "Apis"
	_dd1.demon_race = "Avatar"
	_dd1.demon_lvl = 21
	_dd1.demon_str = 8
	_dd1.demon_for = 12
	_dd1.demon_end = 8
	_dd1.demon_spd = 9
	_dd1.demon_off = 4
	_dd1.demon_def = 4
	_dd1.demon_skills = list("Fire Dance")
	_dd1.demon_passives = list("Anti-Elec", "Moneybags")
	_dd1.demon_unique = TRUE
	_dd1.demon_icon = 'Icons/DevilSummoner/Demons/Apis.dmi'
	_dd1.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Apis128.dmi'
	_dd1.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Apis32.dmi'
	db["Apis"] = _dd1

	// Shiisaa (Avatar, Lv 28)
	var/datum/demon_data/_dd2 = new /datum/demon_data()
	_dd2.demon_name = "Shiisaa"
	_dd2.demon_race = "Avatar"
	_dd2.demon_lvl = 28
	_dd2.demon_str = 13
	_dd2.demon_for = 9
	_dd2.demon_end = 12
	_dd2.demon_spd = 10
	_dd2.demon_off = 7
	_dd2.demon_def = 6
	_dd2.demon_skills = list("Mazio", "Power Hit")
	_dd2.demon_passive_learn = list("Elec Boost" = 29)
	_dd2.demon_unique = FALSE
	_dd2.demon_icon = 'Icons/DevilSummoner/Demons/Shiisaa.dmi'
	_dd2.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Shiisaa128.dmi'
	_dd2.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Shiisaa32.dmi'
	db["Shiisaa"] = _dd2

	// Kamapua'a (Avatar, Lv 32)
	var/datum/demon_data/_dd3 = new /datum/demon_data()
	_dd3.demon_name = "Kamapua'a"
	_dd3.demon_race = "Avatar"
	_dd3.demon_lvl = 32
	_dd3.demon_str = 14
	_dd3.demon_for = 9
	_dd3.demon_end = 11
	_dd3.demon_spd = 14
	_dd3.demon_off = 7
	_dd3.demon_def = 6
	_dd3.demon_skills = list("Diarahan")
	_dd3.demon_passive_learn = list("Ares Aid" = 33)
	_dd3.demon_unique = TRUE
	_dd3.demon_icon = 'Icons/DevilSummoner/Demons/Kamapuaa.dmi'
	_dd3.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kamapuaa128.dmi'
	_dd3.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kamapuaa32.dmi'
	db["Kamapua'a"] = _dd3

	// Bai Ze (Avatar, Lv 37)
	var/datum/demon_data/_dd4 = new /datum/demon_data()
	_dd4.demon_name = "Bai Ze"
	_dd4.demon_race = "Avatar"
	_dd4.demon_lvl = 37
	_dd4.demon_str = 12
	_dd4.demon_for = 15
	_dd4.demon_end = 11
	_dd4.demon_spd = 15
	_dd4.demon_off = 6
	_dd4.demon_def = 6
	_dd4.demon_skills = list("Diarama")
	_dd4.demon_passive_learn = list("Anti-Ailment" = 38)
	_dd4.demon_unique = FALSE
	_dd4.demon_icon = 'Icons/DevilSummoner/Demons/Bai Ze.dmi'
	_dd4.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Bai Ze128.dmi'
	_dd4.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Bai Ze32.dmi'
	db["Bai Ze"] = _dd4

	// Pabilsag (Avatar, Lv 45)
	var/datum/demon_data/_dd5 = new /datum/demon_data()
	_dd5.demon_name = "Pabilsag"
	_dd5.demon_race = "Avatar"
	_dd5.demon_lvl = 45
	_dd5.demon_str = 19
	_dd5.demon_for = 11
	_dd5.demon_end = 18
	_dd5.demon_spd = 13
	_dd5.demon_off = 10
	_dd5.demon_def = 9
	_dd5.demon_skills = list("Taunt")
	_dd5.demon_passives = list("Crit Up")
	_dd5.demon_skill_learn = list("Multi-Strike" = 46)
	_dd5.demon_unique = TRUE
	_dd5.demon_icon = 'Icons/DevilSummoner/Demons/Pabilsag.dmi'
	_dd5.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pabilsag128.dmi'
	_dd5.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pabilsag32.dmi'
	db["Pabilsag"] = _dd5

	// Baihu (Avatar, Lv 53)
	var/datum/demon_data/_dd6 = new /datum/demon_data()
	_dd6.demon_name = "Baihu"
	_dd6.demon_race = "Avatar"
	_dd6.demon_lvl = 53
	_dd6.demon_str = 23
	_dd6.demon_for = 10
	_dd6.demon_end = 15
	_dd6.demon_spd = 21
	_dd6.demon_off = 12
	_dd6.demon_def = 8
	_dd6.demon_skills = list("Piercing Hit")
	_dd6.demon_passives = list("Double Strike")
	_dd6.demon_skill_learn = list("Multi-Strike" = 62, "Shield All" = 63)
	_dd6.demon_passive_learn = list("Phys Amp" = 55, "Force Drain" = 61)
	_dd6.demon_unique = FALSE
	_dd6.demon_icon = 'Icons/DevilSummoner/Demons/Baihu.dmi'
	_dd6.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Baihu128.dmi'
	_dd6.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Baihu32.dmi'
	db["Baihu"] = _dd6

	// Airavata (Avatar, Lv 60)
	var/datum/demon_data/_dd7 = new /datum/demon_data()
	_dd7.demon_name = "Airavata"
	_dd7.demon_race = "Avatar"
	_dd7.demon_lvl = 60
	_dd7.demon_str = 20
	_dd7.demon_for = 16
	_dd7.demon_end = 30
	_dd7.demon_spd = 10
	_dd7.demon_off = 10
	_dd7.demon_def = 15
	_dd7.demon_skills = list("Zandyne")
	_dd7.demon_skill_learn = list("Diarahan" = 70)
	_dd7.demon_passive_learn = list("Null Force" = 61, "Force Amp" = 62, "Life Bonus" = 68, "Life Surge" = 69)
	_dd7.demon_unique = FALSE
	_dd7.demon_icon = 'Icons/DevilSummoner/Demons/Airavata.dmi'
	_dd7.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Airavata128.dmi'
	_dd7.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Airavata32.dmi'
	db["Airavata"] = _dd7

	// Ukano Mitama (Avatar, Lv 64)
	var/datum/demon_data/_dd8 = new /datum/demon_data()
	_dd8.demon_name = "Ukano Mitama"
	_dd8.demon_race = "Avatar"
	_dd8.demon_lvl = 64
	_dd8.demon_str = 19
	_dd8.demon_for = 21
	_dd8.demon_end = 17
	_dd8.demon_spd = 23
	_dd8.demon_off = 10
	_dd8.demon_def = 9
	_dd8.demon_skills = list("Mazandyne")
	_dd8.demon_skill_learn = list("Mediarahan" = 65)
	_dd8.demon_passive_learn = list("Force Repel" = 66)
	_dd8.demon_unique = TRUE
	_dd8.demon_icon = 'Icons/DevilSummoner/Demons/Ukano Mitama.dmi'
	_dd8.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ukano Mitama128.dmi'
	_dd8.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ukano Mitama32.dmi'
	db["Ukano Mitama"] = _dd8

	// Barong (Avatar, Lv 68)
	var/datum/demon_data/_dd9 = new /datum/demon_data()
	_dd9.demon_name = "Barong"
	_dd9.demon_race = "Avatar"
	_dd9.demon_lvl = 68
	_dd9.demon_str = 24
	_dd9.demon_for = 22
	_dd9.demon_end = 19
	_dd9.demon_spd = 19
	_dd9.demon_off = 12
	_dd9.demon_def = 10
	_dd9.demon_skills = list("None")
	_dd9.demon_passives = list("Life Lift")
	_dd9.demon_passive_learn = list("Elec Drain" = 70)
	_dd9.demon_unique = FALSE
	_dd9.demon_icon = 'Icons/DevilSummoner/Demons/Barong.dmi'
	_dd9.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Barong128.dmi'
	_dd9.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Barong32.dmi'
	db["Barong"] = _dd9

	// Anubis (Avatar, Lv 76)
	var/datum/demon_data/_dd10 = new /datum/demon_data()
	_dd10.demon_name = "Anubis"
	_dd10.demon_race = "Avatar"
	_dd10.demon_lvl = 76
	_dd10.demon_str = 30
	_dd10.demon_for = 29
	_dd10.demon_end = 18
	_dd10.demon_spd = 15
	_dd10.demon_off = 15
	_dd10.demon_def = 9
	_dd10.demon_skills = list("Samarecarm")
	_dd10.demon_unique = TRUE
	_dd10.demon_icon = 'Icons/DevilSummoner/Demons/Anubis.dmi'
	_dd10.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Anubis128.dmi'
	_dd10.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Anubis32.dmi'
	db["Anubis"] = _dd10

	// Itsumade (Avian, Lv 8)
	var/datum/demon_data/_dd11 = new /datum/demon_data()
	_dd11.demon_name = "Itsumade"
	_dd11.demon_race = "Avian"
	_dd11.demon_lvl = 8
	_dd11.demon_str = 5
	_dd11.demon_for = 7
	_dd11.demon_end = 3
	_dd11.demon_spd = 9
	_dd11.demon_off = 3
	_dd11.demon_def = 2
	_dd11.demon_skills = list("Zan")
	_dd11.demon_skill_learn = list("Extra Cancel" = 9, "Force Dance" = 27)
	_dd11.demon_passive_learn = list("+Poison" = 10, "Hero Aid" = 26)
	_dd11.demon_unique = FALSE
	_dd11.demon_icon = 'Icons/DevilSummoner/Demons/Itsumade.dmi'
	_dd11.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Itsumade128.dmi'
	_dd11.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Itsumade32.dmi'
	db["Itsumade"] = _dd11

	// Moh Shuvuu (Avian, Lv 16)
	var/datum/demon_data/_dd12 = new /datum/demon_data()
	_dd12.demon_name = "Moh Shuvuu"
	_dd12.demon_race = "Avian"
	_dd12.demon_lvl = 16
	_dd12.demon_str = 9
	_dd12.demon_for = 6
	_dd12.demon_end = 7
	_dd12.demon_spd = 10
	_dd12.demon_off = 5
	_dd12.demon_def = 4
	_dd12.demon_skills = list("Bufu")
	_dd12.demon_skill_learn = list("Ice Dance" = 18, "Diarama" = 30, "Mabufu" = 31)
	_dd12.demon_passive_learn = list("Watchful" = 17, "Anti-Ailment" = 28, "Vigilant" = 29)
	_dd12.demon_unique = FALSE
	_dd12.demon_icon = 'Icons/DevilSummoner/Demons/Moh Shuvuu.dmi'
	_dd12.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Moh Shuvuu128.dmi'
	_dd12.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Moh Shuvuu32.dmi'
	db["Moh Shuvuu"] = _dd12

	// Hamsa (Avian, Lv 24)
	var/datum/demon_data/_dd13 = new /datum/demon_data()
	_dd13.demon_name = "Hamsa"
	_dd13.demon_race = "Avian"
	_dd13.demon_lvl = 24
	_dd13.demon_str = 9
	_dd13.demon_for = 6
	_dd13.demon_end = 10
	_dd13.demon_spd = 15
	_dd13.demon_off = 5
	_dd13.demon_def = 5
	_dd13.demon_skills = list("Mazan")
	_dd13.demon_skill_learn = list("Diarama" = 25, "Media" = 34)
	_dd13.demon_passive_learn = list("Dodge" = 30, "Force Boost" = 31, "Mana Surge" = 32, "Vigilant" = 33)
	_dd13.demon_unique = FALSE
	_dd13.demon_icon = 'Icons/DevilSummoner/Demons/Hamsa.dmi'
	_dd13.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hamsa128.dmi'
	_dd13.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hamsa32.dmi'
	db["Hamsa"] = _dd13

	// Suparna (Avian, Lv 31)
	var/datum/demon_data/_dd14 = new /datum/demon_data()
	_dd14.demon_name = "Suparna"
	_dd14.demon_race = "Avian"
	_dd14.demon_lvl = 31
	_dd14.demon_str = 9
	_dd14.demon_for = 13
	_dd14.demon_end = 10
	_dd14.demon_spd = 15
	_dd14.demon_off = 5
	_dd14.demon_def = 5
	_dd14.demon_skills = list("Mow Down")
	_dd14.demon_skill_learn = list("Force Dance" = 34, "Mazan" = 35)
	_dd14.demon_passive_learn = list("Force Boost" = 32, "Quick Move" = 33, "+Paralyze" = 36)
	_dd14.demon_unique = FALSE
	_dd14.demon_icon = 'Icons/DevilSummoner/Demons/Suparna.dmi'
	_dd14.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Suparna128.dmi'
	_dd14.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Suparna32.dmi'
	db["Suparna"] = _dd14

	// Vidofnir (Avian, Lv 39)
	var/datum/demon_data/_dd15 = new /datum/demon_data()
	_dd15.demon_name = "Vidofnir"
	_dd15.demon_race = "Avian"
	_dd15.demon_lvl = 39
	_dd15.demon_str = 16
	_dd15.demon_for = 11
	_dd15.demon_end = 10
	_dd15.demon_spd = 18
	_dd15.demon_off = 8
	_dd15.demon_def = 5
	_dd15.demon_skills = list("Mazio")
	_dd15.demon_skill_learn = list("Drain" = 41, "Multi-Strike" = 48, "Ziodyne" = 49)
	_dd15.demon_passive_learn = list("Swift Step" = 40, "Extra Bonus" = 47)
	_dd15.demon_unique = FALSE
	_dd15.demon_icon = 'Icons/DevilSummoner/Demons/Vidofnir.dmi'
	_dd15.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Vidofnir128.dmi'
	_dd15.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Vidofnir32.dmi'
	db["Vidofnir"] = _dd15

	// Badb Catha (Avian, Lv 46)
	var/datum/demon_data/_dd16 = new /datum/demon_data()
	_dd16.demon_name = "Badb Catha"
	_dd16.demon_race = "Avian"
	_dd16.demon_lvl = 46
	_dd16.demon_str = 18
	_dd16.demon_for = 12
	_dd16.demon_end = 18
	_dd16.demon_spd = 14
	_dd16.demon_off = 9
	_dd16.demon_def = 9
	_dd16.demon_skills = list("Might Call")
	_dd16.demon_passives = list("Extra One")
	_dd16.demon_skill_learn = list("Zandyne" = 47, "Mazandyne" = 56)
	_dd16.demon_passive_learn = list("Anti-Most" = 54, "Preserve Extra" = 55)
	_dd16.demon_unique = FALSE
	_dd16.demon_icon = 'Icons/DevilSummoner/Demons/Badb Catha.dmi'
	_dd16.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Badb Catha128.dmi'
	_dd16.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Badb Catha32.dmi'
	db["Badb Catha"] = _dd16

	// Anzu (Avian, Lv 54)
	var/datum/demon_data/_dd17 = new /datum/demon_data()
	_dd17.demon_name = "Anzu"
	_dd17.demon_race = "Avian"
	_dd17.demon_lvl = 54
	_dd17.demon_str = 20
	_dd17.demon_for = 13
	_dd17.demon_end = 15
	_dd17.demon_spd = 22
	_dd17.demon_off = 10
	_dd17.demon_def = 8
	_dd17.demon_skills = list("Mazandyne")
	_dd17.demon_skill_learn = list("Makarakarn" = 63, "Might Call" = 64, "Tetrakarn" = 65)
	_dd17.demon_passive_learn = list("Force Amp" = 62)
	_dd17.demon_unique = FALSE
	_dd17.demon_icon = 'Icons/DevilSummoner/Demons/Anzu.dmi'
	_dd17.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Anzu128.dmi'
	_dd17.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Anzu32.dmi'
	db["Anzu"] = _dd17

	// Feng Huang (Avian, Lv 62)
	var/datum/demon_data/_dd18 = new /datum/demon_data()
	_dd18.demon_name = "Feng Huang"
	_dd18.demon_race = "Avian"
	_dd18.demon_lvl = 62
	_dd18.demon_str = 16
	_dd18.demon_for = 20
	_dd18.demon_end = 15
	_dd18.demon_spd = 27
	_dd18.demon_off = 8
	_dd18.demon_def = 8
	_dd18.demon_skills = list("Inferno")
	_dd18.demon_skill_learn = list("Agidyne" = 70, "Recarm" = 71)
	_dd18.demon_passive_learn = list("Fire Drain" = 63, "Fire Amp" = 64)
	_dd18.demon_unique = FALSE
	_dd18.demon_icon = 'Icons/DevilSummoner/Demons/Feng Huang.dmi'
	_dd18.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Feng Huang128.dmi'
	_dd18.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Feng Huang32.dmi'
	db["Feng Huang"] = _dd18

	// Garuda (Avian, Lv 69)
	var/datum/demon_data/_dd19 = new /datum/demon_data()
	_dd19.demon_name = "Garuda"
	_dd19.demon_race = "Avian"
	_dd19.demon_lvl = 69
	_dd19.demon_str = 26
	_dd19.demon_for = 15
	_dd19.demon_end = 17
	_dd19.demon_spd = 27
	_dd19.demon_off = 13
	_dd19.demon_def = 9
	_dd19.demon_skills = list("Megidolaon")
	_dd19.demon_unique = FALSE
	_dd19.demon_icon = 'Icons/DevilSummoner/Demons/Garuda.dmi'
	_dd19.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Garuda128.dmi'
	_dd19.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Garuda32.dmi'
	db["Garuda"] = _dd19

	// Da Peng (Avian, Lv 77)
	var/datum/demon_data/_dd20 = new /datum/demon_data()
	_dd20.demon_name = "Da Peng"
	_dd20.demon_race = "Avian"
	_dd20.demon_lvl = 77
	_dd20.demon_str = 28
	_dd20.demon_for = 16
	_dd20.demon_end = 19
	_dd20.demon_spd = 30
	_dd20.demon_off = 14
	_dd20.demon_def = 10
	_dd20.demon_skills = list("Mediarahan")
	_dd20.demon_passive_learn = list("Life Lift" = 78)
	_dd20.demon_unique = FALSE
	_dd20.demon_icon = 'Icons/DevilSummoner/Demons/Da Peng.dmi'
	_dd20.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Da Peng128.dmi'
	_dd20.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Da Peng32.dmi'
	db["Da Peng"] = _dd20

	// Kabuso (Beast, Lv 2)
	var/datum/demon_data/_dd21 = new /datum/demon_data()
	_dd21.demon_name = "Kabuso"
	_dd21.demon_race = "Beast"
	_dd21.demon_lvl = 2
	_dd21.demon_str = 4
	_dd21.demon_for = 6
	_dd21.demon_end = 4
	_dd21.demon_spd = 4
	_dd21.demon_off = 2
	_dd21.demon_def = 2
	_dd21.demon_skills = list("Agi")
	_dd21.demon_skill_learn = list("Zan" = 4)
	_dd21.demon_passive_learn = list("+Poison" = 25, "Mana Bonus" = 26, "Watchful" = 27)
	_dd21.demon_unique = FALSE
	_dd21.demon_icon = 'Icons/DevilSummoner/Demons/Kabuso.dmi'
	_dd21.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kabuso128.dmi'
	_dd21.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kabuso32.dmi'
	db["Kabuso"] = _dd21

	// Hairy Jack (Beast, Lv 10)
	var/datum/demon_data/_dd22 = new /datum/demon_data()
	_dd22.demon_name = "Hairy Jack"
	_dd22.demon_race = "Beast"
	_dd22.demon_lvl = 10
	_dd22.demon_str = 7
	_dd22.demon_for = 5
	_dd22.demon_end = 5
	_dd22.demon_spd = 9
	_dd22.demon_off = 4
	_dd22.demon_def = 3
	_dd22.demon_skills = list("Anger Hit")
	_dd22.demon_passive_learn = list("+Poison" = 12, "Life Bonus" = 11)
	_dd22.demon_unique = FALSE
	_dd22.demon_icon = 'Icons/DevilSummoner/Demons/Hairy Jack.dmi'
	_dd22.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hairy Jack128.dmi'
	_dd22.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hairy Jack32.dmi'
	db["Hairy Jack"] = _dd22

	// Nekomata (Beast, Lv 19)
	var/datum/demon_data/_dd23 = new /datum/demon_data()
	_dd23.demon_name = "Nekomata"
	_dd23.demon_race = "Beast"
	_dd23.demon_lvl = 19
	_dd23.demon_str = 10
	_dd23.demon_for = 4
	_dd23.demon_end = 9
	_dd23.demon_spd = 12
	_dd23.demon_off = 5
	_dd23.demon_def = 5
	_dd23.demon_skills = list("Paral Eyes")
	_dd23.demon_passives = list("+Paralyze")
	_dd23.demon_skill_learn = list("Multi-Hit" = 21, "Media" = 31)
	_dd23.demon_passive_learn = list("Anti-Force" = 20, "Anti-Elec" = 29, "Double Strike" = 30)
	_dd23.demon_unique = FALSE
	_dd23.demon_icon = 'Icons/DevilSummoner/Demons/Nekomata.dmi'
	_dd23.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nekomata128.dmi'
	_dd23.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nekomata32.dmi'
	db["Nekomata"] = _dd23

	// Orthrus (Beast, Lv 27)
	var/datum/demon_data/_dd24 = new /datum/demon_data()
	_dd24.demon_name = "Orthrus"
	_dd24.demon_race = "Beast"
	_dd24.demon_lvl = 27
	_dd24.demon_str = 14
	_dd24.demon_for = 7
	_dd24.demon_end = 12
	_dd24.demon_spd = 10
	_dd24.demon_off = 7
	_dd24.demon_def = 6
	_dd24.demon_skills = list("Desperation")
	_dd24.demon_passives = list("Retaliate")
	_dd24.demon_skill_learn = list("Berserk" = 33, "Power Charge" = 34)
	_dd24.demon_passive_learn = list("Preserve Extra" = 28, "Crit Up" = 32)
	_dd24.demon_unique = FALSE
	_dd24.demon_icon = 'Icons/DevilSummoner/Demons/Orthrus.dmi'
	_dd24.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Orthrus128.dmi'
	_dd24.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Orthrus32.dmi'
	db["Orthrus"] = _dd24

	// Cait Sith (Beast, Lv 35)
	var/datum/demon_data/_dd25 = new /datum/demon_data()
	_dd25.demon_name = "Cait Sith"
	_dd25.demon_race = "Beast"
	_dd25.demon_lvl = 35
	_dd25.demon_str = 10
	_dd25.demon_for = 15
	_dd25.demon_end = 11
	_dd25.demon_spd = 15
	_dd25.demon_off = 5
	_dd25.demon_def = 6
	_dd25.demon_skills = list("Mazan")
	_dd25.demon_skill_learn = list("Mabufu" = 38, "Maragi" = 39)
	_dd25.demon_passive_learn = list("Fire Boost" = 36, "Life Surge" = 37, "Force Boost" = 40)
	_dd25.demon_unique = FALSE
	_dd25.demon_icon = 'Icons/DevilSummoner/Demons/Cait Sith.dmi'
	_dd25.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Cait Sith128.dmi'
	_dd25.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Cait Sith32.dmi'
	db["Cait Sith"] = _dd25

	// Nue (Beast, Lv 42)
	var/datum/demon_data/_dd26 = new /datum/demon_data()
	_dd26.demon_name = "Nue"
	_dd26.demon_race = "Beast"
	_dd26.demon_lvl = 42
	_dd26.demon_str = 19
	_dd26.demon_for = 12
	_dd26.demon_end = 15
	_dd26.demon_spd = 12
	_dd26.demon_off = 10
	_dd26.demon_def = 8
	_dd26.demon_skills = list("Ziodyne")
	_dd26.demon_skill_learn = list("Berserk" = 51, "Power Charge" = 52)
	_dd26.demon_passive_learn = list("Pierce" = 44, "Elec Boost" = 50)
	_dd26.demon_unique = FALSE
	_dd26.demon_icon = 'Icons/DevilSummoner/Demons/Nue.dmi'
	_dd26.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nue128.dmi'
	_dd26.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nue32.dmi'
	db["Nue"] = _dd26

	// Myrmecolion (Beast, Lv 50)
	var/datum/demon_data/_dd27 = new /datum/demon_data()
	_dd27.demon_name = "Myrmecolion"
	_dd27.demon_race = "Beast"
	_dd27.demon_lvl = 50
	_dd27.demon_str = 22
	_dd27.demon_for = 15
	_dd27.demon_end = 10
	_dd27.demon_spd = 19
	_dd27.demon_off = 11
	_dd27.demon_def = 5
	_dd27.demon_skills = list("Piercing Hit")
	_dd27.demon_passives = list("Drain Hit")
	_dd27.demon_skill_learn = list("Agidyne" = 60)
	_dd27.demon_passive_learn = list("Life Stream" = 58, "Pierce" = 59)
	_dd27.demon_unique = FALSE
	_dd27.demon_icon = 'Icons/DevilSummoner/Demons/Myrmecolion.dmi'
	_dd27.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Myrmecolion128.dmi'
	_dd27.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Myrmecolion32.dmi'
	db["Myrmecolion"] = _dd27

	// Cerberus (Beast, Lv 58)
	var/datum/demon_data/_dd28 = new /datum/demon_data()
	_dd28.demon_name = "Cerberus"
	_dd28.demon_race = "Beast"
	_dd28.demon_lvl = 58
	_dd28.demon_str = 25
	_dd28.demon_for = 11
	_dd28.demon_end = 17
	_dd28.demon_spd = 21
	_dd28.demon_off = 13
	_dd28.demon_def = 9
	_dd28.demon_skills = list("Agidyne")
	_dd28.demon_passives = list("Hero Soul")
	_dd28.demon_skill_learn = list("Deathbound" = 68, "Multi-Strike" = 69)
	_dd28.demon_passive_learn = list("Life Stream" = 66, "Pierce" = 67)
	_dd28.demon_unique = FALSE
	_dd28.demon_icon = 'Icons/DevilSummoner/Demons/Cerberus.dmi'
	_dd28.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Cerberus128.dmi'
	_dd28.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Cerberus32.dmi'
	db["Cerberus"] = _dd28

	// Fenrir (Beast, Lv 66)
	var/datum/demon_data/_dd29 = new /datum/demon_data()
	_dd29.demon_name = "Fenrir"
	_dd29.demon_race = "Beast"
	_dd29.demon_lvl = 66
	_dd29.demon_str = 22
	_dd29.demon_for = 23
	_dd29.demon_end = 12
	_dd29.demon_spd = 25
	_dd29.demon_off = 11
	_dd29.demon_def = 6
	_dd29.demon_skills = list("Piercing Hit")
	_dd29.demon_passives = list("Double Strike")
	_dd29.demon_unique = FALSE
	_dd29.demon_icon = 'Icons/DevilSummoner/Demons/Fenrir.dmi'
	_dd29.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Fenrir128.dmi'
	_dd29.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Fenrir32.dmi'
	db["Fenrir"] = _dd29

	// Mahakala (Deity, Lv 22)
	var/datum/demon_data/_dd30 = new /datum/demon_data()
	_dd30.demon_name = "Mahakala"
	_dd30.demon_race = "Deity"
	_dd30.demon_lvl = 22
	_dd30.demon_str = 11
	_dd30.demon_for = 11
	_dd30.demon_end = 9
	_dd30.demon_spd = 7
	_dd30.demon_off = 6
	_dd30.demon_def = 5
	_dd30.demon_skills = list("None")
	_dd30.demon_passives = list("Quick Move")
	_dd30.demon_passive_learn = list("Double Strike" = 23)
	_dd30.demon_unique = FALSE
	_dd30.demon_icon = 'Icons/DevilSummoner/Demons/Mahakala.dmi'
	_dd30.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mahakala128.dmi'
	_dd30.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mahakala32.dmi'
	db["Mahakala"] = _dd30

	// Thor (Deity, Lv 29)
	var/datum/demon_data/_dd31 = new /datum/demon_data()
	_dd31.demon_name = "Thor"
	_dd31.demon_race = "Deity"
	_dd31.demon_lvl = 29
	_dd31.demon_str = 21
	_dd31.demon_for = 5
	_dd31.demon_end = 16
	_dd31.demon_spd = 3
	_dd31.demon_off = 11
	_dd31.demon_def = 8
	_dd31.demon_skills = list("Mazio")
	_dd31.demon_passive_learn = list("Ares Aid" = 30)
	_dd31.demon_unique = TRUE
	_dd31.demon_icon = 'Icons/DevilSummoner/Demons/Thor.dmi'
	_dd31.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Thor128.dmi'
	_dd31.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Thor32.dmi'
	db["Thor"] = _dd31

	// Arahabaki (Deity, Lv 33)
	var/datum/demon_data/_dd32 = new /datum/demon_data()
	_dd32.demon_name = "Arahabaki"
	_dd32.demon_race = "Deity"
	_dd32.demon_lvl = 33
	_dd32.demon_str = 18
	_dd32.demon_for = 13
	_dd32.demon_end = 12
	_dd32.demon_spd = 6
	_dd32.demon_off = 9
	_dd32.demon_def = 6
	_dd32.demon_skills = list("Bufudyne")
	_dd32.demon_passive_learn = list("Life Aid" = 35)
	_dd32.demon_unique = TRUE
	_dd32.demon_icon = 'Icons/DevilSummoner/Demons/Arahabaki.dmi'
	_dd32.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Arahabaki128.dmi'
	_dd32.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Arahabaki32.dmi'
	db["Arahabaki"] = _dd32

	// Odin (Deity, Lv 37)
	var/datum/demon_data/_dd33 = new /datum/demon_data()
	_dd33.demon_name = "Odin"
	_dd33.demon_race = "Deity"
	_dd33.demon_lvl = 37
	_dd33.demon_str = 13
	_dd33.demon_for = 20
	_dd33.demon_end = 11
	_dd33.demon_spd = 9
	_dd33.demon_off = 7
	_dd33.demon_def = 6
	_dd33.demon_skills = list("Ziodyne")
	_dd33.demon_passives = list("Null Elec")
	_dd33.demon_unique = TRUE
	_dd33.demon_icon = 'Icons/DevilSummoner/Demons/Odin.dmi'
	_dd33.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Odin128.dmi'
	_dd33.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Odin32.dmi'
	db["Odin"] = _dd33

	// Yama (Deity, Lv 41)
	var/datum/demon_data/_dd34 = new /datum/demon_data()
	_dd34.demon_name = "Yama"
	_dd34.demon_race = "Deity"
	_dd34.demon_lvl = 41
	_dd34.demon_str = 20
	_dd34.demon_for = 15
	_dd34.demon_end = 12
	_dd34.demon_spd = 10
	_dd34.demon_off = 10
	_dd34.demon_def = 6
	_dd34.demon_skills = list("Agidyne")
	_dd34.demon_passives = list("Null Fire")
	_dd34.demon_unique = TRUE
	_dd34.demon_icon = 'Icons/DevilSummoner/Demons/Yama.dmi'
	_dd34.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Yama128.dmi'
	_dd34.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Yama32.dmi'
	db["Yama"] = _dd34

	// Inti (Deity, Lv 45)
	var/datum/demon_data/_dd35 = new /datum/demon_data()
	_dd35.demon_name = "Inti"
	_dd35.demon_race = "Deity"
	_dd35.demon_lvl = 45
	_dd35.demon_str = 20
	_dd35.demon_for = 20
	_dd35.demon_end = 10
	_dd35.demon_spd = 11
	_dd35.demon_off = 10
	_dd35.demon_def = 5
	_dd35.demon_skills = list("Zandyne")
	_dd35.demon_skill_learn = list("Ziodyne" = 46)
	_dd35.demon_passive_learn = list("Dual Shadow" = 47)
	_dd35.demon_unique = TRUE
	_dd35.demon_icon = 'Icons/DevilSummoner/Demons/Inti.dmi'
	_dd35.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Inti128.dmi'
	_dd35.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Inti32.dmi'
	db["Inti"] = _dd35

	// Mithra (Deity, Lv 49)
	var/datum/demon_data/_dd36 = new /datum/demon_data()
	_dd36.demon_name = "Mithra"
	_dd36.demon_race = "Deity"
	_dd36.demon_lvl = 49
	_dd36.demon_str = 15
	_dd36.demon_for = 26
	_dd36.demon_end = 15
	_dd36.demon_spd = 9
	_dd36.demon_off = 8
	_dd36.demon_def = 8
	_dd36.demon_skills = list("Megido")
	_dd36.demon_passive_learn = list("Mana Stream" = 50)
	_dd36.demon_unique = TRUE
	_dd36.demon_icon = 'Icons/DevilSummoner/Demons/Mithra.dmi'
	_dd36.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mithra128.dmi'
	_dd36.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mithra32.dmi'
	db["Mithra"] = _dd36

	// Osiris (Deity, Lv 53)
	var/datum/demon_data/_dd37 = new /datum/demon_data()
	_dd37.demon_name = "Osiris"
	_dd37.demon_race = "Deity"
	_dd37.demon_lvl = 53
	_dd37.demon_str = 21
	_dd37.demon_for = 19
	_dd37.demon_end = 17
	_dd37.demon_spd = 12
	_dd37.demon_off = 11
	_dd37.demon_def = 9
	_dd37.demon_skills = list("Makarakarn")
	_dd37.demon_skill_learn = list("Megido" = 55)
	_dd37.demon_unique = TRUE
	_dd37.demon_icon = 'Icons/DevilSummoner/Demons/Osiris.dmi'
	_dd37.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Osiris128.dmi'
	_dd37.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Osiris32.dmi'
	db["Osiris"] = _dd37

	// Lugh (Deity, Lv 57)
	var/datum/demon_data/_dd38 = new /datum/demon_data()
	_dd38.demon_name = "Lugh"
	_dd38.demon_race = "Deity"
	_dd38.demon_lvl = 57
	_dd38.demon_str = 22
	_dd38.demon_for = 22
	_dd38.demon_end = 15
	_dd38.demon_spd = 14
	_dd38.demon_off = 11
	_dd38.demon_def = 8
	_dd38.demon_skills = list("Maragi")
	_dd38.demon_skill_learn = list("Deathbound" = 59)
	_dd38.demon_passive_learn = list("Phys Amp" = 58)
	_dd38.demon_unique = TRUE
	_dd38.demon_icon = 'Icons/DevilSummoner/Demons/Lugh.dmi'
	_dd38.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lugh128.dmi'
	_dd38.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lugh32.dmi'
	db["Lugh"] = _dd38

	// Alilat (Deity, Lv 61)
	var/datum/demon_data/_dd39 = new /datum/demon_data()
	_dd39.demon_name = "Alilat"
	_dd39.demon_race = "Deity"
	_dd39.demon_lvl = 61
	_dd39.demon_str = 24
	_dd39.demon_for = 25
	_dd39.demon_end = 14
	_dd39.demon_spd = 14
	_dd39.demon_off = 12
	_dd39.demon_def = 7
	_dd39.demon_skills = list("Megidolaon")
	_dd39.demon_unique = TRUE
	_dd39.demon_icon = 'Icons/DevilSummoner/Demons/Alilat.dmi'
	_dd39.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Alilat128.dmi'
	_dd39.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Alilat32.dmi'
	db["Alilat"] = _dd39

	// Baal (Deity, Lv 65)
	var/datum/demon_data/_dd40 = new /datum/demon_data()
	_dd40.demon_name = "Baal"
	_dd40.demon_race = "Deity"
	_dd40.demon_lvl = 65
	_dd40.demon_str = 23
	_dd40.demon_for = 29
	_dd40.demon_end = 14
	_dd40.demon_spd = 15
	_dd40.demon_off = 12
	_dd40.demon_def = 7
	_dd40.demon_skills = list("None")
	_dd40.demon_passives = list("Elec Amp")
	_dd40.demon_passive_learn = list("Fire Amp" = 66, "Ice Amp" = 67)
	_dd40.demon_unique = TRUE
	_dd40.demon_icon = 'Icons/DevilSummoner/Demons/Baal.dmi'
	_dd40.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Baal128.dmi'
	_dd40.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Baal32.dmi'
	db["Baal"] = _dd40

	// Lord Nan Dou (Deity, Lv 70)
	var/datum/demon_data/_dd41 = new /datum/demon_data()
	_dd41.demon_name = "Lord Nan Dou"
	_dd41.demon_race = "Deity"
	_dd41.demon_lvl = 70
	_dd41.demon_str = 20
	_dd41.demon_for = 28
	_dd41.demon_end = 23
	_dd41.demon_spd = 15
	_dd41.demon_off = 10
	_dd41.demon_def = 12
	_dd41.demon_skills = list("Samarecarm")
	_dd41.demon_unique = TRUE
	_dd41.demon_icon = 'Icons/DevilSummoner/Demons/Lord Nan Dou.dmi'
	_dd41.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lord Nan Dou128.dmi'
	_dd41.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lord Nan Dou32.dmi'
	db["Lord Nan Dou"] = _dd41

	// Asura (Deity, Lv 77)
	var/datum/demon_data/_dd42 = new /datum/demon_data()
	_dd42.demon_name = "Asura"
	_dd42.demon_race = "Deity"
	_dd42.demon_lvl = 77
	_dd42.demon_str = 27
	_dd42.demon_for = 23
	_dd42.demon_end = 23
	_dd42.demon_spd = 20
	_dd42.demon_off = 14
	_dd42.demon_def = 12
	_dd42.demon_skills = list("Megidolaon")
	_dd42.demon_skill_learn = list("Inferno" = 78)
	_dd42.demon_unique = TRUE
	_dd42.demon_icon = 'Icons/DevilSummoner/Demons/Asura.dmi'
	_dd42.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Asura128.dmi'
	_dd42.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Asura32.dmi'
	db["Asura"] = _dd42

	// Angel (Divine, Lv 15)
	var/datum/demon_data/_dd43 = new /datum/demon_data()
	_dd43.demon_name = "Angel"
	_dd43.demon_race = "Divine"
	_dd43.demon_lvl = 15
	_dd43.demon_str = 7
	_dd43.demon_for = 10
	_dd43.demon_end = 7
	_dd43.demon_spd = 7
	_dd43.demon_off = 4
	_dd43.demon_def = 4
	_dd43.demon_skills = list("Dia", "Force Dance")
	_dd43.demon_unique = FALSE
	_dd43.demon_icon = 'Icons/DevilSummoner/Demons/Angel.dmi'
	_dd43.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Angel128.dmi'
	_dd43.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Angel32.dmi'
	db["Angel"] = _dd43

	// Power (Divine, Lv 24)
	var/datum/demon_data/_dd44 = new /datum/demon_data()
	_dd44.demon_name = "Power"
	_dd44.demon_race = "Divine"
	_dd44.demon_lvl = 24
	_dd44.demon_str = 15
	_dd44.demon_for = 7
	_dd44.demon_end = 13
	_dd44.demon_spd = 5
	_dd44.demon_off = 8
	_dd44.demon_def = 7
	_dd44.demon_skills = list("Extra Cancel")
	_dd44.demon_passive_learn = list("Anti-Elec" = 26, "Vigilant" = 25)
	_dd44.demon_unique = FALSE
	_dd44.demon_icon = 'Icons/DevilSummoner/Demons/Power.dmi'
	_dd44.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Power128.dmi'
	_dd44.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Power32.dmi'
	db["Power"] = _dd44

	// Lailah (Divine, Lv 32)
	var/datum/demon_data/_dd45 = new /datum/demon_data()
	_dd45.demon_name = "Lailah"
	_dd45.demon_race = "Divine"
	_dd45.demon_lvl = 32
	_dd45.demon_str = 12
	_dd45.demon_for = 16
	_dd45.demon_end = 9
	_dd45.demon_spd = 11
	_dd45.demon_off = 6
	_dd45.demon_def = 5
	_dd45.demon_skills = list("Mabufu")
	_dd45.demon_passives = list("Extra Bonus")
	_dd45.demon_skill_learn = list("Recarm" = 34)
	_dd45.demon_passive_learn = list("Ice Boost" = 33)
	_dd45.demon_unique = FALSE
	_dd45.demon_icon = 'Icons/DevilSummoner/Demons/Lailah.dmi'
	_dd45.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lailah128.dmi'
	_dd45.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lailah32.dmi'
	db["Lailah"] = _dd45

	// Aniel (Divine, Lv 42)
	var/datum/demon_data/_dd46 = new /datum/demon_data()
	_dd46.demon_name = "Aniel"
	_dd46.demon_race = "Divine"
	_dd46.demon_lvl = 42
	_dd46.demon_str = 19
	_dd46.demon_for = 10
	_dd46.demon_end = 17
	_dd46.demon_spd = 12
	_dd46.demon_off = 10
	_dd46.demon_def = 9
	_dd46.demon_skills = list("Drain")
	_dd46.demon_passive_learn = list("Null Ice" = 44, "Swift Step" = 43)
	_dd46.demon_unique = FALSE
	_dd46.demon_icon = 'Icons/DevilSummoner/Demons/Aniel.dmi'
	_dd46.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Aniel128.dmi'
	_dd46.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Aniel32.dmi'
	db["Aniel"] = _dd46

	// Kazfiel (Divine, Lv 50)
	var/datum/demon_data/_dd47 = new /datum/demon_data()
	_dd47.demon_name = "Kazfiel"
	_dd47.demon_race = "Divine"
	_dd47.demon_lvl = 50
	_dd47.demon_str = 21
	_dd47.demon_for = 16
	_dd47.demon_end = 18
	_dd47.demon_spd = 11
	_dd47.demon_off = 11
	_dd47.demon_def = 9
	_dd47.demon_skills = list("Judgement")
	_dd47.demon_passive_learn = list("Ice Repel" = 52)
	_dd47.demon_unique = FALSE
	_dd47.demon_icon = 'Icons/DevilSummoner/Demons/Kazfiel.dmi'
	_dd47.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kazfiel128.dmi'
	_dd47.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kazfiel32.dmi'
	db["Kazfiel"] = _dd47

	// Remiel (Divine, Lv 59)
	var/datum/demon_data/_dd48 = new /datum/demon_data()
	_dd48.demon_name = "Remiel"
	_dd48.demon_race = "Divine"
	_dd48.demon_lvl = 59
	_dd48.demon_str = 22
	_dd48.demon_for = 21
	_dd48.demon_end = 16
	_dd48.demon_spd = 16
	_dd48.demon_off = 11
	_dd48.demon_def = 8
	_dd48.demon_skills = list("Samarecarm")
	_dd48.demon_passive_learn = list("Phys Drain" = 61)
	_dd48.demon_unique = TRUE
	_dd48.demon_icon = 'Icons/DevilSummoner/Demons/Remiel.dmi'
	_dd48.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Remiel128.dmi'
	_dd48.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Remiel32.dmi'
	db["Remiel"] = _dd48

	// Metatron (Divine, Lv 74)
	var/datum/demon_data/_dd49 = new /datum/demon_data()
	_dd49.demon_name = "Metatron"
	_dd49.demon_race = "Divine"
	_dd49.demon_lvl = 74
	_dd49.demon_str = 24
	_dd49.demon_for = 26
	_dd49.demon_end = 22
	_dd49.demon_spd = 18
	_dd49.demon_off = 12
	_dd49.demon_def = 11
	_dd49.demon_skills = list("Fire of Sinai")
	_dd49.demon_passives = list("Victory Cry")
	_dd49.demon_unique = TRUE
	_dd49.demon_icon = 'Icons/DevilSummoner/Demons/Metatron.dmi'
	_dd49.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Metatron128.dmi'
	_dd49.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Metatron32.dmi'
	db["Metatron"] = _dd49

	// Toubyou (Dragon, Lv 12)
	var/datum/demon_data/_dd50 = new /datum/demon_data()
	_dd50.demon_name = "Toubyou"
	_dd50.demon_race = "Dragon"
	_dd50.demon_lvl = 12
	_dd50.demon_str = 7
	_dd50.demon_for = 8
	_dd50.demon_end = 5
	_dd50.demon_spd = 8
	_dd50.demon_off = 4
	_dd50.demon_def = 3
	_dd50.demon_skills = list("Zio")
	_dd50.demon_passives = list("Life Bonus")
	_dd50.demon_skill_learn = list("Elec Dance" = 13, "Nigayomogi" = 38)
	_dd50.demon_passive_learn = list("Anti-Elec" = 36, "Mana Bonus" = 37)
	_dd50.demon_unique = FALSE
	_dd50.demon_icon = 'Icons/DevilSummoner/Demons/Toubyou.dmi'
	_dd50.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Toubyou128.dmi'
	_dd50.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Toubyou32.dmi'
	db["Toubyou"] = _dd50

	// Bai Suzhen (Dragon, Lv 20)
	var/datum/demon_data/_dd51 = new /datum/demon_data()
	_dd51.demon_name = "Bai Suzhen"
	_dd51.demon_race = "Dragon"
	_dd51.demon_lvl = 20
	_dd51.demon_str = 10
	_dd51.demon_for = 9
	_dd51.demon_end = 7
	_dd51.demon_spd = 10
	_dd51.demon_off = 5
	_dd51.demon_def = 4
	_dd51.demon_skills = list("Diarama")
	_dd51.demon_passive_learn = list("Grimoire" = 22)
	_dd51.demon_unique = FALSE
	_dd51.demon_icon = 'Icons/DevilSummoner/Demons/Bai Suzhen.dmi'
	_dd51.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Bai Suzhen128.dmi'
	_dd51.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Bai Suzhen32.dmi'
	db["Bai Suzhen"] = _dd51

	// Basilisk (Dragon, Lv 28)
	var/datum/demon_data/_dd52 = new /datum/demon_data()
	_dd52.demon_name = "Basilisk"
	_dd52.demon_race = "Dragon"
	_dd52.demon_lvl = 28
	_dd52.demon_str = 13
	_dd52.demon_for = 13
	_dd52.demon_end = 10
	_dd52.demon_spd = 8
	_dd52.demon_off = 7
	_dd52.demon_def = 5
	_dd52.demon_skills = list("Petra Eyes")
	_dd52.demon_passives = list("Anti-Force")
	_dd52.demon_skill_learn = list("Fire Dance" = 42, "Power Hit" = 43)
	_dd52.demon_passive_learn = list("+Stone" = 30, "Anti-Phys" = 40, "Grimoire" = 41)
	_dd52.demon_unique = FALSE
	_dd52.demon_icon = 'Icons/DevilSummoner/Demons/Basilisk.dmi'
	_dd52.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Basilisk128.dmi'
	_dd52.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Basilisk32.dmi'
	db["Basilisk"] = _dd52

	// Asp (Dragon, Lv 36)
	var/datum/demon_data/_dd53 = new /datum/demon_data()
	_dd53.demon_name = "Asp"
	_dd53.demon_race = "Dragon"
	_dd53.demon_lvl = 36
	_dd53.demon_str = 9
	_dd53.demon_for = 15
	_dd53.demon_end = 11
	_dd53.demon_spd = 17
	_dd53.demon_off = 5
	_dd53.demon_def = 6
	_dd53.demon_skills = list("Weak Kill")
	_dd53.demon_skill_learn = list("Life Drain" = 38)
	_dd53.demon_passive_learn = list("Drain Hit" = 37)
	_dd53.demon_unique = FALSE
	_dd53.demon_icon = 'Icons/DevilSummoner/Demons/Asp.dmi'
	_dd53.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Asp128.dmi'
	_dd53.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Asp32.dmi'
	db["Asp"] = _dd53

	// Ym (Dragon, Lv 44)
	var/datum/demon_data/_dd54 = new /datum/demon_data()
	_dd54.demon_name = "Ym"
	_dd54.demon_race = "Dragon"
	_dd54.demon_lvl = 44
	_dd54.demon_str = 14
	_dd54.demon_for = 18
	_dd54.demon_end = 11
	_dd54.demon_spd = 17
	_dd54.demon_off = 7
	_dd54.demon_def = 6
	_dd54.demon_skills = list("Petra Eyes")
	_dd54.demon_skill_learn = list("Holy Dance" = 47)
	_dd54.demon_passive_learn = list("Dual Shadow" = 45, "Mana Surge" = 46)
	_dd54.demon_unique = FALSE
	_dd54.demon_icon = 'Icons/DevilSummoner/Demons/Ym.dmi'
	_dd54.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ym128.dmi'
	_dd54.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ym32.dmi'
	db["Ym"] = _dd54

	// Python (Dragon, Lv 51)
	var/datum/demon_data/_dd55 = new /datum/demon_data()
	_dd55.demon_name = "Python"
	_dd55.demon_race = "Dragon"
	_dd55.demon_lvl = 51
	_dd55.demon_str = 13
	_dd55.demon_for = 25
	_dd55.demon_end = 12
	_dd55.demon_spd = 17
	_dd55.demon_off = 7
	_dd55.demon_def = 6
	_dd55.demon_skills = list("Agidyne")
	_dd55.demon_skill_learn = list("Bufudyne" = 63, "Megido" = 64)
	_dd55.demon_passive_learn = list("Dual Shadow" = 59, "Fire Amp" = 60, "Ice Amp" = 61, "Mana Stream" = 62)
	_dd55.demon_unique = FALSE
	_dd55.demon_icon = 'Icons/DevilSummoner/Demons/Python.dmi'
	_dd55.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Python128.dmi'
	_dd55.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Python32.dmi'
	db["Python"] = _dd55

	// Culebre (Dragon, Lv 58)
	var/datum/demon_data/_dd56 = new /datum/demon_data()
	_dd56.demon_name = "Culebre"
	_dd56.demon_race = "Dragon"
	_dd56.demon_lvl = 58
	_dd56.demon_str = 18
	_dd56.demon_for = 23
	_dd56.demon_end = 15
	_dd56.demon_spd = 18
	_dd56.demon_off = 9
	_dd56.demon_def = 8
	_dd56.demon_skills = list("Bufudyne")
	_dd56.demon_skill_learn = list("Mabufudyne" = 59)
	_dd56.demon_passive_learn = list("Ice Repel" = 60, "Anti-Most" = 66, "Ice Amp" = 67, "Ice Boost" = 68)
	_dd56.demon_unique = FALSE
	_dd56.demon_icon = 'Icons/DevilSummoner/Demons/Culebre.dmi'
	_dd56.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Culebre128.dmi'
	_dd56.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Culebre32.dmi'
	db["Culebre"] = _dd56

	// Vritra (Dragon, Lv 65)
	var/datum/demon_data/_dd57 = new /datum/demon_data()
	_dd57.demon_name = "Vritra"
	_dd57.demon_race = "Dragon"
	_dd57.demon_lvl = 65
	_dd57.demon_str = 30
	_dd57.demon_for = 16
	_dd57.demon_end = 22
	_dd57.demon_spd = 13
	_dd57.demon_off = 15
	_dd57.demon_def = 11
	_dd57.demon_skills = list("Maziodyne")
	_dd57.demon_unique = FALSE
	_dd57.demon_icon = 'Icons/DevilSummoner/Demons/Vritra.dmi'
	_dd57.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Vritra128.dmi'
	_dd57.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Vritra32.dmi'
	db["Vritra"] = _dd57

	// Vasuki (Dragon, Lv 73)
	var/datum/demon_data/_dd58 = new /datum/demon_data()
	_dd58.demon_name = "Vasuki"
	_dd58.demon_race = "Dragon"
	_dd58.demon_lvl = 73
	_dd58.demon_str = 30
	_dd58.demon_for = 18
	_dd58.demon_end = 24
	_dd58.demon_spd = 17
	_dd58.demon_off = 15
	_dd58.demon_def = 12
	_dd58.demon_skills = list("None")
	_dd58.demon_unique = TRUE
	_dd58.demon_icon = 'Icons/DevilSummoner/Demons/Vasuki.dmi'
	_dd58.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Vasuki128.dmi'
	_dd58.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Vasuki32.dmi'
	db["Vasuki"] = _dd58

	// Erthys (Element, Lv 7)
	var/datum/demon_data/_dd59 = new /datum/demon_data()
	_dd59.demon_name = "Erthys"
	_dd59.demon_race = "Element"
	_dd59.demon_lvl = 7
	_dd59.demon_str = 6
	_dd59.demon_for = 5
	_dd59.demon_end = 8
	_dd59.demon_spd = 4
	_dd59.demon_off = 3
	_dd59.demon_def = 4
	_dd59.demon_skills = list("Amrita")
	_dd59.demon_passive_learn = list("Phys Up" = 8)
	_dd59.demon_unique = FALSE
	_dd59.demon_icon = 'Icons/DevilSummoner/Demons/Erthys.dmi'
	_dd59.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Erthys128.dmi'
	_dd59.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Erthys32.dmi'
	db["Erthys"] = _dd59

	// Aeros (Element, Lv 12)
	var/datum/demon_data/_dd60 = new /datum/demon_data()
	_dd60.demon_name = "Aeros"
	_dd60.demon_race = "Element"
	_dd60.demon_lvl = 12
	_dd60.demon_str = 5
	_dd60.demon_for = 8
	_dd60.demon_end = 6
	_dd60.demon_spd = 9
	_dd60.demon_off = 3
	_dd60.demon_def = 3
	_dd60.demon_skills = list("Zio")
	_dd60.demon_unique = FALSE
	_dd60.demon_icon = 'Icons/DevilSummoner/Demons/Aeros.dmi'
	_dd60.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Aeros128.dmi'
	_dd60.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Aeros32.dmi'
	db["Aeros"] = _dd60

	// Aquans (Element, Lv 17)
	var/datum/demon_data/_dd61 = new /datum/demon_data()
	_dd61.demon_name = "Aquans"
	_dd61.demon_race = "Element"
	_dd61.demon_lvl = 17
	_dd61.demon_str = 7
	_dd61.demon_for = 11
	_dd61.demon_end = 7
	_dd61.demon_spd = 8
	_dd61.demon_off = 4
	_dd61.demon_def = 4
	_dd61.demon_skills = list("Ice Dance")
	_dd61.demon_unique = FALSE
	_dd61.demon_icon = 'Icons/DevilSummoner/Demons/Aquans.dmi'
	_dd61.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Aquans128.dmi'
	_dd61.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Aquans32.dmi'
	db["Aquans"] = _dd61

	// Flaemis (Element, Lv 22)
	var/datum/demon_data/_dd62 = new /datum/demon_data()
	_dd62.demon_name = "Flaemis"
	_dd62.demon_race = "Element"
	_dd62.demon_lvl = 22
	_dd62.demon_str = 9
	_dd62.demon_for = 13
	_dd62.demon_end = 8
	_dd62.demon_spd = 8
	_dd62.demon_off = 5
	_dd62.demon_def = 4
	_dd62.demon_skills = list("Maragi")
	_dd62.demon_unique = FALSE
	_dd62.demon_icon = 'Icons/DevilSummoner/Demons/Flaemis.dmi'
	_dd62.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Flaemis128.dmi'
	_dd62.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Flaemis32.dmi'
	db["Flaemis"] = _dd62

	// Pixie (Fairy, Lv 2)
	var/datum/demon_data/_dd63 = new /datum/demon_data()
	_dd63.demon_name = "Pixie"
	_dd63.demon_race = "Fairy"
	_dd63.demon_lvl = 2
	_dd63.demon_str = 3
	_dd63.demon_for = 7
	_dd63.demon_end = 4
	_dd63.demon_spd = 4
	_dd63.demon_off = 2
	_dd63.demon_def = 2
	_dd63.demon_skills = list("Dia")
	_dd63.demon_skill_learn = list("Zio" = 4, "Bufu" = 22)
	_dd63.demon_passive_learn = list("Mana Bonus" = 20, "Moneybags" = 21)
	_dd63.demon_unique = FALSE
	_dd63.demon_icon = 'Icons/DevilSummoner/Demons/Pixie.dmi'
	_dd63.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pixie128.dmi'
	_dd63.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pixie32.dmi'
	db["Pixie"] = _dd63

	// Knocker (Fairy, Lv 7)
	var/datum/demon_data/_dd64 = new /datum/demon_data()
	_dd64.demon_name = "Knocker"
	_dd64.demon_race = "Fairy"
	_dd64.demon_lvl = 7
	_dd64.demon_str = 7
	_dd64.demon_for = 4
	_dd64.demon_end = 8
	_dd64.demon_spd = 4
	_dd64.demon_off = 4
	_dd64.demon_def = 4
	_dd64.demon_skills = list("Zan")
	_dd64.demon_passives = list("Extra Bonus")
	_dd64.demon_skill_learn = list("Dia" = 8, "Extra Cancel" = 24)
	_dd64.demon_passive_learn = list("Anti-Force" = 22, "Race-D" = 23)
	_dd64.demon_unique = FALSE
	_dd64.demon_icon = 'Icons/DevilSummoner/Demons/Knocker.dmi'
	_dd64.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Knocker128.dmi'
	_dd64.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Knocker32.dmi'
	db["Knocker"] = _dd64

	// Kijimuna (Fairy, Lv 14)
	var/datum/demon_data/_dd65 = new /datum/demon_data()
	_dd65.demon_name = "Kijimuna"
	_dd65.demon_race = "Fairy"
	_dd65.demon_lvl = 14
	_dd65.demon_str = 6
	_dd65.demon_for = 8
	_dd65.demon_end = 6
	_dd65.demon_spd = 10
	_dd65.demon_off = 3
	_dd65.demon_def = 3
	_dd65.demon_skills = list("Force Dance")
	_dd65.demon_passives = list("Mana Bonus")
	_dd65.demon_unique = FALSE
	_dd65.demon_icon = 'Icons/DevilSummoner/Demons/Kijimuna.dmi'
	_dd65.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kijimuna128.dmi'
	_dd65.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kijimuna32.dmi'
	db["Kijimuna"] = _dd65

	// Jack Frost (Fairy, Lv 21)
	var/datum/demon_data/_dd66 = new /datum/demon_data()
	_dd66.demon_name = "Jack Frost"
	_dd66.demon_race = "Fairy"
	_dd66.demon_lvl = 21
	_dd66.demon_str = 9
	_dd66.demon_for = 12
	_dd66.demon_end = 10
	_dd66.demon_spd = 6
	_dd66.demon_off = 5
	_dd66.demon_def = 5
	_dd66.demon_skills = list("Ice Dance")
	_dd66.demon_skill_learn = list("Mabufu" = 22, "Diarama" = 28)
	_dd66.demon_passive_learn = list("Anti-Ice" = 23, "Ice Boost" = 26, "Mana Surge" = 27)
	_dd66.demon_unique = FALSE
	_dd66.demon_icon = 'Icons/DevilSummoner/Demons/Jack Frost.dmi'
	_dd66.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Jack Frost128.dmi'
	_dd66.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Jack Frost32.dmi'
	db["Jack Frost"] = _dd66

	// Pyro Jack (Fairy, Lv 29)
	var/datum/demon_data/_dd67 = new /datum/demon_data()
	_dd67.demon_name = "Pyro Jack"
	_dd67.demon_race = "Fairy"
	_dd67.demon_lvl = 29
	_dd67.demon_str = 10
	_dd67.demon_for = 14
	_dd67.demon_end = 12
	_dd67.demon_spd = 9
	_dd67.demon_off = 5
	_dd67.demon_def = 6
	_dd67.demon_skills = list("Fire Dance")
	_dd67.demon_skill_learn = list("Maragi" = 30, "Agidyne" = 34, "Media" = 35)
	_dd67.demon_passive_learn = list("Double Strike" = 31, "Fire Boost" = 32, "Mana Surge" = 33)
	_dd67.demon_unique = FALSE
	_dd67.demon_icon = 'Icons/DevilSummoner/Demons/Pyro Jack.dmi'
	_dd67.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pyro Jack128.dmi'
	_dd67.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pyro Jack32.dmi'
	db["Pyro Jack"] = _dd67

	// Lorelei (Fairy, Lv 37)
	var/datum/demon_data/_dd68 = new /datum/demon_data()
	_dd68.demon_name = "Lorelei"
	_dd68.demon_race = "Fairy"
	_dd68.demon_lvl = 37
	_dd68.demon_str = 9
	_dd68.demon_for = 19
	_dd68.demon_end = 10
	_dd68.demon_spd = 15
	_dd68.demon_off = 5
	_dd68.demon_def = 5
	_dd68.demon_skills = list("Marin Karin")
	_dd68.demon_passives = list("Vigilant")
	_dd68.demon_skill_learn = list("Diarahan" = 38, "Drain" = 47)
	_dd68.demon_passive_learn = list("Drain Hit" = 45, "Grimoire" = 46)
	_dd68.demon_unique = FALSE
	_dd68.demon_icon = 'Icons/DevilSummoner/Demons/Lorelei.dmi'
	_dd68.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lorelei128.dmi'
	_dd68.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lorelei32.dmi'
	db["Lorelei"] = _dd68

	// Silky (Fairy, Lv 44)
	var/datum/demon_data/_dd69 = new /datum/demon_data()
	_dd69.demon_name = "Silky"
	_dd69.demon_race = "Fairy"
	_dd69.demon_lvl = 44
	_dd69.demon_str = 12
	_dd69.demon_for = 23
	_dd69.demon_end = 13
	_dd69.demon_spd = 12
	_dd69.demon_off = 6
	_dd69.demon_def = 7
	_dd69.demon_skills = list("Diarahan", "Media")
	_dd69.demon_skill_learn = list("Bufudyne" = 54)
	_dd69.demon_passive_learn = list("Mana Surge" = 52, "Null Ice" = 53)
	_dd69.demon_unique = FALSE
	_dd69.demon_icon = 'Icons/DevilSummoner/Demons/Silky.dmi'
	_dd69.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Silky128.dmi'
	_dd69.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Silky32.dmi'
	db["Silky"] = _dd69

	// Vivian (Fairy, Lv 52)
	var/datum/demon_data/_dd70 = new /datum/demon_data()
	_dd70.demon_name = "Vivian"
	_dd70.demon_race = "Fairy"
	_dd70.demon_lvl = 52
	_dd70.demon_str = 11
	_dd70.demon_for = 26
	_dd70.demon_end = 15
	_dd70.demon_spd = 16
	_dd70.demon_off = 6
	_dd70.demon_def = 8
	_dd70.demon_skills = list("Drain", "Ziodyne")
	_dd70.demon_skill_learn = list("Recarm" = 61)
	_dd70.demon_passive_learn = list("Elec Repel" = 53, "Anti-Phys" = 60)
	_dd70.demon_unique = FALSE
	_dd70.demon_icon = 'Icons/DevilSummoner/Demons/Vivian.dmi'
	_dd70.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Vivian128.dmi'
	_dd70.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Vivian32.dmi'
	db["Vivian"] = _dd70

	// Titania (Fairy, Lv 58)
	var/datum/demon_data/_dd71 = new /datum/demon_data()
	_dd71.demon_name = "Titania"
	_dd71.demon_race = "Fairy"
	_dd71.demon_lvl = 58
	_dd71.demon_str = 16
	_dd71.demon_for = 27
	_dd71.demon_end = 17
	_dd71.demon_spd = 14
	_dd71.demon_off = 8
	_dd71.demon_def = 9
	_dd71.demon_skills = list("Recarmloss")
	_dd71.demon_unique = TRUE
	_dd71.demon_icon = 'Icons/DevilSummoner/Demons/Titania.dmi'
	_dd71.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Titania128.dmi'
	_dd71.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Titania32.dmi'
	db["Titania"] = _dd71

	// Oberon (Fairy, Lv 62)
	var/datum/demon_data/_dd72 = new /datum/demon_data()
	_dd72.demon_name = "Oberon"
	_dd72.demon_race = "Fairy"
	_dd72.demon_lvl = 62
	_dd72.demon_str = 23
	_dd72.demon_for = 24
	_dd72.demon_end = 18
	_dd72.demon_spd = 13
	_dd72.demon_off = 12
	_dd72.demon_def = 9
	_dd72.demon_skills = list("Samarecarm")
	_dd72.demon_passives = list("Life Lift")
	_dd72.demon_unique = TRUE
	_dd72.demon_icon = 'Icons/DevilSummoner/Demons/Oberon.dmi'
	_dd72.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Oberon128.dmi'
	_dd72.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Oberon32.dmi'
	db["Oberon"] = _dd72

	// Gagyson (Fallen, Lv 11)
	var/datum/demon_data/_dd73 = new /datum/demon_data()
	_dd73.demon_name = "Gagyson"
	_dd73.demon_race = "Fallen"
	_dd73.demon_lvl = 11
	_dd73.demon_str = 6
	_dd73.demon_for = 8
	_dd73.demon_end = 6
	_dd73.demon_spd = 7
	_dd73.demon_off = 3
	_dd73.demon_def = 3
	_dd73.demon_skills = list("Zio")
	_dd73.demon_skill_learn = list("Elec Dance" = 14, "Anger Hit" = 38)
	_dd73.demon_passive_learn = list("Counter" = 12, "Anti-Elec" = 36, "Dodge" = 37)
	_dd73.demon_unique = FALSE
	_dd73.demon_icon = 'Icons/DevilSummoner/Demons/Gagyson.dmi'
	_dd73.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Gagyson128.dmi'
	_dd73.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Gagyson32.dmi'
	db["Gagyson"] = _dd73

	// Abraxas (Fallen, Lv 19)
	var/datum/demon_data/_dd74 = new /datum/demon_data()
	_dd74.demon_name = "Abraxas"
	_dd74.demon_race = "Fallen"
	_dd74.demon_lvl = 19
	_dd74.demon_str = 11
	_dd74.demon_for = 11
	_dd74.demon_end = 5
	_dd74.demon_spd = 8
	_dd74.demon_off = 6
	_dd74.demon_def = 3
	_dd74.demon_skills = list("Force Dance")
	_dd74.demon_skill_learn = list("Mazio" = 41)
	_dd74.demon_passive_learn = list("Race-D" = 20, "Anti-Elec" = 38, "Anti-Force" = 39, "Mana Bonus" = 40)
	_dd74.demon_unique = FALSE
	_dd74.demon_icon = 'Icons/DevilSummoner/Demons/Abraxas.dmi'
	_dd74.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Abraxas128.dmi'
	_dd74.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Abraxas32.dmi'
	db["Abraxas"] = _dd74

	// Flauros (Fallen, Lv 26)
	var/datum/demon_data/_dd75 = new /datum/demon_data()
	_dd75.demon_name = "Flauros"
	_dd75.demon_race = "Fallen"
	_dd75.demon_lvl = 26
	_dd75.demon_str = 14
	_dd75.demon_for = 9
	_dd75.demon_end = 11
	_dd75.demon_spd = 8
	_dd75.demon_off = 7
	_dd75.demon_def = 6
	_dd75.demon_skills = list("Maragi")
	_dd75.demon_skill_learn = list("Nigayomogi" = 40, "Power Charge" = 41, "Power Hit" = 42)
	_dd75.demon_passive_learn = list("Mana Surge" = 27, "+Forget" = 28)
	_dd75.demon_unique = FALSE
	_dd75.demon_icon = 'Icons/DevilSummoner/Demons/Flauros.dmi'
	_dd75.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Flauros128.dmi'
	_dd75.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Flauros32.dmi'
	db["Flauros"] = _dd75

	// Barbatos (Fallen, Lv 33)
	var/datum/demon_data/_dd76 = new /datum/demon_data()
	_dd76.demon_name = "Barbatos"
	_dd76.demon_race = "Fallen"
	_dd76.demon_lvl = 33
	_dd76.demon_str = 11
	_dd76.demon_for = 13
	_dd76.demon_end = 10
	_dd76.demon_spd = 15
	_dd76.demon_off = 6
	_dd76.demon_def = 5
	_dd76.demon_skills = list("Mighty Hit")
	_dd76.demon_passives = list("Force Boost")
	_dd76.demon_passive_learn = list("Crit Up" = 34)
	_dd76.demon_unique = FALSE
	_dd76.demon_icon = 'Icons/DevilSummoner/Demons/Barbatos.dmi'
	_dd76.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Barbatos128.dmi'
	_dd76.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Barbatos32.dmi'
	db["Barbatos"] = _dd76

	// Botis (Fallen, Lv 37)
	var/datum/demon_data/_dd77 = new /datum/demon_data()
	_dd77.demon_name = "Botis"
	_dd77.demon_race = "Fallen"
	_dd77.demon_lvl = 37
	_dd77.demon_str = 13
	_dd77.demon_for = 14
	_dd77.demon_end = 18
	_dd77.demon_spd = 8
	_dd77.demon_off = 7
	_dd77.demon_def = 9
	_dd77.demon_skills = list("Ziodyne")
	_dd77.demon_skill_learn = list("Shield All" = 38)
	_dd77.demon_unique = TRUE
	_dd77.demon_icon = 'Icons/DevilSummoner/Demons/Botis.dmi'
	_dd77.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Botis128.dmi'
	_dd77.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Botis32.dmi'
	db["Botis"] = _dd77

	// Nisroc (Fallen, Lv 41)
	var/datum/demon_data/_dd78 = new /datum/demon_data()
	_dd78.demon_name = "Nisroc"
	_dd78.demon_race = "Fallen"
	_dd78.demon_lvl = 41
	_dd78.demon_str = 14
	_dd78.demon_for = 18
	_dd78.demon_end = 10
	_dd78.demon_spd = 15
	_dd78.demon_off = 7
	_dd78.demon_def = 5
	_dd78.demon_skills = list("Maragi")
	_dd78.demon_skill_learn = list("Weak Kill" = 42, "Agidyne" = 46)
	_dd78.demon_passive_learn = list("+Forget" = 43, "Mana Stream" = 44, "Null Fire" = 45)
	_dd78.demon_unique = FALSE
	_dd78.demon_icon = 'Icons/DevilSummoner/Demons/Nisroc.dmi'
	_dd78.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nisroc128.dmi'
	_dd78.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nisroc32.dmi'
	db["Nisroc"] = _dd78

	// Bifrons (Fallen, Lv 45)
	var/datum/demon_data/_dd79 = new /datum/demon_data()
	_dd79.demon_name = "Bifrons"
	_dd79.demon_race = "Fallen"
	_dd79.demon_lvl = 45
	_dd79.demon_str = 16
	_dd79.demon_for = 20
	_dd79.demon_end = 15
	_dd79.demon_spd = 10
	_dd79.demon_off = 8
	_dd79.demon_def = 8
	_dd79.demon_skills = list("Agidyne")
	_dd79.demon_passive_learn = list("Fire Amp" = 47)
	_dd79.demon_unique = TRUE
	_dd79.demon_icon = 'Icons/DevilSummoner/Demons/Bifrons.dmi'
	_dd79.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Bifrons128.dmi'
	_dd79.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Bifrons32.dmi'
	db["Bifrons"] = _dd79

	// Orobas (Fallen, Lv 49)
	var/datum/demon_data/_dd80 = new /datum/demon_data()
	_dd80.demon_name = "Orobas"
	_dd80.demon_race = "Fallen"
	_dd80.demon_lvl = 49
	_dd80.demon_str = 13
	_dd80.demon_for = 21
	_dd80.demon_end = 14
	_dd80.demon_spd = 17
	_dd80.demon_off = 7
	_dd80.demon_def = 7
	_dd80.demon_skills = list("Mazio")
	_dd80.demon_passives = list("Null Curse")
	_dd80.demon_skill_learn = list("Makarakarn" = 58, "Ziodyne" = 59)
	_dd80.demon_passive_learn = list("Elec Amp" = 50, "+Forget" = 57)
	_dd80.demon_unique = FALSE
	_dd80.demon_icon = 'Icons/DevilSummoner/Demons/Orobas.dmi'
	_dd80.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Orobas128.dmi'
	_dd80.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Orobas32.dmi'
	db["Orobas"] = _dd80

	// Decarabia (Fallen, Lv 56)
	var/datum/demon_data/_dd81 = new /datum/demon_data()
	_dd81.demon_name = "Decarabia"
	_dd81.demon_race = "Fallen"
	_dd81.demon_lvl = 56
	_dd81.demon_str = 18
	_dd81.demon_for = 22
	_dd81.demon_end = 12
	_dd81.demon_spd = 20
	_dd81.demon_off = 9
	_dd81.demon_def = 6
	_dd81.demon_skills = list("Shield All")
	_dd81.demon_skill_learn = list("Maragidyne" = 57)
	_dd81.demon_passive_learn = list("Fire Amp" = 64, "Null Curse" = 65, "Swift Step" = 66)
	_dd81.demon_unique = FALSE
	_dd81.demon_icon = 'Icons/DevilSummoner/Demons/Decarabia.dmi'
	_dd81.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Decarabia128.dmi'
	_dd81.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Decarabia32.dmi'
	db["Decarabia"] = _dd81

	// Murmur (Fallen, Lv 64)
	var/datum/demon_data/_dd82 = new /datum/demon_data()
	_dd82.demon_name = "Murmur"
	_dd82.demon_race = "Fallen"
	_dd82.demon_lvl = 64
	_dd82.demon_str = 24
	_dd82.demon_for = 23
	_dd82.demon_end = 16
	_dd82.demon_spd = 17
	_dd82.demon_off = 12
	_dd82.demon_def = 8
	_dd82.demon_skills = list("Death Call")
	_dd82.demon_skill_learn = list("Tetrakarn" = 65, "Hassohappa" = 74, "Makarakarn" = 75, "Maziodyne" = 76)
	_dd82.demon_passive_learn = list("Null Curse" = 72, "Swift Step" = 73)
	_dd82.demon_unique = FALSE
	_dd82.demon_icon = 'Icons/DevilSummoner/Demons/Murmur.dmi'
	_dd82.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Murmur128.dmi'
	_dd82.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Murmur32.dmi'
	db["Murmur"] = _dd82

	// Agares (Fallen, Lv 71)
	var/datum/demon_data/_dd83 = new /datum/demon_data()
	_dd83.demon_name = "Agares"
	_dd83.demon_race = "Fallen"
	_dd83.demon_lvl = 71
	_dd83.demon_str = 25
	_dd83.demon_for = 25
	_dd83.demon_end = 16
	_dd83.demon_spd = 21
	_dd83.demon_off = 13
	_dd83.demon_def = 8
	_dd83.demon_skills = list("Gigajama", "Tetrakarn")
	_dd83.demon_passive_learn = list("Phys Drain" = 72)
	_dd83.demon_unique = FALSE
	_dd83.demon_icon = 'Icons/DevilSummoner/Demons/Agares.dmi'
	_dd83.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Agares128.dmi'
	_dd83.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Agares32.dmi'
	db["Agares"] = _dd83

	// Nebiros (Fallen, Lv 86)
	var/datum/demon_data/_dd84 = new /datum/demon_data()
	_dd84.demon_name = "Nebiros"
	_dd84.demon_race = "Fallen"
	_dd84.demon_lvl = 86
	_dd84.demon_str = 19
	_dd84.demon_for = 30
	_dd84.demon_end = 25
	_dd84.demon_spd = 28
	_dd84.demon_off = 10
	_dd84.demon_def = 13
	_dd84.demon_skills = list("None")
	_dd84.demon_unique = FALSE
	_dd84.demon_icon = 'Icons/DevilSummoner/Demons/Nebiros.dmi'
	_dd84.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nebiros128.dmi'
	_dd84.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nebiros32.dmi'
	db["Nebiros"] = _dd84

	// Satan (Fallen, Lv 99)
	var/datum/demon_data/_dd85 = new /datum/demon_data()
	_dd85.demon_name = "Satan"
	_dd85.demon_race = "Fallen"
	_dd85.demon_lvl = 99
	_dd85.demon_str = 32
	_dd85.demon_for = 28
	_dd85.demon_end = 27
	_dd85.demon_spd = 28
	_dd85.demon_off = 16
	_dd85.demon_def = 14
	_dd85.demon_skills = list("Megido Ark")
	_dd85.demon_passives = list("Anti-Almighty")
	_dd85.demon_unique = TRUE
	_dd85.demon_icon = 'Icons/DevilSummoner/Demons/Satan.dmi'
	_dd85.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Satan128.dmi'
	_dd85.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Satan32.dmi'
	db["Satan"] = _dd85

	// Kikimora (Femme, Lv 9)
	var/datum/demon_data/_dd86 = new /datum/demon_data()
	_dd86.demon_name = "Kikimora"
	_dd86.demon_race = "Femme"
	_dd86.demon_lvl = 9
	_dd86.demon_str = 5
	_dd86.demon_for = 9
	_dd86.demon_end = 5
	_dd86.demon_spd = 6
	_dd86.demon_off = 3
	_dd86.demon_def = 3
	_dd86.demon_skills = list("Dia")
	_dd86.demon_skill_learn = list("Zan" = 10, "Nigayomogi" = 35)
	_dd86.demon_passive_learn = list("Mana Bonus" = 11, "Anti-Fire" = 33, "Watchful" = 34)
	_dd86.demon_unique = FALSE
	_dd86.demon_icon = 'Icons/DevilSummoner/Demons/Kikimora.dmi'
	_dd86.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kikimora128.dmi'
	_dd86.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kikimora32.dmi'
	db["Kikimora"] = _dd86

	// Lilim (Femme, Lv 18)
	var/datum/demon_data/_dd87 = new /datum/demon_data()
	_dd87.demon_name = "Lilim"
	_dd87.demon_race = "Femme"
	_dd87.demon_lvl = 18
	_dd87.demon_str = 8
	_dd87.demon_for = 11
	_dd87.demon_end = 8
	_dd87.demon_spd = 7
	_dd87.demon_off = 4
	_dd87.demon_def = 4
	_dd87.demon_skills = list("Sexy Gaze")
	_dd87.demon_skill_learn = list("Elec Dance" = 37, "Fatal Strike" = 38, "Mazio" = 39)
	_dd87.demon_passive_learn = list("Anti-Elec" = 20, "Dodge" = 35, "Grimoire" = 36)
	_dd87.demon_unique = FALSE
	_dd87.demon_icon = 'Icons/DevilSummoner/Demons/Lilim.dmi'
	_dd87.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lilim128.dmi'
	_dd87.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lilim32.dmi'
	db["Lilim"] = _dd87

	// Leanan Sidhe (Femme, Lv 26)
	var/datum/demon_data/_dd88 = new /datum/demon_data()
	_dd88.demon_name = "Leanan Sidhe"
	_dd88.demon_race = "Femme"
	_dd88.demon_lvl = 26
	_dd88.demon_str = 8
	_dd88.demon_for = 16
	_dd88.demon_end = 8
	_dd88.demon_spd = 10
	_dd88.demon_off = 4
	_dd88.demon_def = 4
	_dd88.demon_skills = list("Media")
	_dd88.demon_skill_learn = list("Bufudyne" = 40, "Diarama" = 41, "Mabufu" = 42)
	_dd88.demon_passive_learn = list("Anti-Ailment" = 27, "Ice Boost" = 38, "Life Surge" = 39)
	_dd88.demon_unique = FALSE
	_dd88.demon_icon = 'Icons/DevilSummoner/Demons/Leanan Sidhe.dmi'
	_dd88.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Leanan Sidhe128.dmi'
	_dd88.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Leanan Sidhe32.dmi'
	db["Leanan Sidhe"] = _dd88

	// Yuki Jyorou (Femme, Lv 34)
	var/datum/demon_data/_dd89 = new /datum/demon_data()
	_dd89.demon_name = "Yuki Jyorou"
	_dd89.demon_race = "Femme"
	_dd89.demon_lvl = 34
	_dd89.demon_str = 9
	_dd89.demon_for = 17
	_dd89.demon_end = 10
	_dd89.demon_spd = 14
	_dd89.demon_off = 5
	_dd89.demon_def = 5
	_dd89.demon_skills = list("Mabufu")
	_dd89.demon_skill_learn = list("Marin Karin" = 36, "Drain" = 39)
	_dd89.demon_passive_learn = list("Drain Hit" = 35, "Ice Boost" = 37, "Mana Surge" = 38)
	_dd89.demon_unique = FALSE
	_dd89.demon_icon = 'Icons/DevilSummoner/Demons/Yuki Jyorou.dmi'
	_dd89.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Yuki Jyorou128.dmi'
	_dd89.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Yuki Jyorou32.dmi'
	db["Yuki Jyorou"] = _dd89

	// Peri (Femme, Lv 38)
	var/datum/demon_data/_dd90 = new /datum/demon_data()
	_dd90.demon_name = "Peri"
	_dd90.demon_race = "Femme"
	_dd90.demon_lvl = 38
	_dd90.demon_str = 8
	_dd90.demon_for = 22
	_dd90.demon_end = 10
	_dd90.demon_spd = 14
	_dd90.demon_off = 4
	_dd90.demon_def = 5
	_dd90.demon_skills = list("Ziodyne")
	_dd90.demon_passives = list("Elec Drain")
	_dd90.demon_passive_learn = list("Mana Stream" = 39)
	_dd90.demon_unique = TRUE
	_dd90.demon_icon = 'Icons/DevilSummoner/Demons/Peri.dmi'
	_dd90.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Peri128.dmi'
	_dd90.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Peri32.dmi'
	db["Peri"] = _dd90

	// Ixtab (Femme, Lv 42)
	var/datum/demon_data/_dd91 = new /datum/demon_data()
	_dd91.demon_name = "Ixtab"
	_dd91.demon_race = "Femme"
	_dd91.demon_lvl = 42
	_dd91.demon_str = 14
	_dd91.demon_for = 20
	_dd91.demon_end = 15
	_dd91.demon_spd = 9
	_dd91.demon_off = 7
	_dd91.demon_def = 8
	_dd91.demon_skills = list("Diarahan")
	_dd91.demon_skill_learn = list("Death Call" = 44)
	_dd91.demon_passive_learn = list("Mana Stream" = 43)
	_dd91.demon_unique = FALSE
	_dd91.demon_icon = 'Icons/DevilSummoner/Demons/Ixtab.dmi'
	_dd91.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ixtab128.dmi'
	_dd91.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ixtab32.dmi'
	db["Ixtab"] = _dd91

	// Hariti (Femme, Lv 46)
	var/datum/demon_data/_dd92 = new /datum/demon_data()
	_dd92.demon_name = "Hariti"
	_dd92.demon_race = "Femme"
	_dd92.demon_lvl = 46
	_dd92.demon_str = 22
	_dd92.demon_for = 17
	_dd92.demon_end = 14
	_dd92.demon_spd = 9
	_dd92.demon_off = 11
	_dd92.demon_def = 7
	_dd92.demon_skills = list("Maziodyne")
	_dd92.demon_passives = list("Elec Amp")
	_dd92.demon_unique = TRUE
	_dd92.demon_icon = 'Icons/DevilSummoner/Demons/Hariti.dmi'
	_dd92.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hariti128.dmi'
	_dd92.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hariti32.dmi'
	db["Hariti"] = _dd92

	// Dzelarhons (Femme, Lv 50)
	var/datum/demon_data/_dd93 = new /datum/demon_data()
	_dd93.demon_name = "Dzelarhons"
	_dd93.demon_race = "Femme"
	_dd93.demon_lvl = 50
	_dd93.demon_str = 21
	_dd93.demon_for = 20
	_dd93.demon_end = 13
	_dd93.demon_spd = 12
	_dd93.demon_off = 11
	_dd93.demon_def = 7
	_dd93.demon_skills = list("Zandyne")
	_dd93.demon_passives = list("Force Drain")
	_dd93.demon_skill_learn = list("Tetrakarn" = 51)
	_dd93.demon_unique = TRUE
	_dd93.demon_icon = 'Icons/DevilSummoner/Demons/Dzelarhons.dmi'
	_dd93.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Dzelarhons128.dmi'
	_dd93.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Dzelarhons32.dmi'
	db["Dzelarhons"] = _dd93

	// Rangda (Femme, Lv 58)
	var/datum/demon_data/_dd94 = new /datum/demon_data()
	_dd94.demon_name = "Rangda"
	_dd94.demon_race = "Femme"
	_dd94.demon_lvl = 58
	_dd94.demon_str = 23
	_dd94.demon_for = 15
	_dd94.demon_end = 18
	_dd94.demon_spd = 18
	_dd94.demon_off = 12
	_dd94.demon_def = 9
	_dd94.demon_skills = list("Assassinate")
	_dd94.demon_skill_learn = list("Diarahan" = 66, "Drain" = 67, "Power Hit" = 68, "Zandyne" = 69)
	_dd94.demon_passive_learn = list("Phys Repel" = 59)
	_dd94.demon_unique = FALSE
	_dd94.demon_icon = 'Icons/DevilSummoner/Demons/Rangda.dmi'
	_dd94.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Rangda128.dmi'
	_dd94.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Rangda32.dmi'
	db["Rangda"] = _dd94

	// Anat (Femme, Lv 66)
	var/datum/demon_data/_dd95 = new /datum/demon_data()
	_dd95.demon_name = "Anat"
	_dd95.demon_race = "Femme"
	_dd95.demon_lvl = 66
	_dd95.demon_str = 18
	_dd95.demon_for = 30
	_dd95.demon_end = 22
	_dd95.demon_spd = 12
	_dd95.demon_off = 9
	_dd95.demon_def = 11
	_dd95.demon_skills = list("Recarmloss")
	_dd95.demon_unique = TRUE
	_dd95.demon_icon = 'Icons/DevilSummoner/Demons/Anat.dmi'
	_dd95.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Anat128.dmi'
	_dd95.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Anat32.dmi'
	db["Anat"] = _dd95

	// Kali (Femme, Lv 74)
	var/datum/demon_data/_dd96 = new /datum/demon_data()
	_dd96.demon_name = "Kali"
	_dd96.demon_race = "Femme"
	_dd96.demon_lvl = 74
	_dd96.demon_str = 29
	_dd96.demon_for = 20
	_dd96.demon_end = 23
	_dd96.demon_spd = 18
	_dd96.demon_off = 15
	_dd96.demon_def = 12
	_dd96.demon_skills = list("Prayer")
	_dd96.demon_unique = TRUE
	_dd96.demon_icon = 'Icons/DevilSummoner/Demons/Kali.dmi'
	_dd96.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kali128.dmi'
	_dd96.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kali32.dmi'
	db["Kali"] = _dd96

	// Lilith (Femme, Lv 83)
	var/datum/demon_data/_dd97 = new /datum/demon_data()
	_dd97.demon_name = "Lilith"
	_dd97.demon_race = "Femme"
	_dd97.demon_lvl = 83
	_dd97.demon_str = 26
	_dd97.demon_for = 31
	_dd97.demon_end = 24
	_dd97.demon_spd = 18
	_dd97.demon_off = 13
	_dd97.demon_def = 12
	_dd97.demon_skills = list("None")
	_dd97.demon_passives = list("Anti-Almighty")
	_dd97.demon_unique = TRUE
	_dd97.demon_icon = 'Icons/DevilSummoner/Demons/Lilith.dmi'
	_dd97.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lilith128.dmi'
	_dd97.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lilith32.dmi'
	db["Lilith"] = _dd97

	// Ghost Q (Fiend, Lv 26)
	var/datum/demon_data/_dd98 = new /datum/demon_data()
	_dd98.demon_name = "Ghost Q"
	_dd98.demon_race = "Fiend"
	_dd98.demon_lvl = 26
	_dd98.demon_str = 9
	_dd98.demon_for = 11
	_dd98.demon_end = 10
	_dd98.demon_spd = 12
	_dd98.demon_off = 5
	_dd98.demon_def = 5
	_dd98.demon_skills = list("Berserk")
	_dd98.demon_unique = TRUE
	_dd98.demon_icon = 'Icons/DevilSummoner/Demons/Ghost Q.dmi'
	_dd98.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ghost Q128.dmi'
	_dd98.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ghost Q32.dmi'
	db["Ghost Q"] = _dd98

	// Sage of Time (Fiend, Lv 41)
	var/datum/demon_data/_dd99 = new /datum/demon_data()
	_dd99.demon_name = "Sage of Time"
	_dd99.demon_race = "Fiend"
	_dd99.demon_lvl = 41
	_dd99.demon_str = 9
	_dd99.demon_for = 25
	_dd99.demon_end = 12
	_dd99.demon_spd = 11
	_dd99.demon_off = 5
	_dd99.demon_def = 6
	_dd99.demon_skills = list("Death Call", "Petra Eyes")
	_dd99.demon_unique = TRUE
	_dd98.demon_icon = 'Icons/DevilSummoner/Demons/Sage of Time.dmi'
	_dd98.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Sage of Time128.dmi'
	_dd98.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Sage of Time32.dmi'
	db["Sage of Time"] = _dd99

	// Billiken (Fiend, Lv 50)
	var/datum/demon_data/_dd100 = new /datum/demon_data()
	_dd100.demon_name = "Billiken"
	_dd100.demon_race = "Fiend"
	_dd100.demon_lvl = 50
	_dd100.demon_str = 15
	_dd100.demon_for = 21
	_dd100.demon_end = 16
	_dd100.demon_spd = 14
	_dd100.demon_off = 8
	_dd100.demon_def = 8
	_dd100.demon_skills = list("Life Drain")
	_dd100.demon_passives = list("Moneybags")
	_dd100.demon_unique = TRUE
	_dd98.demon_icon = 'Icons/DevilSummoner/Demons/Billiken.dmi'
	_dd98.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Billiken128.dmi'
	_dd98.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Billiken32.dmi'
	db["Billiken"] = _dd100

	// Trumpeter (True Fiend, Lv 63)
	var/datum/demon_data/_dd101 = new /datum/demon_data()
	_dd101.demon_name = "Trumpeter"
	_dd101.demon_race = "True Fiend"
	_dd101.demon_lvl = 63
	_dd101.demon_str = 16
	_dd101.demon_for = 27
	_dd101.demon_end = 16
	_dd101.demon_spd = 20
	_dd101.demon_off = 8
	_dd101.demon_def = 8
	_dd101.demon_skills = list("Judgement")
	_dd101.demon_passives = list("Attack All")
	_dd101.demon_passive_learn = list("Anti-Most" = 65)
	_dd101.demon_unique = TRUE
	_dd98.demon_icon = 'Icons/DevilSummoner/Demons/Trumpeter.dmi'
	_dd98.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Trumpeter128.dmi'
	_dd98.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Trumpeter32.dmi'
	db["Trumpeter"] = _dd101

	// Alice (Fiend, Lv 88)
	var/datum/demon_data/_dd102 = new /datum/demon_data()
	_dd102.demon_name = "Alice"
	_dd102.demon_race = "Fiend"
	_dd102.demon_lvl = 88
	_dd102.demon_str = 24
	_dd102.demon_for = 32
	_dd102.demon_end = 24
	_dd102.demon_spd = 24
	_dd102.demon_off = 12
	_dd102.demon_def = 12
	_dd102.demon_skills = list("Die For Me!")
	_dd102.demon_passives = list("Ultimate Hit")
	_dd102.demon_unique = TRUE
	_dd98.demon_icon = 'Icons/DevilSummoner/Demons/Alice.dmi'
	_dd98.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Alice128.dmi'
	_dd98.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Alice32.dmi'
	db["Alice"] = _dd102

	// Tam Lin (Genma, Lv 6)
	var/datum/demon_data/_dd103 = new /datum/demon_data()
	_dd103.demon_name = "Tam Lin"
	_dd103.demon_race = "Genma"
	_dd103.demon_lvl = 6
	_dd103.demon_str = 9
	_dd103.demon_for = 2
	_dd103.demon_end = 5
	_dd103.demon_spd = 6
	_dd103.demon_off = 5
	_dd103.demon_def = 3
	_dd103.demon_skills = list("Anger Hit")
	_dd103.demon_passives = list("Knight Soul", "Phys Up")
	_dd103.demon_unique = TRUE
	_dd103.demon_icon = 'Icons/DevilSummoner/Demons/Tam Lin.dmi'
	_dd103.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tam Lin128.dmi'
	_dd103.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tam Lin32.dmi'
	db["Tam Lin"] = _dd103

	// Jambavan (Genma, Lv 13)
	var/datum/demon_data/_dd104 = new /datum/demon_data()
	_dd104.demon_name = "Jambavan"
	_dd104.demon_race = "Genma"
	_dd104.demon_lvl = 13
	_dd104.demon_str = 11
	_dd104.demon_for = 4
	_dd104.demon_end = 10
	_dd104.demon_spd = 4
	_dd104.demon_off = 6
	_dd104.demon_def = 5
	_dd104.demon_skills = list("Agi")
	_dd104.demon_passives = list("Knight Soul")
	_dd104.demon_skill_learn = list("Extra Cancel" = 29, "Fire Dance" = 30, "Mow Down" = 31)
	_dd104.demon_passive_learn = list("Race-O" = 14, "Race-D" = 28)
	_dd104.demon_unique = FALSE
	_dd104.demon_icon = 'Icons/DevilSummoner/Demons/Jambavan.dmi'
	_dd104.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Jambavan128.dmi'
	_dd104.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Jambavan32.dmi'
	db["Jambavan"] = _dd104

	// Ictinike (Genma, Lv 21)
	var/datum/demon_data/_dd105 = new /datum/demon_data()
	_dd105.demon_name = "Ictinike"
	_dd105.demon_race = "Genma"
	_dd105.demon_lvl = 21
	_dd105.demon_str = 12
	_dd105.demon_for = 10
	_dd105.demon_end = 6
	_dd105.demon_spd = 9
	_dd105.demon_off = 6
	_dd105.demon_def = 3
	_dd105.demon_skills = list("Elec Dance")
	_dd105.demon_passives = list("Quick Move")
	_dd105.demon_skill_learn = list("Mow Down" = 23, "Fatal Strike" = 34)
	_dd105.demon_passive_learn = list("Counter" = 32, "Paladin Soul" = 33)
	_dd105.demon_unique = FALSE
	_dd105.demon_icon = 'Icons/DevilSummoner/Demons/Ictinike.dmi'
	_dd105.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ictinike128.dmi'
	_dd105.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ictinike32.dmi'
	db["Ictinike"] = _dd105

	// Tlaloc (Genma, Lv 28)
	var/datum/demon_data/_dd106 = new /datum/demon_data()
	_dd106.demon_name = "Tlaloc"
	_dd106.demon_race = "Genma"
	_dd106.demon_lvl = 28
	_dd106.demon_str = 14
	_dd106.demon_for = 14
	_dd106.demon_end = 8
	_dd106.demon_spd = 8
	_dd106.demon_off = 7
	_dd106.demon_def = 4
	_dd106.demon_skills = list("Maragi")
	_dd106.demon_passive_learn = list("+Forget" = 30, "Fire Boost" = 29)
	_dd106.demon_unique = FALSE
	_dd106.demon_icon = 'Icons/DevilSummoner/Demons/Tlaloc.dmi'
	_dd106.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tlaloc128.dmi'
	_dd106.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tlaloc32.dmi'
	db["Tlaloc"] = _dd106

	// Hanuman (Genma, Lv 33)
	var/datum/demon_data/_dd107 = new /datum/demon_data()
	_dd107.demon_name = "Hanuman"
	_dd107.demon_race = "Genma"
	_dd107.demon_lvl = 33
	_dd107.demon_str = 13
	_dd107.demon_for = 9
	_dd107.demon_end = 10
	_dd107.demon_spd = 17
	_dd107.demon_off = 7
	_dd107.demon_def = 5
	_dd107.demon_skills = list("Berserk")
	_dd107.demon_passives = list("Retaliate")
	_dd107.demon_passive_learn = list("Life Aid" = 34)
	_dd107.demon_unique = FALSE
	_dd107.demon_icon = 'Icons/DevilSummoner/Demons/Hanuman.dmi'
	_dd107.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hanuman128.dmi'
	_dd107.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hanuman32.dmi'
	db["Hanuman"] = _dd107

	// Cu Chulainn (Genma, Lv 37)
	var/datum/demon_data/_dd108 = new /datum/demon_data()
	_dd108.demon_name = "Cu Chulainn"
	_dd108.demon_race = "Genma"
	_dd108.demon_lvl = 37
	_dd108.demon_str = 21
	_dd108.demon_for = 9
	_dd108.demon_end = 12
	_dd108.demon_spd = 11
	_dd108.demon_off = 11
	_dd108.demon_def = 6
	_dd108.demon_skills = list("Mazio")
	_dd108.demon_passives = list("Phys Boost")
	_dd108.demon_passive_learn = list("Pierce" = 38)
	_dd108.demon_unique = TRUE
	_dd108.demon_icon = 'Icons/DevilSummoner/Demons/Cu Chulainn.dmi'
	_dd108.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Cu Chulainn128.dmi'
	_dd108.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Cu Chulainn32.dmi'
	db["Cu Chulainn"] = _dd108

	// Kama (Genma, Lv 42)
	var/datum/demon_data/_dd109 = new /datum/demon_data()
	_dd109.demon_name = "Kama"
	_dd109.demon_race = "Genma"
	_dd109.demon_lvl = 42
	_dd109.demon_str = 14
	_dd109.demon_for = 18
	_dd109.demon_end = 11
	_dd109.demon_spd = 15
	_dd109.demon_off = 7
	_dd109.demon_def = 6
	_dd109.demon_skills = list("Marin Karin")
	_dd109.demon_skill_learn = list("Shield All" = 44)
	_dd109.demon_passive_learn = list("Anti-Ailment" = 43)
	_dd109.demon_unique = TRUE
	_dd109.demon_icon = 'Icons/DevilSummoner/Demons/Kama.dmi'
	_dd109.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kama128.dmi'
	_dd109.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kama32.dmi'
	db["Kama"] = _dd109

	// Kresnik (Genma, Lv 46)
	var/datum/demon_data/_dd110 = new /datum/demon_data()
	_dd110.demon_name = "Kresnik"
	_dd110.demon_race = "Genma"
	_dd110.demon_lvl = 46
	_dd110.demon_str = 23
	_dd110.demon_for = 14
	_dd110.demon_end = 11
	_dd110.demon_spd = 14
	_dd110.demon_off = 12
	_dd110.demon_def = 6
	_dd110.demon_skills = list("Mighty Hit")
	_dd110.demon_skill_learn = list("Agidyne" = 47)
	_dd110.demon_passive_learn = list("Null Phys" = 48)
	_dd110.demon_unique = TRUE
	_dd110.demon_icon = 'Icons/DevilSummoner/Demons/Kresnik.dmi'
	_dd110.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kresnik128.dmi'
	_dd110.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kresnik32.dmi'
	db["Kresnik"] = _dd110

	// Kangiten (Genma, Lv 54)
	var/datum/demon_data/_dd111 = new /datum/demon_data()
	_dd111.demon_name = "Kangiten"
	_dd111.demon_race = "Genma"
	_dd111.demon_lvl = 54
	_dd111.demon_str = 20
	_dd111.demon_for = 22
	_dd111.demon_end = 14
	_dd111.demon_spd = 14
	_dd111.demon_off = 10
	_dd111.demon_def = 7
	_dd111.demon_skills = list("Mediarahan")
	_dd111.demon_passives = list("Dual Shadow")
	_dd111.demon_unique = TRUE
	_dd111.demon_icon = 'Icons/DevilSummoner/Demons/Kangiten.dmi'
	_dd111.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kangiten128.dmi'
	_dd111.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kangiten32.dmi'
	db["Kangiten"] = _dd111

	// Ganesha (Genma, Lv 61)
	var/datum/demon_data/_dd112 = new /datum/demon_data()
	_dd112.demon_name = "Ganesha"
	_dd112.demon_race = "Genma"
	_dd112.demon_lvl = 61
	_dd112.demon_str = 26
	_dd112.demon_for = 21
	_dd112.demon_end = 26
	_dd112.demon_spd = 4
	_dd112.demon_off = 13
	_dd112.demon_def = 13
	_dd112.demon_skills = list("Judgement")
	_dd112.demon_passives = list("Ice Drain")
	_dd112.demon_skill_learn = list("Deathbound" = 70)
	_dd112.demon_passive_learn = list("Force Drain" = 63, "Hero Soul" = 69)
	_dd112.demon_unique = FALSE
	_dd112.demon_icon = 'Icons/DevilSummoner/Demons/Ganesha.dmi'
	_dd112.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ganesha128.dmi'
	_dd112.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ganesha32.dmi'
	db["Ganesha"] = _dd112

	// Jarilo (Genma, Lv 68)
	var/datum/demon_data/_dd113 = new /datum/demon_data()
	_dd113.demon_name = "Jarilo"
	_dd113.demon_race = "Genma"
	_dd113.demon_lvl = 68
	_dd113.demon_str = 20
	_dd113.demon_for = 21
	_dd113.demon_end = 16
	_dd113.demon_spd = 27
	_dd113.demon_off = 10
	_dd113.demon_def = 8
	_dd113.demon_skills = list("Holy Strike")
	_dd113.demon_unique = TRUE
	_dd113.demon_icon = 'Icons/DevilSummoner/Demons/Jarilo.dmi'
	_dd113.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Jarilo128.dmi'
	_dd113.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Jarilo32.dmi'
	db["Jarilo"] = _dd113

	// Heimdall (Genma, Lv 75)
	var/datum/demon_data/_dd114 = new /datum/demon_data()
	_dd114.demon_name = "Heimdall"
	_dd114.demon_race = "Genma"
	_dd114.demon_lvl = 75
	_dd114.demon_str = 24
	_dd114.demon_for = 22
	_dd114.demon_end = 18
	_dd114.demon_spd = 27
	_dd114.demon_off = 12
	_dd114.demon_def = 9
	_dd114.demon_skills = list("Taunt")
	_dd114.demon_passives = list("Null Curse")
	_dd114.demon_unique = TRUE
	_dd114.demon_icon = 'Icons/DevilSummoner/Demons/Heimdall.dmi'
	_dd114.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Heimdall128.dmi'
	_dd114.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Heimdall32.dmi'
	db["Heimdall"] = _dd114

	// Poltergeist (Ghost, Lv 1)
	var/datum/demon_data/_dd115 = new /datum/demon_data()
	_dd115.demon_name = "Poltergeist"
	_dd115.demon_race = "Ghost"
	_dd115.demon_lvl = 1
	_dd115.demon_str = 4
	_dd115.demon_for = 5
	_dd115.demon_end = 4
	_dd115.demon_spd = 4
	_dd115.demon_off = 2
	_dd115.demon_def = 2
	_dd115.demon_skills = list("Bufu")
	_dd115.demon_skill_learn = list("Agi" = 26)
	_dd115.demon_passive_learn = list("Anti-Fire" = 25)
	_dd115.demon_unique = FALSE
	_dd115.demon_icon = 'Icons/DevilSummoner/Demons/Poltergeist.dmi'
	_dd115.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Poltergeist128.dmi'
	_dd115.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Poltergeist32.dmi'
	db["Poltergeist"] = _dd115

	// Agathion (Ghost, Lv 6)
	var/datum/demon_data/_dd116 = new /datum/demon_data()
	_dd116.demon_name = "Agathion"
	_dd116.demon_race = "Ghost"
	_dd116.demon_lvl = 6
	_dd116.demon_str = 5
	_dd116.demon_for = 7
	_dd116.demon_end = 5
	_dd116.demon_spd = 5
	_dd116.demon_off = 3
	_dd116.demon_def = 3
	_dd116.demon_skills = list("Zio")
	_dd116.demon_skill_learn = list("Agi" = 8, "Bufu" = 30)
	_dd116.demon_passive_learn = list("Anti-Curse" = 27, "Mana Bonus" = 28, "Moneybags" = 29)
	_dd116.demon_unique = FALSE
	_dd116.demon_icon = 'Icons/DevilSummoner/Demons/Agathion.dmi'
	_dd116.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Agathion128.dmi'
	_dd116.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Agathion32.dmi'
	db["Agathion"] = _dd116

	// Tenong Cut (Ghost, Lv 16)
	var/datum/demon_data/_dd117 = new /datum/demon_data()
	_dd117.demon_name = "Tenong Cut"
	_dd117.demon_race = "Ghost"
	_dd117.demon_lvl = 16
	_dd117.demon_str = 7
	_dd117.demon_for = 10
	_dd117.demon_end = 10
	_dd117.demon_spd = 5
	_dd117.demon_off = 4
	_dd117.demon_def = 5
	_dd117.demon_skills = list("Paral Eyes")
	_dd117.demon_passives = list("+Paralyze")
	_dd117.demon_skill_learn = list("Berserk" = 30, "Nigayomogi" = 31)
	_dd117.demon_passive_learn = list("Dodge" = 17, "Anti-Phys" = 29)
	_dd117.demon_unique = FALSE
	_dd117.demon_icon = 'Icons/DevilSummoner/Demons/Tenong Cut.dmi'
	_dd117.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tenong Cut128.dmi'
	_dd117.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tenong Cut32.dmi'
	db["Tenong Cut"] = _dd117

	// Kumbhanda (Ghost, Lv 25)
	var/datum/demon_data/_dd118 = new /datum/demon_data()
	_dd118.demon_name = "Kumbhanda"
	_dd118.demon_race = "Ghost"
	_dd118.demon_lvl = 25
	_dd118.demon_str = 11
	_dd118.demon_for = 10
	_dd118.demon_end = 7
	_dd118.demon_spd = 13
	_dd118.demon_off = 6
	_dd118.demon_def = 4
	_dd118.demon_skills = list("Assassinate")
	_dd118.demon_skill_learn = list("Desperation" = 26, "Life Drain" = 33, "Multi-Hit" = 34)
	_dd118.demon_passive_learn = list("Anti-Curse" = 27, "Anti-Phys" = 31, "Extra Bonus" = 32)
	_dd118.demon_unique = FALSE
	_dd118.demon_icon = 'Icons/DevilSummoner/Demons/Kumbhanda.dmi'
	_dd118.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kumbhanda128.dmi'
	_dd118.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kumbhanda32.dmi'
	db["Kumbhanda"] = _dd118

	// Loa (Ghost, Lv 34)
	var/datum/demon_data/_dd119 = new /datum/demon_data()
	_dd119.demon_name = "Loa"
	_dd119.demon_race = "Ghost"
	_dd119.demon_lvl = 34
	_dd119.demon_str = 12
	_dd119.demon_for = 18
	_dd119.demon_end = 13
	_dd119.demon_spd = 7
	_dd119.demon_off = 6
	_dd119.demon_def = 7
	_dd119.demon_skills = list("Power Charge")
	_dd119.demon_passives = list("Life Surge")
	_dd119.demon_skill_learn = list("Extra Cancel" = 38, "Life Drain" = 39, "Nigayomogi" = 40, "Petra Eyes" = 41)
	_dd119.demon_passive_learn = list("+Forget" = 35, "+Poison" = 36, "Drain Hit" = 37)
	_dd119.demon_unique = FALSE
	_dd119.demon_icon = 'Icons/DevilSummoner/Demons/Loa.dmi'
	_dd119.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Loa128.dmi'
	_dd119.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Loa32.dmi'
	db["Loa"] = _dd119

	// Pisaca (Ghost, Lv 41)
	var/datum/demon_data/_dd120 = new /datum/demon_data()
	_dd120.demon_name = "Pisaca"
	_dd120.demon_race = "Ghost"
	_dd120.demon_lvl = 41
	_dd120.demon_str = 12
	_dd120.demon_for = 13
	_dd120.demon_end = 22
	_dd120.demon_spd = 10
	_dd120.demon_off = 6
	_dd120.demon_def = 11
	_dd120.demon_skills = list("Life Drain")
	_dd120.demon_skill_learn = list("Desperation" = 52)
	_dd120.demon_passive_learn = list("Null Curse" = 42, "Anti-Ailment" = 49, "Drain Hit" = 50, "Null Ice" = 51)
	_dd120.demon_unique = FALSE
	_dd120.demon_icon = 'Icons/DevilSummoner/Demons/Pisaca.dmi'
	_dd120.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pisaca128.dmi'
	_dd120.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pisaca32.dmi'
	db["Pisaca"] = _dd120

	// Kudlak (Ghost, Lv 50)
	var/datum/demon_data/_dd121 = new /datum/demon_data()
	_dd121.demon_name = "Kudlak"
	_dd121.demon_race = "Ghost"
	_dd121.demon_lvl = 50
	_dd121.demon_str = 20
	_dd121.demon_for = 12
	_dd121.demon_end = 18
	_dd121.demon_spd = 16
	_dd121.demon_off = 10
	_dd121.demon_def = 9
	_dd121.demon_skills = list("Bufudyne")
	_dd121.demon_passive_learn = list("Ice Amp" = 51)
	_dd121.demon_unique = TRUE
	_dd121.demon_icon = 'Icons/DevilSummoner/Demons/Kudlak.dmi'
	_dd121.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kudlak128.dmi'
	_dd121.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kudlak32.dmi'
	db["Kudlak"] = _dd121

	// Purple Mirror (Ghost, Lv 61)
	var/datum/demon_data/_dd122 = new /datum/demon_data()
	_dd122.demon_name = "Purple Mirror"
	_dd122.demon_race = "Ghost"
	_dd122.demon_lvl = 61
	_dd122.demon_str = 16
	_dd122.demon_for = 26
	_dd122.demon_end = 22
	_dd122.demon_spd = 13
	_dd122.demon_off = 8
	_dd122.demon_def = 11
	_dd122.demon_skills = list("Judgement")
	_dd122.demon_skill_learn = list("Makarakarn" = 62)
	_dd122.demon_unique = TRUE
	_dd122.demon_icon = 'Icons/DevilSummoner/Demons/Purple Mirror.dmi'
	_dd122.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Purple Mirror128.dmi'
	_dd122.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Purple Mirror32.dmi'
	db["Purple Mirror"] = _dd122

	// Neko Shogun (Hero, Lv 31)
	var/datum/demon_data/_dd123 = new /datum/demon_data()
	_dd123.demon_name = "Neko Shogun"
	_dd123.demon_race = "Hero"
	_dd123.demon_lvl = 31
	_dd123.demon_str = 11
	_dd123.demon_for = 17
	_dd123.demon_end = 8
	_dd123.demon_spd = 11
	_dd123.demon_off = 6
	_dd123.demon_def = 4
	_dd123.demon_skills = list("Mow Down")
	_dd123.demon_passives = list("Paladin Soul")
	_dd123.demon_skill_learn = list("Power Charge" = 32)
	_dd123.demon_unique = TRUE
	_dd123.demon_icon = 'Icons/DevilSummoner/Demons/Neko Shogun.dmi'
	_dd123.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Neko Shogun128.dmi'
	_dd123.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Neko Shogun32.dmi'
	db["Neko Shogun"] = _dd123

	// Hagen (Hero, Lv 39)
	var/datum/demon_data/_dd124 = new /datum/demon_data()
	_dd124.demon_name = "Hagen"
	_dd124.demon_race = "Hero"
	_dd124.demon_lvl = 39
	_dd124.demon_str = 18
	_dd124.demon_for = 10
	_dd124.demon_end = 14
	_dd124.demon_spd = 13
	_dd124.demon_off = 9
	_dd124.demon_def = 7
	_dd124.demon_skills = list("Assassinate")
	_dd124.demon_passives = list("Hero Soul")
	_dd124.demon_passive_learn = list("Null Curse" = 40)
	_dd124.demon_unique = TRUE
	_dd124.demon_icon = 'Icons/DevilSummoner/Demons/Hagen.dmi'
	_dd124.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hagen128.dmi'
	_dd124.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hagen32.dmi'
	db["Hagen"] = _dd124

	// Jeanne D'Arc (Hero, Lv 50)
	var/datum/demon_data/_dd125 = new /datum/demon_data()
	_dd125.demon_name = "Jeanne D'Arc"
	_dd125.demon_race = "Hero"
	_dd125.demon_lvl = 50
	_dd125.demon_str = 23
	_dd125.demon_for = 12
	_dd125.demon_end = 18
	_dd125.demon_spd = 13
	_dd125.demon_off = 12
	_dd125.demon_def = 9
	_dd125.demon_skills = list("Hassohappa")
	_dd125.demon_passives = list("Dual Shadow", "Hero Soul")
	_dd125.demon_unique = TRUE
	_dd125.demon_icon = 'Icons/DevilSummoner/Demons/Jeanne DArc.dmi'
	_dd125.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Jeanne DArc128.dmi'
	_dd125.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Jeanne DArc32.dmi'
	db["Jeanne D'Arc"] = _dd125

	// Yoshitsune (Hero, Lv 57)
	var/datum/demon_data/_dd126 = new /datum/demon_data()
	_dd126.demon_name = "Yoshitsune"
	_dd126.demon_race = "Hero"
	_dd126.demon_lvl = 57
	_dd126.demon_str = 22
	_dd126.demon_for = 16
	_dd126.demon_end = 12
	_dd126.demon_spd = 23
	_dd126.demon_off = 11
	_dd126.demon_def = 6
	_dd126.demon_skills = list("Hassohappa")
	_dd126.demon_skill_learn = list("Piercing Hit" = 59)
	_dd126.demon_unique = TRUE
	_dd126.demon_icon = 'Icons/DevilSummoner/Demons/Yoshitsune.dmi'
	_dd126.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Yoshitsune128.dmi'
	_dd126.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Yoshitsune32.dmi'
	db["Yoshitsune"] = _dd126

	// Guan Yu (Hero, Lv 70)
	var/datum/demon_data/_dd127 = new /datum/demon_data()
	_dd127.demon_name = "Guan Yu"
	_dd127.demon_race = "Hero"
	_dd127.demon_lvl = 70
	_dd127.demon_str = 25
	_dd127.demon_for = 26
	_dd127.demon_end = 22
	_dd127.demon_spd = 13
	_dd127.demon_off = 13
	_dd127.demon_def = 11
	_dd127.demon_skills = list("Holy Strike")
	_dd127.demon_unique = TRUE
	_dd127.demon_icon = 'Icons/DevilSummoner/Demons/Guan Yu.dmi'
	_dd127.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Guan Yu128.dmi'
	_dd127.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Guan Yu32.dmi'
	db["Guan Yu"] = _dd127

	// Masakado (Hero, Lv 82)
	var/datum/demon_data/_dd128 = new /datum/demon_data()
	_dd128.demon_name = "Masakado"
	_dd128.demon_race = "Hero"
	_dd128.demon_lvl = 82
	_dd128.demon_str = 26
	_dd128.demon_for = 24
	_dd128.demon_end = 24
	_dd128.demon_spd = 24
	_dd128.demon_off = 13
	_dd128.demon_def = 12
	_dd128.demon_skills = list("None")
	_dd128.demon_passives = list("Anti-All")
	_dd128.demon_unique = TRUE
	_dd128.demon_icon = 'Icons/DevilSummoner/Demons/Masakado.dmi'
	_dd128.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Masakado128.dmi'
	_dd128.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Masakado32.dmi'
	db["Masakado"] = _dd128

	// Obariyon (Jaki, Lv 3)
	var/datum/demon_data/_dd129 = new /datum/demon_data()
	_dd129.demon_name = "Obariyon"
	_dd129.demon_race = "Jaki"
	_dd129.demon_lvl = 3
	_dd129.demon_str = 6
	_dd129.demon_for = 4
	_dd129.demon_end = 5
	_dd129.demon_spd = 4
	_dd129.demon_off = 3
	_dd129.demon_def = 3
	_dd129.demon_skills = list("Extra Cancel")
	_dd129.demon_skill_learn = list("Dia" = 27)
	_dd129.demon_passive_learn = list("Life Bonus" = 25, "Race-O" = 26)
	_dd129.demon_unique = FALSE
	_dd129.demon_icon = 'Icons/DevilSummoner/Demons/Obariyon.dmi'
	_dd129.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Obariyon128.dmi'
	_dd129.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Obariyon32.dmi'
	db["Obariyon"] = _dd129

	// Ogre (Jaki, Lv 8)
	var/datum/demon_data/_dd130 = new /datum/demon_data()
	_dd130.demon_name = "Ogre"
	_dd130.demon_race = "Jaki"
	_dd130.demon_lvl = 8
	_dd130.demon_str = 10
	_dd130.demon_for = 5
	_dd130.demon_end = 6
	_dd130.demon_spd = 3
	_dd130.demon_off = 5
	_dd130.demon_def = 3
	_dd130.demon_skills = list("Anger Hit")
	_dd130.demon_passives = list("Knight Soul")
	_dd130.demon_skill_learn = list("Berserk" = 29)
	_dd130.demon_passive_learn = list("Watchful" = 10, "Counter" = 27, "Phys Up" = 28)
	_dd130.demon_unique = FALSE
	_dd130.demon_icon = 'Icons/DevilSummoner/Demons/Ogre.dmi'
	_dd130.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ogre128.dmi'
	_dd130.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ogre32.dmi'
	db["Ogre"] = _dd130

	// Mokoi (Jaki, Lv 15)
	var/datum/demon_data/_dd131 = new /datum/demon_data()
	_dd131.demon_name = "Mokoi"
	_dd131.demon_race = "Jaki"
	_dd131.demon_lvl = 15
	_dd131.demon_str = 9
	_dd131.demon_for = 7
	_dd131.demon_end = 9
	_dd131.demon_spd = 6
	_dd131.demon_off = 5
	_dd131.demon_def = 5
	_dd131.demon_skills = list("Fatal Strike")
	_dd131.demon_skill_learn = list("Berserk" = 31, "Extra Cancel" = 32, "Ice Dance" = 33)
	_dd131.demon_passive_learn = list("Watchful" = 16, "Moneybags" = 17, "Counter" = 29, "Race-D" = 30)
	_dd131.demon_unique = FALSE
	_dd131.demon_icon = 'Icons/DevilSummoner/Demons/Mokoi.dmi'
	_dd131.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mokoi128.dmi'
	_dd131.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mokoi32.dmi'
	db["Mokoi"] = _dd131

	// Ogun (Jaki, Lv 23)
	var/datum/demon_data/_dd132 = new /datum/demon_data()
	_dd132.demon_name = "Ogun"
	_dd132.demon_race = "Jaki"
	_dd132.demon_lvl = 23
	_dd132.demon_str = 15
	_dd132.demon_for = 6
	_dd132.demon_end = 9
	_dd132.demon_spd = 9
	_dd132.demon_off = 8
	_dd132.demon_def = 5
	_dd132.demon_skills = list("Fire Dance")
	_dd132.demon_passives = list("Counter")
	_dd132.demon_skill_learn = list("Multi-Hit" = 24, "Brutal Hit" = 33)
	_dd132.demon_passive_learn = list("Anti-Fire" = 25, "Ares Aid" = 31, "Retaliate" = 32)
	_dd132.demon_unique = FALSE
	_dd132.demon_icon = 'Icons/DevilSummoner/Demons/Ogun.dmi'
	_dd132.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ogun128.dmi'
	_dd132.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ogun32.dmi'
	db["Ogun"] = _dd132

	// Wendigo (Jaki, Lv 31)
	var/datum/demon_data/_dd133 = new /datum/demon_data()
	_dd133.demon_name = "Wendigo"
	_dd133.demon_race = "Jaki"
	_dd133.demon_lvl = 31
	_dd133.demon_str = 15
	_dd133.demon_for = 7
	_dd133.demon_end = 12
	_dd133.demon_spd = 13
	_dd133.demon_off = 8
	_dd133.demon_def = 6
	_dd133.demon_skills = list("Ice Dance")
	_dd133.demon_passives = list("Anti-Ice")
	_dd133.demon_skill_learn = list("Brutal Hit" = 32, "Mighty Hit" = 35)
	_dd133.demon_passive_learn = list("Ice Boost" = 33, "Life Surge" = 34)
	_dd133.demon_unique = FALSE
	_dd133.demon_icon = 'Icons/DevilSummoner/Demons/Wendigo.dmi'
	_dd133.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Wendigo128.dmi'
	_dd133.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Wendigo32.dmi'
	db["Wendigo"] = _dd133

	// Legion (Jaki, Lv 39)
	var/datum/demon_data/_dd134 = new /datum/demon_data()
	_dd134.demon_name = "Legion"
	_dd134.demon_race = "Jaki"
	_dd134.demon_lvl = 39
	_dd134.demon_str = 10
	_dd134.demon_for = 17
	_dd134.demon_end = 19
	_dd134.demon_spd = 9
	_dd134.demon_off = 5
	_dd134.demon_def = 10
	_dd134.demon_skills = list("Petra Eyes")
	_dd134.demon_passives = list("Anti-Phys")
	_dd134.demon_skill_learn = list("Bufudyne" = 40, "Power Hit" = 49)
	_dd134.demon_passive_learn = list("Endure" = 47, "Swift Step" = 48)
	_dd134.demon_unique = FALSE
	_dd134.demon_icon = 'Icons/DevilSummoner/Demons/Legion.dmi'
	_dd134.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Legion128.dmi'
	_dd134.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Legion32.dmi'
	db["Legion"] = _dd134

	// Girimehkala (Jaki, Lv 47)
	var/datum/demon_data/_dd135 = new /datum/demon_data()
	_dd135.demon_name = "Girimehkala"
	_dd135.demon_race = "Jaki"
	_dd135.demon_lvl = 47
	_dd135.demon_str = 20
	_dd135.demon_for = 14
	_dd135.demon_end = 19
	_dd135.demon_spd = 10
	_dd135.demon_off = 10
	_dd135.demon_def = 10
	_dd135.demon_skills = list("Bufudyne")
	_dd135.demon_skill_learn = list("Hassohappa" = 48, "Shield All" = 57)
	_dd135.demon_passive_learn = list("Ice Amp" = 49, "Grimoire" = 55, "Null Phys" = 56)
	_dd135.demon_unique = FALSE
	_dd135.demon_icon = 'Icons/DevilSummoner/Demons/Girimehkala.dmi'
	_dd135.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Girimehkala128.dmi'
	_dd135.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Girimehkala32.dmi'
	db["Girimehkala"] = _dd135

	// Rakshasa (Jaki, Lv 55)
	var/datum/demon_data/_dd136 = new /datum/demon_data()
	_dd136.demon_name = "Rakshasa"
	_dd136.demon_race = "Jaki"
	_dd136.demon_lvl = 55
	_dd136.demon_str = 23
	_dd136.demon_for = 12
	_dd136.demon_end = 16
	_dd136.demon_spd = 20
	_dd136.demon_off = 12
	_dd136.demon_def = 8
	_dd136.demon_skills = list("Deathbound")
	_dd136.demon_passives = list("Null Phys")
	_dd136.demon_skill_learn = list("Piercing Hit" = 66)
	_dd136.demon_passive_learn = list("Ice Drain" = 63, "Phys Amp" = 64, "Phys Boost" = 65)
	_dd136.demon_unique = FALSE
	_dd136.demon_icon = 'Icons/DevilSummoner/Demons/Rakshasa.dmi'
	_dd136.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Rakshasa128.dmi'
	_dd136.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Rakshasa32.dmi'
	db["Rakshasa"] = _dd136

	// Grendel (Jaki, Lv 64)
	var/datum/demon_data/_dd137 = new /datum/demon_data()
	_dd137.demon_name = "Grendel"
	_dd137.demon_race = "Jaki"
	_dd137.demon_lvl = 64
	_dd137.demon_str = 27
	_dd137.demon_for = 14
	_dd137.demon_end = 23
	_dd137.demon_spd = 16
	_dd137.demon_off = 14
	_dd137.demon_def = 12
	_dd137.demon_skills = list("Tetrakarn")
	_dd137.demon_passive_learn = list("Avenge" = 65)
	_dd137.demon_unique = TRUE
	_dd137.demon_icon = 'Icons/DevilSummoner/Demons/Grendel.dmi'
	_dd137.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Grendel128.dmi'
	_dd137.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Grendel32.dmi'
	db["Grendel"] = _dd137

	// Black Frost (Jaki, Lv 80)
	var/datum/demon_data/_dd138 = new /datum/demon_data()
	_dd138.demon_name = "Black Frost"
	_dd138.demon_race = "Jaki"
	_dd138.demon_lvl = 80
	_dd138.demon_str = 27
	_dd138.demon_for = 27
	_dd138.demon_end = 22
	_dd138.demon_spd = 20
	_dd138.demon_off = 14
	_dd138.demon_def = 11
	_dd138.demon_skills = list("Mabufudyne")
	_dd138.demon_passives = list("Fire Repel", "Ice Repel")
	_dd138.demon_unique = TRUE
	_dd138.demon_icon = 'Icons/DevilSummoner/Demons/Black Frost.dmi'
	_dd138.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Black Frost128.dmi'
	_dd138.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Black Frost32.dmi'
	db["Black Frost"] = _dd138

	// Ubelluris (Kishin, Lv 20)
	var/datum/demon_data/_dd139 = new /datum/demon_data()
	_dd139.demon_name = "Ubelluris"
	_dd139.demon_race = "Kishin"
	_dd139.demon_lvl = 20
	_dd139.demon_str = 14
	_dd139.demon_for = 4
	_dd139.demon_end = 12
	_dd139.demon_spd = 6
	_dd139.demon_off = 7
	_dd139.demon_def = 6
	_dd139.demon_skills = list("Berserk")
	_dd139.demon_passive_learn = list("Counter" = 21)
	_dd139.demon_unique = FALSE
	_dd139.demon_icon = 'Icons/DevilSummoner/Demons/Ubelluris.dmi'
	_dd139.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ubelluris128.dmi'
	_dd139.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ubelluris32.dmi'
	db["Ubelluris"] = _dd139

	// Nalagiri (Kishin, Lv 28)
	var/datum/demon_data/_dd140 = new /datum/demon_data()
	_dd140.demon_name = "Nalagiri"
	_dd140.demon_race = "Kishin"
	_dd140.demon_lvl = 28
	_dd140.demon_str = 14
	_dd140.demon_for = 7
	_dd140.demon_end = 14
	_dd140.demon_spd = 9
	_dd140.demon_off = 7
	_dd140.demon_def = 7
	_dd140.demon_skills = list("Power Hit")
	_dd140.demon_passive_learn = list("Anti-Phys" = 30)
	_dd140.demon_unique = FALSE
	_dd140.demon_icon = 'Icons/DevilSummoner/Demons/Nalagiri.dmi'
	_dd140.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nalagiri128.dmi'
	_dd140.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nalagiri32.dmi'
	db["Nalagiri"] = _dd140

	// Hitokotonusi (Kishin, Lv 36)
	var/datum/demon_data/_dd141 = new /datum/demon_data()
	_dd141.demon_name = "Hitokotonusi"
	_dd141.demon_race = "Kishin"
	_dd141.demon_lvl = 36
	_dd141.demon_str = 17
	_dd141.demon_for = 8
	_dd141.demon_end = 15
	_dd141.demon_spd = 12
	_dd141.demon_off = 9
	_dd141.demon_def = 8
	_dd141.demon_skills = list("Might Call")
	_dd141.demon_skill_learn = list("Mighty Hit" = 38)
	_dd141.demon_unique = TRUE
	_dd141.demon_icon = 'Icons/DevilSummoner/Demons/Hitokotonusi.dmi'
	_dd141.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hitokotonusi128.dmi'
	_dd141.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hitokotonusi32.dmi'
	db["Hitokotonusi"] = _dd141

	// Take-Mikazuchi (Kishin, Lv 43)
	var/datum/demon_data/_dd142 = new /datum/demon_data()
	_dd142.demon_name = "Take-Mikazuchi"
	_dd142.demon_race = "Kishin"
	_dd142.demon_lvl = 43
	_dd142.demon_str = 23
	_dd142.demon_for = 10
	_dd142.demon_end = 15
	_dd142.demon_spd = 11
	_dd142.demon_off = 12
	_dd142.demon_def = 8
	_dd142.demon_skills = list("Mazio")
	_dd142.demon_passives = list("Phys Boost")
	_dd142.demon_skill_learn = list("Multi-Strike" = 45)
	_dd142.demon_unique = TRUE
	_dd142.demon_icon = 'Icons/DevilSummoner/Demons/Take-Mikazuchi.dmi'
	_dd142.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Take-Mikazuchi128.dmi'
	_dd142.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Take-Mikazuchi32.dmi'
	db["Take-Mikazuchi"] = _dd142

	// Zouchouten (Kishin, Lv 50)
	var/datum/demon_data/_dd143 = new /datum/demon_data()
	_dd143.demon_name = "Zouchouten"
	_dd143.demon_race = "Kishin"
	_dd143.demon_lvl = 50
	_dd143.demon_str = 22
	_dd143.demon_for = 15
	_dd143.demon_end = 17
	_dd143.demon_spd = 12
	_dd143.demon_off = 11
	_dd143.demon_def = 9
	_dd143.demon_skills = list("Agidyne")
	_dd143.demon_passive_learn = list("Fire Amp" = 51)
	_dd143.demon_unique = TRUE
	_dd143.demon_icon = 'Icons/DevilSummoner/Demons/Zouchouten.dmi'
	_dd143.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Zouchouten128.dmi'
	_dd143.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Zouchouten32.dmi'
	db["Zouchouten"] = _dd143

	// Jikokuten (Kishin, Lv 57)
	var/datum/demon_data/_dd144 = new /datum/demon_data()
	_dd144.demon_name = "Jikokuten"
	_dd144.demon_race = "Kishin"
	_dd144.demon_lvl = 57
	_dd144.demon_str = 24
	_dd144.demon_for = 16
	_dd144.demon_end = 22
	_dd144.demon_spd = 11
	_dd144.demon_off = 12
	_dd144.demon_def = 11
	_dd144.demon_skills = list("Ziodyne")
	_dd144.demon_passive_learn = list("Elec Amp" = 58, "Elec Drain" = 59)
	_dd144.demon_unique = TRUE
	_dd144.demon_icon = 'Icons/DevilSummoner/Demons/Jikokuten.dmi'
	_dd144.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Jikokuten128.dmi'
	_dd144.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Jikokuten32.dmi'
	db["Jikokuten"] = _dd144

	// Koumoukuten (Kishin, Lv 64)
	var/datum/demon_data/_dd145 = new /datum/demon_data()
	_dd145.demon_name = "Koumoukuten"
	_dd145.demon_race = "Kishin"
	_dd145.demon_lvl = 64
	_dd145.demon_str = 25
	_dd145.demon_for = 17
	_dd145.demon_end = 23
	_dd145.demon_spd = 15
	_dd145.demon_off = 13
	_dd145.demon_def = 12
	_dd145.demon_skills = list("Mazandyne")
	_dd145.demon_passive_learn = list("Avenge" = 66)
	_dd145.demon_unique = TRUE
	_dd145.demon_icon = 'Icons/DevilSummoner/Demons/Koumoukuten.dmi'
	_dd145.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Koumoukuten128.dmi'
	_dd145.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Koumoukuten32.dmi'
	db["Koumoukuten"] = _dd145

	// Bishamonten (Kishin, Lv 71)
	var/datum/demon_data/_dd146 = new /datum/demon_data()
	_dd146.demon_name = "Bishamonten"
	_dd146.demon_race = "Kishin"
	_dd146.demon_lvl = 71
	_dd146.demon_str = 29
	_dd146.demon_for = 15
	_dd146.demon_end = 26
	_dd146.demon_spd = 17
	_dd146.demon_off = 15
	_dd146.demon_def = 13
	_dd146.demon_skills = list("Hassohappa")
	_dd146.demon_passive_learn = list("Fire Repel" = 72)
	_dd146.demon_unique = TRUE
	_dd146.demon_icon = 'Icons/DevilSummoner/Demons/Bishamonten.dmi'
	_dd146.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Bishamonten128.dmi'
	_dd146.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Bishamonten32.dmi'
	db["Bishamonten"] = _dd146

	// Ometeotl (Kishin, Lv 75)
	var/datum/demon_data/_dd147 = new /datum/demon_data()
	_dd147.demon_name = "Ometeotl"
	_dd147.demon_race = "Kishin"
	_dd147.demon_lvl = 75
	_dd147.demon_str = 28
	_dd147.demon_for = 28
	_dd147.demon_end = 20
	_dd147.demon_spd = 15
	_dd147.demon_off = 14
	_dd147.demon_def = 10
	_dd147.demon_skills = list("None")
	_dd147.demon_passives = list("Double Strike")
	_dd147.demon_unique = TRUE
	_dd147.demon_icon = 'Icons/DevilSummoner/Demons/Ometeotl.dmi'
	_dd147.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ometeotl128.dmi'
	_dd147.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ometeotl32.dmi'
	db["Ometeotl"] = _dd147

	// Zaou-Gongen (Kishin, Lv 93)
	var/datum/demon_data/_dd148 = new /datum/demon_data()
	_dd148.demon_name = "Zaou-Gongen"
	_dd148.demon_race = "Kishin"
	_dd148.demon_lvl = 93
	_dd148.demon_str = 28
	_dd148.demon_for = 31
	_dd148.demon_end = 24
	_dd148.demon_spd = 26
	_dd148.demon_off = 14
	_dd148.demon_def = 12
	_dd148.demon_skills = list("None")
	_dd148.demon_unique = TRUE
	_dd148.demon_icon = 'Icons/DevilSummoner/Demons/Zaou-Gongen.dmi'
	_dd148.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Zaou-Gongen128.dmi'
	_dd148.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Zaou-Gongen32.dmi'
	db["Zaou-Gongen"] = _dd148

	// Sarasvati (Megami, Lv 19)
	var/datum/demon_data/_dd149 = new /datum/demon_data()
	_dd149.demon_name = "Sarasvati"
	_dd149.demon_race = "Megami"
	_dd149.demon_lvl = 19
	_dd149.demon_str = 6
	_dd149.demon_for = 14
	_dd149.demon_end = 8
	_dd149.demon_spd = 7
	_dd149.demon_off = 3
	_dd149.demon_def = 4
	_dd149.demon_skills = list("Diarama")
	_dd149.demon_passive_learn = list("Anti-Force" = 21)
	_dd149.demon_unique = FALSE
	_dd149.demon_icon = 'Icons/DevilSummoner/Demons/Sarasvati.dmi'
	_dd149.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Sarasvati128.dmi'
	_dd149.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Sarasvati32.dmi'
	db["Sarasvati"] = _dd149

	// Kikuri-Hime (Megami, Lv 27)
	var/datum/demon_data/_dd150 = new /datum/demon_data()
	_dd150.demon_name = "Kikuri-Hime"
	_dd150.demon_race = "Megami"
	_dd150.demon_lvl = 27
	_dd150.demon_str = 9
	_dd150.demon_for = 15
	_dd150.demon_end = 12
	_dd150.demon_spd = 7
	_dd150.demon_off = 5
	_dd150.demon_def = 6
	_dd150.demon_skills = list("Media")
	_dd150.demon_skill_learn = list("Recarm" = 29)
	_dd150.demon_unique = FALSE
	_dd150.demon_icon = 'Icons/DevilSummoner/Demons/Kikuri-Hime.dmi'
	_dd150.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kikuri-Hime128.dmi'
	_dd150.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kikuri-Hime32.dmi'
	db["Kikuri-Hime"] = _dd150

	// Hathor (Megami, Lv 31)
	var/datum/demon_data/_dd151 = new /datum/demon_data()
	_dd151.demon_name = "Hathor"
	_dd151.demon_race = "Megami"
	_dd151.demon_lvl = 31
	_dd151.demon_str = 10
	_dd151.demon_for = 18
	_dd151.demon_end = 9
	_dd151.demon_spd = 10
	_dd151.demon_off = 5
	_dd151.demon_def = 5
	_dd151.demon_skills = list("Recarm")
	_dd151.demon_passive_learn = list("Mana Surge" = 32)
	_dd151.demon_unique = TRUE
	_dd151.demon_icon = 'Icons/DevilSummoner/Demons/Hathor.dmi'
	_dd151.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hathor128.dmi'
	_dd151.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hathor32.dmi'
	db["Hathor"] = _dd151

	// Brigid (Megami, Lv 35)
	var/datum/demon_data/_dd152 = new /datum/demon_data()
	_dd152.demon_name = "Brigid"
	_dd152.demon_race = "Megami"
	_dd152.demon_lvl = 35
	_dd152.demon_str = 10
	_dd152.demon_for = 18
	_dd152.demon_end = 10
	_dd152.demon_spd = 13
	_dd152.demon_off = 5
	_dd152.demon_def = 5
	_dd152.demon_skills = list("Media")
	_dd152.demon_passive_learn = list("Null Fire" = 36)
	_dd152.demon_unique = FALSE
	_dd152.demon_icon = 'Icons/DevilSummoner/Demons/Brigid.dmi'
	_dd152.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Brigid128.dmi'
	_dd152.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Brigid32.dmi'
	db["Brigid"] = _dd152

	// Scathach (Megami, Lv 43)
	var/datum/demon_data/_dd153 = new /datum/demon_data()
	_dd153.demon_name = "Scathach"
	_dd153.demon_race = "Megami"
	_dd153.demon_lvl = 43
	_dd153.demon_str = 18
	_dd153.demon_for = 19
	_dd153.demon_end = 11
	_dd153.demon_spd = 11
	_dd153.demon_off = 9
	_dd153.demon_def = 6
	_dd153.demon_skills = list("Recarm")
	_dd153.demon_passives = list("Anti-Ailment", "Null Force")
	_dd153.demon_unique = TRUE
	_dd153.demon_icon = 'Icons/DevilSummoner/Demons/Scathach.dmi'
	_dd153.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Scathach128.dmi'
	_dd153.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Scathach32.dmi'
	db["Scathach"] = _dd153

	// Laksmi (Megami, Lv 51)
	var/datum/demon_data/_dd154 = new /datum/demon_data()
	_dd154.demon_name = "Laksmi"
	_dd154.demon_race = "Megami"
	_dd154.demon_lvl = 51
	_dd154.demon_str = 14
	_dd154.demon_for = 22
	_dd154.demon_end = 15
	_dd154.demon_spd = 16
	_dd154.demon_off = 7
	_dd154.demon_def = 8
	_dd154.demon_skills = list("Recarm")
	_dd154.demon_skill_learn = list("Mediarahan" = 53)
	_dd154.demon_unique = FALSE
	_dd154.demon_icon = 'Icons/DevilSummoner/Demons/Laksmi.dmi'
	_dd154.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Laksmi128.dmi'
	_dd154.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Laksmi32.dmi'
	db["Laksmi"] = _dd154

	// Isis (Megami, Lv 55)
	var/datum/demon_data/_dd155 = new /datum/demon_data()
	_dd155.demon_name = "Isis"
	_dd155.demon_race = "Megami"
	_dd155.demon_lvl = 55
	_dd155.demon_str = 16
	_dd155.demon_for = 27
	_dd155.demon_end = 15
	_dd155.demon_spd = 13
	_dd155.demon_off = 8
	_dd155.demon_def = 8
	_dd155.demon_skills = list("Tetrakarn")
	_dd155.demon_skill_learn = list("Mediarahan" = 56)
	_dd155.demon_unique = TRUE
	_dd155.demon_icon = 'Icons/DevilSummoner/Demons/Isis.dmi'
	_dd155.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Isis128.dmi'
	_dd155.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Isis32.dmi'
	db["Isis"] = _dd155

	// Parvati (Megami, Lv 59)
	var/datum/demon_data/_dd156 = new /datum/demon_data()
	_dd156.demon_name = "Parvati"
	_dd156.demon_race = "Megami"
	_dd156.demon_lvl = 59
	_dd156.demon_str = 12
	_dd156.demon_for = 27
	_dd156.demon_end = 20
	_dd156.demon_spd = 16
	_dd156.demon_off = 6
	_dd156.demon_def = 10
	_dd156.demon_skills = list("Mediarahan")
	_dd156.demon_unique = TRUE
	_dd156.demon_icon = 'Icons/DevilSummoner/Demons/Parvati.dmi'
	_dd156.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Parvati128.dmi'
	_dd156.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Parvati32.dmi'
	db["Parvati"] = _dd156

	// Norn (Megami, Lv 64)
	var/datum/demon_data/_dd157 = new /datum/demon_data()
	_dd157.demon_name = "Norn"
	_dd157.demon_race = "Megami"
	_dd157.demon_lvl = 64
	_dd157.demon_str = 19
	_dd157.demon_for = 25
	_dd157.demon_end = 16
	_dd157.demon_spd = 20
	_dd157.demon_off = 10
	_dd157.demon_def = 8
	_dd157.demon_skills = list("Prayer")
	_dd157.demon_passive_learn = list("Mana Aid" = 65)
	_dd157.demon_unique = TRUE
	_dd157.demon_icon = 'Icons/DevilSummoner/Demons/Norn.dmi'
	_dd157.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Norn128.dmi'
	_dd157.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Norn32.dmi'
	db["Norn"] = _dd157

	// Pallas Athena (Megami, Lv 69)
	var/datum/demon_data/_dd158 = new /datum/demon_data()
	_dd158.demon_name = "Pallas Athena"
	_dd158.demon_race = "Megami"
	_dd158.demon_lvl = 69
	_dd158.demon_str = 25
	_dd158.demon_for = 20
	_dd158.demon_end = 24
	_dd158.demon_spd = 16
	_dd158.demon_off = 13
	_dd158.demon_def = 12
	_dd158.demon_skills = list("Prayer")
	_dd158.demon_passive_learn = list("Phys Repel" = 71)
	_dd158.demon_unique = TRUE
	_dd158.demon_icon = 'Icons/DevilSummoner/Demons/Pallas Athena.dmi'
	_dd158.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pallas Athena128.dmi'
	_dd158.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pallas Athena32.dmi'
	db["Pallas Athena"] = _dd158

	// Amaterasu (Megami, Lv 77)
	var/datum/demon_data/_dd159 = new /datum/demon_data()
	_dd159.demon_name = "Amaterasu"
	_dd159.demon_race = "Megami"
	_dd159.demon_lvl = 77
	_dd159.demon_str = 22
	_dd159.demon_for = 31
	_dd159.demon_end = 21
	_dd159.demon_spd = 19
	_dd159.demon_off = 11
	_dd159.demon_def = 11
	_dd159.demon_skills = list("Samarecarm")
	_dd159.demon_skill_learn = list("Prayer" = 78)
	_dd159.demon_unique = TRUE
	_dd159.demon_icon = 'Icons/DevilSummoner/Demons/Amaterasu.dmi'
	_dd159.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Amaterasu128.dmi'
	_dd159.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Amaterasu32.dmi'
	db["Amaterasu"] = _dd159

	// Saki Mitama (Mitama, Lv 35)
	var/datum/demon_data/_dd160 = new /datum/demon_data()
	_dd160.demon_name = "Saki Mitama"
	_dd160.demon_race = "Mitama"
	_dd160.demon_lvl = 35
	_dd160.demon_str = 10
	_dd160.demon_for = 10
	_dd160.demon_end = 21
	_dd160.demon_spd = 10
	_dd160.demon_off = 5
	_dd160.demon_def = 11
	_dd160.demon_skills = list("None")
	_dd160.demon_unique = FALSE
	_dd160.demon_icon = 'Icons/DevilSummoner/Demons/Saki Mitama.dmi'
	_dd160.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Saki Mitama128.dmi'
	_dd160.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Saki Mitama32.dmi'
	db["Saki Mitama"] = _dd160

	// Kusi Mitama (Mitama, Lv 40)
	var/datum/demon_data/_dd161 = new /datum/demon_data()
	_dd161.demon_name = "Kusi Mitama"
	_dd161.demon_race = "Mitama"
	_dd161.demon_lvl = 40
	_dd161.demon_str = 11
	_dd161.demon_for = 11
	_dd161.demon_end = 11
	_dd161.demon_spd = 23
	_dd161.demon_off = 6
	_dd161.demon_def = 6
	_dd161.demon_skills = list("None")
	_dd161.demon_unique = FALSE
	_dd161.demon_icon = 'Icons/DevilSummoner/Demons/Kusi Mitama.dmi'
	_dd161.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kusi Mitama128.dmi'
	_dd161.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kusi Mitama32.dmi'
	db["Kusi Mitama"] = _dd161

	// Ara Mitama (Mitama, Lv 45)
	var/datum/demon_data/_dd162 = new /datum/demon_data()
	_dd162.demon_name = "Ara Mitama"
	_dd162.demon_race = "Mitama"
	_dd162.demon_lvl = 45
	_dd162.demon_str = 22
	_dd162.demon_for = 13
	_dd162.demon_end = 13
	_dd162.demon_spd = 13
	_dd162.demon_off = 11
	_dd162.demon_def = 7
	_dd162.demon_skills = list("None")
	_dd162.demon_unique = FALSE
	_dd162.demon_icon = 'Icons/DevilSummoner/Demons/Ara Mitama.dmi'
	_dd162.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ara Mitama128.dmi'
	_dd162.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ara Mitama32.dmi'
	db["Ara Mitama"] = _dd162

	// Nigi Mitama (Mitama, Lv 49)
	var/datum/demon_data/_dd163 = new /datum/demon_data()
	_dd163.demon_name = "Nigi Mitama"
	_dd163.demon_race = "Mitama"
	_dd163.demon_lvl = 49
	_dd163.demon_str = 14
	_dd163.demon_for = 23
	_dd163.demon_end = 14
	_dd163.demon_spd = 14
	_dd163.demon_off = 7
	_dd163.demon_def = 7
	_dd163.demon_skills = list("None")
	_dd163.demon_unique = FALSE
	_dd163.demon_icon = 'Icons/DevilSummoner/Demons/Nigi Mitama.dmi'
	_dd163.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nigi Mitama128.dmi'
	_dd163.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nigi Mitama32.dmi'
	db["Nigi Mitama"] = _dd163

	// Tonatiuh (Omega, Lv 34)
	var/datum/demon_data/_dd164 = new /datum/demon_data()
	_dd164.demon_name = "Tonatiuh"
	_dd164.demon_race = "Omega"
	_dd164.demon_lvl = 34
	_dd164.demon_str = 18
	_dd164.demon_for = 9
	_dd164.demon_end = 12
	_dd164.demon_spd = 11
	_dd164.demon_off = 9
	_dd164.demon_def = 6
	_dd164.demon_skills = list("Might Call")
	_dd164.demon_passive_learn = list("Phys Boost" = 35)
	_dd164.demon_unique = TRUE
	_dd164.demon_icon = 'Icons/DevilSummoner/Demons/Tonatiuh.dmi'
	_dd164.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tonatiuh128.dmi'
	_dd164.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tonatiuh32.dmi'
	db["Tonatiuh"] = _dd164

	// Chernobog (Omega, Lv 43)
	var/datum/demon_data/_dd165 = new /datum/demon_data()
	_dd165.demon_name = "Chernobog"
	_dd165.demon_race = "Omega"
	_dd165.demon_lvl = 43
	_dd165.demon_str = 20
	_dd165.demon_for = 14
	_dd165.demon_end = 15
	_dd165.demon_spd = 10
	_dd165.demon_off = 10
	_dd165.demon_def = 8
	_dd165.demon_skills = list("Gigajama")
	_dd165.demon_passive_learn = list("Null Ice" = 44)
	_dd165.demon_unique = TRUE
	_dd165.demon_icon = 'Icons/DevilSummoner/Demons/Chernobog.dmi'
	_dd165.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Chernobog128.dmi'
	_dd165.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Chernobog32.dmi'
	db["Chernobog"] = _dd165

	// Wu Kong (Omega, Lv 52)
	var/datum/demon_data/_dd166 = new /datum/demon_data()
	_dd166.demon_name = "Wu Kong"
	_dd166.demon_race = "Omega"
	_dd166.demon_lvl = 52
	_dd166.demon_str = 23
	_dd166.demon_for = 10
	_dd166.demon_end = 14
	_dd166.demon_spd = 21
	_dd166.demon_off = 12
	_dd166.demon_def = 7
	_dd166.demon_skills = list("Multi-Strike")
	_dd166.demon_passives = list("Null Phys")
	_dd166.demon_unique = TRUE
	_dd166.demon_icon = 'Icons/DevilSummoner/Demons/Wu Kong.dmi'
	_dd166.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Wu Kong128.dmi'
	_dd166.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Wu Kong32.dmi'
	db["Wu Kong"] = _dd166

	// Kartikeya (Omega, Lv 56)
	var/datum/demon_data/_dd167 = new /datum/demon_data()
	_dd167.demon_name = "Kartikeya"
	_dd167.demon_race = "Omega"
	_dd167.demon_lvl = 56
	_dd167.demon_str = 19
	_dd167.demon_for = 15
	_dd167.demon_end = 12
	_dd167.demon_spd = 26
	_dd167.demon_off = 10
	_dd167.demon_def = 6
	_dd167.demon_skills = list("Multi-Strike")
	_dd167.demon_skill_learn = list("Megido" = 57)
	_dd167.demon_passive_learn = list("Attack All" = 58)
	_dd167.demon_unique = TRUE
	_dd167.demon_icon = 'Icons/DevilSummoner/Demons/Kartikeya.dmi'
	_dd167.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kartikeya128.dmi'
	_dd167.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kartikeya32.dmi'
	db["Kartikeya"] = _dd167

	// Susano-o (Omega, Lv 60)
	var/datum/demon_data/_dd168 = new /datum/demon_data()
	_dd168.demon_name = "Susano-o"
	_dd168.demon_race = "Omega"
	_dd168.demon_lvl = 60
	_dd168.demon_str = 26
	_dd168.demon_for = 19
	_dd168.demon_end = 19
	_dd168.demon_spd = 12
	_dd168.demon_off = 13
	_dd168.demon_def = 10
	_dd168.demon_skills = list("Mazandyne")
	_dd168.demon_passives = list("Force Amp")
	_dd168.demon_unique = TRUE
	_dd168.demon_icon = 'Icons/DevilSummoner/Demons/Susano-o.dmi'
	_dd168.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Susano-o128.dmi'
	_dd168.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Susano-o32.dmi'
	db["Susano-o"] = _dd168

	// Beiji-Weng (Omega, Lv 70)
	var/datum/demon_data/_dd169 = new /datum/demon_data()
	_dd169.demon_name = "Beiji-Weng"
	_dd169.demon_race = "Omega"
	_dd169.demon_lvl = 70
	_dd169.demon_str = 28
	_dd169.demon_for = 20
	_dd169.demon_end = 15
	_dd169.demon_spd = 23
	_dd169.demon_off = 14
	_dd169.demon_def = 8
	_dd169.demon_skills = list("Megidolaon")
	_dd169.demon_unique = TRUE
	_dd169.demon_icon = 'Icons/DevilSummoner/Demons/Beiji-Weng.dmi'
	_dd169.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Beiji-Weng128.dmi'
	_dd169.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Beiji-Weng32.dmi'
	db["Beiji-Weng"] = _dd169

	// Shiva (Omega, Lv 76)
	var/datum/demon_data/_dd170 = new /datum/demon_data()
	_dd170.demon_name = "Shiva"
	_dd170.demon_race = "Omega"
	_dd170.demon_lvl = 76
	_dd170.demon_str = 25
	_dd170.demon_for = 22
	_dd170.demon_end = 25
	_dd170.demon_spd = 20
	_dd170.demon_off = 13
	_dd170.demon_def = 13
	_dd170.demon_skills = list("Tandava")
	_dd170.demon_passives = list("Avenge")
	_dd170.demon_unique = TRUE
	_dd170.demon_icon = 'Icons/DevilSummoner/Demons/Shiva.dmi'
	_dd170.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Shiva128.dmi'
	_dd170.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Shiva32.dmi'
	db["Shiva"] = _dd170

	// Makara (Snake, Lv 14)
	var/datum/demon_data/_dd171 = new /datum/demon_data()
	_dd171.demon_name = "Makara"
	_dd171.demon_race = "Snake"
	_dd171.demon_lvl = 14
	_dd171.demon_str = 7
	_dd171.demon_for = 8
	_dd171.demon_end = 6
	_dd171.demon_spd = 9
	_dd171.demon_off = 4
	_dd171.demon_def = 3
	_dd171.demon_skills = list("Taunt")
	_dd171.demon_skill_learn = list("Dia" = 16, "Diarama" = 35, "Fire Dance" = 36)
	_dd171.demon_passive_learn = list("Anti-Curse" = 15, "Dodge" = 33, "Vigilant" = 34)
	_dd171.demon_unique = FALSE
	_dd171.demon_icon = 'Icons/DevilSummoner/Demons/Makara.dmi'
	_dd171.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Makara128.dmi'
	_dd171.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Makara32.dmi'
	db["Makara"] = _dd171

	// Nozuchi (Snake, Lv 23)
	var/datum/demon_data/_dd172 = new /datum/demon_data()
	_dd172.demon_name = "Nozuchi"
	_dd172.demon_race = "Snake"
	_dd172.demon_lvl = 23
	_dd172.demon_str = 13
	_dd172.demon_for = 7
	_dd172.demon_end = 14
	_dd172.demon_spd = 5
	_dd172.demon_off = 7
	_dd172.demon_def = 7
	_dd172.demon_skills = list("Nigayomogi")
	_dd172.demon_skill_learn = list("Assassinate" = 37, "Desperation" = 38, "Mow Down" = 39)
	_dd172.demon_passive_learn = list("Grimoire" = 24, "Double Strike" = 35, "Paladin Soul" = 36)
	_dd172.demon_unique = FALSE
	_dd172.demon_icon = 'Icons/DevilSummoner/Demons/Nozuchi.dmi'
	_dd172.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nozuchi128.dmi'
	_dd172.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nozuchi32.dmi'
	db["Nozuchi"] = _dd172

	// Pendragon (Snake, Lv 30)
	var/datum/demon_data/_dd173 = new /datum/demon_data()
	_dd173.demon_name = "Pendragon"
	_dd173.demon_race = "Snake"
	_dd173.demon_lvl = 30
	_dd173.demon_str = 22
	_dd173.demon_for = 7
	_dd173.demon_end = 11
	_dd173.demon_spd = 6
	_dd173.demon_off = 11
	_dd173.demon_def = 6
	_dd173.demon_skills = list("Fatal Strike")
	_dd173.demon_passives = list("Anti-Curse")
	_dd173.demon_skill_learn = list("Power Hit" = 39, "Taunt" = 40)
	_dd173.demon_passive_learn = list("Paladin Soul" = 31, "Counter" = 37, "Life Aid" = 38)
	_dd173.demon_unique = FALSE
	_dd173.demon_icon = 'Icons/DevilSummoner/Demons/Pendragon.dmi'
	_dd173.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pendragon128.dmi'
	_dd173.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pendragon32.dmi'
	db["Pendragon"] = _dd173

	// Gui Xian (Snake, Lv 38)
	var/datum/demon_data/_dd174 = new /datum/demon_data()
	_dd174.demon_name = "Gui Xian"
	_dd174.demon_race = "Snake"
	_dd174.demon_lvl = 38
	_dd174.demon_str = 12
	_dd174.demon_for = 14
	_dd174.demon_end = 22
	_dd174.demon_spd = 6
	_dd174.demon_off = 6
	_dd174.demon_def = 11
	_dd174.demon_skills = list("Power Charge")
	_dd174.demon_skill_learn = list("Mighty Hit" = 46)
	_dd174.demon_passive_learn = list("Preserve Extra" = 39, "Anti-Phys" = 43, "Life Surge" = 44, "Null Elec" = 45)
	_dd174.demon_unique = FALSE
	_dd174.demon_icon = 'Icons/DevilSummoner/Demons/Gui Xian.dmi'
	_dd174.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Gui Xian128.dmi'
	_dd174.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Gui Xian32.dmi'
	db["Gui Xian"] = _dd174

	// Quetzalcoatl (Snake, Lv 44)
	var/datum/demon_data/_dd175 = new /datum/demon_data()
	_dd175.demon_name = "Quetzalcoatl"
	_dd175.demon_race = "Snake"
	_dd175.demon_lvl = 44
	_dd175.demon_str = 16
	_dd175.demon_for = 10
	_dd175.demon_end = 27
	_dd175.demon_spd = 7
	_dd175.demon_off = 8
	_dd175.demon_def = 14
	_dd175.demon_skills = list("Mabufu")
	_dd175.demon_passives = list("+Stone")
	_dd175.demon_passive_learn = list("Life Aid" = 45)
	_dd175.demon_unique = FALSE
	_dd175.demon_icon = 'Icons/DevilSummoner/Demons/Quetzalcoatl.dmi'
	_dd175.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Quetzalcoatl128.dmi'
	_dd175.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Quetzalcoatl32.dmi'
	db["Quetzalcoatl"] = _dd175

	// Seiryuu (Snake, Lv 51)
	var/datum/demon_data/_dd176 = new /datum/demon_data()
	_dd176.demon_name = "Seiryuu"
	_dd176.demon_race = "Snake"
	_dd176.demon_lvl = 51
	_dd176.demon_str = 21
	_dd176.demon_for = 13
	_dd176.demon_end = 15
	_dd176.demon_spd = 18
	_dd176.demon_off = 11
	_dd176.demon_def = 8
	_dd176.demon_skills = list("Maziodyne")
	_dd176.demon_skill_learn = list("Deathbound" = 62, "Hassohappa" = 63)
	_dd176.demon_passive_learn = list("Elec Repel" = 53, "Double Strike" = 59, "Elec Amp" = 60, "Life Aid" = 61)
	_dd176.demon_unique = FALSE
	_dd176.demon_icon = 'Icons/DevilSummoner/Demons/Seiryuu.dmi'
	_dd176.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Seiryuu128.dmi'
	_dd176.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Seiryuu32.dmi'
	db["Seiryuu"] = _dd176

	// Gucumatz (Snake, Lv 58)
	var/datum/demon_data/_dd177 = new /datum/demon_data()
	_dd177.demon_name = "Gucumatz"
	_dd177.demon_race = "Snake"
	_dd177.demon_lvl = 58
	_dd177.demon_str = 20
	_dd177.demon_for = 13
	_dd177.demon_end = 22
	_dd177.demon_spd = 19
	_dd177.demon_off = 10
	_dd177.demon_def = 11
	_dd177.demon_skills = list("Shield All")
	_dd177.demon_passive_learn = list("Force Repel" = 59)
	_dd177.demon_unique = FALSE
	_dd177.demon_icon = 'Icons/DevilSummoner/Demons/Gucumatz.dmi'
	_dd177.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Gucumatz128.dmi'
	_dd177.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Gucumatz32.dmi'
	db["Gucumatz"] = _dd177

	// Orochi (Snake, Lv 66)
	var/datum/demon_data/_dd178 = new /datum/demon_data()
	_dd178.demon_name = "Orochi"
	_dd178.demon_race = "Snake"
	_dd178.demon_lvl = 66
	_dd178.demon_str = 30
	_dd178.demon_for = 13
	_dd178.demon_end = 26
	_dd178.demon_spd = 13
	_dd178.demon_off = 15
	_dd178.demon_def = 13
	_dd178.demon_skills = list("Hassohappa")
	_dd178.demon_passives = list("Fire Drain")
	_dd178.demon_skill_learn = list("Multi-Strike" = 76)
	_dd178.demon_passive_learn = list("Avenge" = 67, "Crit Up" = 74, "Ice Drain" = 75)
	_dd178.demon_unique = FALSE
	_dd178.demon_icon = 'Icons/DevilSummoner/Demons/Orochi.dmi'
	_dd178.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Orochi128.dmi'
	_dd178.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Orochi32.dmi'
	db["Orochi"] = _dd178

	// Ananta (Snake, Lv 72)
	var/datum/demon_data/_dd179 = new /datum/demon_data()
	_dd179.demon_name = "Ananta"
	_dd179.demon_race = "Snake"
	_dd179.demon_lvl = 72
	_dd179.demon_str = 31
	_dd179.demon_for = 18
	_dd179.demon_end = 26
	_dd179.demon_spd = 13
	_dd179.demon_off = 16
	_dd179.demon_def = 13
	_dd179.demon_skills = list("Makarakarn")
	_dd179.demon_passive_learn = list("Attack All" = 73)
	_dd179.demon_unique = FALSE
	_dd179.demon_icon = 'Icons/DevilSummoner/Demons/Ananta.dmi'
	_dd179.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ananta128.dmi'
	_dd179.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ananta32.dmi'
	db["Ananta"] = _dd179

	// Hoyau Kamui (Snake, Lv 80)
	var/datum/demon_data/_dd180 = new /datum/demon_data()
	_dd180.demon_name = "Hoyau Kamui"
	_dd180.demon_race = "Snake"
	_dd180.demon_lvl = 80
	_dd180.demon_str = 29
	_dd180.demon_for = 19
	_dd180.demon_end = 26
	_dd180.demon_spd = 22
	_dd180.demon_off = 15
	_dd180.demon_def = 13
	_dd180.demon_skills = list("None")
	_dd180.demon_passives = list("Life Stream")
	_dd180.demon_unique = TRUE
	_dd180.demon_icon = 'Icons/DevilSummoner/Demons/Hoyau Kamui.dmi'
	_dd180.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hoyau Kamui128.dmi'
	_dd180.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hoyau Kamui32.dmi'
	db["Hoyau Kamui"] = _dd180

	// Kobold (Touki, Lv 3)
	var/datum/demon_data/_dd181 = new /datum/demon_data()
	_dd181.demon_name = "Kobold"
	_dd181.demon_race = "Touki"
	_dd181.demon_lvl = 3
	_dd181.demon_str = 4
	_dd181.demon_for = 3
	_dd181.demon_end = 5
	_dd181.demon_spd = 7
	_dd181.demon_off = 2
	_dd181.demon_def = 3
	_dd181.demon_skills = list("Snipe")
	_dd181.demon_skill_learn = list("Anger Hit" = 27, "Fatal Strike" = 28)
	_dd181.demon_passive_learn = list("Hero Aid" = 4, "Life Bonus" = 25, "Phys Up" = 26)
	_dd181.demon_unique = FALSE
	_dd181.demon_icon = 'Icons/DevilSummoner/Demons/Kobold.dmi'
	_dd181.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Kobold128.dmi'
	_dd181.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Kobold32.dmi'
	db["Kobold"] = _dd181

	// Bilwis (Touki, Lv 10)
	var/datum/demon_data/_dd182 = new /datum/demon_data()
	_dd182.demon_name = "Bilwis"
	_dd182.demon_race = "Touki"
	_dd182.demon_lvl = 10
	_dd182.demon_str = 8
	_dd182.demon_for = 4
	_dd182.demon_end = 7
	_dd182.demon_spd = 7
	_dd182.demon_off = 4
	_dd182.demon_def = 4
	_dd182.demon_skills = list("Fatal Strike")
	_dd182.demon_passives = list("Hero Aid")
	_dd182.demon_skill_learn = list("Multi-Hit" = 28)
	_dd182.demon_passive_learn = list("Race-D" = 12, "Double Strike" = 27)
	_dd182.demon_unique = FALSE
	_dd182.demon_icon = 'Icons/DevilSummoner/Demons/Bilwis.dmi'
	_dd182.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Bilwis128.dmi'
	_dd182.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Bilwis32.dmi'
	db["Bilwis"] = _dd182

	// Gozuki (Touki, Lv 18)
	var/datum/demon_data/_dd183 = new /datum/demon_data()
	_dd183.demon_name = "Gozuki"
	_dd183.demon_race = "Touki"
	_dd183.demon_lvl = 18
	_dd183.demon_str = 13
	_dd183.demon_for = 4
	_dd183.demon_end = 11
	_dd183.demon_spd = 6
	_dd183.demon_off = 7
	_dd183.demon_def = 6
	_dd183.demon_skills = list("Berserk")
	_dd183.demon_passives = list("Race-O")
	_dd183.demon_skill_learn = list("Power Hit" = 32)
	_dd183.demon_passive_learn = list("Phys Up" = 29, "Race-D" = 30, "Retaliate" = 31)
	_dd183.demon_unique = FALSE
	_dd183.demon_icon = 'Icons/DevilSummoner/Demons/Gozuki.dmi'
	_dd183.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Gozuki128.dmi'
	_dd183.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Gozuki32.dmi'
	db["Gozuki"] = _dd183

	// Mezuki (Touki, Lv 25)
	var/datum/demon_data/_dd184 = new /datum/demon_data()
	_dd184.demon_name = "Mezuki"
	_dd184.demon_race = "Touki"
	_dd184.demon_lvl = 25
	_dd184.demon_str = 11
	_dd184.demon_for = 12
	_dd184.demon_end = 9
	_dd184.demon_spd = 9
	_dd184.demon_off = 6
	_dd184.demon_def = 5
	_dd184.demon_skills = list("Mazio")
	_dd184.demon_passives = list("Race-O")
	_dd184.demon_skill_learn = list("Multi-Hit" = 31, "Weak Kill" = 32)
	_dd184.demon_passive_learn = list("Elec Boost" = 27)
	_dd184.demon_unique = FALSE
	_dd184.demon_icon = 'Icons/DevilSummoner/Demons/Mezuki.dmi'
	_dd184.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mezuki128.dmi'
	_dd184.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mezuki32.dmi'
	db["Mezuki"] = _dd184

	// Ikusa (Touki, Lv 33)
	var/datum/demon_data/_dd185 = new /datum/demon_data()
	_dd185.demon_name = "Ikusa"
	_dd185.demon_race = "Touki"
	_dd185.demon_lvl = 33
	_dd185.demon_str = 17
	_dd185.demon_for = 12
	_dd185.demon_end = 11
	_dd185.demon_spd = 9
	_dd185.demon_off = 9
	_dd185.demon_def = 6
	_dd185.demon_skills = list("Assassinate")
	_dd185.demon_passives = list("+Stone")
	_dd185.demon_skill_learn = list("Ice Dance" = 36, "Power Charge" = 37)
	_dd185.demon_passive_learn = list("Ares Aid" = 34, "Retaliate" = 35)
	_dd185.demon_unique = FALSE
	_dd185.demon_icon = 'Icons/DevilSummoner/Demons/Ikusa.dmi'
	_dd185.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ikusa128.dmi'
	_dd185.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ikusa32.dmi'
	db["Ikusa"] = _dd185

	// Berserker (Touki, Lv 38)
	var/datum/demon_data/_dd186 = new /datum/demon_data()
	_dd186.demon_name = "Berserker"
	_dd186.demon_race = "Touki"
	_dd186.demon_lvl = 38
	_dd186.demon_str = 25
	_dd186.demon_for = 5
	_dd186.demon_end = 15
	_dd186.demon_spd = 9
	_dd186.demon_off = 13
	_dd186.demon_def = 8
	_dd186.demon_skills = list("None")
	_dd186.demon_passives = list("Extra One")
	_dd186.demon_passive_learn = list("Endure" = 40)
	_dd186.demon_unique = TRUE
	_dd186.demon_icon = 'Icons/DevilSummoner/Demons/Berserker.dmi'
	_dd186.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Berserker128.dmi'
	_dd186.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Berserker32.dmi'
	db["Berserker"] = _dd186

	// Lham Dearg (Touki, Lv 43)
	var/datum/demon_data/_dd187 = new /datum/demon_data()
	_dd187.demon_name = "Lham Dearg"
	_dd187.demon_race = "Touki"
	_dd187.demon_lvl = 43
	_dd187.demon_str = 21
	_dd187.demon_for = 9
	_dd187.demon_end = 18
	_dd187.demon_spd = 11
	_dd187.demon_off = 11
	_dd187.demon_def = 9
	_dd187.demon_skills = list("Mighty Hit")
	_dd187.demon_passive_learn = list("Endure" = 45, "Life Stream" = 44, "Pierce" = 51)
	_dd187.demon_unique = FALSE
	_dd187.demon_icon = 'Icons/DevilSummoner/Demons/Lham Dearg.dmi'
	_dd187.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lham Dearg128.dmi'
	_dd187.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lham Dearg32.dmi'
	db["Lham Dearg"] = _dd187

	// Yaksa (Touki, Lv 51)
	var/datum/demon_data/_dd188 = new /datum/demon_data()
	_dd188.demon_name = "Yaksa"
	_dd188.demon_race = "Touki"
	_dd188.demon_lvl = 51
	_dd188.demon_str = 24
	_dd188.demon_for = 11
	_dd188.demon_end = 14
	_dd188.demon_spd = 18
	_dd188.demon_off = 12
	_dd188.demon_def = 7
	_dd188.demon_skills = list("Diarahan")
	_dd188.demon_skill_learn = list("Deathbound" = 52)
	_dd188.demon_passive_learn = list("Fire Repel" = 53, "Ares Aid" = 59, "Phys Amp" = 60)
	_dd188.demon_unique = FALSE
	_dd188.demon_icon = 'Icons/DevilSummoner/Demons/Yaksa.dmi'
	_dd188.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Yaksa128.dmi'
	_dd188.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Yaksa32.dmi'
	db["Yaksa"] = _dd188

	// Nata Taishi (Touki, Lv 59)
	var/datum/demon_data/_dd189 = new /datum/demon_data()
	_dd189.demon_name = "Nata Taishi"
	_dd189.demon_race = "Touki"
	_dd189.demon_lvl = 59
	_dd189.demon_str = 22
	_dd189.demon_for = 16
	_dd189.demon_end = 17
	_dd189.demon_spd = 20
	_dd189.demon_off = 11
	_dd189.demon_def = 9
	_dd189.demon_skills = list("Deathbound")
	_dd189.demon_passives = list("Fire Repel")
	_dd189.demon_unique = TRUE
	_dd189.demon_icon = 'Icons/DevilSummoner/Demons/Nata Taishi.dmi'
	_dd189.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nata Taishi128.dmi'
	_dd189.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nata Taishi32.dmi'
	db["Nata Taishi"] = _dd189

	// Oumitsunu (Touki, Lv 67)
	var/datum/demon_data/_dd190 = new /datum/demon_data()
	_dd190.demon_name = "Oumitsunu"
	_dd190.demon_race = "Touki"
	_dd190.demon_lvl = 67
	_dd190.demon_str = 32
	_dd190.demon_for = 6
	_dd190.demon_end = 29
	_dd190.demon_spd = 16
	_dd190.demon_off = 16
	_dd190.demon_def = 15
	_dd190.demon_skills = list("None")
	_dd190.demon_passives = list("Life Lift")
	_dd190.demon_unique = TRUE
	_dd190.demon_icon = 'Icons/DevilSummoner/Demons/Oumitsunu.dmi'
	_dd190.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Oumitsunu128.dmi'
	_dd190.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Oumitsunu32.dmi'
	db["Oumitsunu"] = _dd190

	// King Frost (Tyrant, Lv 26)
	var/datum/demon_data/_dd191 = new /datum/demon_data()
	_dd191.demon_name = "King Frost"
	_dd191.demon_race = "Tyrant"
	_dd191.demon_lvl = 26
	_dd191.demon_str = 14
	_dd191.demon_for = 11
	_dd191.demon_end = 10
	_dd191.demon_spd = 7
	_dd191.demon_off = 7
	_dd191.demon_def = 5
	_dd191.demon_skills = list("Mabufu")
	_dd191.demon_passive_learn = list("Ice Boost" = 28)
	_dd191.demon_unique = TRUE
	_dd191.demon_icon = 'Icons/DevilSummoner/Demons/King Frost.dmi'
	_dd191.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/King Frost128.dmi'
	_dd191.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/King Frost32.dmi'
	db["King Frost"] = _dd191

	// Moloch (Tyrant, Lv 33)
	var/datum/demon_data/_dd192 = new /datum/demon_data()
	_dd192.demon_name = "Moloch"
	_dd192.demon_race = "Tyrant"
	_dd192.demon_lvl = 33
	_dd192.demon_str = 19
	_dd192.demon_for = 12
	_dd192.demon_end = 10
	_dd192.demon_spd = 8
	_dd192.demon_off = 10
	_dd192.demon_def = 5
	_dd192.demon_skills = list("None")
	_dd192.demon_passives = list("Ares Aid")
	_dd192.demon_passive_learn = list("Null Fire" = 35)
	_dd192.demon_unique = TRUE
	_dd192.demon_icon = 'Icons/DevilSummoner/Demons/Moloch.dmi'
	_dd192.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Moloch128.dmi'
	_dd192.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Moloch32.dmi'
	db["Moloch"] = _dd192

	// Balor (Tyrant, Lv 40)
	var/datum/demon_data/_dd193 = new /datum/demon_data()
	_dd193.demon_name = "Balor"
	_dd193.demon_race = "Tyrant"
	_dd193.demon_lvl = 40
	_dd193.demon_str = 16
	_dd193.demon_for = 19
	_dd193.demon_end = 11
	_dd193.demon_spd = 10
	_dd193.demon_off = 8
	_dd193.demon_def = 6
	_dd193.demon_skills = list("Death Call")
	_dd193.demon_passives = list("Crit Up")
	_dd193.demon_passive_learn = list("Life Stream" = 41)
	_dd193.demon_unique = TRUE
	_dd193.demon_icon = 'Icons/DevilSummoner/Demons/Balor.dmi'
	_dd193.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Balor128.dmi'
	_dd193.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Balor32.dmi'
	db["Balor"] = _dd193

	// Hecate (Tyrant, Lv 47)
	var/datum/demon_data/_dd194 = new /datum/demon_data()
	_dd194.demon_name = "Hecate"
	_dd194.demon_race = "Tyrant"
	_dd194.demon_lvl = 47
	_dd194.demon_str = 15
	_dd194.demon_for = 24
	_dd194.demon_end = 12
	_dd194.demon_spd = 12
	_dd194.demon_off = 8
	_dd194.demon_def = 6
	_dd194.demon_skills = list("Diarahan")
	_dd194.demon_passives = list("Pierce")
	_dd194.demon_passive_learn = list("Anti-Most" = 49)
	_dd194.demon_unique = TRUE
	_dd194.demon_icon = 'Icons/DevilSummoner/Demons/Hecate.dmi'
	_dd194.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hecate128.dmi'
	_dd194.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hecate32.dmi'
	db["Hecate"] = _dd194

	// Tzitzimitl (Tyrant, Lv 54)
	var/datum/demon_data/_dd195 = new /datum/demon_data()
	_dd195.demon_name = "Tzitzimitl"
	_dd195.demon_race = "Tyrant"
	_dd195.demon_lvl = 54
	_dd195.demon_str = 20
	_dd195.demon_for = 25
	_dd195.demon_end = 15
	_dd195.demon_spd = 10
	_dd195.demon_off = 10
	_dd195.demon_def = 8
	_dd195.demon_skills = list("Maziodyne")
	_dd195.demon_unique = TRUE
	_dd195.demon_icon = 'Icons/DevilSummoner/Demons/Tzitzimitl.dmi'
	_dd195.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tzitzimitl128.dmi'
	_dd195.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tzitzimitl32.dmi'
	db["Tzitzimitl"] = _dd195

	// Loki (Tyrant, Lv 61)
	var/datum/demon_data/_dd196 = new /datum/demon_data()
	_dd196.demon_name = "Loki"
	_dd196.demon_race = "Tyrant"
	_dd196.demon_lvl = 61
	_dd196.demon_str = 17
	_dd196.demon_for = 23
	_dd196.demon_end = 22
	_dd196.demon_spd = 15
	_dd196.demon_off = 9
	_dd196.demon_def = 11
	_dd196.demon_skills = list("Megidolaon")
	_dd196.demon_passives = list("Anti-Most")
	_dd196.demon_unique = TRUE
	_dd196.demon_icon = 'Icons/DevilSummoner/Demons/Loki.dmi'
	_dd196.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Loki128.dmi'
	_dd196.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Loki32.dmi'
	db["Loki"] = _dd196

	// Mot (Tyrant, Lv 68)
	var/datum/demon_data/_dd197 = new /datum/demon_data()
	_dd197.demon_name = "Mot"
	_dd197.demon_race = "Tyrant"
	_dd197.demon_lvl = 68
	_dd197.demon_str = 20
	_dd197.demon_for = 31
	_dd197.demon_end = 25
	_dd197.demon_spd = 8
	_dd197.demon_off = 10
	_dd197.demon_def = 13
	_dd197.demon_skills = list("None")
	_dd197.demon_passives = list("Double Strike")
	_dd197.demon_passive_learn = list("Dual Shadow" = 69)
	_dd197.demon_unique = TRUE
	_dd197.demon_icon = 'Icons/DevilSummoner/Demons/Mot.dmi'
	_dd197.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mot128.dmi'
	_dd197.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mot32.dmi'
	db["Mot"] = _dd197

	// Astaroth (Tyrant, Lv 75)
	var/datum/demon_data/_dd198 = new /datum/demon_data()
	_dd198.demon_name = "Astaroth"
	_dd198.demon_race = "Tyrant"
	_dd198.demon_lvl = 75
	_dd198.demon_str = 32
	_dd198.demon_for = 25
	_dd198.demon_end = 15
	_dd198.demon_spd = 19
	_dd198.demon_off = 16
	_dd198.demon_def = 8
	_dd198.demon_skills = list("Deathbound")
	_dd198.demon_passive_learn = list("Anti-All" = 76)
	_dd198.demon_unique = TRUE
	_dd198.demon_icon = 'Icons/DevilSummoner/Demons/Astaroth.dmi'
	_dd198.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Astaroth128.dmi'
	_dd198.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Astaroth32.dmi'
	db["Astaroth"] = _dd198

	// Nergal (Tyrant, Lv 81)
	var/datum/demon_data/_dd199 = new /datum/demon_data()
	_dd199.demon_name = "Nergal"
	_dd199.demon_race = "Tyrant"
	_dd199.demon_lvl = 81
	_dd199.demon_str = 26
	_dd199.demon_for = 28
	_dd199.demon_end = 20
	_dd199.demon_spd = 23
	_dd199.demon_off = 13
	_dd199.demon_def = 10
	_dd199.demon_skills = list("None")
	_dd199.demon_passives = list("Anti-All")
	_dd199.demon_unique = TRUE
	_dd199.demon_icon = 'Icons/DevilSummoner/Demons/Nergal.dmi'
	_dd199.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nergal128.dmi'
	_dd199.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nergal32.dmi'
	db["Nergal"] = _dd199

	// Belial (Tyrant, Lv 86)
	var/datum/demon_data/_dd200 = new /datum/demon_data()
	_dd200.demon_name = "Belial"
	_dd200.demon_race = "Tyrant"
	_dd200.demon_lvl = 86
	_dd200.demon_str = 30
	_dd200.demon_for = 24
	_dd200.demon_end = 29
	_dd200.demon_spd = 19
	_dd200.demon_off = 15
	_dd200.demon_def = 15
	_dd200.demon_skills = list("None")
	_dd200.demon_unique = TRUE
	_dd200.demon_icon = 'Icons/DevilSummoner/Demons/Belial.dmi'
	_dd200.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Belial128.dmi'
	_dd200.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Belial32.dmi'
	db["Belial"] = _dd200

	// Beelzebub (Tyrant, Lv 91)
	var/datum/demon_data/_dd201 = new /datum/demon_data()
	_dd201.demon_name = "Beelzebub"
	_dd201.demon_race = "Tyrant"
	_dd201.demon_lvl = 91
	_dd201.demon_str = 33
	_dd201.demon_for = 26
	_dd201.demon_end = 22
	_dd201.demon_spd = 26
	_dd201.demon_off = 17
	_dd201.demon_def = 11
	_dd201.demon_skills = list("None")
	_dd201.demon_passives = list("Phys Drain")
	_dd201.demon_unique = TRUE
	_dd201.demon_icon = 'Icons/DevilSummoner/Demons/Beelzebub.dmi'
	_dd201.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Beelzebub128.dmi'
	_dd201.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Beelzebub32.dmi'
	db["Beelzebub"] = _dd201

	// Lucifer (Tyrant, Lv 99)
	var/datum/demon_data/_dd202 = new /datum/demon_data()
	_dd202.demon_name = "Lucifer"
	_dd202.demon_race = "Tyrant"
	_dd202.demon_lvl = 99
	_dd202.demon_str = 29
	_dd202.demon_for = 30
	_dd202.demon_end = 28
	_dd202.demon_spd = 28
	_dd202.demon_off = 15
	_dd202.demon_def = 14
	_dd202.demon_skills = list("Root of Evil")
	_dd202.demon_unique = TRUE
	_dd202.demon_icon = 'Icons/DevilSummoner/Demons/Lucifer.dmi'
	_dd202.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Lucifer128.dmi'
	_dd202.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Lucifer32.dmi'
	db["Lucifer"] = _dd202

	// Orcus (Vile, Lv 23)
	var/datum/demon_data/_dd203 = new /datum/demon_data()
	_dd203.demon_name = "Orcus"
	_dd203.demon_race = "Vile"
	_dd203.demon_lvl = 23
	_dd203.demon_str = 18
	_dd203.demon_for = 3
	_dd203.demon_end = 12
	_dd203.demon_spd = 6
	_dd203.demon_off = 9
	_dd203.demon_def = 6
	_dd203.demon_skills = list("Brutal Hit")
	_dd203.demon_unique = FALSE
	_dd203.demon_icon = 'Icons/DevilSummoner/Demons/Orcus.dmi'
	_dd203.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Orcus128.dmi'
	_dd203.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Orcus32.dmi'
	db["Orcus"] = _dd203

	// Baphomet (Vile, Lv 32)
	var/datum/demon_data/_dd204 = new /datum/demon_data()
	_dd204.demon_name = "Baphomet"
	_dd204.demon_race = "Vile"
	_dd204.demon_lvl = 32
	_dd204.demon_str = 9
	_dd204.demon_for = 18
	_dd204.demon_end = 9
	_dd204.demon_spd = 12
	_dd204.demon_off = 5
	_dd204.demon_def = 5
	_dd204.demon_skills = list("Maragi")
	_dd204.demon_skill_learn = list("Drain" = 33)
	_dd204.demon_unique = FALSE
	_dd204.demon_icon = 'Icons/DevilSummoner/Demons/Baphomet.dmi'
	_dd204.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Baphomet128.dmi'
	_dd204.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Baphomet32.dmi'
	db["Baphomet"] = _dd204

	// Pazuzu (Vile, Lv 40)
	var/datum/demon_data/_dd205 = new /datum/demon_data()
	_dd205.demon_name = "Pazuzu"
	_dd205.demon_race = "Vile"
	_dd205.demon_lvl = 40
	_dd205.demon_str = 13
	_dd205.demon_for = 17
	_dd205.demon_end = 17
	_dd205.demon_spd = 9
	_dd205.demon_off = 7
	_dd205.demon_def = 9
	_dd205.demon_skills = list("Holy Dance")
	_dd205.demon_passives = list("Null Force")
	_dd205.demon_unique = TRUE
	_dd205.demon_icon = 'Icons/DevilSummoner/Demons/Pazuzu.dmi'
	_dd205.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Pazuzu128.dmi'
	_dd205.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Pazuzu32.dmi'
	db["Pazuzu"] = _dd205

	// Abaddon (Vile, Lv 48)
	var/datum/demon_data/_dd206 = new /datum/demon_data()
	_dd206.demon_name = "Abaddon"
	_dd206.demon_race = "Vile"
	_dd206.demon_lvl = 48
	_dd206.demon_str = 17
	_dd206.demon_for = 18
	_dd206.demon_end = 17
	_dd206.demon_spd = 12
	_dd206.demon_off = 9
	_dd206.demon_def = 9
	_dd206.demon_skills = list("Bufudyne")
	_dd206.demon_passive_learn = list("Anti-Most" = 50, "Null Ice" = 49)
	_dd206.demon_unique = FALSE
	_dd206.demon_icon = 'Icons/DevilSummoner/Demons/Abaddon.dmi'
	_dd206.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Abaddon128.dmi'
	_dd206.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Abaddon32.dmi'
	db["Abaddon"] = _dd206

	// Arioch (Vile, Lv 56)
	var/datum/demon_data/_dd207 = new /datum/demon_data()
	_dd207.demon_name = "Arioch"
	_dd207.demon_race = "Vile"
	_dd207.demon_lvl = 56
	_dd207.demon_str = 24
	_dd207.demon_for = 14
	_dd207.demon_end = 18
	_dd207.demon_spd = 16
	_dd207.demon_off = 12
	_dd207.demon_def = 9
	_dd207.demon_skills = list("Deathbound")
	_dd207.demon_skill_learn = list("Tetrakarn" = 57)
	_dd207.demon_unique = TRUE
	_dd207.demon_icon = 'Icons/DevilSummoner/Demons/Arioch.dmi'
	_dd207.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Arioch128.dmi'
	_dd207.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Arioch32.dmi'
	db["Arioch"] = _dd207

	// Tao Tie (Vile, Lv 62)
	var/datum/demon_data/_dd208 = new /datum/demon_data()
	_dd208.demon_name = "Tao Tie"
	_dd208.demon_race = "Vile"
	_dd208.demon_lvl = 62
	_dd208.demon_str = 20
	_dd208.demon_for = 27
	_dd208.demon_end = 16
	_dd208.demon_spd = 15
	_dd208.demon_off = 10
	_dd208.demon_def = 8
	_dd208.demon_skills = list("Megidolaon")
	_dd208.demon_unique = TRUE
	_dd208.demon_icon = 'Icons/DevilSummoner/Demons/Tao Tie.dmi'
	_dd208.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tao Tie128.dmi'
	_dd208.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tao Tie32.dmi'
	db["Tao Tie"] = _dd208

	// Tezcatlipoca (Vile, Lv 68)
	var/datum/demon_data/_dd209 = new /datum/demon_data()
	_dd209.demon_name = "Tezcatlipoca"
	_dd209.demon_race = "Vile"
	_dd209.demon_lvl = 68
	_dd209.demon_str = 26
	_dd209.demon_for = 25
	_dd209.demon_end = 19
	_dd209.demon_spd = 14
	_dd209.demon_off = 13
	_dd209.demon_def = 10
	_dd209.demon_skills = list("Gigajama")
	_dd209.demon_passives = list("Attack All")
	_dd209.demon_unique = TRUE
	_dd209.demon_icon = 'Icons/DevilSummoner/Demons/Tezcatlipoca.dmi'
	_dd209.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Tezcatlipoca128.dmi'
	_dd209.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Tezcatlipoca32.dmi'
	db["Tezcatlipoca"] = _dd209

	// Nyarlathotep (Vile, Lv 80)
	var/datum/demon_data/_dd210 = new /datum/demon_data()
	_dd210.demon_name = "Nyarlathotep"
	_dd210.demon_race = "Vile"
	_dd210.demon_lvl = 80
	_dd210.demon_str = 30
	_dd210.demon_for = 22
	_dd210.demon_end = 19
	_dd210.demon_spd = 25
	_dd210.demon_off = 15
	_dd210.demon_def = 10
	_dd210.demon_skills = list("None")
	_dd210.demon_passives = list("Mana Aid")
	_dd210.demon_unique = TRUE
	_dd210.demon_icon = 'Icons/DevilSummoner/Demons/Nyarlathotep.dmi'
	_dd210.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Nyarlathotep128.dmi'
	_dd210.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Nyarlathotep32.dmi'
	db["Nyarlathotep"] = _dd210

	// Hare of Inaba (Wilder, Lv 9)
	var/datum/demon_data/_dd211 = new /datum/demon_data()
	_dd211.demon_name = "Hare of Inaba"
	_dd211.demon_race = "Wilder"
	_dd211.demon_lvl = 9
	_dd211.demon_str = 5
	_dd211.demon_for = 6
	_dd211.demon_end = 5
	_dd211.demon_spd = 9
	_dd211.demon_off = 3
	_dd211.demon_def = 3
	_dd211.demon_skills = list("Dia")
	_dd211.demon_passives = list("Extra Bonus")
	_dd211.demon_skill_learn = list("Amrita" = 10)
	_dd211.demon_passive_learn = list("+Poison" = 35, "Life Bonus" = 36, "Mana Bonus" = 37)
	_dd211.demon_unique = FALSE
	_dd211.demon_icon = 'Icons/DevilSummoner/Demons/Hare of Inaba.dmi'
	_dd211.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Hare of Inaba128.dmi'
	_dd211.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Hare of Inaba32.dmi'
	db["Hare of Inaba"] = _dd211

	// Waira (Wilder, Lv 17)
	var/datum/demon_data/_dd212 = new /datum/demon_data()
	_dd212.demon_name = "Waira"
	_dd212.demon_race = "Wilder"
	_dd212.demon_lvl = 17
	_dd212.demon_str = 9
	_dd212.demon_for = 10
	_dd212.demon_end = 6
	_dd212.demon_spd = 8
	_dd212.demon_off = 5
	_dd212.demon_def = 3
	_dd212.demon_skills = list("Force Dance")
	_dd212.demon_passives = list("Phys Up")
	_dd212.demon_skill_learn = list("Berserk" = 38, "Mow Down" = 39)
	_dd212.demon_passive_learn = list("Life Bonus" = 18, "Quick Move" = 37)
	_dd212.demon_unique = FALSE
	_dd212.demon_icon = 'Icons/DevilSummoner/Demons/Waira.dmi'
	_dd212.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Waira128.dmi'
	_dd212.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Waira32.dmi'
	db["Waira"] = _dd212

	// Garm (Wilder, Lv 25)
	var/datum/demon_data/_dd213 = new /datum/demon_data()
	_dd213.demon_name = "Garm"
	_dd213.demon_race = "Wilder"
	_dd213.demon_lvl = 25
	_dd213.demon_str = 15
	_dd213.demon_for = 5
	_dd213.demon_end = 10
	_dd213.demon_spd = 11
	_dd213.demon_off = 8
	_dd213.demon_def = 5
	_dd213.demon_skills = list("Berserk")
	_dd213.demon_passives = list("Life Surge")
	_dd213.demon_skill_learn = list("Fatal Strike" = 41, "Fire Dance" = 42, "Mow Down" = 43)
	_dd213.demon_passive_learn = list("Counter" = 27, "+Forget" = 39, "Retaliate" = 40)
	_dd213.demon_unique = FALSE
	_dd213.demon_icon = 'Icons/DevilSummoner/Demons/Garm.dmi'
	_dd213.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Garm128.dmi'
	_dd213.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Garm32.dmi'
	db["Garm"] = _dd213

	// Afanc (Wilder, Lv 33)
	var/datum/demon_data/_dd214 = new /datum/demon_data()
	_dd214.demon_name = "Afanc"
	_dd214.demon_race = "Wilder"
	_dd214.demon_lvl = 33
	_dd214.demon_str = 13
	_dd214.demon_for = 8
	_dd214.demon_end = 14
	_dd214.demon_spd = 14
	_dd214.demon_off = 7
	_dd214.demon_def = 7
	_dd214.demon_skills = list("Mow Down")
	_dd214.demon_skill_learn = list("Mighty Hit" = 41, "Power Hit" = 42)
	_dd214.demon_passive_learn = list("Retaliate" = 34, "Phys Boost" = 35)
	_dd214.demon_unique = FALSE
	_dd214.demon_icon = 'Icons/DevilSummoner/Demons/Afanc.dmi'
	_dd214.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Afanc128.dmi'
	_dd214.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Afanc32.dmi'
	db["Afanc"] = _dd214

	// Xiezhai (Wilder, Lv 37)
	var/datum/demon_data/_dd215 = new /datum/demon_data()
	_dd215.demon_name = "Xiezhai"
	_dd215.demon_race = "Wilder"
	_dd215.demon_lvl = 37
	_dd215.demon_str = 7
	_dd215.demon_for = 22
	_dd215.demon_end = 11
	_dd215.demon_spd = 13
	_dd215.demon_off = 4
	_dd215.demon_def = 6
	_dd215.demon_skills = list("Nigayomogi")
	_dd215.demon_passives = list("Crit Up")
	_dd215.demon_passive_learn = list("Extra One" = 39)
	_dd215.demon_unique = TRUE
	_dd215.demon_icon = 'Icons/DevilSummoner/Demons/Xiezhai.dmi'
	_dd215.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Xiezhai128.dmi'
	_dd215.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Xiezhai32.dmi'
	db["Xiezhai"] = _dd215

	// Mothman (Wilder, Lv 43)
	var/datum/demon_data/_dd216 = new /datum/demon_data()
	_dd216.demon_name = "Mothman"
	_dd216.demon_race = "Wilder"
	_dd216.demon_lvl = 43
	_dd216.demon_str = 14
	_dd216.demon_for = 21
	_dd216.demon_end = 17
	_dd216.demon_spd = 7
	_dd216.demon_off = 7
	_dd216.demon_def = 9
	_dd216.demon_skills = list("Media")
	_dd216.demon_skill_learn = list("Mazan" = 46)
	_dd216.demon_passive_learn = list("Anti-Fire" = 44, "Swift Step" = 45, "Endure" = 47)
	_dd216.demon_unique = FALSE
	_dd216.demon_icon = 'Icons/DevilSummoner/Demons/Mothman.dmi'
	_dd216.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Mothman128.dmi'
	_dd216.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Mothman32.dmi'
	db["Mothman"] = _dd216

	// Taown (Wilder, Lv 50)
	var/datum/demon_data/_dd217 = new /datum/demon_data()
	_dd217.demon_name = "Taown"
	_dd217.demon_race = "Wilder"
	_dd217.demon_lvl = 50
	_dd217.demon_str = 22
	_dd217.demon_for = 17
	_dd217.demon_end = 11
	_dd217.demon_spd = 16
	_dd217.demon_off = 11
	_dd217.demon_def = 6
	_dd217.demon_skills = list("Diarahan")
	_dd217.demon_skill_learn = list("Gigajama" = 51, "Death Call" = 61)
	_dd217.demon_passive_learn = list("Force Repel" = 52, "Double Strike" = 58, "Grimoire" = 59, "Phys Amp" = 60)
	_dd217.demon_unique = FALSE
	_dd217.demon_icon = 'Icons/DevilSummoner/Demons/Taown.dmi'
	_dd217.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Taown128.dmi'
	_dd217.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Taown32.dmi'
	db["Taown"] = _dd217

	// Sleipnir (Wilder, Lv 57)
	var/datum/demon_data/_dd218 = new /datum/demon_data()
	_dd218.demon_name = "Sleipnir"
	_dd218.demon_race = "Wilder"
	_dd218.demon_lvl = 57
	_dd218.demon_str = 21
	_dd218.demon_for = 12
	_dd218.demon_end = 16
	_dd218.demon_spd = 24
	_dd218.demon_off = 11
	_dd218.demon_def = 8
	_dd218.demon_skills = list("None")
	_dd218.demon_passives = list("Ice Drain")
	_dd218.demon_passive_learn = list("Force Drain" = 59)
	_dd218.demon_unique = FALSE
	_dd218.demon_icon = 'Icons/DevilSummoner/Demons/Sleipnir.dmi'
	_dd218.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Sleipnir128.dmi'
	_dd218.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Sleipnir32.dmi'
	db["Sleipnir"] = _dd218

	// Behemoth (Wilder, Lv 65)
	var/datum/demon_data/_dd219 = new /datum/demon_data()
	_dd219.demon_name = "Behemoth"
	_dd219.demon_race = "Wilder"
	_dd219.demon_lvl = 65
	_dd219.demon_str = 33
	_dd219.demon_for = 10
	_dd219.demon_end = 29
	_dd219.demon_spd = 9
	_dd219.demon_off = 17
	_dd219.demon_def = 15
	_dd219.demon_skills = list("Deathbound")
	_dd219.demon_skill_learn = list("Mighty Hit" = 74, "Piercing Hit" = 75)
	_dd219.demon_passive_learn = list("Attack All" = 66, "Dual Shadow" = 73)
	_dd219.demon_unique = FALSE
	_dd219.demon_icon = 'Icons/DevilSummoner/Demons/Behemoth.dmi'
	_dd219.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Behemoth128.dmi'
	_dd219.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Behemoth32.dmi'
	db["Behemoth"] = _dd219

	// Ammut (Wilder, Lv 73)
	var/datum/demon_data/_dd220 = new /datum/demon_data()
	_dd220.demon_name = "Ammut"
	_dd220.demon_race = "Wilder"
	_dd220.demon_lvl = 73
	_dd220.demon_str = 32
	_dd220.demon_for = 16
	_dd220.demon_end = 26
	_dd220.demon_spd = 15
	_dd220.demon_off = 16
	_dd220.demon_def = 13
	_dd220.demon_skills = list("Deathbound")
	_dd220.demon_unique = TRUE
	_dd220.demon_icon = 'Icons/DevilSummoner/Demons/Ammut.dmi'
	_dd220.demon_portrait = 'Icons/DevilSummoner/DemonPortraits128/Ammut128.dmi'
	_dd220.demon_portrait2 = 'Icons/DevilSummoner/DemonPortraits32/Ammut32.dmi'
	db["Ammut"] = _dd220

	DEMON_DB = db
