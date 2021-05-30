(
	-- Created for INDG

	if psdInViewerPortMaster != undefined then (destroyDialog psdInViewerPortMaster) else (psdInViewerPortMaster = undefined)
	global psdInViewerPortMaster
	
	local theFileLoad = "\\\\nas\\GRIP\\Grip_batchTools\\Miscellaneous\\TheTexture.png"
	if not (doesFileExist theFileLoad) then theFileLoad = ""

	-- for nodes in nodes get them all
	fn getAllSceneNodes thePattern:"_artwork" =
	(
		theNodes = for geo in objects where matchpattern geo.name pattern:("*"+ thePattern +"*") collect geo
		return theNodes
	)
	-- make viewport textures visible
	fn makeViewportSexy =
	(
		viewport.SetShowEdgeFaces false
		displayColor.shaded = #material
		displaySafeFrames = true
		actionMan.executeAction 0 "63566"  -- Views: Default Shading
		actionMan.executeAction -844228238 "13"  -- Viewport Lighting and Shadows: Standard
	)
	-- backface cull on all .base objects GRIP related
	fn backfaceCulling actived:true =
	(
		for geo in geometry where (matchpattern geo.name pattern:"*.Base") and (matchpattern geo.layer.name pattern:"*_LS_*") do geo.backfaceCull  = actived
	)
	-- loadSpecial material (backs itself up, recovers itself based activate), crops for too
	fn loadSpecialMat geoMeshLoad: theLabel: activated: cropForGrip:true =
	(
		--if activated == unsupplied then activated = false
		if theLabel != unsupplied and geoMeshLoad != unsupplied then 
		(
			print activated
			if activated == true then 
			(
				local cutValue
				local labelBitmap
				local labelOpacity
				
				if cropForGrip then cutValue = 0.5 else cutValue = 0.0
					
				labelBitmap = (bitmapTexture name:"previewLabel" filename:theLabel clipw:cutValue cliph:cutValue apply:cropForGrip cropPlace:0)
				if cropForGrip then (
					labelOpacity = (bitmapTexture name:"previewLabelOpacity" filename:theLabel clipu:cutValue clipw:cutValue cliph:cutValue apply:cropForGrip cropPlace:0))
				else (labelOpacity = VrayColor color:[255,255,255])
					
				local previewMaterial = VrayMtl name:"previewMat" texmap_diffuse:labelBitmap texmap_opacity:labelOpacity
				local specialMaterial = Blend name:"theBlender"
				previewMaterial.ShowInViewport = true
				for geo in geoMeshLoad where (matchpattern (geo.name) pattern:("_artwork*")) and \
					(getNodeByName (geo.name)).mat.name != "theBlender" do (
						local theLocalGeo = (getNodeByName (geo.name))
						localMaterial = theLocalGeo.mat
						theLocalGeo.mat = specialMaterial
						theLocalGeo.mat.ShowInViewport = true
						theLocalGeo.mat.map1 = previewMaterial
						theLocalGeo.mat.map2 = localMaterial
						theLocalGeo.xray = false
					)
			)
			else if activated == false then
			(
				for geo in geoMeshLoad where (matchpattern (geo.name) pattern:("_artwork*")) do (
					if (getNodeByName (geo.name)).mat.name == "theBlender" then
					(
						local theLocalGeo = (getNodeByName (geo.name))
							
						theLocalGeo.mat = theLocalGeo.mat.map2
						localMaterial = theLocalGeo.mat
					)
				)
			)
			redrawViews() 
		)
	)
	-- initiliez
	fn __init__ =
	(
		-- will disable 
		loadSpecialMat geoMeshLoad:(getAllSceneNodes()) theLabel:("") activated:false
		redrawViews() 
	)
	
	-- register and unregister callbacks when max open
	fn registerCallbacks theEventsArray:#(#filePostOpen) theIdName:#PSDxAndImageMode =
	(
		callbacks.removeScripts id:theIdName
		for theEvent in theEventsArray do (
			callbacks.addScript theEvent ("for rollouts in psdInViewerPortMaster.theRollout1.rollouts where ( \
					rollouts.name == \"psdInViewerPort\") do (rollouts.MTL_mainScene.items = #(MaxFilePath); \
					rollouts.BTN_hiddenClose.pressed() \
					)") id:theIdName
		)
	)
	fn unregisterCallbacks theIdName:#PSDxAndImageMode =
	(
		callbacks.removeScripts id:theIdName
	)
	__init__()
	registerCallbacks()
	
	-- to hold rollout
	rollout psdInViewerPortMaster "theMaster -" 
	(
		subRollout theRollout1 width:400 height:200
	)
	-- the rollout
	rollout psdInViewerPort "PSD/PNG?Image- Loader - trial edition - v.qt(3.1415)"
	(
		button BTN_hiddenClose width:0 height:0
		multilistbox MTL_mainScene "workScene" items:#(MaxFilePath) height:1 width:375 enabled:true
		multilistbox MTL_fileLocation "theFile" items:#(theFileLoad) height:1 width:375 enabled:true

		checkbox CHK_active "Active" enabled:false across:3 align:#center
		checkbox CHK_cropGripArtwork "Crop Artwork for GRIP" checked:false offset:[10,0]
		button BTN_helpLoad "help" width:40 height:20 align:#right offset:[-12,-2]
		
		button BTN_goActive "Activate" width:120 height:40 across:2 offset:[-17,0]
		button BTN_loadFile "LoadFile" width:200 height:40 offset:[-17,0]
		
		-- activate on and off
		on BTN_goActive pressed do
		(
			CHK_active.checked = not CHK_active.checked
			if CHK_active.checked then BTN_goActive.text = "Dezactivate" else BTN_goActive.text = "Activate"
			makeViewportSexy()
			backfaceCulling()
			loadSpecialMat geoMeshLoad:(getAllSceneNodes()) theLabel:theFileLoad activated:(CHK_active.checked) cropForGrip:(CHK_cropGripArtwork.checked)
			redrawViews() 
		)
		-- load button
		on BTN_loadFile pressed do
		(
			theFileLoad = getOpenFileName caption:"Load artwork:" filename:(maxFilePath) \
			types:"PSD(*.psd)|*.psd|PNG(*.png)|*.png|JPG(*.jpg*)|*.jpg*|All(*.*)|*.*|"
			if theFileLoad != undefined then (
				local theFileLoadReduce = (filterstring theFileLoad "\\")[(filterstring theFileLoad "\\").count]
				BTN_loadFile.text = theFileLoadReduce
				MTL_fileLocation.items = #(theFileLoad)
				MTL_fileLocation.tooltip = theFileLoad
				
				if CHK_active.checked then (
					loadedNodes = (getAllSceneNodes())
					loadSpecialMat geoMeshLoad:loadedNodes theLabel:theFileLoad activated:false
					loadSpecialMat geoMeshLoad:loadedNodes theLabel:theFileLoad activated:true cropForGrip:CHK_cropGripArtwork.checked
				)
			)
			if theFileLoad == undefined then theFileLoad = MTL_fileLocation.items[1]
		)
		-- crop mode
		on CHK_cropGripArtwork changed theState do
		(
			if CHK_active.checked then
			(
				loadedNodes = (getAllSceneNodes())
				loadSpecialMat geoMeshLoad:loadedNodes theLabel:theFileLoad activated:false
				loadSpecialMat geoMeshLoad:loadedNodes theLabel:theFileLoad activated:true cropForGrip:theState
			)
		)
		-- go to locations
		on MTL_mainScene doubleclicked val do
		(
			try (shellLaunch "explorer.exe" ("\"" + MTL_mainScene.items[val] + "\""))
			catch(messagebox "file missing")
			MTL_mainScene.selection = #()
		)
		on MTL_fileLocation doubleclicked val do
		(
			try (
				theLocation = MTL_fileLocation.items[val]
				shellLaunch "explorer.exe" ("\"" + (substring theLocation \
					1 (theLocation.count - ((filterstring theLocation "\\")[(filterstring theLocation "\\").count]).count)) + "\"")
				)
			catch(messagebox "file missing")
			MTL_fileLocation.selection = #()
		)
		on BTN_hiddenClose pressed do
		(
			if CHK_active.checked then (
				BTN_goActive.pressed()
			)
		)
		-- help pdf documentation
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" +"\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\thePsdMode\\psdMode.pdf" + "\""))
			catch(messagebox "file missing")
		)
		-- when close, clean
		on psdInViewerPort close do
		(
			__init__()
			unregisterCallbacks()
		)
	)
	
	--createDialog psdInViewerPort width:400 height:160 --style:#(#style_titlebar) --style_sysmenu
	createDialog psdInViewerPortMaster width:425 height:200
	addSubrollout psdInViewerPortMaster.theRollout1  psdInViewerPort
) 