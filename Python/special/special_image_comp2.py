# Created by Livyx
# Short version
# Compiles 2-4 Images together using value found in filename

# Long versione the "main" image
# # Use the Test feature to setup one image the way the user wants then dezactivate Test to load all images in a set
# # # The tool searches inside the file name based on the seperators used in the filename such as "-"
# # # Using the seperator value it determins that the 5th position is "005" or "ivorypink" and will do search in other
# # #   images folders for said value, if it finds a image that has a corespoding value inside its file name it will merge
# # #   the files together, the GUI allows position and scale manipulation.
# # # A Image can be loaded and manipulated via the position and offset GUI, the size of the iamge is a fixed size in Pixels (ignores the size of the original image(resizes))
# # # Text function takes value from filename and adds to the image
# # # Text function allows the position to be either top or bottom and the size of the text be determin (size is based on % of image)
# # # Max Crop function determins a bounding box of all the elements that were merged together and crops the max value found
# # # Max Crop values can be adjusted using the special hidden iterface that turns of only when the checker is clicked
# # # Max Crop allows extra edge pixes such like a border be around the cropped image, these values can be manipulated
# # # Max Crop Edge is 500, 250 pixels are added both left and right. But Height is determied as procent out of height (500*30%=150(75 top, 75 bottom))
# # # Extra Images can be loaded if there is a need for complexity with the same layout as the first image (2 extra images can be loaded)
# # Prefix adds a prefix string to the files(filename are based on the original names)
# This tool generates a GUI that allows the User to load a set of 2, up to 4 images and bring them togheter
# The GUI provides the users path locations, and also the tools to manipulate the image insid

from tkinter import *
from tkinter import filedialog
from pathlib import Path
from PIL import Image, ImageFont, ImageDraw, ImageChops
import os

# Fnct to load second Image GUI
def loadsecondimg():
    # Second Image add
    # Second Image add
    framescgui.config(height=2, borderwidth=2, relief=GROOVE, padx=5, pady=5)
    labfsimg2 = Label(framesdimglo, text="Second Texture Image")
    labfsimg2.pack(side="top")
    entryfsimgPath2 = Entry(framesdimglo, width=92, textvariable=varfsimg2)
    entryfsimgPath2.pack(side="left")
    loadbasepathbtn2 = Button(framesdimglo, text='Load', command=loadfsimg2, width=8)
    loadbasepathbtn2.pack(side="left")
       # Element for Size Second image
    labstexv = Label(framevassdet, text="Size in Pixels")
    labstexv.pack(side="left")
    entryMs2 = Entry(framevassdet, width=10, textvariable=vMsi2)
    entryMs2.pack(side="left")
        # Element for Offset X Second image
    laboffx2 = Label(framevassdet, text="Offset X procent")
    laboffx2.pack(side="left")
    entryoffsttx2 = Entry(framevassdet, width=10, textvariable=voffsttx2)
    entryoffsttx2.pack(side="left")
        # Element for Offset Y Second image
    laboffy2 = Label(framevassdet, text="Offset Y procent")
    laboffy2.pack(side="left")
    entryoffstty2 = Entry(framevassdet, width=10, textvariable=voffstty2)
    entryoffstty2.pack(side="left")
        # radio buttons Second image
    vpostex2.set("center")
        # Radio buttons for position Second image
    for text, mode in modez2:
        btnradio2 = Radiobutton(framesdimset, text=text,variable=vpostex2, value=mode)
        btnradio2.pack(side="left")
    loadsecondimgui.destroy()
