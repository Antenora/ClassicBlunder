//Pixel skill collision core.
//Hitbox data: per-skill Hitbox* overrides > BAKED_HITBOXES (hitbox_table.dm) > 32x32

obj/Skills/Projectile/var/tmp
	HitboxW = 0
	HitboxH = 0
	HitboxX = -1
	HitboxY = -1
	FireOffsetX = 0 //art+box+mask offset, world px
	FireOffsetY = 0 //rotates with the displayed facing so it stays on the same side of the flight line
obj/Skills/AutoHit/var/tmp
	HitboxW = 0
	HitboxH = 0
	HitboxX = -1
	HitboxY = -1
	FireOffsetX = 0
	FireOffsetY = 0

proc/Dir2HitboxChar(d)
	switch(d)
		if(NORTH) return "N"
		if(SOUTH) return "S"
		if(EAST) return "E"
		if(WEST) return "W"
	return null

proc/DisplayedCardinal(d, prev)
	switch(d)
		if(NORTH, SOUTH, EAST, WEST) return d
		if(SOUTHEAST)
			if(prev == SOUTH || prev == EAST) return prev
			return (prev == NORTH) ? EAST : SOUTH
		if(SOUTHWEST)
			if(prev == SOUTH || prev == WEST) return prev
			return (prev == NORTH) ? WEST : SOUTH
		if(NORTHEAST)
			if(prev == NORTH || prev == EAST) return prev
			return (prev == SOUTH) ? EAST : NORTH
		if(NORTHWEST)
			if(prev == NORTH || prev == WEST) return prev
			return (prev == SOUTH) ? WEST : NORTH
	return prev || SOUTH

proc/GetBakedHitbox(iconFile, d=0)
	if(!iconFile) return null
	var/key = lowertext("[iconFile]")
	if(d)
		var/dc = Dir2HitboxChar(d)
		if(dc)
			var/list/r = BAKED_HITBOXES["[key]:[dc]"]
			if(r) return r
	return BAKED_HITBOXES[key]

proc/BakedMaskKey(iconFile, d=0)
	if(!iconFile) return null
	var/key = lowertext("[iconFile]")
	if(d)
		var/dc = Dir2HitboxChar(d)
		if(dc && BAKED_MASKS["[key]:[dc]"]) return "[key]:[dc]"
	return BAKED_MASKS[key] ? key : null

proc/GetBakedMask(iconFile, d=0)
	var/k = BakedMaskKey(iconFile, d)
	return k ? BAKED_MASKS[k] : null

var/list/RUNTIME_MASKS
var/list/RUNTIME_RECTS
var/list/RUNTIME_FRAMES
var/list/RUNTIME_ICONKEYS //file > md5, computed once per session
var/list/RUNTIME_SCANS //md5 > 1 while a scan is in flight

#define RUNTIME_CACHE_VER 2
#define RUNTIME_FRAME_CAP 16
#define RUNTIME_STATE_CAP 8

proc/RuntimeMasksInit()
	if(RUNTIME_MASKS) return
	RUNTIME_MASKS = list()
	RUNTIME_RECTS = list()
	RUNTIME_FRAMES = list()
	RUNTIME_ICONKEYS = list()
	RUNTIME_SCANS = list()
	var/savefile/S = new("hitbox_runtime_cache.sav")
	var/ver
	S["ver"] >> ver
	if(ver != RUNTIME_CACHE_VER) return
	var/list/m
	var/list/r
	var/list/fr
	S["masks"] >> m
	S["rects"] >> r
	S["frames"] >> fr
	if(istype(m)) RUNTIME_MASKS = m
	if(istype(r)) RUNTIME_RECTS = r
	if(istype(fr)) RUNTIME_FRAMES = fr

proc/SaveRuntimeMasks()
	var/savefile/S = new("hitbox_runtime_cache.sav")
	S["ver"] << RUNTIME_CACHE_VER
	S["masks"] << RUNTIME_MASKS
	S["rects"] << RUNTIME_RECTS
	S["frames"] << RUNTIME_FRAMES

proc/GetRuntimeFrames(f, d=0)
	var/k = RuntimeIconKey(f, 0)
	if(!k) return null
	if(d)
		var/dc = Dir2HitboxChar(d)
		if(dc && RUNTIME_FRAMES["[k]:[dc]"]) return "[k]:[dc]"
	return RUNTIME_FRAMES[k] ? k : null

