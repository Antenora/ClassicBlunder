mob
	proc
		StyleUnlock(obj/Skills/Buffs/NuStyle/ns)//this proc accepts a style object as a parameter so it doesnt check for all styles ever
			if(!ns.StyleComboUnlock) return
			if(!islist(ns.StyleComboUnlock)) return
			ns.initUnlock()
			var/list/preReq = ns.StyleComboUnlock
			// each entry is either a text path or a path, keep that in mind, with text, if it ends in 'any' we need to find the above type
			for(var/pr in preReq)
				if(!pr || pr == null || pr == "") return
				var/obj/Skills/Buffs/NuStyle/nextPath = preReq[pr]
				if(!nextPath || nextPath == null || nextPath == "") return
				if(!ispath(nextPath))
					nextPath = text2path(nextPath)
				if(locate(nextPath, src))
					continue
				else
					nextPath = new nextPath
				// we have it bro
				var/thePath = pr
				var/obj/Skills/Buffs/NuStyle/found = 0
				if(!ispath(thePath))
					if(findtext(thePath, "/_Any"))
						// this implies it is any sword style
						var/par = replacetext(thePath, "/_Any", "")
						// should b the parent
						// var/obj/Skills/s = FindSkill(text2path(par))
						// world<<"[s]"
						for(var/obj/Skills/Buffs/NuStyle/style in src)
							if(istype(style, text2path(par)) && style.SignatureTechnique >= nextPath.SignatureTechnique-1)
								found = style
								break
					else
						thePath = text2path(thePath)
				
				if(!found)
					if(locate(thePath, src))
						found = thePath
					else
						continue

				if(!SignatureStyles.Find("[nextPath.name]") && found)
					SignatureStyles[nextPath.name] = nextPath.type
					src << "You can now unlock [nextPath.name] by investing a Tier [nextPath.SignatureTechnique] Signature into it!"
				del nextPath
			return

			if(ns.StyleComboUnlock)//does this even exist?)
				if(IsList(ns.StyleComboUnlock))
					for(var/x in ns.StyleComboUnlock)
						if(!x) return //hmm?
						var/advanced_path=ns.StyleComboUnlock[x]
						if(!advanced_path || advanced_path == null)
							return
						var/obj/Skills/aps=new advanced_path
						if(locate(aps, src))
							del aps
							continue
						if(x == null || isnull(x) || x == "")
							continue
						var/obj/Skills/bps=new x
						if(locate(bps, src))
							bps=locate(bps, src)
							if(!src.SignatureStyles.Find("[aps.name]"))
								src.SignatureStyles.Add("[aps.name]")
								src.SignatureStyles["[aps.name]"]="[aps.type]"
								src << "You can now unlock [aps.name] by investing a Tier [aps.SignatureTechnique] Signature into it!"
								del aps
							else
								del aps
								continue
						else
							del bps
							del aps
							continue
				else
					src << "Something is critically wrong with how [ns] is set up to get upgraded styles. Contact Yan."
					return
		PrerequisiteRemove(var/obj/Skills/s)
			if(s.PreRequisite.len > 0)
				for(var/x in s.PreRequisite)
					var/path=text2path(x)
					var/obj/Skills/ns=new path

					for(var/obj/Skills/cs in src.Skills)
						var/SwordSkill=0
						if(cs?:NeedsSword)
							SwordSkill=1
						if(src.Saga=="Weapon Soul"&&SwordSkill)
							continue//do not remove sword skills from weapon soul users
						if(cs.type == ns.type)
							src << "Prerequisite technique [ns] has been removed."
							src.SkillsLocked.Add(ns.type)
							src.DeleteSkill(cs)
							continue
					continue