# Fnct to load third Image GUI
def loadthirdimg():
    # Third Image add
    # Third Image add
    framethgui.config(height=2, borderwidth=2, relief=GROOVE, padx=5, pady=5)
    labfsimg3 = Label(framethimglo, text="Third Texture Image")
    labfsimg3.pack(side="top")
    entryfsimgPath3 = Entry(framethimglo, width=92, textvariable=varfsimg3)
    entryfsimgPath3.pack(side="left")
    loadbasepathbtn3 = Button(framethimglo, text='Load', command=loadfsimg3, width=8)
    loadbasepathbtn3.pack(side="left")
       # Element for Size Third image
    labthexv = Label(framevasthet, text="Size in Pixels")
    labthexv.pack(side="left")
    entryMs3 = Entry(framevasthet, width=10, textvariable=vMsi3)
    entryMs3.pack(side="left")
        # Element for Offset X Third image
    laboffx3 = Label(framevasthet, text="Offset X procent")
    laboffx3.pack(side="left")
    entryoffsttx3 = Entry(framevasthet, width=10, textvariable=voffsttx3)
    entryoffsttx3.pack(side="left")
        # Element for Offset Y Third image
    laboffy3 = Label(framevasthet, text="Offset Y procent")
    laboffy3.pack(side="left")
    entryoffstty3 = Entry(framevasthet, width=10, textvariable=voffstty3)
    entryoffstty3.pack(side="left")
        # Set for Radio Buttons
    vpostex3.set("center")
        # Radio buttons for position Third image
    for text, mode in modez3:
        btnradio3 = Radiobutton(framethimset, text=text,variable=vpostex3, value=mode)
        btnradio3.pack(side="left")
    loadthirdmgui.destroy()
# Fnct to load/set dir path for BaseImage
def loadim():
    dirloadbase = filedialog.askdirectory()
    varbasepath.set(dirloadbase)
# Fnct to load/set dir path for FirstImage
def loadfsimg():
    dirfsimg = filedialog.askdirectory()
    varfsimg.set(dirfsimg)
# Fnct to load/set dir path for SecondImage
def loadfsimg2():
    varsdimg = filedialog.askdirectory()
    varfsimg2.set(varsdimg)
# Fnct to load/set dir path for ThirdImage
def loadfsimg3():
    varthimg = filedialog.askdirectory()
    varfsimg3.set(varthimg)
# Fnct to load/set dir path for SaveLocation
def loadsavloc():
    dirsavepathload = filedialog.askdirectory()
    varsavpath.set(dirsavepathload)
# Fnct to set test mode (does single test)
def testmode():
    global test
    if testvar.get() == "test":
        print("Test Mode Activated")
    else:
        print("Test Mode Desactivated")
    print("")
    test = testvar.get()
# Fnct to set text mode (adds text on Image)
def textvarmode():
    global textmode
    if vtextmode.get() == "Text":
        print("Text Mode Activated")
        print("Will Add Text From Filename Position ")
    else:
        print("Text Desactivated")
    print("")
    textmode = vtextmode.get()
# Fnct to set crop mode (Max crops final comp)
def cropmaxvalue():
    global vmaxcrop
    if vmaxcrop.get() == "y":
        print("Max Crop Activated")
    else:
        print("Max Crop Dezactivated")
    #print(vmaxcrop.get())
    print("")
    # add extra entry for max crop
    labmaxedge = Label(framesettingscrophi, text="Crop Edge Pixels")
    labmaxedge.pack(side="left")
    entrymaxedge = Entry(framesettingscrophi, width=10, textvariable=vcrpbrdr)
    entrymaxedge.pack(side="left")
    # add extra entry for max crop
    labmaxtop = Label(framesettingscrophi, text="Procent Height")
    labmaxtop.pack(side="left")
    entrymaxtop = Entry(framesettingscrophi, width=10, textvariable=vcrpbrdrh)
    entrymaxtop.pack(side="left")
    # When button is dezactivated delete entries
    if vmaxcrop.get() == "n":
        try:
            list = framesettingscrophi.slaves()
            for l in list:
                l.destroy()
        except UnboundLocalError:
            pass
