#define BUILD_JOURNAL "Saves/BuildJournal.txt"
#define BUILD_JOURNAL_SAVING "Saves/BuildJournal.saving.txt"
#define OBJECT_SAVE_CHUNK 100

var/list/worldObjectList = list()
var/worldSaveBusy = 0
var/worldSaveRefused = 0
var/turfLoadState = 0
var/turfLoadCount = 0
var/customTurfLoadState = 0
var/customTurfLoadCount = 0
var/objectLoadState = 0
var/objectLoadCount = 0
var/objectSaveJournalCut = 0
var/worldObjectLoading = 0
var/savefile/_objTwinBuffer
var/regex/_objTwinStrip

proc/BootSeconds(t0)
	var/d = world.timeofday - t0
	if(d < 0)
		d += 864000
	return round(d) / 10

proc/ObjectSaveSafe()
	if(fexists("Saves/Itemsave/File1") && objectLoadState != 2)
		worldSaveRefused = 1
		if(objectLoadState == 3)
			Log("Mapper", "OBJECT SAVE REFUSED: the object load reported problems this boot (see the Object load lines above). Saving now could make them permanent.", 1)
			world << "<small><font color=red>Server: object save SKIPPED - the object load reported problems this boot. Tell an admin before anyone saves.</font>"
		else
			Log("Mapper", "OBJECT SAVE REFUSED: the object save on disk never finished loading this boot (state [objectLoadState]). Saving now would overwrite it.", 1)
			world << "<small><font color=red>Server: object save SKIPPED - the saved objects never finished loading this boot. Tell an admin before anyone saves.</font>"
		return 0
	return 1

proc/ObjectSaveFailed(reason)
	worldSaveRefused = 1
	Log("Mapper", "OBJECT SAVE FAILED: [reason].", 1)
	world << "<small><font color=red>Server: object save FAILED - [reason]. Tell an admin before anyone saves again.</font>"

proc/ObjectCommitMark(files)
	if(fexists("Saves/Itemsave/Commit"))
		fdel("Saves/Itemsave/Commit")
	text2file("[files]", "Saves/Itemsave/Commit")

proc/ObjectSaveCommit(files)
	for(var/i = 1 to files)
		if(fexists("Saves/Itemsave/Stage[i]"))
			if(!fcopy("Saves/Itemsave/Stage[i]", "Saves/Itemsave/File[i]"))
				return 0
			fdel("Saves/Itemsave/Stage[i]")
	var/cleanup_file = files + 1
	while(fexists("Saves/Itemsave/File[cleanup_file]"))
		fdel("Saves/Itemsave/File[cleanup_file]")
		cleanup_file++
	fdel("Saves/Itemsave/Commit")
	return 1

proc/ObjectSaveRecover()
	if(!fexists("Saves/Itemsave/Commit"))
		return 1
	var/n = text2num(trimtext(file2text("Saves/Itemsave/Commit")))
	if(!isnum(n) || n < 0)
		fdel("Saves/Itemsave/Commit")
		return 1
	Log("Mapper", "Object save: finishing an interrupted commit of [n] file\s.", 1)
	return ObjectSaveCommit(n)

proc/ObjOnSwapMap(atom/A)
	if(!A || !swapmaps_loaded || A.z <= swapmaps_compiled_maxz)
		return 0
	for(var/swapmap/M in swapmaps_loaded)
		if(A.z >= M.z1 && A.z <= M.z2)
			return 1
	return 0

proc/ObjectSaveSnapshot()
	var/list/chunks = list()
	var/list/written = list()
	var/list/Types = list()
	for(var/obj/A in global.worldObjectList)
		if(written[A] || !A.Savable || A.gfx_transient_visual || !isturf(A.loc) || ObjOnSwapMap(A))
			continue
		written[A] = 1
		A.Saved_X = A.x
		A.Saved_Y = A.y
		A.Saved_Z = A.z
		Types += A
		if(Types.len >= OBJECT_SAVE_CHUNK)
			chunks += list(Types)
			Types = list()
	if(Types.len)
		chunks += list(Types)
	objectSaveJournalCut = fexists(BUILD_JOURNAL) ? length(file2text(BUILD_JOURNAL)) : 0
	return chunks

proc/BuildJournalStripObjectLines(t)
	var/list/keep = list()
	for(var/line in splittext(replacetext("[t]", ascii2text(13), ""), "\n"))
		if(!length(trimtext(line)) || findtext(line, "OC\t") == 1 || findtext(line, "OD\t") == 1)
			continue
		keep += line
	return keep.len ? jointext(keep, "\n") + "\n" : ""

proc/BuildJournalDropObjectLines()
	if(worldSaveRefused && fexists(BUILD_JOURNAL_SAVING))
		var/held = BuildJournalStripObjectLines(file2text(BUILD_JOURNAL_SAVING))
		fdel(BUILD_JOURNAL_SAVING)
		if(length(held))
			text2file(held, BUILD_JOURNAL_SAVING)
	if(objectSaveJournalCut > 0 && fexists(BUILD_JOURNAL))
		var/t = file2text(BUILD_JOURNAL)
		var/rawHead = copytext(t, 1, objectSaveJournalCut + 1)
		if(findtext(rawHead, "OC\t") || findtext(rawHead, "OD\t"))
			var/head = BuildJournalStripObjectLines(rawHead)
			var/tail = copytext(t, objectSaveJournalCut + 1)
			fdel(BUILD_JOURNAL)
			if(length(head) || length(trimtext(tail)))
				text2file("[head][tail]", BUILD_JOURNAL)
	objectSaveJournalCut = 0

