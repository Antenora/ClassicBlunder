/proc/getCurrentPlayers()
    var/list/theplayers = list()
    for(var/mob/p in theplayers)
        if(p.client)
            theplayers += p
    return theplayers

// NOTE: WE CURRENTLY AREN'T DOING FACTIONS.
//WHEN YOU WANT TO ADD FACTIONS BACK, REMOVE THE BLOCK COMMENT! THIS IS TO CLEAR OUT THE ADMIN VERBS!
/*

/mob/Admin3/verb/GiveRegisterVerb()
    set name = "Give Register Verb"

    for(var/mob/p in players)
        if(p.information.faction == "Solo")
            players -= p
    var/mob/p = input(src, "Pick a player", "Player") in players
    p << "You have been given the register verb."
    p.verbs += /mob/proc/RegisterMember



/mob/Admin3/verb/AssignJob()
    set name = "Assign Job"

    var/mob/p = input(src, "Pick a player", "Player") in players
    var/choice = input(src, "Pick a job", "Job") in JOBS
    p.information.setJob(choice)


/mob/Admin3/verb/changeFaction(mob/b in players)
    set name = "Change Faction"
    if(!b.client)
        return
    var/choice = input(src, "Pick a faction", "Faction") in FACTIONS
    b.information.setFaction(choice)

/mob/Admin3/verb/changeNationalities(mob/b in players)
    set name = "Change Nationalities"
    if(!b.client)
        return
    alert("if i catch u abusing the freedom to freely input in this i will smite you")
    b.information.nationality = input(src, "What nationality?") as text
    b.information.secondNationality = input(src, "what second nationality") as text

/mob/Admin3/verb/offerNationalityChange(mob/b in players)
    set name = "Offer Nation Change"
    if(!b.client)
        return
    b.information.setNationality(b)
*/
/mob/verb/customizePU()
    set name = "Customize: PU Charging"
    set category = "Other"
    if(!src.client)
        return
    var/choice = input(src, "Change PU Charging", "PU Charging Style") as text
    if(length(choice)>200)
        return
    if(length(choice)<1)
        return
    custom_powerup = choice
    choice = input(src, "Do you want to include your name in the PU charging?") in list("Yes", "No")
    if(choice == "Yes")
        customPUnameInclude = TRUE
    else
        customPUnameInclude = FALSE

/mob/verb/Admins()
    set name = "Admins"
    set category = "Other"
    if(!(world.time > src.verb_delay)) return
    src.verb_delay = world.time + 1
    var/View = {"<html><head><title>Admins</title>
<style>
body{margin:0;background:#0d1730;color:#d8f6ff;font-family:Verdana,Arial,sans-serif;font-size:12px;}
.wrap{border:2px solid #45c7e0;margin:8px;padding:10px;background:#132447;}
h2{margin:0 0 8px 0;color:#8be9ff;font-size:16px;letter-spacing:1px;}
.row{display:flex;justify-content:space-between;border-top:1px solid #2e6682;padding:5px 0;}
.row:first-of-type{border-top:0;}
.online{color:#55ee55;font-weight:bold;}
.rank{color:#ffd76b;margin-left:12px;}
</style></head><body><div class='wrap'><h2>ADMINS</h2>"}
    var/any = FALSE
    for(var/mob/p in players)
        if(p.Admin)
            any = TRUE
            var/show_key = p.DisplayKey ? p.DisplayKey : p.key
            View += "<div class='row'><span>[show_key]<span class='rank'>Rank [p.Admin]</span></span><span class='online'>Online</span></div>"
    if(!any)
        View += "<div class='row'><span>No admins are currently online.</span></div>"
    View += "</div></body></html>"
    src << browse(View, "window=Admins;size=320x420")



/*
/mob/verb/FactionCount()
    set name = "Faction Count"
    set category = "Other"
    var/list/total = FACTIONS
    for(var/mob/Players/M in players)
        if(!M.client)
            continue
        if(isai(M))
            continue
        if(M.information.faction in total)
            total["[M.information.faction]"] += 1
            continue
        else if(!(M.information.faction in FACTIONS))
            total["[M.information.faction]"] += 1
    src<<"______________"
    src<<"Faction Count:"
    src<<"______________"
    for(var/x in total)
        if(total[x]>0)
            src<<"[x]: [total[x]]"
characterInformation*/



//TODO: somebody else can do examine
/mob/var/hidingInformation = FALSE
/mob/verb/Hide_Information()
    set category = "Other"
    hidingInformation = !hidingInformation
    src << "The ID Card is [hidingInformation ? "hidden." : "not hidden."]"

characterInformation/proc/getFactionGuild(mob/Players/p)
    var/content = ""
    if(showFaction)
        content += "<font color='[factionColor]'>[faction] (<font color='[jobColor]'>[job]</font>)</font>"
    if(showGuild)
        content += "\n"
        for(var/x in p.inGuilds)
            if(findGuildByID(x))
                var/guild/g = findGuildByID(x)
                if(p.UniqueID == g.ownerID)
                    content += "[g.name] ( Leader )"
                else if(p.UniqueID in g.officers)
                    content += "[g.name] ( Officer )"

                else
                    content += "[g.name] ( Member )"
characterInformation/proc/getInformation(mob/p, see_pronouns)
    if(p.hidingInformation)
        return "[p.subjectpronoun() == "They" ? "They have" : "[p.subjectpronoun()] has"] no ID Card"
    var/msg = ""
    // if(rankingNumber == "ERROR")
    //     rankingNumber = num2text(rand(1000,9001))
    if(see_pronouns)
        var/theyString = p.subjectpronoun() == "They" ? "use" : "uses"
   //     var/theyString2 = p.subjectpronoun() == "They" ? "are" : "is"
        msg={"
<font face='courier'><font color='#color'>[p.name]'s ID Card is visible.
[p.subjectpronoun()] [theyString] [src.pronouns[1]]/[src.pronouns[2]]
<i>"[catchline]"</i>\n
[getInfo()]"}
    else
        msg={"
<font face='courier'><font color='#color'>[p.name]'s ID Card is visible.
<i>"[catchline]"</i>\n
[getInfo()]"}

    return msg
