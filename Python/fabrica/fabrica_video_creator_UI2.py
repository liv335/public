from tkinter import *
from tkinter import filedialog,messagebox,colorchooser
from PIL import Image ,ImageFont, ImageDraw
import subprocess
from subprocess import Popen, CREATE_NEW_CONSOLE
from pathlib import Path
import os

def load(i):
    path = filedialog.askopenfilename()
    if path != None:
        input_array[i].set(path)
        checkbox_array[i].deselect()
        bool_array[i] = False
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

    draw.text(pos, textWrite, color, font = font)
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
def changeBool(i):
    bool_array[i] = not bool_array[i]

def removeTemp(loc):
    os.remove(loc)
def startcmd(value):
    terminal = 'cmd'
    command = 'Python'
    #command = terminal + ' ' + '/c' + ' ' + value
    command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    proc = subprocess.Popen(command, creationflags = CREATE_NEW_CONSOLE)

def choosecolor():
    # variable to store hexadecimal code of color
    color_code = colorchooser.askcolor(title = "Choose color")
    if color_code[0]!= None:
        button_color.config(bg = color_code[1])
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
    if os.path.exists(localPath) and os.path.exists(ffmpegLoc):
        print(localPath)
        print(os.path.exists(localPath))
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
        max_inputs = 4
        duration = int (var_duration.get() / max_inputs)

        theInput = (True,(2560,1920))
        if theInput[0]:
            #print(int(var_textsize.get() / 100))
            textSize = int(theInput[1][1] * (var_textsize.get()/100))

            posY = (theInput[1][1] / 2) - textSize / 2

            failed_input = "Missing Image Input"
            temp_filename = "blank"
            inputs = {}

            # too lazy to optimize now
            for b in range(len(bool_array)):
                if bool_array[b]:
                    text = input_array[b].get()
                    input_create_blank = createBlankImage(localPath, theInput[1], temp_filename + f"{b}.png", white)
                    addtext(input_create_blank, theTextColor, (50, posY), textSize, text, (theInput[1][0] - 50, theInput[1][1] - 50))

                    inputs[b] = input_create_blank
                else:
                    if os.path.exists(input_array[b].get()):
                        inputs[b] = input_array[b].get()
                    else:
                        text = "Failed::" + input_array[b].get()
                        input_create_blank = createBlankImage(localPath, theInput[1], temp_filename + f"{b}.png", white)
                        addtext(input_create_blank, theTextColor, (50, posY), textSize, text,(theInput[1][0] - 50, theInput[1][1] - 50))
                        inputs[b] = input_create_blank

            the_inputs = []
            the_complex_filter_loop = []
            the_complex_filter_options = ["[0][f0]overlay[bg1];","[bg1][f1]overlay[bg2];","[bg2][f2]overlay[bg3];","[bg3][f3]overlay",",format = yuv420p[v]"]
            the_delays = ["-3", "+1", "+2", "+4"]

            for i in range(max_inputs):
                inputs_values = f"-loop 1 -t {duration} -i {inputs[i]} "
                the_inputs.append(inputs_values)

            for i in range(max_inputs):
                filter_inputs = f"[{i}:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{the_delays[i]}/TB[f{i}]; "
                the_complex_filter_loop.append(filter_inputs)

            the_complex_filter = the_complex_filter_loop + the_complex_filter_options

            theOptions = [" -map \"[v]\"  "]
            theCommand = f"{ffmpegLoc} "

            for i in the_inputs:
                theCommand += i
            theCommand += "-filter_complex \""
            for f in the_complex_filter:
                theCommand += f
            theCommand = theCommand + "\""
            for o in theOptions:
                theCommand += o
            theCommand += f"{savePath}"

            print(theCommand)
            startcmd(theCommand)
        else:
            messagebox.showinfo("Error","Something went wrong, inputs, missing files")
            print("Error: something went wrong, inputs, missing files")
        pass