# Fnct to start comp
def imagecomp():
    Fext = vext.get()
    # Load Paths
    pathbase = varbasepath.get()
    pathcomp = varsavpath.get()
    pathimg1 = varfsimg.get()
    pathimg2 = varfsimg2.get()
    pathimg3 = varfsimg3.get()
    # Base Image Values Gets
    offsbx = voffsbasx.get() + "%"
    offsby = voffsbasy.get() + "%"
    posbase = vposbase.get()
    # First Image Values Get
    Msi = int(vMsi.get())
    postex1 = vpostex1.get()
    offsttx1 = voffsttx1.get() + "%"
    offstty1 = voffstty1.get() + "%"
    # Second Image Values Get (If exist)
    Msi2 = int(vMsi2.get())
    offsttx2 = voffsttx2.get() + "%"
    offstty2 = voffstty2.get() + "%"
    postex2 = vpostex2.get()
    # Third Image Values Get (If exist)
    Msi3 = int(vMsi3.get())
    offsttx3 = voffsttx3.get() + "%"
    offstty3 = voffstty3.get() + "%"
    postex3 = vpostex3.get()
    # get target, get seperator
    target1 = int(vtarget1.get()) - 1
    basesep = vbasesep.get()
    # text mode get
    textmode = vtextmode.get()
    targett = int(vtargetxt.get()) - 1
    postt = vpostxt.get()
    # max scrop get
    maxcrop = vmaxcrop.get()
    crpbrdr = int(vcrpbrdr.get())
    crpbrdrh = float(vcrpbrdrh.get())
    # sex size get
    if int(vproctxt.get()) < 100:
        ttsproc = float(int(vproctxt.get())/100)
    elif int(vproctxt.get()) == 0:
        print("Text Size error deafult 5%")
        ttsproc = 0.05
    elif int(vproctxt.get()) > 100:
        print("Text Size error deafult 5%")
        ttsproc = 0.05
    # Function to convert x,y from procent to int
    # Use procent logic, convert to int
    def offsetxy(offsx,offsy):
        # offset x
        if offsx[1] == "%":
            offsx =(float(offsx[0])/10)
        elif offsx[2] == "%":
            offsx =(float(offsx[:1])/10)
        elif offsx[3] == "%":
            offsx =(float(offsx[:2])/10)
        # offset y
        if offsy[1] == "%":
            offsy = (float(offsy[0])/10)
        elif offsy[2] == "%":
            offsy =(float(offsy[:1])/10)
        elif offsy[3] == "%":
            offsy = (float(offsy[:2])/10)
        return offsx, offsy
    # function to determin position
    def postvalue(posimg, imgimg, offsetx, offsety):
        if posimg == "center":
            posvx = int((imgN.width - imgimg.width) / 2) + int(imgN.width / 2 * offsetx)
            posvy = int((imgN.height - imgimg.height) / 2) + int(imgN.width / 2 * offsety)
        elif posimg == "left":
            posvx = 0
            posvy = int((imgN.height - imgimg.height) / 2) + int((imgN.height / 2) * offsety)
        elif posimg == "right":
            posvx = int(imgN.width - imgimg.width)
            posvy = int((imgN.height - imgimg.height) / 2) + int(imgN.height / 2 * offsety)
        elif posimg == "top":
            posvx = int((imgN.width - imgimg.width) / 2) + int(imgN.width / 2 * offsetx)
            posvy = 0
        elif posimg == "bottom":
            posvx = int((imgN.width - imgimg.width) / 2) + int(imgN.width / 2 * offsetx)
            posvy = imgN.height - imgimg.height
        return posvx, posvy
    # transform procent string to int for base image
    offsetbx = (offsetxy(offsbx,offsby)[0])
    offsetby = (offsetxy(offsbx,offsby)[1])
    # transform procent string to int for first tex image
    offsettx1 = (offsetxy(offsttx1, offstty1)[0])
    offsetty1 = (offsetxy(offsttx1, offstty1)[1])
    # transform procent string to int for second tex image
    offsettx2 = (offsetxy(offsttx2,offstty2)[0])
    offsetty2 = (offsetxy(offsttx2,offstty2)[1])
    # transform procent string to int for second tex image
    offsettx3 = (offsetxy(offsttx3,offstty3)[0])
    offsetty3 = (offsetxy(offsttx3,offstty3)[1])
    # loop for if test
    x = 1
    # def function to load texture image
    def imgload(pathimgtx,Msi):
        for f in Path(pathimgtx).glob('*' + vn + "*" + Fext):
            print("texture image")
            print(f.name)
            # Load Second Image
            itxt = Image.open(f)
            # Resize Second Image
            if itxt.width < itxt.height:
                Ar = (itxt.width / itxt.height)
                itxt = itxt.resize((int(Msi / itxt.width * itxt.width * Ar), int(Msi / itxt.height * itxt.height)),Image.ANTIALIAS)
            elif itxt.width > itxt.height:
                Ar = (itxt.height / itxt.width)
                itxt = itxt.resize((int(Msi / itxt.width * itxt.width), int(Msi / itxt.height * itxt.height * Ar)),Image.ANTIALIAS)
            elif itxt.width == itxt.height:
                itxt = itxt.resize((Msi, Msi), Image.ANTIALIAS)
            return itxt
    for file in Path(pathbase).glob("*" + Fext):
        if x == 1:
            v1 = file.name.split(basesep)[target1]
            leftt = vleftextrat.get()
            rightt = vrightextrat.get()
            vn = leftt + v1 + rightt
            try:
                print("match files that contain : " + str(vn))
                # load base image
                for filebase in Path(pathbase).glob('*' + vn + "*" + Fext):
                    print("base image")
                    print(filebase.name)
                    imgbase = Image.open(filebase)
                    # First tex image
                    try:
                        # find and load image
                        imgtex1 = imgload(pathimg1, Msi)
                        imgtexm1 = Image.new(imgtex1.mode, (Msi, Msi), (255, 255, 255))
                        # Move second image to module new image for standardization
                        imgtexm1.paste(imgtex1, (int((Msi - imgtex1.width) / 2), (int((Msi - imgtex1.height) / 2))))
                    except ValueError:
                        pass
                    except NameError:
                        pass
                    except AttributeError:
                        pass
                    # second tex image
                    try:
                        # find and load image
                        imgtex2 = imgload(pathimg2, Msi2)
                        imgtexm2 = Image.new(imgtex2.mode, (Msi2, Msi2), (255, 255, 255))
                        # Move second image to module new image for standardization
                        imgtexm2.paste(imgtex2, (int((Msi2 - imgtex2.width) / 2), (int((Msi2 - imgtex2.height) / 2))))
                    except ValueError:
                        pass
                    except NameError:
                        pass
                    except AttributeError:
                        pass
                    # third tex image
                    try:
                        # find and load image
                        imgtex3 = imgload(pathimg3, Msi3)
                        imgtexm3 = Image.new(imgtex3.mode, (Msi3, Msi3), (255, 255, 255))
                        # Move second image to module new image for standardization
                        imgtexm3.paste(imgtex3, (int((Msi3 - imgtex3.width) / 2), (int((Msi3 - imgtex3.height) / 2))))
                    except ValueError:
                        pass
                    except NameError:
                        pass
                    except AttributeError:
                        pass
                    # get largest dimension
                    if imgbase.width < imgbase.height:
                        imgN = Image.new('RGB', (imgbase.height, imgbase.height), (255, 255, 255))
                    elif imgbase.width > imgbase.height:
                        imgN = Image.new('RGB', (imgbase.width, imgbase.width), (255, 255, 255))
                    elif imgbase.width == imgbase.height:
                        imgN = Image.new('RGB', (imgbase.width, imgbase.width), (255, 255, 255))
                    # Create new for crop of base image
                    basecrop = Image.new(imgbase.mode, imgbase.size, imgbase.getpixel((0, 0)))
                    # inverts image based on based on the other?
                    diffb = ImageChops.difference(imgbase, basecrop)
                    # blends image values
                    diffbasecrop = ImageChops.add(diffb, diffb, 2, 0)
                    # crop box def
                    BboxI = diffbasecrop.getbbox()
                    # use box to crop
                    imgbase = imgbase.crop(BboxI)
                    # resize baseimage when needed
                    resproc = str(strigresproc.get() + "%")
                    if baseres == "y" or resproc != "100%":
                        if resproc[1] == "%":
                            resproc = int(resproc[0])/100
                        elif resproc[2] == "%":
                            resproc = int(resproc[:2])/100
                        elif resproc[3] == "%":
                            resproc = int(resproc[:3])/100
                        imgbase =  imgbase.resize((int(imgbase.width*resproc),int(imgbase.height*resproc)),Image.ANTIALIAS)
                    # Determine new position inside image
                    # Add base
                    try:
                        imgN.paste(imgbase, (postvalue(posbase,imgbase,offsetbx,offsetby)[0],postvalue(posbase,imgbase,offsetbx,offsetby)[1]),imgbase)
                    except ValueError:
                        imgN.paste(imgbase, (postvalue(posbase,imgbase,offsetbx,offsetby)[0],postvalue(posbase,imgbase,offsetbx,offsetby)[1]))

                    # Add first tex image
                    try:
                        try:
                            imgN.paste(imgtexm1, (postvalue(postex1, imgtex1, offsettx1, offsetty1)[0], postvalue(postex1, imgtex1, offsettx1, offsetty1)[1]), imgtexm1)
                        except ValueError:
                            imgN.paste(imgtexm1, (postvalue(postex1, imgtex1, offsettx1, offsetty1)[0], postvalue(postex1, imgtex1, offsettx1, offsetty1)[1]))
                    except UnboundLocalError:
                        pass
                    except AttributeError:
                        pass
                    # Add second text image
                    try:
                        try:
                            imgN.paste(imgtexm2, (postvalue(postex2,imgtex2,offsettx2,offsetty2)[0],postvalue(postex2,imgtex2,offsettx2,offsetty2)[1]), imgtexm2)
                        except ValueError:
                            imgN.paste(imgtexm2, (postvalue(postex2,imgtex2,offsettx2,offsetty2)[0],postvalue(postex2,imgtex2,offsettx2,offsetty2)[1]))
                    except UnboundLocalError:
                        pass
                    except AttributeError:
                        pass
                    except NameError:
                        pass
                    # Add second text image
                    try:
                        try:
                            imgN.paste(imgtexm3, (postvalue(postex3,imgtex3,offsettx3,offsetty3)[0],postvalue(postex3,imgtex3,offsettx3,offsetty3)[1]), imgtexm3)
                        except ValueError:
                            imgN.paste(imgtexm3, (postvalue(postex3,imgtex3,offsettx3,offsetty3)[0],postvalue(postex3,imgtex3,offsettx3,offsetty3)[1]))
                    except UnboundLocalError:
                        pass
                    except AttributeError:
                        pass
                    except NameError:
                        pass
                    # Reset local value inside loop
                    imgtex1 = None
                    imgtex2 = None
                    imgtex3 = None
                    # Draw text
                    if textmode == "Text":
                        # Value text from name
                        vtt = file.name.split("-")[targett]
                        tsize = int(imgN.height*ttsproc)
                        draw = ImageDraw.Draw(imgN)
                        font = ImageFont.truetype("C:\Windows\Fonts\AdobeFanHeitiStd-Bold.otf", tsize)
                        # Def text width to use to determin position
                        ttwidth = font.getsize(vtt)[0]
                        # Write text
                        ttlocw = int(imgN.width/2)
                        # Text pos
                        if postt == "top":
                            ttloch = 0
                        elif postt == "bottom":
                            ttloch = imgN.height-tsize
                        draw.text((ttlocw-ttwidth/2,ttloch), vtt , (0, 0, 0),font=font)
                    else:
                        pass
                    # Optimize image crop
                    if maxcrop == "y":
                        basecrop = Image.new(imgN.mode, imgN.size, imgN.getpixel((0, 0)))
                        # Inverts image based on based on the other?
                        diffb = ImageChops.difference(imgN, basecrop)
                        # Blends image values
                        diffbasecrop = ImageChops.add(diffb, diffb, 2, 0)
                        # Crop box def
                        BboxI = diffbasecrop.getbbox()
                        # Use box to crop
                        imgN = imgN.crop(BboxI)
                        OffimgN = Image.new(imgN.mode, (imgN.width+crpbrdr,imgN.height+int(crpbrdr*(crpbrdrh/100))), imgN.getpixel((0, 0)))
                        OffimgN.paste(imgN,(int((OffimgN.width-imgN.width)/2),int((OffimgN.height-imgN.height)/2)))
                        # Save image
                        OffimgN.save(pathcomp + os.sep + vsavpref.get() + file.name)
                    else:
                        # Save image
                        imgN.save(pathcomp + os.sep + vsavpref.get() + file.name)
                    print("")
            except IndexError:
                print("")
                pass
            except OSError:
                print("")
                pass
            if test == "test":
                print("sigle test mode")
                x += 1
        else :
            break
