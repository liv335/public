from tkinter import *
from tkinter import filedialog
import pandas as pd
from pathlib import Path
from PIL import Image, ImageFont, ImageDraw, ImageChops
import os

"""
Tool designed to produce a special sheet for checking, takes excel sheet with names, hex values but also texture swatches
then complies them together, this helps for checking color accuracies.
"""

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

def stopbutton():
    if v_stop_actiavted.get() == True:
        v_stop_actiavted.set(False)
        button_stop.config(bg = "White")
    elif v_stop_actiavted.get() == False:
        v_stop_actiavted.set(True)
        button_stop.config(bg = "Red")

def searchsubfolders():
    if v_subfolders.get() == True:
        v_subfolders.set(False)
        button_togglefolders.config(text="SearchFolder")
    elif v_subfolders.get() == False:
        v_subfolders.set(True)
        button_togglefolders.config(text="SearchSubFolders")

def loadimgpath():
    imgpathvar = filedialog.askopenfilename()
    v_pathimg.set(imgpathvar)

def loadimgsave():
    imgsavevar = filedialog.askopenfilename()
    v_pathsave.set(imgsavevar)

def loadexcel():
    excelval = filedialog.askopenfilename()
    v_excel.set(excelval.replace("/","\\"))
    button_loadExcel.config(text="Payload ready",fg="green")
    button_run.config(bg = "green",state ="normal")
    button_loadExcel.config(text = "Ready")

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
        ttloch = 0 + 50
    elif postt == "bottom":
        ttloch = imgN.height - tsize - 50
    draw.text((ttlocw - ttwidth / 2, ttloch), vtt, (0, 0, 0), font=font)

def createRgbsquare(imageopen,RGB):
    rgbvalsize = (int(imageopen.height / 4.6))
    rgbvalueadd = Image.new(imageopen.mode, (rgbvalsize, rgbvalsize), RGB)
    return rgbvalueadd

def resizeimagefunc(textureimage,texturesize):
    if textureimage.height > textureimage.width:
        textureaspectratio = textureimage.height / textureimage.width
        resizeimage = textureimage.resize((int(texturesize / textureimage.width * textureimage.width),int(texturesize / textureimage.height * textureimage.height * textureaspectratio)),Image.ANTIALIAS)
    elif textureimage.width > textureimage.height:
        textureaspectratio = textureimage.width / textureimage.height
        resizeimage = textureimage.resize((int(texturesize / textureimage.width * textureimage.width * textureaspectratio),int(texturesize / textureimage.height * textureimage.height)),Image.ANTIALIAS)
    elif textureimage.height == textureimage.width:
        resizeimage = textureimage.resize(((texturesize, texturesize)), Image.ANTIALIAS)
    return resizeimage

def textureimag(textureimage,texturesize):
    # Get Texture
    textureimage = Image.open(textureimage)
    # Resize Image
    resizeimage = resizeimagefunc(textureimage,texturesize)
    # Create new Image
    textureimagenew = Image.new(textureimage.mode, (texturesize, texturesize), (255,255,255))
    # Paste Newsize
    textureimagenew.paste(resizeimage)
    return textureimagenew