def testSomething():
    pass

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

    # global variables
    var_duration = IntVar()
    var_duration.set(8)
    var_textsize = IntVar()
    var_textsize.set(20)
    var_textcolor = StringVar()
    var_textcolor.set("(0.0,0.0,0.0)")

    var_saveloc = StringVar()
    var_saveloc.set("Select Folder Path")

    # main frame
    frm_top = Frame(app)
    frm_top.pack(side="top")

    # create dynamic interface
    input_text_array = ["Star Video", "Load Input", "Load Input", "End Video"]
    input_label_values = ["Input 1", "Input 2", "Input 3", "Input 4"]
    maxinputs = len(input_text_array)

    # array list
    label_array = {}
    input_array = {}
    bool_array = {}
    frame_array = {}
    entry_array = {}
    button_array = {}
    checkbox_array = {}

    for i in range(maxinputs):
        # labels
        the_label = Label(frm_top, text = input_label_values[i])
        label_array[i] = the_label
        label_array[i].pack()

        # string variable
        var_input = StringVar()
        input_array[i] = var_input
        input_array[i].set(input_text_array[i])

        # bool variable
        var_bool = BooleanVar()
        bool_array[i] = var_bool
        bool_array[i].set(True)

        # entry box
        the_frame = Frame(frm_top)
        frame_array[i] = the_frame
        frame_array[i].pack(side = "top")

        the_entry = Entry(frame_array[i], width = 50, textvariable = input_array[i])
        entry_array[i] = the_entry
        entry_array[i].pack(side = "left")

        the_button = Button(frame_array[i], text="Load Input",
                            width = 10, height = 1, bg = "grey", state = "normal")
        button_array[i] = the_button
        button_array[i].pack(side = "left")
        exec(f"button_array[{i}].config(command = lambda:load({i}))")

        the_checkbox = Checkbutton(frame_array[i], text="text",
                                   variable = bool_array[i], onvalue = 1, offvalue = 0)
        checkbox_array[i] = the_checkbox
        exec(f"checkbox_array[{i}].config(command = lambda:changeBool({i}))")
        checkbox_array[i].pack(side = "left")

    # save bar location and button
    frm_info_top = Frame(frm_top)
    frm_info_top.pack(side = "top")
    lb_o = Label(frm_info_top, text = "Options")
    lb_o.pack(side = "top")

    frm_s = Frame(frm_top)
    frm_s.pack(side = "top")
    entry_s = Entry(frm_s, width= 50, textvariable = var_saveloc)
    entry_s.pack(side = "left")
    btn_s = Button(frm_s, text="Save Location", command = loadsave,
                   width = 10, height = 1, bg='yellow')
    btn_s.pack(side = "left")

    # options
    frm_o = Frame(frm_top)
    frm_o.pack(side="top")

    lb_o = Label(frm_o, text="Duration")
    lb_o.pack(side="left")
    entry_d = Entry(frm_o, width= 7, textvariable = var_duration, state = "disabled")
    entry_d.pack(side="left")

    lb_d = Label(frm_o, text="Text Size %")
    lb_d.pack(side="left")
    entry_ts = Entry(frm_o, width= 7, textvariable = var_textsize, state = "normal")
    entry_ts.pack(side="left")

    button_color = Button(frm_o, text="Text Color", command = choosecolor,
                          width = 10, height = 1, bg = "black", fg = "grey")
    button_color.pack(side="left")
    button_font = Button(frm_o, text="Text Font", command = choosefont,
                         width = 10, height=1, bg = "black", fg = "grey")
    button_font.pack(side="left")

    # run
    button_run = Button(frm_top, text="Make Video", command = runApp,
                        width = 15, height = 2, bg = "green")
    button_run.pack()
    #button_test = Button(frm_top, text="Test", command=testSomething, width=15, height=2, bg='green')
    #button_test.pack()

    app.title('Fast Video Creator')
    app.minsize(500, 320)
    app.maxsize(500, 320)
    app.geometry("320x100")

    app.mainloop()
