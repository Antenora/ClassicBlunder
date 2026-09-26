
//THIS IS AN EXAMPLE. THIS WILL BE TAKEN FOR SRW SAGA
/*

datum/saga_skill_tree/KingOfBraves
	id = "king_of_braves"
	title = "King of Braves"
	required_saga = "King of Braves"

	background_icon = 'HUD/SagaSkillTree/srw_background.dmi'
	background_state = "Background"

	accent_color = "#ffd966"
	node_learned_color = "#806321"
	line_learned_color = "#ffd966"
	button_color = "#69521e"

	font_file = 'HUD/PixelOperator8.ttf'
	font_size = 12
	node_font_size = 10
	title_font_size = 16


datum/saga_skill_tree_node/KingOfBraves
	tree_id = "king_of_braves"

	Focus
		id = "focus"
		title = "Focus"
		description = "Temporarily improves accuracy and evasion."
		skill_path = /obj/Skills/Buffs/SpiritCommands/Focus
		cost = 1
		tree_x = 522
		tree_y = 790

	Accel
		id = "accel"
		title = "Accel"
		description = "Temporarily increases speed."
		skill_path = /obj/Skills/Buffs/SpiritCommands/Accel
		cost = 1
		tree_x = 822
		tree_y = 790
		node_icon = 'HUD/SkillIcons.dmi'
		node_icon_state = "Kienzan"

datum/saga_skill_tree_node/RankedSkill/KingOfBravesFightingSpirit
	id = "fighting_spirit"
	tree_id = "king_of_braves"
	title = "Fighting Spirit"
	description = "Rank 1 unlocks Valor. Rank 2 unlocks Soul."

	rank_skills = list(
		/obj/Skills/Buffs/SpiritCommands/Instant/Valor,
		/obj/Skills/Buffs/SpiritCommands/Instant/Soul
	)

	rank_costs = list(100, 200)

	requires = list("focus")
	required_saga_level = 3
	tree_x = 522
	tree_y = 550


datum/saga_skill_tree_node/Passive/KingOfBravesWillLimit
	id = "will_limit"
	tree_id = "king_of_braves"
	title = "Will Limit Break"
	description = "Each rank increases your maximum Will by 10."

	cost = 50
	max_rank = 7

	passive_name = "WillLimitBreak"
	passive_amount = 1

	requires = list("focus")
	required_saga_level = 3
	tree_x = 822
	tree_y = 550

datum/saga_skill_tree_node/Passive/KingOfBravesColorofCourage
	id = "color_of_courage"
	tree_id = "king_of_braves"
	title = "Color of Courage"
	description = "For every tick of this passive, you can survive past an extra 10% of HP into the Negatives."

	cost = 100
	max_rank = 5

	passive_name = "Color of Courage"
	passive_amount = 1

	requires = list("fighting_spirit")
	required_saga_level = 5
	tree_x = 522
	tree_y = -100

	VisibilityCondition(mob/M)
		if(!..()) return FALSE
		return M.WillUnlocked && M.SagaLevel >= 6

*/