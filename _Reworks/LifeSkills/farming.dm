#define FARM_STATE_EMPTY 0
#define FARM_WILT_DAYS 3
#define FARM_GROW_CUT_PER_RANK 4     // % off total grow time per Farming rank
#define FARM_WATER_RATE 2            // fill per tick while holding (100 total)
#define FARM_MULTI_HARVESTS 3
#define FARM_PANEL_ROWS 6

proc/FarmDay()
	return round(world.realtime / 864000)

proc/FarmDayFrac()
	return (world.realtime % 864000) / 864000

// crop registry

/datum/farm_crop
	var/id
	var/name
	var/tier = 1
	var/base_days = 1
	var/multi = 0        // harvests repeatedly (stage 5 > 4 reset)
	var/giantable = 0
	var/mtype            // /obj/Items/Material/Crop path
	var/gtype            // giant material path (if giantable)

var/list/FarmCropDefs = list()   // id -> datum, registration order

proc/LifeCropAdd(id, name, tier, base_days, multi, giantable)
	var/datum/farm_crop/d = new
	d.id = id
	d.name = name
	d.tier = tier
	d.base_days = base_days
	d.multi = multi
	d.giantable = giantable
	d.mtype = text2path("/obj/Items/Material/Crop/[id]")
	if(giantable) d.gtype = text2path("/obj/Items/Material/Crop/giant_[id]")
	FarmCropDefs[id] = d

proc/FarmCropDef(id)
	if(!FarmCropDefs.len) RegisterFarmCrops()
	return FarmCropDefs[id]

proc/RegisterFarmCrops()
	if(FarmCropDefs.len) return
	LifeCropAdd("radish", "Radish", 1, 1, 0, 0)
	LifeCropAdd("lettuce", "Lettuce", 1, 1, 0, 0)
	LifeCropAdd("spinach", "Spinach", 1, 1, 0, 0)
	LifeCropAdd("turnip", "Turnip", 1, 1, 0, 0)
	LifeCropAdd("peas", "Green Peas", 1, 1, 1, 0)
	LifeCropAdd("carrot", "Carrot", 2, 2, 0, 0)
	LifeCropAdd("beetroot", "Beetroot", 2, 2, 0, 0)
	LifeCropAdd("onion", "Onion", 2, 2, 0, 0)
	LifeCropAdd("potato", "Potato", 2, 2, 0, 0)
	LifeCropAdd("cucumber", "Cucumber", 2, 2, 1, 1)
	LifeCropAdd("strawberry", "Strawberry", 2, 2, 1, 0)
	LifeCropAdd("cabbage", "Cabbage", 3, 3, 0, 1)
	LifeCropAdd("corn", "Corn", 3, 3, 1, 0)
	LifeCropAdd("tomato", "Tomato", 3, 3, 1, 1)
	LifeCropAdd("wheat", "Wheat", 3, 3, 0, 0)
	LifeCropAdd("beans", "Pinto Beans", 3, 3, 1, 0)
	LifeCropAdd("zucchini", "Zucchini", 3, 3, 1, 1)
	LifeCropAdd("leek", "Leek", 3, 3, 0, 0)
	LifeCropAdd("broccoli", "Broccoli", 4, 4, 0, 0)
	LifeCropAdd("eggplant", "Eggplant", 4, 4, 1, 0)
	LifeCropAdd("bellpepper", "Bell Pepper", 4, 4, 1, 0)
	LifeCropAdd("blueberry", "Blueberry", 4, 4, 1, 0)
	LifeCropAdd("raspberry", "Raspberry", 4, 4, 1, 0)
	LifeCropAdd("garlic", "Garlic", 4, 4, 0, 0)
	LifeCropAdd("sweetpotato", "Sweet Potato", 4, 4, 0, 0)
	LifeCropAdd("celery", "Celery", 4, 4, 0, 0)
	LifeCropAdd("pumpkin", "Pumpkin", 5, 6, 0, 1)
	LifeCropAdd("watermelon", "Watermelon", 5, 6, 0, 0)
	LifeCropAdd("grapes", "Blue Grapes", 5, 6, 1, 0)
	LifeCropAdd("artichoke", "Artichoke", 5, 6, 0, 0)

