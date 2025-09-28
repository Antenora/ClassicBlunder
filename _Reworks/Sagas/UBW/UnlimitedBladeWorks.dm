mob/var/usingUBW = FALSE

/mob/Admin3/verb/GiveDomainExpansion()
	CreateSwapMap()
	var/obj/Skills/Buffs/SlotlessBuffs/Domain_Expansion/d = new()
	d.range = input(src, "What is the range of the domain activation when used wide?") as num
	d.identifier = input(src, "What is the identifier, exact?") as text
	var/mob/p = input(src, "Who to give to?") in players
	src?:Edit(d)
	p.AddSkill(d)



mob
	proc
		DomainExpansion(identifier, range, target)
			if(!fexists("Maps/map_[identifier]_Domain.sav"))
				AdminMessage("[src] has no domain map. please use createswap map and name it map_identifier_Domain")
				// SwapMaps_SaveChunk("Maps/[identifier]_Domain.sav", locate(_x,_y,_z), locate(endX, endY,_z))
				// SwapMaps_Save("Maps/[identifier]_Domain.sav")
				src <<" No Domain Map, Admins Alerted . . . "
				return
			var/list/targets = list()
			if(target && Target)
				targets += Target
				targets += src
			else if(range)
				for(var/mob/m in range(range))
					if(m.client)
						targets |= m
			var/swapmap/newMap = SwapMaps_CreateFromTemplate("[identifier]_Domain")
			var/turf/center = newMap.CenterTile()
			for(var/mob/teleportThese in targets)
				teleportThese.PrevX=teleportThese.x
				teleportThese.PrevY=teleportThese.y
				teleportThese.PrevZ=teleportThese.z
				teleportThese.in_tmp_map = newMap.id
				teleportThese.loc = locate(center.x+rand(-10,10), center.y+rand(-10,10), center.z)


		stopDomainExapansion()
			var/swapmap/map = swapmaps_byname[in_tmp_map]
			for(var/turf/t in block(map.x1, map.y1, map.z1, map.x2, map.y2))
				for(var/mob/m in t)
					m.x = m.PrevX
					m.y = m.PrevY
					m.z = m.PrevZ
					m.PrevX = null
					m.PrevY = null
					m.PrevZ = null
					m.in_tmp_map = null
			map.Del()


		UnlimitedBladeWorks()
			if(usingUBW) return
			var/list/targets = list()
			for(var/mob/m in range(15))
				targets |= m
			if(!fexists("Maps/map_[src:UniqueID]_UBW.sav"))
				SwapMaps_SaveChunk("[src:UniqueID]_UBW", locate(1,71,1), locate(61, 121,1))
				SwapMaps_Save("[src:UniqueID]_UBW")

			var/swapmap/newMap = SwapMaps_CreateFromTemplate("[src:UniqueID]_UBW")
			var/turf/center = newMap.CenterTile()
			usingUBW = TRUE
			for(var/mob/teleportThese in targets)
				teleportThese.PrevX=teleportThese.x
				teleportThese.PrevY=teleportThese.y
				teleportThese.PrevZ=teleportThese.z
				teleportThese.in_tmp_map = newMap.id
				teleportThese.loc = locate(center.x+rand(-10,10), center.y+rand(-10,10), center.z)

		stopUnlimitedBladeWorks()
			if(!usingUBW) return
			var/swapmap/map = swapmaps_byname[in_tmp_map]
			usingUBW = FALSE
			for(var/turf/t in block(map.x1, map.y1, map.z1, map.x2, map.y2))
				for(var/mob/m in t)
					m.x = m.PrevX
					m.y = m.PrevY
					m.z = m.PrevZ
					m.PrevX = null
					m.PrevY = null
					m.PrevZ = null
					m.in_tmp_map = null
			map.Del()