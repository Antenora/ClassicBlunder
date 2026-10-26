/proc/CharacterRigDirect(datum/character_rig_raster/source, list/mapping, width = 48, height = 40, datum/character_rig_raster/alternate)
	var/datum/character_rig_raster/R = new(width, height)
	for(var/list/pair in mapping)
		var/i = pair[2]
		R.pixels[pair[1]] = i > 1024 ? (alternate ? alternate.pixels[i - 1024] : source.pixels[i - 1024]) : source.pixels[i]
	return R

/proc/CharacterRigThin(datum/character_rig_raster/source)
	var/datum/character_rig_raster/colored = source.Copy()
	for(var/i = 1, i <= colored.pixels.len, i++)
		if(colored.pixels[i] == "#000000ff") colored.pixels[i] = null
	for(var/y = 0, y < source.h, y++)
		for(var/x = 0, x < source.w, x++)
			if(source.At(x, y) == "#000000ff" && !CharacterRigTouching(colored, x, y)) source.Put(x, y, null)
	return source

/proc/CharacterRigDarker(datum/character_rig_raster/source, list/palette)
	for(var/i = 1, i <= source.pixels.len, i++)
		var/c = source.pixels[i]
		if(palette[c]) source.pixels[i] = palette[c]
	return source

/proc/CharacterRigBounds(datum/character_rig_raster/source)
	var/list/bounds = list(32, 32, 0, 0)
	for(var/y = 0, y < 32, y++)
		for(var/x = 0, x < 32, x++)
			if(!source.At(x, y)) continue
			bounds[1] = min(bounds[1], x)
			bounds[2] = min(bounds[2], y)
			bounds[3] = max(bounds[3], x + 1)
			bounds[4] = max(bounds[4], y + 1)
	return bounds[3] ? bounds : null

/proc/CharacterRigDrape(datum/character_rig_raster/source, list/recipe)
	var/list/bounds = CharacterRigBounds(source)
	var/datum/character_rig_raster/R = new(48, 40)
	if(!bounds) return R
	var/list/hip = recipe["hip"]
	var/lean = recipe["lean"]
	var/progress = recipe["progress"]
	if(!lean && !progress) return CharacterRigPlace(source, list(round(hip[1] - 16, 1), round(hip[2] - 25, 1)))
	var/cc = cos(lean)
	var/ss = sin(lean)
	var/tx = hip[1] + ss
	var/ty = hip[2] - cc
	var/curvature = min(35 * progress * 0.0174532925199433 / max(1, bounds[4] - 25), 0.45 / max(1, 16 - bounds[1]))
	for(var/y = 0, y < 40, y++)
		for(var/x = 0, x < 48, x++)
			var/lx = (x - tx) * cc + (y - ty) * ss
			var/ly = -(x - tx) * ss + (y - ty) * cc
			var/sx = lx + 16
			var/sy = ly + 24
			if(ly > 0 && abs(curvature) > 0.00000001)
				var/radius = 1 / curvature
				sx = sqrt((lx + radius) ** 2 + ly ** 2) - radius + 16
				sy = arctan(lx + radius, ly) * 0.0174532925199433 / curvature + 24
			sx = round((sx + 0.5) * 8)
			sy = round((sy + 0.5) * 8)
			if(sx >= 0 && sy >= 0 && sx < 256 && sy < 256) R.Put(x, y, source.pixels[source.SourceAt(3, sx, sy)])
	return R

/proc/CharacterRigSideArm(datum/character_rig_raster/base, datum/character_rig_raster/garment, list/recipe, list/palette)
	var/datum/character_rig_raster/R = CharacterRigDirect(base, recipe["base"])
	var/datum/character_rig_raster/mapped = CharacterRigDirect(garment, recipe["uv"])
	R.Over(mapped)
	if(recipe["far"]) CharacterRigDarker(R, palette)
	var/list/geometry = CharacterRigGeometry()
	var/list/side = geometry["side"]
	var/list/masks = side["masks"]
	if(!garment.derivatives) garment.derivatives = list()
	var/datum/character_rig_raster/extension = garment.derivatives["extension"]
	if(!extension)
		extension = garment.Copy()
		for(var/i in masks["arm_shape"]) extension.pixels[i] = null
		garment.derivatives["extension"] = extension
	var/datum/character_rig_raster/extra = CharacterRigGather(extension, recipe["extension"])
	var/list/boundary = new/list(1920)
	for(var/i in recipe["ink"]) boundary[i] = 1
	for(var/i in recipe["ink"])
		if(mapped.pixels[i]) continue
		for(var/shift in list(48, 1, -48, -1))
			var/j = i + shift
			if(j < 1 || j > 1920) continue
			if(extra.pixels[j] && extra.pixels[j] != "#000000ff")
				R.pixels[i] = extra.pixels[j]
				break
	var/datum/character_rig_raster/bare = CharacterRigDirect(base, recipe["base"])
	for(var/i = 1, i <= 1920, i++)
		if(extra.pixels[i] && (!bare.pixels[i] || boundary[i])) R.pixels[i] = extra.pixels[i]
	var/datum/character_rig_raster/exposed = new(48, 40)
	for(var/i = 1, i <= 1920, i++)
		if(bare.pixels[i] && !mapped.pixels[i] && !extra.pixels[i]) exposed.pixels[i] = R.pixels[i]
	var/datum/character_rig_raster/distal = new(48, 40)
	if(recipe["distal"])
		for(var/i in recipe["distal"]) distal.pixels[i] = R.pixels[i]
	return list(R, exposed, distal)