// crop materials

/obj/Items/Material/Crop
	icon = 'Icons/LifeSkills/FarmingMats.dmi'
	desc = "Fresh produce from a soil plot."
	var/tier = 1

/obj/Items/Material/Crop/radish { name = "Radish"; MaterialClass = "Radish"; icon_state = "radish"; tier = 1 }
/obj/Items/Material/Crop/lettuce { name = "Lettuce"; MaterialClass = "Lettuce"; icon_state = "lettuce"; tier = 1 }
/obj/Items/Material/Crop/spinach { name = "Spinach"; MaterialClass = "Spinach"; icon_state = "spinach"; tier = 1 }
/obj/Items/Material/Crop/turnip { name = "Turnip"; MaterialClass = "Turnip"; icon_state = "turnip"; tier = 1 }
/obj/Items/Material/Crop/peas { name = "Green Peas"; MaterialClass = "GreenPeas"; icon_state = "peas"; tier = 1 }
/obj/Items/Material/Crop/carrot { name = "Carrot"; MaterialClass = "Carrot"; icon_state = "carrot"; tier = 2 }
/obj/Items/Material/Crop/beetroot { name = "Beetroot"; MaterialClass = "Beetroot"; icon_state = "beetroot"; tier = 2 }
/obj/Items/Material/Crop/onion { name = "Onion"; MaterialClass = "Onion"; icon_state = "onion"; tier = 2 }
/obj/Items/Material/Crop/potato { name = "Potato"; MaterialClass = "Potato"; icon_state = "potato"; tier = 2 }
/obj/Items/Material/Crop/cucumber { name = "Cucumber"; MaterialClass = "Cucumber"; icon_state = "cucumber"; tier = 2 }
/obj/Items/Material/Crop/strawberry { name = "Strawberry"; MaterialClass = "Strawberry"; icon_state = "strawberry"; tier = 2 }
/obj/Items/Material/Crop/cabbage { name = "Cabbage"; MaterialClass = "Cabbage"; icon_state = "cabbage"; tier = 3 }
/obj/Items/Material/Crop/corn { name = "Corn"; MaterialClass = "Corn"; icon_state = "corn"; tier = 3 }
/obj/Items/Material/Crop/tomato { name = "Tomato"; MaterialClass = "Tomato"; icon_state = "tomato"; tier = 3 }
/obj/Items/Material/Crop/wheat { name = "Wheat"; MaterialClass = "Wheat"; icon_state = "wheat"; tier = 3 }
/obj/Items/Material/Crop/beans { name = "Pinto Beans"; MaterialClass = "PintoBeans"; icon_state = "beans"; tier = 3 }
/obj/Items/Material/Crop/zucchini { name = "Zucchini"; MaterialClass = "Zucchini"; icon_state = "zucchini"; tier = 3 }
/obj/Items/Material/Crop/leek { name = "Leek"; MaterialClass = "Leek"; icon_state = "leek"; tier = 3 }
/obj/Items/Material/Crop/broccoli { name = "Broccoli"; MaterialClass = "Broccoli"; icon_state = "broccoli"; tier = 4 }
/obj/Items/Material/Crop/eggplant { name = "Eggplant"; MaterialClass = "Eggplant"; icon_state = "eggplant"; tier = 4 }
/obj/Items/Material/Crop/bellpepper { name = "Bell Pepper"; MaterialClass = "BellPepper"; icon_state = "bellpepper"; tier = 4 }
/obj/Items/Material/Crop/blueberry { name = "Blueberry"; MaterialClass = "Blueberry"; icon_state = "blueberry"; tier = 4 }
/obj/Items/Material/Crop/raspberry { name = "Raspberry"; MaterialClass = "Raspberry"; icon_state = "raspberry"; tier = 4 }
/obj/Items/Material/Crop/garlic { name = "Garlic"; MaterialClass = "Garlic"; icon_state = "garlic"; tier = 4 }
/obj/Items/Material/Crop/sweetpotato { name = "Sweet Potato"; MaterialClass = "SweetPotato"; icon_state = "sweetpotato"; tier = 4 }
/obj/Items/Material/Crop/celery { name = "Celery"; MaterialClass = "Celery"; icon_state = "celery"; tier = 4 }
/obj/Items/Material/Crop/pumpkin { name = "Pumpkin"; MaterialClass = "Pumpkin"; icon_state = "pumpkin"; tier = 5 }
/obj/Items/Material/Crop/watermelon { name = "Watermelon"; MaterialClass = "Watermelon"; icon_state = "watermelon"; tier = 5 }
/obj/Items/Material/Crop/grapes { name = "Blue Grapes"; MaterialClass = "BlueGrapes"; icon_state = "grapes"; tier = 5 }
/obj/Items/Material/Crop/artichoke { name = "Artichoke"; MaterialClass = "Artichoke"; icon_state = "artichoke"; tier = 5 }

