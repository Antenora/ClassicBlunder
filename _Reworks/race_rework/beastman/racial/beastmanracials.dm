/*

pick a main path
Ferocious-
    Heart of The Beastman - Gain a guage, the more damage that is dealt or taken, the bar goes up, it will burn down.
        When on low life, you gain passive regeneration based on the guage's level, gain The Grit, upon use consume the guage and convert it to a vai health shield (only usable below 50)

    Monkey King - Passively gain hardening, instinct. Gain Nimbus passive, a passive that will dash you to your enemy on normal attack every 10 - tick seconds. (within a range)
        Gain Never Fall, a buff that will store damage taken into a passive, upon reaching its limit, it will automatically release a large cirular aoe.

    Unseen Predator - Change heavy strike into a stacking debuff that reduces the enemy's pure reduction (mayb just end) and applies crippling every time it lands, can only b applied every x seconds
        Upon reaching max stacks, the debuff expires and gives you a buff that gives brutalize, Gain Savagery, upon use it immensely cripples the enemy, and reduces their pure reduction

    Undying Rage - gains an ability that triggers when you reach 0.1% health that prevents your health from falling below 0.1%, time based on asc level
        (potential idea: if you manage to ko an enemy during this buff, instantly heal 2.5-5% per asc health. this would make this a good path for antags(?) or chain verbers, or 2v2s)
        Gain "Fury" passive that is momentum/hardening but for spd
Nimble-
    Feather Maker-
        Pick between Feather Cloak or Feather Knife
            Cloak - After meditating for x seconds, gain a shield of vai health -- scratch this, won't work I think
            Gain an buff that gives you a vai health shield based on your ascension for a few seconds, while the buff is up gain hardening, deflection and reversal

            Knife - Gain innate secret knife style ability and sword punching, where randomly you will summon blades that strike into your enemy, this scales with ascension
                gain an ability that empowers this ability, as well as giving you momentum
    ???

Niche/Spirtual-
    Spirit Walker-
        Gain Stances for any style you take, including sagas
            (these should probably b timed)
            Winged - gain sweeping strikes, extend / gum-gum, combomaster
                0 Str
                -0.25 End
                -0.25 Def
                +0.5 Off
                0 For
                0 Spd
            Ram - Gain godspeed, blurring strikes, steady
                +0.25 Spd
                +0.25 End
                -0.25 Off
                -0.25 Def

            Bear - gain brutalize, instinct, cheapshot
                +0.25 Str
                -0.5 Def
                +0.25 For
            
            Turtle - gain hardening, hardenedframe, deathfield
                +0.5 end
                -0.5 def

        Gain a utility button, once a fight, when used do an ability based on what stance u are in (perhaps, as u can see im an udyr fan boy and this is too much)

    Shapeshifter-
        Gain a 'transformation', a customizable buff that turns you into your full beastial form
            either make this dynamic or make them follow set paths
    
    Trickster-
        gain invisiblity, imitate, allowed to freely tick void on/off, and change scent - rp spec 100%
        treats imagination and intelligence as the same
    
    Fox Fire-
        Change Heavy Strike to a stacking debuff that enemy cost, at max stacks, the next heavy strike consumes the debuff and heals the user
        innate fox fire attunemnt that chills and steals mana/energy on hit (with autohits/projectiles only)
        gain Fox-fire a For homing projectile that causes burning when it hits an enemy, and applies fox fire attunement more intensely
*/


/mob/var/tmp/last_nimbus = -100
/mob/var/nimbus_message = "player_name rides a cloud towards target_name!"
/mob/proc/change_nimbus_message()
    var/inP = input(src, "Use player_name and target_name to swap out for those names.") as text | null
    if(inP >= glob.MAXCATCHLINELENGTH+10 || inP == "" || !inP)
        src << " no too long " 
    else
        nimbus_message = inP