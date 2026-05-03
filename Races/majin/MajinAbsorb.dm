// Absorb is now lethal-and-imprisoning. A KO'd victim is sent
// to the Majin's personal absorb room on z = MAJIN_ABSORB_Z and
// stays there (even while logged out) until the Majin dies or
// something pulls them out of the zone.
//
//  Innocent: regular absorb slots / skills; blob mechanic.
//  Super:    +2 absorb slots, +2 stolen skills per victim, digested stolen skills get 1.5x DamageMult.
//  Unhinged: Power counts 2x in damage calcs

// Pending ejection registry. When a Majin dies (or otherwise releases a
// victim) while that victim is logged out, it records who should be ejected.
var/global/list/MAJIN_PENDING_EJECTIONS = list()

// Pending digestion registry
var/global/list/MAJIN_PENDING_DIGESTIONS = list()

// Pending digestion credits. If the Majin is offline at the 96h mark, a victim
// who logs in alone can force their own release; the Majin then has to retro-
// actively receive the permanent power/skill credit when they next log in.
var/global/list/MAJIN_PENDING_DIGEST_CREDITS = list()

/mob/proc/GrantObserveMajinVerb()
    if(!verbs) return
    if(!(/mob/verb/Observe_Majin in verbs))
        verbs += /mob/verb/Observe_Majin

/mob/proc/RevokeObserveMajinVerb()
    if(!verbs) return
    if(/mob/verb/Observe_Majin in verbs)
        verbs -= /mob/verb/Observe_Majin
    if(client && client.eye != src && !absorbedBy)
        Observify(src, src)
        Observing = 0

/mob/verb/Observe_Majin()
    set category = "Other"
    set name = "Observe Majin"
    if(!absorbedBy)
        src << "You are not currently absorbed by a Majin."
        RevokeObserveMajinVerb()
        return
    var/mob/Players/M = GetMajinByCkey(absorbedBy)
    if(!M)
        src << "You cannot sense the Majin that absorbed you."
        return
    if(client && client.eye == M)
        Observify(src, src)
        Observing = 0
        src << "You stop observing [M]."
        return
    Observify(src, M)
    Observing = 1
    src << "You focus your senses on [M]."

// Majin cheat-death visual effect
/obj/majin_cheat_frag
    mouse_opacity = 0
    density = 0
    appearance_flags = 32