/obj/Items/Material/Crop/giant_cabbage { name = "Giant Cabbage"; MaterialClass = "GiantCabbage"; icon_state = "cabbage"; tier = 5 }
/obj/Items/Material/Crop/giant_cucumber { name = "Giant Cucumber"; MaterialClass = "GiantCucumber"; icon_state = "cucumber"; tier = 5 }
/obj/Items/Material/Crop/giant_pumpkin { name = "Giant Pumpkin"; MaterialClass = "GiantPumpkin"; icon_state = "pumpkin"; tier = 5 }
/obj/Items/Material/Crop/giant_tomato { name = "Giant Tomato"; MaterialClass = "GiantTomato"; icon_state = "tomato"; tier = 5 }
/obj/Items/Material/Crop/giant_zucchini { name = "Giant Zucchini"; MaterialClass = "GiantZucchini"; icon_state = "zucchini"; tier = 5 }

// farm tools

/obj/Items/FarmTool
	icon = 'Icons/LifeSkills/FarmTools.dmi'
	Savable = 1
	Grabbable = 1
	Cost = 0

/obj/Items/FarmTool/Hoe
	name = "Farmer's Hoe"
	icon_state = "hoe"
	desc = "Click it to till a soil plot where you stand. Click again on your plot to clear it."
	Click()
		if(!usr || loc != usr) return
		usr.UseHoe()

/obj/Items/FarmTool/WateringCan
	name = "Watering Can"
	icon_state = "wateringcan"
	desc = "Hold your Interact key at your seeded plot to water it."

mob/proc/UseHoe()
	var/turf/T = loc
	if(!isturf(T)) return
	var/obj/LifeSkills/FarmPlot/P = locate() in T
	if(P)
		if(P.owner_ckey != ckey)
			src << "That's [P.owner_name]'s plot."
			return
		if(P.crop_id) src << "<font color=#ff6464>You till the plot under - the [P.CropName()] is destroyed.</font>"
		else src << "You till the soil plot back under."
		del P
		return
	if(!(T.SecondaryTurfType in list("Grass", "Dirt")) || T.Water || T.density)
		src << "The ground here can't be tilled - find grass or dirt."
		return
	P = new(T)
	P.owner_ckey = ckey
	P.owner_name = name
	src << "You till a soil plot. Use your Interact key on it to plant a seed."

// the plot

