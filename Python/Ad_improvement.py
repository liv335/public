from tkinter import *
from tkinter import filedialog
from pathlib import Path
from PIL import Image, ImageChops
from scipy.interpolate import interp1d
import os, shutil, json, numpy as np, time
from colorama import init, Fore
init(autoreset=True)

# Frame 0
def bnt_frm0_click():
    if bnt_frm0.config('text')[(-1)] == 'On_frame_1st':
        bnt_frm0.config(text='Off_frame_1st', fg='red')
    else:
        bnt_frm0.config(text='On_frame_1st', fg='green')
# Frame 8
def bnt_frm8_click():
    if bnt_frm8.config('text')[(-1)] == 'On_frame_2nd':
        bnt_frm8.config(text='Off_frame_2nd', fg='red')
    else:
        bnt_frm8.config(text='On_frame_2nd', fg='green')
# Frame 17
def bnt_frm17_click():
    if bnt_frm17.config('text')[(-1)] == 'On_frame_3rd':
        bnt_frm17.config(text='Off_frame_3rd', fg='red')
    else:
        bnt_frm17.config(text='On_frame_3rd', fg='green')
# Frame 48
def bnt_frm48_click():
    if bnt_frm48.config('text')[(-1)] == 'On_frame_4th':
        bnt_frm48.config(text='Off_frame_4th', fg='red')
    else:
        bnt_frm48.config(text='On_frame_4th', fg='green')
# Frame 182
def bnt_frm182_click():
    if bnt_frm182.config('text')[(-1)] == 'On_frame_5th':
        bnt_frm182.config(text='Off_frame_5th', fg='red')
    else:
        bnt_frm182.config(text='On_frame_5th', fg='green')

# Frame white_white
def bnt_frmwhite_white_click():
    if bnt_frmwhite_white.config('text')[(-1)] == 'Off_envWhite_white':
        bnt_frmwhite_white.config(text='On_envWhite_white', fg='green')
    else:
        bnt_frmwhite_white.config(text='Off_envWhite_white', fg='red')
# Frame white_black
def bnt_frmwhite_black_click():
    if bnt_frmwhite_black.config('text')[(-1)] == 'Off_envWhite_white':
        bnt_frmwhite_black.config(text='On_envWhite_black', fg='green')
    else:
        bnt_frmwhite_black.config(text='Off_envWhite_black', fg='red')
# Frame white_black_black
def bnt_frmenvblack_black_click():
    if bnt_frmenvblack_black.config('text')[(-1)] == 'Off_envBlack_black':
        bnt_frmenvblack_black.config(text='On_envBlack_black', fg='green')
    else:
        bnt_frmenvblack_black.config(text='Off_envBlack_black', fg='red')
# black_white
def bnt_frmblack_white_click():
    if bnt_frmblack_white.config('text')[(-1)] == 'Off_envBlack_white':
        bnt_frmblack_white.config(text='On_envBlack_white', fg='green')
    else:
        bnt_frmblack_white.config(text='Off_envBlack_white', fg='red')

# collect
def collectsecretframes():
    '''
    approvedlist = ('envBlack_white0000', 'envBlack_black0000', 'envWhite_white0000', 'envWhite_black0000',
                    'F-0008', 'F-0017', 'F-0048', 'F-0182',
                    'F-0016', 'F-0112', 'F-0128', 'F-0129', 'F-0130',
                    'Hdr0000')
     '''
    approvedlist = ('envBlack_white0000', 'envBlack_black0000', 'envWhite_white0000', 'envWhite_black0000',
                    'F-', 'Hdr0000')

    secretlocation = str(os.path.normpath(sourcevar.get() + os.sep + os.pardir)) + os.sep + 'render_output' + os.sep + 'AdOverviewImage'
    for secretrenders in approvedlist:
        for files in Path(secretlocation).glob('*' + secretrenders + '*'):
            if files.suffix == ".png" or files.suffix == ".jpg" or files.suffix == ".json":
                print(Fore.LIGHTGREEN_EX + 'Found: ' + str(files.name))
                shutil.copy(str(files), sourcevar.get() + os.sep + files.name)
