#define BALANCED_RATE 0.25
#define FULL_RATE 0.5
#define LOW_RATE 0.15

#define MAJIN_BLOB_DROP_THRESHOLD 15 // Base health threshold (% HP) below which blobs start dropping. Raised by ascension via getDropThreshold; capped at 75.
#define MAJIN_BLOB_DROP_RATE 0.15 // Chance per tick to drop a blob while under threshold (raised by ascension).
#define MAX_BLOBS 2 // Starting cap on simultaneous active blobs (raised by ascension).

// fraction of Power that gets baked into blob heal/reduction values.
#define INNOCENT_BLOB_HEAL_FRAC 0.000005
#define INNOCENT_BLOB_BUFF_FRAC 0.0000005

// Absorb mechanic
#define MAJIN_BASE_ABSORB_LIMIT 2
#define MAJIN_BASE_SKILLS_PER_VICTIM 2
#define MAJIN_SUPER_ABSORB_BONUS 2 // Extra absorb slots for the Super class.
#define MAJIN_SUPER_SKILL_BONUS 2 // Extra skill-per-victim slots for the Super class.
#define MAJIN_SUPER_DIGESTED_SKILL_DMG_MULT 1.5

// Digestion: 4 rolls at 24h intervals, each at 25/50/75/100% respectively.
#define MAJIN_DIGEST_INTERVAL_HOURS 24
#define MAJIN_DIGEST_TOTAL_ROLLS 4
#define MAJIN_DIGEST_PERCENT_PER_ROLL 25
// Polling cadence
#define MAJIN_DIGEST_CHECK_CADENCE (5 MINUTES)

// NOTE: MAJIN_ABSORB_Z and MAJIN_UNHINGED_POWER_MULT live in
// _1CodeFolder/__Defines.dm because core files (Stats.dm,
// _BinaryChecks.dm, BattleSystem.dm) reference them and must see the
// define before the Majin race is included.

#define MAJIN_ROOM_COUNT 5

blobDropper
    var/list/blobList = list()
    var/numBlobs = 0
    var/numBlobsMax = MAX_BLOBS
    var/blobDropRate = MAJIN_BLOB_DROP_RATE
    var/dropThreshold = MAJIN_BLOB_DROP_THRESHOLD

    New(mob/Players/p)
        if(!p.isRace(MAJIN))
            del(src)
            p<<"You are not a Majin!"
            return
        var/ascen = p.AscensionsAcquired
        blobList = list()
        numBlobs = 0
        numBlobsMax = MAX_BLOBS + getMaxBlobs(ascen)
        blobDropRate = MAJIN_BLOB_DROP_RATE + getDropRate(ascen)
        dropThreshold = clamp(MAJIN_BLOB_DROP_THRESHOLD + getDropThreshold(ascen), MAJIN_BLOB_DROP_THRESHOLD, 75)

majinAbsorb/New(mob/Players/p)
    if(p)
        if(!p.isRace(MAJIN))
            del(src)
            p<<"You are not a Majin!"
            return
        updateVariables(p)
        StartDigestionLoop(p)

/mob/var/tmp/blobDropper/majinPassive = null
/mob/var/majinAbsorb/majinAbsorb = null

/mob/var/PeakPowerObserved = 0

/mob/var/absorbedBy = null
/mob/var/majinRoomIndex = 0 // which room (1..MAJIN_ROOM_COUNT) they were placed into.
/mob/var/absorbedAtTimestamp = 0
/mob/var/tmp/majinNextDigestCheck = 0
/mob/var/tmp/majinCheatFXRunning = 0
/mob/var/tmp/majinCheatDeathInProgress = 0

// Once-per-ascension cheat death
/mob/var/majinCheatDeathUsed = 0
