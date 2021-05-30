from tkinter import *
from tkinter import filedialog,messagebox,colorchooser
from PIL import Image ,ImageFont, ImageDraw
import subprocess
from subprocess import Popen, CREATE_NEW_CONSOLE
from pathlib import Path
import os

def loadimage1():
    path = filedialog.askopenfilename()
    if path != None:
        var_input2.set(path)

def loadimage2():
    path = filedialog.askopenfilename()
    if path != None:
        var_input3.set(path)

def loadsave():
    path = filedialog.askdirectory()
    if path != None:
        var_saveloc.set(path)

def checkFile(loc):
    num = 0
    while os.path.exists(loc):
        try:
            num = int(loc.split(".")[0][-1])
            num += 1
            loc = loc.split(".")[0][:-1] + str(num) + "." + loc.split(".")[1]
        except ValueError:
            break
    return loc

def text_wrap(text,font,writing,max_width,max_height):
    lines = [[]]
    words = text.split()
    for word in words:
        #print(word)
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
    theFont = var_font.get()
    imag = Image.open(imag)
    draw = ImageDraw.Draw(imag)
    font = ImageFont.truetype(theFont, tsize)

    textWrite = text_wrap(textWrite, font, draw, boxsize[0], boxsize[1])
    #print(font.getsize(textWrite)[0])

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
    if not os.path.exists(loc + "/temp/"):
        os.makedirs(loc + "/temp/")
    nameBlank = (loc + "/temp/" + name)
    whiteBackground = Image.new("RGB", size, color)
    whiteBackground.save(nameBlank)
    return nameBlank

def removeTemp(loc):
    os.remove(loc)

def startcmd(value):
    terminal = 'cmd'
    command = 'Python'
    #command = terminal + ' ' + '/c' + ' ' + value
    command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    proc = subprocess.Popen(command, creationflags=CREATE_NEW_CONSOLE)

def choosecolor():
    # variable to store hexadecimal code of color
    color_code = colorchooser.askcolor(title ="Choose color")
    if color_code[0]!= None:
        button_color.config(bg=color_code[1])
        var_textcolor.set(color_code[0])

def choosefont():
    # variable to store hexadecimal code of color
    path = filedialog.askopenfilename()
    print(path[-4:])
    if path[-4:] == ".otf" or path[-4:] == ".ttf":
        var_font.set(path)

def runApp():
    # main variables
    localPath = var_saveloc.get()
    ffmpegLoc = var_ffmpeg.get()
    savePath = checkFile(localPath + "/" + "out1.mp4")

    # colors
    white = (255, 255, 255)
    black = (0, 0, 0)
    try:
        theTextColor = ([int(float(i)) for i in var_textcolor.get().replace("(","").replace(")","").split(",")])
        theTextColor = (theTextColor[0],theTextColor[1],theTextColor[2])
    except ValueError:
        theTextColor = black

    # options
    maxInputs = 4
    duration = int (var_duration.get() / maxInputs)

    # text inputs ?
    text1 = var_input1.get()
    text2 = var_input4.get()

    # image inputs
    input2 = var_input2.get()
    input3 = var_input3.get()

    theInput = checkimageinput(input2, input3)
    if theInput[0]:
        #print(int(var_textsize.get() / 100))
        textSize = int(theInput[1][1] * (var_textsize.get()/100))

        posY = (theInput[1][1] / 2) - textSize / 2
        #print(posY)

        input1 = createBlankImage(localPath, theInput[1], "blank_1.png", white)
        addtext(input1, theTextColor, (50, posY), textSize, text1, (theInput[1][0] - 50, theInput[1][1] - 50))

        input4 = createBlankImage(localPath, theInput[1], "blank_4.png", white)
        addtext(input4, theTextColor, (50, posY), textSize, text2, (theInput[1][0] - 50, theInput[1][1] - 50))

        theInputs = [f"-loop 1 -t {duration} -i {input1} ",
                        f"-loop 1 -t {duration} -i {input2} ",
                        f"-loop 1 -t {duration} -i {input3} ",
                        f"-loop 1 -t {duration} -i {input4} ",]
        theDelays = ["-3","+1","+2","+4"]
        theComplexFilter = [f"[0:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{theDelays[0]}/TB[f0]; ",
                            f"[1:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{theDelays[1]}/TB[f1]; ",
                            f"[2:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{theDelays[2]}/TB[f2]; ",
                            f"[3:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{theDelays[3]}/TB[f3]; ",
                            "[0][f0]overlay[bg1];","[bg1][f1]overlay[bg2];","[bg2][f2]overlay[bg3];","[bg3][f3]overlay",",format = yuv420p[v]"]
        theOptions = [" -map \"[v]\"  "]
        theCommand = f"{ffmpegLoc} "

        for i in theInputs:
            theCommand += i
        theCommand += "-filter_complex \""
        for f in theComplexFilter:
            theCommand += f
        theCommand = theCommand + "\""
        for o in theOptions:
            theCommand += o
        theCommand += f"{savePath}"

        """
        theCommand = f"{ffmpegLoc} \
-loop 1 -t {duration} -i {input1} \
-loop 1 -t {duration} -i {input2} \
-loop 1 -t {duration} -i {input3} \
-loop 1 -t {duration} -i {input4} \
\
-filter_complex \
\"[0:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS-3/TB[f0]; \
[1:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+1/TB[f1]; \
[2:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+3/TB[f2]; \
[3:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+8/TB[f3]; \
[0][f0]overlay[bg1];\
[bg1][f1]overlay[bg2];\
[bg2][f2]overlay[bg3];\
[bg3][f3]overlay,\
format=yuv420p[v]\" -map \"[v]\"  \
{savePath}"
"""
        print(theCommand)
        startcmd(theCommand)
    else:
        messagebox.showinfo("Error","Something went wrong, inputs, missing files")
        print("Error: something went wrong, inputs, missing files")
    pass

