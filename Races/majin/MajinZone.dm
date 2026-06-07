var/global/list/MAJIN_ROOM_COORDS = list(
    list(8,  10,  MAJIN_ABSORB_Z),  // Room 1
    list(8,  33,  MAJIN_ABSORB_Z),  // Room 2
    list(8,  56,  MAJIN_ABSORB_Z),  // Room 3
    list(8,  78,  MAJIN_ABSORB_Z),  // Room 4
    list(8, 101,  MAJIN_ABSORB_Z)   // Room 5
)

var/global/list/MAJIN_ROOM_OWNERS = list(null, null, null, null, null)

// for quick lookup.
/mob/var/majinOwnedRoom = 0 // 1..MAJIN_ROOM_COUNT, or 0 if unowned.

/proc/IsInMajinAbsorbZone(atom/a)
    if(!a) return 0
    return a.z == MAJIN_ABSORB_Z

/mob/proc/ClaimMajinRoom()
    if(majinOwnedRoom >= 1 && majinOwnedRoom <= MAJIN_ROOM_COUNT)
        if(MAJIN_ROOM_OWNERS[majinOwnedRoom] == ckey)
            return majinOwnedRoom 
        if(!MAJIN_ROOM_OWNERS[majinOwnedRoom])
            MAJIN_ROOM_OWNERS[majinOwnedRoom] = ckey 
            return majinOwnedRoom
        majinOwnedRoom = 0
    for(var/i = 1, i <= MAJIN_ROOM_COUNT, i++)
        if(!MAJIN_ROOM_OWNERS[i])
            MAJIN_ROOM_OWNERS[i] = ckey
            majinOwnedRoom = i
            return i
    return 0 

/mob/proc/ReleaseMajinRoom()
    if(!majinOwnedRoom) return
    if(MAJIN_ROOM_OWNERS[majinOwnedRoom] == ckey)
        MAJIN_ROOM_OWNERS[majinOwnedRoom] = null
    majinOwnedRoom = 0

/mob/proc/GetMajinRoomTurf()
    var/room = ClaimMajinRoom()
    if(!room) return null
    var/list/coords = MAJIN_ROOM_COORDS[room]
    return locate(coords[1], coords[2], coords[3])

/proc/GetMajinByCkey(theCkey)
    return GetOnlineMobByCkey(theCkey)

/proc/GetOnlineMobByCkey(theCkey)
    if(!theCkey) return null
    for(var/mob/Players/p in players)
        if(p.ckey == theCkey)
            return p
    return null

// Free up a room on character deletion
/mob/proc/MajinCleanupOnDeletion()
    if(majinAbsorb && majinAbsorb.absorbed && majinAbsorb.absorbed.len)
        majinAbsorb.releaseAll(src, "character_deleted")
    ReleaseMajinRoom()


// Print a report on a single room, its owning Majin, that Majin's absorbed roster and anyone physically in the room
/mob/proc/AdminReportMajinRoom(roomNum)
    if(roomNum < 1 || roomNum > MAJIN_ROOM_COUNT) return
    var/ownerCkey = MAJIN_ROOM_OWNERS[roomNum]
    src << "<b>=== Majin Absorb Room [roomNum] ===</b>"
    if(!ownerCkey)
        src << "Owner: (unassigned)"
        return
    var/mob/Players/owner = GetOnlineMobByCkey(ownerCkey)
    src << "Owner: [owner ? "[owner.name] ([ownerCkey]) — online" : "[ownerCkey] — offline"]"
    if(owner && owner.majinAbsorb && islist(owner.majinAbsorb.absorbed) && owner.majinAbsorb.absorbed.len)
        src << "Absorbed roster ([owner.majinAbsorb.absorbed.len]):"
        for(var/key in owner.majinAbsorb.absorbed)
            var/list/entry = owner.majinAbsorb.absorbed[key]
            if(!islist(entry)) continue
            var/mob/v = GetOnlineMobByCkey(key)
            var/vName = entry["name"] ? entry["name"] : key
            src << "- [vName] ([key]) — [v ? "online" : "offline"]"
    else if(owner)
        src << "Absorbed roster: (empty)"
    else
        src << "(Owner is offline, their absorbed roster isn't loaded, showing only players physically present.)"
    var/list/coords = MAJIN_ROOM_COORDS[roomNum]
    var/turf/T = locate(coords[1], coords[2], coords[3])
    var/phys = 0
    if(T)
        for(var/mob/Players/v in T)
            if(!phys) src << "Players physically in the room:"
            phys++
            var/tag = (v.absorbedBy == ownerCkey) ? "" : " <font color='red'>(absorbedBy=[v.absorbedBy ? v.absorbedBy : "none"]!)</font>"
            src << "- [v.name] ([v.ckey])[tag]"
    if(!phys)
        src << "Players physically in the room: (none)"

