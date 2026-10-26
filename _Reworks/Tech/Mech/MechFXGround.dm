var/list/MECHFX_DUST_TINTS = list(\
	"grass" = list(0.8, 0.74, 0.58),\
	"sand" = list(1, 0.9, 0.66),\
	"stone" = list(0.86, 0.83, 0.78),\
	"wastes" = list(0.96, 0.88, 0.7))

proc/MechFXSurface(turf/T)
	if(!isturf(T)) return null
	switch(BuildMaterialFor(T))
		if("Grass") return "grass"
		if("Sand") return "sand"
		if("Dirt") return "wastes"
		if("Stone", "Wood") return "stone"
		if("Water", "Ice") return null
	return "grass"

proc/MechFXDustMat(surf)
	var/key = "d[surf]"
	var/list/M = MECHFX_MATS[key]
	if(M) return M
	var/list/T = MECHFX_DUST_TINTS[surf] || MECHFX_DUST_TINTS["grass"]
	M = list(T[1] * 1.4, 0, 0, 0, T[2] * 1.4, 0, 0, 0, T[3] * 1.4)
	MECHFX_MATS[key] = M
	return M

proc/MechFXDustLayer(ref_layer, ref_y, py)
	var/dy = py - ref_y
	return ref_layer - dy * 0.018 / max(1, world.maxy * 32) + ((dy <= 0) ? 6e-7 : -6e-7)

proc/MechFXPuffCenter(wx, wy, w, h, cxp, cyp, sc)
	var/nw = round(w * sc, 1)
	var/nh = round(h * sc, 1)
	return list(round(wx - (nw / 2 + (cxp - w / 2) * sc), 1) + nw / 2, round(wy + (nh / 2 + (cyp - h / 2) * sc), 1) - nh / 2)

proc/MechFXFootDust(z, wx, wy, d, v, heavy, surf, ref_layer, ref_y)
	var/obj/mechfx/dust/D = MechFXGet(/obj/mechfx/dust)
	if(!D) return
	var/big = heavy || surf == "sand"
	var/w = big ? MECHFX_DUSTBIG_W : MECHFX_DUST_W
	var/h = big ? MECHFX_DUSTBIG_H : MECHFX_DUST_H
	var/cxp = big ? 96 : 56
	var/cyp = big ? 100 : 56
	var/sc = (surf == "sand" && heavy) ? 1.25 : 1
	var/tag = (surf == "sand") ? "s" : (heavy ? "h" : "m")
	D.icon = big ? MECHFX_DUSTBIG_ICON : MECHFX_DUST_ICON
	D.icon_state = "[tag]_[d]_[v]"
	D.color = MechFXDustMat(surf)
	D.alpha = 255
	D.layer = MechFXDustLayer(ref_layer, ref_y, wy)
	var/list/c = MechFXPuffCenter(wx, wy, w, h, cxp, cyp, sc)
	if(MechFXPlace(D, c[1], c[2], z, w, h, (sc != 1) ? MechFXMatrix(sc, sc, 0) : null))
		MechFXDue(D, big ? 26 : 24)
	else
		MechFXFree(D)

proc/MechFXSheet(z, wx, wy, v, surf, sc, rot, vx, vy, a, ref_layer, ref_y, delay)
	set waitfor = 0
	if(delay > 0) sleep(delay * world.tick_lag)
	var/obj/mechfx/dust/D = MechFXGet(/obj/mechfx/dust)
	if(!D) return
	D.icon = MECHFX_SHEET_ICON
	D.icon_state = "p[v]"
	D.color = MechFXDustMat(surf)
	D.alpha = a
	D.layer = MechFXDustLayer(ref_layer, ref_y, wy)
	var/list/c = MechFXPuffCenter(wx, wy, MECHFX_SHEET_W, MECHFX_SHEET_H, 28, 40, sc)
	if(!MechFXPlace(D, c[1], c[2], z, MECHFX_SHEET_W, MECHFX_SHEET_H, MechFXMatrix(sc, sc, rot)))
		MechFXFree(D)
		return
	MechFXDriftLinear(D, vx, vy, 18)
	MechFXDue(D, 18)

proc/MechFXGrit(z, gx, gy, vx, vy, hop, surf, ref_layer, ref_y)
	var/obj/mechfx/grit/G = MechFXGet(/obj/mechfx/grit)
	if(!G) return
	var/list/T = MECHFX_DUST_TINTS[surf] || MECHFX_DUST_TINTS["grass"]
	G.color = rgb(round(T[1] * 0.55 * 255, 1), round(T[2] * 0.55 * 255, 1), round(T[3] * 0.55 * 255, 1))
	G.alpha = 191
	G.layer = MechFXDustLayer(ref_layer, ref_y, gy)
	var/bx = floor(gx)
	var/by = ceil(gy)
	if(!MechFXPlace(G, bx + 0.5, by - 0.5, z, 1, 1, null))
		MechFXFree(G)
		return
	var/matrix/B = G.transform
	for(var/i = 1 to 6)
		var/t = i * MECHFX_TICK_S
		var/q = t / 0.3
		var/matrix/M = matrix(B)
		M.Translate(floor(gx + vx * t) - bx, ceil(gy + vy * t + hop * 4 * q * (1 - q)) - by)
		if(i == 1)
			animate(G, transform = M, time = world.tick_lag)
		else
			animate(transform = M, time = world.tick_lag)
	MechFXDue(G, 6)