def runcomp():
    clearconsole()
    def complogic():
        loopcnt = 0
        valuecheckresize = False
        whitecolor = (255,255,255)
        imgpath = v_pathimg.get()
        exl = v_excel.get()
        df2 = pd.read_excel(exl, index_col='EAN', dtype=str)
        for index, row in df2.iterrows():
            if v_stop_actiavted.get() == False:
                try:
                    eanval = index
                    hexval = df2.loc[eanval, 'HEX']
                    rgbval = (tuple(int(hexval[i:i + 2], 16) for i in (0, 2, 4)))
                    for grip_images in Path(imgpath).glob("*" + str(eanval) + "*"):
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
                        # add text
                        # 1# write 5th word in file text, 2#check file name,#3 use current workimage, #4position, 5# procent 5 = 5% of workset height
                        addtextfromname = v_addtextvalue.get()
                        addtext(addtextfromname, grip_images, imageworkset, 'top',5)

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

                        # Used to move the image by procentaje, currently disabled
                        procmainx = v_procmainx.get()
                        procmainy = v_procmainy.get()

                        # return croped image
                        newimag = cropimagemain(imageopen)

                        # Define Main Image positio
                        mainimgplacement = Image.new(imageworkset.mode,(int(worksize * 0.533), int(worksize * 0.88)), whitecolor)
                        # Resize Image
                        if newimag.height > newimag.width:
                            newimag = resizeimagefunc(newimag,int(mainimgplacement.width * (newimag.width / newimag.height * 1.4)))
                        elif newimag.height < newimag.width:
                            newimag = resizeimagefunc(newimag, int(mainimgplacement.width * (newimag.height / newimag.width * 0.9)))
                        elif newimag.height == newimag.width:
                            newimag = resizeimagefunc(newimag, int(mainimgplacement.width * 0.9))
                        # Add Image to Placement
                        mainimgplacement.paste(newimag,(int((mainimgplacement.width-newimag.width)/2),int((mainimgplacement.height-newimag.height)/2)))
                        # Postion main Image Center

                        #mainpos = (int((imageworkset.width-newimag.width)/2+int(imageworkset.height*(procmainx/100))), int((imageworkset.height-newimag.height)/2)+int(imageworkset.width*(procmainy/100)))
                        mainpos = ((int(imageworkset.width*0.232)),(int(imageworkset.height*0.07)))
                        imageworkset.paste(mainimgplacement, mainpos)

                        # AddSquare Function
                        rgbvalueadd = createRgbsquare(imageworkset, rgbval)
                        rgbpos = (int(worksize*0.766), int((worksize-(worksize/4.6))/2))
                        imageworkset.paste(rgbvalueadd, rgbpos)

                        # Path for textures name
                        pathtexture = v_texturepath.get()
                        # get from using seperator EX: "-" where name is 123-yo-file-ean , will find based on "-" the input value, [2] is "file"
                        searchfilenameval = grip_images.name.split(v_seperator.get())[v_searchtextvalue.get()]
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
                            #print(textureimageloc)
                            writeconsole(textureimageloc.name)
                            imagetexture = textureimag(textureimageloc, int(worksize*0.213))
                            imageworkset.paste(imagetexture,(int(0.016*worksize),int((worksize-(worksize/4.6))/2)))

                        # save image
                        imageworkset.save(v_pathsave.get() + os.sep + v_prefix.get() + grip_images.name)

                        # Write in console
                        writeconsole(str(rgbval))
                        writeconsole(grip_images.name)
                        loopcnt += 1
                        writeconsole("Image: " + str(loopcnt))
                        writeconsole("")
                        #print(rgbval)
                except FileNotFoundError:
                    print("Not Found")
                    pass
            else:
                writeconsole("Stoped!!\nStoped!!")
                print("Stop")
                break
    complogic()

