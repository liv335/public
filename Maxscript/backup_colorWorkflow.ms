(
	--Created for INDG

	global theRollout -- atempts to close rollout if already is open
	try (if theRollout != undefined then closeRolloutFloater theRollout; theRollout = undefined) catch()
	
	-- fileLoad
	local theFileLoad
	local wasCancelled = false
	
	-- bitmap variables
	local theBitmaptexture = undefined
	local theBitmap =  undefined
	local theLoadedImage = undefined
	
	-- for x,y and draw crosshair
	local _selected = false
	local xValue = 0
	local yValue = 0
	local numberPasses = 2
	
	local namingForRenders = "_index_"
	-- window height/width, might be a problem for 960x960
	local previewHeight
	local previewWidth
	if renderHeight >= 1024 then previewHeight = 1024 else previewHeight = renderHeight
	if renderWidth >= 960 then previewWidth = 960 else previewWidth = renderWidth
	
	-- always render camera
	local theCamera = $PITC_Camera001
	local mainRolloutHeight = 960
	local mainRolloutWidth = 520
	local theParts = 2
	
	-- size and position
	local previewPos = 250
	local theSampleSizeList = #("3x3","5x5","7x7")
	
	-- folder location
	local extension = ".png"
	local theFolderLocation = (maxFilepath + "_analysis")
	local theTemplateBitmap = (theFolderLocation +"\\" + "_index_template" + extension)
	local theLocation
	local theNoArtworkLocation = "\\\\nas\\GRIP\\Grip_batchTools\\Miscellaneous\\forColorEditorTool\\00000 - forToolCheckColor-2k-art.png"
	local dataTesting = false
	
	-- rollouts
	local theData = undefined
	local theCurve = undefined
	local theBatch = undefined
	local theDeterminer = undefined
	local theMaterialsRoll = undefined
	local progressBarYolo = undefined
	
	-- strage array
	local valueArray = #()
	local returnArray = #()
	
	local theUndoCheck = false
	if colorWorkFlow == undefined then theUndoCheck = true
	
	-- returnNodesData
	fn returnsNodesData =
	(
		local nodeListLoader = #()
		struct nodeLoaderDynamics
		(
			geoLoad,
			geoMat,
			geoIfEmpty,
			geoIfArt
		)
		for geo in Geometry where (matchpattern geo.layer.name pattern:"*OBJ*") and geo.name[1] == "_" and \
			not (matchpattern geo.name pattern:"*_droplets*") do (
				local theLoader = nodeLoaderDynamics()
				theLoader.geoLoad = geo
				theLoader.geoMat = geo.mat
				try (
					if (geo.mat.map1.name) == "Empty" and (geo.mat.map1 == VrayBlendMtl) then (theLoader.geoIfEmpty = true) else (theLoader.geoIfEmpty = false)
					) 
				catch (
					for albedoColor in (getClassInstances VrayColor) where albedoColor.name =="Albedo" do (
						try (for i = 1 to (refs.dependents albedoColor).count where ((classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
							(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject) and \
							geo == (refs.dependents albedoColor)[i] do theLoader.geoIfEmpty = "notDead" 
							)
						catch (theLoader.geoIfEmpty = "dead")
					)
				)
				try (if (matchpattern geo.mat.name pattern:("art@*")) then (theLoader.geoIfArt = true) else (theLoader.geoIfArt = false)) catch (theLoader.geoIfArt = false)
				appendIfUnique nodeListLoader theLoader
			)
		return nodeListLoader
	)
	local theLoadedMaterials = returnsNodesData()
	fn theSystemsCheck theLoadedMaterials: =
	(
		struct theCheck
		(
			failMatCheck,
			artworkCheck,
			artworkBad,
			artworkNameText
		)
		local sceneCheckLoader = theCheck()
		local failedMat = for matCheck in theLoadedMaterials where (classOf matCheck.geoLoad.mat == Blend) and \
			not (matchpattern matCheck.geoLoad.mat.name pattern:("*art@*")) collect matCheck
		local appliedArt = for matCheck in theLoadedMaterials where (matchpattern matCheck.geoLoad.mat.name pattern:"art@*") collect matCheck
		if (failedMat.count == theLoadedMaterials.count) then sceneCheckLoader.failMatCheck = "Valid!" else  sceneCheckLoader.failMatCheck = "Invalid!"
		if (appliedArt.count != 0) then sceneCheckLoader.artworkCheck = "Applied!" else sceneCheckLoader.artworkCheck = "Not Applied"
		print appliedArt.count
		sceneCheckLoader.artworkBad = appliedArt.count
		sceneCheckLoader.artworkNameText = "Load one"
		return sceneCheckLoader
	)
	local theSystemCheck = (theSystemsCheck theLoadedMaterials:theLoadedMaterials)
	
	-- loadArtworkUsing
	fn loadArtworkUsingGrip theFile: theNodes: =
	(
		if theNodes.count != 0 and theFile != undefined then 
		(
			theSexyBitmanp = Bitmaptexture filename:theFile
			theArtworkAssignments = GripViewerRendering.getArtworkAssignments theSexyBitmanp
			PITCRendering.applyArtworks theArtworkAssignments nodes:theNodes
		)
	)
	-- function to get unique value
	fn fileToUse ext:extension =
	(
		return location = theFolderLocation + "\\" + \
				namingForRenders + (bit.intAsHex ((substring (timeGetTime() as string) 1 ((timeGetTime() as string).count - 1)) as integer)) + ext
	)
	-- grabScreen withSafe frame
	fn getScreenGrabSafeFrame filenameLocation: theCameraCheck:$PITC_Camera001 =
	(
		-- name created when function is run
		local unqiueId = (bit.intAsHex ((substring (timeGetTime() as string) 1 ((timeGetTime() as string).count - 1)) as integer)) as string
		(
			displaySafeFrames = true
			viewport.SetShowEdgeFaces false
			displayColor.shaded = #material
			actionMan.executeAction 0 "63566"  -- Views: Default Shading
			if theCameraCheck != undefined then viewport.setCamera theCameraCheck
			completeRedraw()
		)
		
		--local filenameLocation = maxFilepath + (getfileNameFile maxFileName)
		local grabScreen = gw.getViewportDib()
		grabScreen.filename = (filenameLocation + "\\" + namingForRenders + unqiueId +  "_grabView" + extension) -- filename if needed
		
		local theBaseForResize = bitmap (grabScreen.width as float *(renderHeight/grabScreen.height as float)) renderHeight color:white filename:(filenameLocation + "\\" + namingForRenders + unqiueId + "_Resize" + extension) -- filename if needed
		theBitmapResized = copy grabScreen theBaseForResize
		
		local cropFileName = (filenameLocation + "\\" + namingForRenders + unqiueId + "_Crop" + extension)
		local theCropGrab = bitmap renderWidth renderHeight color:white filename:cropFileName -- filename if needed
		pasteBitmap theBitmapResized theCropGrab (box2  (((theBitmapResized.width/2)-(renderWidth/2))) 0 \
			(((renderWidth/2)-(theBitmapResized.width/2))+theBitmapResized.width) theBitmapResized.height) [0,0]
		save theCropGrab 
			
		free grabScreen
		free theBitmapResized
		free theCropGrab
		
		return cropFileName
	)
	
	-- HSB to PSformat
	fn convertHSBtoPSformat theColor: =
	(
		local theHSBString = "0,0,0"
		if (classOf theColor) == color then (
			hueAdjustment = ((((theColor.h/255)*360) as integer) as string)
			if hueAdjustment == "360" then hueAdjustment = "0"
			theHSBString = (hueAdjustment + "," + ((((theColor.s/255)*100) as integer) as string) + "," + \
														((((theColor.v/255)*100) as integer) as string))
		)
		return theHSBString
	)
	-- convertString
	fn convertStringHSBtoColor theString: phShop:true =
	(
		local theHSBColor = (color 0 0 0)
		if (filterString theString ",").count == 3 and phShop == true then (
			theHSBColor.v = ((((filterString theString ",")[3] as float)/100)*255)
			theHSBColor.s = ((((filterString theString ",")[2] as float)/100)*255)
			theHSBColor.h = ((((filterString theString ",")[1] as float)/360)*255)
		)
		else if (filterString theString ",").count == 3 and phShop == false then (
			theHSBColor.v = ((filterString theString ",")[3] as float)
			theHSBColor.s = ((filterString theString ",")[2] as float)
			theHSBColor.h = ((filterString theString ",")[1] as float)
		)
		return theHSBColor
	)
	-- something (make stuff string, cause redundency, and lazy, and as long as my salary doesn't match the average european tehnical artist or IT salary then I get to do what I want until i'm fired or quit)
	fn something redValue: greenValue: blueValue: colorValue: =
	(
		local textString = "0,0,0"
		if redValue != unsupplied and greenValue != unsupplied and blueValue != unsupplied then (
			try (
				return textString = ((redValue as integer) as string) + "," + ((greenValue as integer) as string) + "," + ((blueValue as integer) as string)
			)
			catch()
		)
		if colorValue != unsupplied and classOf colorValue == color then (
			try (
				textString = ((colorValue.red as integer) as string + "," + ((colorValue.green as integer)as string) + "," + ((colorValue.blue as integer) as string))
			)
			catch()
		)

		return textString
	)
	
	-- try to determin curve from grip settings
	local leCurve = "0.0, 0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0, 1.0"
	if $__pitcStudioSettings__ != undefined then (
		try 
		(
			leCurve = ($__pitcStudioSettings__.CAS_GripStudioSettings.colorCorrectionCurve) as string
			leCurve = (substring leCurve 3 ((leCurve.count)-3))
		)
		catch ()
	)
	else ()
	
	-- rollout -main- Loading
	local theRollout = newRolloutFloater "main -" mainRolloutWidth mainRolloutHeight
	
	-- give hex get color, give color get hex
	fn hexAndColor valueGive: =
	(
		local valueGive = valueGive
		if (classOf valueGive) == Color then valueGive = #(valueGive.red,valueGive.green,valueGive.blue)
		local returnValue = "invalid"
		if valueGive[1] == "#" then (valueGive = (substring valueGive 2 valueGive.count))
		if valueGive.count == 6 then (
			try (returnValue = for k=0 to 2 collect (bit.hexasint (substring (valueGive as string) (1 + 2*k) 2))) catch (returnValue = "invalid hex")
		)
		else if valueGive.count == 3 then (
			try theCheck = for checkValue in valueGive where ((checkValue as integer) > 255) or ((checkValue as integer) < 0) collect "bad" 
			catch (theCheck = #("bad"))
			if (findItem theCheck "bad") == 0 then (
				try (
						local r_color = (bit.intAsHex (valueGive[1] as integer)) as string
						local g_color = (bit.intAsHex (valueGive[2] as integer)) as string
						local b_color = (bit.intAsHex (valueGive[3] as integer)) as string
						if r_color.count == 1 then r_color = "0" + r_color
						if g_color.count == 1 then g_color = "0" + g_color
						if b_color.count == 1 then b_color = "0" + b_color
						returnValue = "#" + r_color + g_color + b_color
					)
				catch (returnValue = "invalid rgb")
			)
			else (returnValue = "invalid rgb")
		)
		return returnValue
	)
	-- update progressBar based on parts
	fn defineProgressBar parts: =
	(
		try (progressBarYolo.open = true) catch ()
		if progressBarYolo.progressingYolo.value == 100 then (progressBarYolo.progressingYolo.value = 0;progressBarYolo.LBL_theProgress.text = "0/0")
		progressBarYolo.progressingYolo.value = progressBarYolo.progressingYolo.value + (100/parts)
		progressBarYolo.LBL_theProgress.text = (((progressBarYolo.progressingYolo.value)/(100/parts)) as string) + "/" + (parts as string)
	)
	
	-- 0 rollout 
	rollout progressBarYolo "Progress -.-"
	(
		label LBL_theProgress "0/0"
		progressBar progressingYolo value:0 color:green
		-- button progressIt "theProgress"
		/*
			on progressIt pressed do (defineProgressBar parts:5)
		*/
	)
	-- 1 rollout
	rollout theCurve "Curve -.-"
	(
		edittext TXT_stringCurve "maxCurve:" text:leCurve width:430 offset:[0,0] readOnly:true tooltip:leCurve align:#center
	)
	-- 2 rollout
	rollout theBatch "Batch it -.-"
	(
		group "list Loaders" 
		(
			edittext TXT_addId "name:" text:"default" width:120 offset:[10,0] across:2
			checkBox CHK_backgroundRender "BackgroundRender" 
			
			button BTN_addHex "addValue" width:120 across:3
			edittext TXT_addHEX "HEX:" text:"#000000" width:120 offset:[10,0]
			button BTN_loadList "loadList" width:120
			
			button BTN_removeHex "removeValue" width:120 across:3
			edittext TXT_addRGB "RGB:" text:"0,0,0" width:120 offset:[10,0]
			button BTN_exportList "exportReturn" width:120
		)
		group "batchPlace" 
		(
			multilistbox MTB_theValueBox "valueSet" width:200 align:#left offset:[0,0] across:3 items:valueArray
			button BTN_batchThem "batchValues" width:80 height:100 align:#center offset:[0,30]
			multilistbox MTB_theValueReturn "returnSet" width:200 align:#right offset:[0,0] items:returnArray
		)
		-- readFile
		fn readBatchTxt theFile: =
		(
			if theFile != unsupplied then 
			(
				local batchHexList = #()
				local fileToSearch = (openFile theFile)
				if fileToSearch != undefined then
				(
					while not eof fileToSearch do(
						lineToRead = readline fileToSearch
						append batchHexList lineToRead
					)
					close fileToSearch
				)
				return batchHexList
			)
		)
		-- writeBatchtext
		fn writeBatchText theList: saveLocation: =
		(
			if theList != undefined and theList.count != 0 and saveLocation != unsupplied and saveLocation != undefined then
			(
				deleteFile saveLocation
				local theWrite = "name,desiredHex,inputHex,status\n"
				local theFile = createFile saveLocation
				for values in theList do theWrite = theWrite + values + "\n"
				format "%" theWrite to:theFile
				close theFile
			)
		)
		-- random function for colorAdaption naming if random is input, because fun times
		fn theNameAdapt colorValue: colorName: = 
		(
			local nameAdd = ""
			local theList = #("Common","Uncommon","Rare","Over","Grand","Super","Mega","Arch")
			local theName = #("Impressive","Achiever","Exciting","Meditative","Pleasant", \
				"Sensible","Adaptable","Flexible","Mediator","Positive","Sensitive","Ambitious","Focused", \
				"Modest","Practical","Sincere","Balanced","Forgiving","Organized","Proactive","Skilled","Cheerful","Generous", \
				"Original","Productive","Solid","Consistent","Genuine","Outgoing","Professional","Sporty","Cooperative", \
				"Helpful","Particular","Quality","Thoughtful","Courageous","Insightful","Patient","Quick", \
				"Trustworthy","Curious","Interesting","Perceptive","Racy","Understanding","Devoted", \
				"Inventive","Personable","Responsible","Warm")
			nameAdd += theName[(random 1 51)]
			if colorValue > 216 then nameAdd += theList[8]
			else if colorValue >= 216 and colorValue > 196 then nameAdd += theList[7]
			else if colorValue >= 196 and colorValue > 176 then nameAdd += theList[6]
			else if colorValue >= 176 and colorValue > 154 then nameAdd += theList[5]
			else if colorValue >= 154 and colorValue > 128 then nameAdd += theList[4]
			else if colorValue >= 128 and colorValue > 96 then nameAdd += theList[3]
			else if colorValue >= 96 and colorValue > 76 then nameAdd += theList[2]
			else if colorValue >= 76 and colorValue > 56 then nameAdd += theList[1]
			else if colorValue >= 56 and colorValue > 12 then nameAdd
			nameAdd += colorName
			if colorValue == 255 then nameAdd = colorName
			return nameAdd
		)
		on CHK_backgroundRender changed theStatus do
		(
			if theStatus then (
				messageBox ("it works but you need to talk to Liviu for the moment to show how set this up\n" + \
			"Liviu, may make it easier in the future")
			)
			renderers.current.output_on = not (theStatus)
			if renderSceneDialog.isOpen() do renderSceneDialog.update()
		)
		-- button to load list
		on BTN_loadList pressed do
		(
			local fileImport = (getOpenFileName  caption:"Open txt/csv file" filename:".txt" types:"All Files(*.*)|*.*|Text files(*.txt)|*.txt|CSV files(.csv)|*.csv|")
			if fileImport != undefined then 
			(
				local fullName = undefined
				-- readText
				local batchListLoadHex = (readBatchTxt theFile:fileImport)
				-- do loop
				for hexValues in batchListLoadHex do (
					theStringLoad = (filterString hexValues ",")
					if theStringLoad[1] != "name" and theStringLoad[1] != "" and theStringLoad[1] != " " then (
						try (
							if (hexAndColor valueGive:theStringLoad[2]) != "invalid" then (
								fullName = theStringLoad[1] + "," + theStringLoad[2]
							)
						) 
						catch 
						(
							if (hexAndColor valueGive:theStringLoad[1]) != "invalid" then (
								fullName = "default,"+theStringLoad[1]
							)
						)
						if fullName != undefined then (
							appendIfUnique valueArray fullName
							MTB_theValueBox.items = valueArray
						)
					)
				)
			)
		)
		-- button to export list
		on BTN_exportList pressed do
		(
			if MTB_theValueReturn.items.count != 0 then
			(
				locationFileExport = (getSaveFileName  caption:"Save Export file" filename:".txt" types:"All Files(*.*)|*.*|Text files(*.txt)|*.txt|CSV files(.csv)|*.csv|")
				if locationFileExport != undefined then (
					writeBatchText theList:(MTB_theValueReturn.items) saveLocation:locationFileExport
					messageBox "Saved Export List" beep:false
				)
			)
		)
		/*
		i've disabled features for clicking in the lists, might not be useful
		click on item 1 in list 1 selects item 1 in other list aswell, 
		*/
		-- unselect
		on MTB_theValueBox rightclick do
		(
			--MTB_theValueReturn.selection = #{}
			MTB_theValueBox.selection = #{}
		)
		-- unselect
		on MTB_theValueReturn rightclick do
		(
			MTB_theValueReturn.selection = #{}
			--MTB_theValueBox.selection = #{}
		)
		-- select in other box
		on MTB_theValueBox selected i do
		(
			--MTB_theValueReturn.selection = i
		)
		-- select in other box
		on MTB_theValueReturn selected i do
		(
			--MTB_theValueBox.selection = i
		)
		-- add to box value from hex
		on BTN_addHex pressed do 
		(
			appendIfUnique valueArray (TXT_addId.text + "," + TXT_addHEX.text)
			MTB_theValueBox.items = valueArray
		)
		-- removeHex if possible both list
		on BTN_removeHex pressed do
		(
			for i in MTB_theValueBox.selection do (
				deleteItem valueArray (findItem valueArray (MTB_theValueBox.items[(MTB_theValueBox.selection as array)[1]]))
			)
			MTB_theValueBox.items = valueArray
			
			for i in MTB_theValueReturn.selection do (
				deleteItem returnArray (findItem returnArray (MTB_theValueReturn.items[(MTB_theValueReturn.selection as array)[1]]))
			)
			MTB_theValueReturn.items = returnArray
		)
		-- batchThem button
		on BTN_batchThem pressed do
		(
			local theSatusText = "unknown"
			wasCancelled = false
			(defineProgressBar parts:1)
			theParts = (MTB_theValueBox.items.count * theDeterminer.SPN_passCout.value)
			
			if MTB_theValueBox.items.count != 0  then (
				for hexValues in MTB_theValueBox.items do (
					if not wasCancelled and not (keyboard.escPressed) then (
						local hexName = "deafult"
						local hexReduce = "#000000"
						
						-- determin if hex solo or not, some cases list will be able to add just hex without names
						try (hexReduce = (filterString hexValues ",")[2];hexName = (filterString hexValues ",")[1]) catch (hexReduce = (filterString hexValues ",")[1])
						
						-- load and press the button
						theDeterminer.CLR_theDesired.color = color (hexAndColor valueGive:hexReduce)[1] (hexAndColor valueGive:hexReduce)[2] (hexAndColor valueGive:hexReduce)[3]
						theData.TXT_desiredRGB.text = (something redValue:theDeterminer.CLR_theDesired.color.red greenValue:theDeterminer.CLR_theDesired.color.green blueValue:theDeterminer.CLR_theDesired.color.blue)
						theData.TXT_desiredHSB.text = (convertHSBtoPSformat theColor:(theDeterminer.CLR_theDesired.color))							
						-- retunded update then determin
						theDeterminer.BTN_theDeterminer.pressed()
						
						-- determin status message
						try (theSatusText = theDeterminer.TXT_outMessage.text) catch()
						
						-- if random do some magic
						if hexName == "random" then (
							local composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"theColor"
							if ((hexAndColor valueGive:hexReduce)[1]) <= 5 and ((hexAndColor valueGive:hexReduce)[2]) <= 5 and ((hexAndColor valueGive:hexReduce)[3]) <= 5 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"Black"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) < 30 and ((hexAndColor valueGive:hexReduce)[2]) < 30 and ((hexAndColor valueGive:hexReduce)[3]) < 30 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"Dark"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) < 50 and ((hexAndColor valueGive:hexReduce)[2]) < 50 and ((hexAndColor valueGive:hexReduce)[3]) < 50 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"Shadow"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) < 125 and ((hexAndColor valueGive:hexReduce)[2]) > 165 and ((hexAndColor valueGive:hexReduce)[3]) > 165 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[3]) colorName:"CyanBluish"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) > 165 and ((hexAndColor valueGive:hexReduce)[2]) < 125 and ((hexAndColor valueGive:hexReduce)[3]) > 165 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"PurplePink"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) > 165 and ((hexAndColor valueGive:hexReduce)[2]) > 165 and ((hexAndColor valueGive:hexReduce)[3]) < 125 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"YellowOrange"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) > 200 and ((hexAndColor valueGive:hexReduce)[2]) < 150 and ((hexAndColor valueGive:hexReduce)[3]) < 150 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"Red"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) < 150 and ((hexAndColor valueGive:hexReduce)[2]) > 200 and ((hexAndColor valueGive:hexReduce)[3]) < 150 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[2]) colorName:"Green"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) < 150 and ((hexAndColor valueGive:hexReduce)[2]) < 150 and ((hexAndColor valueGive:hexReduce)[3]) > 200 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[3]) colorName:"Blue"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) > 200 and ((hexAndColor valueGive:hexReduce)[2]) > 200 and ((hexAndColor valueGive:hexReduce)[3]) > 200 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"Bright"
							)
							else if ((hexAndColor valueGive:hexReduce)[1]) >= 250 and ((hexAndColor valueGive:hexReduce)[2]) >= 250 and ((hexAndColor valueGive:hexReduce)[3]) >= 250 then (
								composeName = theNameAdapt colorValue:((hexAndColor valueGive:hexReduce)[1]) colorName:"White"
							)
							returnValueAdditive =  (composeName +"," + (hexReduce as string) + "," + theDeterminer.TXT_hexValueInput.text + "," + theSatusText)
						)
						else (returnValueAdditive =  (hexName +"," + (hexReduce as string) + "," + theDeterminer.TXT_hexValueInput.text + "," + theSatusText))
						-- add to list
						append returnArray returnValueAdditive
						MTB_theValueReturn.items = returnArray
					)
					else (exit)
				)
				messageBox "Batching finished!" beep:false
				wasCancelled = false
			)
		)
		-- enter hex has string
		on TXT_addHEX entered txt do
		(
			TXT_addRGB.text = "0,0,0"
			TXT_addHEX.text = "#000000"
			if (hexAndColor valueGive:txt)[1] as string != "i" then try (
				TXT_addRGB.text = (hexAndColor valueGive:txt)[1] as string + "," + (hexAndColor valueGive:txt)[2] as string + "," +  (hexAndColor valueGive:txt)[3] as string
				)
				catch ()
			else ()
			try (TXT_addHEX.text = hexAndColor valueGive:(color ((filterString TXT_addRGB.text ",")[1] as integer) ((filterString TXT_addRGB.text ",")[2] as integer) ((filterString TXT_addRGB.text ",")[3] as integer)))
			catch ()
		)
		-- enter RGB as string
		on TXT_addRGB entered txt do
		(
			TXT_addRGB.text = "0,0,0"
			TXT_addHEX.text = "#000000"
			try (TXT_addHEX.text = hexAndColor valueGive:(color ((filterString txt ",")[1] as integer) ((filterString txt ",")[2] as integer) ((filterString txt ",")[3] as integer)))
			catch()
			if TXT_addRGB.text[1] != "i" then (
				TXT_addRGB.text = (hexAndColor valueGive:TXT_addHEX.text)[1] as string + "," + (hexAndColor valueGive:TXT_addHEX.text)[2] as string + "," +  (hexAndColor valueGive:TXT_addHEX.text)[3] as string
			)
			if TXT_addRGB.text[1] == "i" then (TXT_addRGB.text = "0,0,0"; TXT_addHEX.text = "#000000")
		)
	)
	-- 3 rollout
	rollout theData "Advance data -.-"
	(
		group "colorData" 
		(
			label LBL_stringRGB "1pxRGB:" across:4
			edittext TXT_stringRGB text:"0,0,0" width:100 offset:[0,0] readOnly:true tooltip:"Red,Green,Blue"
			
			label LBL_curveRGB "withLocalCurve:"
			edittext TXT_curveRGB text:"0,0,0" width:100 offset:[0,0] readOnly:true tooltip:"Red,Green,Blue"
			
			dropdownlist DBL_selectSize width:50 items:theSampleSizeList across:4 align:#center
			edittext TXT_stringAverageRGB text:"0,0,0" width:100 offset:[0,3] readOnly:true tooltip:"Red,Green,Blue"
			
			label LBL_desiredRGB "desiredOutput:" offset:[0,2.5]
			edittext TXT_desiredRGB text:"0,0,0" width:100 offset:[0,3] readOnly:true tooltip:"Red,Green,Blue"
			
			label LBL_HSB "HSB:" across:4
			edittext TXT_HSB text:"0,0,0" width:100 offset:[0,0] readOnly:true tooltip:"Hue,Saturation,Brightness"
			
			label LBL_desiredHSB "desiredHSB:"
			edittext TXT_desiredHSB text:"0,0,0" width:100 offset:[0,0] readOnly:true tooltip:"Hue,Saturation,Brightness"
		)
		-- dropdown selection --
		on DBL_selectSize selected i do
		(
			theDeterminer.BTN_theHiddenUpdate.pressed()
			wasCancelled = false
		)
	)
	
	-- updateMaterialRollout
	fn sceneUpdate artworkName: artworkStatus: sceneStatus: =
	(
		try (
			if artworkStatus != unsupplied then theMaterialsRoll.TXT_artworkStatus.text = artworkStatus
			if sceneStatus != unsupplied then theMaterialsRoll.TXT_sceneStatus.text = sceneStatus
			if artworkName != unsupplied then theMaterialsRoll.TXT_artworkName.text = artworkName
		)
		catch ()
	)
	-- unDomaterial
	fn undoMaterials =
	(
		try (
			if theMaterialsRoll.TXT_sceneStatus.text == "Applied!" and theMaterialsRoll.TXT_artworkStatus.text == "Valid!" then
			(
				for geo in theLoadedMaterials do (((getNodeByName (geo.geoLoad.name)).mat = geo.geoMat))
				reCheck = (theSystemsCheck theLoadedMaterials:theLoadedMaterials)
				(sceneUpdate artworkName:"Load One" artworkStatus:theSystemCheck.failMatCheck sceneStatus:theSystemCheck.artworkCheck)
			)
		)
		catch ()
	)

	-- 4 rollout
	rollout theMaterialsRoll "Artwork and Geometry -.-"
	(
		label LBL_stringRGB "Helps Adds and Undo Artwork" across:2
		checkbox CKH_undoMats "undoOnClose" checked:theUndoCheck enabled:theUndoCheck height:20 offset:[0,0] align:#center
		
		edittext TXT_sceneStatus "StatusArtwork:  " text:theSystemCheck.artworkCheck width:250 readOnly:true across:2 
		button BTN_loadArtwork "loadArtwork" width:150 height:20 offset:[0,0] align:#center enabled:theUndoCheck
		
		edittext TXT_artworkStatus "StatusMaterials:" text:theSystemCheck.failMatCheck width:250 readOnly:true across:2
		button BTN_loadNoArtwork "loadBaseNoArtwork" width:150 height:20 offset:[0,0] align:#center enabled:theUndoCheck
		
		edittext TXT_artworkName "ArtworName:     " text:"Load One" width:250 readOnly:true across:2 
		button BTN_undoMaterials "undoArtwork" width:150 height:20 offset:[0,0] align:#center enabled:theUndoCheck
		

		on BTN_loadNoArtwork pressed do
		(
			if TXT_artworkStatus.text == "Valid!" then
			(
				-- reduce name
				local theFileLoadReduce = (filterstring theNoArtworkLocation "\\")[(filterstring theNoArtworkLocation "\\").count]
				-- getNodes
				local nodesLoad = for nodez in theLoadedMaterials collect (getNodeByName(nodez.geoLoad.name))
				-- load Artwork
				if PITCRendering != undefined then (
					try (
							(loadArtworkUsingGrip theFile:theNoArtworkLocation theNodes:nodesLoad)
							(sceneUpdate artworkName:theFileLoadReduce sceneStatus:"Applied!")
							(messagebox "loaded no Artwork" beep:false)
						) catch (messagebox "error during apply artwork")
				) else (messagebox "error try to open PITC studio first")
			)
			else (messagebox "error invalid Scene")
		)
		on BTN_loadArtwork pressed do
		(
			if TXT_artworkStatus.text == "Valid!" then
			(
				local theFileLoad = getOpenFileName caption:"Load artwork:" filename:(maxFilePath) \
											types:"PNG(*.png)|*.png|JPG(*.jpg*)|*.jpg*|All(*.*)|*.*|"
				if theFileLoad != undefined then 
				(
					-- reduce name
					local theFileLoadReduce = (filterstring theFileLoad "\\")[(filterstring theFileLoad "\\").count]
					-- getNodes
					local nodesLoad = for nodez in theLoadedMaterials collect (getNodeByName(nodez.geoLoad.name))
					-- load Artwork
					if PITCRendering != undefined then (
						try (
								loadArtworkUsingGrip theFile:theFileLoad theNodes:nodesLoad 
								(sceneUpdate artworkName:theFileLoadReduce sceneStatus:"Applied!")
								(messagebox ("loaded " + theFileLoadReduce + " as Artwork") beep:false)
							) catch (messagebox "error during apply artwork")
					) else (messagebox "try to open PITC studio first")
				)
			) else (messagebox "invalid Scene")
		)
		-- undoButton
		on BTN_undoMaterials pressed do
		(
			if TXT_sceneStatus.text == "Applied!" and TXT_artworkStatus.text == "Valid!" then
			(
				undoMaterials()
				(messagebox "materials restored" beep:false)
			)
			else (messagebox "undo masterials error, please close tool and manually check materials" )
		)
		
	)
	-- 5 rollout
	rollout theDeterminer "Determiner - renderer -"
	(
		button BTN_theHiddenUpdate width:0 height:0
		group "operation"
		(
			button BTN_theLoad "testing" width:0 height:0
			--button BTN_thePreviewLoad "loadImage" width:200 height:30 across:2
			button BTN_grabViewport "load-preview" width:160 height:30 across:3
			button BTN_theRender "simple-render" width:160 height:30 offset:[-1,0]
			button BTN_theDeterminer "determin-value" width:160 height:30
		)
		group "selection" 
		(
			button BTN_adjustColor "adjustSelection" width:120 offset:[0,0] heigth:20 across:4
			edittext TXT_Selection ":" text:"nothing selected" tooltip:"nothing selected" offset:[15,0] width:120 readOnly:true  
			colorPicker CLR_theDesired "desiredRGB:" align:#right offset:[10,0] color:(color 0 0 0)
			edittext TXT_hex "HEX:" text:"#000000" width:90 offset:[25,0] tooltip:"HEX"
			
			button BTN_helpLoad "help" width:40 height:20 across:3 offset:[-60,0]
			label LBL_outMessage "statusMessage" offset:[-150,0] readOnly:true 
			edittext TXT_outMessage ":" text:"unknown" width:340 offset:[-185,0] readOnly:true tooltip:"the Status of a determination will be posted here EX: Invalid, Valid, Out of Scope on,"
		)
		group "valueDesired"
		(
			checkBox CHK_useHSB "useHSB" checked:false across:7 
			spinner SPN_adjustGI "GI" type:#float width:55 range:[0.75,2.5,1] offset:[-25,1] enabled:false
			bitmap BIT_theValueInput width:50 height:20 bitmap:(bitmap 50 20 color:(color 0 0 0)) offset:[-20,0]
			label LBL_theValueHex "input-Hex:" offset:[-30,0] readOnly:true 
			edittext TXT_hexValueInput text:"#000000" width:80 offset:[-30,0] readOnly:true tooltip:"HEX"
			label LBL_theValueInput "input-RGB:" offset:[-20,0] readOnly:true 
			edittext TXT_stringValueInput text:"0,0,0" width:90 offset:[-20,0] readOnly:true tooltip:"Red,Green,Blue"
		)
		group "dataLocation"
		(
			spinner SPN_xValue "posX" align:#left width:75 type:#integer range:[0,1000,0] across:5
			spinner SPN_yValue "posY" align:#left width:75 type:#integer range:[0,1000,0]
			checkBox CHK_regionMode "doRegion" checked:true
			spinner SPN_regionSize "regionSize" align:#left width:75 type:#integer offset:[-15,0] range:[15,75,35] 
			spinner SPN_passCout "numerPass" align:#left width:75 type:#integer range:[2,6,numberPasses] 
		)
		dotNetControl BIT_Preview "System.Windows.Forms.PictureBox" width:previewWidth height:previewHeight pos:[(mainRolloutWidth/2-previewWidth/2),previewPos]
		
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" + "\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\colorizableWeapon\\The Determiner.pdf" + "\""))
			catch(messagebox "file missing")
		)
		
		-- getColorLOcation
		fn getColorLocation mouseEventArgs =
		(
			local theX = amax 0 (amin mouseEventArgs.X (BIT_Preview.width - 1))
			local theY = amax 0 (amin mouseEventArgs.Y (BIT_Preview.height - 1))
			[(theX + 0.5) / BIT_Preview.width, (theY + 0.5) / BIT_Preview.height]
		)
		-- remove/add gamma 2.2
		fn convertToGamma enterValue: gamma: =
		(
			-- sRGB to liniar and liniar to sRGB
			local theValue = 0
			enterValue = enterValue as float
			if gamma == 2.2 and enterValue <= 255.0 and enterValue >= 0.0 then (
				if (enterValue <= 0.00313066844250063) then
					theValue = enterValue*12.92
				else
					theValue = (1.055*(pow (enterValue/255) (1/2.4))- 0.055)*255
				)
			else if gamma == 1.0 and enterValue <= 255.0 and enterValue >= 0.0 then (
				if (enterValue <= 0.0404482362771082) then 
					theValue = enterValue / 12.92
				else
					theValue = (pow (((enterValue/255)+0.055)/1.055) 2.4)*255
				)
			else if enterValue <= 0.0 then theValue = 0
			else if enterValue >= 255 then theValue = 255
			return theValue
		)
		-- make curve pop
		fn getXandY curve: =
		(
			local arrayCurved = #()
			if curve == unsupplied then curve = "0.0, 0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0, 1.0"
			curve = (filterstring curve ",")
			local x = #()
			local y = #()
			i = 1
			for num = 1 to ((curve.count/2) as integer) do (
				append x ((curve[i]) as float)
				append y ((curve[i+1]) as float)
				i += 2
			)
			append arrayCurved x
			append arrayCurved y
			-- arrays of array, array[1] = x ,array[2] y
			return arrayCurved
		)
		-- do CurveMagic
		fn returnYFromCurved x: xs: ys: =
		(
			x = x as float
			local ks = #()
			for i = 1 to (xs.count) do (
				try(
						if x != 0.0 then (
							lower = -(-ys[i] / (ys[i - 1] + x))
							higher = (ys[i + 1] / (ys[i] + x))
							leValue = ((lower + higher) * x) + x
							append ks (((leValue * 1000.0) as integer) / 1000.0)
						)
						else if x == 0.0 then (
							append ks (0.0)
						)
					)
				catch (
					append ks (0.0)
				)
			)
			q = 0
			o = 0
			for i = 1 to (xs.count) do (
				if xs[i] <= x then (
					i += 1
					t = (x - xs[i - 1]) / (xs[i] - xs[i - 1])
					a = ks[i - 1] * (xs[i] - xs[i - 1]) - (ys[i] - ys[i - 1])
					b = -ks[i] * (xs[i] - xs[i - 1]) + (ys[i] - ys[i - 1])
					q = (1 - t) * ys[i - 1] + t * ys[i] + t * (1 - t) * (a * (1 - t) + b * t)
					q = (((q * 1000.0) as integer) / 1000.0)
				)
			)
			-- q = return y
			return q
		)
		-- bitmap indicator
		fn createLocationIndicatorBitmap size: =
		(
			local theSizeOfArea = 3
			try (theSizeOfArea = ((theData.DBL_selectSize.selected)[1] as integer)/2+1) catch()
			theBitmap = dotNetObject "System.Drawing.Bitmap" size size
			local theBackColor = (dotNetClass "System.Drawing.Color").Transparent
			local theAreaColor = (dotNetClass "System.Drawing.Color").Blue
			local theForeColor = (dotNetClass "System.Drawing.Color").Magenta
			for y = 0 to (size - 1) do (
				for x = 0 to (size - 1) do (
					theBitmap.SetPixel x y (
						if (y == 0 or y == size-1) and CHK_regionMode.checked then theForeColor 
						else if (x == 0 or x == size-1) and CHK_regionMode.checked then theForeColor
						else if (y == ((size/2) as integer) and x == ((size/2) as integer)) then theForeColor
						/*
						else if (y == ((size/2) as integer) and x == ((size/2) as integer)) then theForeColor
						else if (y == ((size/2-1) as integer) and x == ((size/2-1) as integer)) then theForeColor
						else if (y == ((size/2+1) as integer) and x == ((size/2+1) as integer)) then theForeColor
						else if (y == ((size/2-1) as integer) and x == ((size/2+1) as integer)) then theForeColor
						else if (y == ((size/2+1) as integer) and x == ((size/2-1) as integer)) then theForeColor
						*/
						else if (y == ((size/2-theSizeOfArea) as integer) and (x >= ((size/2-theSizeOfArea) as integer)) and (x <= ((size/2+theSizeOfArea) as integer)) or \ 
						(y == ((size/2+theSizeOfArea) as integer)) and (x >= ((size/2-theSizeOfArea) as integer))) and (x <= ((size/2+theSizeOfArea) as integer)) then theAreaColor
						else if (x == ((size/2-theSizeOfArea) as integer) and (y <= ((size/2+theSizeOfArea) as integer)) and (y >= ((size/2-theSizeOfArea) as integer)) or \ 
						(x == ((size/2+theSizeOfArea) as integer)) and (y <= ((size/2+theSizeOfArea) as integer)) and (y >= ((size/2-theSizeOfArea) as integer))) then theAreaColor
						else theBackColor
						)
				)
			)
			theBitmap
		)
		-- init
		fn initDialog =
		(
			BIT_Preview.Cursor = dotNetObject "Cursor" ((dotNetClass "Autodesk.Max.GlobalInterface").Instance.COREInterface.GetSysCursor 6) -- Select
		)

		-- getPixel
		fn getPixelValue offSetX: offSetY: =
		(
			if offSetX == unsupplied or (classOf offSetX != integer) then offSetX = 0
			if offSetY == unsupplied or (classOf offSetY != integer) then offSetY =0
			local demPixels = (color 0 0 0)
			xValue = SPN_xValue.value
			yValue = SPN_yValue.value
			if theBitmapTexture != undefined then pixels = (getPixels theBitmaptexture [(xValue as integer + offSetX),(yValue as integer+ offsetY)] 1)
			if pixels != undefined and pixels.count != 0 then (
				demPixels = pixels[1]
			)
			return demPixels
		)
		-- too lazy to optimize threePointAverage, if sampleSize is 3 then it will pick 9 pixels, in a square where 0,0 is selection.
		fn getByThreeAverage sampleSize: =
		(
			sampleSize = (substring theSampleSizeList[theData.DBL_selectSize.selection] 1 1) as integer
			local theAverageColor = color 0 0 0 0
			try (
				local count = 0
				for x = -((sampleSize/2) as integer) to ((sampleSize/2) as integer) do (for y = -((sampleSize/2) as integer) to ((sampleSize/2) as integer) do (
					count += 1;theAverageColor = (getPixelValue offSetX:x offSetY:y) + theAverageColor)
				)
				theAverageColor = theAverageColor/count
			)
			catch ()
			return theAverageColor
		)
		
		-- rendering Functions
		fn theRenderFunction indexFile: loadIndex: = 
		(
			-- make dir if missing
			if (doesFileExist theFolderLocation) then () else (makeDir theFolderLocation)
			
			-- get x and y from rollout
			local renderX = (SPN_xValue.value - (SPN_regionSize.value/2))
			local renderY = (SPN_yValue.value - (SPN_regionSize.value/2))
				
			-- try to make a template for VFB, pixel ratio breaks region render if no other render was rendered 
			local templateSizeLoad = bitmap renderWidth renderHeight color:white filename:theTemplateBitmap
			save templateSizeLoad
				
			-- remove this due to pop up
			try (renderers.current.system_distributedRender = false) catch()
				
			-- reset vfb, always then crop if possible
			if renderers.current.output_on then
			(
				vfbControl #setregion "reset"
				if CHK_regionMode.checked then (
					try (vfbControl #loadimage theTemplateBitmap) catch ()
					vfbControl #setregion (renderX) (renderY) (renderX+SPN_regionSize.value) (renderY+SPN_regionSize.value)
				)
			)
			else (setRenderType #crop;if renderSceneDialog.isOpen() do renderSceneDialog.update())
			-- clear template
			free templateSizeLoad
			-- render
			if renderers.current.output_on then (try (render camera:theCamera cancelled:&wasCancelled vfb:false outputfile:indexFile) catch())
			else (try (render camera:theCamera cancelled:&wasCancelled renderType:#crop \
				region:#((renderX),(renderY),(renderX+SPN_regionSize.value),(renderY+SPN_regionSize.value)) vfb:false outputfile:indexFile) catch())
			-- reset vfb
			if renderers.current.output_on then (vfbControl #setregion "reset")
			else (setRenderType #normal;if renderSceneDialog.isOpen() do renderSceneDialog.update())
			theFileLoad = loadIndex
		)
		-- try to clean?
		fn cleanerTry =
		(
			try (theLoadedImage.Dispose())catch()
			try (
				close theBitmapTexture
				free theBitmapTexture
			)catch()
			try (
				close theFileLoad
				free theFileLoad
				)catch()
		)
		
		-- capValue to 0 or 255 if above or below
		fn capValue newColor: =
		(
			if newColor < 0  then newColor = 0
			else if newColor > 255 then newColor = 255
			return newColor
		)
		-- adjustObject color if Albedo exist
		fn adjustObject newColor: =
		(
			theGamma = 1.0
			newColor = (color (capValue newColor:(newColor.red)) (capValue newColor:(newColor.green)) (capValue newColor:(newColor.blue)))
			gammaAdjust = (color (convertToGamma enterValue:newColor.red gamma:theGamma) \
				(convertToGamma enterValue:newColor.green gamma:theGamma) \
				(convertToGamma enterValue:newColor.blue gamma:theGamma))
			local inversAdjust = (color (255 - newColor.red as integer) (255 - newColor.green as integer) (255 - newColor.blue as integer))
			try (
				for albedoColor in (getClassInstances VrayColor) where albedoColor.name =="Albedo" do (
					for i = 1 to (refs.dependents albedoColor).count where (classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
					(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject and \
						(getNodeByName TXT_Selection.text) == (refs.dependents albedoColor)[i] do albedoColor.color = gammaAdjust)
			)
			catch()
			try (
				for inversAlbedoColor in (getClassInstances VrayColor) where inversAlbedoColor.name =="InverseAlbedo" do (
					for i = 1 to (refs.dependents inversAlbedoColor).count where (classOf (refs.dependents inversAlbedoColor)[i]) == Editable_mesh or \
					(classOf (refs.dependents inversAlbedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject and \
						(getNodeByName TXT_Selection.text) == (refs.dependents inversAlbedoColor)[i] do inversAlbedoColor.color = inversAdjust)
				)
			catch()
		)
		-- find albedo
		fn returnColorToWork itemCheck: =
		(
			local inputValue = color 0 0 0
			if itemCheck != undefined then (
				for albedoColor in (getClassInstances VrayColor) where albedoColor.name == "Albedo" do (
					for i = 1 to (refs.dependents albedoColor).count where ((classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
						(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject) and itemCheck == (refs.dependents albedoColor)[i] do (
					inputValue = albedoColor.color
					)
				)
			)
			return inputValue
		)

		-- update Rollout Function --
		fn updateRollout =
		(
			if $__pitcStudioSettings__ != undefined then ( 
				try 
				(
				leCurve = ($__pitcStudioSettings__.CAS_GripStudioSettings.colorCorrectionCurve) as string
				leCurve = (substring leCurve 3 ((leCurve.count)-3))
				)
				catch (leCurve = "0.0, 0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0, 1.0")
			) else (leCurve = "0.0, 0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0, 1.0")
			local pointColor = (getPixelValue offSetX:0 offSetY:0)
			local threePointAverage = (getByThreeAverage())
			local zaCurve = (theCurve.TXT_stringCurve.text)
			theData.TXT_stringRGB.text = (something colorValue:(pointColor))
			theData.TXT_stringAverageRGB.text = (something redValue:(threePointAverage.red as integer) greenValue:(threePointAverage.green as integer) blueValue:(threePointAverage.blue as integer))
			if leCurve != ("0.0, 0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0, 1.0") then (	
				theData.TXT_curveRGB.text = ((something redValue:(((returnYFromCurved x:((threePointAverage.red as integer)/256 as float) xs:((getXandY curve:leCurve)[1]) ys:((getXandY curve:leCurve)[2])) *255) as integer) \ 
					greenValue:(((returnYFromCurved x:((threePointAverage.green as integer)/256 as float) xs:((getXandY curve:zaCurve)[1]) ys:((getXandY curve:zaCurve)[2])) *255) as integer) \
						blueValue:(((returnYFromCurved x:((threePointAverage.blue as integer)/256 as float) xs:((getXandY curve:zaCurve)[1]) ys:((getXandY curve:zaCurve)[2])) *255) as integer))
					)
			)
			else (theData.TXT_curveRGB.text = theData.TXT_stringAverageRGB.text)
			theData.TXT_HSB.text = (convertHSBtoPSformat theColor:(color ((filterstring theData.TXT_curveRGB.text ",")[1] as integer) \
																							((filterstring theData.TXT_curveRGB.text ",")[2] as integer) \
																							((filterstring theData.TXT_curveRGB.text ",")[3] as integer)
																							))
			BIT_Preview.Invalidate()
		)
		
		-- color Picker
		-- updateDesired
		on CLR_theDesired changed newValue do
		(
			theData.TXT_desiredRGB.text = (something redValue:CLR_theDesired.color.red greenValue:CLR_theDesired.color.green blueValue:CLR_theDesired.color.blue)
			theData.TXT_desiredHSB.text = (convertHSBtoPSformat theColor:(CLR_theDesired.color))							
			TXT_hex.text = (hexAndColor valueGive:newValue)
		)

		-- Buttons --
		-- on load
		on BTN_theLoad pressed do
		(
			updateRollout()
			free theBitmapTexture
			try (
				theLoadedImage = (dotNetClass "System.Drawing.Image").FromFile theFileLoad
				theBitmapTexture = openbitmap theFileLoad
				BIT_Preview.Image = theLoadedImage
				BIT_Preview.width = theBitmapTexture.width
				BIT_Preview.height = theBitmapTexture.height 
				BIT_Preview.pos = [(mainRolloutWidth/2-BIT_Preview.width/2),previewPos]
				SPN_xValue.range = [0,theBitmapTexture.width,SPN_xValue.value]
				SPN_yValue.range = [0,theBitmapTexture.height,SPN_yValue.value]
			)
			catch()
			updateRollout()
		)
		-- preview image can be used as template
		on BTN_thePreviewLoad pressed do
		(
			local theFileLoader = getOpenFileName caption:"Load preview:" \
			types:"PNG(*.png)|*.png|JPG(*.jpg*)|*.jpg*|All(*.*)|*.*|"
			if theFileLoader != undefined then 
			(
				theFileLoad = theFileLoader
				theDeterminer.BTN_theLoad.pressed()
			)
		)
		on BTN_grabViewport pressed do
		(
			if (doesFileExist theFolderLocation) then () else (makeDir theFolderLocation)
			theFileLoad = (getScreenGrabSafeFrame filenameLocation:theFolderLocation)
			if theFileLoad != undefined then theDeterminer.BTN_theLoad.pressed()
		)
		-- button to determin value 
		on BTN_theDeterminer pressed do
		(
			local leAdd = 0
			local theAdditiveAverage = #()
			local redOffest
			local greenOffset
			local blueOffset
			local colorAdjust = CLR_theDesired.color
			-- adjust and render
			(adjustObject newColor:colorAdjust)
				
			-- render with random name
			theLocation = fileToUse()
			(theRenderFunction indexFile:theLocation loadIndex:theLocation)
			theFileLoad = theLocation
			theDeterminer.BTN_theLoad.pressed()
			
			append theAdditiveAverage colorAdjust	
			
			--update progressBar
			try ((defineProgressBar parts:theParts)) catch()
			-- loop overPasses
			for passes = 1 to SPN_passCout.value-1 do
			(
				if not (keyboard.escPressed) and not wasCancelled then 
				(
					theDeterminer.BTN_theHiddenUpdate.pressed()
					--treshhold = 10
					-- get the offsets
					if not CHK_useHSB.checked then (
						redOffest = (CLR_theDesired.color.red - ((filterstring (theData.TXT_curveRGB.text) ",")[1]) as integer)
						greenOffset = (CLR_theDesired.color.green  - ((filterstring (theData.TXT_curveRGB.text) ",")[2]) as integer)
						blueOffset = (CLR_theDesired.color.blue  - ((filterstring (theData.TXT_curveRGB.text) ",")[3]) as integer)
						
						colorAdjust = (color (colorAdjust.red + redOffest) (colorAdjust.green + greenOffset) (colorAdjust.blue + blueOffset))
						append theAdditiveAverage colorAdjust		
							
						-- adjust color
						(adjustObject newColor:colorAdjust)
						if dataTesting == true then (						
							print "#Checking..."
							print (theData.TXT_curveRGB.text)
							print (("Red:" + redOffest as string +",") + ("Green:" + greenOffset as string +",") + ("Blue:" +blueOffset as string))
							print colorAdjust
							print "------"
						)
					)
					else (
						stringFy = (convertHSBtoPSformat theColor:colorAdjust)
						
						hueOffset = CLR_theDesired.color.h + ((((filterstring stringFy ",")[1] as float - ((filterstring (theData.TXT_HSB.text) ",")[1]) as float)/360) * 255 as integer)
						satOffset = CLR_theDesired.color.s + ((((filterstring stringFy ",")[2] as float - ((filterstring (theData.TXT_HSB.text) ",")[2]) as float)/100) * 255 as integer)
						valueOffset = CLR_theDesired.color.v + ((((filterstring stringFy ",")[3] as float - ((filterstring (theData.TXT_HSB.text) ",")[3]) as float)/100) * 255 as integer)
						
						if hueOffset > 255.0 then hueOffset = 255
						if satOffset > 255.0 then satOffset = 255
						if valueOffset > 255.0 then valueOffset = 255
							
						-- adjust color	
						colorAdjust = (convertStringHSBtoColor theString:((hueOffset as string) + "," + (satOffset as string)+ "," + (valueOffset as string)) phShop:false)
						append theAdditiveAverage colorAdjust	
						
						(adjustObject newColor:colorAdjust)
						if dataTesting == true then (
							print "#Checking..."
							print (theData.TXT_HSB.text)
							print (("Hue:" + hueOffset as string +",") + ("Saturation:" + satOffset as string +",") + ("Brightness:" +valueOffset as string))
							print colorAdjust
							print "------"
						)
					)
				)
					
				-- render with random name
				theLocation = fileToUse()
				(theRenderFunction indexFile:theLocation loadIndex:theLocation)
				theFileLoad = theLocation
				theDeterminer.BTN_theLoad.pressed()
				
				--update progressBar
				try ((defineProgressBar parts:theParts)) catch()
			)
			-- determined now adjust interface
			if not CHK_useHSB.checked then 
			(
				colorAdjust = ((theAdditiveAverage[theAdditiveAverage.count] + theAdditiveAverage[theAdditiveAverage.count-1])/2)
				colorAdjust = color (capValue newColor:(colorAdjust.red)) (capValue newColor:(colorAdjust.green)) (capValue newColor:(colorAdjust.blue))
			)
			else 
			(
				colorAdjust = theAdditiveAverage[theAdditiveAverage.count]
				colorAdjust = color (capValue newColor:(colorAdjust.red)) (capValue newColor:(colorAdjust.green)) (capValue newColor:(colorAdjust.blue))
			)
				
			BIT_theValueInput.bitmap = (bitmap 50 20 color:colorAdjust)
			TXT_hexValueInput.text = (hexAndColor valueGive:colorAdjust)
			TXT_stringValueInput.text = (something redValue:colorAdjust.red greenValue:colorAdjust.green blueValue:colorAdjust.blue)
			
			local theStart = "Invalid"
			local readHSBstring = (filterstring (theData.TXT_HSB.text) ",")
			local desireHSBstring = (filterstring (theData.TXT_desiredHSB.text) ",")
			local readRGBstring = (filterstring (theData.TXT_curveRGB.text) ",")
			local tresHold = 4
			
			theSeparetor = "|"
			theRGBmissing = (((CLR_theDesired.color.red - readRGBstring[1] as float) as integer) as string)+ theSeparetor + \
									(((CLR_theDesired.color.green - readRGBstring[2] as float) as integer) as string ) + theSeparetor + \
									(((CLR_theDesired.color.blue - readRGBstring[3] as float) as integer) as string) + theSeparetor
									
			theHSBmissing = ((desireHSBstring[1] as integer - readHSBstring[1] as integer) as string) + theSeparetor + \
									((desireHSBstring[2] as integer - readHSBstring[2] as integer) as string) + theSeparetor + \
									((desireHSBstring[3] as integer - readHSBstring[3] as integer) as string) + theSeparetor
			if ((((filterString theHSBmissing theSeparetor)[1]) as integer) < tresHold) and ((((filterString theHSBmissing theSeparetor)[1]) as integer) > -tresHold) then theStart = "Valid"
			
			if (colorAdjust.s as integer) == 255 and (((colorAdjust.s as float)/255)*100 as integer) != (((filterString theHSBmissing theSeparetor)[1]) as integer) then theStart += "-SatMax"
			else if ((((filterString theHSBmissing theSeparetor)[2]) as integer) > tresHold) and ((((filterString theHSBmissing theSeparetor)[2]) as integer) > -tresHold) then theStart +=  "-SatOff"
			
			if (colorAdjust.v as integer) == 0 and (((colorAdjust.v as float)/255)*100 as integer) != (((filterString theHSBmissing theSeparetor)[1]) as integer) then theStart +=  "-BrightMin"
			else if ((((filterString theHSBmissing theSeparetor)[3]) as integer) > tresHold) and ((((filterString theHSBmissing theSeparetor)[3]) as integer) < -tresHold) then theStart += "-BrightOff"
			TXT_outMessage.text = theStart + "<>RGB:" + theRGBmissing + "<>HSB:" + theHSBmissing
		)
		-- rendering analysis
		on BTN_theRender pressed do
		(
			-- try to close any textures loaded
			try (theLoadedImage.Dispose()) catch()
			try (close theBitmapTexture) catch()
			try (close theFileLoad) catch()
			
			-- do location
			theLocation = fileToUse()
			(theRenderFunction indexFile:theLocation loadIndex:theLocation)
			theFileLoad = theLocation
			theDeterminer.BTN_theLoad.pressed()
		)
		on SPN_adjustGI changed theValue do
		(
			try (setUserProp (getNodeByName TXT_Selection.text) "VRay_GI_Multipier" theValue) catch()
		)
		on BTN_adjustColor pressed do
		(
			local theValue = 1.0
			try (
				TXT_Selection.text = $.name
				TXT_Selection.tooltip = $.name
				try (
					theValue = (getUserProp (getNodeByName TXT_Selection.text) "VRay_GI_Multipier")
					if theValue == undefined then (
						setUSerPropBuffer (getNodeByName TXT_Selection.text) "VRay_GI_Multipier = 1.000000"
						theValue = (getUserProp (getNodeByName TXT_Selection.text) "VRay_GI_Multipier")
					)					
					SPN_adjustGI.value = theValue
					SPN_adjustGI.enabled = true
				) catch (SPN_adjustGI.value = 1.0)
			)
			catch (messageBox "Select something first" beep:false)
		)
		--well updateRollout function is inside rollout, created hidden button to pressed from other rollouts. bcuz lazy
		on BTN_theHiddenUpdate pressed do
		(
			updateRollout()
		)
		-- Text --
		--hexDesired
		on TXT_hex entered newValue do
		(
			try (
				if newValue.count == 7 then (
					newValue = (substring newValue 1 newValue.count)
					CLR_theDesired.color = (color ((hexAndColor valueGive:newValue)[1]) ((hexAndColor valueGive:newValue)[2]) ((hexAndColor valueGive:newValue)[3]))
					theData.TXT_desiredRGB.text = (hexAndColor valueGive:newValue)[1] as string + "," + (hexAndColor valueGive:newValue)[2] as string + "," + (hexAndColor valueGive:newValue)[3] as string
				)
				else if newValue.count == 6 then (
					CLR_theDesired.color = color ((hexAndColor valueGive:newValue)[1]) ((hexAndColor valueGive:newValue)[2]) ((hexAndColor valueGive:newValue)[3])
					theData.TXT_desiredRGB.text = (hexAndColor valueGive:newValue)[1] as string + "," + (hexAndColor valueGive:newValue)[2] as string + "," + (hexAndColor valueGive:newValue)[3] as string
					TXT_hex.text = "#" + newValue
				)
				else TXT_hex.text = "#invalid"
			)
			catch (TXT_hex.text = "#invalid")
		)
		
		-- checkBox
		on CHK_regionMode changed theState do
		(
			updateRollout()
		)
		
		-- Spinners --
		-- spinner for x coord
		on SPN_xValue changed theValue do
		(
			updateRollout()
		)
		-- spinner for y coord
		on SPN_yValue changed theValue do
		(
			updateRollout()
		)
		-- update rollout when region size changed
		on SPN_regionSize changed theValue do
		(
			updateRollout()
		)
		-- update progressBar pass
		on SPN_passCout changed theValue do
		(
			theParts = theValue
		)
		
		-- BIT_Preview --
		-- press on Mouse
		on BIT_Preview MouseDown arg do
		(
			_selected = true
			if _selected then (
				SPN_xValue.value = (((getColorLocation arg)[1]) * BIT_Preview.width) as integer
				SPN_yValue.value = (((getColorLocation arg)[2]) * BIT_Preview.height) as integer
				updateRollout()
			)
		)
		-- relase mouse
		on BIT_Preview MouseUp arg do
		(
			_selected = true
		)
		--on move do
		on BIT_Preview MouseMove arg do
		(
			if _selected then (
				SPN_xValue.value = (((getColorLocation arg)[1]) * BIT_Preview.width) as integer
				SPN_yValue.value = (((getColorLocation arg)[2]) * BIT_Preview.height) as integer
				updateRollout()
			)
			_selected = false
		)
		-- paint on
		on BIT_Preview Paint arg do
		(
			if not _selected then
			(
				local thePosition = dotNetObject "System.Drawing.Point" ((SPN_xValue.value)-SPN_regionSize.value/2) ((SPN_yValue.value)-SPN_regionSize.value/2)
				local theDraw = dotNetObject "System.Drawing.Bitmap" (createLocationIndicatorBitmap size:SPN_regionSize.value)
				arg.Graphics.DrawImage theDraw thePosition
			)
		)
		
		-- try to delete files from analysis
		fn tryCleanFolder =
		(
			for f in (getFiles (theFolderLocation + "\\" + "*" + extension)) do try (if (matchpattern (f as string) pattern:("*_index_*")) then deletefile f) catch()
		)
		-- rolloutOpen/Close 
		-- on open
		on theDeterminer open do
		(
			gc()
			initDialog()
		)
		-- on close
		on theDeterminer close do
		(
			try (theLoadedImage.Dispose())catch()
			try (close theBitmapTexture;free theBitmapTexture)catch()
			try (close theFileLoad;free theFileLoad)catch()
			gc()
			tryCleanFolder()
			if theMaterialsRoll.CKH_undoMats.checked then
			(
				undoMaterials()
			)
		)
	)
	
	-- add the rollouts
	try (addRollout theCurve theRollout) catch(messagebox "error: the curve rollout fail")
	try (addRollout theMaterialsRoll theRollout) catch(messagebox "error: the material and artwork rollout fail")
	
	try (addRollout theBatch theRollout) catch(messagebox "error: the batch rollout fail")
	try (addRollout theData theRollout) catch(messagebox "error: the data rollout fail")
	
	try (addRollout progressBarYolo theRollout) catch(messagebox "error: progressbar rollout fail")
	try (addRollout theDeterminer theRollout) catch(messagebox "error: the determiner rollout fail")

	try(
		theCurve.open = false
		theMaterialsRoll.open = true
		
		theBatch.open = false
		theData.open = false
		
		progressBarYolo.open = false
		theDeterminer.open =  true
	)
	catch()
)