# collect
def collectsecretartwork():
    try:
        artworkSource.set(filedialog.askopenfilename())
        t_btnartworksecret.config(text=(artworkSource.get()), fg='cyan')
        if len(artworkSource.get()) == 0:
            t_btnartworksecret.config(text='OverrideArtwork', fg='black')
    except FileNotFoundError:
        artworkSource.set('OverrideArtwork')
        t_btnartworksecret.config(text='OverrideArtwork', fg='black')

# resize
def resizeimage(imageobj, imagesize):
    newsizeimage = None
    iw = imageobj.width
    ih = imageobj.height
    if imageobj.height > imageobj.width:
        i_ar = iw / ih
        newsizeimage = imageobj.resize((int(imagesize * i_ar), imagesize), Image.ANTIALIAS)
    elif imageobj.height < imageobj.width:
        i_ar = ih / iw
        newsizeimage = imageobj.resize((imagesize, (int(imagesize * i_ar))), Image.ANTIALIAS)
    elif imageobj.height == imageobj.width:
        newsizeimage = imageobj.resize((imagesize, imagesize), Image.ANTIALIAS)
    return newsizeimage
# Max crop
def maxscropimage(imageobj):
    createbaseresize = Image.new(imageobj.mode, imageobj.size, imageobj.getpixel((0, 0)))
    # inverts image based on based on the other?
    invertimage = ImageChops.difference(imageobj, createbaseresize)
    # blends image values
    blendinvertimage = ImageChops.add(invertimage, invertimage, 2, 0)
    # crop box def
    getboundboxfromval = blendinvertimage.getbbox()
    # use box to crop
    newcropobj = imageobj.crop(getboundboxfromval)
    return newcropobj
# create new SquareImage
def squareimage(modulesize, imageobj, color, extentioncheck, colormode):
    newsquaredImage = None
    if extentioncheck == ".jpg":
        newsquaredImage = Image.new("RGB", (modulesize, modulesize), color)
    elif extentioncheck == ".png":
        newsquaredImage = Image.new(colormode, (modulesize, modulesize), color)
    # Center Image
    poswidth = (int((modulesize - imageobj.height) / 2))
    posheight = (int((modulesize - imageobj.width) / 2))
    # Paste resize Image into New Image
    if extentioncheck == ".jpg":
        newsquaredImage.paste(imageobj, (posheight, poswidth))
    elif extentioncheck == ".png":
        try:
            newsquaredImage.paste(imageobj, (posheight, poswidth), imageobj)
        except ValueError:
            newsquaredImage.paste(imageobj, (posheight, poswidth))
    return newsquaredImage

# Return Curve
def returncurve():
    os.chdir(sourcevar.get())
    path0  = os.path.normpath(os.getcwd() + os.sep + os.pardir)
    ext = ".json"
    for file in Path(path0).glob('**/*' + ext):
        try:
            j = file
            with open(j, 'r+') as f:
                dataid = json.load(f)
                try:
                    id_num = dataid['colorCorrectionCurve']
                    break
                except KeyError:
                    id_num = dataid['curves']
                    break
        except KeyError:
            print("")
    try:
        curve = str(id_num).replace("[", "").replace("]", "")
        print("found curve in " + str(file.name))
        #print(curve)
    except NameError:
        curve = "0.0,0.0, 0.25,0.25, 0.5,0.5, 0.75,0.75, 1.0,1.0"
        print("No json with curve found")
        print("using default curve")
    return curve
# write
def writecurve():
    A = None
    B = A.replace(' ', '')
    bec = []
    try:
        for num in B.split(','):
            c = float(num) * 255
            bec.append(int(c))

        print(bec)
        ca = 0
        cb = 2
        for num in range(5):
            print(str(bec[ca:cb]).replace('[', '').replace(']', ''))
            if ca < 8:
                ca += 2
                cb += 2
            else:
                ca = 8
                cb = 10

    except ValueError:
        print(Fore.LIGHTRED_EX + 'Add some curve values EX: 0,0,0,0,0.25,0.15,0.75,0.56,0.91,0.95,1,1')
