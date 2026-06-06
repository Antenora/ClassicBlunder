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
    if(majinOwnedRoom) return majinOwnedRoom
    for(var/i = 1, i <= MAJIN_ROOM_COUNT, i++)
        if(!MAJIN_ROOM_OWNERS[i])
            MAJIN_ROOM_OWNERS[i] = ckey
            majinOwnedRoom = i
            return i
    src << "There is no Absorb room available, please report this to an Admin."
    return 0

/mob/proc/ReleaseMajinRoom()
    if(!majinOwnedRoom) return
    if(MAJIN_ROOM_OWNERS[majinOwnedRoom] == ckey)
        MAJIN_ROOM_OWNERS[majinOwnedRoom] = null
    majinOwnedRoom = 0

/mob/proc/GetMajinRoomTurf()
    if(!majinOwnedRoom)
        ClaimMajinRoom()
    if(!majinOwnedRoom) return null
    var/list/coords = MAJIN_ROOM_COORDS[majinOwnedRoom]
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
