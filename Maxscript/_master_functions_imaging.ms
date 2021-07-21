------------------------------------------------------------------------------------------------------------------------------
-- Fast Screenshot - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- Makes a screenshot taking into account safe frame of viewport
-- Can save image directly
-- Can show image
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	/*
	grabViewport safe frame screenshot
	*/
	fn getScreenGrabSafeFrame filenameLocation: extension:".jpg" freeImages:false displayImage:true saveGrab:false saveCrop:false theCamera: =
	(
		namingForRenders = "viewportGrab_"
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
	getScreenGrabSafeFrame filenameLocation:"C:\\Users\\335\\Documents\\3dsMax\\_script"
)