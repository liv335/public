from tkinter import *
from tkinter import filedialog, simpledialog
from pathlib import Path
from PIL import Image, ImageFont, ImageDraw, ImageChops
import os
import pandas as pd

# Write presets
def writepreset():
    def presetcreation():
        presetname = simpledialog.askstring(title = "Preset", prompt = "EnterPresetName")
        txtfile = open(v_pathimg.get() + os.sep + "Preset_" + presetname + ".txt", "w+")
        preset_value = \
        "v_pathimg:" + str(v_pathimg.get()) + "\n" \
        "v_pathsave:" + str(v_pathsave.get()) + "\n" \
        "v_texturepath:" + str(v_texturepath.get()) + "\n" \
        "v_excel:" + str(v_excel.get()) + "\n" \
        "v_prefix:" + str(v_prefix.get()) + "\n" \
        "v_frontval:" + str(v_frontval.get()) + "\n" \
        "v_backval:" + str(v_backval.get()) + "\n" \
        "v_seperator:" + str(v_seperator.get()) + "\n" \
        "v_searchtextvalue:" + str(v_searchtextvalue.get()) + "\n" \
        "v_addtextvalue:" + str(v_addtextvalue.get()) + "\n" \
        "v_subfolders:" + str(v_subfolders.get()) + "\n" \
        "v_testtoggle:" + str(v_testtoggle.get()) + "\n" \
        "v_overide_res:" + str(v_overide_res.get()) + "\n" \
        "v_res_value:" + str(v_res_value.get()) + "\n" \
        "v_stop_actiavted:" + str(v_stop_actiavted.get()) + "\n"
        txtfile.write(preset_value)
        txtfile.close()
        writeconsole("Preset created : " + presetname)
    try:
        if os.path.isdir(v_pathimg.get()) == True:
            presetcreation()
        else:
            writeconsole("Not a valid directory")
    except TypeError:
        writeconsole("Preset creation Canceled")

# Adjust
def loadpreset():
    def presetloading():
        presetfile = filedialog.askopenfilename()
        if ((str(presetfile).split("/")[-1]).split("_")[0]) == "Preset":
            with open(presetfile, 'r') as file:
                data = file.read().split('\n')
            # Search for data inside config file
            sep = ":"
            cntd = 0
            for i in data:
                if data[cntd].split(sep)[0] == "v_pathimg":
                    v_pathimg.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_pathsave":
                    v_pathsave.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_texturepath":
                    v_texturepath.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_excel":
                    button_loadExcel.config(text="Payload ready", fg="green")
                    button_run.config(bg="green", state="normal")
                    button_loadExcel.config(text="Ready")
                    v_excel.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_prefix":
                    v_prefix.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_frontval":
                    v_frontval.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_backval":
                    v_backval.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_seperator":
                    v_seperator.set(data[cntd].split(sep)[1])

                if data[cntd].split(sep)[0] == "v_searchtextvalue":
                    v_searchtextvalue.set(int(data[cntd].split(sep)[1]))

                if data[cntd].split(sep)[0] == "v_addtextvalue":
                    v_addtextvalue.set(int(data[cntd].split(sep)[1]))

                if data[cntd].split(sep)[0] == "v_subfolders":
                    if str(v_subfolders.get()) != (data[cntd].split(sep)[1]):
                        searchsubfolders()

                if data[cntd].split(sep)[0] == "v_testtoggle":
                    if str(v_testtoggle.get()) != (data[cntd].split(sep)[1]):
                        testtoggle()

                if data[cntd].split(sep)[0] == "v_overide_res":
                    if str(v_overide_res.get()) != (data[cntd].split(sep)[1]):
                        overiderestoggle()

                if data[cntd].split(sep)[0] == "v_res_value":
                    v_res_value.set(int(data[cntd].split(sep)[1]))

                if data[cntd].split(sep)[0] == "v_stop_actiavted":
                    if str(v_stop_actiavted.get()) != (data[cntd].split(sep)[1]):
                        stopbutton()
                cntd += 1
            writeconsole("Loading :" + str(presetfile).split("/")[-1][:-4])
        else:
            writeconsole("Invalid Preset")
    try:
        writeconsole("")
        presetloading()
    except FileNotFoundError:
        writeconsole("No Preset Loaded")