/mob/proc/MajinCheatDeathReformFX(piece_count, out_ticks = 6, hold_ticks = 30, in_ticks = 18)
    if(majinCheatFXRunning) return
    if(!icon) return
    majinCheatFXRunning = 1

    var/icon/base = icon(icon, icon_state)
    if(!base)
        majinCheatFXRunning = 0
        majinCheatDeathInProgress = 0
        return

    var/w = base.Width()
    var/h = base.Height()
    if(!w || !h)
        majinCheatFXRunning = 0
        majinCheatDeathInProgress = 0
        return

    // Scale piece count, radius, and scatter to the icon
    var/size = max(w, h)
    var/scale = size / 32
    if(!piece_count)
        piece_count = round(10 * scale * scale)
        piece_count = max(10, min(60, piece_count))
    var/radius_min = max(3, round(4 * scale))
    var/radius_max = max(radius_min + 2, round(8 * scale))
    var/scatter = round(40 * scale)

    var/old_alpha = alpha
    var/list/fragments = list()

    // Host fragments on the turf rather than on src's own vis_contents so
    // hiding src (alpha=0) doesn't hide the fragment
    var/turf/host_turf = get_turf(src)

    var/list/kept_overlays = list()
    for(var/O in src.overlays)
        if(O:blend_mode == BLEND_ADD) continue
        kept_overlays += O

    // Coverage grid prevents any pixel of the base sprite from appearing
    // in more than one fragment.
    var/list/coverage = new/list(w * h)

    // Hide the original sprite while fragments separate.
    alpha = 0

    for(var/i = 1, i <= piece_count, i++)
        var/cx = rand(max(2, round(5 * scale)), max(round(5 * scale) + 1, w - round(4 * scale)))
        var/cy = rand(max(2, round(5 * scale)), max(round(5 * scale) + 1, h - round(4 * scale)))
        var/radius = rand(radius_min, radius_max)
        var/rsq = radius * radius

        var/x1 = max(1, cx - radius)
        var/y1 = max(1, cy - radius)
        var/x2 = min(w, cx + radius)
        var/y2 = min(h, cy + radius)

        var/icon/fragment_icon = new/icon(base)
        if(y2 < h) fragment_icon.DrawBox(null, 1, y2 + 1, w, h)
        if(y1 > 1) fragment_icon.DrawBox(null, 1, 1, w, y1 - 1)
        if(x1 > 1) fragment_icon.DrawBox(null, 1, y1, x1 - 1, y2)
        if(x2 < w) fragment_icon.DrawBox(null, x2 + 1, y1, w, y2)

        // Mask for the alpha filter: transparent everywhere, opaque only
        // at this fragment's owned pixels. Clips overlays (clothing) to
        // the same shape as the carved body.
        var/icon/circle_mask = new/icon(base)
        circle_mask.DrawBox(null, 1, 1, w, h)

        var/claimed_any = 0
        for(var/px = x1, px <= x2, px++)
            for(var/py = y1, py <= y2, py++)
                var/dx = px - cx
                var/dy = py - cy
                if((dx * dx) + (dy * dy) > rsq)
                    fragment_icon.DrawBox(null, px, py, px, py)
                    continue
                var/idx = (py - 1) * w + px
                if(coverage[idx])
                    fragment_icon.DrawBox(null, px, py, px, py)
                    continue
                coverage[idx] = 1
                circle_mask.DrawBox(rgb(255, 255, 255), px, py, px, py)
                claimed_any = 1

        // Entirely covered by prior fragments — skip to avoid an empty atom.
        if(!claimed_any) continue

        var/obj/majin_cheat_frag/fragment = new()
        fragment.icon = fragment_icon
        fragment.overlays = kept_overlays
        fragment.filters = filter(type = "alpha", icon = circle_mask)
        fragment.layer = MOB_LAYER + 100 + (i * 0.001)
        fragment.plane = plane
        fragment.pixel_x = 0
        fragment.pixel_y = 0
        if(host_turf)
            host_turf.vis_contents += fragment
        else
            src.vis_contents += fragment
        fragments += fragment

        var/out_x = rand(-scatter, scatter)
        var/out_y = rand(-scatter, scatter)
        animate(fragment, pixel_x = out_x, pixel_y = out_y, alpha = 220, time = out_ticks)
        animate(pixel_x = out_x, pixel_y = out_y, alpha = 220, time = hold_ticks)
        animate(pixel_x = 0, pixel_y = 0, alpha = 255, time = in_ticks)

    spawn(out_ticks + hold_ticks + in_ticks + 2)
        for(var/obj/majin_cheat_frag/fragment in fragments)
            if(host_turf)
                host_turf.vis_contents -= fragment
            src.vis_contents -= fragment
            del(fragment)
        alpha = old_alpha
        // Ensure the user returns on their alive sprite
        icon_state = ""
        majinCheatFXRunning = 0
        majinCheatDeathInProgress = 0

majinAbsorb
    var/list/absorbed = list()

    // refreshed any time class or ascension changes.
    var/absorbLimit = MAJIN_BASE_ABSORB_LIMIT
    var/skillsPerVictim = MAJIN_BASE_SKILLS_PER_VICTIM

    var/permanentAbsorbPower = 0
    // Skills retained from digested victims.
    var/list/permanentSkillRefs = list()
    // ckeys of victims this Majin has fully digested. Cannot be re-absorbed
    // by this Majin.
    var/list/digestedVictims = list()
    var/tmp/digestionLoopRunning = 0

majinAbsorb/proc/updateVariables(mob/p)
    if(!p) return
    var/isSuper = (p.Class == "Super")
    var/asc = p.AscensionsAcquired
    absorbLimit = MAJIN_BASE_ABSORB_LIMIT + asc + (isSuper ? MAJIN_SUPER_ABSORB_BONUS : 0)
    skillsPerVictim = MAJIN_BASE_SKILLS_PER_VICTIM + (isSuper ? (MAJIN_SUPER_SKILL_BONUS + asc) : 0)

majinAbsorb/proc/SumAbsorbedPeakPower(mob/absorber)
    . = 0
    if(!absorbed || !absorbed.len) return
    var/list/stale = null
    for(var/key in absorbed)
        var/list/entry = absorbed[key]
        if(!islist(entry)) continue
        var/mob/victim = entry["mob"]
        var/valid = 0
        if(victim && victim.z == MAJIN_ABSORB_Z)
            valid = 1
        else if(!victim && entry["was_logged_in"] == FALSE)
            valid = 1
        if(valid)
            . += entry["peak"]
        else
            if(!stale) stale = list()
            stale += key
    if(stale)
        for(var/k in stale)
            releaseVictim(absorber, k, "left_zone")