# add curve to Image
def addcurve(imagobj):
    curvez = returncurve()

    print("Adding Curve")
    x = []
    y = []
    co = 0
    curve = curvez.split(',')
    for num in curve:
        if (co % 2) and not num * 100 == 0 and not num == 1:
            y.append(float(num))
        elif not (co % 2) and not num * 100 == 0 and not num == 1:
            x.append(float(num))
        co += 1

    if len(x) > 2 and len(y) > 2:
        x = x
        y = y
    else:
        x = [0.0,0.25,0.5,0.75,1.0]
        y = [0.0,0.25,0.5,0.75,1.0]
    print (len(x))
    f2 = interp1d(x, y, kind='cubic')
    xnew = np.linspace(0, 1, num=256, endpoint=True)
    listc = f2(xnew)
    # remove values below 0 and above 1
    list0 = [0 if i < 0 else i for i in listc]
    list01 = [1 if i > 1 else i for i in list0]
    listm = [int((i) * 255) for i in list01]
    bb = np.round((listm), decimals=0)
    # npImage = np.array(Image.open(path1 + f))
    npImage = imagobj
    # redef type data
    cc = bb.astype(np.uint8)
    # apply data save image
    im = Image.fromarray(cc[npImage])
    return im
# run mode
def runcreate(modsize, filetouse, color, colormode, filepos, pathtouse, curvecheck):
    imageobj = Image.open(pathtouse + os.sep + filetouse)
    if imageobj.mode == "I" or imageobj.mode == "F":
        n = np.array(imageobj)
        n = (n / 256).astype(np.uint8)
        r = Image.fromarray(n)
        imageobj = r.convert('RGB')
    imageobj = maxscropimage(imageobj)
    imageobj = resizeimage(imageobj, modsize)
    imageobj = squareimage(modsize, imageobj, color, filetouse.split(filetouse[:-4])[(-1)], colormode)
    if curvecheck == True:
        imageobj = addcurve(imageobj)
    funCompDoit.paste(imageobj, filepos)

