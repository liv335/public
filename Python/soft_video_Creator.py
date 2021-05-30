from tkinter import *
from PIL import Image ,ImageFont, ImageDraw
import subprocess
from subprocess import Popen, CREATE_NEW_CONSOLE
from pathlib import Path
import os

#localPath = r"C:\Users\335\Desktop\ProductionTesting\ProductionTesting\00002 - paintCan\local_renderPass\presetStep-0_0.0\local_renderPass\_compose"

#input1 = (localPath + os.sep + "blank_1.png")
#whiteBackground.save(localPath + os.sep + "blank_1.png")

#input4 = (localPath + os.sep + "blank_4.png")
#whiteBackground.save(localPath + os.sep + "blank_4.png")

def text_wrap(text,font,writing,max_width,max_height):
    lines = [[]]
    words = text.split()
    for word in words:
        print(word)
        # try putting this word in last line then measure
        lines[-1].append(word)
        (w,h) = writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]), font=font)
        if w > max_width: # too wide
            # take it back out, put it on the next line, then measure again
            lines.append([lines[-1].pop()])
            (w,h) = writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]), font=font)
            if h > max_height: # too high now, cannot fit this word in, so take out - add ellipses
                lines.pop()
                # try adding ellipses to last word fitting (i.e. without a space)
                #lines[-1][-1] += '...'
                # keep checking that this doesn't make the textbox too wide,
                # if so, cycle through previous words until the ellipses can fit
                while writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]),font=font)[0] > max_width:
                    lines[-1].pop()
                    #lines[-1][-1] += '...'
                break
    return '\n'.join([' '.join(line) for line in lines])

def addtext(imag,color,pos,tsize,textWrite,boxsize):
    theFont = (r"C:\Klearn\video\AdobeArabic-Bold.otf")
    imag = Image.open(imag)
    draw = ImageDraw.Draw(imag)
    font = ImageFont.truetype(theFont, tsize)

    textWrite = text_wrap(textWrite, font, draw, boxsize[0], boxsize[1])
    print(font.getsize(textWrite)[0])

    draw.text(pos, textWrite, color, font=font)
    imag.save(imag.filename)
    return draw

def checkimageinput(imag, imag2):
    theCheck = False
    theSize = (0,0)
    try:
        imag = Image.open(imag)
        imag2 = Image.open(imag2)
        theCheck = (imag.size[1] == imag2.size[1] and imag.size[0] == imag2.size[0])
        theSize = imag.size
    except FileNotFoundError:
        pass
    return theCheck, theSize

def createBlankImage(loc,size,name,color):
    nameBlank = (loc + os.sep + name)
    whiteBackground = Image.new("RGB", size, color)
    whiteBackground.save(nameBlank)
    return nameBlank

def removeTemp(loc):
    os.remove(loc)

def startcmd(value):
    terminal = 'cmd'
    command = 'Python'
    command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    proc = subprocess.Popen(command, creationflags=CREATE_NEW_CONSOLE)

def runApp():
    pass
runApp()
# main variables
#localPath = r"C:\Users\335\Documents\3dsMax\scenes\00007_gabyTest"
localPath = r"C:\Users\335\Downloads\waize\textures\rendering_maps\animation"
ffmpegLoc = r"C:\_work\_script\ffmpeg\bin\ffmpeg.exe"
savePath = localPath + os.sep + "out.mp4"
#path = r"C:\Users\335\Documents\3dsMax\scenes\00007_gabyTest\render_output"
path = r"C:\Users\335\Downloads\waize\textures\rendering_maps\animation"
filename = r"\turnable_s"

theCommand = f"{ffmpegLoc} -t 4 -framerate 8 -i {path}{filename}%d.png {savePath}"
print(theCommand)
startcmd(theCommand)


#removeTemp(input1)
#removeTemp(input4)
