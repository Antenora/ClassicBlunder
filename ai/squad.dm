
//We need to setup so that admins can impend new entries and save them.
var/list/squad_database

// Helper — builds a flat property list step-by-step. Used to avoid BYOND 516 quirks
// with complex inline list literals containing many mixed keys in a single expression.
proc/_squad_props(icon_path, name_text, potential, str_mod, end_mod, for_mod, off_mod, def_mod, spd_mod, spammer)
	var/list/p = list()
	p["icon"] = icon_path
	p["name"] = name_text
	p["Potential"] = potential
	p["StrMod"] = str_mod
	p["EndMod"] = end_mod
	p["ForMod"] = for_mod
	p["OffMod"] = off_mod
	p["DefMod"] = def_mod
	p["SpdMod"] = spd_mod
	p["ai_spammer"] = spammer
	return p

proc/BuildSquadDatabase()
	squad_database = list()

	var/list/basic_bot_techs = list()
	basic_bot_techs += "/obj/Skills/AutoHit/Focus_Punch"
	basic_bot_techs += "/obj/Skills/AutoHit/Sweeping_Kick"
	basic_bot_techs += "/obj/Skills/Projectile/Gear/Plasma_Blaster"
	squad_database["basic bot"] = new/ai_sheet("basic bot", _squad_props('Icons/Characters/Androids/Android1.dmi', "Basic Bot", 0.3, 2, 2, 2, 2, 2, 2, 0.5), basic_bot_techs)

	var/list/battle_bot_techs = list()
	battle_bot_techs += "/obj/Skills/AutoHit/Flying_Kick"
	battle_bot_techs += "/obj/Skills/Projectile/Dragon_Nova"
	squad_database["battle bot"] = new/ai_sheet("battle bot", _squad_props('Icons/Characters/Androids/Android2.dmi', "Battle Bot", 0.5, 3, 2, 2, 2, 2, 2, 1), battle_bot_techs)

	var/list/bullet_bot_techs = list()
	bullet_bot_techs += "/obj/Skills/Projectile/Gear/Plasma_Gatling"
	bullet_bot_techs += "/obj/Skills/Projectile/Gear/Plasma_Blaster"
	squad_database["bullet bot"] = new/ai_sheet("bullet bot", _squad_props('Icons/Characters/Androids/Android4.dmi', "Bullet Bot", 0.5, 2, 3, 2, 2, 2, 2, 1), bullet_bot_techs)

	var/list/guardian_bot_techs = list()
	guardian_bot_techs += "/obj/Skills/AutoHit/Flying_Kick"
	guardian_bot_techs += "/obj/Skills/AutoHit/Force_Palm"
	guardian_bot_techs += "/obj/Skills/Projectile/Dragon_Nova"
	guardian_bot_techs += "/obj/Skills/Projectile/Gear/Plasma_Blaster"
	squad_database["guardian bot"] = new/ai_sheet("guardian bot", _squad_props('Icons/Characters/Androids/Android11.dmi', "Guardian Bot", 0.6, 3, 3, 3, 3, 3, 3, 1), guardian_bot_techs)

	var/list/gajalaka_techs = list()
	gajalaka_techs += "/obj/Skills/AutoHit/Focus_Punch"
	gajalaka_techs += "/obj/Skills/AutoHit/Sweeping_Kick"
	gajalaka_techs += "/obj/Skills/Projectile/Gear/Plasma_Blaster"
	squad_database["gajalaka"] = new/ai_sheet("gajalaka", _squad_props('Icons/NPCS/New Monsters/GajalakaWild.dmi', "Gajalaka", 0.3, 2, 2, 2, 2, 2, 2, 0.5), gajalaka_techs)

	var/list/gaja_warrior_techs = list()
	gaja_warrior_techs += "/obj/Skills/AutoHit/Flying_Kick"
	gaja_warrior_techs += "/obj/Skills/Projectile/Force_Palm"
	squad_database["gajalaka warrior"] = new/ai_sheet("gajalaka warrior", _squad_props('Icons/NPCS/New Monsters/GajalakaWild.dmi', "Gajalaka Warrior", 0.5, 3, 2, 2, 2, 2, 2, 1), gaja_warrior_techs)

	var/list/gaja_thrower_techs = list()
	gaja_thrower_techs += "/obj/Skills/Projectile/Gear/Plasma_Gatling"
	gaja_thrower_techs += "/obj/Skills/Projectile/Blast"
	squad_database["gajalaka thrower"] = new/ai_sheet("gajalaka thrower", _squad_props('Icons/NPCS/New Monsters/GajalakaWild.dmi', "Gajalaka Thrower", 0.5, 2, 3, 2, 2, 2, 2, 1), gaja_thrower_techs)

	var/list/gaja_champ_techs = list()
	gaja_champ_techs += "/obj/Skills/AutoHit/Flying_Kick"
	gaja_champ_techs += "/obj/Skills/AutoHit/Force_Palm"
	gaja_champ_techs += "/obj/Skills/Projectile/Dragon_Nova"
	gaja_champ_techs += "/obj/Skills/Projectile/Blast"
	squad_database["gajalaka champion"] = new/ai_sheet("gajalaka champion", _squad_props('Icons/NPCS/New Monsters/GajalakaWild.dmi', "Gajalaka Champion", 0.6, 3, 3, 3, 3, 3, 3, 1), gaja_champ_techs)

	var/list/gaja_berserk_techs = list()
	gaja_berserk_techs += "/obj/Skills/AutoHit/Flying_Kick"
	gaja_berserk_techs += "/obj/Skills/AutoHit/Force_Palm"
	gaja_berserk_techs += "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Turns_Red"
	squad_database["gajalaka berserker"] = new/ai_sheet("gajalaka berserker", _squad_props('Icons/NPCS/New Monsters/GajalakaWild.dmi', "Gajalaka Berserker", 0.4, 3, 3, 3, 3, 3, 3, 1), gaja_berserk_techs)

	// Oliphant spirit has extra custom fields beyond the helper — build inline step by step.
	var/list/oliphant_props = list()
	oliphant_props["icon"] = 'Sagas/Weapon Soul/Durendal/knight.dmi'
	oliphant_props["name"] = "Oliphant Spirit"
	oliphant_props["Potential"] = 0.4
	oliphant_props["StrMod"] = 3
	oliphant_props["EndMod"] = 0.2
	oliphant_props["ForMod"] = 3
	oliphant_props["OffMod"] = 3
	oliphant_props["DefMod"] = 1
	oliphant_props["SpdMod"] = 2
	oliphant_props["Health"] = 20
	oliphant_props["ai_spammer"] = 1
	oliphant_props["ai_movement_type"] = "ranged"
	var/list/oliphant_techs = list()
	oliphant_techs += "/obj/Skills/Projectile/Dragon_Nova"
	oliphant_techs += "/obj/Skills/Projectile/Kienzan"
	oliphant_techs += "/obj/Skills/Projectile/Tracking_Bomb"
	squad_database["oliphant spirit"] = new/ai_sheet("oliphant spirit", oliphant_props, oliphant_techs)