/obj/LifeSkills/FarmPlot
	name = "soil plot"
	icon = 'Icons/LifeSkills/FarmPlots.dmi'
	icon_state = "plot_a"
	density = 0
	Savable = 1
	layer = TURF_LAYER + 0.2
	var/owner_ckey = ""
	var/owner_name = ""
	var/crop_id = ""
	var/needed = 0             // watered days to mature (rank snapshot at planting)
	var/grow_days = 0          // watered days banked
	var/wet_day = -1           // day index last fully watered
	var/wet_time = 0           // realtime at watering - drives the slow visual creep
	var/last_eval_day = 0
	var/missed_run = 0         // consecutive unwatered growth days
	var/wilted = 0
	var/will_giant = 0
	var/owner_rank = 0         // planter's Farming rank, drives the giant roll at maturity
	var/harvests_left = 0
	var/water_progress = 0     // 0..100, stored across interrupted watering
	var/tmp/obj/cropvis

	New()
		..()
		spawn(2) Evaluate()

	Del()
		if(cropvis) del cropvis
		..()

	proc/CropName()
		var/datum/farm_crop/d = FarmCropDef(crop_id)
		return d ? d.name : "crop"

	proc/Ready()
		return crop_id && !wilted && grow_days >= needed

	proc/Evaluate()
		var/today = FarmDay()
		if(!last_eval_day) last_eval_day = today
		if(!crop_id || wilted)
			last_eval_day = today
			UpdateVisual()
			return
		while(last_eval_day < today)
			if(grow_days >= needed)   // ripe crops wait dry, no wilt
				last_eval_day = today
				break
			if(wet_day == last_eval_day)
				grow_days++
				missed_run = 0
				if(grow_days >= needed) RollGiantAtMaturity()
			else
				missed_run++
				if(missed_run >= FARM_WILT_DAYS)
					wilted = 1
					water_progress = 0
					last_eval_day = today
					break
			last_eval_day++
		UpdateVisual()

	proc/VisualStage()
		if(!crop_id) return 0
		var/p = grow_days
		// watered plants creep over the hours since watering, never all at once
		if(wet_day == FarmDay() && grow_days < needed && wet_time)
			p += clamp((world.realtime - wet_time) / 864000, 0, 0.999)
		return min(5, round(p / max(1, needed) * 5))

	proc/UpdateVisual()
		icon_state = (crop_id && !wilted && wet_day == FarmDay() && grow_days < needed) ? "plot_a_wet" : "plot_a"
		if(!crop_id)
			if(cropvis) { vis_contents -= cropvis; del cropvis }
			return
		if(!cropvis)
			cropvis = new
			cropvis.mouse_opacity = 0
			cropvis.layer = layer + 0.1
			vis_contents += cropvis
		var/datum/farm_crop/d = FarmCropDef(crop_id)
		cropvis.pixel_x = 0
		if(wilted)
			cropvis.icon = 'Icons/LifeSkills/FarmCrops.dmi'
			cropvis.icon_state = "wilt"
			return
		var/vs = VisualStage()
		if(vs >= 5 && will_giant && d && d.giantable)
			if(crop_id == "pumpkin")
				cropvis.icon = 'Icons/LifeSkills/GiantPumpkin.dmi'
				cropvis.icon_state = "giant_pumpkin"
				cropvis.pixel_x = -8
			else
				cropvis.icon = 'Icons/LifeSkills/FarmGiants.dmi'
				cropvis.icon_state = "giant_[crop_id]"
		else
			cropvis.icon = 'Icons/LifeSkills/FarmCrops.dmi'
			cropvis.icon_state = "[crop_id]_[vs]"

	// a ripening crop has a small rank-scaled chance to come up giant
	proc/RollGiantAtMaturity()
		if(will_giant || !crop_id || wilted) return
		var/datum/farm_crop/d = FarmCropDef(crop_id)
		if(!d || !d.giantable) return
		if(prob(2 + owner_rank)) will_giant = 1

	proc/SetWatered()
		water_progress = 0
		wet_day = FarmDay()
		wet_time = world.realtime
		UpdateVisual()

	Examined(mob/M)
		Evaluate()
		var/datum/farm_crop/d = FarmCropDef(crop_id)
		if(!crop_id)
			M << "[owner_name]'s empty soil plot."
			return
		if(wilted)
			M << "[owner_name]'s plot - the [d.name] has wilted from neglect. Interact to clear it."
			return
		if(Ready())
			M << "[owner_name]'s plot - the [d.name] is ready to harvest!"
			return
		M << "[owner_name]'s plot - [d.name], day [min(grow_days + 1, needed)] of [needed]. [wet_day == FarmDay() ? "Watered for today." : "<font color=#ffd86b>Needs watering.</font>"]"

	InteractWith(mob/M)
		Evaluate()
		if(M.ckey != owner_ckey)
			M << "This is [owner_name]'s plot."
			return 1
		if(wilted)
			var/datum/farm_crop/d = FarmCropDef(crop_id)
			M << "You clear away the wilted [d ? d.name : "crop"]."
			crop_id = ""
			wilted = 0
			will_giant = 0
			water_progress = 0
			UpdateVisual()
			return 1
		if(!crop_id)
			M.client?.FarmPanelOpen("pick", src)
			return 1
		if(Ready())
			M.HarvestPlot(src)
			return 1
		if(wet_day == FarmDay())
			M << "The [CropName()] is watered for today - come back tomorrow."
			return 1
		if(!(locate(/obj/Items/FarmTool/WateringCan) in M))
			M << "You need a Watering Can to water your crops."
			return 1
		spawn() M.StartWaterPlot(src)
		return 1

