recipes
	var/list/recipe/savedRecipes = list()

	proc
		addRecipe(recipe/recipe)
			if(recipe == 0)
				return
			savedRecipes += recipe
		removeRecipe(recipe/recipe)
			if(recipe == 0)
				return
			savedRecipes -= recipe

		findByName(name)
			for(var/recipe/i in savedRecipes)
				if(i.name == name)
					return i
			return 0

		removeByName(name)
			for(var/recipe/i in savedRecipes)
				if(i.name == name)
					savedRecipes -= i
					break

		listRecipes()
			var/list/recipes = list()
			for(var/recipe/i in savedRecipes)
				recipes += i.name
			return recipes

recipe
	var
		name
		prepare_text
		eat_text
		description
		icon
		icon_state
		pixel_x
		pixel_y
		meal = FALSE
		drink = FALSE

	New(name, icon, iconstate, x, y, eattext, prep, desc, mealType)
		src.name = name
		src.icon = icon
		icon_state = iconstate
		pixel_x = x
		pixel_y = y
		eat_text = eattext
		prepare_text = prep
		description = desc
		if(mealType=="Food")
			meal = TRUE
		if(mealType == "Drink")
			drink = TRUE