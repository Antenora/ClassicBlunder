/datum/craft_recipe/lifecraft/cooking/bacon
	id = "bacon"
	label = "Bacon"
	tier = 1
	rank_req = 1
	fx_kind = "yield"
	fx_arg = "Mining"
	result_type = /obj/Items/Edibles/Dish/bacon
	slotspec = list(\
		list("Main", 2, "cat:Meat", 1),\
		list("Season", 1, "tag:herb", 1))

/datum/craft_recipe/lifecraft/cooking/meatballs
	id = "meatballs"
	label = "Meatballs"
	tier = 1
	rank_req = 1
	fx_kind = "yield"
	fx_arg = "Hunting"
	result_type = /obj/Items/Edibles/Dish/meatballs
	slotspec = list(\
		list("Main", 2, "cat:Meat", 1),\
		list("Side", 1, "cat:Crops", 1),\
		list("Season", 1, "tag:herb", 1))

/datum/craft_recipe/lifecraft/cooking/grilled_salmon
	id = "grilled_salmon"
	label = "Grilled Salmon"
	tier = 1
	rank_req = 1
	fx_kind = "yield"
	fx_arg = "Foraging"
	result_type = /obj/Items/Edibles/Dish/grilled_salmon
	slotspec = list(\
		list("Main", 2, "cat:Fish", 1),\
		list("Season", 1, "tag:herb", 1))

/datum/craft_recipe/lifecraft/cooking/jam
	id = "jam"
	label = "Jam"
	tier = 1
	rank_req = 1
	fx_kind = "yield"
	fx_arg = "Farming"
	result_type = /obj/Items/Edibles/Dish/jam
	slotspec = list(\
		list("Main", 3, "cat:Fruit", 1))

/datum/craft_recipe/lifecraft/cooking/french_fries
	id = "french_fries"
	label = "French Fries"
	tier = 2
	rank_req = 3
	fx_kind = "yield"
	fx_arg = "Mining"
	result_type = /obj/Items/Edibles/Dish/french_fries
	slotspec = list(\
		list("Main", 2, "tag:tuber", 2),\
		list("Season", 1, "tag:herb", 1))

/datum/craft_recipe/lifecraft/cooking/sushi
	id = "sushi"
	label = "Sushi"
	tier = 2
	rank_req = 3
	fx_kind = "yield"
	fx_arg = "Fishing"
	result_type = /obj/Items/Edibles/Dish/sushi
	slotspec = list(\
		list("Main", 2, "cat:Fish", 2),\
		list("Side", 1, "cat:Crops", 2))

/datum/craft_recipe/lifecraft/cooking/potato_chips
	id = "potato_chips"
	label = "Potato Chips"
	tier = 2
	rank_req = 3
	fx_kind = "yield"
	fx_arg = "Foraging"
	result_type = /obj/Items/Edibles/Dish/potato_chips
	slotspec = list(\
		list("Main", 3, "tag:tuber", 2))

/datum/craft_recipe/lifecraft/cooking/jelly
	id = "jelly"
	label = "Jelly"
	tier = 2
	rank_req = 3
	fx_kind = "yield"
	fx_arg = "Farming"
	result_type = /obj/Items/Edibles/Dish/jelly
	slotspec = list(\
		list("Main", 1, "mat:Gelatin", 1),\
		list("Side", 2, "cat:Fruit", 2))

/datum/craft_recipe/lifecraft/cooking/steak
	id = "steak"
	label = "Steak"
	tier = 2
	rank_req = 3
	fx_kind = "yield"
	fx_arg = "Hunting"
	result_type = /obj/Items/Edibles/Dish/steak
	slotspec = list(\
		list("Main", 2, "cat:Meat", 2),\
		list("Side", 1, "tag:mushroom", 1),\
		list("Season", 1, "tag:herb", 1))

/datum/craft_recipe/lifecraft/cooking/giant_gummy_bear
	id = "giant_gummy_bear"
	label = "Giant Gummy Bear"
	tier = 2
	rank_req = 4
	fx_kind = "quality"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/giant_gummy_bear
	slotspec = list(\
		list("Main", 2, "mat:Gelatin", 1),\
		list("Side", 1, "tag:sweet", 2))