// planting / watering / harvest

mob/var/list/farm_seeds
mob/var/LifeFarmGiantDay = -1

mob/proc/FarmSeedCount(id)
	if(!farm_seeds) farm_seeds = list()
	return farm_seeds[id] ? farm_seeds[id] : 0

mob/proc/FarmGiveSeeds(id, n)
	if(!farm_seeds) farm_seeds = list()
	farm_seeds[id] = FarmSeedCount(id) + n

mob/proc/PlantSeed(obj/LifeSkills/FarmPlot/P, id)
	if(!P || P.crop_id || P.wilted || P.owner_ckey != ckey) return
	if(get_dist(src, P) > 1) return
	var/datum/farm_crop/d = FarmCropDef(id)
	if(!d || FarmSeedCount(id) < 1) return
	var/rank = LifeRank("Farming")
	if(!LIFE_GATHER_GATE_OK(rank, LIFE_HUNT_DIFF(d.tier)))
		src << "<font color=#ff6464>That crop is beyond you. (Farming rank [LIFE_HUNT_DIFF(d.tier) - 1] required)</font>"
		return
	if(!UseLifeStamina(LIFE_COST_GATHER)) return
	farm_seeds[id] = FarmSeedCount(id) - 1
	P.crop_id = id
	P.needed = max(1, -round(-(d.base_days * (100 - FARM_GROW_CUT_PER_RANK * rank) / 100)))
	P.grow_days = 0
	P.wet_day = -1
	P.last_eval_day = FarmDay()
	P.missed_run = 0
	P.wilted = 0
	P.water_progress = 0
	P.harvests_left = d.multi ? FARM_MULTI_HARVESTS : 1
	// giants roll at ripening - only the capstone guarantees one at planting
	P.will_giant = 0
	P.owner_rank = rank
	if(d.giantable && rank >= LIFE_MAX_RANK && LifeFarmGiantDay != DaysOfWipe())
		P.will_giant = 1
		LifeFarmGiantDay = DaysOfWipe()
		src << "<b>Green Colossus: this one is going to be enormous.</b>"
	P.UpdateVisual()
	src << "You plant [d.name] seeds. Water them daily - ready in [P.needed] day[P.needed == 1 ? "" : "s"]."

mob/proc/StartWaterPlot(obj/LifeSkills/FarmPlot/P)
	if(!P || !client || client.life_minigame_sink) return
	if(Using) return
	Using = 1
	var/r = RunLifeMinigame(src, "water_fill", 1, list("plot" = P, "target" = P))
	Using = 0
	if(r >= 1)
		src << "<font color=#78eb78>The soil drinks deep - watered for today.</font>"
	else if(r == 0 && P && P.water_progress > 0)
		src << "You stop pouring at [P.water_progress]% - the soil holds what it got."

