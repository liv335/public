------------------------------------------------------------------------------------------------------------------------------
-- callback experiment - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- script for automatic readouts when selecting
-- added some buttons to change wirecolors
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	if RLT_displayInfo != undefined then (destroyDialog RLT_displayInfo) else (RLT_displayInfo = undefined)
	global RLT_displayInfo
	
	var_main_height = 100
	var_main_width = 200
	var_btn_color = 30
	
	fn registerCallbacks =
	(
		callbacks.removeScripts id:#DisplayInfoActive
		for theEvent in #(#selectionSetChanged) do (
			callbacks.addScript theEvent @"(
				try (
					RLT_displayInfo.BTN_hiddenUpdate.pressed()
					) 
				catch ())" id:#DisplayInfoActive
		)
	)
	
	fn selectionReturn =
	(
		currentLayers = #()
		local theState
		
		for geo in selection do (appendIfUnique currentLayers geo.layer.name)
		
		if currentLayers.count == 1 then theState = currentLayers[1]
		else if currentLayers.count == 0 then theState = "No Selection"
		else theState = "Multi Layers"
		
		return theState
	)
	
	fn unregisterCallbacks =
	(
		callbacks.removeScripts id:#DisplayInfoActive
	)
	
	fn __init__ =
	(
		unregisterCallbacks()
		registerCallbacks()
	)
	
	__init__()
	
	rollout RLT_displayInfo "DisplayInfo"
	(
		edittext EDT_currentLayer "CurrentLayer:" Text:(selectionReturn()) LabelOnTop:true readOnly:true
		button BTN_hiddenUpdate width:0 height:0
		
		dotnetcontrol BTN_blue "System.Windows.Forms.Button" height:var_btn_color width:var_btn_color across:3
		dotnetcontrol BTN_green "System.Windows.Forms.Button" height:var_btn_color width:var_btn_color
		dotnetcontrol BTN_red "System.Windows.Forms.Button" height:var_btn_color width:var_btn_color		
		on RLT_displayInfo open do
		(
			BTN_blue.backcolor = (DotNetClass "System.Drawing.Color").fromARGB 0 0 255
			BTN_green.backcolor = (DotNetClass "System.Drawing.Color").fromARGB 0 255 0
			BTN_red.backcolor = (DotNetClass "System.Drawing.Color").fromARGB 255 0 0
		)
		
		on BTN_blue click do
		(
			for obj in selection do obj.wirecolor = (color 0 0 255)
		)
		
		on BTN_green click do
		(
			for obj in selection do obj.wirecolor = (color 0 255 0)
		)
		
		on BTN_red click do
		(
			for obj in selection do obj.wirecolor = (color 255 0 0)
		)
		
		on BTN_hiddenUpdate pressed do
		(
			EDT_currentLayer.text = selectionReturn()
		)
		on RLT_displayInfo close do
		(
			unregisterCallbacks()
			RLT_displayInfo = undefined
		)
	)
	CreateDialog RLT_displayInfo height:var_main_height width:var_main_width
)