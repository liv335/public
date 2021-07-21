------------------------------------------------------------------------------------------------------------------------------
-- Data functions - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- pothlib, similar to python pathlib
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	fn pathFile fileCheck: =
	(
		local filterFile = (filterstring fileCheck "\\")
		local fileName = (filterString (filterFile[filterFile.count]) ".")
		struct theFileStruct
		(
			fullPath,
			parts,
			parent,
			fullName,
			fileName,
			suffix
		)
		theFile = theFileStruct()
		theFile.fullPath = fileCheck
		theFile.parts = filterFile
		theFile.parent = (substring fileCheck 1 (fileCheck.count - (filterFile[filterFile.count]).count - 1))
		theFile.fullName = (substring (filterFile[filterFile.count]) 1 fileCheck.count)
		theFile.fileName = (filterString (filterFile[filterFile.count]) ".")[1]
		theFile.suffix = (substring (filterFile[filterFile.count]) (fileName[1].count+1) fileCheck.count)
		return theFile
	)
	
	pathFile fileCheck:theFile
)