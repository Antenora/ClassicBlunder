#define OUGI_ROOM_SPAN 21
#define OUGI_ROOM_HALF 10
#define OUGI_FRAME_TILES 21
#define OUGI_HOLD_STASIS 100
#define OUGI_HOLD_STALL 1000000
#define OUGI_KEEPER_DS 2

#define OUGI_FLASH_DS 5
#define OUGI_DIM_DS 1.5
#define OUGI_PIN_DS 3
#define OUGI_WIPE_IN_DS 2.5
#define OUGI_WIPE_HOLD_DS 1.5
#define OUGI_WIPE_OUT_DS 2.5
#define OUGI_WHITEOUT_DS 1.5
#define OUGI_PLATE_DELAY_DS 2
#define OUGI_FIZZLE_DS 6
#define OUGI_HIT_SETTLE_DS 3
#define OUGI_PRELUDE_HOLD_DS 15
#define OUGI_RELAY_STEPS 400

#define OUGI_DIM_LEVEL 0.30
#define OUGI_FX_PLANE (/obj/fx_relay::plane)
#define OUGI_PLATE_W 144
#define OUGI_PLATE_H 40
#define OUGI_PLATE_TEXT_PAD 64
#define OUGI_PLATE_BAND_LO 13
#define OUGI_PLATE_BAND_HI 26
#define OUGI_FONT_INK_TOP 8
#define OUGI_FONT_BASELINE 2
#define OUGI_FONT_DESCENT 0
#define OUGI_FONT_ADVANCE 6
#define OUGI_FLASH_PLANE 22
#define OUGI_STREAK_FADE_DS 1
#define OUGI_FENCE_DS 15
#define OUGI_BLANKET_PX 4096
#define OUGI_EASE_BACK_DS 10
#define OUGI_STANDIN_ICON 'Icons/Other/RPMode.dmi'
#define OUGI_ART_FALLBACK 'Icons/impact_frames.dmi'
#define OUGI_BACKDROP_PLANE -40
#define OUGI_BACKDROP_OLD_PLANE -41
#define OUGI_BD_COPIES 5
#define OUGI_ACTOR_LAYER (MOB_LAYER + 0.04)
#define OUGI_ACTOR_FRONT_LAYER (MOB_LAYER + 0.045)

#if fexists("../../../Icons/Private/Backdrops/mountain_dusk.dmi") || fexists("Icons/Private/Backdrops/mountain_dusk.dmi")
#define OUGI_BD_MOUNTAIN_DUSK_ART 'Icons/Private/Backdrops/mountain_dusk.dmi'
#else
#define OUGI_BD_MOUNTAIN_DUSK_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Backdrops/sky_pink.dmi") || fexists("Icons/Private/Backdrops/sky_pink.dmi")
#define OUGI_BD_SKY_PINK_ART 'Icons/Private/Backdrops/sky_pink.dmi'
#else
#define OUGI_BD_SKY_PINK_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_nameplate.dmi") || fexists("Icons/Private/Ougi/ougi_nameplate.dmi")
#define OUGI_NAMEPLATE_ART 'Icons/Private/Ougi/ougi_nameplate.dmi'
#else
#define OUGI_NAMEPLATE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_focus_gold_L.dmi") || fexists("Icons/Private/Ougi/ougi_focus_gold_L.dmi")
#define OUGI_FOCUS_L_ART 'Icons/Private/Ougi/ougi_focus_gold_L.dmi'
#else
#define OUGI_FOCUS_L_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_focus_gold_S.dmi") || fexists("Icons/Private/Ougi/ougi_focus_gold_S.dmi")
#define OUGI_FOCUS_S_ART 'Icons/Private/Ougi/ougi_focus_gold_S.dmi'
#else
#define OUGI_FOCUS_S_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_ring.dmi") || fexists("Icons/Private/Ougi/ougi_ring.dmi")
#define OUGI_GOLD_RING_ART 'Icons/Private/Ougi/ougi_ring.dmi'
#else
#define OUGI_GOLD_RING_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_sparkle.dmi") || fexists("Icons/Private/Ougi/ougi_sparkle.dmi")
#define OUGI_SPARKLE_ART 'Icons/Private/Ougi/ougi_sparkle.dmi'
#else
#define OUGI_SPARKLE_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_wipe_fringe_L.dmi") || fexists("Icons/Private/Ougi/ougi_wipe_fringe_L.dmi")
#define OUGI_WIPE_FRINGE_L_ART 'Icons/Private/Ougi/ougi_wipe_fringe_L.dmi'
#else
#define OUGI_WIPE_FRINGE_L_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_wipe_fringe_S.dmi") || fexists("Icons/Private/Ougi/ougi_wipe_fringe_S.dmi")
#define OUGI_WIPE_FRINGE_S_ART 'Icons/Private/Ougi/ougi_wipe_fringe_S.dmi'
#else
#define OUGI_WIPE_FRINGE_S_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_wipe_streaks_L.dmi") || fexists("Icons/Private/Ougi/ougi_wipe_streaks_L.dmi")
#define OUGI_WIPE_STREAKS_L_ART 'Icons/Private/Ougi/ougi_wipe_streaks_L.dmi'
#else
#define OUGI_WIPE_STREAKS_L_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_wipe_streaks_S.dmi") || fexists("Icons/Private/Ougi/ougi_wipe_streaks_S.dmi")
#define OUGI_WIPE_STREAKS_S_ART 'Icons/Private/Ougi/ougi_wipe_streaks_S.dmi'
#else
#define OUGI_WIPE_STREAKS_S_ART OUGI_ART_FALLBACK
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_fill_gold.png") || fexists("Icons/Private/Ougi/ougi_fill_gold.png")
#define OUGI_FILL_GOLD_ART 'Icons/Private/Ougi/ougi_fill_gold.png'
#else
#define OUGI_FILL_GOLD_ART 'HUD/fin_fill.png'
#endif

