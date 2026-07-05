#define SUPPORTER_T1_TITLE "Stolen Code Seeder"
#define SUPPORTER_T1_COLOR "#FFC107"
#define SUPPORTER_T2_TITLE "Supporter"
#define SUPPORTER_T2_COLOR "#FF9800"
#define SUPPORTER_T3_TITLE "Pizza Supplier"
#define SUPPORTER_T3_COLOR "#FF5722"
#define SUPPORTER_T4_TITLE "Giga Supporter"
#define SUPPORTER_T4_COLOR "#F44336"
#define SUPPORTER_T5_TITLE "Top Supporter"
#define SUPPORTER_T5_COLOR "#E91E63"
#define SUPPORTER_T6_TITLE "The Top Supporter"
#define SUPPORTER_T6_COLOR "#9C27B0"

#define DONATOR_T1_TITLE "Donator"
#define DONATOR_T1_COLOR "#9c07ff"
#define DONATOR_T2_TITLE "Enabler"
#define DONATOR_T2_COLOR "#673ab7"
#define DONATOR_T3_TITLE "Sponsor"
#define DONATOR_T3_COLOR "#3f51b5"
#define DONATOR_T4_TITLE "Patron"
#define DONATOR_T4_COLOR "#2196f3"
#define DONATOR_T5_TITLE "Giga Donator"
#define DONATOR_T5_COLOR "#03a9f4"
#define DONATOR_T6_TITLE "The Giga Enabler"
#define DONATOR_T6_COLOR "#00bcd4"



/*
SUPPORTER - MONTHLY PAYMENTS
T1 = $1
T2 = $5
T3 = $10
T4 = $15
T5 = $20

DONATOR - ONE TIME PAYMENTS / TOTAL DONATIONS
T2 IS = TO T5 SUPPORTER
T1 = $10-$19
T2 = $20-$39
T3 = $40-$99
T4 = $100-$199
T5 = $200-$499


*/



donator/proc/getTitle()
    if (getTier() == 1)
        return DONATOR_T1_TITLE
    else if (getTier() == 2)
        return DONATOR_T2_TITLE
    else if (getTier() == 3)
        return DONATOR_T3_TITLE
    else if (getTier() == 4)
        return DONATOR_T4_TITLE
    else if (getTier() == 5)
        return DONATOR_T5_TITLE
    else if (getTier() == 6)
        return DONATOR_T6_TITLE

donator/proc/getColor()
    if (getTier() == 1)
        return DONATOR_T1_COLOR
    else if (getTier() == 2)
        return DONATOR_T2_COLOR
    else if (getTier() == 3)
        return DONATOR_T3_COLOR
    else if (getTier() == 4)
        return DONATOR_T4_COLOR
    else if (getTier() == 5)
        return DONATOR_T5_COLOR
    else if (getTier() == 6)
        return DONATOR_T6_COLOR

donator/proc/getHeader()
    return "<b><font color=[getColor()]>([getTitle()]) </font></b>"

supporter/proc/getHeader()
    return "<b><font color=[getColor()]>([getTitle()]) </font></b>"


supporter/proc/getTitle()
    if (getTier() == 1)
        return SUPPORTER_T1_TITLE
    else if (getTier() == 2)
        return SUPPORTER_T2_TITLE
    else if (getTier() == 3)
        return SUPPORTER_T3_TITLE
    else if (getTier() == 4)
        return SUPPORTER_T4_TITLE
    else if (getTier() == 5)
        return SUPPORTER_T5_TITLE
    else if (getTier() == 6)
        return SUPPORTER_T6_TITLE
supporter/proc/getColor()
    if (getTier() == 1)
        return SUPPORTER_T1_COLOR
    else if (getTier() == 2)
        return SUPPORTER_T2_COLOR
    else if (getTier() == 3)
        return SUPPORTER_T3_COLOR
    else if (getTier() == 4)
        return SUPPORTER_T4_COLOR
    else if (getTier() == 5)
        return SUPPORTER_T5_COLOR
    else if (getTier() == 6)
        return SUPPORTER_T6_COLOR

/mob/proc/getBenefitTitle(donator/donator, supporter/supporter)
    if(donator && supporter)
        if(client.getPref("useDonator"))
            return donator.getHeader()
        else
            return supporter.getHeader()
    if (donator)
        return donator.getHeader()
    else if (supporter)
        return supporter.getHeader()
