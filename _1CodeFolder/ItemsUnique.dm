

//File for items that use unique properties that don't really fit in with tech, wizardy



obj/Items/DragonBall
	icon = 'Icons/Enchantment/Grimoire/Dragonballs.dmi'
	name = "Dragon Ball"
	Destructable=0
	ShatterTier=0
	LegendaryItem=0 //To keep them from being deleted i suppose
	Stealable=1
	Pickable=1
	var
		set_index = 1 //Which number of the set is the dragonball.
		set_id = "main" //Different sets will have different set ids. Keeps different sets as different sets
		set_total = 7 //How many dragon balls are in the set.

	//gayass defaults
	One/
		set_index = 1
		pixel_y=12
		set_id = "main"
		name = "One-Star Dragon Ball"
		icon_state="1"
	Two/
		set_index = 2
		pixel_x = 9
		pixel_y = 12
		set_id = "main"
		name = "Two-Star Dragon Ball"
		icon_state="2"
	Three/
		set_index = 3
		pixel_x = 5
		pixel_y = 4
		set_id = "main"
		name = "Three-Star Dragon Ball"
		icon_state="3"
	Four/
		set_index = 4
		pixel_x = -5
		pixel_y = 4
		set_id = "main"
		name = "Four-Star Dragon Ball"
		icon_state="4"
	Five/
		set_index = 5
		pixel_x = -9
		pixel_y = 12
		set_id = "main"
		name = "Five-Star Dragon Ball"
		icon_state="5"
	Six/
		set_index = 6
		pixel_x = -5
		pixel_y = 20
		set_id = "main"
		name = "Six-Star Dragon Ball"
		icon_state="6"
	Seven/
		set_index = 7
		pixel_x = 5
		pixel_y = 20
		set_id = "main"
		name = "Seven-Star Dragon Ball"
		icon_state="7"