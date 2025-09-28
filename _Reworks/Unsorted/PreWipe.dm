// when true give everyone who logs in give/edit/adminheal
/var/list/testerVerbs = list(
    /mob/Admin2/verb/Give_Make,
    /mob/Admin2/verb/Edit,
    /mob/Admin2/verb/EditPassiveHandler,
    /mob/Admin2/verb/Delete,
    /mob/Admin2/verb/AdminHealComplete,
    /mob/Admin2/verb/Event_Character_Setup,
    /mob/Admin3/verb/SagaManagement,
    /mob/Admin3/verb/SecretManagement,
    /mob/Admin3/verb/Give_FutureDiary,
    /mob/proc/giveAllSkillTree,
    /mob/proc/giveAllSigs,
)


/mob/Admin3/verb/AddToTesterWhiteList(name as text)
    set category = "Admin"
    glob.TESTER_WHITE_LIST += name
    world<< "Added [name] to the tester white list"


var/allSkills = list()


/mob/Admin4/verb/giveAllSignatures()
    set name = "Give All Signatures"
    set category = "Admin"
    giveAllSigs()
/mob/Admin4/verb/giveAllSkills()
    set name = "Give All Skill Tree"
    set category = "Admin"
    giveAllSkillTree()




/proc/generateAllSkills()
    world<<"Prepare for lag"
    for(var/typeOfSkill in typesof(/obj/Skills))
        allSkills += new typeOfSkill
    world<<"Done"

/mob/proc/giveAllSkillTree(tier)
    set name = "Give all SkillTree"
    tier = input("What tier do you want to give?") as num
    if(tier > 4 || tier == 0 || tier < -1)
        return src<< "Invalid tier"
    if(length(allSkills) < 1)
        generateAllSkills()
        return
    if(tier == -1)
        for(var/obj/Skills/a in allSkills)
            if(a.Copyable)
                var/obj/Skills/newSkill = new a.type
                src.AddSkill(a)
                src<<"Giving [a]"
                newSkill.Cooldown = 10
    else
        for(var/obj/Skills/a in allSkills)
            if(a.Copyable == tier)
                var/obj/Skills/newSkill = new a.type
                src.AddSkill(a)
                src<<"Giving [a]"
                newSkill.Cooldown = 10

/mob/proc/giveAllSigs(tier)
    set name = "Give all SIG"
    tier = input("What tier do you want to give?") as num
    if(tier > 4 || tier < 1)
        return src<< "Invalid tier"
    if(length(allSkills) < 1)
        generateAllSkills()
        return
    for(var/obj/Skills/a in allSkills)
        if(a.SignatureTechnique == tier)
            var/obj/Skills/newSkill = new a.type
            src.AddSkill(newSkill)
            newSkill.Cooldown = 10

/proc/giveTesterVerbs(mob/p)
    if(glob.TESTER_MODE)
        p.verbs += testerVerbs
        if(p.key in glob.TESTER_WHITE_LIST)
            p<< "You are on the tester white list"
            p<< "You have been given tester verbs"
        else
            p<< "You are not on the tester white list"
            del p


/mob/Admin4/verb/Toggle_Testing()
    set category = "Admin"
    glob.TESTER_MODE = !glob.TESTER_MODE
    world<< "Testing mode is now [glob.TESTER_MODE]"