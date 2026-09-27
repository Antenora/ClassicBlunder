datum/saga_skill_tree_node/Variable/SuperRobotWars
	Cyberize
		id = "cyberize"
		tree_id = "super_robot_wars"
		title = "Cyberization"
		description = "Increases CyberizeMod by 0.2 per rank."

		cost = 30
		rank_costs = list(30,50,70,90,110)
		max_rank = 5

		variable_name = "CyberizeMod"
		variable_amount = 0.2

		tree_x = 672-64
		tree_y = 500-64


datum/saga_skill_tree_node/Passive/SuperRobotWars
	WillLimit
		id = "will_limit"
		title = "Will Limit Break"
		description = "Each rank increases your maximum Will by 10."

		cost = 50
		max_rank = 7

		passive_name = "WillLimitBreak"
		passive_amount = 1

		tree_x = 672
		tree_y = 500