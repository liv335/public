------------------------------------------------------------------------------------------------------------------------------
-- viewgrabber - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- when do all cameras checkes does for each camera in scenes grabs/saves screenshots
-- otherwise grabs/saves screenshot of viewport with safe frame active
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	global RLT_autoScreenGrab
	try (if RLT_autoScreenGrab != undefined then destroyDialog RLT_autoScreenGrab; RLT_autoScreenGrab = undefined) catch()
	
	testLocation = @"C:\_work\GDM_logistics\renders\screenshots"
	
	fn getScreenGrabSafeFrame filenameLocation: extension:".jpg" freeImages:false displayImage:true saveGrab:false saveCrop:false theCamera: namingForRenders:"viewportGrab_" =
	(
		unqiueId = ((bit.intAsHex ((substring (timeGetTime() as string) 1 ((timeGetTime() as string).count - 1)) as integer)) as string)
		(
			displaySafeFrames = true
			viewport.SetShowEdgeFaces false
			displayColor.shaded = #material
			actionMan.executeAction 0 "63566"  -- Views: Default Shading
			if theCamera != undefined and theCamera != unsupplied then viewport.setCamera theCamera
			completeRedraw()
		)
		
		--local filenameLocation = maxFilepath + (getfileNameFile maxFileName)
		grabScreen = gw.getViewportDib()
		if filenameLocation != undefined and filenameLocation != undefined then (
			grabScreen.filename = (filenameLocation + "\\" + namingForRenders + unqiueId +  "_grabView" + extension) -- filename if needed for testing
			if saveGrab then save grabScreen
		)
		
		theBaseForResize = bitmap (grabScreen.width as float *(renderHeight/grabScreen.height as float)) renderHeight color:white filename:(filenameLocation + "\\" + namingForRenders + unqiueId + "_Resize" + extension) -- filename if needed
		theBitmapResized = copy grabScreen theBaseForResize
		
		if filenameLocation != undefined and filenameLocation != undefined then ( 
			cropFileName = (filenameLocation + "\\" + namingForRenders + unqiueId + "_Crop" + extension)
		) else (
			cropFileName = ""
		)
		
		theCropGrab = bitmap renderWidth renderHeight color:white filename:cropFileName -- filename if needed
		pasteBitmap theBitmapResized theCropGrab (box2  (((theBitmapResized.width/2)-(renderWidth/2))) 0 \
			(((renderWidth/2)-(theBitmapResized.width/2))+theBitmapResized.width) theBitmapResized.height) [0,0]
			
		if displayImage then display theCropGrab
		if saveCrop then save theCropGrab
			
		-- freeImages will close display if displayed
		if freeImages then
		(
			free grabScreen
			free theBitmapResized
			free theCropGrab
		)
		return cropFileName -- the crop file name can be return to be used, especially if saved
	)
	
	fn camerasUpdate =
	(
		cameraList = for c in cameras where not matchpattern c.name pattern:"*.Target*" collect c.name
		return (sort cameraList)
	)
	
	rollout RLT_autoScreenGrab "AutoScreenGrab" 
	(
		checkbox CKH_doAll "Do all Cams" checked:false across:4
		checkbox CKH_show "Show grab" checked:false
		checkbox CHK_save "Save Grab" checked:true
		button BTN_loadLocation "Change Save"
		
		--edittext ETD_saveLocation "Save Location" text:testLocation labelOnTop:true
		listbox LST_saveLocation "Save Location" height:1 items:#(testLocation) selection:0
		
		button BTN_doScreenGrab "Do screengrab" width:120 height:40
		
		multilistbox MLB_cameraList "Cameras" items:(camerasUpdate()) height:12
		
		on BTN_doScreenGrab pressed do
		(
			if CKH_doAll.checked then			
			(
				for c in cameras where not matchpattern c.name pattern:"*.Target*" do (
						getScreenGrabSafeFrame filenameLocation:LST_saveLocation.items[1] \
					theCamera:c displayImage:CKH_show.checked saveCrop:CHK_save.checked namingForRenders:(c.name + "__")
				)
				messageBox "Screens Grabbed" title:"Done!" beep:false
			)
			else (
				getScreenGrabSafeFrame filenameLocation:LST_saveLocation.items[1] \
					displayImage:CKH_show.checked saveCrop:CHK_save.checked 
				
				messageBox "Screen Grabbed" title:"Done!" beep:false
			)
		)
		on BTN_loadLocation pressed do
		(
			fileLocation = getSavePath caption:"Load SaveLocation:" initialDir:MaxFilePath
			if fileLocation != undefined then (LST_saveLocation.items = #(fileLocation)) -- load path
		)
		
		on LST_saveLocation doubleclicked val do
		(
			try (shellLaunch "explorer.exe" ("\"" + LST_saveLocation.items[1] + "\"")) catch() -- open location
		)
		on LST_saveLocation rightclick val do
		(
			LST_saveLocation.selection = 0 -- reset selection
		)
		
		on MLB_cameraList doubleclicked val do
		(
			viewport.setCamera (getNodeByName MLB_cameraList.items[val]) -- go to camera
		)
		on MLB_cameraList rightclick val do
		(
			MLB_cameraList.selection = 0 -- reset selection
		)
		on MLB_cameraList selected val do
		(
			var_vams = camerasUpdate()
			if MLB_cameraList.items.count != var_vams.count then
				(
					MLB_cameraList.items = var_vams -- update list
				)
		)
	)
	CreateDialog RLT_autoScreenGrab width:400 height:300
)