proc/ObjTwinDedupable(obj/O)
	return O && !istype(O, /obj/Items) && !istype(O, /obj/Money)

proc/ObjIconSame(a, b)
	if(a == b)
		return 1
	if(!a || !b)
		return 0
	if(!_objTwinBuffer)
		_objTwinBuffer = new
	_objTwinBuffer["i"] << a
	var/ta = _objTwinBuffer.ExportText("i")
	_objTwinBuffer["i"] << b
	var/tb = _objTwinBuffer.ExportText("i")
	_objTwinBuffer.dir.Remove("i")
	return ta == tb

proc/ObjTwinSignature(obj/O)
	if(!O)
		return ""
	if(!_objTwinBuffer)
		_objTwinBuffer = new
	if(!_objTwinStrip)
		_objTwinStrip = regex(@"(^|\n)\s*(transform|appearance_flags|Saved_X|Saved_Y|Saved_Z) = [^\n]*", "g")
	_objTwinBuffer["o"] << O
	var/t = _objTwinBuffer.ExportText("o")
	_objTwinBuffer.dir.Remove("o")
	return md5(_objTwinStrip.Replace(t, ""))

proc/ObjTwinOnTurf(obj/O, turf/T, list/sigCache)
	if(!O || !T)
		return null
	var/sig
	for(var/obj/X in T)
		if(X == O || X.type != O.type || X.gfx_transient_visual)
			continue
		if(X.icon != O.icon || X.icon_state != O.icon_state || X.dir != O.dir || X.pixel_x != O.pixel_x || X.pixel_y != O.pixel_y || X.layer != O.layer)
			continue
		if(istype(O, /obj/Turfs/CustomObj1) && X:custom_def != O:custom_def)
			continue
		if(!sig)
			sig = ObjTwinSignature(O)
		var/xs = sigCache ? sigCache[X] : null
		if(!xs)
			xs = ObjTwinSignature(X)
			if(sigCache)
				sigCache[X] = xs
		if(xs == sig)
			return X
	if(sig && sigCache)
		sigCache[O] = sig
	return null

proc/ObjPlacementTwin(obj/O)
	var/turf/T = O?.loc
	if(!isturf(T))
		return null
	if(O.sp_recolor)
		SurfaceApply(O)
	for(var/obj/X in T)
		if(X == O || X.type != O.type || X.gfx_transient_visual)
			continue
		if(X.icon_state != O.icon_state || X.dir != O.dir)
			continue
		if(X.pixel_x != O.pixel_x || X.pixel_y != O.pixel_y || X.layer != O.layer)
			continue
		if(X.density != O.density || X.opacity != O.opacity || X.name != O.name || X.desc != O.desc || X.color != O.color || X.alpha != O.alpha)
			continue
		if(istype(O, /obj/Turfs/CustomObj1) && X:custom_def != O:custom_def)
			continue
		if(istype(O, /obj/Special/Teleporter2) && (X:gotoX != O:gotoX || X:gotoY != O:gotoY || X:gotoZ != O:gotoZ))
			continue
		if(!ObjIconSame(X.icon, O.icon))
			continue
		return X
	return null

proc/WorldObjectListPrune()
	var/list/known = list()
	var/list/keep = list()
	for(var/obj/o in global.worldObjectList)
		if(known[o] || !isturf(o.loc))
			continue
		known[o] = 1
		keep += o
	global.worldObjectList.Cut()
	global.worldObjectList += keep
	return known

proc/WorldSaveBegin()
	WorldSaveLock()
	worldSaveRefused = 0
	objectSaveJournalCut = 0
	if(fexists(BUILD_JOURNAL))
		var/t = file2text(BUILD_JOURNAL)
		if(length(t))
			text2file(t, BUILD_JOURNAL_SAVING)
		fdel(BUILD_JOURNAL)

proc/WorldSaveEnd()
	if(fexists(BUILD_JOURNAL_SAVING))
		if(!worldSaveRefused)
			fdel(BUILD_JOURNAL_SAVING)
		else
			var/held = file2text(BUILD_JOURNAL_SAVING)
			var/fresh = fexists(BUILD_JOURNAL) ? file2text(BUILD_JOURNAL) : ""
			if(fexists(BUILD_JOURNAL))
				fdel(BUILD_JOURNAL)
			text2file("[held][fresh]", BUILD_JOURNAL)
			fdel(BUILD_JOURNAL_SAVING)
	worldSaveBusy = 0

proc/MapSaveSafe()
	if(fexists("Saves/Map/File1") && turfLoadState != 2)
		worldSaveRefused = 1
		Log("Mapper", "MAP SAVE REFUSED: the turf save on disk never finished loading this boot (state [turfLoadState]). Saving now would overwrite it with the compiled map.", 1)
		world << "<small><font color=red>Server: map save SKIPPED - the saved turfs never finished loading this boot. Tell an admin before anyone saves.</font>"
		return 0
	if(turfLoadState == 2 && turfLoadCount > 0 && Turfs.len < turfLoadCount * 0.8)
		worldSaveRefused = 1
		Log("Mapper", "MAP SAVE REFUSED: [Turfs.len] turfs in memory but [turfLoadCount] were loaded from disk; refusing to overwrite the save.", 1)
		world << "<small><font color=red>Server: map save SKIPPED - far fewer turfs in memory than were loaded from disk. Tell an admin before anyone saves.</font>"
		return 0
	if(fexists("Saves/Map/CustomTurfs1") && customTurfLoadState != 2)
		worldSaveRefused = 1
		Log("Mapper", "MAP SAVE REFUSED: the custom turf save on disk never finished loading this boot (state [customTurfLoadState]).", 1)
		world << "<small><font color=red>Server: map save SKIPPED - the saved custom turfs never finished loading this boot. Tell an admin before anyone saves.</font>"
		return 0
	if(customTurfLoadState == 2 && customTurfLoadCount > 0 && CustomTurfs.len < customTurfLoadCount * 0.8)
		worldSaveRefused = 1
		Log("Mapper", "MAP SAVE REFUSED: [CustomTurfs.len] custom turfs in memory but [customTurfLoadCount] were loaded from disk; refusing to overwrite the save.", 1)
		world << "<small><font color=red>Server: map save SKIPPED - far fewer custom turfs in memory than were loaded from disk. Tell an admin before anyone saves.</font>"
		return 0
	return 1


