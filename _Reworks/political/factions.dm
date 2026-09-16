
/mob/proc/RegisterMember()
    set name = "Register Member"
    set category = "Roleplay"
    set hidden = 1
    // get the person targetted
    if(!Target)
        src<< "You need a target"
        return
    if(!Target.client)
        src<<"They are not a player."
        return
    if(get_dist(src, Target) > 1)
        src<<"Too far away."
        return
    if(Target.information.faction != information.faction)
        src<<"They are not a member of your faction."
        return
    // check if they are already registered
    var/selectedJob = Ask(src, "What job would you like to set [Target] to?", "Register Member", "Staff Member", "pick", (JOBS - list("Branch Direction", "Unregistered")), 0)
    var/acceptance = Ask(Target, "Do you accept the job title of [selectedJob] from [src]?", "Register Member", null, "pick", list("Yes","No"), 0)
    switch(acceptance)
        if("Yes")
            Target.information.setJob(selectedJob)
        if("No")
            src << "[Target] declined your job offer!"




characterInformation
    var/faction = "UNEMPLOYED"
    var/factionColor = "#6c0303d7"
    var/job = "BROKE BOY"
    var/jobColor = "#0ba800ff"
    var/showFaction = TRUE
    proc/assignJob(mob/admin, mob/target)
        var/choice = Ask(admin, "Pick a job", "Job", null, "pick", JOBS, 0)
        target.information.setJob(choice)

    proc/pickJob(mob/p) // TEMPORARY UNTIL IT GETS SET UP VIA SPAWNING
        var/choice = Ask(p, "Pick a job", "Job", null, "pick", JOBS, 0)
        setJob(choice)
        p << "You are now a [choice]."


    proc/setJob(name)
        job = name


    proc/setFaction(name)
        faction = name
        factionColor = FACTION_COLORS[name]
        if(factionColor == null)
            factionColor = "white"

    proc/pickFaction(mob/p) // TEMPORARY UNTIL IT GETS SET UP VIA SPAWNING
        var/choice = Ask(p, "Pick a faction", "Faction", null, "pick", FACTIONS, 0)
        setFaction(choice)
        p << "You are now a member of the [choice] faction."