# Test mode
def testtoggle():
    if v_testtoggle.get() == False:
        writeconsole("Test Mode On")
        button_test.config(text="Single Test Mode",fg="Green")
        v_testtoggle.set(True)
    elif v_testtoggle.get() == True:
        writeconsole("Test Mode Off")
        v_testtoggle.set(False)
        button_test.config(text="Full Loop Mode",fg="Orange")

# Override resolution
def overiderestoggle():
    if v_overide_res.get() == False:
        writeconsole("Override Resolution : True")
        entry_resolution.config(state="normal")
        button_resolution.config(fg = "Green")
        v_overide_res.set(True)
    elif v_overide_res.get() == True:
        writeconsole("Override Resolution : False")
        entry_resolution.config(state="disabled")
        button_resolution.config(fg="Orange")
        v_overide_res.set(False)

# write console information
def writeconsole(datatoadd):
    # unlock console
    entryPrints.config(state="normal")
    # writes data in console
    entryPrints.insert("1.0", datatoadd + "\n")
    # locks console
    entryPrints.config(state="disabled")
    # updates GUI
    root.update()

# clear console command
def clearconsole():
    # unlocks console
    entryPrints.config(state="normal")
    # removes data
    entryPrints.delete("1.0", END)
    # locks console
    entryPrints.config(state="disabled")
    # updates GUI
    root.update()

# Stop Button
def stopbutton():
    if v_stop_actiavted.get() == True:
        v_stop_actiavted.set(False)
        button_stop.config(bg = "White")
    elif v_stop_actiavted.get() == False:
        v_stop_actiavted.set(True)
        button_stop.config(bg = "Red")

# Subfolders
def searchsubfolders():
    if v_subfolders.get() == True:
        v_subfolders.set(False)
        writeconsole(("Searching files in folder"))
        button_togglefolders.config(text="SearchFolder",fg="Green")
    elif v_subfolders.get() == False:
        v_subfolders.set(True)
        writeconsole(("Searching in folder and subfolders"))
        button_togglefolders.config(text="SearchSubFolders",fg="Orange")

# LoadImagePath
def loadimgpath():
    imgpathvar = filedialog.askopenfilename()
    v_pathimg.set(imgpathvar)

# LoadImageSave
def loadimgsave():
    imgsavevar = filedialog.askopenfilename()
    v_pathsave.set(imgsavevar)

# LoadExcel
def loadexcel():
    excelval = filedialog.askopenfilename()
    print(str(excelval).split("/")[-1].split(".")[-1])
    if (str(excelval).split("/")[-1].split(".")[-1]) == "xlsx":
        v_excel.set(excelval.replace("/","\\"))
        button_loadExcel.config(text="Payload ready",fg="green")
        button_run.config(bg = "green",state ="normal")
        button_loadExcel.config(text = "Ready")
    else:
        writeconsole("Incorect file format not a .xlsx")

# Add text
def addtext(targettext,file,imgN,postt,procents):
    # Value text from name
    vtt = file.name.split("-")[targettext]
    tsize = int(imgN.height * float(procents/100))
    draw = ImageDraw.Draw(imgN)
    font = ImageFont.truetype("C:\Windows\Fonts\AdobeFanHeitiStd-Bold.otf", tsize)
    # Def text width to use to determin position
    ttwidth = font.getsize(vtt)[0]
    # Write text
    ttlocw = int(imgN.width / 2)
    # Text pos
    if postt == "top":
        ttloch = 0 + int(imgN.height*0.016)
    elif postt == "bottom":
        ttloch = imgN.height - tsize - int(imgN.height*0.016)
    draw.text((ttlocw - ttwidth / 2, ttloch), vtt, (0, 0, 0), font=font)

