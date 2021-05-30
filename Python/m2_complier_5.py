# This script was created for INDG to complie m2 presets for AkzoNobel
# added GUI

from tkinter import filedialog
from tkinter import *
from tkinter import messagebox
import os
from PIL import Image, ImageChops, ImageDraw, ImageFont
import pandas

dir_path = os.path.dirname(os.path.realpath(__file__))
#print (dir_path)

def m2_comp():
    # paths
    impath = ImageTarget.get()
    bkpath = entryBackground.get()
    #alphapath = dir_path
    alphapath = 'C:/Users/DING/Documents/3dsMax/akzo Nobel/m2_comper'
    csvpath = filedialog.askopenfilename()

    # Delimiter, CSV file
    delim = variable.get()

    # CSV = 'Akzo_test.csv'
    df = pandas.read_csv(csvpath, delimiter=delim, dtype=str)
    df2 = df.set_index("Filename", drop=False)
    # Image size
    # Mdsi = int(imgSize.get())
    Mdsi = int(imgSize.get())

    for index, row in df2.iterrows():
        try:
            # get filename
            file_name = row['Filename']
            print('Searching for : ' + file_name)
            # add hex value
            try:
                h = df2.loc[file_name, 'HEX']
                print (h)
            except KeyError:
                pass
            # get m2 number
            try:
                NrV = (df2.loc[file_name, 'm2'])
                print(NrV)
            except TypeError:
                print("Missing m2 value")
                print('    ')
                pass
            # remove extention
            Imn = (file_name[:-4])
        except TypeError:
            print("Invalid Filename Column")
            print('    ')
            break
        try:
            # define constants elements
            alphaTop = alphapath + '/' + 'Top_alpha.png'
            imAtc = Image.open(alphaTop)
            ######
            imAt = imAtc.resize((Mdsi, Mdsi), Image.ANTIALIAS)
            ######
            alphaBottom = alphapath + '/' + 'Bottom_alpha.png'
            imAbc = Image.open(alphaBottom)
            imAb = imAbc.resize((Mdsi, Mdsi), Image.ANTIALIAS)
            ######
            imIcon = alphapath + '/' + 'ICON.png'
            imIconIb = Image.open(imIcon)
            imIconI = imIconIb.resize((int(Mdsi*(0.207)),int((Mdsi*(0.207)))), Image.ANTIALIAS)
            #imIconB = alphapath + '/' + 'ICONB.png'
            #imIconIB = Image.open(imIconB)
        except FileNotFoundError:
            print("Missing Alphas for backgrounds")
            break

        # define color constants
        greyRgb = (236, 236, 236)
        white = (255, 255, 255)
        # extention constant
        ext = '.png'
        try:
            # load image
            im = Image.open(impath + '/' + Imn + ext)
            # crops image (if white or transparent)
            ImC = Image.new(im.mode, im.size, im.getpixel((0, 0)))
            diffb = ImageChops.difference(im, ImC)
            diffb2 = ImageChops.add(diffb, diffb, 2, 0)
            BboxI = diffb2.getbbox()
            imO = im.crop((BboxI))

            # define size elements
            Md = int(Mdsi * (0.635))
            PosH = int(Mdsi * (0.1825))
            PosW = int(Mdsi * (0.325))
            iw = imO.width
            ih = imO.height

            # Resize and position image
            if imO.height > imO.width:
                # print('Height is bigger')
                i_ar = iw / ih
                ns = imO.resize((int(Md * i_ar), Md), Image.ANTIALIAS)
                nsM = Image.new('RGBA', (Md, Md))
                nsM.paste(ns, ((int((Md - ns.width) / 2)), 0), ns)
            elif imO.height < imO.width:
                # print('Weight is bigger')
                i_ar = ih / iw
                ns = imO.resize(Md, (int(Md * i_ar), Image.ANTIALIAS))
                nsM = Image.new('RGBA', (Md, Md))
                nsM.paste(ns, (0, (int((Md - ns.height) / 2))), ns)
            elif imO.height == imO.width:
                # print('Equality')
                i_ar = ih / iw
                ns = imO.resize(Md, Md, Image.ANTIALIAS)
                nsM = Image.new('RGBA', (Md, Md))
                nsM.paste(ns, (0, 0), ns)

            # Image add background
            # Background elements
            # create Image (Mdsi is image size)
            ImnS = Image.new('RGBA', (Mdsi, Mdsi), white)

            # Add hex
            try:
                try:
                    RGB = (tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)))
                except IndexError:
                    pass
                # print(RGB)
                try:
                    imHex = Image.new('RGBA', (Mdsi, Mdsi), RGB)
                    ImnS.paste(imHex, (0, 0), imAt)
                except UnboundLocalError:
                    try:
                        print('Hex value missing')
                        # add background if no hex provided
                        BImg = row['background']
                        imb = Image.open(bkpath + '/' + BImg)
                        imbrs = imb.resize((Mdsi, Mdsi), Image.BILINEAR)
                        ImnS.paste(imbrs, (0, 0), imAt)
                        print("Adding : " + BImg)
                    except TypeError:
                        print('No Background Image Found')
                        pass
                    pass
            except TypeError:
                try:
                    print('Hex value missing')
                    # add background if no hex provided
                    BImg = row['background']
                    imb = Image.open(bkpath + '/' + BImg)
                    imbrs = imb.resize((Mdsi, Mdsi), Image.BILINEAR)
                    ImnS.paste(imbrs, (0, 0), imAt)
                    print("Adding : " + BImg)
                except TypeError:
                    print('No Background Image Found')
                    pass
                pass

            # add grey bottom constant
            imBg = Image.new('RGBA', (Mdsi, Mdsi), greyRgb)
            ImnS.paste(imBg, (0, 0), imAb)
            ipw = int(Mdsi*(0.755))
            iph = int(Mdsi*(0.021))
            ImnS.paste(imIconI, (ipw, iph), imIconI)
            # add text
            ttw = int(Mdsi*(0.05))
            tth = int(Mdsi*(0.041))
            #text hight
            ithi = int(Mdsi*(0.038))
            ImText = Image.new('RGBA', (ttw, tth))
            draw = ImageDraw.Draw(ImText)
            #font = ImageFont.truetype(r'C:\Window\Fonts\arialbd.ttf', 102)
            font = ImageFont.truetype(r'C:\Window\Fonts\arialbd.ttf', ithi)
            wt, ht = draw.textsize(str(NrV), font=font)
            draw.text(((ImText.width - wt) / 2, (ImText.height - ht) / 2), str(NrV), (26, 26, 26),
                      font=font)
            ImText.save(impath + '/' + 'text.png')
            ttpw = int(Mdsi*(0.843))
            ttph = int(Mdsi*(0.056))
            ImnS.paste(ImText, (ttpw, ttph), ImText)

            # create folder
            suffix = '_AkzoNobel_m2'
            ndir = impath + "/AkzoNobel_m2_preset"
            try:
                os.mkdir(ndir)
            except OSError:
                pass
            # add render
            ImnS.paste(nsM, (PosH, PosW), nsM)
            ImnS.save(ndir + '/' + Imn + suffix + ext)
            # print(row['Filename'], row['m2'])
            print('Done!')
            print('   ')
        except FileNotFoundError:
            print("File Not Found: " + file_name)
            print('   ')
            pass
        pass

    #annyoing message
    #messagebox.showinfo("By LivyX", "This is here just to be annoying, also Done!")

if __name__ == "__main__":
    #Create window
    app = Tk()
    app.title('m2 Preset')
    app.minsize(400, 200)
    app.maxsize(400, 200)
    app.geometry("400x200")
    #Input
    labels = Label(app, text="Image Location")
    labels.pack()
    ImageTarget = Entry(app,width= 50)
    ImageTarget.pack()
    #InputSearch Location
    labels = Label(app, text="Backgrounds Folder")
    labels.pack()
    entryBackground = Entry(app,width= 50)
    entryBackground.pack()
    #Input Select delimter
    labels = Label(app, text="Delimiter")
    labels.pack()

    OPTIONS = [
        ";",
        ",",
        ":",
        "/"
    ]
    variable = StringVar(app)
    variable.set(OPTIONS [0])
    entrydelim = OptionMenu(app,variable,*OPTIONS )
    entrydelim.pack()

    labels = Label(app, text="Image size")
    labels.pack()

    imgSize = Entry(app,width=7)
    imgSize.insert(END, '2500')
    imgSize.pack()

    #Run Button
    button_run = Button(app, text="Run complier", command=m2_comp)
    button_run.pack()

    #loop
    app.mainloop()