proc/WorldSaveLock()
	while(worldSaveBusy && world.time - worldSaveBusy < 3000)
		sleep(world.tick_lag)
	worldSaveBusy = max(1, world.time)

/mob/Admin4/verb/checkworldObjectList()
	var/before = length(worldObjectList)
	WorldObjectListPrune()
	usr << "<small>Server: worldObjectList [before] -> [length(worldObjectList)] (dead, off-map and repeated entries removed)."

/mob/Admin4/verb/DeduplicateTurfList()
	set name = "Dedup Turfs List"
	set category = "Admin"
	set background = 1
	usr << "<small>Server: Deduplicating Turfs lists. This may take a moment..."

	var/turfs_before = length(global.Turfs)
	var/customturfs_before = length(global.CustomTurfs)
	var/turfs_nonturf = 0
	var/customturfs_nonturf = 0
	var/i = 0

	var/list/seen = list()
	for(var/A in global.Turfs)
		i++
		if(i % 5000 == 0) sleep(-1)
		if(!istype(A, /turf))
			turfs_nonturf++
			continue
		var/turf/T = A
		var/key = "[T.x],[T.y],[T.z]"
		if(!seen[key]) seen[key] = T
	global.Turfs.Cut()
	for(var/k in seen) global.Turfs += seen[k]

	sleep(-1)

	seen = list()
	i = 0
	for(var/A in global.CustomTurfs)
		i++
		if(i % 5000 == 0) sleep(-1)
		if(!istype(A, /turf/CustomTurf))
			customturfs_nonturf++
			continue
		var/turf/CustomTurf/T = A
		var/key = "[T.x],[T.y],[T.z]"
		if(!seen[key]) seen[key] = T
	global.CustomTurfs.Cut()
	for(var/k in seen) global.CustomTurfs += seen[k]

	var/turfs_after = length(global.Turfs)
	var/customturfs_after = length(global.CustomTurfs)
	if(turfLoadCount > 0)
		turfLoadCount = max(0, turfLoadCount - (turfs_before - turfs_after))
	if(customTurfLoadCount > 0)
		customTurfLoadCount = max(0, customTurfLoadCount - (customturfs_before - customturfs_after))
	usr << "<small>Server: Turfs:        [turfs_before] -> [turfs_after] (removed [turfs_before - turfs_after]; [turfs_nonturf] were non-turf entries)"
	usr << "<small>Server: CustomTurfs:  [customturfs_before] -> [customturfs_after] (removed [customturfs_before - customturfs_after]; [customturfs_nonturf] were non-turf entries)"
	usr << "<small>Server: Run a world save now."

proc/find_savableObjects()
	var/list/known = WorldObjectListPrune()
	var/chunkCount = 0
	for(var/obj/_object in world)
		if(++chunkCount % 5000 == 0)
			sleep(world.tick_lag)
		if(known[_object] || _object.Savable != 1 || _object.gfx_transient_visual || !isturf(_object.loc))
			continue
		global.worldObjectList += _object
		known[_object] = 1

