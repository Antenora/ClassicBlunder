// monster materials: a passive worked into gear at the anvil (Smithing rank 5+)
// magnitude comes from the MAT's quality only
// Hunting fills the drop tables later

var/list/LifeMonsterMatDefs = list()

/datum/monster_mat_def
	var/id
	var/name
	var/passive_key       
	var/passive_label
	var/base_mag = 1
	var/per_quality = 1

proc/LifeMatAdd(id, name, passive_key, passive_label, base_mag, per_quality)
	var/datum/monster_mat_def/d = new
	d.id = id
	d.name = name
	d.passive_key = passive_key
	d.passive_label = passive_label
	d.base_mag = base_mag
	d.per_quality = per_quality
	LifeMonsterMatDefs[id] = d

proc/RegisterMonsterMats()
	if(LifeMonsterMatDefs.len) return
	RegisterHuntContent()   // Hunting fills the socketable defs

proc/LifeMonsterMatDef(id)
	RegisterMonsterMats()
	return LifeMonsterMatDefs[id]

// the item type Hunting will drop; MaterialClass = the def id
/obj/Items/Material/MonsterPart
	icon = 'Icons/LifeSkills/MonsterMats.dmi'
	desc = "A trophy from the hunt. A skilled smith can work it into gear, and there may be other uses."
	var/tier = 1

proc/ApplyMonsterMatToGear(obj/Items/I, mmid, matq)
	var/datum/monster_mat_def/d = LifeMonsterMatDef(mmid)
	if(!I || !d) return
	matq = QualityClamp(matq)
	if(!I.passives) I.passives = list()
	I.passives[d.passive_key] = (I.passives[d.passive_key] ? I.passives[d.passive_key] : 0) + d.base_mag + d.per_quality * (matq - 1)
	I.mmat_id = mmid
	I.mmat_quality = matq

proc/LifeConsumeMonsterMat(mob/M, mmid, matq)
	var/datum/monster_mat_def/d = LifeMonsterMatDef(mmid)
	if(!M || !d) return 0
	return LifeConsumeExact(M, mmid, matq, 1)

proc/LifeMonsterMatLine(mmid, matq)
	var/datum/monster_mat_def/d = LifeMonsterMatDef(mmid)
	if(!d) return ""
	matq = QualityClamp(matq)
	return "<font color=[QualityColor(matq)]>[d.name]</font> - <font color=#8be9ff>[d.passive_label] +[d.base_mag + d.per_quality * (matq - 1)]</font>"