/datum/craft_recipe/lifecraft/cooking/curry
	id = "curry"
	label = "Curry"
	tier = 2
	rank_req = 4
	fx_kind = "recover"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/curry
	slotspec = list(\
		list("Main", 2, "cat:Meat", 2),\
		list("Side", 1, "cat:Crops", 2),\
		list("Season", 1, "tag:herb", 2))

/datum/craft_recipe/lifecraft/cooking/hot_dog
	id = "hot_dog"
	label = "Hot Dog"
	tier = 3
	rank_req = 5
	fx_kind = "yield"
	fx_arg = "Mining"
	result_type = /obj/Items/Edibles/Dish/hot_dog
	slotspec = list(\
		list("Main", 3, "cat:Meat", 3),\
		list("Side", 2, "tag:grain", 3))

/datum/craft_recipe/lifecraft/cooking/sandwich
	id = "sandwich"
	label = "Sandwich"
	tier = 3
	rank_req = 5
	fx_kind = "yield"
	fx_arg = "Fishing"
	result_type = /obj/Items/Edibles/Dish/sandwich
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Meat", 2),\
		list("Season", 1, "tag:leafy", 1))

/datum/craft_recipe/lifecraft/cooking/pancakes
	id = "pancakes"
	label = "Pancakes"
	tier = 3
	rank_req = 5
	fx_kind = "yield"
	fx_arg = "Foraging"
	result_type = /obj/Items/Edibles/Dish/pancakes
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:sweet", 2))

/datum/craft_recipe/lifecraft/cooking/apple_pie
	id = "apple_pie"
	label = "Apple Pie"
	tier = 3
	rank_req = 5
	fx_kind = "yield"
	fx_arg = "Farming"
	result_type = /obj/Items/Edibles/Dish/apple_pie
	slotspec = list(\
		list("Main", 2, "tag:grain", 3),\
		list("Side", 3, "cat:Fruit", 1))

/datum/craft_recipe/lifecraft/cooking/burrito
	id = "burrito"
	label = "Burrito"
	tier = 3
	rank_req = 5
	fx_kind = "yield"
	fx_arg = "Hunting"
	result_type = /obj/Items/Edibles/Dish/burrito
	slotspec = list(\
		list("Main", 3, "cat:Meat", 3),\
		list("Side", 2, "tag:grain", 3),\
		list("Season", 1, "tag:legume", 1))

/datum/craft_recipe/lifecraft/cooking/gingerbread_man
	id = "gingerbread_man"
	label = "Gingerbread Man"
	tier = 3
	rank_req = 6
	fx_kind = "quality"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/gingerbread_man
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:sweet", 2),\
		list("Season", 1, "tag:herb", 3))

/datum/craft_recipe/lifecraft/cooking/ramen
	id = "ramen"
	label = "Ramen"
	tier = 3
	rank_req = 6
	fx_kind = "recover"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/ramen
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Meat", 3),\
		list("Season", 1, "tag:allium", 2))

/datum/craft_recipe/lifecraft/cooking/pizza
	id = "pizza"
	label = "Pizza"
	tier = 4
	rank_req = 7
	fx_kind = "yield"
	fx_arg = "Mining"
	result_type = /obj/Items/Edibles/Dish/pizza
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Meat", 4),\
		list("Season", 1, "tag:mushroom", 3))

/datum/craft_recipe/lifecraft/cooking/bagel
	id = "bagel"
	label = "Bagel"
	tier = 4
	rank_req = 7
	fx_kind = "yield"
	fx_arg = "Fishing"
	result_type = /obj/Items/Edibles/Dish/bagel
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Fish", 4),\
		list("Season", 1, "tag:herb", 3))

/datum/craft_recipe/lifecraft/cooking/waffle
	id = "waffle"
	label = "Waffle"
	tier = 4
	rank_req = 7
	fx_kind = "yield"
	fx_arg = "Foraging"
	result_type = /obj/Items/Edibles/Dish/waffle
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:sweet", 4),\
		list("Season", 1, "cat:Fruit", 3))

