var/global/list/character_rig_queue = list()
var/global/character_rig_building = 0
var/global/list/character_rig_shared = list()
var/global/list/character_rig_recency = list()

/obj/character_rig_visual
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	gfx_transient_visual = 1
	pixel_x = -16
	pixel_y = -12

/proc/CharacterRigFamily(source)
	return source in list('Icons/base/default/frisky-male_black_brown.dmi', 'Icons/base/default/frisky-male_dark_brown.dmi', 'Icons/base/default/frisky-male_pale_brown.dmi', 'Icons/base/default/frisky-male_tan_brown.dmi', 'Icons/base/default/frisky-male_white_brown.dmi')

/proc/CharacterRigQueue()
	set waitfor = 0
	if(character_rig_building) return
	character_rig_building = 1
	while(character_rig_queue.len)
		var/mob/M = character_rig_queue[1]
		character_rig_queue.Cut(1, 2)
		if(M && M.CharacterRigEligible()) M.CharacterRigBuild()
		sleep(world.tick_lag)
	character_rig_building = 0

/obj/Items/var/CharacterRigType = "Auto"

/obj/Items/proc/CharacterRigBehavior()
	if(CharacterRigType != "Auto") return CharacterRigType
	if(IsHat) return "Head"
	if(istype(src, /obj/Items/Armor)) return "Rigid armor"
	if(!istype(src, /obj/Items/Wearables)) return "Unchanged"
	var/source = EquipIcon ? EquipIcon : icon
	if(!length("[source]")) source = initial(EquipIcon) ? initial(EquipIcon) : initial(icon)
	if(source == 'Icons/Clothes/ClothesCloak.dmi') return "Covering cloak"
	if(source == 'Icons/NSE/Icons/Dove_-_Cloak.dmi') return "Back cloak"
	var/name = lowertext("[source]")
	if(findtext(name, "trench") || findtext(name, "coat")) return "Coat"
	if(findtext(name, "cloak") || findtext(name, "cape")) return "Back cloak"
	return "Fitted"

/obj/Items/verb/Animation_Behavior()
	set name = "Animation Behavior"
	set src in usr.contents
	var/choice = input(usr, "Choose how this clothing moves with a modular base.", "Animation Behavior", CharacterRigType) as null|anything in list("Auto", "Fitted", "Rigid armor", "Coat", "Back cloak", "Covering cloak", "Head", "Unchanged")
	if(!choice || !(src in usr.contents)) return
	CharacterRigType = choice
	usr.CharacterRigInvalidate()

/datum/character_rig_layer
	var/image/appearance_source
	var/behavior
	var/under = 0

	proc/Sample(direction, flip = 0)
		var/image/A = appearance_source
		var/datum/character_rig_raster/R = CharacterRigReadIcon(A.icon, A.icon_state, direction, 1, A.pixel_x, A.pixel_y, flip)
		if(A.color || A.alpha != 255)
			for(var/i = 1, i <= R.pixels.len, i++)
				if(!R.pixels[i]) continue
				var/list/c = rgb2num(R.pixels[i])
				if(istext(A.color))
					var/list/tint = rgb2num(A.color)
					for(var/k = 1, k <= 3, k++) c[k] = round(c[k] * tint[k] / 255)
					if(tint.len >= 4) c[4] = c[4] * tint[4] / 255
				var/opacity = round(c[4] * A.alpha / 255)
				R.pixels[i] = opacity ? lowertext(rgb(c[1], c[2], c[3], opacity)) : null
				if(length(R.pixels[i]) == 7) R.pixels[i] += "ff"
		return R

