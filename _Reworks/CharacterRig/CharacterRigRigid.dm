/proc/CharacterRigHelmet(datum/character_rig_raster/source)
	var/datum/character_rig_raster/upper = source.Copy()
	var/seeds = 0
	for(var/y = 0, y < 32, y++)
		for(var/x = 0, x < 32, x++)
			if(y >= 16) upper.Put(x, y, null)
			else if(y <= 11 && source.At(x, y)) seeds++
	var/list/result = list()
	if(seeds < 3) return result
	for(var/list/component in CharacterRigComponents(upper))
		var/eligible = 0
		for(var/i in component)
			if(i <= 384) eligible = 1
		if(eligible) result += component
	return result

/proc/CharacterRigPercentile(list/values, fraction)
	var/list/ordered = list()
	for(var/value in values)
		var/position = 1
		while(position <= ordered.len && ordered[position] <= value) position++
		ordered.Insert(position, value)
	if(!ordered.len) return 0
	var/position = (ordered.len - 1) * fraction
	var/before = round(position) + 1
	var/after = min(before + 1, ordered.len)
	return ordered[before] + (ordered[after] - ordered[before]) * (position - round(position))

/proc/CharacterRigShoulder(datum/character_rig_raster/source)
	var/datum/character_rig_raster/upper = source.Copy()
	var/reach = 0
	for(var/y = 0, y < 32, y++)
		for(var/x = 0, x < 32, x++)
			if(y >= 20) upper.Put(x, y, null)
			else if(x < 11.5 && y >= 14 && source.At(x, y) && source.At(x, y) != "#000000ff") reach++
	var/list/result = list()
	if(reach < 2) return result
	for(var/list/component in CharacterRigComponents(upper))
		var/eligible = 0
		for(var/i in component)
			var/x = (i - 1) % 32
			var/y = round((i - 1) / 32)
			if(x < 11.5 && y >= 14) eligible = 1
		if(eligible) result += component
	return result

/proc/CharacterRigKnee(datum/character_rig_raster/source)
	var/list/zone = list()
	var/list/values = list()
	for(var/y = 26, y < 28, y++)
		for(var/x = 0, x < 32, x++)
			var/c = source.At(x, y)
			if(!c) continue
			var/list/rgb = rgb2num(c)
			zone += 1 + x + y * 32
			values += max(rgb[1], rgb[2], rgb[3])
	if(zone.len < 8) return list()
	var/threshold = CharacterRigPercentile(values, 0.25) + 80
	var/count = 0
	for(var/value in values)
		if(value >= threshold) count++
	return count >= 3 ? zone : list()

/proc/CharacterRigUnderlay(datum/character_rig_raster/source, list/patch, list/eligible)
	var/datum/character_rig_raster/R = source.Copy()
	var/list/donors = list()
	var/list/colored = list()
	var/list/values = list()
	for(var/x = 0, x < 32, x++)
		for(var/y = 0, y < 32, y++)
			var/i = 1 + x + y * 32
			var/c = source.pixels[i]
			if(!c || (i in patch)) continue
			donors += i
			if(c == "#000000ff") continue
			var/list/rgb = rgb2num(c)
			colored += i
			values += max(rgb[1], rgb[2], rgb[3])
	if(colored.len)
		var/threshold = CharacterRigPercentile(values, 0.6)
		donors = list()
		for(var/j = 1, j <= colored.len, j++)
			if(values[j] <= threshold) donors += colored[j]
	for(var/i in patch)
		R.pixels[i] = null
		if(eligible && !(i in eligible)) continue
		var/best = 100000
		var/x = (i - 1) % 32
		var/y = round((i - 1) / 32)
		for(var/j in donors)
			var/distance = (x - (j - 1) % 32) ** 2 + (y - round((j - 1) / 32)) ** 2
			if(distance < best)
				best = distance
				R.pixels[i] = source.pixels[j]
	return R

/proc/CharacterRigAssignment(list/costs, columns)
	var/rows = costs.len
	var/list/u = new/list(rows + 1)
	var/list/v = new/list(columns + 1)
	var/list/matched = new/list(columns + 1)
	var/list/from = new/list(columns + 1)
	for(var/row = 1, row <= rows, row++)
		matched[1] = row
		var/column = 1
		var/list/distance = new/list(columns + 1)
		var/list/visited = new/list(columns + 1)
		for(var/j = 2, j <= columns + 1, j++) distance[j] = 100000000
		while(1)
			visited[column] = 1
			var/current = matched[column]
			var/list/cost = costs[current]
			var/delta = 100000000
			var/next = 0
			for(var/j = columns + 1, j >= 2, j--)
				if(visited[j]) continue
				var/value = cost[j - 1] - u[current + 1] - v[j]
				if(value < distance[j])
					distance[j] = value
					from[j] = column
				if(distance[j] < delta || (distance[j] == delta && !matched[j]))
					delta = distance[j]
					next = j
			for(var/j = 1, j <= columns + 1, j++)
				if(visited[j])
					u[matched[j] + 1] += delta
					v[j] -= delta
				else distance[j] -= delta
			column = next
			if(!matched[column]) break
		while(column != 1)
			var/previous = from[column]
			matched[column] = matched[previous]
			column = previous
	var/list/result = new/list(rows)
	for(var/j = 2, j <= columns + 1, j++)
		if(matched[j]) result[matched[j]] = j - 1
	return result

/proc/CharacterRigRigid(datum/character_rig_raster/source, list/pivot, list/target, angle)
	var/datum/character_rig_raster/R = new(48, 40)
	var/list/points = list()
	var/list/colors = list()
	var/min_x = 1000
	var/min_y = 1000
	var/max_x = -1000
	var/max_y = -1000
	var/cc = cos(angle)
	var/ss = sin(angle)
	for(var/y = 0, y < 32, y++)
		for(var/x = 0, x < 32, x++)
			if(!source.At(x, y)) continue
			var/tx = (x - pivot[1]) * cc - (y - pivot[2]) * ss + target[1]
			var/ty = (x - pivot[1]) * ss + (y - pivot[2]) * cc + target[2]
			points += list(list(tx, ty))
			colors += source.At(x, y)
			min_x = min(min_x, tx)
			max_x = max(max_x, tx)
			min_y = min(min_y, ty)
			max_y = max(max_y, ty)
	if(!points.len) return R
	var/list/candidates = list()
	for(var/y = max(0, round(min_y - 1)), y <= min(39, -round(-max_y - 1)), y++)
		for(var/x = max(0, round(min_x - 1)), x <= min(47, -round(-max_x - 1)), x++) candidates += 1 + x + y * 48
	var/list/costs = list()
	for(var/list/point in points)
		var/list/cost = list()
		for(var/i in candidates) cost += (point[1] - (i - 1) % 48) ** 2 + (point[2] - round((i - 1) / 48)) ** 2
		costs += list(cost)
	var/list/assignment = CharacterRigAssignment(costs, candidates.len)
	for(var/i = 1, i <= assignment.len, i++) R.pixels[candidates[assignment[i]]] = colors[i]
	return R