# RgbSquare function
def createRgbsquare(imageopen,RGB):
    rgbvalsize = (int(imageopen.height / 4.6))
    rgbvalueadd = Image.new(imageopen.mode, (rgbvalsize, rgbvalsize), RGB)
    return rgbvalueadd

# resizer
def resizeimagefunc(textureimage,texturesize):
    if textureimage.height < textureimage.width:
        textureaspectratio = textureimage.height / textureimage.width
        resizeimage = textureimage.resize((int((texturesize / textureimage.width) * textureimage.width),int((texturesize / textureimage.height) * (textureimage.height * textureaspectratio))),Image.ANTIALIAS)
    elif textureimage.height > textureimage.width:
        textureaspectratio = textureimage.width / textureimage.height
        resizeimage = textureimage.resize((int((texturesize / textureimage.width) * (textureimage.width * textureaspectratio)),int((texturesize / textureimage.height) * textureimage.height)),Image.ANTIALIAS)
    elif textureimage.height == textureimage.width:
        resizeimage = textureimage.resize(((texturesize, texturesize)), Image.ANTIALIAS)
    return resizeimage

# Texture add to image
def textureimag(textureimageload,texturesize):
    # Get Texture
    textureimage = Image.open(textureimageload)
    # Resize Image
    resizeimage = resizeimagefunc(textureimage,texturesize)
    # Create new Image
    textureimagenew = Image.new(textureimage.mode, (texturesize, texturesize), (255,255,255))
    # Paste Newsize
    textureimagenew.paste(resizeimage,(int((textureimagenew.width-resizeimage.width)/2),int((textureimagenew.height-resizeimage.height)/2)))
    return textureimagenew