if __name__ == "__main__":
    # Start GUI
    root = Tk()
    root.title('Image Complier')
    # Create frames for Layout manipulation
    framebase = Frame(root,height=2,borderwidth=2,relief= GROOVE,padx=5, pady=5)
    framebase.pack(side="top", padx=10, pady=10)
    # Frame base
    frameload = Frame(framebase)
    frameload.pack(side="top")
        # Target elements base
    frametarget = Frame(framebase)
    frametarget.pack(side="top")
        # Position controls for base image
    framebaseposcont = Frame(framebase,height=2,borderwidth=2,relief= GROOVE,padx=5, pady=5)
    framebaseposcont.pack(side="top")
    framebasepos = Frame(framebaseposcont)
    framebasepos.pack(side="top")
    framebaseposv = Frame(framebaseposcont)
    framebaseposv.pack(side="top")
        # Save location
    framesave = Frame(framebase)
    framesave.pack(side="top")
    # Text Gui Layout
    frametxtlay = Frame(framebase,height=2,borderwidth=2,relief= GROOVE,padx=12, pady=5)
    frametxtlay.pack(side="top")
        # Text Controlers
    frametxtlab = Frame(frametxtlay)
    frametxtlab.pack(side="top")
    frametxtset = Frame(frametxtlay)
    frametxtset.pack(side="top")
    frametxtpos = Frame(frametxtlay)
    frametxtpos.pack(side="top")
    # Save first image
    framefsim = Frame(root,height=2,borderwidth=2,relief= GROOVE,padx=5, pady=5)
    framefsim.pack(side="top")
    framefsimglo = Frame(framefsim)
    framefsimglo.pack(side="top")
    framefsimset = Frame(framefsim)
    framefsimset.pack(side="top")
    framevaset = Frame(framefsim)
    framevaset.pack(side="top")
        # Layout Second image
    framescgui = Frame(root)
    framescgui.pack(side="top")
    framesdim = Frame(framescgui)
    framesdim.pack(side="top")
    framesdimglo = Frame(framesdim)
    framesdimglo.pack(side="top")
    framesdimset = Frame(framesdim)
    framesdimset.pack(side="top")
    framevassdet = Frame(framesdim)
    framevassdet.pack(side="top")
        # Layout Thrd image
    framethgui = Frame(root)
    framethgui.pack(side="top")
    framethim = Frame(framethgui)
    framethim.pack(side="top")
    framethimglo = Frame(framethim)
    framethimglo.pack(side="top")
    framethimset = Frame(framethim)
    framethimset.pack(side="top")
    framevasthet = Frame(framethim)
    framevasthet.pack(side="top")
        # Settings frame (test mode)
    framesettings = Frame(root)
    framesettings.pack(side="top")
    # Maxscrop frame
    framesettingscrop = Frame(root)
    framesettingscrop.pack(side="top")
        # Maxscrop hidden frame
    framesettingscrophi = Frame(root)
    framesettingscrophi.pack(side="top")
    # Run frame
    frameloadex = Frame(root)
    frameloadex.pack(side="top")
    framerun = Frame(root)
    framerun.pack(side="top")
    # End Frame
    # Test Mode Gui
    test = "noTest"
    testvar = StringVar(framesettings, value='noTest')
    checktestbtn = Checkbutton(framesettings, text="Test Mode",command=testmode, variable=testvar, onvalue="test", offvalue="noTest")
    checktestbtn.pack()
    # Base Image Location
    labloc = Label(frameload, text="Base Image")
    labloc.pack(side="top")
    varbasepath = StringVar(frameload, value='BaseImagePath')
    entryPath = Entry(frameload, width=82, textvariable=varbasepath)
    entryPath.pack(side="left")
        # Radio modes for base
    basemodez = [("center", "center"),("top", "top"),("bottom", "bottom"),("left", "left"),("right", "right")]
    vposbase = StringVar()
    vposbase.set("center")
        # Radio buttons for position base
    for text, mode in basemodez:
        btnbasepos = Radiobutton(framebasepos, text=text,variable=vposbase, value=mode)
        btnbasepos.pack(side="left")
        # Element base for Offset X
    labbaseoffx = Label(framebaseposv, text="Offset X procent")
    labbaseoffx.pack(side="left")
    voffsbasx = StringVar(framebaseposv, value='0')
    entryoffsbasx1 = Entry(framebaseposv, width=10, textvariable=voffsbasx)
    entryoffsbasx1.pack(side="left")
        # Element base for Offset Y
    labbaseoffy = Label(framebaseposv, text="Offset Y procent")
    labbaseoffy.pack(side="left")
    voffsbasy = StringVar(framebaseposv, value='-25')
    entryoffsbasx = Entry(framebaseposv, width=10, textvariable=voffsbasy)
    entryoffsbasx.pack(side="left")
        # Resize base value
    baseres = "y"
    strigresproc = StringVar(root, value="100")
    entryresproc = Entry(frameload, width=4, textvariable=strigresproc)
    entryresproc.pack(side="left",padx=5)
    labresproci = Label(frameload, text="%",width=1)
    labresproci.pack(side="left")
        # Target value inside filename strig (base)
    labtarget = Label(frametarget, text="NameTarget(6 = 6th word in filename)")
    labtarget.pack(side="left")
        # Target inside name
    vleftextrat = StringVar(frametarget, value='')
    vtarget1 = StringVar(frametarget, value='6')
    vrightextrat = StringVar(frametarget, value='')
    entryleftt = Entry(frametarget, width=5, textvariable=vleftextrat)
    entryleftt.pack(side="left")
    entrytarget1 = Entry(frametarget, width=5, textvariable=vtarget1)
    entrytarget1.pack(side="left")
    entryrightt = Entry(frametarget, width=5, textvariable=vrightextrat)
    entryrightt.pack(side="left")
        # Do with seperator value (base)
    labsep = Label(frametarget, text="Seperator")
    labsep.pack(side="left")
    vbasesep = StringVar(frametarget, value='-')
    entrybasesep = Entry(frametarget, width=5, textvariable=vbasesep)
    entrybasesep.pack(side="left")
        # Load base path button
    loadbasepathbtn = Button(frameload, text='Load', command=loadim, width=8)
    loadbasepathbtn.pack(side="left")
    # Txt settings
    labtxtme = Label(frametxtlab, text="Text Menu")
    labtxtme.pack(side="top")
    textmode = "Text"
    vtextmode = StringVar(frametxtset, value='Text')
    checktxtbtn = Checkbutton(frametxtset, text="Text",command=textvarmode, variable=vtextmode, onvalue="Text", offvalue="noText")
    checktxtbtn.pack(side="left")
    checktxtbtn.select()
        # Get value from file name strig position
    vtargetxt = StringVar(frametxtset, value=6)
    entrybasesep = Entry(frametxtset, width=5, textvariable=vtargetxt)
    entrybasesep.pack(side="left")
    labtxt = Label(frametxtset, text="From TextTarget")
    labtxt.pack(side="left")
        # Resize text procent of whole image
    vproctxt = StringVar(frametxtset, value=5)
    entryproctxt = Entry(frametxtset, width=5, textvariable=vproctxt)
    entryproctxt.pack(side="left")
    labproctxt = Label(frametxtset, text="Procent SizeText")
    labproctxt.pack(side="left")
        # Text Position
    modetext = [("top", "top"),("bottom", "bottom")]
    vpostxt = StringVar()
    vpostxt.set("top")
        # Radio buttons for position Text
    for text, mode in modetext:
        btntextsel = Radiobutton(frametxtpos, text=text,variable=vpostxt, value=mode)
        btntextsel.pack(side="left")
    # Save path Location
    labsavloc = Label(framesave, text="Save Location")
    labsavloc.pack(side="top")
        # Save prefix entry
    labsavpref = Label(framesave, text="Prefix")
    labsavpref.pack(side="left")
    vsavpref = StringVar(framesave, value='Comp-')
    entrysavpref = Entry(framesave, width=7, textvariable=vsavpref)
    entrysavpref.pack(side="left")
        # Save entry layout
    varsavpath = StringVar(framesave, value='Save Path')
    entrySavepath = Entry(framesave, width=64, textvariable=varsavpath)
    entrySavepath.pack(side="left",padx=5)
        # Extention
    saveopt = [".png", ".jpg", ".tif"]
    vext = StringVar()
    vext.set(saveopt[0])
    resizev = OptionMenu(framesave,vext,*saveopt)
    resizev.config(width=3)
    resizev.pack(side="left",padx=2)
    resizev.config(bg='#e59800')
        # Load path button
    loadpathsavebtn = Button(framesave, text='Load', command=loadsavloc, width=8)
    loadpathsavebtn.pack(side="left")
    # Base First Image add
    labfsimg = Label(framefsimglo, text="First Texture Image")
    labfsimg.pack(side="top")
    varfsimg = StringVar(framefsimglo, value='TextureImagePath')
    entryfsimgPath = Entry(framefsimglo, width=92, textvariable=varfsimg)
    entryfsimgPath.pack(side="left")
    loadbasepathbtn = Button(framefsimglo, text='Load', command=loadfsimg, width=8)
    loadbasepathbtn.pack(side="left")
       # Element for Size First image
    labstexv = Label(framevaset, text="Size in Pixels")
    labstexv.pack(side="left")
    vMsi = StringVar(framevaset, value='800')
    entryMsi = Entry(framevaset, width=10, textvariable=vMsi)
    entryMsi.pack(side="left")
        # Element for Offset X First image
    laboffx1 = Label(framevaset, text="Offset X procent")
    laboffx1.pack(side="left")
    voffsttx1 = StringVar(framevaset, value='0')
    entryoffsttx1 = Entry(framevaset, width=10, textvariable=voffsttx1)
    entryoffsttx1.pack(side="left")
        # Element for Offset Y First image
    laboffy1 = Label(framevaset, text="Offset Y procent")
    laboffy1.pack(side="left")
    voffstty1 = StringVar(framevaset, value='70')
    entryoffstty1 = Entry(framevaset, width=10, textvariable=voffstty1)
    entryoffstty1.pack(side="left")
        # Radio buttons First image
    modez = [("center", "center"),("top", "top"),("bottom", "bottom"),("left", "left"),("right", "right")]
    vpostex1 = StringVar()
    vpostex1.set("center")
        # Radio buttons for position FirstImage
    for text, mode in modez:
        b = Radiobutton(framefsimset, text=text,variable=vpostex1, value=mode)
        b.pack(side="left")
    # Load Second Image
    loadsecondimgui = Button(frameloadex, text='Load2ndImg', bg="Yellow", command=loadsecondimg, width=10, height=1)
    loadsecondimgui.pack(side="left")
        # Images Second Image strings
    vMsi2 = StringVar(framevassdet, value='800')
    modez2 = [("center", "center"), ("top", "top"), ("bottom", "bottom"), ("left", "left"), ("right", "right")]
        # Store String Variables for SecondImage
    varfsimg2 = StringVar(framesdimglo, value='TextureImagePath')
    voffsttx2 = StringVar(framevassdet, value='0')
    voffstty2 = StringVar(framevassdet, value='0')
    vpostex2 = StringVar()
    # Load Third Image
    loadthirdmgui = Button(frameloadex, text='Load3rdImg', bg="Yellow", command=loadthirdimg, width=10, height=1)
    loadthirdmgui.pack(side="left")
        # Images Third Image strings
    vMsi3 = StringVar(framevassdet, value='800')
    modez3 = [("center", "center"), ("top", "top"), ("bottom", "bottom"), ("left", "left"), ("right", "right")]
    # Store String Variables for ThirdImage
    varfsimg3 = StringVar(framethimglo, value='TextureImagePath')
    voffsttx3 = StringVar(framevasthet, value='0')
    voffstty3 = StringVar(framevasthet, value='0')
    vpostex3 = StringVar()
    # Max crop mode
    vmaxcrop = StringVar(framesettingscrop, value='n')
    vcrpbrdr = StringVar(framesettingscrop, value='200')
    vcrpbrdrh = StringVar(framesettingscrop, value='30')
        # Max crop new entries
    checkmcropbtn = Checkbutton(framesettingscrop, text="MaxCrop",command=cropmaxvalue, variable=vmaxcrop, onvalue="y", offvalue="n")
    checkmcropbtn.pack(side="left")
    # Run comp
    loadimgbtn = Button(framerun, text='Run', bg="Orange", command=imagecomp, width=21, height=2)
    loadimgbtn.pack(side="top")
    # End main GUI loop
    root.mainloop()