/datum/craft_recipe/lifecraft/cooking/strawberry_cake
	id = "strawberry_cake"
	label = "Strawberry Cake"
	tier = 4
	rank_req = 7
	fx_kind = "yield"
	fx_arg = "Farming"
	result_type = /obj/Items/Edibles/Dish/strawberry_cake
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:berry", 2),\
		list("Season", 1, "tag:sweet", 4))

/datum/craft_recipe/lifecraft/cooking/roasted_chicken
	id = "roasted_chicken"
	label = "Roasted Chicken"
	tier = 4
	rank_req = 7
	fx_kind = "yield"
	fx_arg = "Hunting"
	result_type = /obj/Items/Edibles/Dish/roasted_chicken
	slotspec = list(\
		list("Main", 3, "cat:Meat", 4),\
		list("Side", 1, "tag:allium", 2),\
		list("Season", 1, "tag:herb", 3))

/datum/craft_recipe/lifecraft/cooking/donut
	id = "donut"
	label = "Donut"
	tier = 4
	rank_req = 8
	fx_kind = "quality"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/donut
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:sweet", 4))

/datum/craft_recipe/lifecraft/cooking/garlic_bread
	id = "garlic_bread"
	label = "Garlic Bread"
	tier = 4
	rank_req = 8
	fx_kind = "recover"
	fx_arg = ""
	result_type = /obj/Items/Edibles/Dish/garlic_bread
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "mat:Garlic", 1),\
		list("Season", 1, "tag:herb", 3))

/datum/craft_recipe/lifecraft/cooking/burger
	id = "burger"
	label = "Burger"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "Str"
	result_type = /obj/Items/Edibles/Dish/burger
	slotspec = list(\
		list("Main", 3, "cat:Meat", 4),\
		list("Side", 2, "tag:grain", 3),\
		list("Season", 1, "tag:leafy", 1))

/datum/craft_recipe/lifecraft/cooking/fruitcake
	id = "fruitcake"
	label = "Fruitcake"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "End"
	result_type = /obj/Items/Edibles/Dish/fruitcake
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Fruit", 4),\
		list("Season", 1, "tag:sweet", 2))

/datum/craft_recipe/lifecraft/cooking/cookies
	id = "cookies"
	label = "Cookies"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "Spd"
	result_type = /obj/Items/Edibles/Dish/cookies
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "tag:sweet", 4))

/datum/craft_recipe/lifecraft/cooking/spaghetti
	id = "spaghetti"
	label = "Spaghetti"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "For"
	result_type = /obj/Items/Edibles/Dish/spaghetti
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Meat", 4),\
		list("Season", 1, "cat:Crops", 3))

/datum/craft_recipe/lifecraft/cooking/nachos
	id = "nachos"
	label = "Nachos"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "Off"
	result_type = /obj/Items/Edibles/Dish/nachos
	slotspec = list(\
		list("Main", 3, "tag:grain", 3),\
		list("Side", 2, "cat:Crops", 4),\
		list("Season", 1, "tag:herb", 3))

/datum/craft_recipe/lifecraft/cooking/dumplings
	id = "dumplings"
	label = "Dumplings"
	tier = 4
	rank_req = 8
	fx_kind = "stat"
	fx_arg = "Def"
	result_type = /obj/Items/Edibles/Dish/dumplings
	slotspec = list(\
		list("Main", 2, "cat:Meat", 4),\
		list("Side", 2, "tag:grain", 3),\
		list("Season", 1, "tag:leafy", 3))

