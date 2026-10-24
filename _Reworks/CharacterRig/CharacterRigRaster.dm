/datum/character_rig_raster
	var/w = 32
	var/h = 32
	var/list/pixels
	var/list/uv
	var/list/scales
	var/list/derivatives

	New(width = 32, height = 32)
		w = width
		h = height
		pixels = new/list(w * h)

	proc/At(x, y)
		if(x < 0 || y < 0 || x >= w || y >= h) return null
		return pixels[1 + x + y * w]

	proc/Put(x, y, value)
		if(x < 0 || y < 0 || x >= w || y >= h) return
		scales = null
		derivatives = null
		pixels[1 + x + y * w] = value

	proc/Copy()
		var/datum/character_rig_raster/R = new(w, h)
		R.pixels = pixels.Copy()
		return R

	proc/Over(datum/character_rig_raster/R, dx = 0, dy = 0)
		if(!R) return src
		scales = null
		derivatives = null
		for(var/y = 0, y < R.h, y++)
			if(y + dy < 0 || y + dy >= h) continue
			for(var/x = 0, x < R.w, x++)
				if(x + dx < 0 || x + dx >= w) continue
				var/c = R.pixels[1 + x + y * R.w]
				if(!c) continue
				var/i = 1 + x + dx + (y + dy) * w
				if(copytext(c, 8, 10) == "ff" || !pixels[i])
					pixels[i] = c
				else
					var/list/front = rgb2num(c)
					var/list/back = rgb2num(pixels[i])
					var/alpha = front[4] + back[4] * (255 - front[4]) / 255
					for(var/k = 1, k <= 3, k++) front[k] = round((front[k] * front[4] + back[k] * back[4] * (255 - front[4]) / 255) / alpha, 1)
					pixels[i] = lowertext(rgb(front[1], front[2], front[3], round(alpha, 1)))
					if(length(pixels[i]) == 7) pixels[i] += "ff"
		return src

	proc/Mask(list/allowed)
		var/datum/character_rig_raster/R = new(w, h)
		for(var/i in allowed) R.pixels[i] = pixels[i]
		return R

	proc/StripInk(boundary_only = 0)
		if(!derivatives) derivatives = list()
		var/key = "ink-[boundary_only]"
		if(derivatives[key]) return derivatives[key]
		var/datum/character_rig_raster/R = Copy()
		for(var/y = 0, y < h, y++)
			for(var/x = 0, x < w, x++)
				var/i = 1 + x + y * w
				if(pixels[i] != "#000000ff") continue
				if(!boundary_only || !At(x - 1, y) || !At(x + 1, y) || !At(x, y - 1) || !At(x, y + 1)) R.pixels[i] = null
		derivatives[key] = R
		return R

	proc/SourceAt(level, x, y)
		var/width = w * (2 ** level)
		var/height = h * (2 ** level)
		x = clamp(x, 0, width - 1)
		y = clamp(y, 0, height - 1)
		var/i = 1 + x + y * width
		if(!level) return i
		if(!scales) scales = list()
		var/list/cache = scales["[level]"]
		if(!cache)
			cache = new/list(width * height)
			scales["[level]"] = cache
		if(cache[i]) return cache[i]
		var/px = round(x / 2)
		var/py = round(y / 2)
		var/b = SourceAt(level - 1, px, py - 1)
		var/d = SourceAt(level - 1, px - 1, py)
		var/e = SourceAt(level - 1, px, py)
		var/f = SourceAt(level - 1, px + 1, py)
		var/j = SourceAt(level - 1, px, py + 1)
		var/result = e
		if(pixels[b] != pixels[j] && pixels[d] != pixels[f])
			if(!(y % 2))
				if(!(x % 2) && pixels[d] == pixels[b]) result = d
				else if((x % 2) && pixels[b] == pixels[f]) result = f
			else
				if(!(x % 2) && pixels[d] == pixels[j]) result = d
				else if((x % 2) && pixels[j] == pixels[f]) result = f
		cache[i] = result
		return result

	proc/Outline(list/eligible)
		var/datum/character_rig_raster/R = Copy()
		for(var/i in eligible)
			if(pixels[i]) continue
			var/x = (i - 1) % w
			var/y = round((i - 1) / w)
			if(At(x - 1, y) || At(x + 1, y) || At(x, y - 1) || At(x, y + 1)) R.pixels[i] = "#000000ff"
		return R

	proc/ToIcon(flip = 0)
		var/icon/I = icon('Icons/CharacterRig/blank.dmi')
		for(var/y = 0, y < 32, y++)
			var/start = 0
			var/last
			for(var/x = 0, x <= 32, x++)
				var/c = x < 32 ? At(flip ? 39 - x : x + 8, y + 4) : null
				if(c == last) continue
				if(last) I.DrawBox(last, start + 1, 32 - y, x, 32 - y)
				start = x
				last = c
		return I

	proc/ToCanvas(flip = 0)
		var/icon/I = icon('Icons/CharacterRig/canvas.dmi', "", SOUTH, 1, 0)
		for(var/y = 0, y < h, y++)
			var/start = 0
			var/last
			for(var/x = 0, x <= w, x++)
				var/c = x < w ? At(flip ? w - 1 - x : x, y) : null
				if(c == last) continue
				if(last) I.DrawBox(last, start + 1, h - y, x, h - y)
				start = x
				last = c
		return I