/proc/CharacterRigFlow(datum/character_rig_raster/source, list/recipe, upper = 0)
	var/datum/character_rig_raster/R = new(48, 40)
	var/list/bounds = CharacterRigBounds(source)
	if(!bounds) return R
	var/list/points = list()
	var/min_x = 32
	for(var/y = bounds[2] * 8, y < bounds[4] * 8, y++)
		for(var/x = bounds[1] * 8, x < bounds[3] * 8, x++)
			var/c = source.pixels[source.SourceAt(3, x, y)]
			if(!c) continue
			var/sx = (x + 0.5) / 8 - 0.5
			var/sy = (y + 0.5) / 8 - 0.5
			points += list(list(sx, sy, c))
			min_x = min(min_x, sx)
	var/list/hip = recipe["hip"]
	var/lean = recipe["lean"]
	var/progress = recipe["progress"]
	var/cc = cos(lean)
	var/ss = sin(lean)
	var/tx = hip[1] + ss
	var/ty = hip[2] - cc
	var/curvature = min(35 * progress * 0.0174532925199433 / max(1, bounds[4] - 25), 0.45 / max(1, 16 - min_x))
	var/attachment = min(16, bounds[2])
	var/list/distance = new/list(1920)
	for(var/list/point in points)
		var/u = point[1] - 16
		var/v = point[2] - 24
		var/mx
		var/my
		if(upper)
			var/fraction = clamp((point[2] - attachment) / max(1, 24 - attachment), 0, 1)
			u -= 2 * progress * sin(180 * fraction) ** 2
			mx = u * cc - v * ss + tx
			my = u * ss + v * cc + ty
		else
			v = max(0, v)
			var/theta = lean + curvature * v * 57.2957795130823
			if(abs(curvature) < 0.00000001)
				mx = -ss * v + cos(theta) * u + tx
				my = cc * v + sin(theta) * u + ty
			else
				mx = (cos(theta) - cc) / curvature + cos(theta) * u + tx
				my = (sin(theta) - ss) / curvature + sin(theta) * u + ty
		var/x = round(mx, 1)
		var/y = round(my, 1)
		if(x < 0 || y < 0 || x >= 48 || y >= 40) continue
		var/cost = (mx - x) ** 2 + (my - y) ** 2
		var/i = 1 + x + y * 48
		if(cost <= 0.14 && (isnull(distance[i]) || cost < distance[i] - 0.0000001))
			distance[i] = cost
			R.pixels[i] = point[3]
	return R

