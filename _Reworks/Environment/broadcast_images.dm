#define GFX_BC_CHUNK 16
#define GFX_BC_MARGIN 8
#define GFX_BC_SYNC 1

/image/var/tmp
	list/gfx_bc
	gfx_bc_reach = 0
	datum/gfx_bc_bucket/gfx_bc_bucket

/client/var/tmp/list/gfx_bc_sync

/datum/gfx_bc_bucket
	var
		key
		z = 0
		x0 = 0
		y0 = 0
		reach = 0
		list/imgs
		atom/movable/holder
		hx = 0
		hy = 0
		hz = 0

var/list/_gfx_bc_chunks = list()
var/list/_gfx_bc_zb = list()
var/list/_gfx_bc_holders = list()
var/list/_gfx_bc_hb = list()
var/list/_gfx_bc_art = list()
var/list/_gfx_bc_relq = list()
var/_gfx_bc_relf = 0
var/_gfx_bc_loop = 0

var/_gfx_bc_tt = -1
var/list/_gfx_bc_tc = list()
var/list/_gfx_bc_tz = list()
var/list/_gfx_bc_tx0 = list()
var/list/_gfx_bc_tx1 = list()
var/list/_gfx_bc_ty0 = list()
var/list/_gfx_bc_ty1 = list()
var/list/_gfx_bc_ts = list()
var/list/_gfx_bc_tzi = list()
var/list/_gfx_bc_cand = list()
var/_gfx_bc_mcx = 0
var/_gfx_bc_mcy = 0
var/_gfx_bc_mcz = 0
var/_gfx_bc_mr = 0
var/list/_gfx_bc_mc
var/_gfx_bc_fkey
var/datum/gfx_bc_bucket/_gfx_bc_fb

proc/GfxBcClients()
	. = list()
	for(var/client/C)
		. += C

proc/GfxBcBuildTable(list/roster)
	_gfx_bc_tt = world.time
	_gfx_bc_tc = list()
	_gfx_bc_tz = list()
	_gfx_bc_tx0 = list()
	_gfx_bc_tx1 = list()
	_gfx_bc_ty0 = list()
	_gfx_bc_ty1 = list()
	_gfx_bc_ts = list()
	_gfx_bc_tzi = list()
	_gfx_bc_cand = list()
	_gfx_bc_mc = null
	for(var/client/C as anything in roster)
		if(!C) continue
		var/atom/A = GfxViewAnchor(C)
		var/turf/T = A ? get_turf(A) : null
		if(!T) continue
		var/list/d = GfxCameraViewTiles(C)
		var/hw = ceil(max(d[1], C.gfx_screen_cover_w) / 2) + GFX_BC_MARGIN
		var/hh = ceil(max(d[2], C.gfx_screen_cover_h) / 2) + GFX_BC_MARGIN
		_gfx_bc_tc += C
		_gfx_bc_tz += T.z
		_gfx_bc_tx0 += T.x - hw
		_gfx_bc_tx1 += T.x + hw
		_gfx_bc_ty0 += T.y - hh
		_gfx_bc_ty1 += T.y + hh
		_gfx_bc_ts.len++
		_gfx_bc_ts[_gfx_bc_ts.len] = C.gfx_bc_sync
		if(_gfx_bc_tzi.len < T.z) _gfx_bc_tzi.len = T.z
		var/list/zl = _gfx_bc_tzi[T.z]
		if(!zl)
			zl = list()
			_gfx_bc_tzi[T.z] = zl
		zl += _gfx_bc_tc.len