proc/RuntimeIconKey(f, standing = 1)
	if(!f || (!isfile(f) && !isicon(f))) return null
	RuntimeMasksInit()
	var/base = RUNTIME_ICONKEYS[f]
	if(!base)
		base = md5(f)
		if(!base) return null
		RUNTIME_ICONKEYS[f] = base
	var/k = standing ? base : "[base]!"
	if(isnull(RUNTIME_RECTS[k]) && !RUNTIME_SCANS[k]) //rect presence marks "scanned"
		RUNTIME_SCANS[k] = 1
		spawn(1) ScanIconInk(f, k, standing)
	return k

proc/GetRuntimeMask(f, d=0, standing = 1)
	var/k = RuntimeIconKey(f, standing)
	if(!k) return null
	if(d)
		var/dc = Dir2HitboxChar(d)
		if(dc)
			var/list/m = RUNTIME_MASKS["[k]:[dc]"]
			if(m) return m
	return RUNTIME_MASKS[k]

proc/GetRuntimeRect(f, d=0, standing = 1)
	var/k = RuntimeIconKey(f, standing)
	if(!k) return null
	if(d)
		var/dc = Dir2HitboxChar(d)
		if(dc)
			var/list/r = RUNTIME_RECTS["[k]:[dc]"]
			if(r) return r
	return RUNTIME_RECTS[k]

proc/IconPixelSolid(icon/I, x, y, d, st, fr)
	var/c = I.GetPixel(x, y, st, d, fr)
	if(!c) return FALSE
	if(length(c) >= 9) //"#RRGGBBAA": partial alpha reported
		return text2num(copytext(c, 8, 10), 16) >= 128
	return TRUE

proc/IconCellInk(icon/I, cx, cy, w, h, d, st, fr)
	var/x1 = min(cx*4 + 4, w)
	var/y1 = min(cy*4 + 4, h)
	for(var/y = cy*4 + 1, y <= y1, y++)
		for(var/x = cx*4 + 1, x <= x1, x++)
			if(IconPixelSolid(I, x, y, d, st, fr)) return TRUE
	return FALSE

proc/NewMaskGrid(mw, mh, packs)
	var/datalen = 3 + mh*packs
	var/list/G = new/list(datalen)
	G[1] = mw
	G[2] = mh
	G[3] = packs
	for(var/i = 4, i <= datalen, i++)
		G[i] = 0
	return G

proc/MaskGridOr(list/D, list/S)
	for(var/i = 4, i <= D.len, i++)
		D[i] |= S[i]

proc/MaskGridSame(list/A, list/B)
	for(var/i = 4, i <= A.len, i++)
		if(A[i] != B[i]) return FALSE
	return TRUE

proc/MaskGridEmpty(list/A)
	for(var/i = 4, i <= A.len, i++)
		if(A[i]) return FALSE
	return TRUE

proc/MaskFramePeriod(list/frames)
	var/n = frames.len
	for(var/p = 1, p*2 <= n, p++)
		var/ok = 1
		for(var/i = p + 1, i <= n, i++)
			if(!MaskGridSame(frames[i], frames[((i - 1) % p) + 1]))
				ok = 0
				break
		if(ok) return p
	return n

proc/MaskGridRect(list/G)
	var/mw = G[1]
	var/mh = G[2]
	var/packs = G[3]
	var/minx = mw
	var/maxx = -1
	var/miny = mh
	var/maxy = -1
	for(var/r = 0, r < mh, r++)
		for(var/c = 0, c < mw, c++)
			if(G[4 + r*packs + round(c / 24)] & (1 << (c % 24)))
				if(c < minx) minx = c
				if(c > maxx) maxx = c
				if(r < miny) miny = r
				if(r > maxy) maxy = r
	if(maxx < 0) return null
	return list(minx*4, miny*4, (maxx - minx + 1)*4, (maxy - miny + 1)*4)

proc/ScanIconGrid(icon/I, list/G, w, h, d, st, fr, list/skip)
	var/mw = G[1]
	var/mh = G[2]
	var/packs = G[3]
	for(var/cy = 0, cy < mh, cy++)
		for(var/cx = 0, cx < mw, cx++)
			var/idx = 4 + cy*packs + round(cx / 24)
			var/bit = (1 << (cx % 24))
			if(skip && (skip[idx] & bit))
				G[idx] |= bit
				continue
			if(IconCellInk(I, cx, cy, w, h, d, st, fr))
				G[idx] |= bit
		sleep(-1)