/datum/character_rig_cache
	var/source
	var/list/layers = list()
	var/list/frames = list()
	var/list/durations = list()
	var/list/presented = list()
	var/list/clips = list()
	var/valid = 1
	var/rejection_reason

	proc/Timeline(motion, direction)
		var/list/geometry = CharacterRigGeometry()
		var/list/timelines = geometry["timelines"]
		var/name = direction == NORTH ? "north" : direction == SOUTH ? "south" : direction == WEST ? "west" : "east"
		return timelines["[name]-[motion]"]

	proc/Presented(motion, n)
		var/key = "[motion]-[n]"
		if(presented[key]) return presented[key]
		var/list/sequence = frames[motion]
		var/icon/result = icon('Icons/CharacterRig/playback.dmi')
		for(var/direction in list(SOUTH, NORTH, EAST, WEST))
			var/list/timeline = Timeline(motion, direction)
			var/list/travel = timeline["travel"]
			var/icon/frame = icon('Icons/CharacterRig/playback.dmi', "", SOUTH, 1, 0)
			frame.Blend(icon(sequence[n], "", direction, 1, 0), ICON_OVERLAY, 9, 9 - travel[n])
			result.Insert(frame, "", direction, 1, 0)
		presented[key] = result
		return result

	proc/Clip(motion, direction, preview)
		var/key = "[motion]-[direction]-[preview]"
		if(clips[key]) return clips[key]
		var/list/timeline = Timeline(motion, direction)
		var/list/order = timeline["order"]
		var/list/delays = timeline["delays"]
		var/first = motion == "dash" && !preview ? 2 : 1
		var/last = motion == "dash" && !preview ? 6 : order.len
		var/icon/result = icon('Icons/CharacterRig/playback.dmi')
		var/total = 0
		for(var/n = first, n <= last, n++)
			result.Insert(Presented(motion, order[n]), "", frame = n - first + 1, moving = 0, delay = delays[n])
			if((n - first + 1) % 16 == 0) result = icon(fcopy_rsc(result))
			total += delays[n]
		var/list/clip = list(result, total, Presented(motion, order[last]))
		clips[key] = clip
		return clip

	proc/Key()
		var/list/values = list(md5(fcopy_rsc(source)))
		for(var/datum/character_rig_layer/L in layers)
			var/image/A = L.appearance_source
			values += "[md5(fcopy_rsc(A.icon))]|[A.icon_state]|[A.pixel_x]|[A.pixel_y]|[A.color]|[A.alpha]|[A.layer]|[L.behavior]|[L.under]"
		return md5(jointext(values, ";"))

	proc/Capture(mob/M)
		source = M.icon
		for(var/under in list(1, 0))
			var/list/appearances = under ? M.underlays : M.overlays
			for(var/entry in appearances)
				var/image/A = entry
				if(!A.icon) continue
				var/behavior
				var/layer_name
				for(var/obj/Items/I in M)
					if(!findtext(I.suffix, "Equipped")) continue
					var/expected = under ? I.UnderlayIcon : (I.EquipIcon ? I.EquipIcon : I.icon)
					if(expected && A.icon == expected)
						behavior = I.CharacterRigBehavior()
						layer_name = I.name
						break
				if(!behavior && A.layer == FLOAT_LAYER - 2)
					behavior = "Head"
					layer_name = under ? "the hair/head underlay" : "the hair/head overlay"
				if(!behavior || behavior == "Unchanged") continue
				var/icon/check = icon(A.icon)
				if(!check.Width() || !check.Height()) continue
				var/matrix/T = A.transform
				var/list/issues = list()
				if(check.Width() != 32 || check.Height() != 32) issues += "a [check.Width()]x[check.Height()] image instead of 32x32"
				if(islist(A.color)) issues += "a color matrix"
				if(length(A.filters)) issues += "image filters"
				if(T && (T.a != 1 || T.b || T.c || T.d || T.e != 1 || T.f)) issues += "a scaled, rotated, or shifted image"
				if(issues.len)
					valid = 0
					rejection_reason = "[layer_name] uses [jointext(issues, ", ")]"
					return
				var/datum/character_rig_layer/L = new
				L.appearance_source = A
				L.behavior = behavior
				L.under = under
				var/position = 1
				while(position <= layers.len)
					var/datum/character_rig_layer/previous = layers[position]
					if(previous.under < under || (previous.under == under && previous.appearance_source.layer > A.layer)) break
					position++
				layers.Insert(position, L)

	proc/Textures(direction, flip = 0)
		var/list/groups = list()
		for(var/name in list("Fitted", "Rigid", "Coat", "Covering cloak", "Back cloak", "Head")) groups[name] = new /datum/character_rig_raster
		for(var/datum/character_rig_layer/L in layers)
			var/name = L.behavior
			if(name == "Rigid armor")
				name = "Fitted"
			var/datum/character_rig_raster/R = groups[name]
			if(!R) continue
			var/datum/character_rig_raster/texture = L.Sample(direction, flip)
			R.Over(texture)
			var/datum/character_rig_raster/rigid = groups["Rigid"]
			if(L.behavior == "Rigid armor") rigid.Over(texture)
			else if(name == "Fitted")
				for(var/i = 1, i <= 1024, i++)
					if(texture.pixels[i]) rigid.pixels[i] = null
		for(var/name in groups)
			if(!CharacterRigBounds(groups[name])) groups[name] = null
		return groups

	proc/Build(mob/M, generation)
		var/list/geometry = CharacterRigGeometry()
		var/list/ns_poses = geometry["poses"]
		var/list/side = geometry["side"]
		var/list/side_poses = side["poses"]
		for(var/motion in list("punch", "dash", "rotation"))
			frames[motion] = list()
		for(var/direction in list(SOUTH, NORTH, EAST, WEST))
			var/is_side = direction == EAST || direction == WEST
			var/flip = direction == WEST
			var/list/groups = Textures(direction, flip)
			var/datum/character_rig_raster/B = CharacterRigReadIcon(source, "", direction, is_side ? 4 : 1, 0, 0, flip)
			var/datum/character_rig_view/V
			var/datum/character_rig_side/S
			if(is_side)
				var/list/opposite = Textures(direction == EAST ? WEST : EAST, !flip)
				var/list/front = Textures(SOUTH)
				var/datum/character_rig_raster/alternate = CharacterRigReadIcon(source, "", direction, 2, 0, 0, flip, 1)
				S = new(B, alternate, groups["Fitted"], opposite["Fitted"], front["Fitted"], groups["Coat"], groups["Covering cloak"], groups["Back cloak"], groups["Head"], opposite["Coat"], groups["Rigid"], opposite["Rigid"])
			else
				if(groups["Fitted"]) B.Over(groups["Fitted"])
				V = new(B, groups["Coat"], groups["Covering cloak"], groups["Back cloak"], groups["Head"], direction)
			var/list/timing = list()
			for(var/motion in list("punch", "dash", "rotation"))
				var/name = direction == NORTH ? "north" : "south"
				var/list/recipes = is_side ? side_poses[motion] : ns_poses["[name]-[motion]"]
				var/list/output = frames[motion]
				var/list/delays = list()
				for(var/n = 1, n <= recipes.len, n++)
					if(!M || M.character_rig_generation != generation) return 0
					var/list/recipe = recipes[n]
					var/datum/character_rig_raster/R = is_side ? S.Render(recipe) : V.Render(recipe)
					var/icon/frame = R.ToCanvas(flip)
					if(output.len < n) output += icon('Icons/CharacterRig/canvas.dmi')
					var/icon/I = icon(output[n])
					I.Insert(frame, "", direction, 1, 0)
					output[n] = I
					if(is_side) delays += recipe["duration"]
					else if(motion == "punch")
						var/list/values = list(4, 1.1, 1.2, 1.8, 0.5, 0.9, 1.1, 0.9, 1.2, 1, 4.5)
						delays += values[n]
					else if(motion == "rotation") delays += 1.2
					else
						var/list/values = list(6.5, 1, 0.8, 0.7, 0.7, 10)
						delays += values[n]
					if(world.tick_usage > 60) sleep(world.tick_lag)
				timing[motion] = delays
			durations["[direction]"] = timing
		return 1

