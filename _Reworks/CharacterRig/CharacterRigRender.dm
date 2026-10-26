var/global/list/character_rig_geometry
var/global/list/character_rig_all_pixels

/proc/CharacterRigGeometry()
	if(!character_rig_geometry)
		character_rig_geometry = json_decode(file2text('Icons/CharacterRig/frisky_male.json'))
		character_rig_all_pixels = list()
		for(var/i = 1, i <= 1920, i++) character_rig_all_pixels += i
	return character_rig_geometry

/proc/CharacterRigTouching(datum/character_rig_raster/R, x, y)
	return !!R.At(x - 1, y) + !!R.At(x + 1, y) + !!R.At(x, y - 1) + !!R.At(x, y + 1)

/proc/CharacterRigPlace(datum/character_rig_raster/source, list/offset)
	var/datum/character_rig_raster/R = new(48, 40)
	R.Over(source, offset[1], offset[2])
	return R

/proc/CharacterRigComponents(datum/character_rig_raster/source)
	var/list/seen = new/list(source.w * source.h)
	var/list/components = list()
	for(var/i = 1, i <= seen.len, i++)
		if(seen[i] || !source.pixels[i]) continue
		var/list/queue = list(i)
		seen[i] = 1
		var/position = 1
		while(position <= queue.len)
			var/j = queue[position++]
			var/x = (j - 1) % source.w
			var/y = round((j - 1) / source.w)
			for(var/dy = -1, dy <= 1, dy++)
				for(var/dx = -1, dx <= 1, dx++)
					if(!source.At(x + dx, y + dy)) continue
					var/k = j + dx + dy * source.w
					if(!seen[k])
						seen[k] = 1
						queue += k
		components += list(queue)
	return components

/proc/CharacterRigRemoveFragments(datum/character_rig_raster/frame, datum/character_rig_raster/cloth, original_components)
	if(!cloth) return frame
	var/list/components = CharacterRigComponents(frame)
	if(components.len <= original_components) return frame
	for(var/list/component in components)
		if(component.len > 4) continue
		var/fabric_only = 1
		for(var/i in component)
			if(!cloth.pixels[i] || cloth.pixels[i] != frame.pixels[i]) fabric_only = 0
		if(fabric_only)
			for(var/i in component) frame.pixels[i] = null
	return frame

/proc/CharacterRigArm(datum/character_rig_raster/source, datum/character_rig_raster/cap, datum/character_rig_raster/body, list/recipe, separate = 0)
	if(recipe["translate"]) return CharacterRigPlace(source, recipe["translate"])
	var/datum/character_rig_raster/texture = recipe["strike"] ? source.StripInk(1) : source
	var/datum/character_rig_raster/R = CharacterRigGather(texture, recipe["map"])
	if(!recipe["strike"])
		for(var/i = 1, i <= R.pixels.len, i++)
			if(R.uv[i] >= 737) R.pixels[i] = null
	var/list/palm = recipe["palm"]
	for(var/list/pair in palm) R.pixels[pair[1]] = source.pixels[pair[2]]
	if(recipe["strike"])
		R = R.Outline(recipe["outline"])
	else
		var/datum/character_rig_raster/colored = R.Copy()
		for(var/i = 1, i <= colored.pixels.len, i++)
			if(colored.pixels[i] == "#000000ff") colored.pixels[i] = null
		for(var/y = 0, y < 40, y++)
			for(var/x = 0, x < 48, x++)
				if(R.At(x, y) == "#000000ff" && !CharacterRigTouching(colored, x, y)) R.Put(x, y, null)
		for(var/list/pair in palm)
			var/i = pair[1] - 1
			for(var/neighbor in list(i, i + 2, i - 47, i + 49, i + 1))
				if(neighbor > 0 && neighbor <= 1920 && !colored.pixels[neighbor]) R.pixels[neighbor] = "#000000ff"
	if(recipe["patch"])
		var/datum/character_rig_raster/original = R.Copy()
		var/datum/character_rig_raster/P = CharacterRigGather(cap.StripInk(1), recipe["patch"])
		for(var/i in recipe["rim"])
			if(original.pixels[i] != "#000000ff" || !body.pixels[i]) continue
			var/x = (i - 1) % 48
			var/y = round((i - 1) / 48)
			if(P.pixels[i] || CharacterRigTouching(P, x, y)) R.pixels[i] = null
		R.Over(P)
		if(separate)
			for(var/i in recipe["rim"])
				if(original.pixels[i] == "#000000ff" && body.pixels[i]) R.pixels[i] = original.pixels[i]
		for(var/list/pair in palm) R.pixels[pair[1]] = original.pixels[pair[1]]
	return R

