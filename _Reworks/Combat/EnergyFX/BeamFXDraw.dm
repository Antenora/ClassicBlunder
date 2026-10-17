var/list/BEAMFX_FAM = list()

#define BFX_FAM 1
#define BFX_ST 2
#define BFX_LIGHT 3
#define BFX_X 4
#define BFX_Y 5
#define BFX_ANG 6
#define BFX_SX 7
#define BFX_SY 8
#define BFX_PRE 9
#define BFX_ALPHA 10
#define BFX_LAYER 11
#define BFX_ORDER 12
#define BFX_TAG 13
#define BFX_FADE 14
#define BFX_SEED 15
#define BFX_ZL 16
#define BFX_PR 17
#define BFX_CAR 18

/datum/bfx_slot
	var/obj/energyfx/obj
	var/fam
	var/light = 0
	var/list/last
	var/idle = 0
	var/st
	var/pr = 0

/datum/beamfx/proc/Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr = 0)
	var/list/sp = list(fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	var/list/F = frame_specs[j]
	F[key] = sp
	if(logging) flog += list(sp)

/datum/beamfx/proc/Frame(fi, j)
	return