#if fexists("../../../Icons/Private/Ougi/ougi_fill_locked.png") || fexists("Icons/Private/Ougi/ougi_fill_locked.png")
#define OUGI_FILL_LOCKED_ART 'Icons/Private/Ougi/ougi_fill_locked.png'
#else
#define OUGI_FILL_LOCKED_ART 'HUD/fin_fill.png'
#endif
#define OUGI_RING_ICON 'Icons/Effects/KenShockwaveGold.dmi'
#define OUGI_BLACK_ICON 'Icons/Effects/blackcutin.dmi'
#define OUGI_WHITE_ICON 'Icons/Effects/lightcutin.dmi'

globalTracker
	var/tmp
		OUGI_DAMAGE_MULT = 6
		OUGI_LOCK_RANGE = 20
		OUGI_TENSION_LOCK_S = 5
		OUGI_COOLDOWN_S = 60
		OUGI_CHAIN_WINDOW_S = 10
		OUGI_REFUND_PCT = 50
		list/OUGI_BURST_CONST = list(0, 0, 0.25, 0.33, 0.5)
		OUGI_ROOM_COPIES = 2
		OUGI_FAST = 0
		OUGI_PLATE_TOP_GAP = 10
		OUGI_GAUGE_SOUTH = 122
		OUGI_GAUGE_EDGE = "#8a5a10"
		OUGI_GAUGE_GLOW = "#ffc850"
		OUGI_RING_COLOR = "#ffd23a"
		list/OugiScenes
		list/OugiRooms
		list/OugiStages
		list/OugiBackdrops
		list/OugiLiveScenes
	var
		OUGI_POTENTIAL = 10
		OUGI_RPP_COST = 250

mob
	var
		EquippedOugi
		tmp
			datum/ougi_scene/OugiLock
			ougi_prev_stasis = 0
			ougi_prev_stall = 0
			ougi_was_rp = 0
			ougi_cd_until = 0
			ougi_return_dir = 0
			ougi_return_step_x = 0
			ougi_return_step_y = 0
			ougi_return_flight = 0
			ougi_return_pixel_x = 0
			ougi_return_pixel_y = 0
			ougi_return_pixel_z = 0
			ougi_return_state
			matrix/ougi_return_transform
			ougi_added_pixel_scale = 0
			ougi_return_layer
			obj/ougi_stand_in/ougi_stand_in