mob/Player/AI
	var/tmp/obj/Skills/Companion/PlayerCompanion/Squad/in_squad

obj/Skills/Companion
	PlayerCompanion
		cooldown=10

		Squad

			var
				list/squad = list() //Squad track AI ids. Initial summon associates a name to them, which players may modify.
				max_squad = 5
				list/team = list()
				formation
			proc
				AddNewMember(id)

					var/ai_sheet/a = squad_database[id]
					if(a)
						/* Full sheet allows data about individual squad members to be tracked and modified.
						var/ai_sheet/new_sheet = new //Squad members are modifiable like this. Important for players basically.
						for(var/v in a.vars)
							new_sheet.vars[v] = a.vars[v]
						new_sheet.properties[name] = "[new_sheet.properties[name]] [rand(1,9999)]"
						*/
						var newname
						if(a.properties[name]) newname = a.properties[name]
						else newname = id
						var/index = 1
						while(("[newname] [index]" in squad))
							index++
						squad += "[newname] [index]"
						squad["[newname] [index]"] = id //Soon this should just be ai_sheet datum.
				RemoveMember(id)
					squad -= id
			verb
				PlayerEditSquad()
					var/c = input("Which?") as null|anything in squad
					if(c)
						if(istext(squad[c])) //just a id
							switch(input("Would you like to change [c]'s name?") in list("Yes","No"))
								if("Yes")
									var new_name
									while(!new_name)
										new_name = input("Name") as text
									c = new_name
						else
							return



			Companion_Summon()
				set src in usr
				set category = "Companion"
				if(Using)
					return
				Using=1
				var has_f_out
				for(var/mob/Player/AI/a in active_ai)
					animate(a, alpha=0, time=10)
					usr.ai_followers-=a
					active_ai-=a
					spawn(10)
						del(a)
					has_f_out=1
				if(has_f_out)
					Using=0
					return

				if((world.realtime < last_use + cooldown))
					usr << "You cannot summon any companions right now, it is still on cooldown. ([(world.realtime - last_use)/10] seconds)"
					return
				var/limit = 0
				for(var/index in squad)
					limit++
					if(limit > max_squad) break

					var/mob/Player/AI/a = new
					ticking_ai.Remove(a)
					companion_ais += a
					a.alpha=0
					a.loc = locate(usr.x,usr.y,usr.z)
					animate(a, alpha=255, time=10)
					a.ai_owner = usr
					a.ai_follow= formation ? formation : 1
					a.ai_hostility=0

					a.AI_Database_Sync(index, squad_database)
					a.ai_focus_owner_target = companion_focus_target

					a.ko_death = companion_ko_death
					a.Timeless = 1

					a.ai_team_fire=companion_team_fire
					a.ai_focus_owner_target = companion_focus_target
					a.Potential = usr.Potential * a.Potential
					usr.ai_followers +=a
					a.ai_alliances = list()
					a.ai_alliances += "[usr.ckey]"
					a.in_squad = src
					for(var/alliance in team) a.ai_alliances += alliance
					active_ai+=a
					a.AIGain()
					a.ai_state = "Idle"
				last_use = world.time
				Using=0