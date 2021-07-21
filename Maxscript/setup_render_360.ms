------------------------------------------------------------------------------------------------------------------------------
-- fast 360 setuper - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- using FFmpeg, script can setup and render a fast 360
-- requires more work
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	if RLT_do360 != undefined then (destroyDialog RLT_do360) else (RLT_do360 = undefined)
	global RLT_do360
	
	main_height = 320
	main_width = 100
	theDummy = "_360_"
	theLayerDummy = "_360_"
	wasCancelled = False
	
	fn backupFiles theFileLocation: =
	(
		
	)
	
	fn deleteKeysAnimation dummyName:theDummy =
	(
		deletekeys (getNodeByName theDummy).controller #allkeys
	)
	
	fn runFFmpeg pathLoc:(trimright maxFilePath @"\") ffmpegLoc:@"C:\_work\_script\ffmpeg\bin\ffmpeg.exe" =
	(
		_space = " "
		--pathLoc = @"C:\Users\335\Documents\3dsMax\scenes\00007_gabyTest"
		renderLocation = pathLoc + @"\render_output"
		imageName = @"\_360_rendering%d.png"
		filename = @"\out.mp4"
		
		theList = #(ffmpegLoc,"-y","-loglevel quiet","-framerate 30","-i",(renderLocation+imageName),(pathLoc + filename))
		theCommand = ""
		for i in theList do (
			theCommand += (i + _space)
		)
		
		theCommand = (trimright theCommand)
		HiddenDOSCommand ("\"" + theCommand + "\"")
		
		messageBox "Video Done !!" title:"Info" beep:True
	)
	
	fn dummy360Adding dummyName:theDummy dummyLayer:theLayerDummy =
	(
		if (getNodeByName dummyName) == undefined then (Dummy name:dummyName pos:[0,0,0])
		else (getNodeByName dummyName).rotation.z_rotation.controller = Linear_Float()
		
		if (layerManager.getLayerFromName theLayerDummy) == undefined then (layerManager.newLayerFromName theLayerDummy)
		
		(layerManager.getLayerFromName theLayerDummy).addnode (getNodeByName dummyName)
		for geo in geometry where matchpattern geo.layer.name pattern:(dummyLayer) do (
			geo.parent = (getNodeByName dummyName)
		)
	)
	
	fn add360toDummy frames:6 dummyName:theDummy  =
	(
		with animate off
		(
			at time 0 (getNodeByName dummyName).rotation = eulerAngles 0 0 0 
		)
		animationRange = interval 0 (frames-1)
		with animate on
		(
			for f = 0 to frames do
			(
				at time f (getNodeByName dummyName).rotation = (angleaxis ((360/frames)*f) [0,0,1])
			)
		)
	)
	
	fn renderWindow indexFile =
	(
		if wasCancelled != True then
		(
			render cancelled:&wasCancelled vfb:False outputfile:indexFile --camera:theCamera
		)
	)
	
	fn makeDirectory theFileLocation: =
	(
		if not (doesFileExist theFileLocation) then (makeDir theFileLocation)
	)
	
	fn checkFiles theFileLocation thePattern:"_360_"=
	(
		_filesFound = False
		for f in (getFiles (theFileLocation + "\\*")) where matchpattern f pattern:("*" + thePattern + "*") do _filesFound = True
		return _filesFound
	)
	
	rollout RLT_do360 "360"
	(
		button BTN_openFrames "Open Location" width:100 height:40 across:2 
		spinner SPN_numberFrames "Frames" range:[0,72,12] type:#integer
		
		button BTN_do360 "Setup 360" width:100 height:40 across:3
		button BTN_render360 "Render 360" width:100 height:40
		button BTN_makeVideo "Make Video" width:100 height:40
		
		on BTN_openFrames pressed do
		(
			theLocation = (MaxFilePath + "render_output")
			makeDirectory theFileLocation:theLocation
			shellLaunch "explorer.exe" ("\"" + theLocation + "\"")
		)
		
		on BTN_do360 pressed do
		(
			deleteKeysAnimation()
			dummy360Adding()
			add360toDummy frames:(SPN_numberFrames.value)
		)
		
		on BTN_makeVideo pressed do
		(
			runFFmpeg()
		)
		
		on BTN_render360 pressed do
		(
			_continue = True
			filename = @"\_360_rendering"
			theRenderingLocation = (MaxFilePath + "render_output")
			makeDirectory theFileLocation:theRenderingLocation
			
			if (checkFiles theRenderingLocation) and not (queryBox "Other Files found, Continue??" Title:"warning") then _continue = False
			--if not (queryBox "backupFiles, Continue??" Title:"warning") then _continue = False
			if _continue and (queryBox "Start Rendering?" Title:"warning") then (
					for i = 0 to (substituteString (animationRange.end as string) "f" "") as integer do (
						if not wasCancelled then
						(
							sliderTime = i
							renderWindow (theRenderingLocation + filename + (i as string) + ".png")
						)
						else 
						(
							MessageBox "Rendering Canceled"
							exit
						)
					)
				)
			else (MessageBox "Rendering Stopped, move the files")
		)
	)
	createDialog RLT_do360 width:main_height height:main_width
)