// Skill stealing

majinAbsorb/proc/IsStealableSkill(obj/Skills/s)
    if(!s) return 0
    if(!istype(s, /obj/Skills)) return 0
    // Never steal Absorb itself or variants.
    if(istype(s, /obj/Skills/Absorb)) return 0
    if(istype(s, /obj/Skills/Target_Clear)) return 0
    if(istype(s, /obj/Skills/Target_Switch)) return 0
    // No teleports
    if(istype(s, /obj/Skills/Teleport)) return 0
    if(!s.Copyable)
        if(s.SignatureTechnique)
            return 1
        else
            return 0
    return 1

majinAbsorb/proc/CollectStealable(mob/absorbee)
    . = list()
    if(!absorbee) return
    for(var/obj/Skills/s in absorbee.contents)
        if(IsStealableSkill(s))
            . += s

majinAbsorb/proc/StealSkills(mob/absorber, mob/absorbee)
    var/list/result = list("types" = list(), "refs" = list())
    var/list/available = CollectStealable(absorbee)
    if(!available.len)
        absorber << "[absorbee] has no skills you can absorb."
        return result

    var/max_picks = skillsPerVictim
    var/picks_left = max_picks
    while(picks_left > 0 && available.len > 0)
        var/list/menu = list("Cancel")
        var/list/menu_lookup = list()
        for(var/obj/Skills/s in available)
            var/label = "[s.name ? s.name : s.type]"
            menu += label
            menu_lookup[label] = s
        var/choice = input(absorber, "Pick a skill to absorb ([picks_left] picks left):", "Absorb Skills") in menu
        if(choice == "Cancel" || !choice) break
        var/obj/Skills/picked = menu_lookup[choice]
        if(!picked) continue
        var/chosenType = picked.type
        var/obj/Skills/copy = new chosenType
        absorber.AddSkill(copy)
        result["types"] += chosenType
        result["refs"] += copy
        available -= picked
        picks_left -= 1
        absorber << "You rip the knowledge of [choice] from [absorbee] and make it your own."
    return result

majinAbsorb/proc/doAbsorb(mob/absorber, mob/absorbee)
    if(!absorber || !absorbee) return
    updateVariables(absorber)

    if(digestedVictims && ("[absorbee.ckey]" in digestedVictims))
        absorber << "Your body has already digested [absorbee]'s soul; there is nothing left of them for you to consume."
        return

    // Already absorbed by us?
    if(absorbed["[absorbee.ckey]"])
        absorber << "You have already absorbed [absorbee]."
        return

    var/peak = max(absorbee.PeakPowerObserved, absorbee.Power)

    if(absorbee.RollVoidForAbsorb())
        var/halfPeak = peak / 2
        permanentAbsorbPower += halfPeak
        absorber << "<font color='purple'>[absorbee]'s essence slips through your fingers and is lost to the Void! You drag a fraction of their power back with you.</font>"
        OMsg(absorber, "[absorber] tries to absorb [absorbee], but their soul is dragged into the Void!")
        absorbee.Void(0, 0, 1)
        return

    if(absorbed.len >= absorbLimit)
        absorber << "You cannot contain any more bodies in your stomach. Release one first."
        return

    // Ensure a room is claimed
    if(!absorber.majinOwnedRoom)
        absorber.ClaimMajinRoom()
    if(!absorber.majinOwnedRoom)
        return // error already shown

    // Steal skills
    var/list/stolen = StealSkills(absorber, absorbee)

    // Move victim into the Majin's room
    var/turf/dest = absorber.GetMajinRoomTurf()
    if(!dest)
        absorber << "Your stomach is nowhere to be found. Report this to an Admin."
        for(var/obj/Skills/s in stolen["refs"])
            absorber.DeleteSkill(s)
        return

    absorbee.absorbedBy = absorber.ckey
    absorbee.majinRoomIndex = absorber.majinOwnedRoom
    absorbee.absorbedAtTimestamp = world.realtime
    absorbee.GrantObserveMajinVerb()
    absorbee.loc = dest

    absorbed["[absorbee.ckey]"] = list(
        "mob" = absorbee,
        "skills" = stolen["types"],
        "skill_refs" = stolen["refs"],
        "peak" = peak,
        "was_logged_in" = (absorbee.client ? TRUE : FALSE),
        "absorbedAt" = world.realtime,
        "digestRollsCompleted" = 0
    )

    absorber << "You absorb [absorbee] into your stomach. Their power becomes yours."
    absorbee << "You are absorbed into [absorber]! Your power and knowledge flow into them."
    OMsg(absorber, "[absorber] absorbs [absorbee]!")
    StartDigestionLoop(absorber)

