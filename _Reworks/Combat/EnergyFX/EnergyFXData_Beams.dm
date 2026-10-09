var/list/ENERGYFX_FEINT_FLASH = list(0.6, 1, 0.55, 0.3, 0.12, 0.04)
var/list/ENERGYFX_FEINT_LIGHT = list(0.6, 1, 0.6, 0.35, 0.16, 0.05)
var/list/ENERGYFX_FEINT_FLECKS = list(list(24, 3), list(-42, 2), list(63, 2))

var/energyfx_wide_registered = EnergyFXRegisterWide()

proc/EnergyFXRegisterWide()
	BEAMFX_FAM["BloomW"] = list(ENERGYFX_ART_WIDE_BLOOMW, 104, 168)
	ENERGYFX_GRAY_FAM["BloomW"] = list(ENERGYFX_ART_WIDE_BLOOMW, ENERGYFX_ART_WIDEDAMP_BLOOMW)
	BEAMFX_FAM["EndW"] = list(ENERGYFX_ART_WIDE_ENDW, 104, 188)
	ENERGYFX_GRAY_FAM["EndW"] = list(ENERGYFX_ART_WIDE_ENDW, ENERGYFX_ART_WIDEDAMP_ENDW)
	BEAMFX_FAM["HeadW"] = list(ENERGYFX_ART_WIDE_HEADW, 128, 208)
	ENERGYFX_GRAY_FAM["HeadW"] = list(ENERGYFX_ART_WIDE_HEADW, ENERGYFX_ART_WIDEDAMP_HEADW)
	BEAMFX_FAM["ImpactH"] = list(ENERGYFX_ART_WIDE_IMPACTH, 160, 128)
	ENERGYFX_GRAY_FAM["ImpactH"] = list(ENERGYFX_ART_WIDE_IMPACTH, ENERGYFX_ART_WIDEDAMP_IMPACTH)
	BEAMFX_FAM["ImpactQ"] = list(ENERGYFX_ART_WIDE_IMPACTQ, 160, 100)
	ENERGYFX_GRAY_FAM["ImpactQ"] = list(ENERGYFX_ART_WIDE_IMPACTQ, ENERGYFX_ART_WIDEDAMP_IMPACTQ)
	BEAMFX_FAM["StampH"] = list(ENERGYFX_ART_WIDE_STAMPH, 64, 80)
	ENERGYFX_GRAY_FAM["StampH"] = list(ENERGYFX_ART_WIDE_STAMPH, ENERGYFX_ART_WIDEDAMP_STAMPH)
	BEAMFX_FAM["StampQ"] = list(ENERGYFX_ART_WIDE_STAMPQ, 64, 100)
	ENERGYFX_GRAY_FAM["StampQ"] = list(ENERGYFX_ART_WIDE_STAMPQ, ENERGYFX_ART_WIDEDAMP_STAMPQ)
	BEAMFX_FAM["SurgeH"] = list(ENERGYFX_ART_WIDE_SURGEH, 112, 84)
	ENERGYFX_GRAY_FAM["SurgeH"] = list(ENERGYFX_ART_WIDE_SURGEH, ENERGYFX_ART_WIDEDAMP_SURGEH)
	BEAMFX_FAM["SurgeQ"] = list(ENERGYFX_ART_WIDE_SURGEQ, 112, 100)
	ENERGYFX_GRAY_FAM["SurgeQ"] = list(ENERGYFX_ART_WIDE_SURGEQ, ENERGYFX_ART_WIDEDAMP_SURGEQ)
	return 1

var/energyfx_beams_registered = EnergyFXRegisterBeams()

