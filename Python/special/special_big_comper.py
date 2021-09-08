# Created by Livyx
# Short version
# Takes range of images in folder and creates composition based on Images in folder

# Long version
# Input a image location, and a save location
# Uses image location to generate a huge overview/compliation of all of the images inside a folder
# Manipulate the number of images per row using the value in row
# Function to resize final image at the end added

from tkinter import *
from tkinter import filedialog
from tkinter import messagebox
from PIL import Image
from pathlib import Path
import os

def loadpath():
    path = filedialog.askdirectory()
    vpath.set(path)

def loadsavepath():
    savepath = filedialog.askdirectory()
    vspath.set(savepath)

def bigcomp():
    totalnum = 0
    maxnum = 100
    try:
        s1 = int(vrow.get())
    except ValueError:
        messagebox.showwarning("Warning", "Decimals numbers not allowed, rounding it")
        print("If Number is float will roundup")
        try:
            s1 = int(float(vrow.get()))
        except ValueError:
            messagebox.showwarning("Warning", "Only numbers allowed, will default to 8")
            s1 = 8
    fileExt = vext.get()
    if totalnum <= maxnum:
        if s1 > 0:
            #load stuff
            path = vpath.get()
            savepath = vspath.get()
            x = 0
            # determin image size new load
            bigiwidth = 0
            bigiheight = 0
            for file in Path(path).glob('*' + fileExt):
                if x <= 1:
                    try:
                        imgbase = Image.open(file)
                    except PermissionError:
                        pass
                    x += 1
            # determin loop
            num = 1
            #bigiheight = imgbase.height
            for file in Path(path).glob('*' + fileExt):
                if totalnum <= maxnum:
                    if num <= s1:
                        bigiwidth += imgbase.width
                        #print(bigiwidth)
                        #print(1)
                    else:
                        pass
                    if num % s1 == True:
                        #print(2)
                        bigiheight += imgbase.height
                        #print(bigiheight)
                    if s1 == 1:
                        bigiheight = num*imgbase.height
                    totalnum += 1
                    num += 1
                print("image width will be: " + str(bigiwidth))
                print("image height will be: " + str(bigiheight))
            # reset count
            BBimg = Image.new('RGB', (bigiwidth, bigiheight), (255, 255, 255))
            x = 0
            y = 0
            num = 1
            num2 = 1
            totalnum = 0
            print("")
            try:
                for file in Path(path).glob('*' + fileExt):
                    if totalnum <= maxnum:
                        print(totalnum)
                        print(num2)
                        print(str(file.name))
                        imgbase = Image.open(file)
                        if fileExt == ".png" or fileExt == ".tif":
                            try:
                                BBimg.paste(imgbase, (x, y),imgbase)
                            except ValueError:
                                BBimg.paste(imgbase, (x, y))
                        else:
                            BBimg.paste(imgbase, (x, y))
                        if num <= s1:
                            x += imgbase.width
                        if num == s1:
                            y += imgbase.height
                            x = 0
                            num = 0
                        num += 1
                        num2 += 1
                        totalnum += 1
                        print("")
            except OSError:
                print(1)
                pass
                # resize image
            if vsize.get() != "100%":
                print(vsize.get())
                resvsize = vsize.get()
                if resvsize[2] == "%":
                    BBimg = BBimg.resize((int(BBimg.width*float(int(resvsize[:1])/10)),int(BBimg.height*float(int(resvsize[:1])/10))), Image.ANTIALIAS)
                print("resizing")
                print("width will be " + str(BBimg.width))
                print("height will be " + str(BBimg.height))
                print("")
                BBimg.save(savepath + os.sep + vname.get() + ".jpg")
            else:
                print("done")
                BBimg.save(savepath + os.sep + vname.get() + ".jpg")
        else:
            print("Items in rows cannot be 0 or negative value")
            messagebox.showwarning("Warning", "Rows cannot be 0 or negative value")

if __name__ == "__main__":

    #Create window
    app = Tk()
    app.title('BigCompApp')
    # variables path
    vpath = StringVar()
    vspath = StringVar()
    # variables rows and extention

    vrow = StringVar()
    vrow.set(8)

    vname = StringVar()
    vname.set("imgcomp")

    # labes
    framelab = Frame(app)
    framelab.pack(side="top")
    frametop = Frame(app)
    frametop.pack(side="top")

    framevaluelab = Frame(app)
    framevaluelab.pack(side="top")
    framevalue = Frame(app)
    framevalue.pack(side="top")

    framebot = Frame(app)
    framebot.pack(side="top")
    # image path GUI
    labels1 = Label(framelab,width= 25, text="Image Path")
    labels1.pack(side="top")
    entry1 = Entry(framelab,width= 80, textvariable=vpath)
    entry1.pack(side="top")
    t_btn1 = Button(framelab,text="Load path", width=10,bg="yellow", command=loadpath,fg="black")
    t_btn1.pack(side="top")
    # image save path GUI
    labels2 = Label(frametop,width= 25, text="Save Location Path")
    labels2.pack(side="top")
    entry2 = Entry(frametop,width= 80, textvariable=vspath)
    entry2.pack(side="top")
    t_btn2 = Button(frametop,text="Load path", width=10,bg="yellow", command=loadsavepath,fg="black")
    t_btn2.pack(side="top")

    labels4 = Label(frametop,width= 25, text="Big Comp Name (will create jpeg)")
    labels4.pack(side="top")
    entry4 = Entry(frametop,width= 15, textvariable=vname)
    entry4.pack(side="top")

    # extention and rows GUI
    labels3 = Label(framevaluelab,width= 14, text="Resize value")
    labels3.pack(side="left",padx=5)
    labels3 = Label(framevaluelab,width= 12, text="Extention")
    labels3.pack(side="left",padx=5)
    labels3 = Label(framevaluelab,width= 16, text="Items in Rows")
    labels3.pack(side="left",padx=5)

    # resize value
    OPTIONS = ["10%","20%","25%","40%","50%","60%","70%","80%","90%","100%"]
    vsize = StringVar()
    vsize.set(OPTIONS[9])

    entrysize = OptionMenu(framevalue,vsize,*OPTIONS)
    entrysize.pack(side="left",padx=25)
    entrysize.config(bg='#e59800')

    # extention
    OPTIONS1 = [".png", ".jpg", ".tif"]
    vext = StringVar()
    vext.set(OPTIONS1[0])

    resizev = OptionMenu(framevalue,vext,*OPTIONS1)
    resizev.pack(side="left",padx=25)
    resizev.config(bg='#e59800')

    # row value
    entryrow = Entry(framevalue,width= 10, textvariable=vrow)
    entryrow.pack(side="left",padx=25)

    #label run
    labels3 = Label(framebot, text="Does comp with images, give items in row")
    labels3.pack(side='top')
    # run button
    t_btn0 = Button(framebot,text="Big Comp", width=20, height =2 ,bg="green", command=bigcomp,fg="black")
    t_btn0.pack(pady=1, side="bottom",fill=X,expand=YES)
    # batman

    #loop
    app.mainloop()