proc/ScanIconInk(f, k, standing = 1)
	set waitfor = 0
	set background = 1
	try
		var/icon/I = new(f)
		var/w = I.Width() || 32
		var/h = I.Height() || 32
		var/mw = -round(-w/4)
		var/mh = -round(-h/4)
		var/packs = -round(-mw/24)
		var/list/states = I.IconStates()
		if(!istype(states) || !states.len)
			states = list(null)
		else if(standing)
			states = states.Copy(1, 2)
		else if(states.len > RUNTIME_STATE_CAP)
			states = states.Copy(1, RUNTIME_STATE_CAP + 1)
		var/list/union = NewMaskGrid(mw, mh, packs)
		var/list/dirdata = list()
		var/list/framedata = list()
		for(var/dc in list("S", "N", "E", "W"))
			var/d = (dc == "S") ? SOUTH : ((dc == "N") ? NORTH : ((dc == "E") ? EAST : WEST))
			var/list/M = NewMaskGrid(mw, mh, packs)
			var/list/frames = list()
			if(standing)
				ScanIconGrid(I, M, w, h, d, states[1], 1, null)
			else
				for(var/fi = 1, fi <= RUNTIME_FRAME_CAP, fi++)
					var/list/G = NewMaskGrid(mw, mh, packs)
					ScanIconGrid(I, G, w, h, d, states[1], fi, null)
					frames += list(G)
					if(fi >= 3 && MaskGridSame(G, frames[fi-1]) && MaskGridSame(G, frames[fi-2]))
						break
				while(frames.len > 1 && MaskGridEmpty(frames[frames.len]))
					frames.Cut(frames.len)
				while(frames.len > 1 && MaskGridSame(frames[frames.len], frames[frames.len-1]))
					frames.Cut(frames.len)
				for(var/list/G in frames)
					MaskGridOr(M, G)
				var/per = MaskFramePeriod(frames)
				if(per < frames.len)
					frames.Cut(per + 1)
				else if(frames.len >= RUNTIME_FRAME_CAP)
					frames.Cut(2)
				for(var/si = 2, si <= states.len, si++)
					var/list/G = NewMaskGrid(mw, mh, packs)
					ScanIconGrid(I, G, w, h, d, states[si], 1, M)
					MaskGridOr(M, G)
			MaskGridOr(union, M)
			var/list/r = MaskGridRect(M)
			if(r)
				dirdata[dc] = list(M, r)
				if(frames.len > 1)
					framedata[dc] = frames
		var/umnx = mw
		var/umxx = -1
		var/umny = mh
		var/umxy = -1
		for(var/dc in dirdata)
			var/list/dd = dirdata[dc]
			var/list/r = dd[2]
			umnx = min(umnx, r[1]/4)
			umny = min(umny, r[2]/4)
			umxx = max(umxx, r[1]/4 + r[3]/4 - 1)
			umxy = max(umxy, r[2]/4 + r[4]/4 - 1)
		if(umxx >= 0)
			RUNTIME_MASKS[k] = union
			RUNTIME_RECTS[k] = list(umnx*4, umny*4, (umxx - umnx + 1)*4, (umxy - umny + 1)*4)
			for(var/dc in dirdata)
				var/list/dd = dirdata[dc]
				RUNTIME_MASKS["[k]:[dc]"] = dd[1]
				RUNTIME_RECTS["[k]:[dc]"] = dd[2]
			for(var/dc in framedata)
				var/list/frames = framedata[dc]
				var/list/ends = list(0)
				for(var/fi = 1, fi <= frames.len, fi++)
					RUNTIME_MASKS["[k]:[dc]@[fi]"] = frames[fi]
					ends += fi
				RUNTIME_FRAMES["[k]:[dc]"] = ends
		else
			RUNTIME_RECTS[k] = list(0, 0, w, h) //fully transparent: canvas rect, marks scanned
		SaveRuntimeMasks()
		if(glob.PIXEL_DEBUG) world.log << "PXC: runtime icon scan complete ([w]x[h], key [copytext(k, 1, 9)])"
	catch(var/exception/e)
		world.log << "PXC: runtime icon scan failed: [e]"
	RUNTIME_SCANS -= k

var/list/ICON_CELL_CACHE = list()
proc/IconCellDims(iconFile)
	if(!iconFile) return list(32, 32)
	var/key = lowertext("[iconFile]")
	var/list/dims = ICON_CELL_CACHE[key]
	if(!dims)
		var/icon/I = new(iconFile)
		dims = list(I.Width() || 32, I.Height() || 32)
		ICON_CELL_CACHE[key] = dims
	return dims