/proc/CharacterRigLeg(datum/character_rig_raster/source, list/recipe)
	if(recipe["translate"]) return CharacterRigPlace(source, recipe["translate"])
	if(!source.derivatives) source.derivatives = list()
	var/list/prepared = source.derivatives["leg"]
	if(!prepared)
		var/datum/character_rig_raster/clean = source.StripInk()
		clean = clean.Copy()
		var/support = 0
		for(var/x = 0, x < 32, x++)
			if(clean.At(x, 27)) support++
		if(support)
			for(var/x = 0, x < 32, x++)
				if(!clean.At(x, 27)) clean.Put(x, 26, null)
		var/datum/character_rig_raster/toes = new
		for(var/y = 29, y < 32, y++)
			for(var/x = 0, x < 32, x++)
				toes.Put(x, y, clean.At(x, y))
				clean.Put(x, y, null)
		prepared = list(clean, toes)
		source.derivatives["leg"] = prepared
	var/datum/character_rig_raster/texture = prepared[1]
	var/datum/character_rig_raster/foot = prepared[2]
	var/datum/character_rig_raster/R = CharacterRigGather(texture, recipe["map"])
	var/list/shift = recipe["foot"]
	R.Over(foot, shift[1], shift[2])
	return R.Outline(character_rig_all_pixels)

/proc/CharacterRigContour(list/layers, list/order, hip, datum/character_rig_raster/cloth)
	var/datum/character_rig_raster/R = new(48, 40)
	var/list/owner = new/list(1920)
	for(var/name in order)
		var/datum/character_rig_raster/L = layers[name]
		if(!L) continue
		for(var/i = 1, i <= 1920, i++)
			if(L.pixels[i])
				R.pixels[i] = L.pixels[i]
				owner[i] = name
	var/list/exterior = new/list(1920)
	var/list/queue = list(1)
	exterior[1] = 1
	var/position = 1
	while(position <= queue.len)
		var/i = queue[position++]
		var/x = (i - 1) % 48
		var/y = round((i - 1) / 48)
		var/list/neighbors = list()
		if(x) neighbors += i - 1
		if(x < 47) neighbors += i + 1
		if(y) neighbors += i - 48
		if(y < 39) neighbors += i + 48
		for(var/j in neighbors)
			if(!R.pixels[j] && !exterior[j])
				exterior[j] = 1
				queue += j
	var/datum/character_rig_raster/upper = new(48, 40)
	for(var/i = 1, i <= 1920, i++)
		if((owner[i] in list("body", "left", "right")) && R.pixels[i] && R.pixels[i] != "#000000ff") upper.pixels[i] = 1
	var/datum/character_rig_raster/border = new(48, 40)
	for(var/y = 0, y < hip, y++)
		for(var/x = 0, x < 48, x++)
			var/i = 1 + x + y * 48
			if(exterior[i] && CharacterRigTouching(upper, x, y)) border.pixels[i] = "#000000ff"
	var/datum/character_rig_raster/clean = border.Copy()
	if(cloth)
		for(var/y = 0, y < hip, y++)
			for(var/x = 0, x < 48, x++)
				if(!border.At(x, y) || CharacterRigTouching(R, x, y) != 1 || CharacterRigTouching(border, x, y)) continue
				for(var/shift in list(-1, 1, -48, 48))
					var/j = 1 + x + y * 48 + shift
					if(j > 0 && j <= 1920 && cloth.pixels[j] && cloth.pixels[j] == R.pixels[j]) clean.Put(x, y, null)
	clean.Over(R)
	return clean