proc/Save_Custom_Turfs(quiet = 0)
	set background = 1
	if(!MapSaveSafe())
		return
	if(!quiet)
		world<<"<small>Server: Saving Custom Turfs..."
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Map/CustomTurfs[E]")
	var/list/Types=list()
	var/list/Healths=list()
	var/list/Levels=list()
	var/list/Builders=list()
	var/list/Xs=list()
	var/list/Ys=list()
	var/list/Zs=list()
	var/list/Icons=list()
	var/list/Icons_States=list()
	var/list/Densitys=list()
	var/list/isRoof=list()
	var/list/Opacitys=list()
	var/list/FlyOver=list()
	var/list/isOutside=list()
	var/list/isUnderwater=list()
	var/list/Destructable=list()
	var/list/EdgeOpt=list()
	var/list/Defs=list()
	var/list/turfSnapshot = CustomTurfs.Copy()
	for(var/turf/CustomTurf/A in turfSnapshot)
		if(A)
			Types+=A.type
			Healths+="[num2text(round(A.Health),100)]"
			Levels+="[num2text(A.Level,100)]"
			Builders+=A.Builder
			Xs+=A.x
			Ys+=A.y
			Zs+=A.z

			Icons += A.icon
			Icons_States+=A.icon_state
			Densitys+=A.density
			isRoof+=A.Roof
			Opacitys+=A.opacity
			FlyOver+=A.FlyOverAble
			isOutside+=A.isOutside
			isUnderwater+=A.isUnderwater
			Destructable+=A.Destructable
			EdgeOpt+=A.EdgeOptOut
			Defs+=A.custom_def
			Amount+=1
			if(Amount % 5000 == 0)
				F["Types"]<<Types
				F["Healths"]<<Healths
				F["Levels"]<<Levels
				F["Builders"]<<Builders
				F["Xs"]<<Xs
				F["Ys"]<<Ys
				F["Zs"]<<Zs
				F["Icons"]<<Icons
				F["Icons_States"]<<Icons_States
				F["Densitys"]<<Densitys
				F["isRoof"]<<isRoof
				F["Opacitys"]<<Opacitys
				F["FlyOver"]<<FlyOver
				F["isOutside"]<<isOutside
				F["isUnderwater"]<<isUnderwater
				F["Destructable"]<<Destructable
				F["EdgeOpt"]<<EdgeOpt
				F["Defs"]<<Defs
				E ++
				sleep(world.tick_lag)
				F=new("Saves/Map/CustomTurfs[E]")
				Types=list()
				Healths=list()
				Levels=list()
				Builders=list()
				Xs=list()
				Ys=list()
				Zs=list()
				Icons=list()
				Icons_States=list()
				Densitys=list()
				isRoof=list()
				Opacitys=list()
				FlyOver=list()
				isOutside=list()
				isUnderwater=list()
				Destructable=list()
				EdgeOpt=list()
				Defs=list()

	if(Amount % 5000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["Icons"]<<Icons
		F["Icons_States"]<<Icons_States
		F["Densitys"]<<Densitys
		F["isRoof"]<<isRoof
		F["Opacitys"]<<Opacitys
		F["FlyOver"]<<FlyOver
		F["isOutside"]<<isOutside
		F["isUnderwater"]<<isUnderwater
		F["Destructable"]<<Destructable
		F["EdgeOpt"]<<EdgeOpt
		F["Defs"]<<Defs

	F = null
	var/cleanup_file = (Amount % 5000) ? E + 1 : E
	while(fexists("Saves/Map/CustomTurfs[cleanup_file]"))
		fdel("Saves/Map/CustomTurfs[cleanup_file]")
		cleanup_file++
	if(!quiet)
		world<<"<small>Server: Custom Turfs Saved([Amount])."

proc/Load_Custom_Turfs()
	set background = 1
	if(fexists("Saves/Map/CustomTurfs1"))
		world<<"<small>Server: Loading Custom Turfs..."
		customTurfLoadState = 1
		var/DebugAmount= 0
		var/E=1
		while(fexists("Saves/Map/CustomTurfs[E]"))
			var/savefile/F=new("Saves/Map/CustomTurfs[E]")
			var/list/Types=F["Types"]
			var/list/Healths=F["Healths"]
			var/list/Levels=F["Levels"]
			var/list/Builders=F["Builders"]
			var/list/Xs=F["Xs"]
			var/list/Ys=F["Ys"]
			var/list/Zs=F["Zs"]
			var/list/Icons=F["Icons"]
			var/list/Icons_States=F["Icons_States"]
			var/list/Densitys=F["Densitys"]
			var/list/isRoof=F["isRoof"]
			var/list/Opacitys=F["Opacitys"]
			var/list/FlyOver=F["FlyOver"]
			var/list/isOutside=F["isOutside"]
			var/list/isUnderwater=F["isUnderwater"]
			var/list/Destructable=F["Destructable"]
			var/list/EdgeOpt=F["EdgeOpt"]
			var/list/Defs=F["Defs"]
			var/Amount = 0
			for(var/A in Types)
				Amount+=1
				DebugAmount += 1
				var/turf/CustomTurf/T=new A(locate(Xs[Amount],Ys[Amount],Zs[Amount]))
				T.icon = Icons[Amount]
				T.icon_state= Icons_States[Amount]
				T.density=Densitys[Amount]
				T.opacity=Opacitys[Amount]
				T.Roof=isRoof[Amount]
				T.Health=text2num(Healths[Amount])
				T.Level=text2num(Levels[Amount])
				T.Builder=Builders[Amount]
				T.FlyOverAble=FlyOver[Amount]
				T.isOutside=isOutside[Amount]
				T.isUnderwater=isUnderwater[Amount]
				T.Destructable=Destructable[Amount]
				T.EdgeOptOut=(EdgeOpt && EdgeOpt.len>=Amount) ? EdgeOpt[Amount] : 0
				T.custom_def=(Defs && Defs.len>=Amount && istext(Defs[Amount])) ? Defs[Amount] : ""
				BuildCustomDefForTurf(T)
				CustomTurfs+=T

				for(var/obj/Turfs/B in T) if(!B.Builder) del(B)

				if(Amount % 5000 == 0)
					sleep(world.tick_lag)
			E ++
		customTurfLoadCount = DebugAmount
		customTurfLoadState = 2
		world<<"<small>Server: Custom Turfs Loaded ([DebugAmount] in [E - 1] Files.)"
	else
		customTurfLoadState = 2

proc/Save_Turfs(quiet = 0)
	set background = 1
	if(!MapSaveSafe())
		return
	if(!quiet)
		world<<"<small>Server: Saving Map..."
	var/Amount=0
	var/E=1
	var/savefile/F=new("Saves/Map/File[E]")
	var/list/Types=list()
	var/list/Healths=list()
	var/list/Levels=list()
	var/list/Builders=list()
	var/list/Xs=list()
	var/list/Ys=list()
	var/list/Zs=list()
	var/list/FlyOver=list()
	var/list/isOutside=list()
	var/list/isUnderwater=list()
	var/list/Destructable=list()
	var/list/EdgeOpt=list()


	var/list/turfSnapshot = Turfs.Copy()
	for(var/turf/A in turfSnapshot)
		if(A)
			Types+=A.type
			Healths+="[num2text(round(A.Health),100)]"
			Levels+="[num2text(A.Level,100)]"
			Builders+=A.Builder
			Xs+=A.x
			Ys+=A.y
			Zs+=A.z
			FlyOver+=A.FlyOverAble
			isOutside+=A.isOutside
			isUnderwater+=A.isUnderwater
			Destructable+=A.Destructable
			EdgeOpt+=A.EdgeOptOut
			Amount+=1
			if(Amount % 5000 == 0)
				F["Types"]<<Types
				F["Healths"]<<Healths
				F["Levels"]<<Levels
				F["Builders"]<<Builders
				F["Xs"]<<Xs
				F["Ys"]<<Ys
				F["Zs"]<<Zs
				F["FlyOver"]<<FlyOver
				F["isOutside"]<<isOutside
				F["isUnderwater"]<<isUnderwater
				F["Destructable"]<<Destructable
				F["EdgeOpt"]<<EdgeOpt
				E ++
				sleep(world.tick_lag)
				F=new("Saves/Map/File[E]")
				Types=list()
				Healths=list()
				Levels=list()
				Builders=list()
				Xs=list()
				Ys=list()
				Zs=list()
				FlyOver=list()
				isOutside=list()
				isUnderwater=list()
				Destructable=list()
				EdgeOpt=list()


	if(Amount % 5000 != 0)
		F["Types"]<<Types
		F["Healths"]<<Healths
		F["Levels"]<<Levels
		F["Builders"]<<Builders
		F["Xs"]<<Xs
		F["Ys"]<<Ys
		F["Zs"]<<Zs
		F["FlyOver"]<<FlyOver
		F["isOutside"]<<isOutside
		F["isUnderwater"]<<isUnderwater
		F["Destructable"]<<Destructable
		F["EdgeOpt"]<<EdgeOpt


	F = null
	var/cleanup_file = (Amount % 5000) ? E + 1 : E
	while(fexists("Saves/Map/File[cleanup_file]"))
		fdel("Saves/Map/File[cleanup_file]")
		cleanup_file++
	if(!quiet)
		world<<"<small>Server: Map Saved([Amount])."

proc/Load_Turfs()
	set background = 1
	if(fexists("Saves/Map/File1"))
		world<<"<small>Server: Loading Map..."
		turfLoadState = 1
		var/DebugAmount= 0
		var/E=1
		while(fexists("Saves/Map/File[E]"))
			var/savefile/F=new("Saves/Map/File[E]")
			var/list/Types=F["Types"]
			var/list/Healths=F["Healths"]
			var/list/Levels=F["Levels"]
			var/list/Builders=F["Builders"]
			var/list/Xs=F["Xs"]
			var/list/Ys=F["Ys"]
			var/list/Zs=F["Zs"]
			var/list/FlyOver=F["FlyOver"]
			var/list/isOutside=F["isOutside"]
			var/list/isUnderwater=F["isUnderwater"]
			var/list/Destructable=F["Destructable"]
			var/list/EdgeOpt=F["EdgeOpt"]
			var/Amount = 0
			for(var/A in Types)
				Amount+=1
				DebugAmount += 1
				var/turf/T=new A(locate(Xs[Amount],Ys[Amount],Zs[Amount]))
				T.Health=text2num(Healths[Amount])
				T.Level=text2num(Levels[Amount])
				T.Builder=Builders[Amount]
				T.FlyOverAble=FlyOver[Amount]
				T.isOutside=isOutside[Amount]
				T.isUnderwater=isUnderwater[Amount]
				T.Destructable=Destructable[Amount]
				T.EdgeOptOut=(EdgeOpt && EdgeOpt.len>=Amount) ? EdgeOpt[Amount] : 0
				if(istype(T,/turf/Special/EventStars))
					T.icon_state="[rand(1,2500)]"
				Turfs+=T

				for(var/obj/Turfs/B in T) if(!B.Builder) del(B)

				if(Amount % 5000 == 0)
					sleep(world.tick_lag)
			E ++
		turfLoadCount = DebugAmount
		turfLoadState = 2
		world<<"<small>Server: Map Loaded ([DebugAmount] in [E - 1] Files.)"
	else
		turfLoadState = 2





var/list/Builds=list()
var/list/AdminBuilds=list()
var/global/buildsInit = 0

proc/Add_Builds()
	if(buildsInit)
		return
	buildsInit = 1
	var/obj/Turfs/CustomObj1/customobj = new
	var/obj/Others/Build/E = new
	E.icon = customobj.icon
	E.icon_state = customobj.icon_state
	E.Creates = customobj.type
	E.name ="-[customobj.name]-"
	Builds += E
	var/turf/CustomTurf/customturf = new(locate(1,1,1))
	var/obj/Others/Build/J = new
	J.icon = customturf.icon
	J.icon_state = customturf.icon_state
	J.Creates = customturf.type
	J.name ="-[customturf.name]-"
	Builds += J
	for(var/A in subtypesof(/obj/Turfs))
		if(!ispath(A)) continue
		var/obj/B = new A
		if(!B) continue
		if(B.Buildable&& B.name!="DBR")
			var/obj/Others/Build/C=new
			C.icon=B.icon
			C.icon_state=B.icon_state
			C.Creates=B.type
			C.dir=B.dir
			C.name="-[B.name]-"
			Builds+=C
	for(var/A in subtypesof(/obj/KatieObj))
		if(!ispath(A)) continue
		var/obj/B=new A
		if(!B) continue
		var/obj/Others/Build/C=new
		C.icon=B.icon
		C.icon_state=B.icon_state
		C.Creates=B.type
		C.dir=B.dir
		C.name="-[B.name]-"
		Builds+=C

	for(var/A in subtypesof(/turf))
		var/turf/C=new A(locate(1,1,1))
		if(C.Buildable && C.name!="DBR")

			var/obj/Others/Build/B=new
			B.icon=C.icon
			B.icon_state=C.icon_state
			B.Creates=C.type
			B.name="-[C.name]-"
			Builds+=B
		del(C)

/obj/Turfs/Newturfs
	Industrial
		name = "Industrial"
		icon = 'Mapping/NewIcons/Industrial.dmi'
	IndustrialBridge
		name = "Industrial Bridge"
		icon = 'Mapping/NewIcons/IndustrialBridge.dmi'
	IndustrialFences
		name = "Industrial Fences"
		icon = 'Mapping/NewIcons/IndustrialFences.dmi'
	IndustrialHouses
		name = "Industrial Houses"
		icon = 'Mapping/NewIcons/IndustrialHouses.dmi'
	IndustrialRoad
		name = "Industrial Road"
		icon = 'Mapping/NewIcons/IndustrialRoad.dmi'
	IndustrialProps
		name = "Industrial Props"
		icon = 'Mapping/NewIcons/IndustrialProps.dmi'
	IndustrialShops
		name = "Industrial Shops"
		icon = 'Mapping/NewIcons/IndustrialShops.dmi'
	IndustrialWall
		name = "Industrial Wall"
		icon = 'Mapping/NewIcons/IndustrialWall.dmi'




obj/Others/Build
	var/Creates
	var/Temp
	verb/IndoorOutdoorToggle()
		set src in world
		if(usr.Inside==0)
			usr.Inside=1
			usr<<"You will now build 'inside' turfs that will not be affected by weather."
		else if(usr.Inside==1)
			usr.Inside=0
			usr<<"You will now build 'outside' turfs that will be affected by weather."
	verb/ShallowToggle()
		set src in world
		if(usr.ShallowMode==0)
			usr.ShallowMode=1
			usr<<"You will now build 'shallow' water that will not drain your energy when entered."
		else if(usr.ShallowMode==1)
			usr.ShallowMode=0
			usr<<"You will now build water tiles that drain your energy when entered."
	verb/UnderwaterToggle()
		set src in world
		if(usr.UnderwaterMode==0)
			usr.UnderwaterMode=1
			usr<<"You will now build Underwater tiles if on the proper Z plane."
		else if(usr.UnderwaterMode==1)
			usr.UnderwaterMode=0
			usr<<"You will now build Underground tiles if on the proper Z plane."


	Click()
		if(!usr.BuildGiven&&!usr.Mapper&&!usr.Admin)
			usr<<"The Build verb has yet to be enabled for you. Unlock Fly to proceed."
			return
		if(istype(src,/turf/IconsX/Icon59))
			return
		if(usr.Target==src)
			for(var/sb in usr.SlotlessBuffs)
				var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
				if(b)
					if(b.TargetOverlay)
						var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
						im.transform*=b.OverlaySize
						usr.overlays-=im
						if(usr.Target)
							usr.Target.overlays-=im
			if(usr.SpecialBuff)
				if(usr.SpecialBuff.BuffName=="Kyoukaken")
					usr.Kyoukaken("Off")
			usr<<"You have deselected [src]"
			usr.RemoveTarget()
			return
		if(usr.Target!=src)
			for(var/sb in usr.SlotlessBuffs)
				var/obj/Skills/Buffs/b = usr.SlotlessBuffs[sb]
				if(b)
					if(b.TargetOverlay)
						var/image/im=image(icon=b.TargetOverlay, pixel_x=b.TargetOverlayX, pixel_y=b.TargetOverlayY)
						im.transform*=b.OverlaySize
						usr.overlays-=im
						if(usr.Target)
							usr.Target.overlays-=im
			if(usr.SpecialBuff)
				if(usr.SpecialBuff.BuffName=="Kyoukaken")
					usr.Kyoukaken("Off")
			if(istype(usr.Target, /obj/Others/Build))
				var/obj/Others/Build/B=usr.Target
				if(B.Temp)
					del usr.Target
			usr.RemoveTarget()
			usr.Target=src
			usr<<"You have selected [src]"
			usr.AdaptationCounter=0
			usr.AdaptationTarget=null
			usr.AdaptationAnnounce=null


/proc/makeNewBuildObj(obj/objInQuestion)
	var/obj/Others/Build/B=new
	B.icon= objInQuestion.icon
	B.icon_state=objInQuestion.icon_state
	B.density = objInQuestion.density
	B.Creates=objInQuestion.type
	B.name="-[objInQuestion.name]-"
	return B

mob/var/buildPreviousX = 0
mob/var/buildPreviousY = 0
mob/var/buildPreviousZ = 0


proc/Build_Lay(obj/Others/Build/O,mob/P, var/tmpX, var/tmpY, var/tmpZ)
	if(!P.Admin&&!P.Mapper)
		if(tmpX>0||tmpY>0||tmpZ>0)
			return
	var/mob/L=P
	var/atom/C
	if(tmpX > 0 || tmpY> 0 || tmpZ> 0)
		P.buildPreviousX = tmpX
		P.buildPreviousY = tmpY
		P.buildPreviousZ = tmpZ
		C=new O.Creates(locate(tmpX,tmpY,tmpZ))
	else
		C=new O.Creates(locate(L.x,L.y,L.z))
	C.Builder=P.ckey
	if(P.UnFlyable)
		C.FlyOverAble=FALSE
		C.density = TRUE
	else
		C.FlyOverAble=1
	if(L.MakeUngrabbable)
		C.Grabbable=0
	if(istype(C,/obj/Turfs/Sign))
		var/obj/Turfs/Sign/sign = C
		spawn
			var/t = P.HUDTextPrompt("What do you want to write on the sign?")
			if(!isnull(t) && sign)
				sign.desc = t
	if(istype(C,/turf/Special/EventStars))
		C.icon_state="[rand(1,2500)]"
	if(P.TurfInvincible)
		C:Destructable=0
	else
		C:Destructable=1
	if(!isturf(C))
		C.Savable=1
		worldObjectList+=C
		if(istype(C,/obj/Turfs/CustomObj1))
			var/obj/Turfs/CustomObj1/customObj=C
			if(P.useCustomObjSettings)
				if(P.CustomObj1Icon)
					customObj.icon=P.CustomObj1Icon
				else
					customObj.icon=O.icon
				if(P.CustomObj1State)
					customObj.icon_state=P.CustomObj1State
				else
					customObj.icon_state=O.icon_state
				if(P.CustomObj1Layer)
					customObj.layer=P.CustomObj1Layer
				else
					C.layer=O.layer
				if(P.CustomObj1Density)
					customObj.density=P.CustomObj1Density
				else
					customObj.density=O.density
				if(P.CustomObj1Opacity)
					customObj.opacity=P.CustomObj1Opacity
				else
					customObj.opacity=O.opacity
				if(P.CustomObj1X)
					customObj.pixel_x=P.CustomObj1X
				else
					customObj.pixel_x=O.pixel_x
				if(P.CustomObj1Y)
					customObj.pixel_y=P.CustomObj1Y
				else
					customObj.pixel_y=O.pixel_y
				if(P.CustomObjEdge)
					customObj.edge=P.CustomObjEdge
				else
					if(istype(O,/obj/Turfs/CustomObj1))
						var/obj/Turfs/CustomObj1/CT=O
						customObj.edge=CT.edge
			else
				customObj.icon=O.icon
				customObj.icon_state=O.icon_state
				customObj.layer=O.layer
				customObj.density=O.density
				customObj.opacity=O.opacity
				customObj.pixel_x=O.pixel_x
				customObj.pixel_y=O.pixel_y
				if(istype(O,/obj/Turfs/CustomObj1))
					var/obj/Turfs/CustomObj1/CT=O
					customObj.edge=CT.edge
		else
			C.icon_state = O.icon_state

	else
		C.Savable=0
		var/turf/_turf=C
		var/turf/CustomTurf/CT=C
		if(istype(C,/turf/CustomTurf))
			C?:InitialType = "/turf/CustomTurf"
			if(P.useCustomTurfSettings)
				if(P.CustomTurfIcon)
					CT.icon = P.CustomTurfIcon
				else
					CT.icon = O.icon
				if(P.CustomTurfState)
					CT.icon_state = P.CustomTurfState
				else
					C.icon_state = O.icon_state
				if(P.CustomTurfRoof)
					CT.Roof = P.CustomTurfRoof
				if(P.CustomTurfDensity)
					CT.density = P.CustomTurfDensity
				else
					CT.density = O.density
				if(P.CustomTurfOpacity)
					CT.opacity = P.CustomTurfOpacity
				else
					CT.opacity = O.opacity
			else
				CT.icon = O.icon
				CT.icon_state = O.icon_state
				CT.Roof = P.CustomTurfRoof
				CT.density = O.density
				CT.opacity = O.opacity
		if(P.ShallowMode==1)
			_turf.Shallow=1
		if(P.BuildOverwrite)
			for(var/obj/Turfs/E in C)
				if(!istype(E, /obj/Special/Teleporter2))
					del(E)
			for(var/obj/KatieObj/E in C)
				del(E)
		if(P.WarperOverwrite)
			for(var/obj/Special/Teleporter2/q in C)
				del(q)
		if(!istype(C,/turf/CustomTurf))
			Turfs+=C
		else
			CustomTurfs+=CT
		LightingRecomputeNear(get_step(C, 0))
	if(ismovable(C))
		if(istype(C, /obj/Turfs/CustomObj1))
			BuildCustomObjApplyDef(C)
		GfxRefreshStructureMetadata(C)
		if(isobj(C) && ObjPlacementTwin(C))
			ReleaseProp(C)

obj/var
	Saved_X
	Saved_Y
	Saved_Z

proc/Save_Objects(quiet = 0)
	set background = 1
	if(!ObjectSaveSafe())
		return
	if(!ObjectSaveRecover())
		ObjectSaveFailed("an earlier interrupted object save could not be finished")
		return
	if(!quiet)
		world<<"<small>Server: Saving Objects..."
	var/stale = 1
	while(fexists("Saves/Itemsave/Stage[stale]"))
		fdel("Saves/Itemsave/Stage[stale]")
		stale++
	var/list/chunks = ObjectSaveSnapshot()
	if(!islist(chunks))
		ObjectSaveFailed("the object snapshot failed; nothing was committed")
		return
	var/files = 0
	var/Amount = 0
	for(var/list/Types in chunks)
		files++
		Amount += Types.len
		SaveObjectChunk("Saves/Itemsave/Stage[files]", Types)
		if(!fexists("Saves/Itemsave/Stage[files]") || length(file("Saves/Itemsave/Stage[files]")) <= 0)
			ObjectSaveFailed("could not write Saves/Itemsave/Stage[files]; nothing was committed")
			return
		sleep(world.tick_lag)
	ObjectCommitMark(files)
	if(text2num(trimtext(file2text("Saves/Itemsave/Commit"))) != files)
		ObjectSaveFailed("could not write the Saves/Itemsave/Commit marker; nothing was committed")
		return
	if(!ObjectSaveCommit(files))
		ObjectSaveFailed("could not copy the staged files over Saves/Itemsave; the save will be finished at the next boot or save")
		return
	BuildJournalDropObjectLines()
	if(!quiet)
		world<<"<small>Server: Objects Saved ([Amount])."
	BuildAreaPaintSave()

proc/SaveObjectChunk(path, list/Types)
	var/savefile/F = new(path)
	F["Types"] << Types

proc/Load_Objects()
	world<<"<small>Server: Loading Items..."
	objectLoadState = 1
	var/recoverFailed = !ObjectSaveRecover()
	if(recoverFailed)
		Log("Mapper", "Object load: an interrupted object save could not be finished; Itemsave may hold mixed save generations.", 1)
		world << "<small><font color=red>Server: an interrupted object save could not be finished. Tell an admin before anyone saves.</font>"
	worldObjectLoading = 1
	var/amount = 0
	var/read = 0
	var/twins = 0
	var/dropped = 0
	var/offmap = 0
	var/list/offmapZ = list()
	var/unreadable = 0
	var/list/unreadableFiles = list()
	var/list/twinTypes = list()
	var/list/sigCache = list()
	var/list/customs = list()
	var/list/warpers = list()
	var/filenum = 1
	while(fexists("Saves/Itemsave/File[filenum]"))
		var/list/L = LoadObjectChunk("Saves/Itemsave/File[filenum]")
		for(var/entry in L)
			read++
			if(!isobj(entry))
				unreadable++
				unreadableFiles["File[filenum]"] = 1
				continue
			var/obj/AObj = entry
			if(!AObj.Savable || AObj.gfx_transient_visual)
				dropped++
				continue
			var/turf/T = locate(AObj.Saved_X, AObj.Saved_Y, AObj.Saved_Z)
			if(!T)
				offmap++
				offmapZ["z[AObj.Saved_Z]"] = (offmapZ["z[AObj.Saved_Z]"] || 0) + 1
				continue
			if(ObjTwinDedupable(AObj) && ObjTwinOnTurf(AObj, T, sigCache))
				twins++
				twinTypes["[AObj.type]"] = (twinTypes["[AObj.type]"] || 0) + 1
				continue
			AObj.loc = T
			worldObjectList += AObj
			amount++
			if(istype(AObj, /obj/Turfs/CustomObj1))
				customs += AObj
			else if(istype(AObj, /obj/Special/Teleporter2))
				warpers += AObj
		filenum++
	for(var/obj/Turfs/CustomObj1/CO in customs)
		BuildCustomObjApplyDef(CO)
	for(var/obj/Special/Teleporter2/W in warpers)
		if(W.AssociatedWarper || isnull(W.gotoZ))
			continue
		var/turf/D = locate(W.gotoX, W.gotoY, W.gotoZ)
		if(!D)
			continue
		for(var/obj/Special/Teleporter2/P in D)
			if(P != W && P.Savable && !P.AssociatedWarper && P.gotoX == W.x && P.gotoY == W.y && P.gotoZ == W.z)
				W.AssociatedWarper = P
				P.AssociatedWarper = W
				break
	worldObjectLoading = 0
	objectLoadCount = amount
	var/suspect = recoverFailed || (offmap >= 50 && offmap * 5 > read)
	objectLoadState = suspect ? 3 : 2
	if(twins || dropped)
		var/list/parts = list()
		for(var/k in twinTypes)
			parts += "[k] x[twinTypes[k]]"
		Log("Mapper", "Object load: [amount] placed, [twins] exact duplicate copies removed[twins ? " ([jointext(parts, ", ")])" : ""], [dropped] non-persistent entries dropped.", 1)
	if(unreadable || offmap)
		var/list/names = list()
		for(var/k in unreadableFiles)
			names += k
		var/list/zparts = list()
		for(var/k in offmapZ)
			zparts += "[k] x[offmapZ[k]]"
		Log("Mapper", "Object load: [unreadable] saved entr[unreadable == 1 ? "y" : "ies"] could not be read[unreadable ? " ([jointext(names, ", ")])" : ""], [offmap] saved object\s point at a location that does not exist[offmap ? " ([jointext(zparts, ", ")]; world.maxz is [world.maxz])" : ""].", 1)
		world << "<small><font color=red>Server: [unreadable + offmap] saved object\s could not be restored (see the Mapper log).</font>"
	if(suspect)
		world << "<small><font color=red>Server: object saving is disabled this boot to protect the object save. Tell an admin.</font>"
	world<<"<small>Server: Items Loaded ([amount][twins ? ", [twins] duplicate copies removed" : ""])."

proc/LoadObjectChunk(path)
	var/savefile/F = new(path)
	var/list/L
	F["Types"] >> L
	return islist(L) ? L : list()