atom/movable
	var/tmp
		hb_icon
		hb_scale = 1
		hb_ovW = 0
		hb_ovH = 0
		hb_ovX = -1
		hb_ovY = -1
		vhb_w = 0 //virtual hitbox dims, px
		vhb_h = 0
		vhb_ox = 0 //box center offset from tile center (world px)
		vhb_oy = 0 //which may sit off-center in the cell
		list/vhb_mask //baked ink mask (narrow phase); null = rect verdict stands
		vhb_cw = 32 //icon cell dims: art + mask sampling anchor cell-center-on-tile-center, so
		vhb_ch = 32 //nothing repositions when dir changes
		list/vhb_fmasks //per-animation-frame masks + clock: the ink follows the frame being drawn
		list/vhb_fends //cumulative frame end times, ds
		vhb_fcycle = 0
		vhb_floop = 0 //0 = loops forever; N = plays N times then holds the last frame
		vhb_anim0 //world.time the client started this animation
		hb_offX = 0 //FireOffset, kept for dir refits
		hb_offY = 0
		vhb_ax = 0 //FireOffset rotated for the current facing (world px): art anchor, mask anchor,
		vhb_ay = 0 //and endpoint blast all shift by this together
		vhb_varx = 0 //Variation art jitter, visual only - survives dir refits
		vhb_vary = 0 //box/mask stay unjittered
		vhb_lastd = 0
		vhb_funsure = 0
		vhb_g0 = 0
		vhb_gdur = 0
		vhb_gfrom = 0
		vhb_gto = 0

	//cell-center-on-tile-center anchoring for art, box, and mask
	proc/ApplySkillHitbox(iconFile, d=0, scale=1, ovW=0, ovH=0, ovX=-1, ovY=-1, offX=0, offY=0)
		if(iconFile != hb_icon || isnull(vhb_anim0))
			vhb_anim0 = world.time //new icon = client restarts its animation
		hb_icon = iconFile
		vhb_lastd = d
		hb_scale = scale
		hb_ovW = ovW
		hb_ovH = ovH
		hb_ovX = ovX
		hb_ovY = ovY
		hb_offX = offX
		hb_offY = offY
		vhb_ax = offX //FireOffset authored on the south shot
		vhb_ay = offY
		switch(d)
			if(NORTH)
				vhb_ax = -offX
				vhb_ay = -offY
			if(EAST)
				vhb_ax = -offY
				vhb_ay = offX
			if(WEST)
				vhb_ax = offY
				vhb_ay = -offX
		var/list/cell = IconCellDims(iconFile)
		vhb_cw = cell[1]
		vhb_ch = cell[2]
		vhb_mask = null
		vhb_fmasks = null
		vhb_fends = null
		vhb_funsure = 0
		vhb_ox = 0
		vhb_oy = 0
		if(ovW > 0 && ovH > 0) //hand override = rect only, tile-centered; owner's word is final
			if(d == EAST || d == WEST) //overrides are authored on the N/S frame; rotate for sideways flight
				vhb_w = max(2, round(ovH*scale))
				vhb_h = max(2, round(ovW*scale))
			else
				vhb_w = max(2, round(ovW*scale))
				vhb_h = max(2, round(ovH*scale))
		else
			var/list/r = GetBakedHitbox(iconFile, d)
			var/mkey = BakedMaskKey(iconFile, d)
			if(mkey)
				vhb_mask = BAKED_MASKS[mkey]
				var/list/fr = BAKED_FRAMES[mkey]
				if(fr)
					vhb_floop = fr[1]
					vhb_fends = fr.Copy(2)
					vhb_fcycle = vhb_fends[vhb_fends.len]
					vhb_fmasks = list()
					for(var/i = 1, i <= vhb_fends.len, i++)
						vhb_fmasks += list(BAKED_MASKS["[mkey]@[i]"])
			else if(!r) //unbaked = uploaded/custom skill icon: runtime measurement (one-time scan)
				vhb_mask = GetRuntimeMask(iconFile, d, 0)
				r = GetRuntimeRect(iconFile, d, 0)
				var/rkey = GetRuntimeFrames(iconFile, d)
				if(rkey)
					var/list/rfr = RUNTIME_FRAMES[rkey]
					vhb_floop = rfr[1]
					vhb_fends = rfr.Copy(2)
					vhb_fcycle = vhb_fends[vhb_fends.len]
					vhb_fmasks = list()
					vhb_funsure = 1
					for(var/i = 1, i <= vhb_fends.len, i++)
						vhb_fmasks += list(RUNTIME_MASKS["[rkey]@[i]"])
			if(!r) r = list(0, 0, cell[1], cell[2]) //unmeasured (or scan pending): full canvas
			vhb_w = max(2, round(r[3]*scale))
			vhb_h = max(2, round(r[4]*scale))
			vhb_ox = round(scale*(r[1] + r[3]/2 - cell[1]/2))
			vhb_oy = round(scale*(r[2] + r[4]/2 - cell[2]/2))
		vhb_ox += vhb_ax
		vhb_oy += vhb_ay
		pixel_x = round(16 - cell[1]/2) + vhb_ax + vhb_varx //art keeps its Variation jitter across refits
		pixel_y = round(16 - cell[2]/2) + vhb_ay + vhb_vary
		if(glob.PIXEL_DEBUG) ShowHitboxDebug()

	proc/CurrentFrameMask()
		var/el = world.time - vhb_anim0
		if(vhb_funsure && el >= vhb_fcycle)
			return vhb_mask
		if(vhb_floop && el >= vhb_fcycle * vhb_floop)
			return vhb_fmasks[vhb_fmasks.len] //finite animation: holds its last frame
		el -= vhb_fcycle * round(el / vhb_fcycle)
		for(var/i = 1, i <= vhb_fends.len, i++)
			if(el < vhb_fends[i])
				return vhb_fmasks[i]
		return vhb_fmasks[vhb_fmasks.len]

	var/tmp/obj/pxhitbox_dbg/vhb_dbg
	//red translucent rect at exactly the collision geometry
	proc/ShowHitboxDebug()
		try
			if(!vhb_dbg)
				vhb_dbg = new
				vis_contents += vhb_dbg
			var/icon/I = new('Skillz.dmi')
			I.DrawBox(rgb(255, 40, 40), 1, 1, 32, 32)
			I.DrawBox(rgb(40, 255, 40), 15, 15, 18, 18)
			vhb_dbg.icon = I
			vhb_dbg.maptext = "<span style='color:#f00'>HB</span>"
			vhb_dbg.transform = matrix(vhb_w/32, 0, 0, 0, vhb_h/32, 0)
			//cancel the parent's pixel_x/y so the box sits on the real collision geometry
			vhb_dbg.pixel_x = vhb_ox - pixel_x
			vhb_dbg.pixel_y = vhb_oy - pixel_y
		catch(var/exception/e)
			world.log << "PXC: hitbox debug overlay failed: [e]"

	proc/ReapplyHitboxForDir(ndir)
		if(!hb_icon && !(hb_ovW > 0)) return
		ApplySkillHitbox(hb_icon, ndir, hb_scale, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)

	proc/ReapplyHitboxScale(ns)
		if(!hb_icon && !(hb_ovW > 0)) return
		if(ns <= 0) return
		if(abs(ns - hb_scale) < max(0.002, hb_scale*0.03)) return
		ApplySkillHitbox(hb_icon, vhb_lastd, ns, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)

	proc/EaseInOutCubic(t)
		if(t <= 0) return 0
		if(t >= 1) return 1
		if(t <= 0.5) return 4*t*t*t
		var/u = 1 - t
		return 1 - 4*u*u*u

	proc/BeginHitboxGrow(gfrom, gto, dur)
		if(dur <= 0 || gto <= 0) return
		vhb_gfrom = (gfrom > 0) ? gfrom : hb_scale
		vhb_gto = gto
		vhb_gdur = dur
		vhb_g0 = world.time
		ReapplyHitboxScale(vhb_gfrom)

	proc/RefitGrowScale()
		if(!vhb_g0 || vhb_gdur <= 0) return
		var/t = (world.time - vhb_g0) / vhb_gdur
		if(t >= 1)
			vhb_g0 = 0
			ReapplyHitboxScale(vhb_gto)
			return
		ReapplyHitboxScale(vhb_gfrom + (vhb_gto - vhb_gfrom) * EaseInOutCubic(t))

	//how many tiles out this box can reach a full-tile mob (off-center boxes reach by offset + half-dim)
	proc/HitboxSweepRange()
		var/reach = max(abs(vhb_ox) + vhb_w/2, abs(vhb_oy) + vhb_h/2)
		return max(1, round((reach + 16) / 32) + 1)

