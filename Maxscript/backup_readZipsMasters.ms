(
	-- Created for INDG

	global batchMasterChecker
	try (if batchMasterChecker != undefined then destroyDialog batchMasterChecker; batchMasterChecker = undefined) catch()
	
	-- variables
	local folderCheck = "\\\\nas\\GRIP\\Master"
	local collectionPlace = "\\\\nas\\GRIP\\Grip_batchTools\\MaxScript\\Others\\readoutDataScript"
	-- read/write/filter
	local _theSep = "\\"
	local _theCSVSep = ","
	-- names
	local defaultName = "master_data" 
	local theMaster
	local theZip
	-- filterNameReduce
	--local theFilter = (substring theMaster (theMaster.count - (filterString theMaster _theSep)[(filterString theMaster _theSep).count].count + 1) theMaster.count)
	local theFilter
	-- file and hull
	local tempFileFolder = "_temp"
	local theSceneHullName = "__pitcSceneHull__"
	-- wholezThing Test -- testing --
	--local theWholeThine = (theMaster + _theSep + theZip)
	
	-- make temp dir
	fn checkAndMakeDir theTempFolder:(theMaster + _theSep + tempFileFolder) =
	(
		if not doesFileExist theTempFolder then (
			makeDir theTempFolder
		)
	)
	-- unzip
	fn unzipFile theZipFile:(theMaster + _theSep + theZip) outputTemp:(theMaster + _theSep + tempFileFolder) = 
	(
		if doesFileExist theZipFile then (
			unmaz theZipFile outputTemp
		)
	)
	-- delete tempFolder
	fn deleteTempFolder theTempFolder:(theMaster + _theSep + tempFileFolder) =
	(
		local sioDir = dotNetClass "System.IO.Directory"
		if (SIODir.Exists theTempFolder) do (SIODir.Delete (theTempFolder) true)
	)
	-- goes to proper layer
	fn moveAndCreateRenameLayer theItem:theSceneHullName theLayer:theFilter =
	(
		LayerManager.newLayerFromName theFilter
		for items in objects where items.name == theItem do (
			(LayerManager.getLayerFromName theFilter).addNode items
			items.name = (items.name + theFilter)
		)
	)
	-- filter filename and merge sceneHull
	fn mergeSceneHullToScene theTempFolder:(theMaster + _theSep + tempFileFolder) \
		theItems:(#(theSceneHullName)) theTempMax:(theMaster + _theSep + tempFileFolder + _theSep + theFilter + ".max") =
	(
		if doesFileExist theTempFolder then (
			mergeMAXFile theTempMax theItems #autoRenameDups #renameMtlDups quiet:true
		)
	)
	
	-- reading 
	-- get bounding box points
	fn getBBoxPoints theObject:theSceneHullName isString:True = 
	(
		if isString then (theObject = getNodeByName theObject)
		if isString and theObject != undefined then
		local bbPoints = #()
		local bbMax = theObject.max
		local bbMin = theObject.min
		append bbPoints (bbMax.x)
		append bbPoints (bbMin.x)
		append bbPoints (bbMax.y)
		append bbPoints (bbMin.y)
		append bbPoints (bbMax.z)
		append bbPoints (bbMin.z)
		return bbPoints
	)
	-- convert to units
	fn convertToLocalUnits theValue:0 =
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
		return (((theValue * (sysUnit as float/intValUnit as float)) as string) + intUnits as string)
	)
	-- readObjectSize
	fn objectSizeRead objectPoints: printListener:false =
	(		
		objectSize = objectPoints
		if printListener then (
			format "Lenght:% Width:% Height:%\n" (convertToLocalUnits theValue:(objectSize[3]-objectSize[4])) \
				(convertToLocalUnits theValue:(objectSize[1]-objectSize[2])) \
				(convertToLocalUnits theValue:(objectSize[5]-objectSize[6]))
		)
		theReturn = (
			(convertToLocalUnits theValue:(objectSize[3]-objectSize[4])) + _theCSVSep + \
			(convertToLocalUnits theValue:(objectSize[1]-objectSize[2])) + _theCSVSep + \
			(convertToLocalUnits theValue:(objectSize[5]-objectSize[6]))
		)
		return theReturn
	)
	-- get Folders
	fn getAllFolders localPath: =
	(
		theFolders = (getDirectories (localPath + "\*"))
		return theFolders
	)
	function outputText value =
	(
		if (value != undefined) do (
			batchMasterChecker.ET_output.AppendText value
			batchMasterChecker.ET_output.AppendText "\r\n"
		)
	)
	-- collect returnZips
	fn folderReturnZipCollect theFolder:folderCheck ext:("*.zip") testMode:True =
	(
		
		format "Starting to Collect Zips !\n"
		local leZipCollect = #()
		for folders in (getAllFolders localPath:theFolder) do (
			for files in (getFiles (folders + ext)) do (
				if not (matchpattern files pattern:("*artwork*")) and \
					not (matchpattern files pattern:("*old*")) and \
						not (matchpattern files pattern:("*backup*")) do (
							outputText ("Found: " + files)
							append leZipCollect files
							)
				)
				
			s=timeStamp()
				
			for subfolders in (getAllFolders localPath:folders) do (
				for files in (getFiles (subfolders + ext)) do (
					if not (matchpattern files pattern:("*artwork*")) and \
						not (matchpattern files pattern:("*old*")) and \
							not (matchpattern files pattern:("*backup*")) do (
								outputText ("Found: " + files)
								append leZipCollect files
								)
				)
			)
			
			e = timeStamp()
			windows.processPostedMessages()
			format "%::%s\n" folders ((e-s)/1000.0) 
		)

		format "Finished !!\n" 
		return leZipCollect
	)
	-- read write logs
	fn writeFileLog theData: location: arrayTogle:false fileNameOut:defaultName ext:".txt" =
	(
		if theData != undefined and theData.count != 0 and theFile != unsupplied then
		(
			logLocation = location + _theSep + fileNameOut + ext
			theWrite = ""
			theFile = createFile logLocation
			if arrayTogle then (for values in theData do theWrite += values + "\n") else (theWrite = theData)
			format "%" theWrite to:theFile
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
	)
	
	fn collectInfoFromMasters theMaster:theMaster tempFileFolder:tempFileFolder theZip:theZip theFilter:theFilter =
	(
		checkAndMakeDir theTempFolder:(theMaster + _theSep + tempFileFolder)
		unzipFile theZipFile:(theMaster + _theSep + theZip) outputTemp:(theMaster + _theSep + tempFileFolder)
		
		mergeSceneHullToScene theTempFolder:(theMaster + _theSep + tempFileFolder) theItems:(#(theSceneHullName)) theTempMax:(theMaster + _theSep + tempFileFolder + _theSep + theFilter + ".max")
			
		local theSize = objectSizeRead objectPoints:(getBBoxPoints theObject:theSceneHullName) printListener:false
			
		moveAndCreateRenameLayer theItem:theSceneHullName theLayer:theFilter 
		deleteTempFolder theTempFolder:(theMaster + _theSep + tempFileFolder)
			
		outputText ("Checking: " + (theMaster + _theSep + theZip))	
			
		return (theFilter + _theCSVSep + theSize)
	)
	
	rollout batchMasterChecker "masterChecker" 
	(
		edittext ETD_masterCheckLocation "Location:" text:folderCheck across:3 width:280
		edittext ETD_logFile "fileName:" text:defaultName offset:[140,0]
		label LBL_ext ".txt" align:#left offset:[140,0]
		button BTN_openSaveLocation "open save location" width:120 height:20 align:#right offset:[-20,0]
		button BTN_checkMasters "findZips" width:200 height:40 across:2
		button BTN_collectMastersData "getDimFromMaster" width:200 height:40
		
		checkBox CKH_resetMax "reset max" checked:false across:3
		edittext ETD_count "Count:" text:"0" width:100
		edittext ETD_isAt "IsAt:" text:"0" width:100
		multilistbox theValueBox "locations" height:0 align:#left offset:[0,0] enabled:true
		 
		dotnetcontrol ET_output "System.Windows.Forms.TextBox" height:150 --pos:[0,0]
		
		on batchMasterChecker open do
		(
			ET_output.MultiLine = true
			ET_output.ReadOnly = true 
			ET_output.WordWrap = false
			ET_output.Scrollbars = (dotnetclass "System.Windows.Forms.ScrollBars").Both
		)
		
		on BTN_openSaveLocation pressed do
		(
			try (shellLaunch "explorer.exe" (collectionPlace))
			catch(messagebox "file missing")
		)	
		
		on BTN_checkMasters pressed do
		(
			outputText "\r\nStarting to Collect Zips !" 
			(
				theValueBox.items = (folderReturnZipCollect theFolder:ETD_masterCheckLocation.text)
			)
			ETD_count.text = (theValueBox.items.count as string)
			outputText "Finished !!\r\n" 
		)
		on BTN_collectMastersData pressed do
		(
			local megaData = #("Name,Lenght,Width,Height")
			if CKH_resetMax.checked then (resetMaxFile #noPrompt)
			if true then -- for testing
			(
				cnt = 0
				outputText ("\r\nStarting... !")
				format "Starting... !\n"
				for zips in theValueBox.items do (
					if (keyboard.escPressed) do ( exit )
					try (
						s = timeStamp()
						
						theMasterFile = zips
						theFilterMaster = (filterString zips _theSep)
						theMasterFolder = (substring theMasterFile 1 (theMasterFile.count - (theFilterMaster[theFilterMaster.count]).count - 1))
							
						theFilter = (substring theMasterFolder \
							(theMasterFolder.count - (filterString theMasterFolder _theSep)[(filterString theMasterFolder _theSep).count].count + 1) theMasterFolder.count
						)
						
						if (keyboard.escPressed) do ( exit )
						append megaData (collectInfoFromMasters theMaster:theMasterFolder tempFileFolder:tempFileFolder theZip:(theFilter + ".zip") theFilter:theFilter)
						
						e = timeStamp()
						windows.processPostedMessages()
						
						format "%::%s\n" zips ((e-s)/1000.0) 
						
					) catch (format "Failed at %::%s\n" cnt ((e-s)/1000.0))
					
					cnt += 1
					ETD_isAt.text = (cnt as string)
				)
				outputText ("\r\nFinished Getting Info !\n")
				format "Finished Getting Info !\n"
			)
			writeFileLog theData:megaData location:collectionPlace arrayTogle:true fileNameOut:(ETD_logFile.text) ext:".txt"
		)
	)
	createDialog batchMasterChecker width:500
)