if __name__ == "__main__":
    root = Tk()
    root.title('Image Complier')
    root.minsize(500,220)
    # Frames
    frameapp = Frame(root)
    frameapp.pack(side="left")

    framemaine = Frame(frameapp)
    framemaine.pack(side="top")

    frameoptions = Frame(frameapp)
    frameoptions.pack(side="top")

    framebuttons = Frame(frameapp)
    framebuttons.pack(side="top")

    frameconsol = Frame(root)
    frameconsol.pack(side="left")

    v_pathimg = StringVar(root)
    # v_pathimg.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\ImgCompTest")
    v_pathimg.set(r"C:\_work\_script\Stuff\ImgComp")


    v_pathsave = StringVar(root)
    #v_pathsave.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\ImgSave")
    v_pathsave.set(r"C:\_work\_script\Stuff\ImgSave")

    v_texturepath = StringVar(root)
    #v_texturepath.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\Texture")
    v_texturepath.set(r"C:\_work\_script\Stuff\Swatch")

    v_excel = StringVar(root)
    #v_excel.set(r"\\nas\GRIP\shapes\maybelline\xOvV\ImageCompTesting\EANHex.xlsx")
    v_excel.set(r"C:\_work\_script\Stuff\EANHex.xlsx")

    v_prefix = StringVar(root)
    v_prefix.set("Comp-")

    # Extra string information to make things safe.
    v_frontval = StringVar(root)
    v_frontval.set("-")
    v_backval = StringVar(root)
    v_backval.set("_Textur")

    v_seperator =  StringVar(root)
    v_seperator.set("-")
    # value from name
    v_searchtextvalue = IntVar(root)
    v_searchtextvalue.set(5)
    # add text based on text position
    v_addtextvalue = IntVar(root)
    v_addtextvalue.set(5)

    # Search subfolders
    v_subfolders = BooleanVar(root)
    v_subfolders.set(True)

    # Override resolution
    v_overide_res = BooleanVar(root)
    v_overide_res.set(True)
    v_res_value = IntVar(root)
    v_res_value.set(3000)

    # main Image position
    v_procmainx = IntVar(root)
    v_procmainx.set(0)
    v_procmainy = IntVar(root)
    v_procmainx.set(0)

    v_stop_actiavted = BooleanVar(root)
    v_stop_actiavted.set(False)

    # Imagepath data
    lab_ImagePath =  Label(framemaine, text ="Images Path")
    lab_ImagePath.pack()
    entry_Imagepath = Entry(framemaine, width=120, textvariable=v_pathimg)
    entry_Imagepath.pack(side="top",padx=5)
    # ImageSave data
    lab_SavePath =  Label(framemaine, text ="Save Path")
    lab_SavePath.pack()
    entry_Savepath = Entry(framemaine, width=120, textvariable=v_pathsave)
    entry_Savepath.pack(side="top",padx=5)
    # AddTexture Swatches data
    lab_Texture =  Label(framemaine, text ="Search Texture")
    lab_Texture.pack()
    entryTexture = Entry(framemaine, width=120, textvariable=v_texturepath)
    entryTexture.pack(side="top",padx=5)

    # Options
    lab_separator =  Label(frameoptions, text ="Seperator")
    lab_separator.pack(side="left")
    entry_seperator = Entry(frameoptions, width=3, textvariable=v_seperator)
    entry_seperator.pack(side="left",padx=2)
    lab_options =  Label(frameoptions, text ="Options to find Swatches >>")
    lab_options.pack(side="left")

    # Options Entries for search textures
    entry_frontval = Entry(frameoptions, width=12, textvariable=v_frontval)
    entry_frontval.pack(side="left",padx=2)
    lab_prefixinfo =  Label(frameoptions, text ="< Prefix")
    lab_prefixinfo.pack(side="left")
    entry_searchval = Entry(frameoptions, width=3, textvariable=v_searchtextvalue)
    entry_searchval.pack(side="left",padx=2)
    lab_searchinfo =  Label(frameoptions, text ="< th word to search")
    lab_searchinfo.pack(side="left")
    entry_backval = Entry(frameoptions, width=12, textvariable=v_backval)
    entry_backval.pack(side="left",padx=2)
    lab_suffixinfo =  Label(frameoptions, text ="< Suffix")
    lab_suffixinfo.pack(side="left")
    entry_searchval = Entry(frameoptions, width=3, textvariable=v_addtextvalue)
    entry_searchval.pack(side="left",padx=2)
    lab_writeinfo =  Label(frameoptions, text ="< th word to write")
    lab_writeinfo.pack(side="left")

    # ExcelLoad
    entry_Excelvar =  Entry(framemaine,width=120, textvariable=v_excel, state='disabled')
    entry_Excelvar.pack()
    button_loadExcel = Button(framemaine, text="LoadExcel", command=loadexcel,bg="white", width = 102, height = 1)
    button_loadExcel.pack()

    # Toggle search folders
    button_togglefolders = Button(framebuttons, text="SearchSubFolders", command=searchsubfolders,bg="white", width = 30, height = 2)
    button_togglefolders.pack()

    # RunApp
    button_run = Button(framebuttons, text="Run App", command=runcomp,bg="white", width = 30, height = 2)
    button_run.pack()

    # Console
    entryPrints = Text(frameconsol, width=100, height=13)
    entryPrints.pack(side="top", padx=3, pady=3)
    button_stop = Button(frameconsol, text="StopProcess", command=stopbutton,bg="white", width = 30, height = 2)
    button_stop.pack()

    root.mainloop()