obj/pxhitbox_dbg
	mouse_opacity = 0
	density = 0
	alpha = 100
	layer = 100
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA

mob
	var/tmp
		obj/pxhitbox_dbg/hurt_dbg
		hurt_dbg_key
		obj/pxhitbox_dbg/hurt_ink_dbg //MOB_INK_COLLIDE collider, drawn separately from the blue skill mask
		hurt_ink_key

mob/proc/PurgeHurtboxDebug()
	var/list/strays
	for(var/atom/movable/a in vis_contents)
		if(istype(a, /obj/pxhitbox_dbg))
			if(!strays) strays = list()
			strays += a
	if(strays)
		for(var/obj/pxhitbox_dbg/D in strays)
			vis_contents -= D
			D.loc = null
	hurt_dbg = null
	hurt_dbg_key = null
	hurt_ink_dbg = null //by TYPE, so this drops the ink overlay too; both trackers must follow it
	hurt_ink_key = null

//blue = the hurtbox skills actually test (silhouette else rect), orange = unmeasured; anchored tile origin, not pixel_x
mob/proc/ShowHurtboxDebug()
	if(!glob || !glob.PIXEL_DEBUG)
		PurgeHurtboxDebug() //unconditional: hurt_dbg/_key are tmp, so a save-loaded stray leaves both null
		return
	var/list/AM = GetBakedMask(icon, dir)
	if(!AM) AM = GetRuntimeMask(icon, dir)
	var/list/r = GetBakedHitbox(icon, dir)
	if(!r) r = GetRuntimeRect(icon, dir)
	var/key = "[icon]:[dir]:[AM ? "m" : "r"]:[r ? "[r[1]],[r[2]],[r[3]],[r[4]]" : "-"]"
	if(hurt_dbg && hurt_dbg_key == key) return //nothing changed since the last build
	try
		if(!hurt_dbg)
			PurgeHurtboxDebug() //a savefile stray would otherwise sit under the new one forever
			hurt_dbg = new
			vis_contents += hurt_dbg
		hurt_dbg_key = key
		var/list/cell = IconCellDims(icon)
		var/cw = cell[1]
		var/ch = cell[2]
		var/icon/I = new('Skillz.dmi')
		if(cw != 32 || ch != 32)
			I.Scale(cw, ch)
		I.DrawBox(rgb(0, 0, 0, 0), 1, 1, cw, ch) //clear to transparent; only the hurtbox gets painted
		if(AM) //true silhouette: one 4px block per set mask cell, rows bottom-up like MaskBitAt reads them
			for(var/rr = 0, rr < AM[2], rr++)
				for(var/cc = 0, cc < AM[1], cc++)
					if(MaskBitAt(AM, cc*4, rr*4))
						I.DrawBox(rgb(40, 140, 255), cc*4+1, rr*4+1, min(cc*4+4, cw), min(rr*4+4, ch))
		else if(r)
			I.DrawBox(rgb(40, 140, 255), r[1]+1, r[2]+1, min(r[1]+r[3], cw), min(r[2]+r[4], ch))
		else
			I.DrawBox(rgb(255, 140, 40), 1, 1, cw, ch) //unmeasured: skills hit the whole cell
		hurt_dbg.icon = I
		//cancel the parent's pixel_x/y - the mask anchors to the tile origin, not the art
		hurt_dbg.pixel_x = -pixel_x
		hurt_dbg.pixel_y = -pixel_y
	catch(var/exception/e)
		world.log << "PXC: hurtbox debug overlay failed: [e]"

