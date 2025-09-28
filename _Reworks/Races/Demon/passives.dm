/proc/collectJSON()
    var/jsonData = file('passives.json')
    jsonData = file2text(jsonData)
    jsonData = json_decode(jsonData)
    glob.JSON_PASSIVES = jsonData

proc/getJSONInfo(tier, type)
    if(length(glob.JSON_PASSIVES) >= 0)
        collectJSON()
    for(var/x in tier)
        . += glob.JSON_PASSIVES["[type]_[x]"]
        for(var/y in glob.JSON_PASSIVES["[type]_[x]"])
            .["[y]"] = glob.JSON_PASSIVES["[type]_[x]"][y]

proc/getPassiveTier(mob/p)
    . = list()
    var/asc = p.AscensionsAcquired
    if(asc in 0 to 5)
        . += "I"
    if(asc in 2 to 5)
        . += "II"
    if(asc in 3 to 5)
        . += "III"
    if(asc in 4 to 5)
        . += "IV"
    if(asc == 5)
        . += "V"