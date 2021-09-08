import subprocess
from subprocess import Popen, CREATE_NEW_CONSOLE
import os
from PIL import Image

def make_temp(loc, name):

    if not os.path.exists(loc + "\\temp\\"):
        os.makedirs(loc + "\\temp\\")
    nameBlank = (loc + "\\temp\\" + name)
    return nameBlank

def resize_file(loc, name, size = 100):

    size = 100/size

    nameTemp = make_temp(loc,"resized.png")
    imageLoad = Image.open(name)

    print (nameTemp)
    imageLoad = imageLoad.resize((int(imageLoad.size[0]/size),int(imageLoad.size[1]/size)), Image.ANTIALIAS)
    imageLoad.save(nameTemp)

    return nameTemp

def startcmd(value):
    terminal = 'cmd'
    command = 'Python'
    #command = terminal + ' ' + '/c' + ' ' + value
    command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    proc = subprocess.Popen(command, creationflags=CREATE_NEW_CONSOLE)

location = r"C:\_work\dan\Profile_Phase_5\save"
added_logo = r"C:\_work\dan\Profile_Phase_5\Daos_studio_logo_dark.png"
the_video = r"C:\_work\dan\Profile_Phase_5\save\out1.mp4"
file_name = r"C:\_work\dan\Profile_Phase_5\save\out_logo"

theCommand = f"ffmpeg -y -i {the_video} -i {added_logo} -filter_complex \"overlay=x=main_w-overlay_w-(main_w*0.01):y=main_h-overlay_h-(main_h*0.01)\" {added_logo}.mp4"

#startcmd(theCommand)

resize_file(location, added_logo, size = 50 )