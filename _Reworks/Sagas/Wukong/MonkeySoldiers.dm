SoldierTracker
    var/totalSoldiers
    var/list/monkeySoldiers = list()
    var/maxSoldiers = 1
/mob/var/SoldierTracker/MonkeySoldiers = new()


/mob/proc/summonMonkeySoldier(dmg, tier)
    if(tier != MonkeySoldiers.maxSoldiers) MonkeySoldiers.maxSoldiers = tier
    if(MonkeySoldiers.totalSoldiers < MonkeySoldiers.maxSoldiers)
        MonkeySoldiers.monkeySoldiers += new/mob/MonkeySoldier(src, dmg, tier * 75)
        MonkeySoldiers.totalSoldiers += 1
        blobLoop += MonkeySoldiers.monkeySoldiers[MonkeySoldiers.totalSoldiers]

/mob/MonkeySoldier
    var/damageValue
    var/timeLimit
    var/distanceLimit = 30
    var/spawnTime
    var/lastAttack
    var/attackDelay = 15
    var/owner_ref
    New(mob/p, dmg, timer)
        owner_ref = "\ref[p]"
        damageValue = clamp(dmg / 2, 0.1,1)
        timeLimit = timer
        lastAttack = 0
        attackDelay = 10
        SetTarget(p.Target)
        spawnTime = world.time
        icon = p.icon
        x = p.x
        y = p.y
        z = p.z
        appearance = new/mutable_appearance(p)
        alpha = 155
    Update()
        var/mob/owner = locate(owner_ref)
        if(world.time > spawnTime + timeLimit)
            owner.MonkeySoldiers.monkeySoldiers -= src
            owner.MonkeySoldiers.totalSoldiers --
            del(src)
        else
            if(Target != owner.Target) Target = owner.Target
            if(lastAttack + attackDelay < world.time)
                lastAttack = world.time
                if(Target && get_dist(Target,src) < distanceLimit)
                    lastAttack = world.time
                    flick("Attack", src)
                    owner.HitEffect(Target, 0, 1)
                    Target.LoseHealth(damageValue)

// /mob/verb/summonSoldier()
//     set category = "Debug"
//     if(!Target) return
//     if(Target == src) return
//     summonMonkeySoldier(min_max_scaling(25.43), 2)


/obj/Skills/Buffs/SlotlessBuffs
    Marlon_Anti_Job_Buff
        DefMult = 3
        EndMult = 3
        StrMult = 3
        ForMult = 3
        SpdMult = 3
        OffMult = 3
        passives = list("BackTrack" = 1, "Flow" = 1, "Instinct" = 1, "GodKi" = 1, "NoWhiff" = 1, "NoMiss" = 1, "MonkeyKing" = 4)
        FlashChange=1
        HairLock=1
        AuraLock='BLANK.dmi'
        IconLock='UltraInstinct.dmi'
        IconUnder=1
        LockX=-18
        LockY=-21
        TopOverlayLock='UltraInstinctSpark.dmi'
        IconTint=list(1,0.15,0.15, 0.15,1,0.15, 0,0,1, 0,0,0)
        adjust(mob/p)
            passives = list("BackTrack" = clamp(round(p.Potential/10), 1,10), "Flow" = clamp(round(p.Potential/10), 1,10), "Instinct" = clamp(round(p.Potential/10), 1,10), "GodKi" = 1, "NoWhiff" = 1, "NoMiss" = 1)
        verb/Anti_Job()
            set category = "Skills"
            set name = "Anti Job Mode"
            adjust(usr)
            src.Trigger(usr)
    TestBuff1
        MonkeyKing = 2
        Cooldown = 5
        verb/TestBuff1()
            set category = "Skills"
            set name = "Test Buff 1"
            src.Trigger(usr)