mob/proc/HarvestPlot(obj/LifeSkills/FarmPlot/P)
	if(!P || !P.Ready() || P.owner_ckey != ckey) return
	var/datum/farm_crop/d = FarmCropDef(P.crop_id)
	if(!d) return
	var/rank = LifeRank("Farming")
	var/datum/life_opp/o = LifeOppRoll("Farming", d.tier, null, QUAL_NORMAL, "farm_mod")
	var/amt = rand(3, 5) + round(rank / 3)
	if(prob(2 + rank))
		amt *= 2
		src << "<font color=#78eb78>A bumper crop!</font>"
	if(o) amt = max(amt + 1, round(amt * o.mag / 10))   // mag 15/20/30 = x1.5/x2/x3
	var/q = QUAL_NORMAL
	if(prob(2 * rank)) q++
	if(o && o.id == "mutant_growth") q++
	q = min(q, LifeQualityCap(rank))
	GiveMaterial(src, d.mtype, amt, q)
	LifeLogFind("Farming", d.name)
	src << "<font color=#78eb78>You harvest [amt]x [QualityName(q)] [d.name].</font>"
	if(P.will_giant && d.gtype)
		GiveMaterial(src, d.gtype, 1, min(QUAL_EPIC, LifeQualityCap(rank)))
		LifeLogFind("Farming", "Giant [d.name]")
		src << "<font color=#b46bff><b>You heave up a Giant [d.name]!</b></font>"
	if(prob(30)) FarmGiveSeeds(P.crop_id, 1 + (prob(25) ? 1 : 0))
	AddLifeXP("Farming", LifeGatherXP("Farming", d.tier), 1.0)
	P.harvests_left--
	if(P.harvests_left > 0)
		P.grow_days = P.needed - 1     // back to stage 4: one watered day per re-harvest
		P.wet_day = -1
		P.missed_run = 0
		P.last_eval_day = FarmDay()
		P.will_giant = 0               // giants only on the first pull
		src << "The [d.name] will fruit again - keep watering it. ([P.harvests_left] harvest[P.harvests_left == 1 ? "" : "s"] left)"
	else
		P.crop_id = ""
		P.will_giant = 0
	P.water_progress = 0
	P.UpdateVisual()

// consume wood from the log for smithing: lowest tier, lowest quality first
proc/LifeCountAnyWood(mob/M)
	. = 0
	for(var/mc in LifeMatsInCategory("Wood"))
		. += M.MatLogCount(mc)

proc/LifeConsumeAnyWood(mob/M, n)
	for(var/mc in LifeMatsInCategory("Wood"))
		for(var/q = QUAL_POOR to QUAL_LEGENDARY)
			var/take = M.MatLogTakeQ(mc, q, n)
			n -= take
			if(n <= 0) return 1
	return n <= 0

// seed stall

/obj/LifeSkills/SeedStall
	name = "seed stall"
	desc = "Seed bags for every farmable crop. Interact to browse."
	icon = 'Icons/LifeSkills/FarmTools.dmi'
	icon_state = "stall"
	density = 1
	Savable = 1
	InteractWith(mob/M)
		M.client?.FarmPanelOpen("shop", src)
		return 1
	Click()
		if(!usr || get_dist(usr, src) > 3) return
		usr.client?.FarmPanelOpen("shop", src)

proc/FarmSeedPrice(datum/farm_crop/d)
	return max(10, round(d.tier * d.tier * 0.02 * glob.progress.EconomyCost))

// seed panel (shop + planting picker)

#define FP_LAYER (FLY_LAYER + 4.6)
#define FP_W 260
#define FP_H 200
// the LS_* defines land after this file in the .dme, so local copies
#define FP_FONT "font-family:'monogram'; font-size:12pt"
#define FP_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"
#define FP_C_HINT "#7a9bb5"
#define FP_C_COST "#ffd86b"

/atom/movable/shud/fptext
	layer = FP_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type = "outline", size = 1, color = "#000000")

/atom/movable/shud/fppic
	layer = FP_LAYER
	mouse_opacity = 2

/atom/movable/shud/fpclick
	layer = FP_LAYER + 0.5
	mouse_opacity = 2
	var/cid
	MouseEntered(location, control, params)
		filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.FarmRowClick(cid)

/atom/movable/shud/fpwidget
	parent_type = /atom/movable/shud/pressbtn
	layer = FP_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.FarmPanelClose()

client
	var/tmp
		farm_mode = ""            // "" closed, "shop", "pick"
		atom/farm_obj
		farm_scroll = 0
		list/farm_hud
		list/farm_rows            // crop ids shown, in order
		farm_atx = 1
		farm_aty = 1