/mob
	var/CharacterRigMode = "Auto"
	var/tmp/datum/character_rig_cache/character_rig_cache
	var/tmp/character_rig_generation = 0
	var/tmp/character_rig_token = 0
	var/tmp/character_rig_active
	var/tmp/character_rig_original_icon
	var/tmp/obj/character_rig_visual/character_rig_visual
	var/tmp/list/character_rig_hidden_overlays
	var/tmp/list/character_rig_hidden_underlays
	var/tmp/character_rig_pending = 0
	var/tmp/character_rig_state
	var/tmp/character_rig_working = 0
	var/tmp/character_rig_rejected = -1
	var/tmp/character_rig_rejection_reason

	proc/CharacterRigEligible()
		var/source = character_rig_active ? character_rig_original_icon : icon
		if(!source || CharacterRigMode == "Off") return 0
		if(CharacterRigMode != "Frisky male" && !CharacterRigFamily(source)) return 0
		var/icon/I = icon(source)
		return I.Width() == 32 && I.Height() == 32

	proc/CharacterRigInvalidate()
		CharacterRigStop()
		character_rig_generation++
		character_rig_cache = null
		character_rig_rejection_reason = null
		if(character_rig_pending) return
		character_rig_pending = 1
		spawn(1)
			if(!src) return
			character_rig_pending = 0
			if(CharacterRigEligible())
				character_rig_queue |= src
				CharacterRigQueue()

	proc/CharacterRigBuild()
		if(!CharacterRigEligible()) return
		character_rig_working = 1
		CharacterRigStop()
		var/generation = character_rig_generation
		var/datum/character_rig_cache/C = new
		C.Capture(src)
		if(!C.valid)
			character_rig_rejected = generation
			character_rig_rejection_reason = C.rejection_reason
			character_rig_working = 0
			return
		character_rig_rejection_reason = null
		var/key = C.Key()
		var/list/shared = character_rig_shared[key]
		if(shared)
			C.frames = shared[1]
			C.durations = shared[2]
			C.presented = shared[3]
			C.clips = shared[4]
			character_rig_cache = C
			character_rig_recency -= key
			character_rig_recency += key
			character_rig_working = 0
			return
		if(C.Build(src, generation) && character_rig_generation == generation && icon == C.source)
			character_rig_cache = C
			character_rig_shared[key] = list(C.frames, C.durations, C.presented, C.clips)
			character_rig_recency -= key
			character_rig_recency += key
			while(character_rig_recency.len > 12)
				character_rig_shared -= character_rig_recency[1]
				character_rig_recency.Cut(1, 2)
		character_rig_working = 0

	proc/CharacterRigReady()
		if(!CharacterRigEligible()) return 0
		if(character_rig_rejected == character_rig_generation) return 0
		if(!character_rig_cache || character_rig_cache.source != (character_rig_active ? character_rig_original_icon : icon))
			if(!character_rig_pending && !character_rig_working && !(src in character_rig_queue)) CharacterRigInvalidate()
			return 0
		if(!character_rig_active)
			for(var/datum/character_rig_layer/L in character_rig_cache.layers)
				var/list/appearances = L.under ? underlays : overlays
				if(!(L.appearance_source in appearances))
					CharacterRigInvalidate()
					return 0
		return 1

	proc/CharacterRigStop()
		character_rig_token++
		if(!character_rig_active) return
		if(character_rig_visual)
			vis_contents -= character_rig_visual
			del character_rig_visual
		if(icon == 'Icons/CharacterRig/blank.dmi') icon = character_rig_original_icon
		if(character_rig_hidden_overlays) overlays += character_rig_hidden_overlays
		if(character_rig_hidden_underlays) underlays += character_rig_hidden_underlays
		character_rig_active = null
		character_rig_original_icon = null
		character_rig_visual = null
		character_rig_hidden_overlays = null
		character_rig_hidden_underlays = null
		character_rig_state = null

	proc/CharacterRigSaveView(original)
		if(!character_rig_active) return
		if(original)
			if(icon == 'Icons/CharacterRig/blank.dmi') icon = character_rig_original_icon
			if(character_rig_visual) vis_contents -= character_rig_visual
			if(character_rig_hidden_overlays) overlays += character_rig_hidden_overlays
			if(character_rig_hidden_underlays) underlays += character_rig_hidden_underlays
		else
			if(icon == character_rig_original_icon) icon = 'Icons/CharacterRig/blank.dmi'
			if(character_rig_hidden_overlays) overlays -= character_rig_hidden_overlays
			if(character_rig_hidden_underlays) underlays -= character_rig_hidden_underlays
			if(character_rig_visual) vis_contents += character_rig_visual

	proc/CharacterRigPlay(motion, duration = 0, preview = 0)
		if(!CharacterRigReady()) return 0
		if(!preview && motion == "punch" && character_rig_active == motion) return 1
		CharacterRigStop()
		character_rig_active = motion
		character_rig_state = icon_state
		character_rig_original_icon = icon
		character_rig_hidden_overlays = list()
		character_rig_hidden_underlays = list()
		for(var/datum/character_rig_layer/L in character_rig_cache.layers)
			if(L.under)
				character_rig_hidden_underlays += L.appearance_source
				underlays -= L.appearance_source
			else
				character_rig_hidden_overlays += L.appearance_source
				overlays -= L.appearance_source
		icon = 'Icons/CharacterRig/blank.dmi'
		if(filters["trail"]) animate(filters["trail"], x = 0, y = 0, time = 0)
		var/token = ++character_rig_token
		CharacterRigAnimate(motion, token, preview)
		return 1

	proc/CharacterRigAnimate(motion, token, preview)
		set waitfor = 0
		var/datum/character_rig_cache/C = character_rig_cache
		var/list/sequence = C.frames[motion]
		if(!sequence || !sequence.len)
			CharacterRigStop()
			return
		var/facing = dir & (EAST | WEST) ? (dir & EAST ? EAST : WEST) : (dir & NORTH ? NORTH : SOUTH)
		var/list/clip = C.Clip(motion, facing, preview)
		character_rig_visual = new
		character_rig_visual.icon = clip[3]
		character_rig_visual.dir = facing
		vis_contents += character_rig_visual
		flick(clip[1], character_rig_visual)
		var/until = world.time + clip[2]
		while(src && character_rig_token == token && icon == 'Icons/CharacterRig/blank.dmi' && icon_state == character_rig_state && ((motion == "dash" && !preview) || world.time < until)) sleep(world.tick_lag)
		if(!src) return
		if(character_rig_token == token) CharacterRigStop()

/mob/Players/verb/Modular_Animation_Settings()
	set name = "Modular Animation Settings"
	set category = "Other"
	var/choice = input(src, "Auto enables the Frisky male family. Choose Frisky male only for a custom base with matching proportions and pixel placement.", "Modular Animation", CharacterRigMode) as null|anything in list("Auto", "Frisky male", "Off")
	if(!choice) return
	CharacterRigMode = choice
	CharacterRigInvalidate()

/mob/Players/verb/Preview_Modular_Animation()
	set name = "Preview Modular Animation"
	set category = "Other"
	var/motion = input(src, "Choose an animation to preview on your current appearance.", "Modular Animation") as null|anything in list("punch", "dash", "rotation")
	if(!motion) return
	if(!CharacterRigEligible())
		src << "This base is not enabled for modular animations. Compatible custom bases can opt in through Modular Animation Settings."
		return
	if(!CharacterRigPlay(motion, 0, 1))
		if(character_rig_rejected == character_rig_generation) src << "Modular animation is unavailable because [character_rig_rejection_reason]. Its existing animations are being preserved."
		else src << "Your animation frames are being prepared. Try the preview again shortly."
