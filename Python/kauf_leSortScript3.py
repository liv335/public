import shutil
import os
from pathlib import Path
from tkinter import *

arrayFolder = ["130-170","202-232","265-295","397-427","460-490","592-622","659-689",
               "774-838","950-980","1013-1043","1157-1187","1220-1250","1364-1394",
               "1434-1464","1516-1576","1606-1646","1688-1718","1751-1781","1811-1841",
               "1874-1904","1961-1991","2028-2058","2100-2160","2190-2220","2262-2292",
               "2325-2355","2397-2427","2473-2503","2560-2590","2627-2657","2718-2778","2808-2980"]

def runMode():
    pathLoad = var_path.get()
    print (pathLoad)
    for p in arrayFolder:
        try:
            os.makedirs(pathLoad + os.sep + str(p))
        except FileExistsError:
            pass
        except TypeError:
            print("bad path")
            pass

    for files in Path(pathLoad).glob("*.png"):
        for i in arrayFolder:
            try:
                stringI = str(i)
                if int(stringI.split("-")[0]) <= int(str(files.stem).split(var_key.get())[1]) <= int(stringI.split("-")[1]):
                    print (files.name)
                    shutil.move(str(files),pathLoad + os.sep + stringI + os.sep + files.name)
            except ValueError:
                pass
            except TypeError:
                print("bad path")
                pass

if __name__ == '__main__':
    app = Tk()
    app.title('sorter')

    var_path = StringVar(app, value='path')
    var_key = StringVar(app, value='ie')

    app.minsize(400, 80)
    app.maxsize(400, 80)

    frametop = Frame(app)
    frametop.pack(side="top")

    framebottom = Frame(app)
    framebottom.pack(side="top")

    lbl_path = Label(frametop, text="path")
    lbl_path.pack(side="left")

    entry_path = Entry(frametop, textvariable=var_path,width=50)
    entry_path.pack(side="left")

    lbl_key = Label(frametop, text="key")
    lbl_key.pack(side="left")

    entry_key = Entry(frametop, textvariable=var_key)
    entry_key.pack(side="left")

    btn_run = Button(framebottom, text='sort', bg="green", command=runMode, width=40, height=2)
    btn_run.pack(side="top")

    app.mainloop()