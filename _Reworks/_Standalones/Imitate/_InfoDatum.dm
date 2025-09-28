#define DO_NOT_SAVE list( "vars", "tag","type","parent_type",)
#define PROFILE_SAVING_PATH "Saves/Profiles/"
characterInformation/var/presetName = ""
characterInformation/var/profileName = ""
characterInformation/var/oldAppearance
characterInformation/var/profileProfile
characterInformation/var/profileTextColor
characterInformation/var/profileEmoteColor
characterInformation/var/profileBase = ""

characterInformation/proc/saveInfo(option, num, mob/p)
    InfoToJSON("[p.ckey]_[option]_[num]", p )

characterInformation/proc/InfoToJSON(txtName, mob/p)
    . = list()
    for(var/variable in vars)
        if(variable in DO_NOT_SAVE)
            continue
        if(variable == "profileBase")
            .[variable] = vars[variable] // i dont think this works, p sure it will break the icon either way
        else
            .[variable] = vars[variable]
    
    if(fexists("[PROFILE_SAVING_PATH]/[p.ckey]/[txtName].json"))
        if(!fdel("[PROFILE_SAVING_PATH]/[p.ckey]/[txtName].json"))
            world.log << " Failed to delete [txtName].json"
            return 0
    
    var/write = file("[PROFILE_SAVING_PATH]/[p.ckey]/[txtName].json")
    write << json_encode(.)

characterInformation/proc/takeInformation(mob/p, mob/org, profileName, file_name, saveOld, num, noSave = FALSE)
    presetName = "[profileName]"
    profileName = p.name
    if(saveOld)
        oldAppearance = org.appearance
    profileProfile = p.Profile
    profileTextColor = p.Text_Color
    profileEmoteColor = p.Emote_Color
    profileBase = p.icon
    if(!noSave)
        saveInfo("[file_name]", num, p)

characterInformation/proc/loadProfile(mob/p, file_name, infoDump)
    var/read = infoDump
    if(file_name)
        if(fexists("[PROFILE_SAVING_PATH]/[p.ckey]/[file_name].json"))
            read = file("[PROFILE_SAVING_PATH]/[p.ckey]/[file_name].json")
            read = json_decode(file2text(read))
    if(read)
        var/data = read
        for(var/variable in vars)
            if(data[variable])
                vars[variable] = data[variable]
    

/mob/proc/swapToProfileVars(isOld)
    Text_Color = information.profileTextColor
    Emote_Color = information.profileEmoteColor
    if(isOld)
        appearance = information.oldAppearance
    else  
        icon = information.profileBase
    Profile = information.profileProfile
    var/ogName = name
    name = information.profileName
    if(!name)
        name = ogName
        // having no name fucks shit so might as well confirm this wont happen

    
/mob/var/Imitating = FALSE
/mob/verb/Save_Profile()
    set category = "Roleplay"
    var/profileName = input(src, "What is the preset name of this profile?") as text
    var/currentIndex = 0
    for(var/x in flist("[PROFILE_SAVING_PATH]/[ckey]/"))
        if(findtext(x,"Custom_Profile"))
            var/name = copytext(x,length(x)-5, length(x)-4)
            currentIndex = text2num(name)
    src<<"You currently have [currentIndex] profiles"
    if(currentIndex+1>5)
        src << "You have too many saved profiles bro."
        return
    currentIndex++
    information.takeInformation(src, null, profileName, "Custom_Profile", FALSE, currentIndex)

/mob/verb/Swap_Profiles()
    set category = "Roleplay"
    if(Imitating)
        src << "You can't swap profiles while imitating another person."
        return
    var/list/presetNames = list()
    var/list/data = list()
    for(var/x in flist("[PROFILE_SAVING_PATH]/[ckey]/"))
        var/read = file("[PROFILE_SAVING_PATH]/[ckey]/[x]")
        read = json_decode(file2text(read))
        data[read["presetName"]] += read
        presetNames += read["presetName"]
    var/pickedProfile = input(src, "what one?") in presetNames + "Cancel"
    information.loadProfile(src, FALSE, data[pickedProfile])
    sleep(1) // prob isnt needed but to make sure
    swapToProfileVars(FALSE)

// THIS COULD BE DONE BETTER / MORE EFFECIENT I KNOW
// NO REASON TO READ UP HERE AND NOT PASS THE WHOLE THING TO THE NEXT ONE