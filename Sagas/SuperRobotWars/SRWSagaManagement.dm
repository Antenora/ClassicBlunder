mob/proc/gainSRW()
	src << "Be it a King of Braves, a Newtype, or even just a poor soul who fell right into the cockpit- It's now your time to shine."
	src << "You are now an <b>Ace Pilot</b>."
	src.Saga = "Super Robot Wars"
	src.SagaLevel = 1

	src.passive_handler.Increase("PilotingProwess", 1)
	src.CyberizeMod+=0.2
	src << "This Saga is evolved via the Saga Skill Tree. Find it in your Character Customization page."
	src.GrantWillMechanic()


/mob/tierUpSaga(path)
	..()
	if(path != "Super Robot Wars") return

	switch(SagaLevel)
		if(2)
			src << "saga level 2"
		if(3)
			src << "saga level 3"


#define SRWOFFSET 64

datum/saga_skill_tree/SuperRobotWars
	id = "super_robot_wars"
	title = "Super Robot Wars"
	required_saga = "Super Robot Wars"

	background_icon = 'HUD/SagaSkillTree/srw_background.dmi'
	background_state = "Background"
	background_color = "#00247e"

	accent_color = "#ffd966"
	node_learned_color = "#806321"
	line_learned_color = "#ffd966"
	button_color = "#69521e"

	font_file = 'HUD/PixelOperator8.ttf'
	font_size = 12
	node_font_size = 10
	title_font_size = 16


//NODE DEFINITION

// NORMAL SKILL NODES
datum/saga_skill_tree_node/SuperRobotWars
	tree_id = "super_robot_wars"

// RANKED SKILL NODES
datum/saga_skill_tree_node/RankedSkill/SuperRobotWars
	tree_id = "super_robot_wars"

// PASSIVE NODES
datum/saga_skill_tree_node/Passive/SuperRobotWars
	tree_id = "super_robot_wars"

// VARIABLE NODES
datum/saga_skill_tree_node/Variable/SuperRobotWars
	tree_id = "super_robot_wars"



// SPIRIT COMMANDS
datum/saga_skill_tree_node/SuperRobotWars
	Accel
		id = "accel"
		title = "Spirit Command: Accel"

		description = "Activate to multiply your SPD stat by 1.3 for 10 seconds."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Accel)
		cost = 20
		tree_x = 672
		tree_y = 680

	Flash
		id = "flash"
		title = "Spirit Command: Flash"

		description = "For two seconds following a hit, all attacks will be dodged."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Flash)
		cost = 20
		tree_x = 672
		tree_y = 680+SRWOFFSET*2
		required_saga_level = 4
		requires=list("accel")

	Focus
		id = "focus"
		title = "Spirit Command: Focus"

		description = "Activate to multiply your OFF and DEF stat by 1.3 for 10 seconds."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Focus)
		cost = 20
		tree_x = 672+SRWOFFSET*1
		tree_y = 680

	Bullseye
		id = "bullseye"
		title = "Spirit Command: Bullseye"

		description = "For ten seconds following landing a hit, all attacks will land."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Bullseye)
		cost = 20
		tree_x = 672+SRWOFFSET*1
		tree_y = 680+SRWOFFSET*2
		required_saga_level = 4
		requires=list("focus")

	Spirit
		id = "spirit"
		title = "Spirit Command: Spirit"

		description = "Immediately raise your Will by 10."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Spirit)
		cost = 20
		tree_x = 672-SRWOFFSET*1
		tree_y = 680

	Persist
		id = "persist"
		title = "Spirit Command: Persist"

		description = "For two seconds following a hit, all damage taken is reduced by 87.5%."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Persist)
		cost = 20
		tree_x = 672-SRWOFFSET*2
		tree_y = 680+SRWOFFSET*2
		required_saga_level = 3

	Drive
		id = "drive"
		title = "Spirit Command: Drive"

		description = "Immediately raise your Will by 30."
		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Drive)
		cost = 30
		requires= list("spirit")
		tree_x = 672-SRWOFFSET*1
		tree_y = 680+SRWOFFSET*3
		required_saga_level = 4

	Valor
		id = "valor"
		title = "Spirit Command: Valor"
		description = "Activate to multiply damage deal by two for two seconds."

		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Valor)

		cost = 50

		required_saga_level = 4
		tree_x = 672
		tree_y = 680+SRWOFFSET*3

	Soul
		id = "soul"
		title = "Spirit Command: Soul"
		description = "Activate to multiply damage deal by x2.2 for two seconds. Overrides Valor."

		skill_paths = list(/obj/Skills/Buffs/SpiritCommands/Instant/Soul,)

		cost = 50

		required_saga_level = 5
		requires=list("valor")
		tree_x = 672
		tree_y = 680+SRWOFFSET*4

#undef SRWOFFSET