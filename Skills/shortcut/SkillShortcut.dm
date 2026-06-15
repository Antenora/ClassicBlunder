//DEFINES
#define SHORTCUT_HELP {"You can use this verb to set up to 10 shortcuts.
The verb 'Skill-Shortcut-1' (or 2, 3, 4, etc.) can be keyed to fire a specific skill contained in your mob.
Some restrictions may apply.
You are free to macro skills by their name as usual.
Options marked with a * already have a skill set to them.
What shortcut do you want to set?"}

#define SHORTCUT_SKILL_HELP "What skill do you want to set to this shortcut?"
#define SHORTCUT_CLEAR_HELP "What shortcut do you want to clear out?"

//VARS
/obj/Skills/var/
    canBeShortcut=0;
/mob/var/
    shortcut/shortcuts
/shortcut/var/
    obj/Skills/shortcut1;
    obj/Skills/shortcut2;
    obj/Skills/shortcut3;
    obj/Skills/shortcut4;
    obj/Skills/shortcut5;
    obj/Skills/shortcut6;
    obj/Skills/shortcut7;
    obj/Skills/shortcut8;
    obj/Skills/shortcut9;
    obj/Skills/shortcut10;
    
//VERBS
/mob/verb/
    Set_Skill_Shortcuts()
        set category="Utility"
        usr.setSkillShortcut();
    Clear_Skill_Shortcut()
        set category="Utility"
        usr.clearSkillShortcut();

    //hidden so as to not clutter the tabs
    Skill_Shortcut_1()
        set hidden=1;
        usr.attemptShortcut(1);
    Skill_Shortcut_2()
        set hidden=1;
        usr.attemptShortcut(2);
    Skill_Shortcut_3()
        set hidden=1;
        usr.attemptShortcut(3);
    Skill_Shortcut_4()
        set hidden=1;
        usr.attemptShortcut(4);
    Skill_Shortcut_5()
        set hidden=1;
        usr.attemptShortcut(5);
    Skill_Shortcut_6()
        set hidden=1;
        usr.attemptShortcut(6);
    Skill_Shortcut_7()
        set hidden=1;
        usr.attemptShortcut(7);
    Skill_Shortcut_8()
        set hidden=1;
        usr.attemptShortcut(8);
    Skill_Shortcut_9()
        set hidden=1;
        usr.attemptShortcut(9);
    Skill_Shortcut_10()
        set hidden=1;
        usr.attemptShortcut(10);

//PROCS
/mob/proc/
    initShortcuts()//called when mob is loaded
        if(!shortcuts) shortcuts=new/shortcut();

/mob/proc/
    //these two are used to deploy the assigned skill
    attemptShortcut(num)
        if(shortcuts)
            var/obj/Skills/attemptedSkill = shortcuts.vars["shortcut[num]"];
            if(attemptedSkill)fireShortcut(attemptedSkill);
            else src << "You don't have a skill assigned to <b>Shortcut [num]</b>!";
    //god i hate that this proc is necessary atm = _ =
    fireShortcut(obj/Skills/s)
        if(s.HeldSkill)
            held_skill_from_macro = world.time
            var/raw = s.HeldVerbName ? s.HeldVerbName : s.name
            var/ident = raw ? replacetext(replacetext(raw, " ", "_"), "-", "_") : null
            if(ident && hascall(s, ident))
                call(s, ident)()
            else
                BeginHeldSkill(s)
            return;
        if(istype(s, /obj/Skills/Queue))
            SetQueue(s);
        else if(istype(s, /obj/Skills/Projectile))
            UseProjectile(s);
        else if(istype(s, /obj/Skills/AutoHit))
            Activate(s);
        else if(istype(s, /obj/Skills/Grapple))
            var/obj/Skills/Grapple/g = s;
            g.Activate(src);

//these are used to assign a shortcut
/mob/proc/
    setSkillShortcut()
        var/list/choices = getSkillShortcutChoices();
        var/choice = input(src, SHORTCUT_HELP, "Set Skill Shortcuts") in choices;
        if(choice=="Nevermind") return;
        var/scName = getShortcutName(choice);
        var/list/skills = getPotentialShortcutSkills();
        var/obj/Skills/sChoice = input(src, SHORTCUT_SKILL_HELP, "Set [choice]") in skills;
        if(sChoice=="Nevermind") return;
        shortcuts.vars[scName]=sChoice;
        src << "<b>[sChoice]</b> has been set as your <b>[choice]</b>!"
    getSkillShortcutChoices()
        var/list/l = list("Nevermind");
        for(var/c = 1, c <= 10, c++)
            var/option = "Shortcut [c]"
            var/obj/Skills/skillAssigned = shortcuts.vars["shortcut[c]"];
            if(skillAssigned) option+="   ([skillAssigned.name])";
            l.Add(option);
        return l;
    getShortcutName(name)
        var/string = copytext(name, 1, findtext(name, "   ", 1, 0));
        var/spacePos = findtext(string, " ", 1, 0);
        string = copytext(string, 1, spacePos) + copytext(string, spacePos+1, 0);
        string = lowertext(string);
        return string;

//these are used to remove an assigned shortcut
/mob/proc/
    clearSkillShortcut()
        var/list/choices = getFilledSkillShortcuts();
        var/choice = input(src, SHORTCUT_CLEAR_HELP, "Clear Skill Shortcut") in choices;
        if(choice=="Nevermind") return;
        var/scName = getShortcutName(choice);
        shortcuts.vars[scName] = null;
        src << "<b>[choice]</b> was cleared out of your shortcuts!"
    getFilledSkillShortcuts()
        var/list/r = list("Nevermind");
        for(var/i = 1, i <= 10, i++)
            var/obj/Skills/skillExist = shortcuts.vars["shortcut[i]"]
            if(skillExist) r.Add("Shortcut [i]   [skillExist.name]");
        if(r.len < 2) src << "You don't have any shortcuts to clear out!";
        return r;

//these are used for determining if a skill is already held by a shortcut or if its a valid skill to be shortcut
/mob/proc/
    getPotentialShortcutSkills()
        var/list/r = list("Nevermind");
        for(var/obj/Skills/s in src.contents)
            if(skillIsShortcut(s)) continue;
            if(s.canBeShortcut) r.Add(s);
        if(r.len < 2) src << "You don't have any skills that can be used with shortcuts!"
        return r;
    skillIsShortcut(obj/Skills/s)
        for(var/i = 1, i <= 10, i++)
            if(src.shortcuts.vars["shortcut[i]"] == s)
                return 1
        return 0;
    
    