proc/_GfxBcCand(turf/T, reach)
	if(_gfx_bc_tt != world.time) GfxBcBuildTable(GfxBcClients())
	var/cx = floor((T.x - 1) / GFX_BC_CHUNK)
	var/cy = floor((T.y - 1) / GFX_BC_CHUNK)
	if(_gfx_bc_mc && cx == _gfx_bc_mcx && cy == _gfx_bc_mcy && T.z == _gfx_bc_mcz && reach == _gfx_bc_mr) return _gfx_bc_mc
	var/k = "[T.z]:[cx]:[cy]:[reach]"
	var/list/c = _gfx_bc_cand[k]
	if(!c)
		var/list/full = list()
		var/list/part = list()
		c = list(full, part)
		if(T.z <= _gfx_bc_tzi.len)
			var/list/zl = _gfx_bc_tzi[T.z]
			if(zl)
				var/bx0 = cx * GFX_BC_CHUNK + 1 - reach
				var/bx1 = cx * GFX_BC_CHUNK + GFX_BC_CHUNK + reach
				var/by0 = cy * GFX_BC_CHUNK + 1 - reach
				var/by1 = cy * GFX_BC_CHUNK + GFX_BC_CHUNK + reach
				var/fx0 = bx0 + reach * 2
				var/fx1 = bx1 - reach * 2
				var/fy0 = by0 + reach * 2
				var/fy1 = by1 - reach * 2
				for(var/i in zl)
					var/a0 = _gfx_bc_tx0[i]
					var/a1 = _gfx_bc_tx1[i]
					var/b0 = _gfx_bc_ty0[i]
					var/b1 = _gfx_bc_ty1[i]
					var/list/s = _gfx_bc_ts[i]
					if(s && s[1] != T.z) s = null
					if((fx0 >= a0 && fx1 <= a1 && fy0 >= b0 && fy1 <= b1) || (s && fx0 >= s[2] && fx1 <= s[3] && fy0 >= s[4] && fy1 <= s[5]))
						full += _gfx_bc_tc[i]
					else if((bx1 >= a0 && bx0 <= a1 && by1 >= b0 && by0 <= b1) || (s && bx1 >= s[2] && bx0 <= s[3] && by1 >= s[4] && by0 <= s[5]))
						part += i
		_gfx_bc_cand += k
		_gfx_bc_cand[k] = c
	_gfx_bc_mcx = cx
	_gfx_bc_mcy = cy
	_gfx_bc_mcz = T.z
	_gfx_bc_mr = reach
	_gfx_bc_mc = c
	return c

proc/_GfxBcHit(i, turf/T, reach)
	var/tx = T.x
	var/ty = T.y
	if(tx >= _gfx_bc_tx0[i] - reach && tx <= _gfx_bc_tx1[i] + reach && ty >= _gfx_bc_ty0[i] - reach && ty <= _gfx_bc_ty1[i] + reach)
		return 1
	var/list/s = _gfx_bc_ts[i]
	return s && s[1] == T.z && tx >= s[2] - reach && tx <= s[3] + reach && ty >= s[4] - reach && ty <= s[5] + reach

proc/GfxBcRecipients(atom/where, reach = 3)
	. = list()
	var/turf/T = get_turf(where)
	if(!T) return
	var/list/c = _GfxBcCand(T, reach)
	. += c[1]
	for(var/i in c[2])
		if(_GfxBcHit(i, T, reach)) . += _gfx_bc_tc[i]

proc/GfxSendImage(image/I, atom/where = null, reach = 3)
	if(!I) return 0
	var/turf/T = get_turf(where ? where : I.loc)
	if(!T) return 0
	if(reach > I.gfx_bc_reach) I.gfx_bc_reach = reach
	reach = I.gfx_bc_reach
	var/list/got = I.gfx_bc
	var/fresh = !got
	if(fresh)
		got = list()
		I.gfx_bc = got
	. = 0
	var/tx = T.x
	var/ty = T.y
	var/tz = T.z
	var/list/c = _GfxBcCand(T, reach)
	var/list/full = c[1]
	if(fresh)
		for(var/client/C as anything in full)
			C.images += I
		got += full
		. += full.len
	else
		for(var/client/C as anything in full)
			if(C in got) continue
			C.images += I
			got += C
			.++
	for(var/i in c[2])
		if(tx < _gfx_bc_tx0[i] - reach || tx > _gfx_bc_tx1[i] + reach || ty < _gfx_bc_ty0[i] - reach || ty > _gfx_bc_ty1[i] + reach)
			var/list/s = _gfx_bc_ts[i]
			if(!s || s[1] != tz || tx < s[2] - reach || tx > s[3] + reach || ty < s[4] - reach || ty > s[5] + reach) continue
		var/client/C = _gfx_bc_tc[i]
		if(!fresh && (C in got)) continue
		C.images += I
		got += C
		.++
	if(I.loc) _GfxBcFile(I)

