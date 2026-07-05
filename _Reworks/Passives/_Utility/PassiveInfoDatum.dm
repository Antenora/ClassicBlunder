/passiveInfo
    var/name
    var/desc
    var/list/lines=list();
    var/balanceNote;
    New()
        ..();
        var/nameToBe = "[type]";
        name=copytext(nameToBe, findLastSlash(nameToBe));
    proc/
        life()
            setLines();
            setBalanceNote();
            renderDesc();
            updatePassiveInfo();
        setLines()//set on a per-passive basis so that we can reference globalTracker variables
        setBalanceNote()//set on a per-passive basis so that we can reference globalTracker variables
        renderDesc()
            desc = "<ul>";
            for(var/l in lines)
                desc += "<li>[l]</li>";
            desc += "</ul><br>"
            if(balanceNote) desc += "<hr><br><b><h4>BALANCE NOTE:</h4></b> [balanceNote]";
        updatePassiveInfo()
            PassiveInfo[name] = desc;

//This is called when the world loads and when a global save happens
/proc/updatePassiveInfo()
    for(var/infoType in subtypesof(/passiveInfo))
        if(!ispath(infoType)) continue
        var/passiveInfo/info = new infoType()
        if(!info) continue
        info.life()