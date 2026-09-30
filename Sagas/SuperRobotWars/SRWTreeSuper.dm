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

	RocketPunchMastery
		id= "rocketpunch_mastery"
		title= "Rocket Punch Mastery"
		description= "Grant extra Rocket Punch skills with the instrisic Rocket Punch part."

		cost = 50
		max_rank = 2

		passive_name = "RocketPunchMastery"
		passive_amount = 1
		requires = list("photonic_fist")

		tree_x = 1122+128
		tree_y = 700

datum/saga_skill_tree_node/IntrinsicPart/SuperRobotWars
	tree_id = "super_robot_wars"

	PhotonicPowerEngine
		id = "photonic_power_engine"
		title = "Photonic Power Engine"
		description = "Grants Photonic Power Engine. Installing this as the Core for your mech grants 25% more heat capacity, +2 cooling per second, and 20% less heat from energy weaponry and skills."
		intrinsic_part_id = "photonic_power_engine"
		cost = 50
		required_saga_level = 1
		tree_x = 972
		tree_y = 700

	SpiralDrive
		id = "SpiralDrive"
		title = "Spiral Drive"
		description = "Grants a Core Drill. Installing this as the Core for your Mech increases the bonuses you get from Will for your base stats."
		intrinsic_part_id = "spiral_drive"
		cost = 50
		required_saga_level = 1
		tree_x = 972
		tree_y = 600

	RocketPunch
		id = "photonic_rocket_punch"
		tree_id = "super_robot_wars"
		title = "Photonic Rocket Punch"
		description = "Grants a Rocket Punch part."
		intrinsic_part_id = "photonic_rocket_punch"
		cost = 20
		required_saga_level = 1
		requires = list("photonic_power_engine")
		tree_x = 1122
		tree_y = 700