// Force-digest every victim of the room's owner
/mob/proc/AdminDigestMajinRoom(roomNum)
    if(roomNum < 1 || roomNum > MAJIN_ROOM_COUNT) return
    var/ownerCkey = MAJIN_ROOM_OWNERS[roomNum]
    if(!ownerCkey)
        src << "Room [roomNum] is unassigned, nothing to digest."
        return
    var/mob/Players/owner = GetOnlineMobByCkey(ownerCkey)
    var/count = 0
    if(owner && owner.majinAbsorb)
        count = owner.majinAbsorb.AdminForceDigestAll(owner)
    else
        // Offline owner: queue digest credits so the owner is still credited on their next login
        var/list/coords = MAJIN_ROOM_COORDS[roomNum]
        var/turf/T = locate(coords[1], coords[2], coords[3])
        if(T)
            for(var/mob/Players/v in T)
                if(v.absorbedBy != ownerCkey) continue
                if(!MAJIN_PENDING_DIGEST_CREDITS["[ownerCkey]"])
                    MAJIN_PENDING_DIGEST_CREDITS["[ownerCkey]"] = list()
                if(!("[v.ckey]" in MAJIN_PENDING_DIGEST_CREDITS["[ownerCkey]"]))
                    MAJIN_PENDING_DIGEST_CREDITS["[ownerCkey]"] += "[v.ckey]"
                v.absorbedBy = null
                v.majinRoomIndex = 0
                v.absorbedAtTimestamp = 0
                v.RevokeObserveMajinVerb()
                MoveToSpawn(v)
                v.KO = 0
                v << "<font color='purple'>You've been digested and sent back to spawn.</font>"
                count++
        src << "Owner is offline, only physically-present victims could be reached."
    src << "<font color='purple'>Force-digested [count] victim(s) from room [roomNum].</font>"
    Log("Admin", "[ExtractInfo(src)] force-digested [count] victim(s) from Majin room [roomNum] (owner [ownerCkey]).")

// Unlink a room from its Majin and free everyone still in it, so the slot can be reused
/mob/proc/AdminUnassignMajinRoom(roomNum)
    if(roomNum < 1 || roomNum > MAJIN_ROOM_COUNT) return
    var/ownerCkey = MAJIN_ROOM_OWNERS[roomNum]
    var/mob/Players/owner = GetOnlineMobByCkey(ownerCkey)
    var/evicted = 0
    if(owner && owner.majinAbsorb)
        // Online owner releases the whole roster (this also frees their room).
        if(islist(owner.majinAbsorb.absorbed))
            evicted = owner.majinAbsorb.absorbed.len
        owner.majinAbsorb.releaseAll(owner, "admin_unassign")
        owner.ReleaseMajinRoom()
    else
        // Offline owner
        var/list/coords = MAJIN_ROOM_COORDS[roomNum]
        var/turf/T = locate(coords[1], coords[2], coords[3])
        if(T)
            for(var/mob/Players/v in T)
                if(ownerCkey && v.absorbedBy != ownerCkey) continue
                v.absorbedBy = null
                v.majinRoomIndex = 0
                v.absorbedAtTimestamp = 0
                v.RevokeObserveMajinVerb()
                v.KO = 1
                v.ClearFrenzyOnKO()
                MoveToSpawn(v)
                if(v.client)
                    v << "<font color='red'>An Admin has expelled you from the Majin's stomach.</font>"
                evicted++
    MAJIN_ROOM_OWNERS[roomNum] = null
    src << "Unassigned room [roomNum][ownerCkey ? " from [ownerCkey]" : ""]; freed [evicted] victim(s)."
    Log("Admin", "[ExtractInfo(src)] unassigned Majin room [roomNum] (owner [ownerCkey]); freed [evicted].")