// Possible FX here at some point
majinAbsorb/proc/releaseVictim(mob/absorber, theCkey, reason = "")
    if(!absorbed || !absorbed[theCkey]) return
    var/list/entry = absorbed[theCkey]

    if(islist(entry["skill_refs"]))
        for(var/obj/Skills/s in entry["skill_refs"])
            if(s) absorber.DeleteSkill(s)

    var/mob/victim = entry["mob"]
    if(victim)
        if(victim.z == MAJIN_ABSORB_Z)
            victim.loc = locate(absorber.x, absorber.y, absorber.z)
        victim.absorbedBy = null
        victim.majinRoomIndex = 0
        victim.absorbedAtTimestamp = 0
        victim.RevokeObserveMajinVerb()
        victim.KO = 1
        victim.ClearFrenzyOnKO()
        if(victim.client)
            victim << "You are violently expelled from [absorber]!"
    else
        // Victim is currently logged out. Stash an ejection point.
        if(absorber)
            MAJIN_PENDING_EJECTIONS["[theCkey]"] = list(absorber.x, absorber.y, absorber.z, "[absorber]")

    absorbed -= theCkey

    if(!absorbed.len)
        absorber.ReleaseMajinRoom()

majinAbsorb/proc/releaseAll(mob/absorber, reason = "")
    if(!absorbed || !absorbed.len) return
    var/list/keys = absorbed.Copy()
    for(var/k in keys)
        releaseVictim(absorber, k, reason)
    absorbed = list()
    absorber.ReleaseMajinRoom()


majinAbsorb/proc/CheckDigestion(mob/absorber, theCkey)
    if(!absorber || !theCkey) return
    if(!absorbed) return
    var/list/entry = absorbed["[theCkey]"]
    if(!islist(entry)) return
    var/absorbedAt = entry["absorbedAt"]
    if(!absorbedAt) return // legacy entry from before digestion; treat as start-of-now
    var/elapsed = world.realtime - absorbedAt
    var/rolls_done = entry["digestRollsCompleted"]
    if(!rolls_done) rolls_done = 0
    while(rolls_done < MAJIN_DIGEST_TOTAL_ROLLS)
        var/threshold = (rolls_done + 1) * MAJIN_DIGEST_INTERVAL_HOURS HOURS
        if(elapsed < threshold) break
        var/chance = (rolls_done + 1) * MAJIN_DIGEST_PERCENT_PER_ROLL
        if(rand(1, 100) <= chance)
            DigestVictim(absorber, theCkey)
            return
        rolls_done++
        entry["digestRollsCompleted"] = rolls_done

majinAbsorb/proc/CheckAllDigestion(mob/absorber)
    if(!absorber || !absorbed || !absorbed.len) return
    // Snapshot keys because DigestVictim mutates the absorbed list.
    var/list/keys = absorbed.Copy()
    for(var/k in keys)
        CheckDigestion(absorber, k)

majinAbsorb/proc/ApplySuperDigestStolenSkillDamageMult(mob/absorber, obj/Skills/s)
    if(!absorber || !s) return
    if(absorber.Class != "Super") return
    if(istype(s, /obj/Skills/Queue))
        var/obj/Skills/Queue/q = s
        q.DamageMult *= MAJIN_SUPER_DIGESTED_SKILL_DMG_MULT
    else if(istype(s, /obj/Skills/Projectile))
        var/obj/Skills/Projectile/pj = s
        pj.DamageMult *= MAJIN_SUPER_DIGESTED_SKILL_DMG_MULT
    else if(istype(s, /obj/Skills/AutoHit))
        var/obj/Skills/AutoHit/ah = s
        ah.DamageMult *= MAJIN_SUPER_DIGESTED_SKILL_DMG_MULT

