(
	-- created for INDG

	global batchStyleOptimizer
	try (if batchStyleOptimizer != undefined then destroyDialog batchStyleOptimizer; batchStyleOptimizer = undefined) catch()
	
	local theMainPath = "\\\\nas\\GRIP\\style-explorations"
	local leMaxCollect = #()
	local dataAdded = ""
	
	-- read write logs
	fn writeFileLog theData: maxPath: maxName: =
	(
		if theData != undefined and theData.count != 0 and maxName != unsupplied and maxName != undefined then
		(
			logLocation = maxPath + (substituteString maxName ".max" "") + "_log.txt"
			--theWrite = ""
			theFile = createFile logLocation
			--for values in theData do theWrite = theWrite + values + "\n"
			format "%" theData to:theFile
			close theFile
		)
	)	
	fn readLog textFileName: =
	(
		local data = #()
		local fileToSearch = (openFile textFileName)
		if fileToSearch != undefined then
		(
			while not eof fileToSearch do(
				lineToRead = readline fileToSearch
				append data lineToRead
			)
			close fileToSearch
		)
		return data
	)
	fn writeLog dataAdd: =
	(
		timz =getUniversalTime()
		theLogTime = (timz[1] as string +"/" + timz[2] as string + "/" +timz[4] as string + "_" \
		+ timz[5] as string +":" + timz[6] as string + ":" +timz[7] as string + "=")
		dataAdded += (theLogTime + dataAdd + "\n")
	)-- log stuff end
	
	-- comment things
	fn retrieveComments =
	(
		sceneComments = #()
		if isvalidNode GripCommentHolder do
		(
			for o in GripCommentHolder.modifiers do
			(
				if (custAttributes.get o 1) as string== "CAS_comment:CAS_comment" do append sceneComments o
			)
		)
		return sceneComments
	)
	local sceneComments = retrieveComments()	
	CAS_comment = attributes CAS_comment
	(		
		parameters params
		(
			artist type:#string
			date type:#string
			title type:#string
			comment type:#string
			nodes type:#nodetab tabSizeVariable:true
			material type:#material
		)
		
		fn createDate =
		(
			try
			(
				tme = getUniversalTime()
				tme = for o in tme collect o as string
				if tme[5].count == 1 do tme[5]= "0" +tme[5]
				if tme[6].count == 1 do tme[6]= "0" +tme[6]
				date =  (tme[1]+ "-"+tme[2] + "-" + tme[4] + "-" + tme[5] + ":" + tme[6])
			)
			catch ("could not create time stamp!")
		)
			
		fn getArtistName =
		(
			theStr = sysInfo.computername
			artist = theStr
		)
		
		on create do
		(
			createDate()
			getArtistName ()
			title = ""
			comment =""
			nodes = #()
		)
	)
	fn createComment =
	(
		theMod = emptyModifier ()
		custAttributes.add theMod CAS_comment
		return theMod
	)
	global GripCommentHolder
	fn storeComment commentMod =
	(
		if isvalidNode GripCommentHolder then 
		(
			if finditem GripCommentHolder.modifiers commentMod == 0 do addmodifier GripCommentHolder commentMod
		)
		else messagebox "no valid __GripComments__ object found "
	)
	fn initGripCommentHolder =
	(
		GripCommentHolder= getnodeByName "__GripComments__"
		if not isvalidNode GripCommentHolder do
		(
			theLayer = layermanager.newLayerfromName "_ENV_"
			theLayer = layermanager.getLayerFromName "_ENV_"
			GripCommentHolder= dummy name:"__GripComments__" renderable:false ishidden:true
			theLayer.addNode GripCommentHolder
		)
		return GripCommentHolder
	)
	fn addCommentStyle maxName: =
	(
		fn storeComment commentMod =
		(
			if isvalidNode GripCommentHolder then 
			(
				if finditem GripCommentHolder.modifiers commentMod == 0 do addmodifier GripCommentHolder commentMod
			)
			else messagebox "no valid __GripComments__ object found "
		)
		fn addComment maxName: =
		(
			newCommentMod =createComment()
			newCommentMod.CAS_comment.nodes = #()
			newCommentMod.CAS_comment.material = undefined
			
			newCommentMod.CAS_comment.artist = "autoCleanTool"
			newCommentMod.CAS_comment.title = "Id_style"
			newCommentMod.CAS_comment.comment = (substituteString maxName ".max" "")
			print ("adding style: " + (substituteString maxName ".max" ""))
			
			newCommentMod.name = 	newCommentMod.CAS_comment.artist + "@" + newCommentMod.CAS_comment.date
			storeComment newCommentMod
			
			if finditem sceneComments newCommentMod == 0 do append sceneComments newCommentMod
		)
		fn cleanComment = 
		(
			forDeletion = for mods in $__GripComments__.modifiers where mods.title == "Id_style" collect mods
			for mods in forDeletion do deleteModifier $__GripComments__ mods
		)
		_continue = true
		cleanComment()
		try
		(
			for mods in $__GripComments__.modifiers where mods.artist == "autoCleanTool" do _continue = false
			if _continue == true then ((print "comment added");(addComment maxName:maxName)) else (print "Id_style already found")
		)
		catch (print"comment failed")
		_continue = true
	)-- end
	
	-- collect files mode (only bitmap?) 
	fn theResourceCollection maxPath: =
	(
		fn createFolder subfolder: maxPath: =
		(
			DirNew = (maxPath as string) + subfolder
			if doesFileExist DirNew == False then (makeDir DirNew; print "folder created")
		)
		fn newCollect subfolder: maxPath: maxName: =
		(
			scenefilelist = #()
			missingList = #()
			for i = 1 to AssetManager.GetNumAssets() do
			(
				typeItemAssetManager = (AssetManager.GetAssetByIndex i).getType()
				nameItemAssetManager = (AssetManager.GetAssetByIndex i).getfilename()
				if typeItemAssetManager == #bitmap then (
					if ((ATSOps.GetFileSystemStatus nameItemAssetManager)[1]) == #ok or \
						((ATSOps.GetFileSystemStatus nameItemAssetManager)[1]) == #found then (append scenefilelist nameItemAssetManager)
					else if ((ATSOps.GetFileSystemStatus nameItemAssetManager)[1]) == #missing then (append missingList nameItemAssetManager)
				)
			)
			fn getFilesRecursive root: pattern: =
			(
				directoryArray = GetDirectories (root + "/*")
			for dir in directoryArray do
				join directoryArray (GetDirectories (dir + "/*"))
				theFiles = #()
			for folders in directoryArray do
				join theFiles (getFiles (folders + pattern))
				theFiles
			)
			for files in scenefilelist do (
				filterName = (filterString (files as string) "\\")
				newLocDir = ((maxPath as string) + subfolder) + "\\" + filterName[filterName.count]
				
				if not (doesfileExist files) then (
					rootMaxSearch = (getFilesRecursive root:maxFilePath pattern:filterName[filterName.count])
					rootLinkSearch = (getFilesRecursive root:(substring files 1 (files.count-(filterName[filterName.count]).count - 1)) pattern:filterName[filterName.count])
					for files in rootMaxSearch where (doesFileExist files) do ((copyfile files newLocDir))
					for files in rootLinkSearch where (doesFileExist files) do ((copyfile files newLocDir))
				) else (copyfile files newLocDir)
			)
			NewDir = (maxPath as string) + subfolder
			ATSOps.SelectFiles scenefilelist
			ATSOps.SetPathOnSelection NewDir
			scenefilelist = undefined
			return missingList
		)
		try (
			foldername = "Resources"
			createFolder subfolder:foldername maxPath:maxPath
			gc()
			missingList = newCollect subfolder:foldername maxPath:maxPath
			return missingList
		)
		catch (print "texture collection failed")
	)-- end
	
	-- cleanup other things
	fn theCleanup =
	(
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
		try
		(
			cleanMaterialEditors()
			removerenderout()
			cleanSceneMiscelanious()
			print ("cleanup done")
		)
		catch(print "cleanup failed")
	)-- end

	-- dezactivate Gradient
	fn dezactivateGradient =
	(
		try 
		(
			if $__pitcStudioSettings__ != undefined and $__pitcStudioSettings__.applyBackgroundGradient == true then (
				$__pitcStudioSettings__.applyBackgroundGradient = false; print "gradient dezactivated")
		)
		catch (print "dezactivate gradient failed")
	)-- end

	-- return folders 
	fn getAllFolders localPath: =
	(
		theFolders = (getDirectories (localPath + "\*"))
		return theFolders
	)-- end
	
	-- backup Max files
	fn backupMaxe maxPath: maxName: =
	(
		DirNew = (maxPath as string) + "backup"
		if (doesFileExist DirNew) == False then (makeDir DirNew; print "folder created")
		saveMaxFile (DirNew + "\\" + maxName) useNewFile:false
	)-- end

	fn cleanSceneFromGeo =
	(
		-- delete objects
		deleteList = for geo in objects where (matchpattern geo.layer.name pattern:("*OBJ*")) or (matchpattern geo.layer.name pattern:("*0*")) collect geo
		if deleteList.count != 0 then (
			try
			(
				select deleteList
				delete $
			)
			catch()
		)
		-- delete layers
		for id = LayerManager.count - 1 to 1 by -1 do
		(
			local layer = LayerManager.getLayer id
			local containsNodes = LayerManager.doesLayerHierarchyContainNodes layer.name
			if not containsNodes then (local deleted = LayerManager.deleteLayerByName layer.name)
		)
	)-- end

	fn doMagicToScene maxPath:maxFilePath maxName:maxFileName addId:true cleanMode:true collectVal:false cleanObj:false writeLogger:true countLeft:false count:0 =
	(
		dataAdded = ""
		if doesFileExist(maxPath + (substituteString maxName ".max" "") + "_log.txt") then (
			for readedLines in (readLog textFileName:(maxPath + (substituteString maxName ".max" "") + "_log.txt")) do dataAdded += (readedLines + "\n")
		)
		try
		(
			if (keyboard.escPressed) do ( exit )
			loadMaxFile (maxPath+maxName) useFileUnits:true quiet:true
			
			initGripCommentHolder()
			
			if countLeft then (print count)
			print ("doing -- " + maxName)
			-- write log
			(writeLog dataAdd:("<start>"))
				
			backupMaxe maxPath:maxPath maxName:maxName
			
			if addId then (addCommentStyle maxName:maxName;(writeLog dataAdd:("style comment added")))
			if collectVal then (
				aList = (theResourceCollection maxPath:maxFilePath)
				print (aList)
				if aList.count != 0 then (for items in aList do (writeLog dataAdd:("missing file: " + items)))
				if aList.count == 0 then (writeLog dataAdd:("no maps collected")) else (writeLog dataAdd:("maps collected"))
			)
			if cleanMode then (theCleanup();(writeLog dataAdd:("materials,miscellaneous clead")))
			
			if cleanObj then (cleanSceneFromGeo();(writeLog dataAdd:("OBJ layer clean")))
			--if CKH_dezGradient.checked then (dezactivateGradient())
				
			saveMaxFile (maxPath + (substituteString maxName ".max" "") + "_autoClean.max" )

			print ("<done>\n")
			-- write log
			(writeLog dataAdd:("<end>"))
			--
				
			if (keyboard.escPressed) do ( exit )
		)
		catch (print (maxName + " = failed");(writeLog dataAdd:(maxName + " = failed")))
		if writeLogger then (writeFileLog theData:dataAdded maxPath:maxPath maxName:maxName)
	)
	
	--function to run
	rollout batchStyleOptimizer "styleFixer" 
	(
		editText folderLocation "styleFolder" width:400 text:theMainPath readOnly:true
		
		--button BTN_runMode "doFullList" width:200 height:30 across:2 enabled:false
		button BTN_collectFiles "collect Files Manual" width:200 height:30 across:2
		button BTN_loadList "loadBatchFiles" width:200 height:30 
		button BTN_selectionMode "doSelection" width:200 height:30 across:2 enabled:false
		button BTN_soloMode "doCurrentScene" width:200 height:30 
		
		checkbox CKH_addIDStyle "add Id_style_Comment" checked:true across:3
		checkbox CKH_cleanScene "clean scene" checked:true
		checkbox CKH_collectMaps "collect texture" checked:true enabled:true
		
		checkbox CKH_cleanOBJs "cleanOBJ" checked:false across:3
		checkbox CKH_writeLog "write log" checked:true enabled:true
		
		button BTN_helpLoad "help" width:40 height:20 align:#right offset:[-7,-3]
		--checkbox CKH_empty "empty" checked:false enabled:false 
		
		--checkbox CKH_dezGradient "dezactivate gradient" checked:true across:3
		--checkbox CKH_empty "empty" checked:false enabled:false 
		
		editText textCountSelection "Selection" width:200 text:"nothing selected" readOnly:true across:2
		editText textCount "MaxesFound" width:200 text:"current" readOnly:true
		multilistbox theValueBox "locations" height:10 align:#left offset:[0,0] enabled:true --tooltip:"Double click - to go to location\nRight click - to un-select"
		
		on BTN_collectFiles pressed do
		(
			theResourceCollection maxPath:maxFilePath
		)
		
		--help documentation
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" + "\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\cleanupStype\\styleSceneCleaner.pdf" + "\""))
			catch(messagebox "file missing")
		)
		
		on BTN_selectionMode pressed do
		(
			cnt = 0
			for vals in theValueBox.selection do cnt += 1
			if leMaxCollect.count != 0 then
			(
				for vals in theValueBox.selection do
				(
					theFilter = (filterstring (leMaxCollect[vals]) "\\")
					maxNameFilter = (theFilter[theFilter.count])
					maxPathFilter =  (substring (leMaxCollect[vals]) 1 (((leMaxCollect[vals]).count) - maxNameFilter.count))
					(doMagicToScene maxPath:maxPathFilter maxName:maxNameFilter \
						addId:CKH_addIDStyle.checked cleanMode:CKH_cleanScene.checked collectVal:CKH_collectMaps.checked \
						cleanObj:CKH_cleanOBJs.checked writeLogger:CKH_writeLog.checked countLeft:true count:cnt
					)
					cnt -= 1
				)
			)
		)
		on BTN_soloMode pressed do
		(
			(doMagicToScene maxPath:maxFilePath maxName:maxFileName \
				addId:CKH_addIDStyle.checked cleanMode:CKH_cleanScene.checked collectVal:CKH_collectMaps.checked \
				cleanObj:CKH_cleanOBJs.checked writeLogger:CKH_writeLog.checked
			)
		)
		on BTN_runMode pressed do
		(
			if leMaxCollect.count != 0 then
			(
				for maxes in leMaxCollect do
				(
					theFilter = (filterstring maxes "\\")
					maxNameFilter = (theFilter[theFilter.count])
					maxPathFilter =  (substring (leMaxCollect[vals]) 1 ((maxescount) - maxNameFilter.count))
					(doMagicToScene maxPath:maxPathFilter maxName:maxNameFilter \
						addId:CKH_addIDStyle.checked cleanMode:CKH_cleanScene.checked collectVal:CKH_collectMaps.checked \
						cleanObj:CKH_cleanOBJs.checked writeLogger:CKH_writeLog.checked
					)
				)
			)
		)
		on BTN_loadList pressed do
		(
			leMaxCollect = #()
			for folders in (getAllFolders localPath:theMainPath) do (
				for subfolders in (getAllFolders localPath:folders) do (
					for files in (getFiles (subfolders + "*.max")) do (
						if matchpattern files pattern:("*autoClean*") then () else (append leMaxCollect files)
					)
				)
			)
			if leMaxCollect.count != 0 then
			(
				clearList = for items in leMaxCollect collect ((Filterstring items "\\")[(Filterstring items "\\").count])
				theValueBox.items  = clearList
				try (BTN_runMode.enabled = true) catch ()
				try (BTN_selectionMode.enabled = true) catch ()
				textCount.text = (leMaxCollect.count as string)
			)
		)
		on theValueBox doubleclicked val do
		(
			location = (substring leMaxCollect[val] \
				1 (leMaxCollect[val].count-((Filterstring leMaxCollect[val] "\\")[(Filterstring leMaxCollect[val] "\\").count]).count-1)
			)
			shellLaunch "explorer.exe" ("\"" + location + "\"")
		)
		on theValueBox rightclick val do
		(
			theValueBox.selection = #()
			textCountSelection.text = "nothing selected"
		)
		on theValueBox selected val do
		(
			textCountSelection.text = ((theValueBox.selection) as string)
		)
	)
	createDialog batchStyleOptimizer width:440 height:320
)