client/proc/FPloc(dx, dyTop, h = 0)
	var/py = FP_H - dyTop - h
	var/axp = ((dx % 32) + 32) % 32
	var/ayp = ((py % 32) + 32) % 32
	return "[farm_atx + (dx - axp) / 32]:[axp],[farm_aty + (py - ayp) / 32]:[ayp]"

client/proc/FpAdd(atom/movable/o)
	farm_hud += o
	screen += o

client/proc/FpText(dx, dyTop, w, h, txt, lay = 0.6)
	var/atom/movable/shud/fptext/T = new
	T.layer = FP_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = FPloc(dx, dyTop, h)
	T.maptext = txt
	FpAdd(T)
	return T

client/proc/FarmPanelOpen(mode, atom/A)
	if(!mob) return
	FarmPanelClose()
	RegisterFarmCrops()
	farm_mode = mode
	farm_obj = A
	farm_scroll = 0
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(FP_W / 32); if(mtw * 32 < FP_W) mtw++
	var/mth = round(FP_H / 32); if(mth * 32 < FP_H) mth++
	farm_atx = max(1, round((vw - mtw) / 2) + 1)
	farm_aty = max(1, round((vh - mth) / 2) + 1)
	farm_hud = list()
	var/atom/movable/shud/fppic/P = new
	P.icon = 'HUD/farm_panel.png'
	P.screen_loc = FPloc(0, 0, FP_H)
	FpAdd(P)
	var/atom/movable/shud/fpwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.screen_loc = FPloc(228, 8, 24)
	FpAdd(X)
	RefreshFarmPanel()

client/proc/FarmPanelClose()
	farm_mode = ""
	farm_obj = null
	if(farm_hud)
		for(var/atom/movable/o in farm_hud)
			screen -= o
			del o
	farm_hud = null
	farm_rows = null

