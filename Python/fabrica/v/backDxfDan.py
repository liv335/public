from pathlib import Path
import shutil
import os
searchLocation = r"C:\Users\335\Google Drive\Dan_profile\Dan_profile_2016"
copyLocation = r"C:\_work\Profile_Phase_4\DxfFolder"
cnt = 0
for files in Path(searchLocation).glob("**/*"):
    #print (files.suffix)
    if files.suffix == ".dxf":
        subfolder = (copyLocation + str(files).split(searchLocation)[1]).split(((copyLocation + str(files).split(searchLocation)[1]).split("\\"))[len((copyLocation + str(files).split(searchLocation)[1]).split("\\"))-1])[0].split("Varianta_finala")[1]
        try:
            shutil.copy(str(files),(copyLocation + subfolder + files.name))
        except FileNotFoundError:
            os.makedirs(copyLocation + subfolder)
            shutil.copy(str(files), (copyLocation + subfolder + files.name))