//green strips + white box = the melee collider under MOB_INK_COLLIDE; different shape from the blue skill mask on purpose
mob/proc/ShowHurtboxInkDebug()
	if(!glob || !glob.PIXEL_DEBUG || !glob.MOB_INK_COLLIDE || !hurt_spans)
		if(hurt_ink_dbg) //targeted, NOT PurgeHurtboxDebug: that one drops the blue mask by type too
			vis_contents -= hurt_ink_dbg
			hurt_ink_dbg.loc = null
			hurt_ink_dbg = null
			hurt_ink_key = null
		return
	var/key = "[icon]:[hurt_ox],[hurt_oy],[hurt_w],[hurt_h]:[HurtSolidH(hurt_h)]" //dir-free
	if(hurt_ink_dbg && hurt_ink_key == key) return
	try
		if(!hurt_ink_dbg)
			hurt_ink_dbg = new
			hurt_ink_dbg.layer = 100.1 //above the blue mask, see-through so you can compare the two
			hurt_ink_dbg.alpha = 70
			vis_contents += hurt_ink_dbg
		hurt_ink_key = key
		var/list/cell = IconCellDims(icon)
		var/cw = cell[1]
		var/ch = cell[2]
		var/icon/I = new('Skillz.dmi')
		if(cw != 32 || ch != 32)
			I.Scale(cw, ch)
		I.DrawBox(rgb(0, 0, 0, 0), 1, 1, cw, ch)
		var/list/S = hurt_spans
		var/list/RS = S[3]
		var/sh = hurt_oy + HurtSolidH(hurt_h) //rows above this are walk-through (MOB_TALL_SOLID): drawn faded
		for(var/r = 0, r < S[2], r++) //one block per row strip, exactly what HurtInkF sweeps
			var/k = r*2 + 1
			var/lo = RS[k]
			if(lo < 0) continue
			I.DrawBox((r*4 < sh) ? rgb(40, 255, 90) : rgb(40, 255, 90, 70), lo + 1, r*4 + 1, min(RS[k+1], cw), min(r*4 + 4, ch))
		var/x1 = hurt_ox + 1 //1px outline of the DERIVED box: reach reads this, the clamp stops on the strips
		var/y1 = hurt_oy + 1
		var/x2 = min(hurt_ox + hurt_w, cw)
		var/y2 = min(hurt_oy + hurt_h, ch)
		I.DrawBox(rgb(255, 255, 255), x1, y1, x2, y1)
		I.DrawBox(rgb(255, 255, 255), x1, y2, x2, y2)
		I.DrawBox(rgb(255, 255, 255), x1, y1, x1, y2)
		I.DrawBox(rgb(255, 255, 255), x2, y1, x2, y2)
		hurt_ink_dbg.icon = I
		hurt_ink_dbg.pixel_x = -pixel_x
		hurt_ink_dbg.pixel_y = -pixel_y
	catch(var/exception/e)
		world.log << "PXC: ink collider debug overlay failed: [e]"

