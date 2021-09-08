import fabrica_profile_automation

"""
Fabrica automation
- create folders,folders
- add background to PNG's with transparency
- move files from one folder to their specific folders/subfolders
"""

if __name__ == '__main__':
    # folder/subfolder creator

    work_location = r"C:\_work\dan\Profile_Phase_6\renders_to_sort"
    list_folder = ["Trafor-3","BC07-PU","BC24-PU","BC37","BC38"]
    list_subfolders = ["3d", "dxg", "images"]

    # background folders inputs
    imageLocation = [r"C:\_work\dan\Profile_Phase_6\renders"] # can do for multiple locations
    imageNames = ["xps_n","xps_n_s"] # for specific add

    # move to folders values
    var_to_folder = r"C:\_work\dan\Profile_Phase_6\renders_to_sort"
    var_from_folder = r"C:\_work\dan\Profile_Phase_6\renders"
    list_check_values = ["bk", "fc"]

    # RUN

    # Create folders/subfolders
    #fabrica_profile_automation.FoldersSubfoldersProfileCreator().create_folders(work_location, folder_to_create = list_folder, list_subfolders_to_create = list_subfolders)

    # Add white and
    #fabrica_profile_automation.AddBackgroundToImages().specific_add(image_names = imageNames, locations = imageLocation, colors = [(255,255,255),(153,153,153)])
    fabrica_profile_automation.AddBackgroundToImages().general_add(locations = imageLocation)

    #fabrica_profile_automation.MoveFilesToFoldersName().move_to_folders(var_from_folder, var_to_folder, list_check_values,index_size = 4)

    # END