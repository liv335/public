(	
	-- Created for INDG
	global batchMasterUpdater
	try (if batchMasterUpdater != undefined then destroyDialog batchMasterUpdater; batchMasterUpdater = undefined) catch()
	
	-- to use main GRIP/PITC master folder backup
	local masterHack = "\\\\nas\\GRIP\\Master" -- PITCConstants.MASTER_FOLDER master folder is use later defined PITCConstants.MASTER_FOLDER if fails reverts to this
	local key = "max"
	local theMasterList = #()
	--function to run
	fn getSettings =
	(
		SETTINGS_NODE_NAME = "__pitcStudioSettings__"
		local theSettings = getNodeByName SETTINGS_NODE_NAME
		if (theSettings == undefined and (PITCEnvironmentEditor.getEnvironment()) != undefined) then (
			theSettings = Dummy name:SETTINGS_NODE_NAME isHidden:true
			local theLayer = (PITCUtils.getLayer PITCEnvironmentEditor.ENV_LAYER_NAME)
			theLayer.addnode theSettings
			custAttributes.add theSettings CAS_GripStudioSettings
			-- Default to white shadow pass background for new scenes.
			theSettings.objectShadowBackgroundColor = white
			-- Default to the latest supported engine version for new scenes.
			theSettings.engineVersion = "v9"
			-- Enable refractive artwork by default.
			theSettings.enableArtworkRefraction = true
			theSettings.useAlbedoAsRefractionColor = true
		)
		theSettings
	)
	
	fn getMasterSceneInfoFilename =
	(
		local theArchiveName = PITCUtils.getArchivePath()
		(getFilenamePath theArchiveName) + (getFilenameFile theArchiveName) + ".json"
	)
	
	fn publishMasterAndInfo =
	(
		theArchiveName = PITCUtils.getArchivePath()
		theSettings = getSettings()
		theSceneInfoFilename = getMasterSceneInfoFilename()
		
		PITCPublish.publishSceneData theSceneInfoFilename theSettings quiet:true
		PITCArchive.publishMaxArchive theArchiveName quiet:true
	)
	
	-- find latest max 
	fn theLatestMax theLocalSearch: keySearch:("max") =
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
		for files in PITCMax where matchPattern ((filterstring files "\\")[(filterstring files "\\").count]) pattern:("*" + keySearch + "*") do 
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
	fn loadPITCifmissing =
	(
		comma = "\""
		mainPath = "//nas/Scripts/StudioTools/PITC/MAXScript/"
		scriptS = #("PITCStudio","PITCConstants","GripMaxTools","GripViewerRendering", \
			"PITCEnvironment","PITCRendering","PITCUtils", \
			"GripViewerRendering_v8","GripViewerRendering_v9")
		for scriptZ in scriptS do
		(
			execute("filein " + comma + mainPath + scriptZ + ".ms" + comma)
		)
	)
	try (loadPITCifmissing()) catch( messageBox "PITC tools failed to load")
	fn readBatchTxt theFile: =
	(
		if theFile != unsupplied then 
		(
			local batchList = #()
			local fileToSearch = (openFile theFile)
			if fileToSearch != undefined then
			(
				while not eof fileToSearch do(
					lineToRead = readline fileToSearch
					append batchList lineToRead
				)
				close fileToSearch
			)
			return batchList
		)
	)
	fn doUpdate theMax: forceReset:false =
	(
		try 
		(
			if forceReset then (try (loadPITCifmissing()) catch(messageBox "PITC tools failed to load"))
				
			loadMaxFile theMax useFileUnits:true quiet:true
			publishMasterAndInfo()
				
			if forceReset then (gc();resetMaxFile #noPrompt)
		) catch(print "update failed")
	)
	
	rollout batchMasterUpdater "batchMasterUpdater" 
	(
		group "run" 
		(
			button BTN_fullLoop "loop full list" width:200 height:30 across:2 enabled:true
			button BTN_selectionMode "doSelection" width:200 height:30 enabled:true
		)
		
		group "action" 
		(
			editText ETX_entryText "" width:410 text:"full path entry" readOnly:false
			
			button BTN_addToList "add" width:100 height:20 across:3 
			button BTN_removeFromList "remove" width:100 height:20
			button BTN_loadBatchList "load Batch" width:100 height:20 
	
			checkbox CKH_searchPITC "search PITC only" checked:true across:4 offset:[10,0] tooltip:"If unchecked will search all .max files"
			checkbox CKH_forceReset "force reset cleanup" checked:false offset:[40,0] tooltip:"Will do a reset of 3ds max, and garbage\ncollection to prevent errors"
			checkbox CKH_checkArchive "read  status" checked:false offset:[80,0]
			
			button BTN_helpLoad "help" width:40 height:20 align:#right offset:[-7,-3]
			--checkbox CKH_empty "empty" checked:false enabled:false
		)
		
		group "selection status"
		(
			editText ETX_textCountSelection "Selection" width:100 text:"null" readOnly:true offset:[0,-1] across:3
			editText ETX_status "Master Status" width:140 text:"unknown" readOnly:true offset:[-35,-1]
			editText ETX_date "Date:" width:165 text:"unknown" readOnly:true offset:[-25,-1]
		)
		multilistbox MLT_theValueBox "locations" height:10 align:#left offset:[0,0] enabled:true items:theMasterList
		
		on CKH_searchPITC changed state do
		(
			--if state then CKH_searchPITC.text = "search PITC only" else CKH_searchPITC.text = "search All max"
		)
		
		-- help documentation
		on BTN_helpLoad pressed do 
		(
			try (shellLaunch "explorer.exe" ("\"" + "\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\batchMasterUpdater\\Batch Master upadater.pdf" + "\""))
			catch(messagebox "file missing")
		)
		
		on BTN_selectionMode pressed do
		(
			if CKH_searchPITC.checked then key = "PITC"
			if theMasterlist.count != 0 then
			(
				for items in MLT_theValueBox.selection do 
				(
					if (keyboard.escPressed) do ( exit )
					theMax = (theLatestMax theLocalSearch:theMasterlist[items] keySearch:key) 
					if theMax != undefined then
					(
						doUpdate theMax:theMax forceReset:CKH_forceReset.checked
					)
					if (keyboard.escPressed) do ( exit )
				)
				messageBox "Done!" beep:false
			)
			else (messageBox "Nothing in List" beep:true)
		)
		
		on BTN_fullLoop pressed do
		(
			if CKH_searchPITC.checked then key = "PITC"
			if theMasterlist.count != 0 then
			(
				for items in theMasterlist do (
					if (keyboard.escPressed) do ( exit )
					theMax = (theLatestMax theLocalSearch:items keySearch:key) 
					if theMax != undefined then
					(
						doUpdate theMax:theMax forceReset:CKH_forceReset.checked
					)
					if (keyboard.escPressed) do ( exit )
				)
				messageBox "Done!" beep:false
			)
			else (messageBox "Nothing in List")
		)
		
		on BTN_addToList pressed do
		(
			appendIfUnique theMasterList (ETX_entryText.text)
			MLT_theValueBox.items = theMasterList
		)
		on BTN_removeFromList pressed do
		(
			for i in MLT_theValueBox.selection do (
				deleteItem theMasterList (findItem theMasterList (MLT_theValueBox.items[(MLT_theValueBox.selection as array)[1]]))
			)
			MLT_theValueBox.items = theMasterList
		)
		on BTN_loadBatchList pressed do
		(
			local fileImport = (getOpenFileName  caption:"Open txt/csv file" \
				filename:".txt" types:"All Files(*.*)|*.*|Text files(*.txt)|*.txt|CSV files(.csv)|*.csv|")
			if fileImport != undefined then 
			(
				theFileLoadReduce = (filterstring fileImport "\\")[(filterstring fileImport "\\").count]
				BTN_loadBatchList.text = theFileLoadReduce
				-- readText
				local batchListLoad = (readBatchTxt theFile:fileImport)
				-- do loop
				for values in batchListLoad do (
					appendIfUnique theMasterList values
					MLT_theValueBox.items = theMasterList
				)
			)
		)
		
		on MLT_theValueBox doubleclicked val do
		(
			try
			(
				location = theMasterlist[val]
				shellLaunch "explorer.exe" ("\"" + location + "\\" + "\"")
			)
			catch (print "go to path failed")
		)
		
		on MLT_theValueBox rightclick val do
		(
			MLT_theValueBox.selection = #()
			ETX_textCountSelection.text = "nothing selected"
			ETX_status.text = "unknown"
			ETX_date.text =  "unknown"
		)
		on MLT_theValueBox selected val do
		(
			local theMasterZip
			local theMasterCheckZip
			try (ETX_textCountSelection.text = ((MLT_theValueBox.selection) as string)) catch()
			theSelection = ((substituteString (substituteString (ETX_textCountSelection.text) "#{" "") "}" "") as integer)
			if theSelection != 0 and theSelection != undefined then
			(
				if CKH_searchPITC.checked then key = "PITC"
				if CKH_checkArchive.checked then (
					theFilter = (filterstring theMasterlist[theSelection] "\\")
					try (masterHack = PITCConstants.MASTER_FOLDER)
					catch(
						loadPITCifmissing()
						try(masterHack = PITCConstants.MASTER_FOLDER)catch()
					)
					try (
						theMasterZip = (masterHack + "\\" + theFilter[theFilter.count-1]  + "\\" + theFilter[theFilter.count]  + "\\" + theFilter[theFilter.count] + ".zip")
						theMasterCheckZip = doesFileExist (theMasterZip)
					) catch (theMasterCheckZip = false)
					if theMasterCheckZip then (
						ETX_status.text = "Found"
						ETX_date.text = (getFileModDate (theMasterZip) as string)
					)
					else (
						ETX_status.text = "missing"
						ETX_date.text =  "unknown"
					)
				)
				else (ETX_status.text = "Read status is off"; ETX_date.text = "Off")
			)
		)
	)
	createDialog batchMasterUpdater width:440 height:370
)