/obj/Items/Edibles/Dish/bacon { name = "Bacon"; dish_id = "bacon"; icon_state = "bacon" }
/obj/Items/Edibles/Dish/meatballs { name = "Meatballs"; dish_id = "meatballs"; icon_state = "meatballs" }
/obj/Items/Edibles/Dish/grilled_salmon { name = "Grilled Salmon"; dish_id = "grilled_salmon"; icon_state = "grilled_salmon" }
/obj/Items/Edibles/Dish/jam { name = "Jam"; dish_id = "jam"; icon_state = "jam" }
/obj/Items/Edibles/Dish/french_fries { name = "French Fries"; dish_id = "french_fries"; icon_state = "french_fries" }
/obj/Items/Edibles/Dish/sushi { name = "Sushi"; dish_id = "sushi"; icon_state = "sushi" }
/obj/Items/Edibles/Dish/potato_chips { name = "Potato Chips"; dish_id = "potato_chips"; icon_state = "potato_chips" }
/obj/Items/Edibles/Dish/jelly { name = "Jelly"; dish_id = "jelly"; icon_state = "jelly" }
/obj/Items/Edibles/Dish/steak { name = "Steak"; dish_id = "steak"; icon_state = "steak" }
/obj/Items/Edibles/Dish/giant_gummy_bear { name = "Giant Gummy Bear"; dish_id = "giant_gummy_bear"; icon_state = "giant_gummy_bear" }
/obj/Items/Edibles/Dish/curry { name = "Curry"; dish_id = "curry"; icon_state = "curry" }
/obj/Items/Edibles/Dish/hot_dog { name = "Hot Dog"; dish_id = "hot_dog"; icon_state = "hot_dog" }
/obj/Items/Edibles/Dish/sandwich { name = "Sandwich"; dish_id = "sandwich"; icon_state = "sandwich" }
/obj/Items/Edibles/Dish/pancakes { name = "Pancakes"; dish_id = "pancakes"; icon_state = "pancakes" }
/obj/Items/Edibles/Dish/apple_pie { name = "Apple Pie"; dish_id = "apple_pie"; icon_state = "apple_pie" }
/obj/Items/Edibles/Dish/burrito { name = "Burrito"; dish_id = "burrito"; icon_state = "burrito" }
/obj/Items/Edibles/Dish/gingerbread_man { name = "Gingerbread Man"; dish_id = "gingerbread_man"; icon_state = "gingerbread_man" }
/obj/Items/Edibles/Dish/ramen { name = "Ramen"; dish_id = "ramen"; icon_state = "ramen" }
/obj/Items/Edibles/Dish/pizza { name = "Pizza"; dish_id = "pizza"; icon_state = "pizza" }
/obj/Items/Edibles/Dish/bagel { name = "Bagel"; dish_id = "bagel"; icon_state = "bagel" }
/obj/Items/Edibles/Dish/waffle { name = "Waffle"; dish_id = "waffle"; icon_state = "waffle" }
/obj/Items/Edibles/Dish/strawberry_cake { name = "Strawberry Cake"; dish_id = "strawberry_cake"; icon_state = "strawberry_cake" }
/obj/Items/Edibles/Dish/roasted_chicken { name = "Roasted Chicken"; dish_id = "roasted_chicken"; icon_state = "roasted_chicken" }
/obj/Items/Edibles/Dish/donut { name = "Donut"; dish_id = "donut"; icon_state = "donut" }
/obj/Items/Edibles/Dish/garlic_bread { name = "Garlic Bread"; dish_id = "garlic_bread"; icon_state = "garlic_bread" }
/obj/Items/Edibles/Dish/burger { name = "Burger"; dish_id = "burger"; icon_state = "burger" }
/obj/Items/Edibles/Dish/fruitcake { name = "Fruitcake"; dish_id = "fruitcake"; icon_state = "fruitcake" }
/obj/Items/Edibles/Dish/cookies { name = "Cookies"; dish_id = "cookies"; icon_state = "cookies" }
/obj/Items/Edibles/Dish/spaghetti { name = "Spaghetti"; dish_id = "spaghetti"; icon_state = "spaghetti" }
/obj/Items/Edibles/Dish/nachos { name = "Nachos"; dish_id = "nachos"; icon_state = "nachos" }
/obj/Items/Edibles/Dish/dumplings { name = "Dumplings"; dish_id = "dumplings"; icon_state = "dumplings" }
