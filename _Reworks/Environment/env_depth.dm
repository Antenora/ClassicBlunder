globalTracker
	var/tmp
		CLOUD_SHADOWS = TRUE //master switch
		CLOUD_ALPHA = 110 //peak shadow opacity; the relay applies it once so overlaps read as one flat shade
		CLOUD_COUNT = 4 //density; 4 = about half of sky sectors hold a bank
		CLOUD_DRIFT_X = 4 //world pixels/sec; +x = east
		CLOUD_DRIFT_Y = 1.2 //world pixels/sec; +y = north

#define CLOUD_PLANE 13 //banks render opaque here; master flattens, relay applies the one alpha
#define CLOUD_INTERVAL 5 //ds between drift ticks
#define CLOUD_ACTIVE_MARGIN 7 //tiles beyond the rendered view used for spawning
#define CLOUD_KEEP_MARGIN 13 //tiles beyond the view before an unused bank can retire
#define CLOUD_IDLE_LIFETIME 50 //ds offscreen before a bank is released
#define CLOUD_FADE_TIME 20 //ds for a newly seeded bank to reach its intended opacity
#define CLOUD_TILE_SOURCE_SIZE 16
#define CLOUD_CHUNK_SIZE 96 //small client-safe pieces cut from the seamless server composite
#define CLOUD_SECTOR_TILES 64 //shared activation grid; comfortably larger than the widest supported half-view

var/list/_cloud_tiles = list() //all 24 original 16px source cells, sliced once at boot
var/icon/_cloud_round_stamp 
var/list/_cloud_banks = list() 
var/list/_cloud_sector_banks = list() 

proc/GfxCloudChunkCount()
	var/count = 0
	for(var/obj/cloud_shadow_bank/C in _cloud_banks)
		if(islist(C.chunk_objs)) count += C.chunk_objs.len
	return count

/obj/cloud_shadow_chunk
	icon = 'Icons/BLANK.dmi'
	icon_state = "N"
	mouse_opacity = 0
	density = 0
	plane = CLOUD_PLANE //opaque gray; the master captures it, the relay shows it
	layer = 6.45
	Savable = 0 //no PIXEL_SCALE - the drift transform must render bilinear, not snap
	gfx_transient_visual = 1
	var/tmp
		off_x = 0 //piece's pixel offset from the bank center
		off_y = 0
		oc_x = 0 //piece-center offset from the bank center
		oc_y = 0
		pxo = 0 //overlay centering offsets so transforms pivot at the piece center
		pyo = 0

/obj/cloud_shadow_bank
	//logical tracker only: never rendered or placed in vis_contents; its chunk objects are
	mouse_opacity = 0
	density = 0
	Savable = 0
	var/tmp
		wx = 0 //bank-center world pixel position
		wy = 0
		zlevel = 0
		radius_px = 0 //half of the longest assembled side; used for offscreen retention
		born_at = 0
		last_seen = 0
		sector_key
		turf/anchor //turf whose vis_contents currently hosts this bank's chunk objects
		list/chunk_objs //the /obj/cloud_shadow_chunk pieces

//overlaps never darken
/obj/cloud_plane_master
	plane = CLOUD_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*cloudshadow"

/obj/cloud_relay
	screen_loc = "SOUTHWEST" //516: render_source anchors bottom-left, matching the master
	layer = 6.45 //below the 6.5 day/night blanket
	plane = 0
	mouse_opacity = 0
	alpha = 0 //raised to the daylight-scaled shadow strength each tick; 0 = night/off
	render_source = "*cloudshadow"

client
	var/tmp
		obj/cloud_plane_master/cloud_plane_master
		obj/cloud_relay/cloud_relay

var/_env_cloud_boot = _EnvCloudBoot()

proc/_EnvCloudBoot()
	_EnvCloudSliceAutotile()
	spawn(80)
		_EnvCloudLoop()
	return 1

proc/_EnvCloudSliceAutotile()
	_cloud_tiles = list()
	_cloud_round_stamp = null
	var/icon/source = icon('Icons/Effects/weather_cloud_autotile.png')
	var/source_h = source.Height()
	for(var/row = 0, row < 8, row++)
		for(var/col = 0, col < 3, col++)
			var/y2 = source_h - row * CLOUD_TILE_SOURCE_SIZE //PNG rows are top-to-bottom
			var/y1 = y2 - CLOUD_TILE_SOURCE_SIZE + 1
			var/x1 = col * CLOUD_TILE_SOURCE_SIZE + 1
			var/x2 = x1 + CLOUD_TILE_SOURCE_SIZE - 1
			var/icon/tile = icon(source)
			tile.Crop(x1, y1, x2, y2)
			_cloud_tiles["[row],[col]"] = tile
	var/icon/stamp = icon('BLANK.dmi')
	stamp.Scale(48, 48)
	stamp.DrawBox(null, 1, 1, 48, 48)
	for(var/row = 0, row < 3, row++)
		for(var/col = 0, col < 3, col++)
			stamp.Blend(_cloud_tiles["[row + 3],[col]"], ICON_OVERLAY, col * 16 + 1, (2 - row) * 16 + 1)
	_cloud_round_stamp = stamp

