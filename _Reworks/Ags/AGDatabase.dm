var/archive/archive = new()



archive
    var/list/AGs = list()
    var/list/SagaUsers = list()
    var/list/SecretUsers = list()

    proc/addAG(AG)
        AGs += AG

    proc/addSagaUser(saga, mob/user)
        SagaUsers += "[saga], [user.name]([user.ckey])"

    proc/addSecretUser(secret, mob/user)
        SecretUsers += "[secret], [user.name]([user.ckey])"

    proc/loadAGs()
        AGs = list()
        for(var/obj/Items/AG in world)
            if(AG.Augmented)
                if(AGs.len)
                    var/exists = 0
                    for(var/AG2 in AGs)
                        if(AG2 == AG)
                            exists = 1
                    if(!exists)
                        AGs += AG
                else
                    AGs += AG



/mob/Admin4/verb/establishArchive()
    set name = "Establish Archive"
    set category = "Admin"
    if(!archive || archive.type != archive)
        archive = new()
        archive.loadAGs()
        archive.addSagaUser("SAGA", usr)
        archive.addSecretUser("SECRET", usr)
        usr<< "Archive established."
    else
        usr<< "Archive already established."


/mob/Admin4/verb/editArchive()
    set name = "Edit Archive"
    set category = "Admin"
    if(!archive || archive.type != archive)
        usr<< "Archive not established."
    else
        var/atom/A = archive
        var/list/B = list()
        for(var/C in A.vars) B += C
        usr.client?.SheetShow("edit:\ref[A]", "EDIT", "[A]", "[A.type]", SheetVarRows(A, B), "a name to edit")


/mob/Admin3/verb/View_Saga_Database()
    src<<jointext(archive.SagaUsers, "\n")

/mob/Admin3/verb/View_Secret_Database()
    src<<jointext(archive.SecretUsers, "\n")
/mob/Admin3/verb/View_AG_Database()
    set category = "Admin"
    if(!archive)
        archive = new()
    archive.loadAGs()
    winset(src, "gridAG.grid", "cells=0x0")
    winset(src, "gridAG", "is-visible=true")
    var/height = 1
    var/width = 0
    for(var/ag in archive.AGs)
        if(width>3)
            height++
            width=0
        src<<output(ag, "gridAG.grid:[++width],[height]")