majinAbsorb/proc/DigestVictim(mob/absorber, theCkey, alreadyReleased = FALSE)
    if(!absorber || !theCkey) return
    if(!absorbed) return
    var/list/entry = absorbed["[theCkey]"]
    if(!islist(entry)) return

    // Permanent power transfer.
    permanentAbsorbPower += entry["peak"]

    if(islist(entry["skill_refs"]))
        for(var/obj/Skills/s in entry["skill_refs"])
            if(s)
                ApplySuperDigestStolenSkillDamageMult(absorber, s)
                permanentSkillRefs += s

    // Mark this ckey as permanently digested by this Majin.
    if(!digestedVictims) digestedVictims = list()
    if(!("[theCkey]" in digestedVictims))
        digestedVictims += "[theCkey]"

    // Release the victim from the absorb zone / stash for offline pickup.
    if(!alreadyReleased)
        var/mob/victim = entry["mob"]
        if(victim)
            victim.absorbedBy = null
            victim.majinRoomIndex = 0
            victim.absorbedAtTimestamp = 0
            victim.RevokeObserveMajinVerb()
            if(victim.client)
                MoveToSpawn(victim)
                victim.KO = 0
                victim << "<font color='purple'>After [MAJIN_DIGEST_INTERVAL_HOURS * (1 + entry["digestRollsCompleted"])]+ hours trapped inside [absorber], your essence finally breaks down. You are spat out, drained but free.</font>"
        else
            // Logged out, handle on next login.
            MAJIN_PENDING_DIGESTIONS["[theCkey]"] = "[absorber]"

    // Free the slot.
    absorbed -= "[theCkey]"
    if(!absorbed.len)
        absorber.ReleaseMajinRoom()

    if(absorber.client)
        absorber << "<font color='purple'>Your stomach finishes breaking down [theCkey]. Their power is yours forever, and their skills are now permanently part of you.</font>"
        OMsg(absorber, "[absorber]'s body finishes digesting one of their absorbed victims!")

majinAbsorb/proc/StartDigestionLoop(mob/absorber)
    if(!absorber) return
    if(digestionLoopRunning) return
    digestionLoopRunning = 1
    spawn()
        while(absorber && absorber.majinAbsorb == src)
            CheckAllDigestion(absorber)
            sleep(MAJIN_DIGEST_CHECK_CADENCE)
        digestionLoopRunning = 0

// Victims remain locked in their Majin's stomach even across relogs

/proc/FindMajinAbsorbingCkey(theCkey)
    if(!theCkey) return null
    for(var/mob/Players/M in players)
        if(M.majinAbsorb && M.majinAbsorb.absorbed && M.majinAbsorb.absorbed["[theCkey]"])
            return M
    return null

/mob/proc/MajinAbsorbOnLogout()
    if(!ckey) return
    var/mob/Players/M = FindMajinAbsorbingCkey(ckey)
    if(!M) return
    var/list/entry = M.majinAbsorb.absorbed["[ckey]"]
    if(!islist(entry)) return
    entry["was_logged_in"] = FALSE
    entry["mob"] = null