# Run command
def runcomp():
    clearconsole()
    def complogic():
        loopcnt = 0
        testcnt = 0
        whitecolor = (255,255,255)
        imgpath = v_pathimg.get()
        exl = v_excel.get()
        df2 = pd.read_excel(exl, index_col='EAN', dtype=str)
        #pict_var = max(filter(lambda x: os.path.isnotdir(x), Path(path_location + os.sep + "render_output").glob("*")),key=lambda x: os.stat(x).st_mtime)
        for index, row in df2.iterrows():
            if v_stop_actiavted.get() == False:
                try:
                    eanval = index
                    hexval = df2.loc[eanval, 'HEX']
                    rgbval = (tuple(int(hexval[i:i + 2], 16) for i in (0, 2, 4)))
                    for grip_images in Path(imgpath).glob("*" + str(eanval) + "*"):
                        grip_images = max(filter(lambda x: os.path.isfile(x),Path(imgpath).glob("*" + str(eanval) + "*")),key=lambda x: os.stat(x).st_mtime)
                        if testcnt < 1:
                            imageopen = Image.open(grip_images)
                            if v_overide_res.get() == False:
                                worksize_mainheight= imageopen.height
                                worksize_mainwidth = imageopen.width
                            else:
                                worksize_mainheight = v_res_value.get()
                                worksize_mainwidth = v_res_value.get()
                            # use image as ref to create square ratio
                            if imageopen.height > imageopen.width:
                                imageworkset = Image.new(imageopen.mode, (worksize_mainheight, worksize_mainheight), whitecolor)
                                worksize = worksize_mainheight
                            elif imageopen.height < imageopen.width:
                                imageworkset = Image.new(imageopen.mode, (worksize_mainwidth, worksize_mainwidth), whitecolor)
                                worksize = worksize_mainwidth
                            elif imageopen.height == imageopen.width:
                                imageworkset = Image.new(imageopen.mode, (worksize_mainheight, worksize_mainwidth), whitecolor)
                                worksize = worksize_mainheight

                            # resize function, takes the current image, finds maxium crop
                            def cropimagemain(imageopen):
                                basecrop = Image.new(imageopen.mode, imageopen.size, imageopen.getpixel((0, 0)))
                                diffb = ImageChops.difference(imageopen, basecrop)
                                diffbasecrop = ImageChops.add(diffb, diffb, 2, 0)
                                bboundbox_c = diffbasecrop.getbbox()
                                # Use box to crop
                                newimgcrop = imageopen.crop(bboundbox_c)
                                offnewimg = Image.new(newimgcrop.mode, (newimgcrop.width, newimgcrop.height), (0, 0, 0))
                                offnewimg.paste(newimgcrop, (0, 0))
                                return offnewimg

                            # return croped image
                            newimag = cropimagemain(imageopen)
                            # Define Main Image positio
                            mainimgplacement = Image.new(imageworkset.mode,(int(worksize * 0.533), int(worksize * 0.88)), whitecolor)
                            # Smart resize based on image size
                            if newimag.height == newimag.width:
                                newimag = resizeimagefunc(newimag, int(mainimgplacement.width))
                            elif newimag.width < mainimgplacement.width:
                                if newimag.height < newimag.width:
                                    newimag = resizeimagefunc(newimag, int(mainimgplacement.width))
                                elif newimag.height > newimag.width:
                                    newimag = resizeimagefunc(newimag, int(mainimgplacement.width+(newimag.height-newimag.width)))
                            elif newimag.width > mainimgplacement.width:
                                newimag = resizeimagefunc(newimag, int(mainimgplacement.width))
                            # Add Image to Placement
                            mainimgplacement.paste(newimag,(int((mainimgplacement.width-newimag.width)/2),int((mainimgplacement.height-newimag.height)/2)))
                            # Postion main Image Center
                            # main position then paste image
                            mainpos = ((int(imageworkset.width*0.232)),(int(imageworkset.height*0.07)))
                            imageworkset.paste(mainimgplacement, mainpos)

                            # AddSquare Function
                            rgbvalueadd = createRgbsquare(imageworkset, rgbval)
                            rgbpos = (int(worksize*0.766), int((worksize-(worksize/4.6))/2))
                            imageworkset.paste(rgbvalueadd, rgbpos)

                            # Path for textures name
                            pathtexture = v_texturepath.get()
                            # get from using seperator EX: "-" where name is 123-yo-file-ean , will find based on "-" the input value, [2] is "file"
                            searchfilenameval = grip_images.name.split(v_seperator.get())[v_searchtextvalue.get() - 1]
                            # add extra string for search to prevent missmatch
                            frontval = v_frontval.get()
                            backval = v_backval.get()
                            # conct together search value + extra strings if Null will only search value from name
                            searchval = frontval + searchfilenameval + backval

                            # if subfolders check is on will check subfolders
                            if v_subfolders.get() == True:
                                searchoptions = "**/" + "*"
                            else:
                                searchoptions = "*"

                            # write in console Loop count
                            # add textures based on search
                            for textureimageloc in Path(pathtexture).glob(searchoptions + searchval + "*"):
                                writeconsole("Searched file with value : " + str(searchval))
                                imagetexture = textureimag(textureimageloc, int(worksize*0.213))
                                imageworkset.paste(imagetexture,(int(0.016*worksize),int((worksize-(worksize/4.6))/2)))

                            # add text
                            # 1# write 5th word in file text, 2#check file name,#3 use current workimage, #4position, 5# procent 5 = 5% of workset height
                            addtextfromname = v_addtextvalue.get() - 1
                            addtext(addtextfromname, grip_images, imageworkset, 'top',5)

                            # save image
                            imageworkset.save(v_pathsave.get() + os.sep + v_prefix.get() + grip_images.name)

                            # Write in console
                            writeconsole("Rgb From HEX : " + str(rgbval))
                            writeconsole("Searching for File with : " + str(eanval))
                            loopcnt += 1
                            writeconsole("Image: " + str(loopcnt))
                            writeconsole("")
                            if v_testtoggle.get() == True:
                                testcnt += 1
                except FileNotFoundError:
                    print("Not Found")
                    pass
            else:
                writeconsole("Stoped!!\nStoped!!")
                print("Stop")
                break
    if v_res_value.get() > 50 and v_res_value.get() < 8000:
        try:
            complogic()
        except TclError:
            writeconsole("Value Error")
    else:
        writeconsole("Invalid Resolution: Try value between 50 and 8000")

