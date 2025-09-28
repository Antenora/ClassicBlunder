#define NUM2HEX(a,b) num2text((a), (b), 16)

/mob/Admin4/verb/restartResourceManager()
	resourceManager = new()


resourceManager
	var
		tmp
			list/resourceList
			list/resourceNames
			list/dynResourceNames

			unkID = 0
		list/dynResources

	New(saveName = "data/uploads")
		GenerateResourceList()
		if(saveName && fexists(saveName))
			LoadFromSavefile(saveName)
		else
			dynResources = list()
			dynResourceNames = list()

	Read(savefile/F)
		..()
		dynResources = dynResources || list()
		dynResourceNames = list()
		var/unkStr = "dynrsc/unk/", unkStrLen = length(unkStr)
		unkID = -1
		for(var/rscName in dynResources)
			if(findtext(rscName, unkStr) == 1)
				unkID = max(unkID, text2num(copytext(rscName, unkStrLen + 1)))
			dynResourceNames[dynResources[rscName]] = rscName
		unkID++

	proc
		GenerateResourceList()
			resourceList = list()
			resourceNames = list()
			var/resource, id = "\[0xc000000]", i = 0

			while((resource = locate(id)))
				resourceNames[resource] = "[resource]"
				resourceList["[resource]"] = resource
				id = "\[0xc[NUM2HEX(++i, 6)]]"

		LoadFromSavefile(fileName)
			var/savefile/F = new(fileName)
			F.cd = ".0"
			Read(F)

		SaveToSavefile(fileName = "data/uploads")
			var/savefile/F = new(fileName)
			F << src

		GetResourceByName(name)
			return resourceList[name] || dynResources[name]

		GetResourceName(resource)
			return resourceNames[resource] || dynResourceNames[resource]

		IsDynResource(resource)
			return !resourceNames[resource]

		GenerateDynResource(resource)
			var/resourceName = "[resource]" || "unk/[unkID++]", name = "dynrsc/[resourceName]"
			dynResources[name] = resource
			dynResourceNames[resource] = name
			return name

atom/movable

	Write(savefile/F)
		var/initIcon = initial(icon)

		var/savedIcon = (icon != initIcon) && (resourceManager.GetResourceName(icon) || resourceManager.GenerateDynResource(icon))

		..()

		if(savedIcon) F["savedIcon"] << savedIcon


	Read(savefile/F)
		try
			if(isnull(F)) throw EXCEPTION("[src] is not reading from a file")
		catch(var/e)
			world.log << "Exception: [e]"
			return // this seems self destructive
		if(!F || isnull(F))
			world.log<<"This thing doesn't exist!! [src]"
			return
		..()
		var/val
		F["savedIcon"] >> val
		if(val) icon = resourceManager.GetResourceByName(val)

var/resourceManager/resourceManager = new()