/mob/proc/MajinAbsorbOnLogin()
    if(!ckey) return

    // Pending digestion (offline at the time of digest) takes priority
    var/digesterName = MAJIN_PENDING_DIGESTIONS["[ckey]"]
    if(digesterName)
        absorbedBy = null
        majinRoomIndex = 0
        absorbedAtTimestamp = 0
        RevokeObserveMajinVerb()
        MoveToSpawn(src)
        KO = 0
        src << "<font color='purple'>While you were away, your essence finished breaking down inside [digesterName]. You have been spat out at spawn — drained, but free.</font>"
        MAJIN_PENDING_DIGESTIONS -= "[ckey]"
        return

    // Safeguard for if this player was absorbed by a Majin that has since died
    var/list/pending = MAJIN_PENDING_EJECTIONS["[ckey]"]
    if(islist(pending) && pending.len >= 3)
        var/turf/T = locate(pending[1], pending[2], pending[3])
        if(T)
            src.loc = T
        src.absorbedBy = null
        src.majinRoomIndex = 0
        src.absorbedAtTimestamp = 0
        src.RevokeObserveMajinVerb()
        src.KO = 1
        src.ClearFrenzyOnKO()
        var/absorberName = (pending.len >= 4) ? pending[4] : "your captor"
        src << "<font color='red'>You are violently expelled from [absorberName]'s corpse!</font>"
        MAJIN_PENDING_EJECTIONS -= "[ckey]"
        return

    if(isRace(MAJIN) && majinAbsorb)
        var/list/credits = MAJIN_PENDING_DIGEST_CREDITS["[ckey]"]
        if(islist(credits) && credits.len)
            for(var/victimCkey in credits)
                majinAbsorb.DigestVictim(src, victimCkey, TRUE)
            MAJIN_PENDING_DIGEST_CREDITS -= "[ckey]"
        majinAbsorb.CheckAllDigestion(src)
        majinAbsorb.StartDigestionLoop(src)

    var/mob/Players/M = FindMajinAbsorbingCkey(ckey)
    if(!M)
        if(absorbedBy && absorbedAtTimestamp)
            var/elapsed = world.realtime - absorbedAtTimestamp
            if(elapsed >= MAJIN_DIGEST_TOTAL_ROLLS * MAJIN_DIGEST_INTERVAL_HOURS HOURS)
                var/absorberCkey = absorbedBy
                absorbedBy = null
                majinRoomIndex = 0
                absorbedAtTimestamp = 0
                RevokeObserveMajinVerb()
                MoveToSpawn(src)
                KO = 0
                src << "<font color='purple'>You have been trapped inside [absorberCkey] for so long that your essence has finally broken down. You are spat out at spawn — drained, but free.</font>"
                if(!MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"])
                    MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] = list()
                MAJIN_PENDING_DIGEST_CREDITS["[absorberCkey]"] += "[ckey]"
        return
    var/list/entry = M.majinAbsorb.absorbed["[ckey]"]
    if(!islist(entry)) return
    entry["mob"] = src
    entry["was_logged_in"] = TRUE
    src.absorbedBy = M.ckey
    src.majinRoomIndex = M.majinOwnedRoom
    src.GrantObserveMajinVerb()
    M.majinAbsorb.CheckDigestion(M, "[ckey]")
    entry = M.majinAbsorb.absorbed["[ckey]"]
    if(!islist(entry)) return
    var/turf/dest = M.GetMajinRoomTurf()
    if(dest)
        src.loc = dest
        src << "You are currently trapped inside of [M]."

// if an absorbed victim is moved/summoned out of the
// Majin absorb zone, immediately release them from the absorber's table
/mob/proc/MajinAbsorbZoneSafeguard()
    if(!ckey) return
    if(!absorbedBy) return
    if(z == MAJIN_ABSORB_Z) return
    var/mob/Players/M = GetMajinByCkey(absorbedBy)
    if(M && M.majinAbsorb && M.majinAbsorb.absorbed && M.majinAbsorb.absorbed["[ckey]"])
        M.majinAbsorb.releaseVictim(M, "[ckey]", "left_zone")
    else
        // Defensive cleanup if the absorber reference disappeared.
        absorbedBy = null
        majinRoomIndex = 0
        RevokeObserveMajinVerb()

// Manual release
/mob/proc/releaseAbsorbedPrompt()
    if(!isRace(MAJIN) || !majinAbsorb)
        src << "You have nothing absorbed."
        return
    if(!majinAbsorb.absorbed || !majinAbsorb.absorbed.len)
        src << "You have no one absorbed."
        return
    var/list/menu = list("Cancel")
    var/list/menu_lookup = list()
    for(var/key in majinAbsorb.absorbed)
        var/list/entry = majinAbsorb.absorbed[key]
        if(!islist(entry)) continue
        var/mob/victim = entry["mob"]
        var/label = victim ? "[victim.name] ([key])" : "[key] (offline)"
        menu += label
        menu_lookup[label] = key
    var/choice = input(src, "Who do you want to spit out?", "Release Absorb") in menu
    if(!choice || choice == "Cancel") return
    var/targetKey = menu_lookup[choice]
    if(!targetKey) return
    majinAbsorb.releaseVictim(src, targetKey, "voluntary")
    src << "You spit [choice] back out."
    OMsg(src, "[src] violently ejects someone from their body!")

/mob/proc/absorbSomebody(mob/target)
    if(!target)
        target = src.Target
    if(!target)
        src << "You need a target to absorb."
        return
    if(target == src)
        src << "You cannot absorb yourself, retard!"
        return
    if(!target.KO)
        src << "[target] must be knocked out before you can absorb them."
        return
    if(target.isRace(ANDROID))
        src << "[target] is mechanical and cannot be absorbed."
        return
    if(target.isRace(MAJIN))
        src << "You cannot absorb another Majin."
        return
    if(!src.majinAbsorb)
        return
    if(target.client && src.client)
        if(target.client.address == src.client.address || target.client.computer_id == src.client.computer_id)
            if(!soIgnore && target.client.computer_id != src.client.computer_id)
                src << "Nice try, bucko."
                return
    majinAbsorb.doAbsorb(src, target)