proc/_GfxBcFile(image/I)
	var/atom/L = I.loc
	var/datum/gfx_bc_bucket/B
	if(ismovable(L))
		B = _gfx_bc_holders[L]
		if(!B)
			var/turf/T = get_turf(L)
			B = new
			B.imgs = list()
			B.holder = L
			if(T)
				B.hx = T.x
				B.hy = T.y
				B.hz = T.z
			_gfx_bc_holders += L
			_gfx_bc_holders[L] = B
			_gfx_bc_hb += B
	else if(isturf(L))
		var/turf/T = L
		var/cx = floor((T.x - 1) / GFX_BC_CHUNK)
		var/cy = floor((T.y - 1) / GFX_BC_CHUNK)
		var/k = "[T.z]:[cx]:[cy]"
		if(k == _gfx_bc_fkey && _gfx_bc_fb && _gfx_bc_fb.imgs)
			B = _gfx_bc_fb
		else
			B = _gfx_bc_chunks[k]
			if(!B)
				B = new
				B.imgs = list()
				B.key = k
				B.z = T.z
				B.x0 = cx * GFX_BC_CHUNK + 1
				B.y0 = cy * GFX_BC_CHUNK + 1
				_gfx_bc_chunks += k
				_gfx_bc_chunks[k] = B
				if(_gfx_bc_zb.len < T.z) _gfx_bc_zb.len = T.z
				var/list/zl = _gfx_bc_zb[T.z]
				if(!zl)
					zl = list()
					_gfx_bc_zb[T.z] = zl
				zl += B
			_gfx_bc_fkey = k
			_gfx_bc_fb = B
	if(I.gfx_bc_bucket == B) return
	if(I.gfx_bc_bucket) _GfxBcUnfile(I)
	if(!B) return
	B.imgs += I
	I.gfx_bc_bucket = B
	if(I.gfx_bc_reach > B.reach) B.reach = I.gfx_bc_reach
	if(!_gfx_bc_loop) _GfxBcSyncLoop()

proc/_GfxBcUnfile(image/I)
	var/datum/gfx_bc_bucket/B = I.gfx_bc_bucket
	if(!B) return
	I.gfx_bc_bucket = null
	B.imgs -= I
	if(!B.imgs.len) _GfxBcDrop(B)

proc/_GfxBcDrop(datum/gfx_bc_bucket/B)
	if(B.key)
		_gfx_bc_chunks -= B.key
		if(B.z <= _gfx_bc_zb.len)
			var/list/zl = _gfx_bc_zb[B.z]
			if(zl) zl -= B
		if(_gfx_bc_fb == B)
			_gfx_bc_fb = null
			_gfx_bc_fkey = null
	else
		_gfx_bc_hb -= B
		if(B.holder) _gfx_bc_holders -= B.holder
		else _gfx_bc_holders -= null
	B.imgs = null

proc/GfxBcRelease(image/I)
	if(!I) return
	var/list/got = I.gfx_bc
	if(got)
		I.gfx_bc = null
		for(var/client/C as anything in got)
			if(!C) continue
			var/list/q = _gfx_bc_relq[C]
			if(!q)
				q = list()
				_gfx_bc_relq += C
				_gfx_bc_relq[C] = q
			q += I
		if(!_gfx_bc_relf)
			_gfx_bc_relf = 1
			spawn()
				_GfxBcFlush()
	if(I.gfx_bc_bucket) _GfxBcUnfile(I)
	I.gfx_bc_reach = 0