var/_pxdbg_shown = 0
var/_pxdbg_boot = _PxDebugBoot()

proc/_PxDebugBoot()
	spawn(25)
		_PxDebugWatcher()
	return 1

//keeps hurtbox overlays live while Pixel Debug is on; idles when off
proc/_PxDebugWatcher()
	set waitfor = 0
	set background = 1
	while(1)
		var/on = (glob && glob.PIXEL_DEBUG) ? 1 : 0
		if(on || _pxdbg_shown)
			for(var/mob/M)
				M.ShowHurtboxDebug() //purges strays by type when it (re)builds, so it must run first
				M.ShowHurtboxInkDebug()
			_pxdbg_shown = on
		sleep(5)

client/verb/Resync_Skill_Geometry()
	set name = "Resync Skill Geometry"
	set category = "Other"
	set hidden = 1
	if(!mob) return
	var/n = 0
	for(var/obj/Skills/Projectile/P in mob.contents)
		P.IconSize = initial(P.IconSize)
		P.IconSizeGrowTo = initial(P.IconSizeGrowTo)
		P.TempSize = initial(P.TempSize)
		P.LockX = initial(P.LockX)
		P.LockY = initial(P.LockY)
		n++
	for(var/obj/Skills/AutoHit/A in mob.contents)
		A.Size = initial(A.Size)
		n++
	mob << "Resynced geometry on [n] skills."

//F's virtual box vs A: A's own virtual box if it has one, else its real bounds (mobs = their tile box)
proc/HitboxesOverlap(atom/movable/F, atom/A)
	if(!F || !A || F.vhb_w <= 0) return FALSE
	var/fl = 1 + (F.x-1)*32 + F.step_x + 16 + F.vhb_ox - F.vhb_w/2
	var/fb = 1 + (F.y-1)*32 + F.step_y + 16 + F.vhb_oy - F.vhb_h/2
	var/al
	var/ab
	var/aw
	var/ah
	var/flyer_vs_flyer = FALSE
	var/list/P
	var/atom/movable/M = A
	if(istype(M) && M.vhb_w > 0)
		flyer_vs_flyer = TRUE
		al = 1 + (M.x-1)*32 + M.step_x + 16 + M.vhb_ox - M.vhb_w/2
		ab = 1 + (M.y-1)*32 + M.step_y + 16 + M.vhb_oy - M.vhb_h/2
		aw = M.vhb_w
		ah = M.vhb_h
	else if(ismob(A))
		P = BodyInkProbe(A)
		var/list/B = BodyInkRectL(P)
		al = B[1]
		ab = B[2]
		aw = B[3]
		ah = B[4]
	else
		al = A.LowerX()
		ab = A.LowerY()
		aw = A.Width()
		ah = A.Height()
	if(!((fl < al + aw) && (al < fl + F.vhb_w) && (fb < ab + ah) && (ab < fb + F.vhb_h)))
		return FALSE
	if(flyer_vs_flyer)
		return TRUE
	return InkOverlap(F, A, max(fl, al), max(fb, ab), min(fl + F.vhb_w, al + aw), min(fb + F.vhb_h, ab + ah), P)