def testSomething():
    pass

#removeTemp(input1)
#removeTemp(input4)

if __name__ == "__main__":
    #Create window
    app = Tk()

    # variables
    # ffmpeg -- to investigate python module
    var_ffmpeg = StringVar()
    var_ffmpeg.set(r"C:\_work\_script\ffmpeg\bin\ffmpeg.exe")
    if not os.path.exists(var_ffmpeg.get()):
        var_ffmpeg.set(os.getcwd() + os.sep + "app" + os.sep + "ffmpeg.exe")

    # font
    var_font = StringVar()
    var_font.set(r"C:\Klearn\video\AdobeArabic-Bold.otf")
    if not os.path.exists(var_font.get()):
        var_font.set(os.getcwd() + "/" + "app" + "/" + "AdobeArabic-Bold.otf")

    var_duration = IntVar()
    var_duration.set(8)
    var_textsize = IntVar()
    var_textsize.set(20)
    var_textcolor = StringVar()
    var_textcolor.set("(0.0,0.0,0.0)")

    var_saveloc = StringVar()
    var_saveloc.set("Select Folder Path")

    var_input1 = StringVar()
    var_input1.set("Transforma-ti Casa")
    var_input2 = StringVar()
    var_input2.set("Load Image 1")
    var_input3 = StringVar()
    var_input3.set("Load Image 2")
    var_input4 = StringVar()
    var_input4.set("fabricadeprofile.ro")

    frm_top = Frame(app)
    frm_top.pack(side="top")

    # entry input 1/text
    lb_1 = Label(frm_top, text="Text input 1")
    lb_1.pack()

    frm_1 = Frame(frm_top)
    frm_1.pack(side="top")
    entry_1 = Entry(frm_1,width= 50, textvariable = var_input1)
    entry_1.pack(side="left")
    btn_s = Button(frm_1, text="Load Input", command=loadsave, width=10, height=1, bg='grey',state="disabled")
    btn_s.pack(side="left")

    # entry input 2/image
    lb_2 = Label(frm_top, text="Image Input 1")
    lb_2.pack()

    frm_2 = Frame(frm_top)
    frm_2.pack(side="top")
    entry_2 = Entry(frm_2,width= 50, textvariable = var_input2)
    entry_2.pack(side="left")
    btn_2 = Button(frm_2, text="Load Input", command=loadimage1, width=10, height=1, bg='yellow')
    btn_2.pack(side="left")

    # entry input 3/image
    lb_3 = Label(frm_top, text="Image Input 2")
    lb_3.pack()

    frm_3 = Frame(frm_top)
    frm_3.pack(side="top")
    entry_3 = Entry(frm_3,width= 50, textvariable = var_input3)
    entry_3.pack(side="left")
    btn_3 = Button(frm_3, text="Load Input", command=loadimage2, width=10, height=1, bg='yellow')
    btn_3.pack(side="left")

    # entry input 3/image
    lb_4 = Label(frm_top, text="Text Input 2")
    lb_4.pack()

    frm_4 = Frame(frm_top)
    frm_4.pack(side="top")
    entry_4 = Entry(frm_4,width= 50, textvariable = var_input4,state="disabled")
    entry_4.pack(side="left")
    btn_4 = Button(frm_4, text="Load input", command=loadimage2, width=10, height=1, bg='grey',state="disabled")
    btn_4.pack(side="left")

    # save location
    lb_s = Label(frm_top, text="Save Location")
    lb_s.pack()

    frm_s = Frame(frm_top)
    frm_s.pack(side="top")
    entry_s = Entry(frm_s,width= 50, textvariable = var_saveloc)
    entry_s.pack(side="left")
    btn_s = Button(frm_s, text="Save Location", command=loadsave, width=10, height=1, bg='yellow')
    btn_s.pack(side="left")

    #options
    frm_o = Frame(frm_top)
    frm_o.pack(side="top")

    lb_o = Label(frm_o, text="Duration")
    lb_o.pack(side="left")
    entry_d = Entry(frm_o, width= 7, textvariable = var_duration, state="disabled")
    entry_d.pack(side="left")

    lb_d = Label(frm_o, text="Text Size %")
    lb_d.pack(side="left")
    entry_ts = Entry(frm_o, width= 7, textvariable = var_textsize, state="normal")
    entry_ts.pack(side="left")

    button_color = Button(frm_o, text="Text Color", command=choosecolor, width=10, height=1, bg='black', fg='grey')
    button_color.pack(side="left")
    button_font = Button(frm_o, text="Text Font", command=choosefont, width=10, height=1, bg='black', fg='grey')
    button_font.pack(side="left")

    # run
    button_run = Button(frm_top, text="Make Video", command=runApp, width=15, height=2, bg='green')
    button_run.pack()
    #button_test = Button(frm_top, text="Test", command=testSomething, width=15, height=2, bg='green')
    #button_test.pack()

    app.title('video')
    app.minsize(500, 320)
    app.maxsize(500, 320)
    app.geometry("320x100")

    app.mainloop()