## lazy update because i feel shitty
def createadsign():
    global funCompDoit
    path = entrySource.get()
    if path.split('\\')[(-1)] != 'ad_signoff':
        sourcevar.set(path + os.sep + 'ad_signoff')
    # Frames
    F0P = (60, 11)
    F8P = (42, 1457)
    F17P = (816, 1457)
    F48P = (1584, 1457)
    F182P = (2358, 1457)

    F0A = (60, 11)
    F16A = (42, 1457)
    F48A = (816, 1457)
    F129A = (1584, 1457)
    F130A = (2358, 1457)

    F0C = (60, 11)
    F17C = (42, 1457)
    F48C = (816, 1457)
    F112C = (1584, 1457)
    F128C = (2358, 1457)

    # env black/white
    CEBB = (2358, 2278)
    CEBW = (816, 2278)
    CEWW = (42, 2278)
    CEWB = (1584, 2278)

    # miscelanious things
    HdrP = (3180, 11)
    ArtP = (2223, 3153)
    RefP = (1614, 11)

    # sizes
    MdArt = 1453
    MdF0 = 1300
    MdBig = 1385
    Mdsmall = 770

    White = (255, 255, 255)
    Black = (0, 0, 0)
    cMod = 'RGB'
    filepngext = '.png'
    filejpgext = '.jpg'

    Frame0 = 'F-0000'
    Frame8 = 'F-0008'
    Frame17 = 'F-0017'
    Frame48 = 'F-0048'
    Frame182 = 'F-0182'

    Frame16 = 'F-0016'
    Frame112 = 'F-0112'
    Frame128 = 'F-0128'
    Frame129 = 'F-0129'
    Frame130 = 'F-0130'

    FrameBB = 'envBlack_black0000'
    FrameBW = 'envBlack_white0000'
    FrameWW = 'envWhite_white0000'
    FrameWB = 'envWhite_black0000'
    HdrFile = 'Hdr'
    ArtworkFile = 'Artwork'
    RefFile = 'IMG_1000'

    ParentDir = os.path.normpath(sourcevar.get() + os.sep + os.pardir)
    ArtworkDir = ParentDir + os.sep + 'artworks' + os.sep + 'artwork'
    ArtworkCheck = ArtworkDir + os.sep + os.path.basename(os.path.normpath(ParentDir)) + '-art' + '.png'
    if artworkSource.get() != 'OverrideArtwork':
        if artworkSource.get() != '' and (artworkSource.get()[-4:] == '.png' or artworkSource.get()[-4:] == '.PNG'):
            ArtworkCheck = artworkSource.get()

    if os.path.isfile(ArtworkCheck):
        shutil.copy(ArtworkCheck, sourcevar.get() + os.sep + 'Artwork.png')
    else:
        print('Not Found Artwork: ' + str(ArtworkCheck))

    adnameValue = 'AD_signoff_empty.png'
    adimageLoad = Image.new('RGB', (4596, 4611), (255, 255, 255))

    if os.path.isfile('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked' + os.sep + adnameValue):
        adimageLoad = Image.open('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked' + os.sep + adnameValue)
    else:
        if not os.path.isfile('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked' + os.sep + adnameValue):
            try:
                shutil.copy('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked' + os.sep + adnameValue, sourcevar.get() + os.sep + adnameValue)
            except PermissionError:
                adimageLoad = Image.new('RGB', (4596, 4611), (255, 255, 255))
                print(Fore.LIGHTRED_EX + 'Canci Find the Ad-Template, will give you a blank one')
                pass
        else:
            try:
                adimageLoad = Image.open(sourcevar.get() + os.sep + adnameValue)
            except FileNotFoundError:
                adimageLoad = Image.new('RGB', (4596, 4611), (255, 255, 255))
                print(Fore.LIGHTRED_EX + 'Canci Find the Ad-Template, will give you a blank one')

    funCompDoit = Image.new(adimageLoad.mode, adimageLoad.size, adimageLoad.getpixel((0,0)))
    funCompDoit.paste(adimageLoad, (0, 0))
    print(Fore.LIGHTMAGENTA_EX + 'Creating Adsignoff\n')

    print (findSubDerivative())
    print (selectString.get())
    # default
    filecrazyarray = [Frame0 + filepngext,
                      Frame8 + filepngext, Frame17 + filepngext,
                      Frame48 + filepngext, Frame182 + filepngext,
                      FrameBB + filepngext, FrameBW + filepngext,
                      FrameWW + filepngext, FrameWB + filepngext,
                      HdrFile + filejpgext, ArtworkFile + filepngext, RefFile + filejpgext]
    coordscrazyarray = [F0P, F8P, F17P, F48P, F182P, CEBB, CEBW, CEWW, CEWB, HdrP, ArtP, RefP]
    sizearraysexy = [MdF0, Mdsmall, Mdsmall, Mdsmall, Mdsmall, Mdsmall, Mdsmall, Mdsmall, Mdsmall, MdBig, MdArt, MdBig]
    bntcrazymofoarray = [bnt_frm0.config('fg')[(-1)] == 'green',
                         bnt_frm8.config('fg')[(-1)] == 'green', bnt_frm17.config('fg')[(-1)] == 'green',
                         bnt_frm48.config('fg')[(-1)] == 'green', bnt_frm182.config('fg')[(-1)] == 'green',
                         bnt_frmwhite_white.config('fg')[(-1)] == 'green', bnt_frmwhite_black.config('fg')[(-1)] == 'green',
                         bnt_frmenvblack_black.config('fg')[(-1)] == 'green', bnt_frmblack_white.config('fg')[(-1)] == 'green',
                         False, False, False]
    ## for cola
    if (findSubDerivative() == "cocacola" and selectString.get() == "automatic") or selectString.get() == "cocacola":
        filecrazyarray = [Frame0 + filepngext,
                          Frame8 + filepngext, Frame17 + filepngext,
                          Frame112 + filepngext, Frame128 + filepngext,
                          FrameBB + filepngext, FrameBW + filepngext,
                          FrameWW + filepngext, FrameWB + filepngext,
                          HdrFile + filejpgext, ArtworkFile + filepngext, RefFile + filejpgext]
        coordscrazyarray = [F0C ,
                            F17C, F48C,
                            F112C, F128C,
                            CEBB, CEBW,
                            CEWW, CEWB,
                            HdrP, ArtP, RefP]
        sizearraysexy = [MdF0,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         MdBig, MdArt, MdBig]
        bntcrazymofoarray = [bnt_frm0.config('fg')[(-1)] == 'green',
                             bnt_frm8.config('fg')[(-1)] == 'green', bnt_frm17.config('fg')[(-1)] == 'green',
                             bnt_frm48.config('fg')[(-1)] == 'green', bnt_frm182.config('fg')[(-1)] == 'green',
                             bnt_frmwhite_white.config('fg')[(-1)] == 'green',
                             bnt_frmwhite_black.config('fg')[(-1)] == 'green',
                             bnt_frmenvblack_black.config('fg')[(-1)] == 'green',
                             bnt_frmblack_white.config('fg')[(-1)] == 'green',
                             False, False, False]
    ## for akzo
    elif (findSubDerivative() == "akzoNobel" and selectString.get() == "automatic") or selectString.get() == "akzoNobel":
        filecrazyarray = [Frame0 + filepngext,
                          Frame16 + filepngext, Frame48 + filepngext,
                          Frame129 + filepngext, Frame130 + filepngext,
                          FrameBB + filepngext, FrameBW + filepngext,
                          FrameWW + filepngext, FrameWB + filepngext,
                          HdrFile + filejpgext, ArtworkFile + filepngext, RefFile + filejpgext]
        coordscrazyarray = [F0A,
                            F16A, F48A,
                            F129A, F130A,
                            CEBB, CEBW,
                            CEWW, CEWB,
                            HdrP, ArtP, RefP]
        sizearraysexy = [MdF0,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         Mdsmall, Mdsmall,
                         MdBig, MdArt, MdBig]
        bntcrazymofoarray = [bnt_frm0.config('fg')[(-1)] == 'green',
                             bnt_frm8.config('fg')[(-1)] == 'green', bnt_frm17.config('fg')[(-1)] == 'green',
                             bnt_frm48.config('fg')[(-1)] == 'green', bnt_frm182.config('fg')[(-1)] == 'green',
                             bnt_frmwhite_white.config('fg')[(-1)] == 'green',
                             bnt_frmwhite_black.config('fg')[(-1)] == 'green',
                             bnt_frmenvblack_black.config('fg')[(-1)] == 'green',
                             bnt_frmblack_white.config('fg')[(-1)] == 'green',
                             False, False, False]

    rangecnt = 0
    for itemfiles in filecrazyarray:
        try:
            print(Fore.LIGHTGREEN_EX + itemfiles)
            corrodnates = coordscrazyarray[rangecnt]
            sizevalue = sizearraysexy[rangecnt]
            if itemfiles == 'Hdr.jpg':
                if not os.path.isfile(path + os.sep + itemfiles):
                    itemfiles = 'Hdr0000.jpg'
            if os.path.isfile(path + os.sep + itemfiles):
                print('file found: ' + str(os.path.isfile(path + os.sep + itemfiles)))
            color = White
            if itemfiles == 'envBlack_white0000.png' or itemfiles == 'envBlack_black0000.png':
                color = Black
            runcreate(sizevalue, itemfiles, color, cMod, corrodnates, path, bntcrazymofoarray[rangecnt])
        except FileNotFoundError:
            print(Fore.LIGHTRED_EX + 'FileNotFoundError Error')
        print('')
        rangecnt += 1
    funCompDoitJpeg = Image.new('RGB', funCompDoit.size, (255, 255, 255))
    funCompDoitJpeg.paste(funCompDoit, (0, 0))
    try:
        if artworkSource.get() != 'OverrideArtwork':
            if artworkSource.get()[-4:] == '.png':
                textImage = Image.open('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked\\custom_artwork.jpg')
            else:
                textImage = Image.open('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked\\local_artwork.jpg')
        else:
            textImage = Image.open('\\\\nas\\GRIP\\Grip_batchTools\\Ad-StoreBacked\\local_artwork.jpg')
            funCompDoitJpeg.paste(textImage, (200, 4300))
    except PermissionError:
        pass
    except FileNotFoundError:
        pass
    timestr = time.strftime('%d-%m-%y-%Hh%Mm')
    funCompDoitJpeg.save(sourcevar.get() + os.sep + 'AutoSignOffSheet' + '_' + timestr + filejpgext)
    print(Fore.LIGHTBLUE_EX + 'Made by Lixy ver. Qt 3.1415...')
    print(Fore.LIGHTBLUE_EX + 'Finnished!!')
    print(Fore.LIGHTBLUE_EX + 'Finnished!!')

