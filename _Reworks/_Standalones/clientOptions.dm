#define CONFIG_OPTIONS_JSON_FOLDER "Saves/options_json/"


client/var/Options/prefs = new()

Options/
    var/seePronouns = 1
    var/usePronouns = 1
    var/useSupporter = 0
    var/useDonator = 1
    var/currentFontFamily = "Gotham Book"
    var/currentFontSize = 8
    var/disableLoginAlert = 0
    var/CombatMessagesInIC = FALSE
    var/autoAttacking = FALSE
    var/oldZanzo = FALSE
    var/list/disableInnovate = list()
    var/list/savableVars = list("oldZanzo","seePronouns", "usePronouns", "useSupporter", "useDonator", "disableLoginAlert", "currentFontFamily", "currentFontSize", "ShowOOC", "LOOCinIC", "AllTabOOC", "LOOCinAll", "AdminAlerts", "CombatMessagesInIC", "disableInnovate")
    proc/savePrefs(ckey)
        . = list()
        for(var/opt in savableVars - autoAttacking)
            .["[opt]"] += vars[opt]
        if(deleteOldPrefs(ckey))
            var/write = file("[CONFIG_OPTIONS_JSON_FOLDER][ckey].json")
            write << json_encode(.)
    proc/loadPrefs(ckey)
        var/thing2Return
        if(fexists("[CONFIG_OPTIONS_JSON_FOLDER][ckey].json"))
            var/read = file("[CONFIG_OPTIONS_JSON_FOLDER][ckey].json")
            if(read)
                thing2Return = json_decode(file2text(read))
                for(var/opt in vars)
                    if(!isnull(thing2Return[opt]))
                        vars[opt] = thing2Return[opt]
    proc/deleteOldPrefs(ckey)
        . = 1
        if(fexists("[CONFIG_OPTIONS_JSON_FOLDER][ckey].json"))
            if(!fdel("[CONFIG_OPTIONS_JSON_FOLDER][ckey].json"))
                world.log << "Failed to delete old preferences for [ckey]."
                return 0






/client/proc/togglePref(pref)
    if (pref == "seePronouns")
        prefs.seePronouns = !prefs.seePronouns
    else
        setPref(pref, !getPref(pref))

/client/proc/setPref(pref, value)
    prefs.vars["[pref]"] = value
    prefs.savePrefs(mob.ckey)

/client/proc/getPref(pref)
    return prefs.vars["[pref]"]


