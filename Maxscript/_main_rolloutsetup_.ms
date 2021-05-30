(
	-- the main floater
	global theMainRollout -- atempts to close rollout if already is open
	try (if theMainRollout != undefined then closeRolloutFloater theMainRollout; theMainRollout = undefined) catch()
	theMainRollout = newRolloutFloater "master" 400 220
	
	-- update the main rollout
	fn updateRollout baseHeight:100 maxHeight:600 =
	(
		if theMainRollout != undefined then
		(
			updateHeight = baseHeight
			for rollouts in theMainRollout.rollouts where (rollouts.open) do (
				updateHeight += rollouts.height
			)
			-- max height
			if updateHeight >= maxHeight then updateHeight = maxHeight
			theMainRollout.size = [theMainRollout.size[1],updateHeight]
		)
		else (messagebox "theMainRollout is missing")
	)
	-- rollouts 
	rollout theOutput "Output"
	(
		local main_BTN_width = 160
		local main_BTN_height = 20
		button BTN_test "Write" width:main_BTN_width height:main_BTN_height across:2
		button BTN_clear "Clear" width:main_BTN_width height:main_BTN_height
		dotnetcontrol TXB_output "System.Windows.Forms.TextBox" height:100
		
		fn outputText value =
		(
			if (value != undefined) do (
				TXB_output.AppendText value
				TXB_output.AppendText "\r\n"
			)
		)
		on theOutput rolledUp state do
		(
			updateRollout()
		)
		on theOutput open do
		(
			TXB_output.MultiLine = true
			TXB_output.ReadOnly = true 
			TXB_output.WordWrap = false
			TXB_output.Scrollbars = (dotnetclass "System.Windows.Forms.ScrollBars").Both
			outputText ("Initialized...")
		)
		
		on BTN_clear pressed do
		(
			TXB_output.Clear()
			outputText ("Cleared...")
		)
		on BTN_test pressed do
		(
			outputText (localtime + "::" + timeGetTime() as string)
		)
	)
	rollout theOutputAdmin "OutputAdmin"
	(
		local main_BTN_width = 160
		local main_BTN_height = 20
		
		button BTN_test "AdminLogin" width:main_BTN_width height:main_BTN_height
		
		on theOutputAdmin rolledUp state do
		(
			updateRollout()
		)
		on BTN_test pressed do
		(
			global adminCheck -- atempts to close rollout if already is open
			try (if adminCheck != undefined then closeRolloutFloater theOutputDialog; theOutputDialog = undefined) catch()
			rollout adminCheck "User/Password" 
			(
				local userLoad
				local userPass
				
				label LBL_user_id "User:" across:2
				edittext ETD_user_ID width:100 offset:[-10,0]
				
				label LBL_pass_id "Password:" across:2
				edittext ETD_pass_ID width:100 offset:[-10,0]
				
				button BTN_confirmation_ID "Ok" width:50 height:20 across:2
				button BTN_cancel_ID "Cancel" width:50 height:20
				
				label LBL_stringConvert "StringTest" 
				edittext ETD_normalString width:85 offset:[0,0] align:#center across:2 
				edittext ETD_theConvert width:85 offset:[0,0] align:#right
				
				edittext ETD_userVisible text:"0c2330232f" width:85 offset:[0,0] align:#center readOnly:true across:2 
				edittext ETD_pwVisible text:"0c2330232f373839" width:85 offset:[0,0] align:#right readOnly:true
				
				fn loadValue nameEnter: =
				(
					theCheck = ""
					if nameEnter != undefined then
					(
						lel_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + \
												"abcdefghijklmnopqrstuvwxyz" + \
												"0123456789+/"
						for i = 1 to nameEnter.count do (
							for m = 1 to lel_chars.count where lel_chars[m] == nameEnter[i] do 
								(
									theCheck += (if ((bit.IntAsHex m) as string).count == 2 then ((bit.IntAsHex m) as string)else("0"+(bit.IntAsHex m) as string))
								)
						)
					)
					return theCheck
				)
								
				fn convertBase64ToString nameEnter: =
				(
					theCheck = ""
					if nameEnter != undefined then
					(
						lel_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + \
												"abcdefghijklmnopqrstuvwxyz" + \
												"0123456789+/"
						try (
							for i = 1 to nameEnter.count by 2 do theCheck += (lel_chars[(bit.HexAsInt (nameEnter[i] + nameEnter[i+1]))]) 
							)
						catch (theCheck = "Invalid String")
					)
					return theCheck
				)
				
				on ETD_normalString entered theValue do
				(
					ETD_theConvert.text = (loadValue nameEnter:theValue)
				)
				
				on ETD_theConvert entered theValue do
				(
					ETD_normalString.text = (convertBase64ToString nameEnter:theValue)
				)
				
				on ETD_user_ID entered theValue do
				(
					userLoad = ((loadValue nameEnter:theValue) == "0c2330232f")
				)
				on ETD_pass_ID entered theValue do
				(
					userPass = ((loadValue nameEnter:theValue) == "0c2330232f373839")
				)
				on BTN_confirmation_ID pressed do
				(
					setFocus adminCheck 
					if (if (classOf userLoad) == BooleanClass then (try(userLoad) catch(False)) else (False)) \
						and (if (classOf userPass) == BooleanClass then (try(userPass) catch(False)) else (False)) then 
					(
						messagebox ("Correct")
					)
					else (messagebox ("Wrong Password"))
					destroyDialog adminCheck
				)
				on BTN_cancel_ID pressed do
				(
					destroyDialog adminCheck
				)
			)
			try (createDialog adminCheck width:200 height:140) catch ()
		)
	)
	rollout theOutputPreview "Preview"
	(
		local main_Bitpreview_height = 200
		local main_Bitpreview_width = 350
		local main_SPN_width = 75
		
		local draw_bitmap = dotNetObject "System.Drawing.Bitmap" main_Bitpreview_width main_BITpreview_height
		
		local _selected = false
		
		checkBox CHK_blueRegion "Blue Region" checked:true across:4
		checkBox CHK_purpleRegion "Purple Region" checked:true 
		checkBox CHK_crossRegion "Cross Region" checked:false
		checkBox CHK_drawMode "Draw" checked:false 
		
		colorPicker CLP_theColor across:4 color:(color 0 0 0)
		spinner SPN_size "Size:" align:#left width:main_SPN_width type:#integer offset:[0,0] range:[15,75,35] 
		spinner SPN_xValue "Pos X:" align:#left width:main_SPN_width type:#integer offset:[0,0] range:[0,main_Bitpreview_width,0]
		spinner SPN_yValue "Pos Y:" align:#left width:main_SPN_width type:#integer offset:[0,0] range:[0,main_Bitpreview_height,0]
		
		dotNetControl BIT_Preview "System.Windows.Forms.PictureBox" height:main_Bitpreview_height width:main_Bitpreview_width
		
		-- initilized
		fn initDialog =
		(
			BIT_Preview.Cursor = dotNetObject "Cursor" ((dotNetClass "Autodesk.Max.GlobalInterface").Instance.COREInterface.GetSysCursor 6) -- Select
		)
		fn updatePreview =
		(
			BIT_Preview.Invalidate()
		)
		
		-- on state and open setup
		on theOutputPreview rolledUp state do
		(
			updateRollout()
		)
		on theOutputPreview open do
		(
			initDialog()
		)
		
		-- checkBox
		on CHK_purpleRegion changed theState do
		(
			updatePreview()
		)
		on CHK_blueRegion changed theState do
		(
			updatePreview()
		)
		on CHK_crossRegion changed theState do
		(
			updatePreview()
		)
		
		-- spinner for x coord
		on SPN_xValue changed theValue do
		(
			updatePreview()
		)
		-- spinner for y coord
		on SPN_yValue changed theValue do
		(
			updatePreview()
		)
		-- update rollout when region size changed
		on SPN_size changed theValue do
		(
			updatePreview()
		)
		
		-- for drawing on preview dotnet
		fn getLocation mouseEventArgs =
		(
			theX = amax 0 (amin mouseEventArgs.X (BIT_Preview.width - 1))
			theY = amax 0 (amin mouseEventArgs.Y (BIT_Preview.height - 1))
			[(theX + 0.5) / BIT_Preview.width, (theY + 0.5) / BIT_Preview.height]
		)
		fn createLocationIndicatorBitmap size: =
		(
			theSizeOfArea = 5
			halfCrossSize = 1
			theBitmap = dotNetObject "System.Drawing.Bitmap" size size
			theBackColor = (dotNetClass "System.Drawing.Color").Transparent
			theAreaColor = (dotNetClass "System.Drawing.Color").Blue
			theForeColor = (dotNetClass "System.Drawing.Color").Magenta
			for y = 0 to (size - 1) do (
				for x = 0 to (size - 1) do (
					theBitmap.SetPixel x y (
						if (y == 0 or y == size-1) and CHK_purpleRegion.checked then theForeColor 
						else if (x == 0 or x == size-1) and CHK_purpleRegion.checked then theForeColor
						else if (y == ((size/2) as integer) and x == ((size/2) as integer)) then theForeColor
						
						--else if (y == ((size/2) as integer) and x == ((size/2) as integer) and CHK_crossRegion.checked) then theForeColor
						else if (y == ((size/2-halfCrossSize) as integer) and x == ((size/2-halfCrossSize) as integer) and CHK_crossRegion.checked) then theForeColor
						else if (y == ((size/2+halfCrossSize) as integer) and x == ((size/2+halfCrossSize) as integer) and CHK_crossRegion.checked) then theForeColor
						else if (y == ((size/2-halfCrossSize) as integer) and x == ((size/2+halfCrossSize) as integer) and CHK_crossRegion.checked) then theForeColor
						else if (y == ((size/2+halfCrossSize) as integer) and x == ((size/2-halfCrossSize) as integer) and CHK_crossRegion.checked) then theForeColor
						
						else if ((y == ((size/2-theSizeOfArea) as integer) and (x >= ((size/2-theSizeOfArea) as integer)) and (x <= ((size/2+theSizeOfArea) as integer)) or \ 
						(y == ((size/2+theSizeOfArea) as integer)) and (x >= ((size/2-theSizeOfArea) as integer))) and (x <= ((size/2+theSizeOfArea) as integer))) and CHK_blueRegion.checked then theAreaColor
						else if ((x == ((size/2-theSizeOfArea) as integer) and (y <= ((size/2+theSizeOfArea) as integer)) and (y >= ((size/2-theSizeOfArea) as integer)) or \ 
						(x == ((size/2+theSizeOfArea) as integer)) and (y <= ((size/2+theSizeOfArea) as integer)) and (y >= ((size/2-theSizeOfArea) as integer)))) and CHK_blueRegion.checked  then theAreaColor
						else theBackColor
						)
				)
			)
			theBitmap	
		)
		fn drawOnPreview doDraw: size:3 =
		(
			if doDraw then
			(
				for x = -size to size do (
					for y = -size to size do (
						if x == 0  or y == 0 then (
							theColorInput = (dotNetClass "System.Drawing.Color").FromArgb CLP_theColor.color.r CLP_theColor.color.g CLP_theColor.color.b
							try (draw_bitmap.SetPixel (SPN_xValue.value + x) (SPN_yValue.value + y) theColorInput) catch ()
						)
						
						if x == 1 or y == 1  then (
							theColorInput = (dotNetClass "System.Drawing.Color").FromArgb (CLP_theColor.color.r/2) (CLP_theColor.color.g/2) (CLP_theColor.color.b/2)
							try (draw_bitmap.SetPixel (SPN_xValue.value + x) (SPN_yValue.value + y) theColorInput) catch ()
						)
					)
				)
				BIT_Preview.Image = draw_bitmap
			)
		)
		
		-- actions for preview
		on BIT_Preview MouseDown arg do
		(
			if not _selected then (
				SPN_xValue.value = (((getLocation arg)[1]) * BIT_Preview.width) as integer
				SPN_yValue.value = (((getLocation arg)[2]) * BIT_Preview.height) as integer
				updatePreview()
			)
			_selected = true
		)
		on BIT_Preview MouseUp arg do
		(
			updatePreview()
			_selected = false
		)
		on BIT_Preview MouseMove arg do
		(
			if _selected then (
				SPN_xValue.value = (((getLocation arg)[1]) * BIT_Preview.width) as integer
				SPN_yValue.value = (((getLocation arg)[2]) * BIT_Preview.height) as integer
			)
			drawOnPreview doDraw:CHK_drawMode.checked
			updatePreview()
		)
		on BIT_Preview Paint arg do
		(
			if not _selected then
			(
				thePosition = dotNetObject "System.Drawing.Point" ((SPN_xValue.value)-SPN_size.value/2) ((SPN_yValue.value)-SPN_size.value/2)
				theDraw = dotNetObject "System.Drawing.Bitmap" (createLocationIndicatorBitmap size:SPN_size.value)
				arg.Graphics.DrawImage theDraw thePosition
			)
		)
	)
	rollout theOutputList "theOutputList"
	(
		local itemsListTest = #("C:\\Users\\335\\Documents\\3dsMax\\_script\\log.txt","yolo","thing")
		local main_BTN_width = 160
		local main_BTN_height = 20
		
		button BTN_addToList "Add" width:main_BTN_width height:main_BTN_height across:2
		button BTN_remove "Remove" width:main_BTN_width height:main_BTN_height
		edittext EDT_textLine "Input:" 
		
		multilistbox MLB_listLocation "locations" items:itemsListTest height:5 align:#left offset:[0,0] enabled:true
		on theOutputList rolledUp state do
		(
			updateRollout()
		)
		on BTN_addToList pressed do
		(
			theListAdd = MLB_listLocation.items
			if EDT_textLine.text != "" then appendIfUnique theListAdd EDT_textLine.text else appendIfUnique theListAdd "N/A"
			MLB_listLocation.items = theListAdd
		)
		on BTN_remove pressed do
		(
			-- small bug found to fix later
			theListRemoval = MLB_listLocation.items
			for i in MLB_listLocation.selection do (
				deleteItem theListRemoval (findItem theListRemoval (MLB_listLocation.items[(MLB_listLocation.selection as array)[1]]))
			)
			MLB_listLocation.items = theListRemoval
		)
		on MLB_listLocation doubleclicked val do
		(
			try (
				location = MLB_listLocation.items[val]
				if (doesFileExist location) then (shellLaunch "explorer.exe" ("\"" + location + "\\" + "\""))
				else (messagebox "Error: File not found")
			)
			catch (messagebox "Error: Open path failed")
		)
		on MLB_listLocation rightclick val do
		(
			MLB_listLocation.selection = #()
		)
		on MLB_listLocation selected val do
		(
			if false then valueGet = ((substituteString (substituteString (MLB_listLocation.selection as string) "#{" "") "}" "") as integer)
			if valueGet != undefined then
			(
				MLB_listLocation.selection = #(((substituteString (substituteString (MLB_listLocation.selection as string) "#{" "") "}" "") as integer))
			)
		)
	)
	-- rollouts array
	theRolloutsStore = #(theOutput, theOutputAdmin,theOutputPreview,theOutputList)
	closedRollouts = #(2,3,4)
	-- add rollouts
	for rollouts in theRolloutsStore do try (addRollout rollouts theMainRollout) catch (messageBox ("failed" + rollouts as string))
	-- closed based on array
	for rollouts = 1 to theRolloutsStore.count where (findItem closedRollouts rollouts) != 0 do theRolloutsStore[rollouts].open = false
	-- updated
	updateRollout()
)