proc/_GfxBcFlush()
	var/list/qs = _gfx_bc_relq
	_gfx_bc_relq = list()
	_gfx_bc_relf = 0
	for(var/client/C as anything in qs)
		if(!C) continue
		var/list/q = qs[C]
		for(var/n = q.len, n >= 1, n--)
			C.images -= q[n]

proc/GfxBcHolderMoved(atom/movable/H)
	if(!H) return 0
	var/datum/gfx_bc_bucket/B = _gfx_bc_holders[H]
	if(!B) return 0
	var/turf/T = get_turf(H)
	if(!T) return 0
	B.hx = T.x
	B.hy = T.y
	B.hz = T.z
	. = 0
	for(var/image/I as anything in B.imgs)
		if(I.loc != H) continue
		var/list/got = I.gfx_bc
		if(!got) continue
		for(var/client/C as anything in GfxBcRecipients(T, I.gfx_bc_reach))
			if(C in got) continue
			C.images += I
			got += C
			.++

proc/GfxBcImageReach(image/I)
	if(!I) return 3
	var/w = world.icon_size
	var/h = world.icon_size
	var/art = I.icon
	if(istype(art, /icon))
		var/icon/A = art
		w = A.Width()
		h = A.Height()
	else if(art)
		var/list/d = _gfx_bc_art[art]
		if(!d)
			var/icon/A = icon(art)
			d = list(A.Width(), A.Height())
			_gfx_bc_art += art
			_gfx_bc_art[art] = d
		w = d[1]
		h = d[2]
	var/matrix/M = I.transform
	var/ma = 1
	var/mb = 0
	var/mc = 0
	var/md = 0
	var/me = 1
	var/mf = 0
	if(M)
		ma = M.a
		mb = M.b
		mc = M.c
		md = M.d
		me = M.e
		mf = M.f
	var/ex = (abs(ma) * w + abs(mb) * h) / 2
	var/ey = (abs(md) * w + abs(me) * h) / 2
	var/cx = I.pixel_x + I.pixel_w + w / 2 + mc
	var/cy = I.pixel_y + I.pixel_z + h / 2 + mf
	var/over = max(0, ex - cx, cx + ex - world.icon_size, ey - cy, cy + ey - world.icon_size)
	return max(3, ceil(over / world.icon_size))

proc/_GfxBcSyncLoop()
	set waitfor = 0
	if(_gfx_bc_loop) return
	_gfx_bc_loop = 1
	while(_gfx_bc_chunks.len || _gfx_bc_hb.len)
		sleep(GFX_BC_SYNC)
		_GfxBcSyncPass(GfxBcClients())
	_gfx_bc_loop = 0

proc/_GfxBcSyncPass(list/roster)
	GfxBcBuildTable(roster)
	var/list/stray = list()
	for(var/datum/gfx_bc_bucket/B as anything in _gfx_bc_hb.Copy())
		var/atom/movable/H = B.holder
		if(!H)
			stray += B.imgs
			continue
		for(var/image/I as anything in B.imgs)
			if(I.loc != H) stray += I
		var/turf/T = get_turf(H)
		if(T && (T.x != B.hx || T.y != B.hy || T.z != B.hz)) GfxBcHolderMoved(H)
	_GfxBcRefile(stray)
	stray = list()
	for(var/i = 1 to _gfx_bc_tc.len)
		var/z = _gfx_bc_tz[i]
		var/x0 = _gfx_bc_tx0[i]
		var/x1 = _gfx_bc_tx1[i]
		var/y0 = _gfx_bc_ty0[i]
		var/y1 = _gfx_bc_ty1[i]
		var/list/s = _gfx_bc_ts[i]
		if(s && s[1] == z && s[2] == x0 && s[3] == x1 && s[4] == y0 && s[5] == y1) continue
		_GfxBcCatchUp(i, s, stray)
		var/client/C = _gfx_bc_tc[i]
		if(!s)
			s = list(z, x0, x1, y0, y1)
			C.gfx_bc_sync = s
			_gfx_bc_ts[i] = s
		else
			s[1] = z
			s[2] = x0
			s[3] = x1
			s[4] = y0
			s[5] = y1
	_GfxBcRefile(stray)

