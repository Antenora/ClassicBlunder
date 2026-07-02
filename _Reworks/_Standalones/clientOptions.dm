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
    var/soundOn = 1
    var/zoom2x = 0          // off = 1x (default), on = 2x map zoom
    var/cmPanX = 0          // saved menu drag offsets (px) from each panel's default anchor
    var/cmPanY = 0
    var/optPanX = 0
    var/optPanY = 0
    var/invPanX = 0
    var/invPanY = 0
    var/skPanX = 0
    var/skPanY = 0
    var/ppPanX = 0          // right-click player/admin panel
    var/ppPanY = 0
    var/ttPanX = 0          // tech tree
    var/ttPanY = 0
    var/descPanX = 0        // inventory item-description popup
    var/descPanY = 0
    var/aqPanX = 0          // acquire skills menu
    var/aqPanY = 0
    var/list/disableInnovate = list()
    var/list/savableVars = list("oldZanzo","soundOn","zoom2x","cmPanX","cmPanY","optPanX","optPanY","invPanX","invPanY","skPanX","skPanY","ppPanX","ppPanY","ttPanX","ttPanY","descPanX","descPanY","aqPanX","aqPanY","seePronouns", "usePronouns", "useSupporter", "useDonator", "disableLoginAlert", "currentFontFamily", "currentFontSize", "ShowOOC", "LOOCinIC", "AllTabOOC", "LOOCinAll", "AdminAlerts", "CombatMessagesInIC", "disableInnovate")
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

/client/proc/ApplyAudioPref()
    winset(src, null, list("command" = ".configure sound [prefs.soundOn ? "on" : "off"]"))

/mob/verb/Gamepad_Mapping()
    set category = "Utility"
    set hidden = 1
    set name = "Gamepad Mapping"
    winset(src, null, list("command" = ".gamepad-mapping"))

// this fires the same client command that control freak got rid of
/mob/verb/Reconnect()
    set category = "Utility"
    set hidden = 1
    set name = "Reconnect"
    winset(src, null, list("command" = ".reconnect"))