client
	var/tmp
		atom/ougi_eye_prev
		ougi_perspective_prev = MOB_PERSPECTIVE
		ougi_in_display = 0
		ougi_dimmed = 0
		ougi_fps_until = 0
		obj/ougi_screen/wipe/ougi_wipe
		ougi_gauge_shown = 0
		ougi_gauge_last = 0
		ougi_gauge_mode
		atom/movable/shud/ougi_gauge/ougi_track
		atom/movable/shud/ougi_gauge/ougi_fill
		list/ougi_sparkles
		list/ougi_backdrop_objs
		list/ougi_backdrop_old
		obj/ougi_backdrop_fade/ougi_backdrop_fade
		obj/ougi_flash_master/ougi_flash_master
		obj/ougi_screen/flash_relay/ougi_flash_relay
		ougi_wipe_covered = 0
		ougi_fences = 0
		ougi_cut_px = 0
		ougi_ease_pending = 0

var/ougi_boot_stamp = "[rand(100000, 999999)]"

proc/OugiScenesRegistry()
	if(!glob.OugiScenes) glob.OugiScenes = list()
	if(!glob.OugiScenes.len) OugiRegisterBuiltinScenes()
	return glob.OugiScenes

proc/OugiRoomsList()
	if(!glob.OugiRooms) glob.OugiRooms = list()
	return glob.OugiRooms

proc/OugiLiveList()
	if(!glob.OugiLiveScenes) glob.OugiLiveScenes = list()
	return glob.OugiLiveScenes

proc/OugiRegisterScene(datum/ougi_scene/S)
	if(!S || !S.id) return 0
	if(!glob.OugiScenes) glob.OugiScenes = list()
	glob.OugiScenes[S.id] = S
	return 1

proc/OugiRegisterBuiltinScenes()
	for(var/T in typesof(/datum/ougi_scene) - /datum/ougi_scene)
		var/datum/ougi_scene/S = new T
		if(S.id) OugiRegisterScene(S)

proc/OugiSceneById(id)
	if(!id) return null
	var/list/R = OugiScenesRegistry()
	return R[id]

proc/OugiTimeScale()
	return glob.OUGI_FAST ? 0.5 : 1

proc/OugiEnvTurf(mob/M, turf/fallback)
	if(M && M.OugiLock && M.client && M.client.eye)
		var/turf/T = get_turf(M.client.eye)
		if(T) return T
	return fallback

proc/OugiEnvArea(mob/M, area/fallback)
	var/turf/T = OugiEnvTurf(M, null)
	return T ? T.loc : fallback

var/list/_ougi_solid_cache = list()

proc/OugiSolidIcon(base)
	var/key = "[base]"
	if(_ougi_solid_cache[key]) return _ougi_solid_cache[key]
	var/icon/I = icon(base)
	I.Crop(1, 1, 32, 32)
	_ougi_solid_cache[key] = I
	return I

proc/OugiViewPx(client/C)
	var/list/vt = GfxCameraViewTiles(C)
	return list(vt[1] * world.icon_size, vt[2] * world.icon_size)

#define OUGI_MARK_WINDOW_DS 60
#define OUGI_MARK_AMP 0.15
#define OUGI_BLEED_DELAY_DS 20
#define OUGI_SUREDODGE_DS 50

/obj/Skills/Ougi
	var
		SecretOugi = 0
		list/RequiredSkills
		OugiStunner = 0
		OugiShearing = 0
		OugiCrippling = 0
		OugiBurning = 0
		OugiDisorienting = 0
		OugiKnockback = 0
		OugiLaunch = 0
		OugiDelayedBleed = 0
		OugiLifeSteal = 0
		OugiMark = 0
		OugiSureDodge = 0
		list/OugiAfterglowPassives
		OugiAfterglowSeconds = 0

/obj/Skills/Buffs/SlotlessBuffs/OugiAfterglow
	name = "Ougi Afterglow"
	BuffName = "Ougi Afterglow"
	TimerLimit = 6
	PauseInRP = 0
	passives = list()

mob/var/tmp
	ougi_mark_by
	ougi_mark_until = 0
	ougi_suredodge_until = 0