proc/_GfxBcRefile(list/stray)
	for(var/image/I as anything in stray)
		_GfxBcUnfile(I)
		if(I.loc && I.gfx_bc) GfxSendImage(I)

proc/_GfxBcStrips(x0, x1, y0, y1, ox0, ox1, oy0, oy1)
	if(x1 < ox0 || x0 > ox1 || y1 < oy0 || y0 > oy1) return list(x0, x1, y0, y1)
	. = list()
	if(x0 < ox0) . += list(x0, ox0 - 1, y0, y1)
	if(x1 > ox1) . += list(ox1 + 1, x1, y0, y1)
	var/mx0 = max(x0, ox0)
	var/mx1 = min(x1, ox1)
	if(y0 < oy0) . += list(mx0, mx1, y0, oy0 - 1)
	if(y1 > oy1) . += list(mx0, mx1, oy1 + 1, y1)

proc/_GfxBcCatchUp(i, list/s, list/stray)
	var/client/C = _gfx_bc_tc[i]
	var/z = _gfx_bc_tz[i]
	var/x0 = _gfx_bc_tx0[i]
	var/x1 = _gfx_bc_tx1[i]
	var/y0 = _gfx_bc_ty0[i]
	var/y1 = _gfx_bc_ty1[i]
	var/same = s && s[1] == z
	var/ox0 = same ? s[2] : 0
	var/ox1 = same ? s[3] : -1
	var/oy0 = same ? s[4] : 0
	var/oy1 = same ? s[5] : -1
	var/list/strips = same ? _GfxBcStrips(x0, x1, y0, y1, ox0, ox1, oy0, oy1) : list(x0, x1, y0, y1)
	if(!strips.len) return
	if(z <= _gfx_bc_zb.len && _gfx_bc_zb[z])
		for(var/datum/gfx_bc_bucket/B as anything in _gfx_bc_zb[z])
			var/r = B.reach
			var/bx0 = B.x0 - r
			var/bx1 = B.x0 + GFX_BC_CHUNK - 1 + r
			var/by0 = B.y0 - r
			var/by1 = B.y0 + GFX_BC_CHUNK - 1 + r
			var/touch = 0
			for(var/k = 1 to strips.len step 4)
				if(bx1 >= strips[k] && bx0 <= strips[k + 1] && by1 >= strips[k + 2] && by0 <= strips[k + 3])
					touch = 1
					break
			if(!touch) continue
			var/bxe = B.x0 + GFX_BC_CHUNK - 1
			var/bye = B.y0 + GFX_BC_CHUNK - 1
			for(var/image/I as anything in B.imgs)
				var/turf/T = I.loc
				if(!isturf(T) || T.z != B.z || T.x < B.x0 || T.x > bxe || T.y < B.y0 || T.y > bye)
					stray |= I
					continue
				var/ir = I.gfx_bc_reach
				var/tx = T.x
				var/ty = T.y
				if(tx < x0 - ir || tx > x1 + ir || ty < y0 - ir || ty > y1 + ir) continue
				if(same && tx >= ox0 - ir && tx <= ox1 + ir && ty >= oy0 - ir && ty <= oy1 + ir) continue
				var/list/got = I.gfx_bc
				if(!got || (C in got)) continue
				C.images += I
				got += C
	for(var/datum/gfx_bc_bucket/B as anything in _gfx_bc_hb)
		var/atom/movable/H = B.holder
		if(!H || B.hz != z) continue
		var/tx = B.hx
		var/ty = B.hy
		for(var/image/I as anything in B.imgs)
			if(I.loc != H) continue
			var/ir = I.gfx_bc_reach
			if(tx < x0 - ir || tx > x1 + ir || ty < y0 - ir || ty > y1 + ir) continue
			if(same && tx >= ox0 - ir && tx <= ox1 + ir && ty >= oy0 - ir && ty <= oy1 + ir) continue
			var/list/got = I.gfx_bc
			if(!got || (C in got)) continue
			C.images += I
			got += C