client/proc/RefreshFarmPanel()
	if(!farm_mode || !mob) return
	// clear everything but the panel + close X (first two)
	while(farm_hud.len > 2)
		var/atom/movable/o = farm_hud[farm_hud.len]
		farm_hud.len--
		screen -= o
		del o
	var/mob/M = mob
	var/rank = M.LifeRank("Farming")
	FpText(0, 12, FP_W, 16, "<center><span style=\"[FP_FONT]; color:#8be9ff\">[farm_mode == "shop" ? "SEED STALL" : "PLANT A SEED"]</span></center>")
	farm_rows = list()
	if(farm_mode == "shop")
		for(var/id in FarmCropDefs) farm_rows += id
	else
		for(var/id in FarmCropDefs)
			if(M.FarmSeedCount(id) > 0) farm_rows += id
		if(!farm_rows.len)
			FpText(12, 90, 236, 28, "<center><span style=\"[FP_FONT_BODY]; color:[FP_C_HINT]\">No seeds. Buy some at a seed stall.</span></center>")
			return
	var/maxscroll = max(0, farm_rows.len - FARM_PANEL_ROWS)
	farm_scroll = clamp(farm_scroll, 0, maxscroll)
	var/dy = 36
	for(var/i = farm_scroll + 1 to min(farm_rows.len, farm_scroll + FARM_PANEL_ROWS))
		var/id = farm_rows[i]
		var/datum/farm_crop/d = FarmCropDef(id)
		var/locked = !LIFE_GATHER_GATE_OK(rank, LIFE_HUNT_DIFF(d.tier))
		var/atom/movable/shud/fpclick/band = new
		band.icon = 'HUD/farm_band.png'
		band.layer = FP_LAYER + 0.42
		band.cid = id
		band.screen_loc = FPloc(12, dy + 2, 18)
		FpAdd(band)
		var/atom/movable/shud/fpclick/ic = new
		ic.icon = 'Icons/LifeSkills/FarmingMats.dmi'
		ic.icon_state = "[id]_bag"
		ic.cid = id
		ic.screen_loc = FPloc(16, dy + 3, 16)
		FpAdd(ic)
		FpText(38, dy + 2, 120, 14, "<span style=\"[FP_FONT_BODY]; color:[locked ? FP_C_HINT : "#ffffff"]\">[d.name]</span>")
		var/right
		if(farm_mode == "shop")
			var/price = FarmSeedPrice(d)
			right = locked ? "rank [LIFE_HUNT_DIFF(d.tier) - 1]" : "$[Commas(price)]"
		else
			right = locked ? "rank [LIFE_HUNT_DIFF(d.tier) - 1]" : "x[M.FarmSeedCount(id)]"
		FpText(158, dy + 2, 86, 14, "<span style=\"[FP_FONT_BODY]; color:[locked ? FP_C_HINT : FP_C_COST]; text-align:right\">[right]</span>", 0.62)
		dy += 22
	if(maxscroll)
		FpText(12, 177, 236, 12, "<center><span style=\"[FP_FONT_BODY]; color:[FP_C_HINT]\">scroll - [farm_scroll + 1]-[min(farm_rows.len, farm_scroll + FARM_PANEL_ROWS)] / [farm_rows.len]</span></center>")

client/proc/FarmWheelScroll(delta_y)
	if(!farm_mode) return 0
	farm_scroll += (delta_y > 0 ? -1 : 1)
	RefreshFarmPanel()
	return 1

client/proc/FarmRowClick(id)
	if(!farm_mode || !mob || !id) return
	var/mob/M = mob
	var/datum/farm_crop/d = FarmCropDef(id)
	if(!d) return
	if(!farm_obj || get_dist(M, farm_obj) > 3)
		FarmPanelClose()
		return
	var/rank = M.LifeRank("Farming")
	if(!LIFE_GATHER_GATE_OK(rank, LIFE_HUNT_DIFF(d.tier)))
		M << "<font color=#ff6464>You need Farming rank [LIFE_HUNT_DIFF(d.tier) - 1] for [d.name].</font>"
		return
	if(farm_mode == "shop")
		var/price = FarmSeedPrice(d)
		if(!M.HasMoney(price))
			M << "<font color=#ff6464>You can't afford [d.name] seeds. ($[Commas(price)])</font>"
			return
		M.TakeMoney(price)
		M.FarmGiveSeeds(id, 1)
		M << "Bought [d.name] seeds. (x[M.FarmSeedCount(id)])"
		RefreshFarmPanel()
	else
		var/obj/LifeSkills/FarmPlot/P = farm_obj
		FarmPanelClose()
		M.PlantSeed(P, id)

proc/FarmGrowthLoop()
	set background = 1
	while(1)
		sleep(600)
		for(var/obj/LifeSkills/FarmPlot/P in world)
			P.Evaluate()
			sleep(-1)

mob/Admin4/verb/farmSpawnSeedStall()
	set category = "Admin"
	new/obj/LifeSkills/SeedStall(loc)
	src << "Seed stall placed."

mob/Admin4/verb/farmGiveAllSeeds()
	set category = "Admin"
	RegisterFarmCrops()
	for(var/id in FarmCropDefs)
		FarmGiveSeeds(id, 5)
	src << "5 of every seed."

mob/Admin4/verb/farmGrowDay()
	set category = "Admin"
	var/grew = 0
	var/missed = 0
	for(var/obj/LifeSkills/FarmPlot/P in world)
		if(P.owner_ckey != ckey || !P.crop_id || P.wilted) continue
		P.Evaluate()
		if(P.wilted || P.grow_days >= P.needed)
			continue
		if(P.wet_day == FarmDay())
			P.grow_days++
			P.missed_run = 0
			if(P.grow_days >= P.needed) P.RollGiantAtMaturity()
			grew++
		else
			P.missed_run++
			missed++
			if(P.missed_run >= FARM_WILT_DAYS)
				P.wilted = 1
				P.water_progress = 0
		P.wet_day = -1
		P.wet_time = 0
		P.UpdateVisual()
	src << "A day passes: [grew] watered plot[grew == 1 ? "" : "s"] grew, [missed] dry plot[missed == 1 ? "" : "s"] missed the day."