/datum/character_rig_side
	var/datum/character_rig_raster/base
	var/datum/character_rig_raster/alternate
	var/datum/character_rig_raster/near
	var/datum/character_rig_raster/far
	var/datum/character_rig_raster/front
	var/datum/character_rig_raster/coat
	var/datum/character_rig_raster/cover
	var/datum/character_rig_raster/back
	var/datum/character_rig_raster/head
	var/list/data
	var/list/masks
	var/list/templates
	var/list/palette
	var/list/parts
	var/list/cloth_parts

	New(datum/character_rig_raster/body_source, datum/character_rig_raster/alternate_source, datum/character_rig_raster/near_source, datum/character_rig_raster/far_source, datum/character_rig_raster/front_source, datum/character_rig_raster/coat_source, datum/character_rig_raster/cover_source, datum/character_rig_raster/back_source, datum/character_rig_raster/head_source, datum/character_rig_raster/far_coat, datum/character_rig_raster/rigid_near, datum/character_rig_raster/rigid_far)
		var/list/geometry = CharacterRigGeometry()
		data = geometry["side"]
		masks = data["masks"]
		templates = data["templates"]
		base = body_source
		alternate = alternate_source
		near = near_source ? near_source : new /datum/character_rig_raster
		far = far_source ? far_source : new /datum/character_rig_raster
		front = front_source ? front_source : new /datum/character_rig_raster
		coat = coat_source
		cover = cover_source
		back = back_source
		head = head_source
		parts = list()
		cloth_parts = list()
		for(var/name in templates) parts[name] = CharacterRigDirect(base, templates[name], 32, 32, alternate)
		parts["head"] = base.Mask(masks["head"])
		palette = list()
		for(var/list/pair in data["palette"])
			if(base.pixels[pair[1]] && base.pixels[pair[2]]) palette[base.pixels[pair[1]]] = base.pixels[pair[2]]
		var/datum/character_rig_raster/H = parts["head"]
		if(head) H.Over(head)
		var/datum/character_rig_raster/clean_near = near.Copy()
		var/datum/character_rig_raster/clean_far = far.Copy()
		var/list/helmet = CharacterRigHelmet(near)
		cloth_parts["head"] = near.Mask(helmet)
		for(var/i in helmet) clean_near.pixels[i] = null
		for(var/i in CharacterRigHelmet(far)) clean_far.pixels[i] = null
		cloth_parts["near"] = clean_near.Mask(masks["arm"])
		cloth_parts["far"] = clean_far.Mask(masks["arm"])
		cloth_parts["near_leg"] = clean_near.Mask(masks["leg"])
		cloth_parts["far_leg"] = clean_far.Mask(masks["leg"])
		cloth_parts["body"] = Torso(clean_near, front)
		if(!coat)
			for(var/which in list("near", "far"))
				var/datum/character_rig_raster/sleeve = cloth_parts[which]
				var/list/patch = CharacterRigShoulder(sleeve)
				if(patch.len)
					cloth_parts["[which]_shoulder"] = sleeve.Mask(patch)
					cloth_parts[which] = CharacterRigUnderlay(sleeve, patch, masks["arm_shape"])
				var/datum/character_rig_raster/rigid = which == "near" ? rigid_near : rigid_far
				if(rigid)
					var/datum/character_rig_raster/leg = cloth_parts["[which]_leg"]
					patch = CharacterRigKnee(rigid.Mask(masks["leg"]))
					if(patch.len)
						cloth_parts["[which]_knee"] = leg.Mask(patch)
						cloth_parts["[which]_leg"] = CharacterRigUnderlay(leg, patch)
		if(coat)
			var/datum/character_rig_raster/surface = coat.Copy()
			for(var/x = 0, x < 32, x++)
				for(var/y = 0, y < 32, y++)
					var/i = 1 + x + y * 32
					if(coat.pixels[i] || !(i in masks["body_shape"])) continue
					var/above = y - 1
					var/below = y + 1
					while(above >= 0 && !coat.At(x, above)) above--
					while(below < 32 && !coat.At(x, below)) below++
					if(above >= 0 && below < 32) surface.pixels[i] = coat.At(x, y - above < below - y ? above : below)
			cloth_parts["surface"] = surface
			var/datum/character_rig_raster/N = cloth_parts["near"]
			N.Over(coat.Mask(masks["arm"]))
			if(far_coat)
				N = cloth_parts["far"]
				N.Over(far_coat.Mask(masks["arm"]))
		if(back)
			var/datum/character_rig_raster/upper = back.Copy()
			var/datum/character_rig_raster/lower = back.Copy()
			for(var/i = 1, i <= 1024, i++)
				if(i > 768) upper.pixels[i] = null
				else lower.pixels[i] = null
			cloth_parts["back_upper"] = upper
			cloth_parts["back_lower"] = lower

	proc/Torso(datum/character_rig_raster/source, datum/character_rig_raster/guide)
		var/datum/character_rig_raster/R = source.Mask(masks["torso"])
		var/datum/character_rig_raster/visible = R.Copy()
		for(var/i in masks["hidden"])
			var/x = (i - 1) % 32
			var/y = round((i - 1) / 32)
			var/g = guide.At(clamp(x + 1, 14, 17), y)
			var/row = 0
			for(var/cx = 16, cx <= 20, cx++)
				if(visible.At(cx, y)) row++
			if(!row && !g) continue
			var/best = 100000
			var/choice
			var/has_color = 0
			for(var/cy = max(16, y - 1), cy <= min(25, y + 1), cy++)
				for(var/cx = 16, cx <= 20, cx++)
					var/c = visible.At(cx, cy)
					if(!c || (has_color && c == "#000000ff")) continue
					if(c != "#000000ff" && !has_color)
						has_color = 1
						best = 100000
					var/cost = (abs(cx - x) + 3 * abs(cy - y)) * 0.15
					if(g && g != "#000000ff")
						var/list/cc = rgb2num(c)
						var/list/gc = rgb2num(g)
						cost += sqrt((cc[1] - gc[1]) ** 2 + (cc[2] - gc[2]) ** 2 + (cc[3] - gc[3]) ** 2) / 70
					if(cost < best)
						best = cost
						choice = c
			var/datum/character_rig_raster/body = parts["body"]
			if(body.pixels[i] && body.pixels[i] != "#000000ff") R.pixels[i] = choice
		R.Over(source.Mask(masks["torso_rest"]))
		return R

	proc/Render(list/recipe)
		if(recipe["rest"])
			var/datum/character_rig_raster/R = new(48, 40)
			R.Over(base, 8, 4)
			R.Over(near, 8, 4)
			if(back) R.Over(back, 8, 4)
			if(coat) R.Over(coat, 8, 4)
			if(cover) R.Over(cover, 8, 4)
			if(head) R.Over(head, 8, 4)
			return R
		var/list/arms = recipe["arms"]
		var/list/near_arm = CharacterRigSideArm(base, cloth_parts["near"], arms["near"], palette)
		var/list/far_arm = list(new /datum/character_rig_raster(48, 40), new /datum/character_rig_raster(48, 40), new /datum/character_rig_raster(48, 40))
		if(arms["far"]) far_arm = CharacterRigSideArm(base, cloth_parts["far"], arms["far"], palette)
		var/datum/character_rig_raster/body
		var/datum/character_rig_raster/H
		var/list/layers = list()
		if(back)
			layers += CharacterRigFlow(cloth_parts["back_upper"], recipe, 1)
			layers += CharacterRigFlow(cloth_parts["back_lower"], recipe)
		if(recipe["motion"] == "dash")
			var/datum/character_rig_raster/T = parts["torso"]
			T = T.Copy()
			T.Over(cloth_parts["body"])
			body = CharacterRigWarp(T, recipe["body"])
			H = parts["head"]
			H = H.Copy()
			H.Over(cloth_parts["head"])
			H = CharacterRigWarp(H, recipe["head"])
			var/datum/character_rig_raster/L = parts["leg"]
			L = L.Copy()
			L.Over(cloth_parts["far_leg"])
			L = CharacterRigWarp(L, recipe["far_leg"])
			L = CharacterRigDarker(CharacterRigThin(L), palette)
			var/list/knee = recipe["knee"]
			if(cloth_parts["far_knee"])
				var/list/patch_pose = knee["far"]
				L.Over(CharacterRigRigid(cloth_parts["far_knee"], list(15.5, 27.5), patch_pose["root"], patch_pose["angle"]))
				CharacterRigThin(L)
			layers += L
			layers += body
			var/shape = recipe["leg_shape"]
			L = parts[shape]
			L = L.Copy()
			var/list/leg_uv = data["leg_uv"]
			L.Over(CharacterRigDirect(cloth_parts["near_leg"], leg_uv[shape], 32, 32))
			layers += CharacterRigWarp(L, recipe["near_leg"])
			if(cloth_parts["near_knee"])
				var/list/patch_pose = knee["near"]
				layers += CharacterRigRigid(cloth_parts["near_knee"], list(15.5, 27.5), patch_pose["root"], patch_pose["angle"])
			if(coat)
				layers += H
				layers += CharacterRigDrape(cloth_parts["surface"], recipe)
			layers += near_arm[1]
			layers += far_arm[1]
			for(var/which in list("far", "near"))
				if(!cloth_parts["[which]_shoulder"]) continue
				var/list/arm_pose = arms[which]
				layers += CharacterRigRigid(cloth_parts["[which]_shoulder"], list(14, 17.5), arm_pose["root"], arm_pose["cap_angle"])
			if(!coat) layers += H
			var/datum/character_rig_raster/exposed = far_arm[2]
			exposed.Over(far_arm[3])
			layers += exposed
			if(cloth_parts["near_shoulder"])
				exposed = near_arm[2]
				exposed.Over(near_arm[3])
			layers += near_arm[2]
		else
			body = CharacterRigDirect(base, recipe["body_base"], 48, 40, alternate)
			body.Over(CharacterRigDirect(cloth_parts["body"], recipe["body_direct"]))
			body.Over(CharacterRigDirect(cloth_parts["head"], recipe["body_direct"]))
			layers += far_arm[1]
			layers += body
			if(coat) layers += CharacterRigDrape(cloth_parts["surface"], recipe)
			layers += near_arm[1]
			if(head) layers += CharacterRigDirect(head, recipe["head_direct"])
		if(cover) layers += CharacterRigDrape(cover, recipe)
		if(coat || cover)
			var/datum/character_rig_raster/face = base.Mask(masks["head"])
			var/datum/character_rig_raster/fabric = cover ? cover : coat
			for(var/i = 1, i <= 1024, i++)
				if(fabric.pixels[i]) face.pixels[i] = null
			layers += recipe["motion"] == "dash" ? CharacterRigWarp(face, recipe["head"]) : CharacterRigDirect(face, recipe["head_direct"])
		return CharacterRigComposite(layers)