/mob/Admin3/verb/Check_Majin_Rooms()
    set category = "Admin"
    set name = "Check Majin Rooms"
    set desc = "Inspect, force-digest, or unassign the Majin absorb rooms."
    var/mob/Players/admin = usr
    if(!istype(admin)) return
    if(!admin.Admin) return
    var/list/menu = list()
    var/list/menu_lookup = list()
    for(var/i = 1, i <= MAJIN_ROOM_COUNT, i++)
        var/ownerCkey = MAJIN_ROOM_OWNERS[i]
        if(!ownerCkey) continue // only rooms currently assigned to a Majin
        var/mob/Players/owner = GetOnlineMobByCkey(ownerCkey)
        var/label = "Room [i]: [owner ? "[owner.name] ([ownerCkey])" : "[ownerCkey] (offline)"]"
        menu += label
        menu_lookup[label] = i
    if(!menu.len)
        admin << "There are no active Majin absorb rooms."
        return
    var/choice = input(admin, "Active Majin absorb rooms:", "Check Majin Rooms") as null|anything in menu
    if(!choice) return
    var/roomNum = menu_lookup[choice]
    if(!roomNum) return
    admin.AdminReportMajinRoom(roomNum)
    var/action = input(admin, "Room [roomNum]: choose an action.", "Check Majin Rooms") as null|anything in list("Trigger Digestion for all victims", "Unassign room from Majin", "Cancel")
    if(!action || action == "Cancel") return
    if(action == "Trigger Digestion for all victims")
        admin.AdminDigestMajinRoom(roomNum)
    else if(action == "Unassign room from Majin")
        admin.AdminUnassignMajinRoom(roomNum)
    admin.AdminReportMajinRoom(roomNum)

/mob/proc/MajinHasValidRoom()
    if(majinOwnedRoom < 1 || majinOwnedRoom > MAJIN_ROOM_COUNT) return 0
    return MAJIN_ROOM_OWNERS[majinOwnedRoom] == ckey

/mob/Admin3/verb/Assign_Majin_Room()
    set category = "Admin"
    set name = "Assign Majin Room"
    set desc = "Manually assign an unoccupied absorb room to an online Majin that has none."
    var/mob/Players/admin = usr
    if(!istype(admin)) return
    if(!admin.Admin) return

    var/list/menu = list()
    var/list/menu_lookup = list()
    for(var/mob/Players/M in players)
        if(!M.isRace(MAJIN)) continue
        if(M.MajinHasValidRoom()) continue
        var/vcount = (M.majinAbsorb && islist(M.majinAbsorb.absorbed)) ? M.majinAbsorb.absorbed.len : 0
        var/label = "[M.name] ([M.ckey])[vcount ? " — [vcount] absorbed" : ""]"
        menu += label
        menu_lookup[label] = M
    if(!menu.len)
        admin << "There are no online Majins without an assigned room."
        return
    var/choice = input(admin, "Assign a room to which Majin?", "Assign Majin Room") as null|anything in menu
    if(!choice) return
    var/mob/Players/majin = menu_lookup[choice]
    if(!majin || !(majin in players))
        admin << "That Majin is no longer online."
        return
    if(majin.MajinHasValidRoom())
        admin << "[majin] already holds room [majin.majinOwnedRoom] now."
        return

    var/list/roomMenu = list()
    var/list/roomLookup = list()
    for(var/i = 1, i <= MAJIN_ROOM_COUNT, i++)
        if(MAJIN_ROOM_OWNERS[i]) continue
        var/rlabel = "Room [i]"
        roomMenu += rlabel
        roomLookup[rlabel] = i
    if(!roomMenu.len)
        admin << "All absorb rooms are currently occupied. Use Check Majin Rooms to free one up first."
        return
    var/rchoice = input(admin, "Assign which room to [majin]?", "Assign Majin Room") as null|anything in roomMenu
    if(!rchoice) return
    var/roomNum = roomLookup[rchoice]
    if(!roomNum) return
    if(MAJIN_ROOM_OWNERS[roomNum]) // someone grabbed it during the prompt lmao
        admin << "Room [roomNum] was just taken. Try again."
        return

    for(var/i = 1, i <= MAJIN_ROOM_COUNT, i++)
        if(MAJIN_ROOM_OWNERS[i] == majin.ckey)
            MAJIN_ROOM_OWNERS[i] = null
    MAJIN_ROOM_OWNERS[roomNum] = majin.ckey
    majin.majinOwnedRoom = roomNum

    // Just in case
    var/list/coords = MAJIN_ROOM_COORDS[roomNum]
    var/turf/dest = locate(coords[1], coords[2], coords[3])
    if(dest)
        for(var/mob/Players/v in players)
            if(v.absorbedBy == majin.ckey)
                v.loc = dest
                v.majinRoomIndex = roomNum

    admin << "Assigned room [roomNum] to [majin] ([majin.ckey])."
    majin << "<font color='purple'>An Admin has assigned you absorb room [roomNum].</font>"
    Log("Admin", "[ExtractInfo(admin)] assigned Majin room [roomNum] to [ExtractInfo(majin)].")