proc/MechFXHoverIdle(z, cx, cy, gy, surf, lay)
	for(var/side in list(-1, 1))
		MechFXSheet(z, cx + side * 62 + MechFXU(-4, 4), cy + MechFXU(-3, 3), rand(0, 3), surf, MechFXU(0.55, 0.8), (side > 0) ? 0 : 180, side * MechFXU(12, 20), MechFXU(-3, 3), 255, lay, gy, 0)

mob/proc/MechFXHover(datum/mechfx_state/S, list/P, X, Y, vx, vy, spd, now)
	if(S.hover_tick == now) return
	var/surf = MechFXSurface(loc)
	if(!surf) return
	S.hover_tick = now
	var/cx = X + P["off"] + P["size"] / 2
	var/cy = Y + 12
	var/gy = Y + 14
	var/lay = layer
	if(spd > 1.5)
		var/ux = vx / spd
		var/uy = vy / spd
		var/first = (rand() < 0.5) ? -1 : 1
		for(var/s = 1 to 2)
			var/side = (s == 1) ? first : -first
			if(rand() > 0.62) continue
			var/ang = MechFXU(26, 50) * side
			var/ox = -ux * cos(ang) + uy * sin(ang)
			var/oy = -ux * sin(ang) - uy * cos(ang)
			var/o = MechFXU(8, 10)
			var/wx
			var/wy
			if(abs(ux) > 0.5)
				wx = cx - ux * 34 + MechFXU(-8, 8)
				wy = cy + side * (14 + o) + MechFXU(-2, 2)
			else
				wx = cx + side * (30 + o) + MechFXU(-3, 3)
				wy = cy - uy * 14 + MechFXU(-3, 3)
			var/vv = MechFXU(36, 66) + spd * 1.1
			MechFXSheet(z, wx, wy, rand(0, 3), surf, MechFXU(0.65, 1.35), arctan(ox, -oy * 0.5) + MechFXU(-15, 15), ox * vv, oy * vv * 0.5, 255, lay, gy, round(MechFXU(0, 1.4), 1))
		if(now % 3 == 0)
			MechFXSheet(z, cx - ux * MechFXU(40, 70), cy - uy * MechFXU(20, 36) + MechFXU(-3, 3), rand(0, 3), surf, MechFXU(1.7, 2.1), arctan(-ux, uy * 0.5) + MechFXU(-11.4592, 11.4592), -ux * 10, 5, 77, lay, gy, 0)
		if(rand() < 0.35)
			var/gside = (rand() < 0.5) ? -1 : 1
			MechFXGrit(z, cx - ux * 20 - uy * gside * 30, cy - uy * 10 + ux * gside * 12, -uy * gside * MechFXU(40, 70) - ux * 30, ux * gside * MechFXU(20, 35) - uy * 20, MechFXU(5, 9), surf, lay, gy)
	else if(now % 3 == 0)
		MechFXHoverIdle(z, cx, cy, gy, surf, lay)

mob/proc/MechFXMounted()
	var/list/row = mech ? mech.MechRow() : null
	if(!row || !row["hover"]) return
	var/datum/mechfx_state/S = MechFXState()
	MechFXIdleLoop(S, ++S.hover_token)

mob/proc/MechFXIdleLoop(datum/mechfx_state/S, token)
	set waitfor = 0
	while(S.hover_token == token && mech && mechfx_st == S)
		sleep(world.tick_lag)
		if(mech_fly_running || mech_air || !glob || !glob.MECHFX || !MECHFX_ASSETS || !mech) continue
		var/now = MechFXNow()
		if(now % 3 || S.hover_tick == now || MechFXHidden() || !MechHovers()) continue
		var/list/P = MECHFX_PROFILES[mech.model]
		if(!P) continue
		var/surf = MechFXSurface(loc)
		if(!surf) continue
		S.hover_tick = now
		var/Y = (y - 1) * 32 + step_y
		MechFXHoverIdle(z, (x - 1) * 32 + step_x + P["off"] + P["size"] / 2, Y + 12, Y + 14, surf, layer)

mob/Players/PmMovementTick()
	var/turf/t0 = loc
	var/sx0 = step_x
	var/sy0 = step_y
	. = ..()
	if(mech && !mech_air && (loc != t0 || step_x != sx0 || step_y != sy0)) MechFXStep()

mob/proc/MechFXStep()
	if(!glob || !glob.MECHFX || !MECHFX_ASSETS || !mech || MechFXHidden() || MechHovers()) return
	var/list/P = MECHFX_PROFILES[mech.model]
	if(!P || P["cls"] == "Light") return
	var/dl = P["delay"]
	var/n = floor(world.time / dl)
	if(abs(world.time - n * dl) >= world.tick_lag / 2) return
	var/f = n % 4
	if(f != 1 && f != 3) return
	var/d = MechFXDir4(dir)
	var/list/ft = MECHFX_FEET["[mech.model]_[d]_[f % P["frames"]]"]
	if(!ft) return
	var/X = (x - 1) * 32 + step_x
	var/Y = (y - 1) * 32 + step_y
	var/wx = X + P["off"] + ft[1]
	var/wy = Y + MechFlyBaseY() + (P["size"] - ft[2])
	var/surf = MechFXSurface(locate(floor(wx / 32) + 1, floor(wy / 32) + 1, z))
	if(!surf) return
	var/datum/mechfx_state/S = MechFXState()
	var/v = S.foot_v % 3
	S.foot_v++
	MechFXFootDust(z, wx, wy, d, v, P["cls"] == "Heavy", surf, layer, Y + 6)