/proc/CharacterRigReadIcon(source, state = "", direction = SOUTH, frame = 1, dx = 0, dy = 0, flip = 0, moving = 0)
	var/datum/character_rig_raster/R = new
	if(!source) return R
	var/icon/I = icon(source, state, direction, frame, moving)
	if(!length(icon_states(I)))
		I = icon(source, state, direction, 1, moving)
		if(!length(icon_states(I))) I = icon(source, state, direction, 1, !moving)
		if(!length(icon_states(I)) && direction != SOUTH && !length(icon_states(icon(source, state, direction))))
			I = icon(source, state, SOUTH, frame, moving)
			if(!length(icon_states(I))) I = icon(source, state, SOUTH, 1, moving)
			if(!length(icon_states(I))) I = icon(source, state, SOUTH, 1, !moving)
	var/width = I.Width()
	var/height = I.Height()
	for(var/y = 0, y < 32, y++)
		for(var/x = 0, x < 32, x++)
			var/sx = (flip ? 31 - x : x) - dx
			var/sy = y + dy
			if(sx < 0 || sy < 0 || sx >= width || sy >= height) continue
			var/c = lowertext(I.GetPixel(sx + 1, height - sy))
			if(!c) continue
			if(length(c) == 7) c += "ff"
			if(copytext(c, 8, 10) == "00") continue
			R.Put(x, y, c)
	return R

/proc/CharacterRigWarp(datum/character_rig_raster/source, list/mapping)
	var/datum/character_rig_raster/R = new(48, 40)
	for(var/list/pair in mapping)
		var/i = pair[2] - 1
		R.pixels[pair[1]] = source.pixels[source.SourceAt(3, i % 256, round(i / 256))]
	return R

/proc/CharacterRigGather(datum/character_rig_raster/source, list/mapping)
	var/datum/character_rig_raster/R = new(48, 40)
	R.uv = new/list(48 * 40)
	for(var/list/pair in mapping)
		var/destination = pair[1]
		for(var/k = 2, k <= pair.len, k++)
			var/i = pair[k] - 1
			var/u = source.SourceAt(3, i % 256, round(i / 256))
			var/c = source.pixels[u]
			if(!c) continue
			R.pixels[destination] = c
			R.uv[destination] = u
			break
	return R

/proc/CharacterRigComposite(list/layers)
	var/datum/character_rig_raster/R = new(48, 40)
	for(var/datum/character_rig_raster/layer in layers) R.Over(layer)
	return R
