#define DO_NOT_SAVE list( "vars", "tag","type","parent_type","profileBase")
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
    else if(information.profileBase)
        icon = information.profileBase
    Profile = information.profileProfile
    var/ogName = name
    name = information.profileName
    if(!name)
        name = ogName
        // having no name fucks shit so might as well confirm this wont happen

    
/mob/var/Imitating = FALSE
#define MAX_PROFILES 5

mob/proc/ProfileSave(presetName)
    if(!presetName) return 0
    var/savefile/F = new("[PROFILE_SAVING_PATH][ckey].sav")
    F.cd = "/profiles/[presetName]"
    F["pname"] << name
    F["profile"] << Profile
    F["textColor"] << Text_Color
    F["emoteColor"] << Emote_Color
    F["appearance"] << appearance       // full look, icon + overlays + underlays
    return 1

mob/proc/ProfileList()
    var/savefile/F = new("[PROFILE_SAVING_PATH][ckey].sav")
    F.cd = "/profiles"
    var/list/out = list()
    for(var/n in F.dir)
        out += n
    return out

mob/proc/ProfileLoad(presetName)
    if(!presetName) return 0
    var/savefile/F = new("[PROFILE_SAVING_PATH][ckey].sav")
    F.cd = "/profiles"
    if(!(presetName in F.dir)) return 0
    F.cd = "/profiles/[presetName]"
    var/app; F["appearance"] >> app
    var/nm; F["pname"] >> nm
    var/prof; F["profile"] >> prof
    var/tc; F["textColor"] >> tc
    var/ec; F["emoteColor"] >> ec
    if(app) appearance = app             // swaps icon + overlays as one unit
    if(nm) name = nm
    Profile = prof
    if(!isnull(tc)) Text_Color = tc
    if(!isnull(ec)) Emote_Color = ec
    return 1

/mob/verb/Save_Profile()
    set category = "Roleplay"
    set hidden = 1
    var/pname = input(src, "Name this profile:") as null|text
    if(!pname) return
    pname = replacetext(pname, "/", "-")   // keep it a valid savefile key
    var/list/existing = ProfileList()
    var/cnt = existing.len
    if("Default" in existing) cnt--        // the auto Default doesn't count against the limit
    if(!(pname in existing) && cnt >= MAX_PROFILES)
        src << "You have too many saved profiles (max [MAX_PROFILES])."
        return
    ProfileSave(pname)
    src << "Saved profile '[pname]'."

/mob/verb/Swap_Profiles()
    set category = "Roleplay"
    set hidden = 1
    if(Imitating)
        src << "You can't swap profiles while imitating another person."
        return
    var/list/existing = ProfileList()
    if(!("Default" in existing))           // first swap
        ProfileSave("Default")
        existing = ProfileList()
    if(!existing.len) return
    var/picked = input(src, "Swap to which profile?", "Swap Profiles") as null|anything in existing
    if(!picked) return
    if(ProfileLoad(picked))
        src << "Swapped to '[picked]'."