if __name__ == "__main__":
    root = Tk()
    root.title('Image Complier')
    root.minsize(500,220)
    # Frames
    frameapp = Frame(root)
    frameapp.pack(side="left")

    framemaintop = Frame(frameapp)
    framemaintop.pack(side="top")

    framesaveprefixlab = Frame(frameapp)
    framesaveprefixlab.pack(side="top")

    framesaveprefix = Frame(frameapp)
    framesaveprefix.pack(side="top")

    framemainbottom = Frame(frameapp)
    framemainbottom.pack(side="top")

    frameoptions = Frame(frameapp,height = 2 ,borderwidth = 2 ,relief = GROOVE,padx = 5, pady = 5)
    frameoptions.pack(side="top",pady = 2)

    frameoptover = Frame(frameapp)
    frameoptover.pack(side="top")

    framebuttons = Frame(frameapp)
    framebuttons.pack(side="top")

    frametestoptions = Frame(framebuttons)
    frametestoptions.pack(side="left")

    framepresets = Frame(framebuttons)
    framepresets.pack(side="left")

    framerunbutton = Frame(frameapp)
    framerunbutton.pack(side="top")

    frameconsol = Frame(root)
    frameconsol.pack(side="left")

    v_pathimg = StringVar(root)
    #v_pathimg.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\ImgCompTest")
    v_pathimg.set(r"Images to Compose")

    v_pathsave = StringVar(root)
    #v_pathsave.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\ImgSave")
    v_pathsave.set(r"Place to Save")

    v_texturepath = StringVar(root)
    #v_texturepath.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\Texture")
    v_texturepath.set(r"Swatches to add")

    v_excel = StringVar(root)
    #v_excel.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\EANHex.xlsx")
    v_excel.set(r"Excel File Location")

    v_prefix = StringVar(root)
    v_prefix.set("Comp-")

    # Extra string information to make things safe.
    v_frontval = StringVar(root)
    v_frontval.set("-")
    v_backval = StringVar(root)
    v_backval.set("_Textur")

    # Seperator variable
    v_seperator =  StringVar(root)
    v_seperator.set("-")

    # value from name
    v_searchtextvalue = IntVar(root)
    v_searchtextvalue.set(6)
    # add text based on text position
    v_addtextvalue = IntVar(root)
    v_addtextvalue.set(6)

    # Search subfolders
    v_subfolders = BooleanVar(root)
    v_subfolders.set(True)

    v_testtoggle = BooleanVar(root)
    v_testtoggle.set(False)

    # Override resolution
    v_overide_res = BooleanVar(root)
    v_overide_res.set(False)
    v_res_value = IntVar(root)
    v_res_value.set(3000)

    # Stop variable
    v_stop_actiavted = BooleanVar(root)
    v_stop_actiavted.set(False)

    # ImagePath data
    lab_ImagePath =  Label(framemaintop, text ="Images Path")
    lab_ImagePath.pack()
    entry_Imagepath = Entry(framemaintop, width=120, textvariable=v_pathimg)
    entry_Imagepath.pack(side="top",padx=5)
    # ImageSave data
    entry_Saveprefix = Entry(framesaveprefix, width=14, textvariable=v_prefix)
    entry_Saveprefix.pack(side="left",padx=0)
    lab_SavePath =  Label(framesaveprefixlab, text ="Save Path")
    lab_SavePath.pack()
    entry_Savepath = Entry(framesaveprefix, width=106, textvariable=v_pathsave)
    entry_Savepath.pack(side="left",padx=0)
    # AddTexture Swatches data
    lab_Texture =  Label(framemainbottom, text ="Search Texture")
    lab_Texture.pack()
    entryTexture = Entry(framemainbottom, width=120, textvariable=v_texturepath)
    entryTexture.pack(side="top",padx=5)

    # Options
    lab_separator =  Label(frameoptions, text ="Seperator >")
    lab_separator.pack(side="left")
    entry_seperator = Entry(frameoptions, width=3, textvariable=v_seperator)
    entry_seperator.pack(side="left",padx=2)
    lab_options =  Label(frameoptions, text ="                                     ")
    lab_options.pack(side="left")

    # Options Entries for search textures
    entry_frontval = Entry(frameoptions, width=12, textvariable=v_frontval)
    entry_frontval.pack(side="left",padx=0)
    lab_prefixinfo =  Label(frameoptions, text ="< Prefix")
    lab_prefixinfo.pack(side="left")
    entry_searchval = Entry(frameoptions, width=3, textvariable=v_searchtextvalue)
    entry_searchval.pack(side="left",padx=0)
    lab_searchinfo =  Label(frameoptions, text ="< th word to search")
    lab_searchinfo.pack(side="left")
    entry_backval = Entry(frameoptions, width=12, textvariable=v_backval)
    entry_backval.pack(side="left",padx=0)
    lab_suffixinfo =  Label(frameoptions, text ="< Suffix")
    lab_suffixinfo.pack(side="left")
    entry_searchval = Entry(frameoptions, width=3, textvariable=v_addtextvalue)
    entry_searchval.pack(side="left",padx=0)
    lab_writeinfo =  Label(frameoptions, text ="< th word to write")
    lab_writeinfo.pack(side="left")

    # Options for frames override
    button_resolution = Button(frameoptover, text="Override Resolution", command=overiderestoggle,bg="white",fg="orange", width = 19, height = 1)
    button_resolution.pack(side="left")
    entry_resolution = Entry(frameoptover, width=12, textvariable=v_res_value,state='disabled')
    entry_resolution.pack(side="left",padx=0)

    # ExcelLoad
    entry_Excelvar =  Entry(framemainbottom,width=120, textvariable=v_excel, state='disabled')
    entry_Excelvar.pack()
    button_loadExcel = Button(framemainbottom, text="LoadExcel", command=loadexcel,bg="Yellow", width = 102, height = 2)
    button_loadExcel.pack()

    # Toggle search folders
    button_togglefolders = Button(framebuttons, text="SearchSubFolders", command=searchsubfolders,fg="Orange",bg="white", width = 30, height = 2)
    button_togglefolders.pack()

    # RunApp
    button_test = Button(framebuttons, text="Full Loop Mode", command=testtoggle,fg="Orange",bg="white", width = 30, height = 2)
    button_test.pack()
    button_run = Button(framerunbutton, text="Run App", command=runcomp,bg="white", width = 62, height = 2,state="disabled")
    button_run.pack()

    # Preset loads/write
    button_writepreset = Button(framepresets, text="WritePreset", command=writepreset,bg="white", width = 30, height = 2)
    button_writepreset.pack()
    button_loadpreset = Button(framepresets, text="LoadPreset", command=loadpreset,bg="white", width = 30, height = 2)
    button_loadpreset.pack()

    # Console
    entryPrints = Text(frameconsol, width=60, height=20)
    entryPrints.pack(side="top", padx=2, pady=1)
    button_stop = Button(frameconsol, text="StopProcess", command=stopbutton,bg="white", width = 30, height = 2)
    button_stop.pack()

    root.mainloop()