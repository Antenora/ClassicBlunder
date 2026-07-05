/mob/proc/LunaticModeOn()
    if(hasSecret("Eldritch"))
        var/SecretInformation/Eldritch/e = src.secretDatum;
        e.useStock(src);
/mob/proc/LunaticModeOff()
    if(hasSecret("Eldritch"))
        var/SecretInformation/Eldritch/e = src.secretDatum;
        e.EndLunaticMode(src);
        src.LunacyDrank=0;

/mob/proc/LunaticModeEffect()
    var/image/img = image(icon='Novabolt.dmi', pixel_x=-15, pixel_y=-15);
    KKTShockwave(src, img, 5, 75, 75, Blend=BLEND_ADD);
    spawn(2) LightningBolt(src, 3);
    spawn(3) RedShock(src, 1);
    spawn(5) PurpleShock(src, 2);
    spawn(7) RedShock(src, 3);
    spawn(8) LightningBolt(src, 3);
    spawn(9) PurpleShock(src, 4);

/proc/RedShock(mob/m, size)
    KKTShockwave(m, 'KenShockwaveBloodlust.dmi', size, Blend=BLEND_ADD);

/proc/PurpleShock(mob/m, size)
    KKTShockwave(m, 'KenShockwavePurple.dmi', size, Blend=BLEND_SUBTRACT);

#define MINIMUM_LUNATIC_MODE 30
/mob/proc/isLunaticMode()
    if(!WoundIntent) return 0;
    if(hasSecret("Eldritch"))
        if(src.secretDatum.secretVariable["Lunatic Mode"] > 0)
            return 1;
    return 0;
/mob/proc/canLunaticMode()
    if(hasSecret("Eldritch"))
        if(src.secretDatum.secretVariable["Madness Active"] == 0)
            src << "You must be unleashing your Madness to enter Lunatic Mode!"
            return 0;
        if(src.secretDatum.secretVariable["Blood Stock"] + src.secretDatum.secretVariable["Resource Stock"] > MINIMUM_LUNATIC_MODE)
            return 1;
    src << "You do not have enough resources or blood stockpiled to enter Lunatic Mode!"
    return 0;
/mob/proc/LunaticModeTimer()
    if(hasSecret("Eldritch"))
        src.secretDatum.secretVariable["Lunatic Mode"] = (src.secretDatum.secretVariable["Lunatic Mode"] - 1);
        if(src.secretDatum.secretVariable["Lunatic Mode"] <= 0)
            src.LunaticModeOff();

//I gaze into my navel and contemplate how Transform / Icon Replace effects could be their own dedicated class
//But enough about that
/mob/proc/Lunatic_Dash_Effect()
    if(!hasSecret("Eldritch")) return;
    spawn()
        var/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form/tf = locate(/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form, src);
        if(!tf) return;

        if(!src.Target) return;
        var/image/T=image(tf.NightmareIcon, pixel_x=tf.NightmareX, pixel_y=tf.NightmareY, loc = src);
        spawn()
            animate(T, alpha=0)
            animate(T, alpha=255, time=2)
        T.appearance_flags=68
        src.Target << T

        spawn(5)
            del T

/mob/var/tmp/image/NightmarePreview;
/mob/proc/NightmarePreviewOn()
    src << "Your nightmare form is now being displayed ONLY to yourself."
    src << "Use this verb again to turn the preview off."
    var/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form/tf = locate(/obj/Skills/Buffs/SlotlessBuffs/Eldritch/True_Form, src);
    if(!tf) return;

    src.NightmarePreview=image(tf.NightmareIcon, pixel_x=tf.NightmareX, pixel_y=tf.NightmareY, loc = src);
    spawn()
        animate(src.NightmarePreview, alpha=0)
        animate(src.NightmarePreview, alpha=255, time=2)
    src.NightmarePreview.appearance_flags=68
    src << src.NightmarePreview
/mob/proc/NightmarePreviewOff()
    src << "You are no longer previewing your Nightmare icon."
    del(src.NightmarePreview);
    src.NightmarePreview = 0;


mob/var/Lunacy=0;//variable that tracks how crazy someone is going
//https://www.youtube.com/watch?v=3Mo1sEJN47c&list=RD3Mo1sEJN47c
mob/var/LunacyDrank=0;//variable that tracks how crazy you've made someone else
//Both are reset on med for 15 seconds

/mob/proc/InflictLunacy(mult, mob/trg)
    if(!src.isLunaticMode()) return
    var/luna = src.getTotalMagicLevel() / 2.5;
    luna *= mult;
    trg.Lunacy += luna;
    src.LunacyDrank += luna;
    trg.LunacyEffects(src);

/mob/proc/ClearLunacy()
    Lunacy=0;

/mob/proc/LunacyEffects(mob/owner)
    if(Lunacy > 100)
        BrainBreak(owner);
/mob/proc/BrainBreak(mob/owner)
    src << "<b>ᛉᛜꓦᚱ ᛒᚱᚣᛁᚢ ᛈᚣᚢ ᚢᛜᚾ ᚺᚣᚢᚧᚳᛊ ᚾᚺᛊ ᛢᚾᚱᚣᛁᚢ</b>"
    AddConfusing(100);
    ClearLunacy();
    owner.BrainBreakMinions();


					