proc/_EnvCloudLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.CLOUD_SHADOWS && _cloud_tiles.len && _cloud_round_stamp)
			var/list/outdoor_players = _EnvCloudOutdoorPlayers()
			_EnvCloudPopulate(outdoor_players)
			_EnvCloudDrift(outdoor_players)
			_EnvCloudUpdateRelays(clamp((1 - DnDarknessFrac() - 0.35) / 0.65, 0, 1))
		else if(_cloud_banks.len)
			_EnvCloudStrip()
			_EnvCloudUpdateRelays(0)
		sleep(CLOUD_INTERVAL)

proc/_EnvCloudEnsureClient(client/C)
	if(!C) return
	if(!C.cloud_plane_master)
		C.cloud_plane_master = new()
		C.screen += C.cloud_plane_master
	if(!C.cloud_relay)
		C.cloud_relay = new()
		C.screen += C.cloud_relay

//the one place cloud translucency is set; the chunks themselves stay opaque
proc/_EnvCloudUpdateRelays(daylight)
	for(var/client/C)
		var/Options/P = C ? C.prefs : null
		if(!istype(P, /Options)) continue
		_EnvCloudEnsureClient(C)
		var/a = round(glob.CLOUD_ALPHA * clamp(daylight, 0, 1) * GfxCloudFactor(C))
		if(C.cloud_relay && C.cloud_relay.alpha != a)
			animate(C.cloud_relay, alpha = a, time = CLOUD_INTERVAL, flags = ANIMATION_END_NOW)

proc/_EnvCloudOutdoorPlayers()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/turf/T = get_turf(P)
		var/area/A = T ? T.loc : null
		if(T && A && A.sees_sky)
			out += P
	return out

//sector keys own the banks, so overlapping views always see the same clouds in the same spots
proc/_EnvCloudPopulate(list/outdoor_players)
	for(var/mob/Players/P in outdoor_players)
		var/half = (ClientViewRange(P.client) + CLOUD_ACTIVE_MARGIN) * world.icon_size
		var/pwx = P.x * world.icon_size + P.step_x
		var/pwy = P.y * world.icon_size + P.step_y
		var/sector_px = CLOUD_SECTOR_TILES * world.icon_size
		var/cx = floor((pwx - 1) / sector_px)
		var/cy = floor((pwy - 1) / sector_px)
		var/max_sx = floor((world.maxx * world.icon_size - 1) / sector_px)
		var/max_sy = floor((world.maxy * world.icon_size - 1) / sector_px)
		var/radius = max(1, ceil(half / sector_px))
		for(var/sx = cx - radius, sx <= cx + radius, sx++)
			for(var/sy = cy - radius, sy <= cy + radius, sy++)
				if(sx < 0 || sy < 0 || sx > max_sx || sy > max_sy) continue
				var/key = "[P.z]:[sx]:[sy]"
				var/obj/cloud_shadow_bank/existing = _cloud_sector_banks[key]
				if(existing)
					existing.last_seen = world.time
					continue
				_EnvCloudSpawnSector(sx, sy, P.z, key)

proc/_EnvCloudSectorNoise(sx, sy, zlevel, salt)
	var/v = abs(sin((sx * 73 + sy * 151 + zlevel * 199 + salt * 251) * 1.37) * 43758.5453)
	return v - floor(v)

proc/_EnvCloudSpawnSector(sx, sy, zlevel, sector_key)
	var/density = clamp(glob.CLOUD_COUNT * 0.12, 0.12, 0.84)
	if(_EnvCloudSectorNoise(sx, sy, zlevel, 1) > density) return 0
	var/sector_px = CLOUD_SECTOR_TILES * world.icon_size
	var/wx
	var/wy
	var/turf/T
	//probe deterministic points until one lands in an outdoor area
	for(var/probe = 2, probe <= 13, probe++)
		wx = round((sx + 0.08 + _EnvCloudSectorNoise(sx, sy, zlevel, probe) * 0.84) * sector_px)
		wy = round((sy + 0.08 + _EnvCloudSectorNoise(sx, sy, zlevel, probe + 20) * 0.84) * sector_px)
		var/tx = clamp(round(wx / world.icon_size), 1, world.maxx)
		var/ty = clamp(round(wy / world.icon_size), 1, world.maxy)
		T = locate(tx, ty, zlevel)
		var/area/A = T ? T.loc : null
		if(A && A.sees_sky) break
		T = null
	if(!T) return 0
	var/obj/cloud_shadow_bank/C = new()
	C.wx = wx
	C.wy = wy
	C.zlevel = zlevel
	C.born_at = world.time
	C.last_seen = world.time
	C.sector_key = sector_key
	_EnvCloudBuildBank(C)
	_cloud_banks += C
	_cloud_sector_banks[sector_key] = C
	_EnvCloudPlace(C, wx, wy, TRUE)
	return 1

