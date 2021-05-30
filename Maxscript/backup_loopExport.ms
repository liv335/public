(
	-- Created for INDG

	fn doExport thelocation:undefined theFBXsave:undefined theOBJsave:undefined saveFBX:true saveOBJ:true doMaterials:true doModifiers:true retroArtwork:true keepColor:true embedTextures:true doCurrent:false =
	(
		-- clean vray blends, can cause error when export FBX
		fn cleanVrayBlends = 
		(
			try (
				for geo in geometry where (classOf (geo.mat) == VrayBlendMtl) and \
					(matchpattern geo.layer.name pattern:("*OBJ*")) and geo.mat.baseMtl != undefined do geo.mat = geo.mat.baseMtl
			)
			catch()
		)
		-- convert artworks found in naslocation/artworks into something usable
		fn doRetroArtwork =
		(
			-- findTheArtwork
			fn findArtwork =
			(
				local theArtwork = undefined
				for file in (getfiles (maxFilePath + "artworks\\artwork\\*")) where (matchpattern file pattern:("*" + ((filterString maxFilePath "\\")[(filterString maxFilePath "\\").count]) + "-art" + ".png")) \
					do if ((getFileSize file) as integer != 216839) then theArtwork = file
				return theArtwork
			)
			-- create diffuse and alpha
			fn createDiffuseAlpha theFileLoad:undefined =
			(
				local nameArray = #()
				if theFileLoad != undefined then (
					local theBitmapDiffuse
					local theBitmapAlpha
					local saveFolder = maxFilePath + "artworks\\artwork\\splitParts"
					local theBitmapTexture = openbitmap theFileLoad 
					
					if theBitmapTexture != undefined and (theBitmapTexture.height == theBitmapTexture.width) then
					(
						if (doesFileExist saveFolder) then () else makeDir (saveFolder)
						if (doesFileExist saveFolder) then (
							pngio.setAlpha false 
							
							theBitmapDiffuse = (bitmap (theBitmapTexture.height/2) (theBitmapTexture.height/2) \
								filename:(saveFolder + "\\" + (substring ((filterString maxFilePath "\\")[(filterString maxFilePath "\\").count]) 1 5) + "_diffuse.png"))
							(pasteBitmap theBitmapTexture theBitmapDiffuse (box2 0 0 (theBitmapTexture.height/2) (theBitmapTexture.height/2)) [0,0])
							
							theBitmapAlpha = (bitmap (theBitmapTexture.height/2) (theBitmapTexture.height/2) \
								filename:(saveFolder + "\\" + (substring ((filterString maxFilePath "\\")[(filterString maxFilePath "\\").count]) 1 5) + "_opacity.png"))
							(pasteBitmap theBitmapTexture theBitmapAlpha  (box2 (theBitmapTexture.height/2) 0 (theBitmapTexture.height/2) (theBitmapTexture.height/2)) [0,0])
							
							save theBitmapDiffuse
							save theBitmapAlpha	
						)
					)
					append nameArray theBitmapDiffuse.filename
					append nameArray theBitmapAlpha.filename
					
					free theBitmapTexture
					free theBitmapDiffuse
					free theBitmapAlpha
					return nameArray
				)
			)
			loadArtwork = findArtwork()
			if loadArtwork != undefined then 
			(
				local getTheSplitParts = (createDiffuseAlpha theFileLoad:loadArtwork)
				local labelBitmap = bitmapTexture name:"previewLabel" filename:(getTheSplitParts[1])
				local labelOpacity = bitmapTexture name:"previewOpacity" filename:(getTheSplitParts[2])
				local normalMaterial = VrayMtl name:"basic material" texmap_diffuse:labelBitmap texmap_opacity:labelOpacity
				for geo in geometry where (matchpattern geo.name pattern:("*artwork*")) do (
					geo.mat = normalMaterial
				)
			)
		)
		-- keepColorizableParts
		fn keepColorizableParts nodeTypesLoad: =
		(
			-- findTheArtwork
			fn findArtwork =
			(
				local theArtwork = undefined
				for file in (getfiles (maxFilePath + "artworks\\artwork\\*")) where (matchpattern file pattern:("*" + ((filterString maxFilePath "\\")[(filterString maxFilePath "\\").count]) + "-art" + ".png")) \
					do if ((getFileSize file) as integer != 216839) then theArtwork = file
				return theArtwork
			)
			loadArtwork = findArtwork()
			print (loadArtwork)
			if loadArtwork != undefined then 
			(
				local theBitmapTexture = openbitmap loadArtwork
				local localArrayColorizable = #()
				if theBitmapTexture != undefined then 
				(
					struct localColorizable 
					(
						nodeID,
						colorLocation
					)
					
					for nodes in nodeTypesLoad where nodes.id != "droplets" \
						and nodes.id != "uvartwork" and nodes.id != "artwork" and nodes.id != "artworkOverlay" do (
						print nodes
						keepColorizable = localColorizable()
						keepColorizable.nodeID = nodes.id
						keepColorizable.colorLocation = nodes.colorLocation
						append localArrayColorizable keepColorizable
					)
					if localArrayColorizable != 0 then 
					(
						for items in localArrayColorizable do (
							for geo in geometry where matchpattern geo.name pattern:("*" + items.nodeID + "*") do
							(
								print geo
								local colorInput = VrayColor name:"color_part" color:(color 255 255 255)
								try (colorInput = VrayColor name:"color_part" \
									color:((getPixels theBitmapTexture [((items.colorLocation)[1]/2)*theBitmapTexture.height,((items.colorLocation)[2]/2)*theBitmapTexture.height] 1)[1])
								) catch ()
								local normalMaterial = VrayMtl name:"basic material" texmap_diffuse:colorInput
								geo.mat = normalMaterial
							)
						)
					)
				)
			)
		)
		-- add another material
		fn cleanObjects =
		(
			local normalMaterial = VrayMtl name:"basic material"
			for geo in geometry where (matchpattern geo.layer.name pattern:("*OBJ*")) do (
				geo.mat = normalMaterial
				if geo.name[1] == "_" then geo.name = substring geo.name 2 (geo.name).count
			)
		)
		-- clean modifiers , turbosmooth, opensudiv if 1st/2nd
		fn cleanModifiers =
		(
			try (
				for geo in geometry where matchpattern geo.layer.name pattern:("*OBJ*") do (
					if (classOf geo.modifiers[1]) == TurboSmooth or (classOf geo.modifiers[1]) == OpenSubdiv then (
						geo.modifiers[1].enabled = false
					)
					else if (classOf geo.modifiers[1]) == Push and ((classOf geo.modifiers[2]) == TurboSmooth or (classOf geo.modifiers[2]) == OpenSubdiv) then (
						geo.modifiers[2].enabled = false
						)
				)
			)
			catch ()
		)
		-- remove all except OBJ
		fn removeNotOBJ = 
		(
			local deleteList = #()
			for geo in objects where not (matchpattern geo.layer.name pattern:("*OBJ*")) do append deleteList geo
			if deleteList.count != 0 then (
				try
				(
					select deleteList
					delete $
				)
				catch()
			)
		)
		-- delete empty layer
		fn deleteEmptyLayers =
		(
			for id = LayerManager.count - 1 to 1 by -1 do
			(
				local layer = LayerManager.getLayer id
				local containsNodes = LayerManager.doesLayerHierarchyContainNodes layer.name
				if not containsNodes then (local deleted = LayerManager.deleteLayerByName layer.name)
			)
		)
		-- clean maetrial editor
		fn cleanMaterialEditors =
		(
			macros.run "Medit Tools" "clear_medit_slots"
			sme.Open() 
			sme.Close() 
			try(
				for i = 0 to (sme.GetNumViews()-1) do (
					sme.DeleteView 1 false
				)
			)
			catch()
			AssetManager.RemoveMissingAssets()
		)
		-- remove render output
		fn removerenderout=
		(
			if rendOutputFilename != "" then rendOutputFilename = ""
			re = maxOps.GetCurRenderElementMgr()
			re.removeallrenderelements()
		)
		-- clean scene
		fn cleanSceneMiscelanious =
		(
			while z !=undefined do (
				x = rootscene
				z = custattributes.getdef x 1
				custAttributes.delete x z
			)
			local animLayerControlManager = trackViewNodes[#Anim_Layer_Control_Manager]
			if (animLayerControlManager != undefined) do (
				animLayerControlManager.animLayers.count = 0
			)
		)
		-- export FBX
		fn FBXExport theFBXsave: saveFile: exportTex:true =
		(
			--Geometry------------------------------------------------------------------------
			FBXExporterSetParam "SmoothingGroups" true
			FBXExporterSetParam "NormalsPerPoly" false
			FBXExporterSetParam "TangentSpaceExport" true
			FBXExporterSetParam "SmoothMeshExport" true
			FBXExporterSetParam "Preserveinstances" false
			FBXExporterSetParam "SelectionSetExport" false
			FBXExporterSetParam "GeomAsBone" false
			FBXExporterSetParam "ColladaTriangulate" true
			FBXExporterSetParam "PreserveEdgeOrientation" true
			--Animation------------------------------------------------------------------------
			FBXExporterSetParam "Animation" false
			--Cameras------------------------------------------------------------------------
			FBXExporterSetParam "Cameras" false
			--Lights------------------------------------------------------------------------
			FBXExporterSetParam "Lights" false
			--Embed Media--------------------------------------------------------------------
			FBXExporterSetParam "EmbedTextures" exportTex
			--Units----------------------------------------------------------------------------
			--Axis Conversion-----------------------------------------------------------------
			FBXExporterSetParam "AxisConversionMethod" "None"
			FBXExporterSetParam "UpAxis" "Y" 
			--UI----------------------------------------------------------------
			FBXExporterSetParam "ShowWarnings" true
			FBXExporterSetParam "GenerateLog" false
			--FBX File Format----------------------------------------------------------------
			FBXExporterSetParam "ASCII" true
			FBXExporterSetParam "FileVersion" "FBX201200"
			
			if (doesFileExist theFBXsave) then () else makeDir (theFBXsave)
			exportFile (saveFile+ ".fbx") #noPrompt selectedOnly:False using:FBXEXP 
		)
		-- export OBJ
		fn OBJExport theOBJsave: saveFile: =
		(
			if (doesFileExist theOBJsave) then () else makeDir (theOBJsave)
			exportFile (saveFile+ ".obj") #noPrompt 
		)
		-- find latest max 
		fn theLatestMax theLocalSearch: =
		(
			local dateList =#()
			local theLocalSearch = theLocalSearch + "\\"
			-- ExtraCrap
			struct dateFiles (
				Location,
				Date
			)
			
			fn getSecondsOfLife fileLolocation: =
			(
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
					local totalSecondsInDay =  (((hours as integer) * 60 * 60) + ((minute as integer) * 60) + (seconds as integer) + extraValue) 
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
				return totalSecondsObjects
			)
			
			local dateFilesLoad = dateFiles()
			local PITCMax= (getFiles (theLocalSearch + "*.max"))
			for files in PITCMax where matchPattern ((filterstring files "\\")[(filterstring files "\\").count]) pattern:("*PITC*") do 
			( 
				dateFilesLoad = dateFiles()
				dateFilesLoad.Location = (files)
				dateFilesLoad.Date = (getSecondsOfLife fileLolocation:files)
				append dateList dateFilesLoad
			)
			if dateList.count != 0 then (
				local versionsList = for dates in dateList collect dates.Date
				local versionSortedList = sort versionsList
				newestPITC = ((dateList[(findItem versionsList (versionSortedList[versionSortedList.count]))].Date))
				newestPITCLoc = ((dateList[(findItem versionsList (versionSortedList[versionSortedList.count]))].Location))
			)
			return newestPITCLoc
		)
		-- doPITCstuff
		fn loadPITCifmissing =
		(
			comma = "\""
			mainPath = "//nas/Scripts/StudioTools/PITC/MAXScript/"
			scriptS = #("PITCStudio","PITCConstants","GripMaxTools","GripViewerRendering","PITCEnvironment","PITCRendering","PITCUtils","GripViewerRendering_v8","GripViewerRendering_v9")
				for scriptZ in scriptS do
				(
					execute("filein " + comma + mainPath + scriptZ + ".ms" + comma)
				)
		)
		
		-- if inputs are defined, go go power rangers
		if thelocation != undefined and theFBXsave != undefined and theOBJsave != undefined then
		(
			if doCurrent == false then (
				local latestMax = (theLatestMax theLocalSearch:thelocation)
				loadMaxFile latestMax useFileUnits:true quiet:true
			)
			-- very weird way to do things, don't ask, don't tell, bascially forcing stuff
			local preloadNodeTypes = undefined
			try (
				preloadNodeTypes = (GripNodeTypes.getNodeTypes())
				if preloadNodeTypes == undefined then (
					loadPITCifmissing()
					try (preloadNodeTypes = (GripNodeTypes.getNodeTypes())) catch()
				)					
			) 
			catch (
				loadPITCifmissing()
				try (preloadNodeTypes = (GripNodeTypes.getNodeTypes())) catch()
			)
			
			-- gepaths
			local localPath = maxFilePath -- not being used
			local localMax = maxFileName
			local saveFileFBX = (theFBXsave + "//" + (substring localMax 1 (localMax.count-4)))
			local saveFileOBJ = (theOBJsave + "//" + (substring localMax 1 (localMax.count-4)))
				
			-- clean renderoutputs and clean all expect things in OBJ
			removerenderout()
			removeNotOBJ()
			
			-- cleanMaterial editor
			cleanMaterialEditors()
				
			-- clear materials, simplify artwork, keep colors from local artworks	
			if doMaterials == true then (cleanObjects()) else (cleanVrayBlends())
			if retroArtwork == true then (doRetroArtwork())
			if keepColor == true and preloadNodeTypes != undefined then (keepColorizableParts nodeTypesLoad:preloadNodeTypes)
			-- reduce turn off turbosmooth/opensudive, making export smaller (less poly)
			if doModifiers == true then (cleanModifiers())
			-- clean other	
			cleanSceneMiscelanious()
				
			-- double remove incase something is left
			removeNotOBJ()
			deleteEmptyLayers()
				
			if saveFBX == true then (FBXExport theFBXsave:theFBXsave saveFile:saveFileFBX exportTex:embedTextures)
			if saveOBJ == true then (OBJExport theOBJsave:theOBJsave saveFile:saveFileOBJ exportTex:embedTextures)
		)
	)
)