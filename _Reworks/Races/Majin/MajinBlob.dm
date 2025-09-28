/var/game_loop/blobLoop = new(5, "Update")

blobDropper/proc/updateVars(mob/Players/p)
    var/ascen = p.AscensionsAcquired
    numBlobsMax = MAX_BLOBS + getMaxBlobs(ascen)
    blobDropRate = MAJIN_BLOB_DROP_RATE + getDropRate(ascen)
    dropThreshold = MAJIN_BLOB_DROP_THRESHOLD + getDropThreshold(ascen)

blobDropper/proc/getMaxBlobs(ascen)
    return 2 *  ascen

blobDropper/proc/getDropRate(ascen)
    return ascen * 0.05

blobDropper/proc/getDropThreshold(ascen)
    return ascen * 5

blobDropper/proc/dropBlob(mob/Players/p, override = 0)
    var/turf/T = p.loc
    var/newX = T.x + rand(-3, 3)
    var/newY = T.y + rand(-3, 3)
    for(var/i = 0, i < 10; i++)
        var/turf/t = locate(newX,newY,p.z)
        if(t.density)
            if(i == 9) break
            newX = T.x + rand(-3, 3)
            newY = T.y + rand(-3, 3)
            continue
        else
            break

    blobList.Add(new/obj/blob(p, newX, newY, p.z, override))
    numBlobs++

blobDropper/proc/canDropBlob(mob/Players/p)
    if(numBlobs >= numBlobsMax)
        return 0
    if(p.Health < dropThreshold)
        return 1
    return 0

blobDropper/proc/tryDropBlob(mob/Players/p, override = 0)
    if(p.Class != "Innocent") return
    if(canDropBlob(p))
        if(rand(1, 10) / 10 <= blobDropRate || override)
            dropBlob(p, override)

blobDropper/proc/resetVariables(mob/Players/p)
    numBlobs = 0
    blobList = list()
    updateVars(p)


/obj/blob
    proc/flyingOutAnimation(landingX, landingY)
        // it isn't so much about the x/y it needs to animate and move with like pixel or a matrix ro something
        sleep(1)
        alpha = 155
        var/halfwayX = (landingX-x)/2
        var/halfwayY = (landingY-y)/2
        animate(src, pixel_x = halfwayX*32, pixel_y = halfwayY*32, pixel_z=16, time = 5, easing = SINE_EASING | EASE_IN)
        animate(alpha = 255, time = 3)
        sleep(5)
        animate(src, pixel_x = pixel_x + (halfwayX*32), pixel_y = pixel_y + (halfwayY*32), pixel_z=0, time = 5, easing = BOUNCE_EASING,flags = ANIMATION_END_NOW)
        sleep(5)
    icon = 'Icons/Characters/Majin/blob.dmi'
    icon_state = "buff"
    density = 0
    Destructable = FALSE
    Grabbable = FALSE
    var/pickedUp = 0
    var/owner = null
    var/toDeath = 0
    var/tmp/obj/Skills/Buffs/SlotlessBuffs/blobBuff/heldBuff = null
    New(mob/Players/p, _x,_y,_z, override)
        loc = locate(p.x, p.y, p.z)
        alpha = 0
        owner = p.ckey
        toDeath = 20 * (1 + p.AscensionsAcquired)
        getRandValue(p, override)
        flyingOutAnimation(_x, _y, _z)
        loc = locate(_x, _y, _z)
        pixel_x = 0
        pixel_y = 0
        pixel_z = 0
        blobLoop += src

/obj/blob/proc/getRandValue(mob/Players/p, override)
    // get either a random buff with health or a super health
    var/ascen = p.AscensionsAcquired
    var/val = rand(1, 100)
    var/buff = FALSE
    if(val <= 10 || override)
        // make the super heal buff
        icon_state = "superheal"
        val = 1 + (0.1 * ascen) + (0.05 * (100 - p.Health))
    else
        buff = pick("PureReduction","Juggernaut","GiantForm","DemonicDurability")
        val = 0.1 + (0.1 * ascen) + (0.05 * ((100 - p.Health)/2))
    heldBuff = new(p, val, buff)
    // heldBuff.loc = src

/obj/blob/Cross(atom/obstacle)
    ..()
    if(istype(obstacle, /mob/Players))
        var/mob/Players/p = obstacle
        if(p.ckey == owner && !pickedUp)
            if(heldBuff)
                p.AddSkill(heldBuff)
                heldBuff.Trigger(p)
                p.majinPassive.blobList -= src
                pickedUp = 1
            return TRUE
        else if(p.ckey != owner && !pickedUp)
            OMsg(p , "[p] steps over something!")
            src.loc = null
            return TRUE


/obj/blob/Update()
    toDeath--
    if(toDeath <= 0 || pickedUp)
        blobLoop -= src
        del src
/mob/Admin3/verb/openBlobdatum(mob/player in players)
    if(player.majinPassive)
        var/atom/A = player.majinPassive
        var/Edit="<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
        var/list/B=new
        Edit+="[A]<br>[A.type]"
        Edit+="<table width=10%>"
        for(var/C in A.vars) B+=C
        B.Remove("Package","bound_x","bound_y","step_x","step_y","Admin","Profile", "GimmickDesc", "NoVoid", "BaseProfile", "Form1Profile", "Form2Profile", "Form3Profile", "Form4Profile", "Form5Profile")
        for(var/C in B)
            Edit+="<td><a href=byond://?src=\ref[A];action=edit;var=[C]>"
            Edit+=C
            Edit+="<td>[Value(A.vars[C])]</td></tr>"
        Edit += "</html>"
        usr<<browse(Edit,"window=[A];size=450x600")





/mob/proc/removeBlobBuffs()
    if(majinPassive)
        for(var/obj/Skills/Buffs/SlotlessBuffs/blobBuff/buff in src)
            if(buff)
                if(buff.Using)
                    buff.Trigger(src)
                buff.loc = null
                src.DeleteSkill(buff)
        for(var/obj/blob/b in majinPassive.blobList)
            if(b)
                b.toDeath = 0
                b.Update()