//build the bank shape, then cut it into client-safe 96x96 pieces
proc/_EnvCloudBuildBank(obj/cloud_shadow_bank/C)
	var/bank_w
	var/bank_h
	var/family = rand(1, 100)
	if(family <= 20) //small puff
		bank_w = rand(78, 116)
		bank_h = rand(68, 96)
	else if(family <= 48) //compact, nearly round bank
		bank_w = rand(112, 164)
		bank_h = rand(96, 142)
	else if(family <= 78) //broad, heavy cloud cover
		bank_w = rand(168, 238)
		bank_h = rand(132, 180)
	else //occasional long bank
		bank_w = rand(224, 304)
		bank_h = rand(82, 116)
	var/list/stamp_pos = list()
	var/step = rand(18, 21)
	var/usable_w = bank_w - 48
	var/columns = max(2, ceil(usable_w / step) + 1)
	var/center_y = bank_h / 2
	var/center_shift = 0
	var/height_scale = rand(94, 104) / 100
	for(var/i = 0, i < columns, i++)
		var/t = i / (columns - 1)
		center_shift = clamp(center_shift + rand(-2, 2), -5, 5)
		height_scale = clamp(height_scale + rand(-4, 4) / 100, 0.88, 1.10)
		var/x = round(t * usable_w)
		var/half_height = max(0, (bank_h - 48) / 2 * sin(180 * t) * height_scale)
		var/rows = max(1, ceil(2 * half_height / step) + 1)
		for(var/j = 0, j < rows, j++)
			var/y_center = center_y + center_shift
			if(rows > 1)
				y_center += -half_height + j * (2 * half_height / (rows - 1))
			var/px = clamp(round(x + rand(-2, 2)), 0, bank_w - 48)
			var/py = clamp(round(y_center - 24 + rand(-2, 2)), 0, bank_h - 48)
			stamp_pos += list(list(px, py))
	C.chunk_objs = list()
	for(var/chunk_x = 1, chunk_x <= bank_w, chunk_x += CLOUD_CHUNK_SIZE)
		for(var/chunk_y = 1, chunk_y <= bank_h, chunk_y += CLOUD_CHUNK_SIZE)
			var/cw = min(bank_w, chunk_x + CLOUD_CHUNK_SIZE - 1) - chunk_x + 1
			var/chh = min(bank_h, chunk_y + CLOUD_CHUNK_SIZE - 1) - chunk_y + 1
			var/icon/chunk = icon('Icons/BLANK.dmi')
			chunk.Scale(cw, chh)
			chunk.DrawBox(null, 1, 1, cw, chh)
			var/any = 0
			for(var/list/sp in stamp_pos)
				//stamp occupies [sp+1 .. sp+48] (1-based) in bank space; overlap this cell?
				if(sp[1] + 48 >= chunk_x && sp[1] + 1 <= chunk_x + cw - 1 && sp[2] + 48 >= chunk_y && sp[2] + 1 <= chunk_y + chh - 1)
					//ICON_OVERLAY not ICON_OR - OR adds color on overlap and builds a purple core
					chunk.Blend(_cloud_round_stamp, ICON_OVERLAY, sp[1] + 2 - chunk_x, sp[2] + 2 - chunk_y)
					any = 1
			if(!any) continue //empty cell - no object needed
			//threshold the alpha flat and recolor to one gray - the relay adds the translucency later
			chunk.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 46 / 255, 44 / 255, 54 / 255, 0)
			var/obj/cloud_shadow_chunk/co = new()
			var/image/piece = image(icon = chunk, layer = FLOAT_LAYER)
			piece.plane = CLOUD_PLANE //force the overlay onto the cloud plane so the master captures it - don't rely on inherit
			piece.pixel_x = round((32 - cw) / 2) //center the piece on the 32px base so transforms pivot at its center
			piece.pixel_y = round((32 - chh) / 2)
			co.overlays = list(piece)
			co.pxo = piece.pixel_x
			co.pyo = piece.pixel_y
			co.off_x = chunk_x - 1 - round(bank_w / 2)
			co.off_y = chunk_y - 1 - round(bank_h / 2)
			co.oc_x = co.off_x + cw / 2
			co.oc_y = co.off_y + chh / 2
			C.chunk_objs += co
	C.radius_px = round(max(bank_w, bank_h) / 2)