proc/InkOverlap(atom/movable/F, atom/A, wl, wb, wr, wt, list/P = null)
	var/list/FM = F.vhb_fmasks ? F.CurrentFrameMask() : F.vhb_mask
	if(!P && ismob(A))
		P = BodyInkProbe(A)
	if(!FM && !P)
		return TRUE
	var/s = F.hb_scale || 1
	var/ftcx = 1 + (F.x-1)*32 + F.step_x + 16 + F.vhb_ax
	var/ftcy = 1 + (F.y-1)*32 + F.step_y + 16 + F.vhb_ay
	if(glob.PIXEL_DEBUG)
		var/aminfo = "n"
		if(P)
			aminfo = P[7] ? "y" : "rect"
			if(!P[7] && ismob(A))
				var/mob/dm = A
				aminfo += "([dm.icon])"
			if(P[5] != 1 || P[6] != 1)
				aminfo += " scale=[P[5]]x[P[6]]"
		world.log << "PXM: [F] window ([wl]..[wr], [wb]..[wt]) fm=[FM ? "y" : "n"] am=[aminfo]"
	for(var/wy = wb + 1, wy < wt, wy += 2)
		for(var/wx = wl + 1, wx < wr, wx += 2)
			if(FM && !MaskBitAt(FM, F.vhb_cw/2 + (wx - ftcx)/s, F.vhb_ch/2 + (wy - ftcy)/s))
				continue
			if(P && !BodyInkHitL(P, wx, wy))
				continue
			return TRUE
	return FALSE


//cell-px coords -> mask bit
proc/MaskBitAt(list/M, cx, cy)
	var/c = round(cx / 4)
	var/r = round(cy / 4)
	if(c < 0 || r < 0 || c >= M[1] || r >= M[2]) return FALSE
	return (M[4 + r*M[3] + round(c / 24)] & (1 << (c % 24))) != 0

//true circle test
proc/CircleHitsBounds(cx, cy, r, atom/A)
	if(!A) return FALSE
	var/nx = max(A.LowerX(), min(cx, A.LowerX() + A.Width()))
	var/ny = max(A.LowerY(), min(cy, A.LowerY() + A.Height()))
	return (nx-cx)*(nx-cx) + (ny-cy)*(ny-cy) <= r*r

proc/SquareHitsBounds(cx, cy, r, atom/A)
	if(!A) return FALSE
	var/nx = max(A.LowerX(), min(cx, A.LowerX() + A.Width()))
	var/ny = max(A.LowerY(), min(cy, A.LowerY() + A.Height()))
	return abs(nx-cx) <= r && abs(ny-cy) <= r

proc/CircleHitsBody(cx, cy, r, mob/m)
	if(!istype(m)) return CircleHitsBounds(cx, cy, r, m)
	var/list/P = BodyInkProbe(m)
	var/list/B = BodyInkRectL(P)
	if(!P[7])
		var/nx = max(B[1], min(cx, B[1] + B[3]))
		var/ny = max(B[2], min(cy, B[2] + B[4]))
		return (nx-cx)*(nx-cx) + (ny-cy)*(ny-cy) <= r*r
	var/wl = max(B[1], cx - r)
	var/wb = max(B[2], cy - r)
	var/wr = min(B[1] + B[3], cx + r)
	var/wt = min(B[2] + B[4], cy + r)
	if(wl >= wr || wb >= wt) return FALSE
	for(var/wy = wb + 1, wy < wt, wy += 2)
		for(var/wx = wl + 1, wx < wr, wx += 2)
			if((wx-cx)*(wx-cx) + (wy-cy)*(wy-cy) > r*r) continue
			if(BodyInkHitL(P, wx, wy)) return TRUE
	return FALSE


//world.time-gated re-hit; marks the timestamp when it passes
proc/RehitEligible(list/lastHit, key, interval)
	var/t = lastHit[key]
	if(!isnull(t) && world.time - t < interval) return FALSE
	lastHit[key] = world.time
	return TRUE