def findSubDerivative():
    setPart = "default"
    for parts in sourcevar.get().split("\\"):
        for option in OPTIONS:
            if parts == option:
                setPart = parts
    return setPart

if __name__ == '__main__':
    app = Tk()
    app.title('Ad_signoff')

    app.minsize(600, 240)
    app.maxsize(600, 240)

    app.geometry('320x100')

    frametop = Frame(app)
    frametop.pack(side='top')

    frametopsecond = Frame(app)
    frametopsecond.pack(side='top')

    frametopleft = Frame(frametopsecond)
    frametopleft.pack(side='left')

    frametopright = Frame(frametopsecond)
    frametopright.pack(side='left')

    framecurveinfo = Frame(app)
    framecurveinfo.pack(side='top')

    framelabbottom = Frame(framecurveinfo)
    framelabbottom.pack(side='top')

    framebottom = Frame(framecurveinfo)
    framebottom.pack(side='bottom')

    framebottom2 = Frame(framecurveinfo)
    framebottom2.pack(side='bottom')

    framebottom0 = Frame(framecurveinfo)
    framebottom0.pack(side='top')

    selectString = StringVar()
    OPTIONS = ["automatic","deafult","cocacola","akzoNobel"]
    selectString.set(OPTIONS[0])
    sourcevar = StringVar(app)

    artworkSource = StringVar(app)
    artworkSource.set('OverrideArtwork')

    labels1 = Label(frametop, text='Base')
    labels1.pack()

    colorparent = OptionMenu(frametop, selectString, *OPTIONS)
    colorparent.config(bg='yellow', width=10, height=1)
    colorparent.pack(side='left')

    entrySource = Entry(frametop, textvariable=sourcevar, width=60)
    entrySource.pack(side='left')

    button_run1 = Button(frametop, text='Ad_sign', command=createadsign, width=15, height=2, bg='green')
    button_run1.pack(side='top')

    t_btnframesecret = Button(frametopleft, text='SecretFramesMode', width=30, height=2, command=collectsecretframes, fg='black', bg='orange')
    t_btnframesecret.pack(side='left')

    t_btnartworksecret = Button(frametopleft, text=(artworkSource.get()), width=30, height=2, command=collectsecretartwork, fg='black', bg='grey')
    t_btnartworksecret.pack(side='left')
    v = StringVar()

    lab_in_lab = Label(framelabbottom, text='Add to curve to')
    lab_in_lab.pack(side='top')

    lab_framesinfo = Label(framelabbottom, text='Frames are off by default', fg='green')
    lab_framesinfo.pack(side='top')

    bnt_frmwhite_white = Button(framebottom, text='On_envWhite_white', width=20, command=bnt_frmwhite_white_click, fg='green')
    bnt_frmwhite_white.pack(pady=1, side='left', fill=X, expand=YES)

    bnt_frmwhite_black = Button(framebottom, text='On_envWhite_Black', width=20, command=bnt_frmwhite_black_click, fg='green')
    bnt_frmwhite_black.pack(pady=1, side='left', fill=X, expand=YES)

    bnt_frmenvblack_black = Button(framebottom, text='On_envBlack_black', width=20, command=bnt_frmenvblack_black_click, fg='green')
    bnt_frmenvblack_black.pack(pady=1, side='left', fill=X, expand=YES)

    bnt_frmblack_white = Button(framebottom, text='On_envBlack_white', width=20, command=bnt_frmblack_white_click, fg='green')
    bnt_frmblack_white.pack(pady=1, side='left', fill=X, expand=YES)

    bnt_frm182 = Button(framebottom2, text='frame_5th', width=20, command=bnt_frm182_click, fg='black')
    bnt_frm182.pack(pady=1, side='right', fill=X, expand=YES)

    bnt_frm48 = Button(framebottom2, text='frame_4th', width=20, command=bnt_frm48_click, fg='black')
    bnt_frm48.pack(pady=1, side='right', fill=X, expand=YES)

    bnt_frm17 = Button(framebottom2, text='frame_3rd', width=20, command=bnt_frm17_click, fg='black')
    bnt_frm17.pack(pady=1, side='right', fill=X, expand=YES)
    bnt_frm8 = Button(framebottom2, text='frame_2nd', width=20, command=bnt_frm8_click, fg='black')
    bnt_frm8.pack(pady=1, side='right', fill=X, expand=YES)

    bnt_frm0 = Button(framebottom0, text='frame_1st', width=30, command=bnt_frm0_click, fg='black')
    bnt_frm0.pack(pady=1, side='bottom', fill=X, expand=YES)

    #bnt_test = Button(app, text='test', width=30, command=findSubDerivative, fg='black')
    #bnt_test.pack(pady=1, side='bottom', fill=X, expand=YES)

    app.mainloop()