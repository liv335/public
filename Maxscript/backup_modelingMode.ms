(
	-- Created for INDG

	if theModelingMode != undefined then (destroyDialog theModelingMode) else (theModelingMode = undefined)
	global theModelingMode
	
	local theNodeOBJStatus
	local theNodeSceneStatus
	local theExclusionStatus
	
	local readSceneStatus
	local readOBJStatus
	local readExclusionStatus
	
	local _allowToClose = false
	
	local backUpGeoName = "=backupGeoMats"
	local backupGeoMat = "=backupMat"
	
	local getMaterialFromBackup
	
	/*
	-- from objects get exclusion/inclusion if light or refract/reflect vrayTraceSets -- default LS
	fn makeSaveExclusion theLayer:"_LS_" =
	(
		indexedNodes = #()
		struct lesLightIon (geoName,geoIsLight,geoExdOrReflect,geoIncOrRefract)
		
		for geo in objects where matchpattern geo.layer.name pattern:("*" + theLayer +"*") do (
			theNodes = lesLightIon()
			
			theNodes.geoName = geo.name
			theNodes.geoIsLight = ((classOf geo) == VrayLight)
			if ((classOf geo) == VrayLight) then (theNodes.geoExdOrReflect = try(for items in geo.excludeList collect items.name) catch (undefined)) 
			else (theNodes.geoExdOrReflect = try (for items in ((vrayGetTraceSets geo).reflect_exclude) collect items.name) catch (undefined))
			
			if ((classOf geo) == VrayLight) then (theNodes.geoIncOrRefract = try(for items in geo.includeList collect items.name) catch (undefined)) 
			else (theNodes.geoIncOrRefract = try (for items in ((vrayGetTraceSets geo).refract_exclude) collect items.name) catch (undefined))
			
			append indexedNodes theNodes
		)
		return indexedNodes
	)
	*/
	-- get all nodes names materials and layers name from layer, if searchInside false, gets all objects and not the given layer
	fn getGeoNodesSetup theLayer:"_OBJ_" searchInside:true specficList: =
	(
		local indexedNodes = #()
		
		struct lesNodeians (geoName, geoMat, geoModz, geoLayerName, geoIsLight, geoExdOrReflect, geoIncOrRefract)
		struct lesNodeiansMod (modName, modStatus, important)
		for geo in objects where (specficList != unsupplied) do (print (findItem specficList geo.name != 0))
		for geo in objects where (
			(if searchInside then (matchpattern geo.layer.name pattern:("*" + theLayer +"*"))
			else (not matchpattern geo.layer.name pattern:("*" + theLayer +"*"))
			) and (geo.name != backUpGeoName) and (if (specficList == unsupplied) then (true) else (findItem specficList geo.name != 0))
			) do (
					
				theIndexMod = #()
				theNodes = lesNodeians()
				
				theNodes.geoName = geo.name
				if geo.mat != undefined then theNodes.geoMat = geo.mat else theNodes.geoMat = (VrayMtl Name:"None")
				
				for modz in geo.modifiers do (
					theModz = lesNodeiansMod()
					
					theModz.modName = modz.name
					theModz.modStatus = modz.enabled
					theModz.important  = ((classof modz == openSubdiv) or (classof modz == TurboSmooth) or (classof modz == Push))
					append theIndexMod theModz
				)
				
				theNodes.geoModz = theIndexMod
				theNodes.geoLayerName = geo.layer.name
				
				theNodes.geoIsLight = ((classOf geo) == VrayLight)
				if ((classOf geo) == VrayLight) then (theNodes.geoExdOrReflect = try(for items in geo.excludeList collect items.name) catch (undefined)) 
				else (theNodes.geoExdOrReflect = try (for items in ((vrayGetTraceSets geo).reflect_exclude) collect items.name) catch (undefined))
				
				if ((classOf geo) == VrayLight) then (theNodes.geoIncOrRefract = try(for items in geo.includeList collect items.name) catch (undefined)) 
				else (theNodes.geoIncOrRefract = try (for items in ((vrayGetTraceSets geo).refract_exclude) collect items.name) catch (undefined))
				
				append indexedNodes theNodes
			)
		return indexedNodes
	)
	
	-- goes to proper layer
	fn workOnCorrectLayer theLayer:"_OBJ_" =
	(
		for i = 0 to ((layerManager).count - 1) where (matchpattern ((layerManager.getLayer i).name) pattern:(theLayer + "*")) do (
			((LayerManager.getLayerFromName ((layerManager.getLayer i).name)).current = true)
		)
	)
	
	-- closes all layers except given layer -- toggle off and on
	fn closeLayersNot theLayer:"_OBJ_" visible:true =
	(
		for i = 0 to ((layerManager).count - 1) where not (matchpattern ((layerManager.getLayer i).name) pattern:(theLayer + "*")) do (
			((LayerManager.getLayerFromName ((layerManager.getLayer i).name)).on = visible)
		)
	)
	
	-- activated geometry on layer
	fn activateAllGeometry theLayer:"_OBJ_" =
	(
		for geo in objects where (matchpattern geo.layer.name pattern:("*"+theLayer+"*")) do geo.isHidden = false
	)
	
	-- hiden PITC specific items
	fn keepHidden =
	(
		theGeoList = #("__GripComments__","__pitcEnvData__","__pitcSceneHull__","__pitcStudioSettings__", \
						"__stylePitcSceneHull__","studioOverrideMtls","pitcMirrorPlane")
		for geo in objects where ((findItem theGeoList geo.name) != 0) do geo.isHidden = true
	)
	
	-- make simple array from struct
	fn collectArrayFromStruct theStructArray: collectIndex:1 strigy:true =
	(
		if not (strigy) then propStructToArray = for values in theStructArray collect try((getProperty values ((getPropNames theStructArray[1])[collectIndex]))) catch ("")
		else propStructToArray = for values in theStructArray collect try((getProperty values ((getPropNames theStructArray[1])[collectIndex])) as string) catch ("")
		return propStructToArray
	)
	
	-- compare one with the other -- testing
	fn theCompareGeo originalStatus: currentStatus: =
	(
		local theStatus = #()
		for o_item in originalStatus do (
			for c_item in currentStatus where (o_item.geoName == c_item.geoName) do (
				if (o_item.geoName == c_item.geoName) then 
				try (if (o_item.geoMat != c_item.geoMat) and (o_item.geoMat.name != "None") do (
					append theStatus (c_item.geoName + ":wrong material - apply this ->:" + o_item.geoMat.name)
					)
				) catch (append theStatus (c_item.geoName + ":error material"))
				for c_mod in c_item.geoModz do (
					if (c_mod.important) and not (c_mod.modStatus) then (append theStatus (c_item.geoName + ":" + c_mod.modName + ":Modifier needs to be activated"))
					if not (c_mod.important) and not (c_mod.modStatus) then (append theStatus (c_item.geoName + ":" + c_mod.modName + ":Modifier off, turn it on?"))
				)
				if (o_item.geoLayerName != c_item.geoLayerName) and c_item.geoLayerName != "0" and o_item.geoLayerName != "0" do (
					append theStatus (c_item.geoName + ": Wrong Layer - move to ->:" + o_item.geoLayerName)
					)
				if c_item.geoLayerName == "0" then (append theStatus (c_item.geoName + ": Geometry in Layer 0"))
			)
		)
		
		/*
		for c_item in currentStatus do (
			print "----"
			print c_item
			theModData = (collectArrayFromStruct theStructArray:originalStatus collectIndex:(findItem (getPropNames currentStatus[1]) #geoModz) strigy:false)[(
					findItem (collectArrayFromStruct theStructArray:originalStatus collectIndex:(findItem (getPropNames currentStatus[1]) #geoName)) c_item.geoName)]
			localModArray = try (
				(for items in (collectArrayFromStruct theStructArray:theModData collectIndex:(findItem (getPropNames theModData[1]) #Modname) strigy:false) collect items)
			) catch (#())
			for modz in c_item.geoModz where (findItem localModArray modz.Modname) == 0 do (append theStatus (c_item.geoName + ": missing modifier:" + modz.Modname))
		)
		*/
		
		-- checks for missing modifiers
		try (
			for o_item in originalStatus do (
				theModData = (collectArrayFromStruct theStructArray:currentStatus collectIndex:(findItem (getPropNames originalStatus[1]) #geoModz) strigy:false)[(
						findItem (collectArrayFromStruct theStructArray:currentStatus collectIndex:(findItem (getPropNames originalStatus[1]) #geoName)) o_item.geoName)]
				localModArray = try (
					(for items in (collectArrayFromStruct theStructArray:theModData collectIndex:(findItem (getPropNames theModData[1]) #Modname) strigy:false) collect items)
				) catch (#())
				for modz in o_item.geoModz where (findItem localModArray modz.Modname) == 0 do (
					append theStatus (o_item.geoName + ": missing modifier:" + modz.Modname)
				)
			)
		)
		catch()
		
		-- checkStatus of current
		for o_item in originalStatus where \
			(findItem (collectArrayFromStruct theStructArray:currentStatus collectIndex:(findItem (getPropNames currentStatus[1]) #geoName)) o_item.geoName) == 0 do (
				append theStatus (o_item.geoName + ": Missing/Deleted/Renamed")
			)
				
		for c_item in currentStatus where \
			(findItem (collectArrayFromStruct theStructArray:originalStatus collectIndex:(findItem (getPropNames currentStatus[1]) #geoName)) c_item.geoName) == 0 do (
				append theStatus (c_item.geoName + ": New Geometry in Layer:" + c_item.geoLayerName)
			)
		return theStatus
	)
	
	-- theCompare
	fn theCompareExclusion originalStatus: currentStatus: =
	(
		local theStatus = #()
		for o_item in originalStatus do (
			for c_item in currentStatus where (o_item.geoName == c_item.geoName) do (
				if (c_item.geoIsLight) then (
					if c_item.geoExdOrReflect != undefined then (
						for items in o_item.geoExdOrReflect where \
							((findItem (for geo in ((getNodebyName c_item.geoName).excludeList) collect geo.name) items) == 0) do (
								append theStatus (o_item.geoName + ":EXClusion mising of:" + items)
							)
					)
					if c_item.geoIncOrRefract != undefined then (
						for items in o_item.geoIncOrRefract where \
							((findItem (for geo in ((getNodebyName c_item.geoName).includeList) collect geo.name) items) == 0) do (
								append theStatus (o_item.geoName + ":INClusion mising of:" + items)
							)
					)
				)
				else (
					if c_item.geoExdOrReflect != undefined then (
						for items in o_item.geoExdOrReflect where \
							((findItem (for geo in (vrayGetTraceSets (getNodebyName c_item.geoName)).reflect_exclude collect geo.name) items) == 0) do (
								append theStatus (o_item.geoName + ":ReFlect mising of:" + items)
							)
					)
					if c_item.geoIncOrRefract != undefined then (
						for items in o_item.geoIncOrRefract where \
							((findItem (for geo in (vrayGetTraceSets (getNodebyName c_item.geoName)).refract_exclude collect geo.name) items) == 0) do (
								append theStatus (o_item.geoName + ":reFRAct mising of:" + items)
							)
					)
				)
			)
		)
		return theStatus
	)
	
	-- 
	fn getNodesFromArray theArray: =
	(
		local theNodesArray = undefined
		if theArray != undefined then (theNodesArray = for geo in objects where (findItem theArray geo.name) != 0 collect geo)
		return theNodesArray
	)
	
	-- fixScene
	fn theFixTheScene originalStatus: currentStatus: specificList: =
	(
		for c_item in currentStatus where (
			if (specificList == unsupplied) then (true) else (findItem specificList c_item.geoName != 0)
			) do (
			theNodeItem = (getNodeByName c_item.geoName)
			theData = (try (originalStatus[(findItem (collectArrayFromStruct theStructArray:originalStatus \
				collectIndex:(findItem (getPropNames originalStatus[1]) #geoName)) c_item.geoName)]) catch(undefined))
				
			if theData != undefined and theNodeItem != undefined then
			(
				-- fix material
				if (c_item.geoMat != theData.geoMat) and (theData.geoMat != undefined) then (
					theNodeItem.mat = (getMaterialFromBackup matName:theData.geoMat.name)
				)
				-- fix layer
				if (c_item.geoLayerName != theData.geoLayerName) and (theData.geoLayerName != "0") then (LayerManager.getLayerFromName (theData.geoLayerName)).addnode theNodeItem
					
				-- turn on modz important
				for modz in theNodeItem.modifiers do (
					for items in theData.geoModz where modz.name == items.modName and items.important do (
						modz.enabled = true
					)
				)
				-- fix exclusion/inclusion or refract/reflect list
				if theData.geoExdOrReflect != undefined then (
					if c_item.geoIsLight then (theNodeItem.excludeList = (getNodesFromArray theArray:theData.geoExdOrReflect))
					else ((vrayGetTraceSets theNodeItem).reflect_exclude = (getNodesFromArray theArray:theData.geoExdOrReflect))
				)
				if theData.geoIncOrRefract != undefined then (
					if c_item.geoIsLight then (theNodeItem.includeList = (getNodesFromArray theArray:theData.geoIncOrRefract))
					else ((vrayGetTraceSets theNodeItem).refract_exclude = (getNodesFromArray theArray:theData.geoIncOrRefract))
				)
			)
		)
	)
	
	-- collect materials
	fn collectMaterials theLayer: =
	(
		local matList = #()
		for geo in geometry where (matchpattern geo.layer.name pattern:("*" + theLayer + "*")) do (
			try (if geo.mat != undefined and geo.mat.name != backupGeoMat then append matList geo.mat) catch ()
		)
		return matList
	)
	
	-- createMaterialBackup
	fn backupMaterials matList: =
	(
		local backupMaterial = undefined
		for mats in sceneMaterials where mats.name == backupGeoMat do 
		(	
			mats.materialList = matList
			backupMaterial = mats
		)
		if backupMaterial == undefined then (
			backupMaterial = MultiMaterial name:backupGeoMat
			backupMaterial.materialList = matList
		)

		if (getNodebyName backUpGeoName) == undefined then (
			backupSphere = Sphere name:backUpGeoName radius:0.0 pos:[0,0,0]
			backupSphere.mat = backupMaterial
			backupSphere.isFrozen  = true
			backupSphere.renderable = false
		)
		else ((getNodebyName backUpGeoName).mat = backupMaterial)
		try ((LayerManager.getLayerFromName "_GRND_").addnode backupSphere) catch(messagebox "Missing GRND layer")
	)
	
	-- getMaterial from sphere
	fn getMaterialFromBackup matName: backupObject:(getNodebyName backUpGeoName) =
	(
		local foundMat
		if backupObject != undefined and (classOf backupObject.mat == MultiMaterial) and matName != "None" then (
			for mats in backupObject.mat.materialList where (matchpattern mats.name pattern:matName) do (foundMat = mats)
		)
		return foundMat
	)
	
	-- collect data
	fn updateOriginalNodes =
	(
		theNodeOBJStatus = getGeoNodesSetup()
		theNodeSceneStatus = (getGeoNodesSetup theLayer:"*" searchInside:true)
		--theExclusionStatus = (makeSaveExclusion theLayer:"*")
	)
	
	-- delete the materialbackup
	fn deleteMaterialBackup =
	(
		try (delete (getNodeByName backUpGeoName)) catch ()
	)
	
	-- read Scene Status
	fn readStatusOfScene =
	(
		readSceneStatus = (getGeoNodesSetup theLayer:"*" searchInside:true)
		readOBJStatus = getGeoNodesSetup()
		--readExclusionStatus = (makeSaveExclusion theLayer:"*")
	)
	
	-- do modeling
	fn doModelingMode activate:true =
	(
		try (
			keepHidden()
			activateAllGeometry()
			closeLayersNot visible:activate
			workOnCorrectLayer()
		) catch (print "Modeling error")
	)
	-- insert readScene status and return data array - add to listbox
	fn checkSceneGetStatus listBoxLoad: =
	(
		readStatusOfScene()
		if listBoxLoad[1] == "Clean" then listBoxLoad = #()
		
		listBoxLoad = ((theCompareGeo originalStatus:theNodeSceneStatus currentStatus:readSceneStatus))
		listBoxLoad = (join listBoxLoad (theCompareExclusion originalStatus:theNodeSceneStatus currentStatus:readSceneStatus))
			
		if (listBoxLoad.count) == 0 then (listBoxLoad = #("Clean"))
		return listBoxLoad
	)
	-- initilize
	fn __init__ =
	(
		-- stuff to load when loading rollout
		doModelingMode activate:true
		updateOriginalNodes()
		
		deleteMaterialBackup()
		(backupMaterials matList:(collectMaterials theLayer:"_OBJ_"))
	)
	-- register and unregister callbacks when max open
	fn registerCallbacks =
	(
		callbacks.removeScripts id:#ModelingModeActive
		for theEvent in #(#filePostOpen) do (
			callbacks.addScript theEvent "(theModelingMode.BTN_hiddenUpdate.pressed())" id:#ModelingModeActive
			callbacks.addScript theEvent "(theModelingMode.MTL_mainScene.items = #(MaxFilePath))" id:#ModelingModeActive
		)
	)
	fn unregisterCallbacks =
	(
		callbacks.removeScripts id:#ModelingModeActive
	)
	
	fn measureFunctionComplex ifCircle:false =
	(
		local intUnits = 1
		local sysUnit = 1
		local intValUnit = 1
		case (units.SystemType) of 
		(
			#millimeters: sysUnit = 1;
			#centimeters: sysUnit = 10;
			#meters: sysUnit = 100;
			#Inches: sysUnit = 25.4;
			#Feet: sysUnit = 304.8;
			default: 1
		)
		case (units.MetricType) of 
		(
			#millimeters: (intUnits = "mm";intValUnit = 1)
			#centimeters: (intUnits = "cm";intValUnit = 10)
			#meters: (intUnits = "m";intValUnit = 1000)
			#kilometers: (intUnits = "km";intValUnit = 1000000)
			default: (intUnits = "";intValUnit = 1)
		)
		local measureDistance = 0
		try (
			for values in ($.EditablePoly.getSelection #Edge) do (
				twopoints = polyOp.getEdgeVerts $ values
				measureDistance += distance ($.verts[twopoints[1]].pos) ($.verts[twopoints[2]].pos)
			)
		) 
		catch ()
		try (
			if classOf $ == Tape then (measureDistance = (distance $ $.Target);ifCircle = false)
			else if classOf $ == TargetObject then (measureDistance = (distance $ (getNodeByName (filterstring ($.name) ".")[1]));ifCircle = false)
			else if ((classOf $[1]) == Tape and (classOf $[2]) == TargetObject) do (measureDistance = (distance $[1] $[2]);ifCircle = false)
		)
		catch ()
		if ifCircle then (measureDistance = ((measureDistance * (sysUnit as float/intValUnit as float))/(2*pi)) as string + intUnits as string)
		else (measureDistance = (((measureDistance * (sysUnit as float/intValUnit as float)) as string) + intUnits as string))
			
		return (#(ifCircle,measureDistance))
	)
	
	fn destoryApp =
	(
		doModelingMode activate:true
		deleteMaterialBackup()
		unregisterCallbacks()
		destroyDialog theModelingMode
	)
	
	--//
	-- initilize application
	
	__init__()
	registerCallbacks()
	
	--\\
	
	rollout theModelingMode "reModeling - trial edition - v.qt(3.1415)"
	(
		timer TMR_executeInterval interval:5000 enabled:false active:false
		
		multilistbox MTL_mainScene "WorkScene" items:#(MaxFilePath) height:1 width:400 across:2 enabled:true
		button BTN_close "Close tool" align:#right height:30 offset:[0,10]
		
		group "data"
		(
			label LBL_information "Select Edge(s) of Editable Poly" across:4 offset:[30,-1]
			checkbox CHK_circle "Circle?" checked:false offset:[60,-1]
			edittext EDT_measurement "Length:" ReadOnly:true
			button BTN_measureSelection "Measure selection"
		)
		
		on CHK_circle changed theState do
		(
			if theState then EDT_measurement.caption = "Radius:"
			else EDT_measurement.caption = "Length:"
		)
		
		on BTN_measureSelection pressed do
		(
			messageSurement = (measureFunctionComplex ifCircle:CHK_circle.checked)
			EDT_measurement.text = messageSurement[2]
			CHK_circle.checked = messageSurement[1]
			if not messageSurement[1] then EDT_measurement.caption = "Length:"
		)
		
		group "scene" 
		(
			button BTN_testScene "Test Scene" width:120 height:40 across:3
			button BTN_activeModeling "Modeling Mode - OFF- " width:160 height:40
			button BTN_fixScene "Fix All" width:120 height:40 
			--button BTN_backupMaterials "Materials backup" width:120 height:40
			button BTN_hiddenUpdate width:0 height:0
			
			checkbox CHK_modelingMode "Modeling Mode" checked:false enabled:false across:5
			checkbox CHK_fixAll "Fix All Globally" checked:true tooltip:"- If unchecked will try to check and fix only the issues from the global checks list\n- If checked will and check fix all scene objects"
			checkbox CHK_timmerActivated "Automatic Test" checked:false tooltip:"- If checked will automatically test the scene"
			spinner SPN_timmerCheck "Check every:" type:#integer range:[1,10,5] offset:[23,1]
			button BTN_helpLoad "help" width:40 height:20 align:#right offset:[-17,-2]
		)
		multilistbox MTL_messageBox "global check"
		
		-- multi list do things when clicked
		on MTL_mainScene doubleclicked val do
		(
			try (shellLaunch "explorer.exe" ("\"" + MTL_mainScene.items[val] + "\""))
			catch(messagebox "file missing")
		)
		-- multi list do things when clicked
		on MTL_messageBox doubleclicked val do
		(
			try (select (getNodeByName (filterstring MTL_messageBox.items[val] ":")[1])) catch()
		)
		on MTL_messageBox rightclick val do
		(
			try (MTL_messageBox.selection = #()) catch ()
		)
		-- hidden button
		on BTN_hiddenUpdate pressed do
		(
			try (__init__()) catch ()
		)
		-- buttons
		on BTN_activeModeling pressed do
		(
			try (
				theModelingMode.BTN_testScene.pressed()
				if (CHK_modelingMode.checked) then (
					BTN_activeModeling.text = "Modeling Mode - OFF -"
					doModelingMode activate:(CHK_modelingMode.checked)
					CHK_modelingMode.checked = false
				)
				else (
					BTN_activeModeling.text = "Modeling Mode - ON -"
					doModelingMode activate:(CHK_modelingMode.checked)
					CHK_modelingMode.checked = true
				)
			)
			catch (messageBox "Modeling mode failed")
		)
		on BTN_testScene pressed do
		(
			try (MTL_messageBox.items = (checkSceneGetStatus listBoxLoad:MTL_messageBox.items)) catch (messageBox "Test errored")
		)
		on BTN_fixScene pressed do
		(
			try (
				local theLocalStatus
				readStatusOfScene()
				
				theLocalStatus = readSceneStatus
				MTL_messageBox.items = (checkSceneGetStatus listBoxLoad:MTL_messageBox.items)
				
				if not (CHK_fixAll.checked) then (
					checksMessageBox = (for item in MTL_messageBox.items collect ((filterstring item ":")[1]))
					(theFixTheScene originalStatus:theNodeSceneStatus currentStatus:readSceneStatus specificList:checksMessageBox)
				)
				else (theFixTheScene originalStatus:theNodeSceneStatus currentStatus:readSceneStatus )
				
				MTL_messageBox.items = (checkSceneGetStatus listBoxLoad:MTL_messageBox.items)
			) catch (messageBox "Fix error failed")
		)
		
		-- help pdf documentation
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" +"\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\modelingMode\\modelingMode.pdf" + "\""))
			catch(messagebox "file missing")
		)
		
		-- timmer things
		on SPN_timmerCheck changed val do
		(
			try (TMR_executeInterval.interval = (val*1000)) catch ()
		)
		on CHK_timmerActivated changed theState do
		(
			try (
				TMR_executeInterval.enabled = theState
				TMR_executeInterval.active = theState
			) catch ()
		)
		on TMR_executeInterval tick do
		(
			BTN_testScene.pressed()
		)
		
		-- on close do close things
		on BTN_close pressed do
		(
			try (
				BTN_testScene.pressed()
				if MTL_messageBox.items[1] == "Clean" then (
					if (queryBox "Do you want to close?" title:"Close?") then (destoryApp())
				)
				else (
					messageBox "Some things are not fixed" title:"Warning!" beep:true
					if (queryBox "Do you really want to close?" beep:true title:"Are you sure?") then (destoryApp())
				)
			)
			catch (
				messageBox "Close Failure" title:"Warning!" beep:true
				if (queryBox "Do you really want to close?" beep:true title:"Are you sure?") then (destroyDialog theModelingMode)
			)
		)
		on theModelingMode close do
		(
			doModelingMode activate:true
			deleteMaterialBackup()
		)
	)
	createDialog theModelingMode width:500 height:360 style:#(#style_titlebar) --style_sysmenu
)