proc/EnergyFXRegisterBeams()
	EnergyFXReg(/obj/Skills/Projectile/Beams/Eraser_Gun, "beam", "Eraser Gun", "#5cff6a", null, null, ENERGYFX_HIT_ERASER_GUN, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Shine_Ray, "beam", "Shine Ray", null, null, null, ENERGYFX_HIT_SHINE_RAY, 1, 15, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Shine_Ray_Prism, "arm", "Shine Ray Prism", null, null, null, ENERGYFX_HIT_SHINE_RAY_PRISM, 1, 6, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Gamma_Ray, "beam", "Gamma Ray", null, null, null, ENERGYFX_HIT_GAMMA_RAY, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Piercer_Ray, "beam", "Piercer Ray", "#ffd23a", null, null, ENERGYFX_HIT_PIERCER_RAY, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Kamehameha, "beam", "Kamehameha", "#3a8dff", null, null, ENERGYFX_HIT_KAMEHAMEHA, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Motionless_Kamehameha, "beam", "Motionless Kamehameha", "#3a8dff", null, null, ENERGYFX_HIT_MOTIONLESS_KAMEHAMEHA, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Galic_Gun, "beam", "Galic Gun", "#a24bff", null, null, ENERGYFX_HIT_GALIC_GUN, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Final_Crash, "beam", "Final Crash", "#a24bff", null, null, ENERGYFX_HIT_FINAL_CRASH, 1, 50, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Dodompa, "beam", "Dodompa", "#ffd23a", null, null, ENERGYFX_HIT_DODOMPA, 1, 10, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Killer_Shine, "beam", "Killer Shine", null, null, null, ENERGYFX_HIT_KILLER_SHINE, 1, 10, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Big/Super_Kamehameha, "beam", "Super Kamehameha", "#3a8dff", null, null, ENERGYFX_HIT_SUPER_KAMEHAMEHA, 2, 60, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Big/Final_Flash, "beam", "Final Flash", "#ffd23a", null, null, ENERGYFX_HIT_FINAL_FLASH, 2, 60, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Big/Super_Dodompa, "beam", "Super Dodompa", "#ffd23a", null, null, ENERGYFX_HIT_SUPER_DODOMPA, 1.5, 15, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Big/True_Kamehameha, "beam", "True Kamehameha", "#3a8dff", null, null, ENERGYFX_HIT_TRUE_KAMEHAMEHA, 2, 60, 0.3)
	EnergyFXReg(/obj/Skills/Projectile/Beams/Big/Final_Shine, "beam", "Final Shine", "#5cff6a", null, null, ENERGYFX_HIT_FINAL_SHINE, 2, 60, 0.3)
	return 1

var/list/ENERGYFX_BEND_TYPES = list()
var/list/ENERGYFX_FORK_TYPES = list()
var/energyfx_bends_registered = EnergyFXRegisterBends()