/datum/character_rig_view
	var/datum/character_rig_raster/base
	var/datum/character_rig_raster/coat
	var/datum/character_rig_raster/cover
	var/datum/character_rig_raster/back
	var/datum/character_rig_raster/head
	var/list/parts
	var/list/caps
	var/list/masks
	var/direction
	var/original_components = 1

	New(datum/character_rig_raster/body_source, datum/character_rig_raster/coat_source, datum/character_rig_raster/cover_source, datum/character_rig_raster/back_source, datum/character_rig_raster/head_source, facing)
		var/list/data = CharacterRigGeometry()
		masks = data["masks"]
		base = body_source
		coat = coat_source
		cover = cover_source
		back = back_source
		head = head_source
		direction = facing
		var/datum/character_rig_raster/original = base.Copy()
		if(coat) original.Over(coat)
		if(cover) original.Over(cover)
		var/list/components = CharacterRigComponents(original)
		original_components = components.len
		parts = list()
		caps = list()
		for(var/name in list("left", "right", "left_leg", "right_leg", "head", "torso")) parts[name] = base.Mask(masks[name])
		var/datum/character_rig_raster/H = parts["head"]
		if(head) H.Over(head)
		if(coat)
			var/datum/character_rig_raster/surface = coat.Copy()
			for(var/i in masks["sleeve_only"]) surface.pixels[i] = null
			for(var/i in masks["infer"])
				if(coat.pixels[i]) continue
				var/x = (i - 1) % 32
				var/y = round((i - 1) / 32)
				var/above = y - 1
				var/below = y + 1
				while(above >= 0 && !coat.At(x, above)) above--
				while(below < 32 && !coat.At(x, below)) below++
				if(above >= 0 && below < 32) surface.pixels[i] = coat.At(x, y - above < below - y ? above : below)
			parts["cloth"] = surface
		for(var/name in list("left", "right"))
			var/datum/character_rig_raster/A = parts[name]
			var/datum/character_rig_raster/C = parts["torso"]
			C = C.Copy()
			C.Over(A)
			if(coat)
				A.Over(coat.Mask(masks["sleeve_[name]"]))
				C.Over(coat)
			caps[name] = C.Mask(masks["patch_[name]"])

	proc/Render(list/recipe)
		if(recipe["rest"])
			var/datum/character_rig_raster/R = new(48, 40)
			if(back) R.Over(back, 8, 4)
			R.Over(base, 8, 4)
			if(coat) R.Over(coat, 8, 4)
			if(cover) R.Over(cover, 8, 4)
			if(head) R.Over(head, 8, 4)
			return R
		var/list/layers = list()
		layers["body"] = CharacterRigWarp(parts["torso"], recipe["body"])
		layers["head"] = CharacterRigWarp(parts["head"], recipe["head"])
		if(coat) layers["cloth"] = CharacterRigWarp(parts["cloth"], recipe["cloth"])
		if(cover)
			layers["cover"] = CharacterRigWarp(cover, recipe["cloth"])
			layers["collar"] = CharacterRigWarp(cover.Mask(masks["head"]), recipe["body"])
		var/datum/character_rig_raster/join = layers["body"]
		join = join.Copy()
		if(coat) join.Over(layers["cloth"])
		var/list/arms = recipe["arms"]
		for(var/name in arms)
			var/datum/character_rig_raster/source = parts[name]
			var/list/arm_recipe = arms[name]
			if(coat && arm_recipe["translate"])
				source = source.Copy()
				var/datum/character_rig_raster/sleeve = coat.Mask(masks["sleeve_[name]"])
				for(var/i = 1, i <= 1024, i++)
					if(coat.pixels[i] && !sleeve.pixels[i]) source.pixels[i] = null
			layers[name] = CharacterRigArm(source, caps[name], join, arms[name], recipe["separate"] == name)
		var/list/legs = recipe["legs"]
		for(var/name in legs) layers[name] = CharacterRigLeg(parts[name], legs[name])
		if(recipe["shade"])
			var/datum/character_rig_raster/leg = layers[recipe["shade"]]
			var/lightest
			var/second
			var/high = -1
			var/next = -1
			var/datum/character_rig_raster/palette_source = parts["torso"]
			for(var/c in palette_source.pixels)
				if(!c) continue
				var/light = text2num(copytext(c, 2, 4), 16) + text2num(copytext(c, 4, 6), 16) + text2num(copytext(c, 6, 8), 16)
				if(light > high)
					second = lightest
					next = high
					lightest = c
					high = light
				else if(light > next && c != lightest)
					second = c
					next = light
			if(second)
				for(var/i = 1, i <= leg.pixels.len, i++)
					if(leg.pixels[i] == lightest) leg.pixels[i] = second
		var/list/order = recipe["order"]
		order = order.Copy()
		if(back)
			layers["back"] = CharacterRigWarp(back, recipe["cloth"])
			order.Insert(1, "back")
		if(recipe["hip"]) return CharacterRigContour(layers, order, recipe["hip"], layers["cloth"])
		var/list/ordered = list()
		for(var/name in order)
			if(layers[name]) ordered += layers[name]
		return CharacterRigRemoveFragments(CharacterRigComposite(ordered), cover ? layers["cover"] : layers["cloth"], original_components)
