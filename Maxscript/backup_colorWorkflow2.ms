(
	-- Created for INDG
	/*
	some much needed globals, sadly some parts of the code requires these globals to set, I've tried to worked around them
	but they are also made undefined when the tool loads and should be like pseudo clean each time it starts
	*/ 
	global theNewFloater
	global colorWorkFlow
	global invertBlendEmpty
	local theCurrentScene = (maxFilePath + maxFileName)
	try (if theNewFloater != undefined then (closeRolloutFloater theNewFloater;theNewFloater = undefined)) catch (theNewFloater = undefined)
	if colorWorkFlow != undefined then colorWorkFlow = undefined
	if invertBlendEmpty != undefined then invertBlendEmpty = undefined
	local theNoArtworkLocation = "00000 - forToolCheckColor-2k-art.png"
	local localMaxPath = maxFilePath
	local localMaxName = maxFileName
	local ignoreMessage = false
	local executionCount = 0
	/*
	functions for colorwork flow
	neet stuff basically
	*/
	-- get date
	fn getSecondsOfLife =
	(
		try (
			local fileLolocation = (getFiles (maxFilePath + maxFileName))[1]
			local totalSecondsObjects = "not a File"
			local fileName = (filterString ((filterstring fileLolocation "\\")[(filterstring fileLolocation "\\").count]) ".")
			local extension = (substring ((filterstring fileLolocation "\\")[(filterstring fileLolocation "\\").count]) (fileName[1].count+1) fileLolocation.count)
			if fileLolocation != undefined and fileLolocation != unsupplied and (doesFileExist fileLolocation) and extension[1] == "." then (
				local modifiedDate = (getFileModDate fileLolocation)
				local extraValue = 0
				local month = (filterstring (filterString modifiedDate " ")[1] "/")[1]
				local day = (filterstring (filterString modifiedDate " ")[1] "/")[2]
				local year = (filterstring (filterString modifiedDate " ")[1] "/")[3]
				local hours = (filterstring (filterString modifiedDate " ")[2] ":")[1]
				local minute = (filterstring (filterString modifiedDate " ")[2] ":")[2]
				local seconds =  (filterstring (filterString modifiedDate " ")[2] ":")[3]
				if (filterString modifiedDate " ")[3] == "PM" then extraValue = 43200
				local totalSecondsInDay =  (((hours as integer) * 60 * 60) + ((minute as integer) * 60) + extraValue) 
				local monthTotalDays = 0
				local monthDays = 0
				for i = 1 to (month as integer)-1 do (
					monthDays = 0
					if (i == 1) or (i == 3) or (i == 5) or (i == 7) or (i == 8) or (i == 10) or (i == 12) then (monthDays = 31)
					else if (i == 2) then (if ((mod (year as integer) 4) == 0.0) then (monthDays = 29) else (monthDays = 28))
					else if (i == 4) or (i == 6) or (i == 9) or (i == 11) then (monthDays = 30)
					monthTotalDays += monthDays
				)
				local baseYear = 2018
				local addSecondsYears = (((year as integer) - baseYear) * 31536000)
				totalSecondsObjects =  (((monthTotalDays + (day as integer))*24*60*60) + totalSecondsInDay + addSecondsYears)
			)
		)
		catch (totalSecondsObjects = 0)
		return totalSecondsObjects
	)
	local getFileCurrentDate = getSecondsOfLife()
	-- function for Nodes
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
				/*
				for albedoColor in (getClassInstances VrayColor) where albedoColor.name =="Albedo" do (
					for i = 1 to (refs.dependents albedoColor).count where (classOf (refs.dependents albedoColor)[i]) == Editable_mesh and \
							geo == (refs.dependents albedoColor)[i] do theLoader.geoIfEmpty = "notDead"
				)
				*/
				try (
					if (geo.mat.map1.name) == "Empty" and (geo.mat.map1 == VrayBlendMtl) then (theLoader.geoIfEmpty = true) else (theLoader.geoIfEmpty = false)
					) 
				catch (
					for albedoColor in (getClassInstances VrayColor) where albedoColor.name =="Albedo" do (
						try (for i = 1 to (refs.dependents albedoColor).count where ((classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
							(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject) and \
							geo == (refs.dependents albedoColor)[i] do theLoader.geoIfmpty = "notDead" 
							)
						catch (theLoader.geoIfEmpty = "dead")
					)
				)
				try (if (matchpattern geo.mat.name pattern:("art@*")) then (theLoader.geoIfArt = true) else (theLoader.geoIfArt = false)) catch (theLoader.geoIfArt = false)
				appendIfUnique nodeListLoader theLoader
			)
		return nodeListLoader
	)
	-- remove add gamma 2.2
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
	fn loadSpecialMat geoMeshLoad: theLabel: activated: =
	(
		--if activated == unsupplied then activated = false
		if theLabel != unsupplied and geoMeshLoad != unsupplied then 
		(
			if activated == true then 
			(
				local labelBitmap = bitmapTexture name:"previewLabel" filename:theLabel clipw:0.5 cliph:0.5 apply:true cropPlace:0
				local labelOpacity = bitmapTexture name:"previewLabelOpacity" filename:theLabel clipu:0.5 clipw:0.5 cliph:0.5 apply:true cropPlace:0
				local previewMaterial = VrayMtl name:"previewMat" texmap_diffuse:labelBitmap texmap_opacity:labelOpacity
				local specialMaterial = Blend name:"theBlender"
				previewMaterial.ShowInViewport = true
				for geo in geoMeshLoad where (matchpattern (geo.geoLoad.name) pattern:("_artwork*")) do (
					if (getNodeByName (geo.geoLoad.name)).mat.name != "theBlender" then
					(
						localMaterial = (getNodeByName (geo.geoLoad.name)).mat
						(getNodeByName (geo.geoLoad.name)).mat = specialMaterial
						(getNodeByName (geo.geoLoad.name)).mat.ShowInViewport = true
						(getNodeByName (geo.geoLoad.name)).mat.map1 = previewMaterial
						(getNodeByName (geo.geoLoad.name)).mat.map2 = localMaterial
						(getNodeByName (geo.geoLoad.name)).xray = false
					)
				)
			)
			else if activated == false then
			(
				for geo in geoMeshLoad where (matchpattern (geo.geoLoad.name) pattern:("_artwork*")) do (
					if (getNodeByName (geo.geoLoad.name)).mat.name == "theBlender" then
					(
						(getNodeByName (geo.geoLoad.name)).mat = (getNodeByName (geo.geoLoad.name)).mat.map2
						localMaterial = (getNodeByName (geo.geoLoad.name)).mat
					)
				)
			)
		)
	)
	/*
	the color editor rollout
	has cool features that I enjoy
	*/
	rollout colorWorkflow "colorEditor - trial edition - v.qt(3.1415)"
	(
		edittext BTB_theItem "loaded" readOnly:true
		checkbox CHK_update "autoUpdate" checked:false offset:[-5,5] across:3
		button BTB_loadItem "workOn" width:82 height:30
		button BTB_updateItem "UpdateColor" width:82 height:30
		
		group "Color"
		(
			Colorpicker PCK_color "color:" color:[0,0,0] modal:false across:4 offset:[-5,-2]
			spinner SPN_red "red:" align:#left width:65 type:#integer range:[0,255,0] 
			spinner SPN_green "green:" align:#left width:75 type:#integer range:[0,255,0] 
			spinner SPN_blue "blue:" align:#left type:#integer width:65 range:[0,255,0] offset:[10,0]
			
			label LBL_empty1 "" across:4
			spinner SPN_hue "   H:" align:#left width:65 type:#integer range:[0,359,0] 
			spinner SPN_saturation "       S:" align:#left width:75 type:#integer range:[0,100,0] 
			spinner SPN_lightness "     L:" align:#left type:#integer width:65 range:[0,100,0] offset:[10,0]
			
			checkbox CHK_liniar "unlock liniar" checked:false offset:[0,0] across:2
			--checkbox CHK_phHSL "use PH HSL" checked:false offset:[0,0] enabled:false

			Colorpicker PCK_colorGamma "liniar input:" color:[0,0,0] modal:false enabled:false offset:[-10,-2]
			--Colorpicker PCK_inverseAlbedo "inverse Albedo:" color:[0,0,0] modal:false enabled:false offset:[-20,-2] width:100
		)
		
		group "Sliders"
		(
			slider SLD_red "red" range:[0,255,0] type:#integer ticks:4 tooltip:"Change the red Value" across:3 orient:#vertical
			slider SLD_green "green" range:[0,255,0] type:#integer ticks:4 tooltip:"Change the green Value" orient:#vertical
			slider SLD_blue "blue" range:[0,255,0] type:#integer ticks:4 tooltip:"Change the blue Value" orient:#vertical
		)
		
		group "Data"
		(
			bitmap BIT_BitmapColor "theColor" bitmap:(bitmap 200 50 color:(color 0 0 0))
			edittext TXT_hex "HEX:" text:"#000000" across:3 width:90
			checkbox CHK_addSpecial "[RGB]" checked:off offset:[10,0]
			edittext TXT_stringRGB "RGB:" text:"0,0,0" width:110 offset:[-25,0] readOnly:true
		)
		-- adjust the albedo function
		fn adjustObject newColor: =
		(
			theGamma = 1.0
			gammaAdjust = (color (convertToGamma enterValue:newColor.red gamma:theGamma) \
				(convertToGamma enterValue:newColor.green gamma:theGamma) \
				(convertToGamma enterValue:newColor.blue gamma:theGamma))
			local inversAdjust = (color (255 - newColor.red as integer) (255 - newColor.green as integer) (255 - newColor.blue as integer))
			try (
				for albedoColor in (getClassInstances VrayColor) where albedoColor.name =="Albedo" do (
					for i = 1 to (refs.dependents albedoColor).count where (classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
					(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject and \
						(getNodeByName BTB_theItem.text) == (refs.dependents albedoColor)[i] do albedoColor.color = gammaAdjust)
			)
			catch()
			try (
				for inversAlbedoColor in (getClassInstances VrayColor) where inversAlbedoColor.name =="InverseAlbedo" do (
					for i = 1 to (refs.dependents inversAlbedoColor).count where (classOf (refs.dependents inversAlbedoColor)[i]) == Editable_mesh or \
					(classOf (refs.dependents inversAlbedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject and \
						(getNodeByName BTB_theItem.text) == (refs.dependents inversAlbedoColor)[i] do inversAlbedoColor.color = inversAdjust)
				)
			catch()
		)
		
		-- function to change stuff
		fn interfanceChange redValue: greenValue: blueValue: theValue: changeColor: changeInputGamma: doHue:true doSat:true doLight:true =
		(
			-- prevents changes to color if the colorpicker is used (pervents value bugging out)
			if changeColor == unsupplied then changeColor = true
			if changeInputGamma == unsupplied then changeInputGamma = true
			-- logic tests
			if (classOf theValue) == Array then theValue = (color theValue[1] theValue[2] theValue[3])
			if (classOf theValue) == string and theValue.count == 7 then (
				theValue = (color (hexAndColor valueGive:theValue)[1] (hexAndColor valueGive:theValue)[2] (hexAndColor valueGive:theValue)[3])
			)
			-- red,green,blue gloc
			if redValue == unsupplied and (classOf theValue) == Color then redValue = theValue.red
			if greenValue == unsupplied and (classOf theValue) == Color then greenValue = theValue.green
			if blueValue == unsupplied and (classOf theValue) == Color then blueValue = theValue.blue
			
			if redValue != unsupplied then redValue = redValue else redValue = PCK_color.color.red
			if greenValue != unsupplied then greenValue = greenValue else greenValue = PCK_color.color.green
			if blueValue != unsupplied then blueValue = blueValue else blueValue = PCK_color.color.blue
				
			-- capping like a boss	
			if redValue < 0 then redValue = 0
			else if redValue > 255 then redValue = 255
			if greenValue < 0 then greenValue = 0
			else if greenValue > 255 then greenValue = 255
			if blueValue < 0 then blueValue = 0
			else if blueValue > 255 then blueValue = 255
				
			-- if specialCharcter is on
			local specialFront = ""
			local specialBack = ""
			if CHK_addSpecial.checked then (specialFront = "[";specialBack= "]")
			-- spinners 
			SPN_red.value = redValue
			SPN_green.value = greenValue
			SPN_blue.value = blueValue
			-- sliders
			SLD_red.value = redValue
			SLD_green.value = greenValue
			SLD_blue.value = blueValue
			
			local reValue = (color redValue greenValue blueValue)
			if changeColor == true then PCK_color.color = reValue
			-- change colorSlot without gamma
			local gammaOne = (color (convertToGamma enterValue:redValue gamma:1.0) \
				(convertToGamma enterValue:greenValue gamma:1.0) \
				(convertToGamma enterValue:blueValue gamma:1.0))
			if changeInputGamma == true and CHK_liniar.checked == true then PCK_colorGamma.color = gammaOne
			BIT_BitmapColor.bitmap = (bitmap 200 50 color:reValue)
			-- strings convert hex and RGb string
			TXT_hex.text = (hexAndColor valueGive:reValue)
			TXT_stringRGB.text = specialFront + ((redValue as integer) as string) + "," + ((greenValue as integer) as string) + "," + ((blueValue as integer) as string) + specialBack
			if BTB_theItem.text != "" and CHK_update.checked then (
				adjustObject newColor:reValue
			)
			if doHue then SPN_hue.value = (if (reValue.h/255 * 360) == 360 then (359) else (reValue.h/255 * 360))
			if doSat then SPN_saturation.value = (reValue.s/255 * 100)
			if doLight then SPN_lightness.value = (reValue.v/255 * 100)
		)
		on SPN_hue changed newValue do
		(
			if SPN_hue.value <= 0 then thenValue = 359
			else if SPN_hue.value >= 359 then thenValue = 0 
			else thenValue = newValue
			interfanceChange theValue:(PCK_color.color.hue = thenValue/360 as float *255) --doHue:false
		)
		
		on SPN_saturation changed newValue do
		(
			interfanceChange theValue:(PCK_color.color.s = newValue/100 as float *255) --doSat:false
		)
		
		on SPN_lightness changed newValue do
		(
			interfanceChange theValue:(PCK_color.color.v = newValue/100 as float *255) --doLight:false
		)
		
		on BTB_updateItem pressed do
		(
			if BTB_theItem.text != "" then (
				adjustObject newColor:(PCK_color.color)
			)
		)
		-- colorPicker
		on PCK_color changed newValue do 
		(
			interfanceChange theValue:newValue changeColor:false
		)
		on CHK_liniar changed theState do
		(
			PCK_colorGamma.enabled = theState
			if theState == true then (interfanceChange theValue:PCK_color.color) else PCK_colorGamma.color = (color 0 0 0)
		)
		on PCK_colorGamma changed newValue do
		(
			gammaAdjust = (color (convertToGamma enterValue:newValue.red gamma:2.2) \
				(convertToGamma enterValue:newValue.green gamma:2.2) \
				(convertToGamma enterValue:newValue.blue gamma:2.2))
			interfanceChange theValue:gammaAdjust changeInputGamma:false
		)
		-- spinners, red, green, blue
		on SPN_red changed newValue do
		(
			interfanceChange redValue:newValue
		)
		on SPN_green changed newValue do
		(
			interfanceChange greenValue:newValue
		)
		on SPN_blue changed newValue do
		(
			interfanceChange blueValue:newValue
		)
		
		-- changeText
		on TXT_hex entered newValue do
		(
			try (
				if newValue.count == 7 then interfanceChange theValue:newValue
				else if newValue.count == 6 then (
					newValue = "#" + newValue 
					interfanceChange theValue:newValue
				)
				else TXT_hex.text = "#invalid"
			)
			catch (TXT_hex.text = "#invalid")
		)
		
		-- specialAdd
		on CHK_addSpecial changed theState do
		(
			interfanceChange theValue:PCK_color.color
		)
		
		-- sliders red,green,blue
		on SLD_red changed newValue do 
		(
			interfanceChange redValue:newValue
		)
		on SLD_green changed newValue do 
		(
			interfanceChange greenValue:newValue
		)
		on SLD_blue changed newValue do 
		(
			interfanceChange blueValue:newValue
		)
		-- load item button, to work upon
		on BTB_loadItem pressed do
		(
			local inputValue
			for albedoColor in (getClassInstances VrayColor) where albedoColor.name == "Albedo" do (
			for i = 1 to (refs.dependents albedoColor).count where ((classOf (refs.dependents albedoColor)[i]) == Editable_mesh or \
				(classOf (refs.dependents albedoColor)[i]) == Editable_poly or (classOf (refs.dependents albedoColor)[i]) == PolyMeshObject) and \
					$ == (refs.dependents albedoColor)[i] do inputValue = albedoColor.color)
			if inputValue != undefined then (
				BTB_theItem.text = $.name
				theGamma = 2.2
				gammaAdjust = (color (convertToGamma enterValue:inputValue.red gamma:theGamma) \
						(convertToGamma enterValue:inputValue.green gamma:theGamma) \
						(convertToGamma enterValue:inputValue.blue gamma:theGamma))
				interfanceChange theValue:gammaAdjust
			)
			else (messageBox "Invalid object")
		)
	)
	/*
	for sexiness a rollout which only contains the bitmap of the artwork used, this can be turned off or on via a checkbox
	could add other features
	*/
	rollout theBitmanPreview "artwork preview - trial edition v.qt(3.14.15)"
	(
		dotNetControl BIT_Preview "System.Windows.Forms.PictureBox" width:200 height:200 pos:[40, 10]
	)
	rollout mapPreviewTool "mapTool preview - trial edition v.qt(3.14.15)"
	(
		edittext TXT_filename "FileName:" text:"Load one" readOnly:true across:2
		button BTN_OverrideFile "Load File"
		edittext TXT_mapsInfo "Preview mode:" text:"false" readOnly:true across:2
		button BTN_showMaps "ShowMaps Special"
		
		-- showMaps
		on BTN_showMaps pressed do
		(
			if TXT_mapsInfo.text == "false" then 
			(
				if TXT_filename.tooltip != undefined then 
				(
					TXT_mapsInfo.text = "true"
					loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:TXT_filename.tooltip activated:true
					viewport.SetShowEdgeFaces false
					displayColor.shaded = #material
					displaySafeFrames = true
					actionMan.executeAction 0 "63566"  -- Views: Default Shading
					actionMan.executeAction -844228238 "13"  -- Viewport Lighting and Shadows: Standard
					--(maxops.getViewportShadingSettings()).ActivateViewportShading.ShadingQuality = #Stadard
				)
			)
			else (
				TXT_mapsInfo.text = "false"
				loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:theTestLabel activated:false
			)
		)
		
		-- ovreride
		on BTN_OverrideFile pressed do
		(
			local theFileLoad = getOpenFileName caption:"Load artwork:" filename:(maxFilePath) \
			types:"PNG(*.png)|*.png|JPG(*.jpg*)|*.jpg*|All(*.*)|*.*|"
			if theFileLoad != undefined then (
				local theFileLoadReduce = (filterstring theFileLoad "\\")[(filterstring theFileLoad "\\").count]
				TXT_filename.text = theFileLoadReduce
				TXT_filename.tooltip = theFileLoad
			)
		)
	)
	
	-- inverBlendsEmtpy if they exist (well tries too, may add other features)
	fn invertBlendEmpty geoMeshLoad: opacity: =
	(
		local valueColor = (color 0 0 0)
		if opacity == unsupplied then opacity = false
		if opacity == true then valueColor = (color 255 255 255)
		if geoMeshLoad != unsupplied then 
		(
			try(
				if (geoMeshLoad.mat.map1.name == "Empty" or geoMeshLoad.mat.map2.name == "Empty") and (matchpattern geoMeshLoad.mat.name pattern:("art@*")) do (
					if valueColor == (color 0 0 0) then (
						materialOne = geoMeshLoad.mat.map1
						materialTwo = geoMeshLoad.mat.map2
						geoMeshLoad.mat.map1 = materialTwo
						geoMeshLoad.mat.map2 = materialOne
					)
					else (
						materialOne = geoMeshLoad.mat.map1
						materialTwo = geoMeshLoad.mat.map2
						geoMeshLoad.mat.map1 = materialTwo
						geoMeshLoad.mat.map2 = materialOne
					)
				)
			)
			catch()
		)
	)
	-- create DynamicRollout dangerous !! but really nice
	fn createDynamicRollout nodeListLoad: =
	(
		theCodeBlock = undefined
		-- the codeBlock
		fn theCodeBlock varLoop: item: visiblity: hasArt: =
		(
			codeBlock = undefined
			local onStatus = "true"
			if item == unsupplied then item = varLoop
			if visiblity == unsupplied or visiblity == undefined then (visiblity = "false")
			if hasArt == unsupplied or  hasArt == undefined then (visiblity = "false")
			if visiblity == "dead" then ((onStatus = "false"); visiblity = "false")
			if visiblity == "notDead" then ((onStatus = "false"); visiblity = "true")
			local varLoop = varLoop as string
			local visiblity = visiblity as string
			local hasArt = hasArt as string
		
			local codeBlock = ("edittext TXT_load"+ varLoop +" \"part" + varLoop +"\"" + "text: \"" + item + "\" enabled:true offset:[-10,0] readOnly:true width:100 across:4" + "\n" + \
								"button BTN_select" + varLoop + "\"Select\" enabled:" + hasArt +" offset:[20,0]" + "\n" + \
								"checkbox CKH_isVis" + varLoop + "\" visible\" enabled:"+ onStatus +" checked:" + visiblity + " offset:[15,0]" + "\n" + \
								"checkbox CKH_hasArt" + varLoop + "\" hasArt\" enabled:false checked:" + hasArt +" offset:[15,0]" + "\n" + \
								"on BTN_select" + varLoop + " pressed do try ( ( select (getNodebyName (TXT_load" + varLoop + ".text)) ;colorWorkflow.BTB_loadItem.pressed() ) ) catch()" + "\n" + \
								"on CKH_isVis" + varLoop + " changed theStatus do (invertBlendEmpty geoMeshLoad:(getNodebyName (TXT_load" + varLoop + ".text)) opacity:theStatus)" + "\n"
								)
			return codeBlock
		)
		local complieCode = ""
		local theInverseCount = nodeListLoad.count
		for i = 1 to nodeListLoad.count do (
			if not (matchpattern nodeListLoad[theInverseCount].geoLoad.name pattern:"*artwork*") then
			(
				local theCode = (theCodeBlock \
					varLoop:theInverseCount \
					item:nodeListLoad[theInverseCount].geoLoad.name \
					visiblity:nodeListLoad[theInverseCount].geoIfEmpty \
					hasArt:nodeListLoad[theInverseCount].geoIfArt \
					colorWorkflow:colorWorkflow
					)
				complieCode = theCode += complieCode
			)
			theInverseCount = theInverseCount - 1
		)
		return complieCode
	)
	-- define the system check
	local theLoadedMaterials = undefined
	theLoadedMaterials = returnsNodesData()
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
		local appliedArt = for matCheck in theLoadedMaterials where (try(matchpattern matCheck.geoLoad.mat.name pattern:"art@*")catch(false)) collect matCheck
		if (failedMat.count == theLoadedMaterials.count) then sceneCheckLoader.failMatCheck = "Valid!" else  sceneCheckLoader.failMatCheck = "Invalid!"
		if (appliedArt.count != 0) then sceneCheckLoader.artworkCheck = "Applied!" else sceneCheckLoader.artworkCheck = "Not Applied"
		sceneCheckLoader.artworkBad = appliedArt.count
		sceneCheckLoader.artworkNameText = "Load one"
		return sceneCheckLoader
	)
	local theChecked = undefined
	theChecked = (theSystemsCheck theLoadedMaterials:theLoadedMaterials)
	local theNewFloater = newRolloutFloater "Editor -" 300 500
	local disableTestButtons = 0
	/*
	the main interface loader, where everything is being collected and loaded
	the main interface is also added to a floater rollout.
	*/
	rollout interfaceReloder "reloader - trial edition - v.qt(3.1415)"
	(
		timer executeInterval interval:1000
		button BTN_reload "test - loadAll - test" width:(disableTestButtons*2) height:disableTestButtons  -- button is hidden for testing, used for other things due to lazyness
		group "Status"
		(
			edittext BTB_artworkStatus "MaterialsStatus:" text:theChecked.failMatCheck readOnly:true
			edittext BTB_sceneStatus "ArtworkStatus:  " text:theChecked.artworkCheck readOnly:true
			edittext BTB_artworkName "ArtworkName:   " text:theChecked.artworkNameText readOnly:true
			
			checkbox CKH_undoMats "undoOnClose" checked:true offset:[0,0] across:2
			checkbox CKH_safeySave "safeySave" checked:true enabled:true offset:[0,0] 
		)
		group "Artwork"
		(
			--checkbox CKH_previewArtwork "previewArtwork" checked:false offset:[0,0] across:2
			--checkbox CKH_previewMapScreen "mapOnScreen" checked:false offset:[0,0] 
			
			button BTN_loadArtwork "loadArtwork" width:120 height:40 across:2 enabled:(theChecked.artworkBad == 0)
			button BTN_loadNoArtwork "loadBaseNoArtwork" width:120 height:40 enabled:(theChecked.artworkBad == 0)
		)
		group "Miscellaneous"
		(
			button BTN_onlyColorTool "onlyColorTool" width:120 height:40 across:2
			button BTN_undoMaterials "undoMaterials" width:120 height:40
			
			button BTN_PSDviewport "PSD/PNG viewport" width:120 height:20 align:#right offset:[-5,0] across:2
			button BTN_helpLoad "help" width:40 height:20 align:#right offset:[-5,0]
			button BTN_remove "remove" width:(disableTestButtons*2) height:disableTestButtons -- button is hidden for testing, used for other things due to lazyness
		)
		on BTN_PSDviewport pressed do 
		(
			try (filein "\\\\nas\\GRIP\\Grip_batchTools\\maxScript\\Others\\thePsdMode\\thePsdMode.ms")
			catch(messagebox "file missing")
		)
		
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" + "\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\colorWorkFlow\\Rollout reloder.pdf" + "\""))
			catch(messagebox "file missing")
		)
		--// for testing 
		-- button BTN_destoryTest "Kill" 
		on BTN_remove pressed do
		(
			for rollouts in theNewFloater.rollouts where rollouts.name != "interfaceReloder" do (removeRollout rollouts theNewFloater)
		)
		--// end testing
		-- updateThe Status when given data
		fn statusUpdate systemCheck: skipStatus: artworkName: =
		(
			if skipStatus == unsupplied then skipStatus = false
			if skipStatus == false then (BTB_artworkStatus.text = systemCheck.failMatCheck)
			BTB_sceneStatus.text = systemCheck.artworkCheck
			if artworkName != unsupplied then BTB_artworkName.text = artworkName
			if artworkName != unsupplied then BTB_artworkName.tooltip = artworkName
			if skipStatus == false then BTN_loadArtwork.enabled = (systemCheck.artworkBad == 0)
		)
		-- for testing
		on BTN_destoryTest pressed do
		(
			print colorWorkflow	
		)
		-- the undoButton
		on BTN_undoMaterials pressed do
		(
			try(
				for geo in theLoadedMaterials do (((getNodeByName (geo.geoLoad.name)).mat = geo.geoMat))
				if BTB_artworkStatus.text != "Invalid!" and BTB_sceneStatus.text != "Not Applied" then (
					(statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:theLoadedMaterials) skipStatus:false artworkName:"Load one")
				)
			)
			catch (
				messagebox "something was deleted, materials could not be restored"
				ignoreMessage = true
			)
		)
		-- loadArtwork and startInterface
		on BTN_loadArtwork pressed do
		(
			try (loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:theTestLabel activated:false)catch()
			
			interfaceReloder.BTN_undoMaterials.pressed()
			local theFileLoad = getOpenFileName caption:"Load artwork:" filename:(maxFilePath) \
			types:"PNG(*.png)|*.png|JPG(*.jpg*)|*.jpg*|All(*.*)|*.*|"
			if theFileLoad != undefined then (
				-- reduce name
				local theFileLoadReduce = (filterstring theFileLoad "\\")[(filterstring theFileLoad "\\").count]
				-- getNodes
				local nodesLoad = for nodez in theLoadedMaterials collect (getNodeByName(nodez.geoLoad.name))
				if PITCRendering != undefined then (
					-- load Artwork
					loadArtworkUsingGrip theFile:theFileLoad theNodes:nodesLoad
				) else (messagebox "try to open PITC studio first")
				-- update Status
				try ((statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:theLoadedMaterials) skipStatus:true artworkName:theFileLoadReduce)) catch()
				interfaceReloder.BTN_reload.pressed()
				try (
					if CKH_previewArtwork.checked == true then (
						theLoadedImage = (dotNetClass "System.Drawing.Image").FromFile theFileLoad
						theBitmanPreview.BIT_Preview.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").StretchImage
						theBitmanPreview.BIT_Preview.Image = theLoadedImage
					)
				)
				catch()
			)
			
			try (CKH_previewMapScreen.checked = false)catch()
		)
		-- loadArtwork and startInterface
		on BTN_loadNoArtwork pressed do
		(
			try (loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:theTestLabel activated:false)catch()
				
			local fileMissing = false
			interfaceReloder.BTN_undoMaterials.pressed()
			if theNoArtworkLocation != undefined then (
				-- reduce name
				local theFileLoadReduce = (filterstring theNoArtworkLocation "\\")[(filterstring theNoArtworkLocation "\\").count]
				-- getNodes
				local nodesLoad = for nodez in theLoadedMaterials collect (getNodeByName(nodez.geoLoad.name))
				if PITCRendering != undefined then (
					-- load Artwork
					try (loadArtworkUsingGrip theFile:theNoArtworkLocation theNodes:nodesLoad) catch (fileMissing = true)
				) else (messagebox "try to open PITC studio first")
				if fileMissing == false then (
					-- update Status
					try ((statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:theLoadedMaterials) skipStatus:true artworkName:theFileLoadReduce)) catch()
					interfaceReloder.BTN_reload.pressed()
					try (
						if CKH_previewArtwork.checked == true then (
							theLoadedImage = (dotNetClass "System.Drawing.Image").FromFile theFileLoad
							theBitmanPreview.BIT_Preview.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").StretchImage
							theBitmanPreview.BIT_Preview.Image = theLoadedImage
						)
					)
					catch()
				)
			)
			try (CKH_previewMapScreen.checked = false)catch()
		)
		-- only ColorTool
		on BTN_onlyColorTool pressed do
		(
			try (loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:theTestLabel activated:false)catch()
				
			interfaceReloder.BTN_remove.pressed()
			interfaceReloder.open  = false
			try (addRollout colorWorkflow theNewFloater) catch ()
				
			try (CKH_previewMapScreen.checked = false)catch()
		)
		-- shows artworkPreview
		on CKH_previewArtwork changed theState do
		(
			if theState == true then (
				try (addRollout theBitmanPreview theNewFloater)catch()
				) else (
				try ((removeRollout theBitmanPreview theNewFloater))catch()
			)
		)
		on CKH_previewMapScreen changed theState do
		(
			BTN_PSDviewport.pressed()
			CKH_previewMapScreen.checked = false
			/* -- disabled
			if theState == true then (
				try (addRollout mapPreviewTool theNewFloater)catch()
			) 
			else (
				try(if mapPreviewTool.TXT_mapsInfo.text == "true" then mapPreviewTool.BTN_showMaps.pressed())catch()
				try ((removeRollout mapPreviewTool theNewFloater))catch()
			)
			*/
		)
		on CKH_safeySave changed theState do
		(
			if theState == true then executionCount = 0 else executionCount = 3
		)
		-- reloadInterface
		on BTN_reload pressed do
		(
			-- clean interface
			interfaceReloder.BTN_remove.pressed()
			--interfaceReloder.open  = false
			local checkDynamic = false
			for rollouts in theNewFloater.rollouts where (rollouts.name == "materialLoader") do (checkDynamic = true)
			if checkDynamic == false then (
				try(
					theStringCode = (createDynamicRollout nodeListLoad:(returnsNodesData()))
					if theStringCode != undefined and theStringCode != "" then (execute ("rollout materialLoader \"execute - trial edition - v.qt(3.1415)\"("+ theStringCode +")" ))
					else (execute ("rollout materialLoader \"execute - trial edition - v.qt(3.1415)\"( )" ))
					)
				catch()
				)
			try (
				if CKH_previewArtwork.checked == true then (
				try (addRollout theBitmanPreview theNewFloater) catch()
				)
			) catch()
			try (addRollout materialLoader theNewFloater) catch ()
			try (addRollout colorWorkflow theNewFloater) catch ()
		) 
		on executeInterval tick do
		(
			if (localMaxPath == maxFilePath) and (getFileCurrentDate != getSecondsOfLife()) and executionCount < 2 then
			(
				getFileCurrentDate = getSecondsOfLife()
				localMaxName = maxFileName
				theCurrentScene = (maxFilePath + maxFileName)
				if BTB_artworkStatus.text != "Invalid!" and BTB_sceneStatus.text == "Applied!" then (
					try ((statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:returnsNodesData()) skipStatus:false artworkName:"Load one")) catch()
				)
				if BTB_sceneStatus.text == "Applied!" and CKH_safeySave.checked == true then (
					interfaceReloder.BTN_undoMaterials.pressed()
					saveMaxFile (maxFilePath + maxFileName) quite:true
					try ((statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:returnsNodesData()) skipStatus:false artworkName:"Load one")) catch()
					-- satefy count, should be 0 as soon mas max saves, should help if statement is looped too many times due to error or bug
					executionCount += 1
					messageBox "Do not save while artwork applied,\nmaterials restored and your save overwritten,\nthank you"
				)
				theLoadedMaterials = returnsNodesData()
				interfaceReloder.BTN_reload.pressed()
				interfaceReloder.BTN_remove.pressed()
			)
			else if (maxFilePath + maxFileName) != theCurrentScene then 
			(
				theCurrentScene = (maxFilePath + maxFileName)
				theLoadedMaterials = returnsNodesData()
				if BTB_artworkStatus.text != "Invalid!" then (
					try ((statusUpdate systemCheck:(theSystemsCheck theLoadedMaterials:theLoadedMaterials) skipStatus:false artworkName:"Load one")) catch()
				)
				interfaceReloder.BTN_reload.pressed()
				interfaceReloder.BTN_remove.pressed()
				executionCount = 0
			)
		)
		-- on close do
		on interfaceReloder close do
		(
			if BTB_artworkStatus.text != "Invalid!" and BTB_sceneStatus.text != "Not Applied" and CKH_undoMats.checked == true then (
				interfaceReloder.BTN_undoMaterials.pressed()
				if ignoreMessage == false then (
					messageBox "materials have been restored" beep:false
				)
			)
			try (loadSpecialMat geoMeshLoad:(returnsNodesData()) theLabel:theTestLabel activated:false)catch()
			if theNewFloater != undefined then theNewFloater = undefined
			if colorWorkFlow != undefined then colorWorkFlow = undefined
			if invertBlendEmpty != undefined then invertBlendEmpty = undefined
		)
	)
	addRollout interfaceReloder theNewFloater
)