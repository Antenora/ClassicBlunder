/proc/collectJSON()
    var/jsonData = file('passives.json')
    jsonData = file2text(jsonData)
    jsonData = json_decode(jsonData)
    glob.JSON_PASSIVES = jsonData

proc/getJSONInfo(tier, type)
    if(length(glob.JSON_PASSIVES) <= 0)
        collectJSON()
    . = list()
    for(var/x in tier)
        var/list/source = glob.JSON_PASSIVES["[type]_[x]"]
        if(source)
            for(var/y in source)
                .[y] = source[y]

proc/getPassiveTier(mob/p, passivesObtained="NotSet", secondary=FALSE)//passivesObtained only checks Mainline DA passives. other sources grab potential
    if(passivesObtained=="NotSet")
        p << "You are accessing getPassiveTier without a passivesObtained parameter"
        return 0;
    . = list()
    var/asc = p.AscensionsAcquired
    if(asc in 0 to 6)
        . += "I"
    if(asc in 2 to 6)
        if(passivesObtained >= getPassiveThreshold(2, secondary))
            . += "II"
    if(asc in 3 to 6)
        if(passivesObtained >= getPassiveThreshold(3, secondary))
            . += "III"
    if(asc in 4 to 6)
        if(passivesObtained >= getPassiveThreshold(4, secondary))
            . += "IV"
    if(asc in 5 to 6)
        if(passivesObtained >= getPassiveThreshold(5, secondary))
            . += "V"

/proc/getPassiveThreshold(tier, secondary=FALSE)
    if(!secondary)
        if(tier==1)
            return 0;
        if(tier==2)
            return 3;
        if(tier==3)
            return 5;
        if(tier==4)
            return 10;
        if(tier==5)
            return 15;
    else//secondary amts
        if(tier==1)
            return 0;
        if(tier==2)
            return 1;
        if(tier==3)
            return 2;
        if(tier==4)
            return 5;
        if(tier==5)
            return 7;