#if ENERGYFX_BEND_ASSETS && ENERGYFX_FORK_ASSETS
proc/EnergyFXRegisterBends()
	ENERGYFX_BEND_TYPES += "EL135"
	ENERGYFX_BEND_TYPES["EL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL135_M.dmi', null, null, 0, -46, 32, 126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "EL4536"
	ENERGYFX_BEND_TYPES["EL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL4536_F.dmi', -175, 0, 151, 124, 23, -18, 80, 112, 78, -133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "EL4572"
	ENERGYFX_BEND_TYPES["EL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL4572_F.dmi', -190, 0, 156, 134, 21, 0, 106, 148, 76, -128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "EL45M"
	ENERGYFX_BEND_TYPES["EL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL45M_M.dmi', null, null, -113, 0, 146, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "EL9036"
	ENERGYFX_BEND_TYPES["EL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL9036_F.dmi', -196, 0, 0, 196, 18, -18, 112, 112, 95, -95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "EL9072"
	ENERGYFX_BEND_TYPES["EL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_EL9072_F.dmi', -232, 0, 0, 232, 0, 0, 148, 148, 77, -77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "EL90M"
	ENERGYFX_BEND_TYPES["EL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EL90M_M.dmi', null, null, -48, 0, 0, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "ER135"
	ENERGYFX_BEND_TYPES["ER135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER135_M.dmi', null, null, 0, 46, 32, -126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "ER4536"
	ENERGYFX_BEND_TYPES["ER4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER4536_F.dmi', -175, 0, 151, -124, 23, 18, 80, 112, 78, 133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "ER4572"
	ENERGYFX_BEND_TYPES["ER4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER4572_F.dmi', -190, 0, 156, -134, 21, 0, 106, 148, 76, 128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "ER45M"
	ENERGYFX_BEND_TYPES["ER45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER45M_M.dmi', null, null, -113, 0, 146, -80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "ER9036"
	ENERGYFX_BEND_TYPES["ER9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER9036_F.dmi', -196, 0, 0, -196, 18, 18, 112, 112, 95, 95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "ER9072"
	ENERGYFX_BEND_TYPES["ER9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_ER9072_F.dmi', -232, 0, 0, -232, 0, 0, 148, 148, 77, 77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "ER90M"
	ENERGYFX_BEND_TYPES["ER90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_ER90M_M.dmi', null, null, -48, 0, 0, -48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "EU180"
	ENERGYFX_BEND_TYPES["EU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_EU180_M.dmi', null, null, 0, -112, 0, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NEL135"
	ENERGYFX_BEND_TYPES["NEL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL135_M.dmi', null, null, 32, -126, 0, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NEL4536"
	ENERGYFX_BEND_TYPES["NEL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL4536_F.dmi', -124, -151, 0, 175, 18, -23, 112, 80, 133, -77, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NEL4572"
	ENERGYFX_BEND_TYPES["NEL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL4572_F.dmi', -134, -156, 0, 190, 0, -21, 148, 106, 128, -75, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NEL45M"
	ENERGYFX_BEND_TYPES["NEL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL45M_M.dmi', null, null, -80, -145, 0, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NEL9036"
	ENERGYFX_BEND_TYPES["NEL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL9036_F.dmi', -138, -205, -138, 205, 4, 0, 112, 156, 119, 0, 190, 374, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NEL9072"
	ENERGYFX_BEND_TYPES["NEL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NEL9072_F.dmi', -164, -217, -164, 218, -29, 0, 148, 206, 98, 0, 200, 424, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NEL90M"
	ENERGYFX_BEND_TYPES["NEL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEL90M_M.dmi', null, null, -34, -192, -34, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NER135"
	ENERGYFX_BEND_TYPES["NER135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER135_M.dmi', null, null, -126, 32, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NER4536"
	ENERGYFX_BEND_TYPES["NER4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER4536_F.dmi', -151, -124, 175, 0, -23, 18, 80, 112, -77, 133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NER4572"
	ENERGYFX_BEND_TYPES["NER4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER4572_F.dmi', -156, -134, 190, 0, -21, 0, 106, 148, -75, 128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NER45M"
	ENERGYFX_BEND_TYPES["NER45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER45M_M.dmi', null, null, -145, -80, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NER9036"
	ENERGYFX_BEND_TYPES["NER9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER9036_F.dmi', -205, -138, 205, -138, 0, 4, 156, 112, 0, 119, 374, 190, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NER9072"
	ENERGYFX_BEND_TYPES["NER9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NER9072_F.dmi', -217, -164, 218, -164, 0, -29, 206, 148, 0, 98, 424, 200, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NER90M"
	ENERGYFX_BEND_TYPES["NER90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NER90M_M.dmi', null, null, -192, -34, 192, -34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NEU180"
	ENERGYFX_BEND_TYPES["NEU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NEU180_M.dmi', null, null, 79, -79, -79, 79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NL135"
	ENERGYFX_BEND_TYPES["NL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL135_M.dmi', null, null, 46, 0, -126, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NL4536"
	ENERGYFX_BEND_TYPES["NL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL4536_F.dmi', 0, -175, -124, 151, 18, 23, 112, 80, 133, 78, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NL4572"
	ENERGYFX_BEND_TYPES["NL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL4572_F.dmi', 0, -190, -134, 156, 0, 21, 148, 106, 128, 76, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NL45M"
	ENERGYFX_BEND_TYPES["NL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL45M_M.dmi', null, null, 0, -113, -80, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NL9036"
	ENERGYFX_BEND_TYPES["NL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL9036_F.dmi', 0, -196, -196, 0, 18, 18, 112, 112, 95, 95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NL9072"
	ENERGYFX_BEND_TYPES["NL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NL9072_F.dmi', 0, -232, -232, 0, 0, 0, 148, 148, 77, 77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NL90M"
	ENERGYFX_BEND_TYPES["NL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NL90M_M.dmi', null, null, 0, -48, -48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NR135"
	ENERGYFX_BEND_TYPES["NR135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR135_M.dmi', null, null, -46, 0, 126, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NR4536"
	ENERGYFX_BEND_TYPES["NR4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR4536_F.dmi', 0, -175, 124, 151, -18, 23, 112, 80, -133, 78, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NR4572"
	ENERGYFX_BEND_TYPES["NR4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR4572_F.dmi', 0, -190, 134, 156, 0, 21, 148, 106, -128, 76, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NR45M"
	ENERGYFX_BEND_TYPES["NR45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR45M_M.dmi', null, null, 0, -113, 81, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NR9036"
	ENERGYFX_BEND_TYPES["NR9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR9036_F.dmi', 0, -196, 196, 0, -18, 18, 112, 112, -95, 95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NR9072"
	ENERGYFX_BEND_TYPES["NR9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NR9072_F.dmi', 0, -232, 232, 0, 0, 0, 148, 148, -77, 77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NR90M"
	ENERGYFX_BEND_TYPES["NR90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NR90M_M.dmi', null, null, 0, -48, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NU180"
	ENERGYFX_BEND_TYPES["NU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NU180_M.dmi', null, null, 112, 0, -112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWL135"
	ENERGYFX_BEND_TYPES["NWL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL135_M.dmi', null, null, 126, 32, -46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWL4536"
	ENERGYFX_BEND_TYPES["NWL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL4536_F.dmi', 151, -124, -175, 0, 23, 18, 80, 112, 78, 133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NWL4572"
	ENERGYFX_BEND_TYPES["NWL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL4572_F.dmi', 156, -134, -190, 0, 21, 0, 106, 148, 76, 128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NWL45M"
	ENERGYFX_BEND_TYPES["NWL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL45M_M.dmi', null, null, 146, -80, -113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWL9036"
	ENERGYFX_BEND_TYPES["NWL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL9036_F.dmi', 205, -138, -205, -138, 0, 4, 156, 112, 0, 119, 374, 190, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NWL9072"
	ENERGYFX_BEND_TYPES["NWL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWL9072_F.dmi', 218, -164, -217, -164, 0, -29, 206, 148, 0, 98, 424, 200, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NWL90M"
	ENERGYFX_BEND_TYPES["NWL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWL90M_M.dmi', null, null, 192, -34, -192, -34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWR135"
	ENERGYFX_BEND_TYPES["NWR135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR135_M.dmi', null, null, -32, -126, 0, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWR4536"
	ENERGYFX_BEND_TYPES["NWR4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR4536_F.dmi', 124, -151, 0, 175, -18, -23, 112, 80, -133, -77, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "NWR4572"
	ENERGYFX_BEND_TYPES["NWR4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR4572_F.dmi', 134, -156, 0, 190, 0, -21, 148, 106, -128, -75, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "NWR45M"
	ENERGYFX_BEND_TYPES["NWR45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR45M_M.dmi', null, null, 81, -145, 0, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWR9036"
	ENERGYFX_BEND_TYPES["NWR9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR9036_F.dmi', 139, -205, 139, 205, -3, 0, 112, 156, -118, 0, 190, 374, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "NWR9072"
	ENERGYFX_BEND_TYPES["NWR9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_NWR9072_F.dmi', 164, -217, 164, 218, 30, 0, 148, 206, -98, 0, 200, 424, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "NWR90M"
	ENERGYFX_BEND_TYPES["NWR90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWR90M_M.dmi', null, null, 34, -192, 34, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "NWU180"
	ENERGYFX_BEND_TYPES["NWU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_NWU180_M.dmi', null, null, 79, 79, -79, -79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SEL135"
	ENERGYFX_BEND_TYPES["SEL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL135_M.dmi', null, null, -126, -32, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SEL4536"
	ENERGYFX_BEND_TYPES["SEL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL4536_F.dmi', -151, 124, 175, 0, -23, -18, 80, 112, -77, -133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SEL4572"
	ENERGYFX_BEND_TYPES["SEL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL4572_F.dmi', -156, 134, 190, 0, -21, 0, 106, 148, -75, -128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SEL45M"
	ENERGYFX_BEND_TYPES["SEL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL45M_M.dmi', null, null, -145, 81, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SEL9036"
	ENERGYFX_BEND_TYPES["SEL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL9036_F.dmi', -205, 139, 205, 139, 0, -3, 156, 112, 0, -118, 374, 190, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SEL9072"
	ENERGYFX_BEND_TYPES["SEL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SEL9072_F.dmi', -217, 164, 218, 164, 0, 30, 206, 148, 0, -98, 424, 200, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SEL90M"
	ENERGYFX_BEND_TYPES["SEL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEL90M_M.dmi', null, null, -192, 34, 192, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SER135"
	ENERGYFX_BEND_TYPES["SER135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER135_M.dmi', null, null, 32, 126, 0, -46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SER4536"
	ENERGYFX_BEND_TYPES["SER4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER4536_F.dmi', -124, 151, 0, -175, 18, 23, 112, 80, 133, 78, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SER4572"
	ENERGYFX_BEND_TYPES["SER4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER4572_F.dmi', -134, 156, 0, -190, 0, 21, 148, 106, 128, 76, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SER45M"
	ENERGYFX_BEND_TYPES["SER45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER45M_M.dmi', null, null, -80, 146, 0, -113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SER9036"
	ENERGYFX_BEND_TYPES["SER9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER9036_F.dmi', -138, 205, -138, -205, 4, 0, 112, 156, 119, 0, 190, 374, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SER9072"
	ENERGYFX_BEND_TYPES["SER9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SER9072_F.dmi', -164, 218, -164, -217, -29, 0, 148, 206, 98, 0, 200, 424, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SER90M"
	ENERGYFX_BEND_TYPES["SER90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SER90M_M.dmi', null, null, -34, 192, -34, -192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SEU180"
	ENERGYFX_BEND_TYPES["SEU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SEU180_M.dmi', null, null, -79, -79, 79, 79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SL135"
	ENERGYFX_BEND_TYPES["SL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL135_M.dmi', null, null, -46, 0, 126, -32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SL4536"
	ENERGYFX_BEND_TYPES["SL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL4536_F.dmi', 0, 175, 124, -151, -18, -23, 112, 80, -133, -77, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SL4572"
	ENERGYFX_BEND_TYPES["SL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL4572_F.dmi', 0, 190, 134, -156, 0, -21, 148, 106, -128, -75, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SL45M"
	ENERGYFX_BEND_TYPES["SL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL45M_M.dmi', null, null, 0, 114, 81, -145, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SL9036"
	ENERGYFX_BEND_TYPES["SL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL9036_F.dmi', 0, 196, 196, 0, -18, -18, 112, 112, -95, -95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SL9072"
	ENERGYFX_BEND_TYPES["SL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SL9072_F.dmi', 0, 232, 232, 0, 0, 0, 148, 148, -77, -77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SL90M"
	ENERGYFX_BEND_TYPES["SL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SL90M_M.dmi', null, null, 0, 48, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SR135"
	ENERGYFX_BEND_TYPES["SR135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR135_M.dmi', null, null, 46, 0, -126, -32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SR4536"
	ENERGYFX_BEND_TYPES["SR4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR4536_F.dmi', 0, 175, -124, -151, 18, -23, 112, 80, 133, -77, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SR4572"
	ENERGYFX_BEND_TYPES["SR4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR4572_F.dmi', 0, 190, -134, -156, 0, -21, 148, 106, 128, -75, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SR45M"
	ENERGYFX_BEND_TYPES["SR45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR45M_M.dmi', null, null, 0, 114, -80, -145, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SR9036"
	ENERGYFX_BEND_TYPES["SR9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR9036_F.dmi', 0, 196, -196, 0, 18, -18, 112, 112, 95, -95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SR9072"
	ENERGYFX_BEND_TYPES["SR9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SR9072_F.dmi', 0, 232, -232, 0, 0, 0, 148, 148, 77, -77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SR90M"
	ENERGYFX_BEND_TYPES["SR90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SR90M_M.dmi', null, null, 0, 48, -48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SU180"
	ENERGYFX_BEND_TYPES["SU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SU180_M.dmi', null, null, -112, 0, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWL135"
	ENERGYFX_BEND_TYPES["SWL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL135_M.dmi', null, null, -32, 126, 0, -46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWL4536"
	ENERGYFX_BEND_TYPES["SWL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL4536_F.dmi', 124, 151, 0, -175, -18, 23, 112, 80, -133, 78, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SWL4572"
	ENERGYFX_BEND_TYPES["SWL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL4572_F.dmi', 134, 156, 0, -190, 0, 21, 148, 106, -128, 76, 200, 216, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SWL45M"
	ENERGYFX_BEND_TYPES["SWL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL45M_M.dmi', null, null, 81, 146, 0, -113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWL9036"
	ENERGYFX_BEND_TYPES["SWL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL9036_F.dmi', 139, 205, 139, -205, -3, 0, 112, 156, -118, 0, 190, 374, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SWL9072"
	ENERGYFX_BEND_TYPES["SWL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWL9072_F.dmi', 164, 218, 164, -217, 30, 0, 148, 206, -98, 0, 200, 424, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SWL90M"
	ENERGYFX_BEND_TYPES["SWL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWL90M_M.dmi', null, null, 34, 192, 34, -192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWR135"
	ENERGYFX_BEND_TYPES["SWR135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR135_M.dmi', null, null, 126, -32, -46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWR4536"
	ENERGYFX_BEND_TYPES["SWR4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR4536_F.dmi', 151, 124, -175, 0, 23, -18, 80, 112, 78, -133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "SWR4572"
	ENERGYFX_BEND_TYPES["SWR4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR4572_F.dmi', 156, 134, -190, 0, 21, 0, 106, 148, 76, -128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "SWR45M"
	ENERGYFX_BEND_TYPES["SWR45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR45M_M.dmi', null, null, 146, 81, -113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWR9036"
	ENERGYFX_BEND_TYPES["SWR9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR9036_F.dmi', 205, 139, -205, 139, 0, -3, 156, 112, 0, -118, 374, 190, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "SWR9072"
	ENERGYFX_BEND_TYPES["SWR9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_SWR9072_F.dmi', 218, 164, -217, 164, 0, 30, 206, 148, 0, -98, 424, 200, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "SWR90M"
	ENERGYFX_BEND_TYPES["SWR90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWR90M_M.dmi', null, null, 192, 34, -192, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "SWU180"
	ENERGYFX_BEND_TYPES["SWU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_SWU180_M.dmi', null, null, -79, 79, 79, -79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WL135"
	ENERGYFX_BEND_TYPES["WL135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL135_M.dmi', null, null, 0, 46, -32, -126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WL4536"
	ENERGYFX_BEND_TYPES["WL4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL4536_F.dmi', 175, 0, -151, -124, -23, 18, 80, 112, -77, 133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "WL4572"
	ENERGYFX_BEND_TYPES["WL4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL4572_F.dmi', 190, 0, -156, -134, -21, 0, 106, 148, -75, 128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "WL45M"
	ENERGYFX_BEND_TYPES["WL45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL45M_M.dmi', null, null, 114, 0, -145, -80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WL9036"
	ENERGYFX_BEND_TYPES["WL9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL9036_F.dmi', 196, 0, 0, -196, -18, 18, 112, 112, -95, 95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "WL9072"
	ENERGYFX_BEND_TYPES["WL9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WL9072_F.dmi', 232, 0, 0, -232, 0, 0, 148, 148, -77, 77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "WL90M"
	ENERGYFX_BEND_TYPES["WL90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WL90M_M.dmi', null, null, 48, 0, 0, -48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WR135"
	ENERGYFX_BEND_TYPES["WR135"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR135_M.dmi', null, null, 0, -46, -32, 126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WR4536"
	ENERGYFX_BEND_TYPES["WR4536"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR4536_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR4536_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR4536_F.dmi', 175, 0, -151, 124, -23, -18, 80, 112, -77, -133, 190, 190, 30, 29, 90, 89)
	ENERGYFX_BEND_TYPES += "WR4572"
	ENERGYFX_BEND_TYPES["WR4572"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR4572_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR4572_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR4572_F.dmi', 190, 0, -156, 134, -21, 0, 106, 148, -75, -128, 216, 200, 32, 30, 92, 89)
	ENERGYFX_BEND_TYPES += "WR45M"
	ENERGYFX_BEND_TYPES["WR45M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR45M_M.dmi', null, null, 114, 0, -145, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WR9036"
	ENERGYFX_BEND_TYPES["WR9036"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR9036_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR9036_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR9036_F.dmi', 196, 0, 0, 196, -18, -18, 112, 112, -95, -95, 266, 266, 58, 58, 175, 175)
	ENERGYFX_BEND_TYPES += "WR9072"
	ENERGYFX_BEND_TYPES["WR9072"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR9072_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR9072_N.dmi', 'Icons/Private/EnergyFX/Beam/EFXBend_WR9072_F.dmi', 232, 0, 0, 232, 0, 0, 148, 148, -77, -77, 302, 302, 62, 62, 177, 177)
	ENERGYFX_BEND_TYPES += "WR90M"
	ENERGYFX_BEND_TYPES["WR90M"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WR90M_M.dmi', null, null, 48, 0, 0, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_BEND_TYPES += "WU180"
	ENERGYFX_BEND_TYPES["WU180"] = list('Icons/Private/EnergyFX/Beam/EFXBend_WU180_M.dmi', null, null, 0, 112, 0, -112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	ENERGYFX_FORK_TYPES += "E"
	ENERGYFX_FORK_TYPES["E"] = list('Icons/Private/EnergyFX/Beam/EFXFork_E_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_E_J.dmi', -207, 0, 128, 158, 128, -158, -49, 0, 196, 320, 34, 33)
	ENERGYFX_FORK_TYPES += "N"
	ENERGYFX_FORK_TYPES["N"] = list('Icons/Private/EnergyFX/Beam/EFXFork_N_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_N_J.dmi', 0, -207, -163, 128, 153, 128, 0, -49, 320, 196, 34, 33)
	ENERGYFX_FORK_TYPES += "NE"
	ENERGYFX_FORK_TYPES["NE"] = list('Icons/Private/EnergyFX/Beam/EFXFork_NE_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_NE_J.dmi', -174, -174, -5, 161, 161, -5, -6, -6, 308, 308, 34, 33)
	ENERGYFX_FORK_TYPES += "NW"
	ENERGYFX_FORK_TYPES["NW"] = list('Icons/Private/EnergyFX/Beam/EFXFork_NW_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_NW_J.dmi', 175, -174, -161, -5, 5, 161, 7, -6, 308, 308, 34, 33)
	ENERGYFX_FORK_TYPES += "S"
	ENERGYFX_FORK_TYPES["S"] = list('Icons/Private/EnergyFX/Beam/EFXFork_S_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_S_J.dmi', 0, 207, 162, -127, -154, -127, 0, 50, 320, 196, 34, 33)
	ENERGYFX_FORK_TYPES += "SE"
	ENERGYFX_FORK_TYPES["SE"] = list('Icons/Private/EnergyFX/Beam/EFXFork_SE_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_SE_J.dmi', -174, 175, 161, 5, -5, -161, -6, 7, 308, 308, 34, 33)
	ENERGYFX_FORK_TYPES += "SW"
	ENERGYFX_FORK_TYPES["SW"] = list('Icons/Private/EnergyFX/Beam/EFXFork_SW_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_SW_J.dmi', 175, 175, 5, -161, -161, 5, 7, 7, 308, 308, 34, 33)
	ENERGYFX_FORK_TYPES += "W"
	ENERGYFX_FORK_TYPES["W"] = list('Icons/Private/EnergyFX/Beam/EFXFork_W_M.dmi', 'Icons/Private/EnergyFX/Beam/EFXFork_W_J.dmi', 207, 0, -127, -157, -127, 159, 50, 0, 196, 320, 34, 33)
	return 1
#else
proc/EnergyFXRegisterBends()
	return 0
#endif

/world/New()
	EnergyFXRegisterBeamMasks()
	. = ..()

proc/EnergyFXRegisterBeamMasks()
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitdodompa.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitdodompa.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitdodompa.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhiterasergun.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhiterasergun.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhiterasergun.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalcrash.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalcrash.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalcrash.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalflash.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalflash.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalflash.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitfinalshine.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgalicgun.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgalicgun.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgalicgun.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgammaray.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgammaray.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitgammaray.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkamehameha.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkamehameha.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkamehameha.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkillershine.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkillershine.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitkillershine.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitmotionlesskamehameha.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitmotionlesskamehameha.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitmotionlesskamehameha.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitpiercerray.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitpiercerray.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitpiercerray.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitshineray.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitshinerayprism.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitshinerayprism.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitshinerayprism.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitsuperdodompa.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitsuperkamehameha.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitsuperkamehameha.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhitsuperkamehameha.dmi:S"] = list(6,0,26,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhittruekamehameha.dmi"] = list(0,0,32,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhittruekamehameha.dmi:N"] = list(0,0,24,32)
	BAKED_HITBOXES["icons/private/energyfx/hit/energyfxhittruekamehameha.dmi:S"] = list(6,0,26,32)
	BAKED_MASKS["icons/private/energyfx/hit/energyfxhitshineray.dmi:N"] = list(8,8,1,63,63,63,63,63,255,255,255)
	BAKED_MASKS["icons/private/energyfx/hit/energyfxhitshineray.dmi:S"] = list(8,8,1,255,255,255,255,252,252,252,252)
	return 44
