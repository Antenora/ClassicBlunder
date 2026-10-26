#if fexists("../../../Icons/Private/BeamFX/BeamFXStamp.dmi") || fexists("Icons/Private/BeamFX/BeamFXStamp.dmi")
#define BEAMFX_ASSETS 1
#define BEAMFX_STAMP_ICON 'Icons/Private/BeamFX/BeamFXStamp.dmi'
#else
#define BEAMFX_ASSETS 0
#define BEAMFX_STAMP_ICON 'Icons/Effects/Arcane Heal.dmi'
#endif

#if fexists("../../../Icons/Private/BeamFX/BeamFXSpeck.dmi") || fexists("Icons/Private/BeamFX/BeamFXSpeck.dmi")
#define BEAMFX_SPECK_ICON 'Icons/Private/BeamFX/BeamFXSpeck.dmi'
#else
#define BEAMFX_SPECK_ICON 'Icons/Effects/Arcane Heal.dmi'
#endif

#define BEAMFX_RIM_LAYER 6.64
#define BEAMFX_TICK 0.05
#define BEAMFX_FR 0.025
#define BEAMFX_CONTACT 22
#define BEAMFX_SWALLOW 26
#define BEAMFX_SWALLOW_V 300

#if fexists("../../../Icons/Private/BeamFX/BeamFXMask.dmi") || fexists("Icons/Private/BeamFX/BeamFXMask.dmi")
#define BEAMFX_MASK_ICON 'Icons/Private/BeamFX/BeamFXMask.dmi'
#else
#define BEAMFX_MASK_ICON 'Icons/Effects/Arcane Heal.dmi'
#endif
