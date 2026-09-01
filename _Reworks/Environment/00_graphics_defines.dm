#define GFX_QUALITY_LOW 1
#define GFX_QUALITY_MEDIUM 2
#define GFX_QUALITY_HIGH 3
#define GFX_QUALITY_ULTRA 4

#define SHADOW_PLANE 12
#define REFLECTION_PLANE 10 //11 is reserved by the Beast transformation cutscene
#define FX_RELAY_PLANE 6 //(3 = farblur band, 20 = DemonFusion anim)
#define FX_SELFLIT_LAYER 6.58
#define MATERIAL_LIGHT_PLANE 14 //13 belongs to the cloud-shadow mask
#define WEATHER_PRECIP_PLANE 16 //native weather panels are flattened here before the outdoor mask
#define WEATHER_MASK_PLANE 17 //white outdoor runs used as the precipitation alpha mask
#define WATER_MASK_PLANE 18 //white water runs: the reflection plane is alpha-clipped to these
#define VIGNETTE_PLANE 32 //corner darkening above the whole world composite

//surface occlusion modes (surfaces.dm resolves them; lighting.dm consumes them)
#define OCCLUDE_NONE 0
#define OCCLUDE_PARTIAL 1 //fences, railings: a weak shadow, light still reads through
#define OCCLUDE_DAPPLE 2 //foliage: broken, noisy shadow
#define OCCLUDE_FULL 3
#define SHADOW_INFINITE 0 //walls: project past the light's reach

#define GFX_STRUCTURE_NONE 0
#define GFX_STRUCTURE_EDGE 1
#define GFX_STRUCTURE_DECK 2
#define GFX_STRUCTURE_RAIL 3
#define GFX_STRUCTURE_FOREGROUND 4
