datum/saga_skill_tree_node/SuperRobotWars
	Bravery
		id = "bravery"
		title = "Bravery"
		description = "Unlocks the King of Braves buff."
		skill_paths = list(
			/obj/Skills/Buffs/SpecialBuffs/King_of_Braves,
			/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave
		)
		cost = 1
		tree_x = 800
		tree_y = 600


datum/saga_skill_tree_node/Passive/SuperRobotWars

	ColorOfCourage
		id = "color_of_courage"
		title = "Color of Courage"
		description = "Each rank lets you survive an additional 10% HP into negative health."

		cost = 100
		max_rank = 5

		passive_name = "Color of Courage"
		passive_amount = 1

		requires = list("bravery")
		required_saga_level = 7
		tree_x = 800
		tree_y = 300

		/*VisibilityCondition(mob/M)
			if(!..()) return FALSE
			return M.WillUnlocked && M.SagaLevel >= 6*/
