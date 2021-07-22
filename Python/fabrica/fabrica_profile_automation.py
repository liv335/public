import os
import shutil
from PIL import Image
from pathlib import Path

__all__ = ["FoldersSubfoldersProfileCreator","create_folders"
           "AddBackgroundToImages","specific_add","general_add"
           "MoveFilesToFoldersName","move_to_folders"]

class FoldersSubfoldersProfileCreator:
    @staticmethod
    def __create_subfolders(path, subfolders_to_create):
        if os.path.exists(path):

            for sf in subfolders_to_create:

                try:
                    os.makedirs(path + os.sep + sf)
                except FileExistsError:
                    pass
        else:
            print("Error::Path Location doesn't exist")

    def create_folders(self, location, folder_to_create, list_subfolders_to_create):
        if os.path.exists(location):

            for f in folder_to_create:

                create_folder_path = location + os.sep + f

                try:
                    os.makedirs(create_folder_path)
                    print("Success::Folder Created::" + create_folder_path)
                    __create_subfolders(create_folder_path, subfolders_to_create = list_subfolders_to_create)
                except FileExistsError:
                    print("Warning::Folder Exists::" + f)
        else:
            print("Wou")

class AddBackgroundToImages:
    # adds background to values
    @staticmethod
    def __addbackground(img, color = (255,255,255)):
        if img is not None:

            c_prefix = "_" + str(color).replace(",","_").replace("(","").replace(")","")

            if color == (153,153,153):
                c_prefix = "g"
            elif color == (255,255,255):
                c_prefix = "a"

            # add background
            background = Image.new(img.mode,img.size,color)
            filesave = img.filename[:-4] + "_bk" + c_prefix + ".png"
            background.paste(img,(0,0),img)
            background.save(filesave)

    # loop for specific files
    def specific_add(self, image_names, image_locations, colors = [(255,255,255),(153,153,153)]):
        ext = ".png"
        for imloc in image_locations:

            # for each location
            for im in image_names:

                # for each name, if exists
                file = imloc + os.sep + im + ext
                if os.path.exists(file):
                    for cs in colors:
                        print("Processing:: " + file)
                        the_image = Image.open(file)
                        __addbackground(the_image,cs)
                else:
                    print("Not found ::" + file)

    # adds background based on name pattern
    def general_add(self, pattern = "bk",locations = None):
        if locations is not None:

            for imloc in locations:

                # for locations given
                for f in Path(imloc).glob("*" + pattern + "*"):

                    if os.path.exists(str(f)):

                        for cs in colors:

                            print("Processing:: " + str(f))
                            the_image = Image.open(str(f))
                            __addbackground(the_image,cs)
                    else:
                        print("Not found::" + str(f))

class MoveFilesToFoldersName:
    @staticmethod
    def move_to_folders(from_folder, to_folder, check_values, index_size = 2):
        for file in Path(from_folder).glob("*"):

            for ck in check_values:

                if ck in str(file):

                    for folders in Path(to_folder).glob(file.name[:index_size]+"*"):
                        move_to = str(folders) + os.sep + "images" + os.sep + file.name

                        if os.path.exists(str(file)):
                            shutil.move(str(file),move_to)
                            print(file.name + ":: was moved")