proc/_EnvCloudDrift(list/outdoor_players)
	var/list/copy = _cloud_banks.Copy()
	for(var/obj/cloud_shadow_bank/C in copy)
		var/area/A = C.anchor ? C.anchor.loc : null
		var/list/W = EnvWindForArea(A)
		var/dpx = (isnum(W[1]) ? W[1] : glob.CLOUD_DRIFT_X) * CLOUD_INTERVAL / 10
		var/dpy = (isnum(W[2]) ? W[2] : glob.CLOUD_DRIFT_Y) * CLOUD_INTERVAL / 10
		var/pre_wx = C.wx
		var/pre_wy = C.wy
		C.wx += dpx
		C.wy += dpy
		var/near_player = 0
		for(var/mob/Players/P in outdoor_players)
			if(P.z != C.zlevel) continue
			var/keep = (ClientViewRange(P.client) + CLOUD_KEEP_MARGIN) * world.icon_size + C.radius_px
			var/pwx = P.x * world.icon_size + P.step_x
			var/pwy = P.y * world.icon_size + P.step_y
			if(max(abs(C.wx - pwx), abs(C.wy - pwy)) <= keep)
				near_player = 1
				C.last_seen = world.time
				break
		if(!near_player && world.time - C.last_seen >= CLOUD_IDLE_LIFETIME)
			_EnvCloudRemove(C)
			continue
		//no per-chunk alpha here - that road leads straight back to overlap darkening
		if(!_EnvCloudPlace(C, pre_wx, pre_wy, FALSE))
			_EnvCloudRemove(C) //left the map; a new upwind bank will replace it near active views

//motion rides in each chunk's transform; integer pixel_x steps make the drift visibly tick
proc/_EnvCloudPlace(obj/cloud_shadow_bank/C, pre_wx, pre_wy, snap)
	if(!C.chunk_objs) return 0
	var/tx = round(C.wx / world.icon_size)
	var/ty = round(C.wy / world.icon_size)
	var/turf/T = locate(tx, ty, C.zlevel)
	if(!T) return 0
	var/bx = C.wx - tx * world.icon_size
	var/by = C.wy - ty * world.icon_size
	var/reanchor = (C.anchor != T)
	if(reanchor) //move every piece to the new host turf's vis_contents together
		if(C.anchor)
			for(var/obj/cloud_shadow_chunk/co in C.chunk_objs) C.anchor.vis_contents -= co
		for(var/obj/cloud_shadow_chunk/co in C.chunk_objs) T.vis_contents += co
		C.anchor = T
	for(var/obj/cloud_shadow_chunk/co in C.chunk_objs)
		if(snap || reanchor)
			var/pbx = snap ? bx : pre_wx - tx * world.icon_size //tile cross: land the piece exactly where it stood
			var/pby = snap ? by : pre_wy - ty * world.icon_size
			co.pixel_x = round(pbx + co.off_x - co.pxo)
			co.pixel_y = round(pby + co.off_y - co.pyo)
			co.transform = matrix(1, 0, pbx + co.oc_x - (co.pixel_x + 16), 0, 1, pby + co.oc_y - (co.pixel_y + 16))
			if(snap) continue
		//END_NOW or queued animations pile up server-side and starve networking
		animate(co, transform = matrix(1, 0, bx + co.oc_x - (co.pixel_x + 16), 0, 1, by + co.oc_y - (co.pixel_y + 16)), time = CLOUD_INTERVAL, flags = ANIMATION_END_NOW | ANIMATION_LINEAR_TRANSFORM)
	return 1

proc/_EnvCloudRemove(obj/cloud_shadow_bank/C)
	if(!C) return
	if(C.chunk_objs)
		for(var/obj/cloud_shadow_chunk/co in C.chunk_objs)
			if(C.anchor) C.anchor.vis_contents -= co
			animate(co, flags = ANIMATION_END_NOW)
			co.overlays = null
			co.transform = null
			co.loc = null
		C.chunk_objs = null
	C.anchor = null
	_cloud_banks -= C
	if(C.sector_key && _cloud_sector_banks[C.sector_key] == C)
		_cloud_sector_banks -= C.sector_key
	C.loc = null

proc/_EnvCloudStrip()
	for(var/obj/cloud_shadow_bank/C in _cloud_banks.Copy())
		_EnvCloudRemove(C)
	_cloud_banks.Cut()
	_cloud_sector_banks.Cut()

/mob/Admin2/verb/Cloud_Shadows_Toggle()
	set category = "Admin"
	set name = "Cloud Shadows Toggle"
	glob.CLOUD_SHADOWS = !glob.CLOUD_SHADOWS
	if(!glob.CLOUD_SHADOWS)
		_EnvCloudStrip()
		_EnvCloudUpdateRelays(0)
	src << "Cloud shadows: [glob.CLOUD_SHADOWS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set cloud shadows to [glob.CLOUD_SHADOWS].")
