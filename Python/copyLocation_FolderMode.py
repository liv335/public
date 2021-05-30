# Working GUI for search and copy to location, useful for finding many files in a tree of folders
# based on text file with names.

import shutil
import os
import time
from pathlib import Path
from tkinter import filedialog
from tkinter import *
from tkinter import messagebox
import pandas as pd

timestr = time.strftime("%y%m%d-%H%M%S")
stopThings = True
def toggle():
    if btn.config('relief')[-1] == 'sunken':
        btn.config(text= "Copy",relief="raised",fg="White", bg='Green')
        print("COPY Mode Activate\n")
    else:
        btn.config(text="Move",relief="sunken", fg="White" ,bg='Red')
        print("MOVE Mode Activate\n")

def run_search():
    if btn.config('text')[-1] == 'Move':
        global stopThings
        stopThings = messagebox.askyesno("YoYo", "Do you want to move files?")

    if stopThings == True:
        file = filedialog.askopenfilename()
        if file != "":
            path = entryTarget.get()
            Target = entryDestionation.get()
            ind = 'Filename'
            b = pd.read_excel(file, index_col=ind, dtype=str)

            for index, row in b.iterrows():
                Fn = index
                Ext = b.loc[Fn, 'Ext']
                Loc = b.loc[Fn, 'Loc']
                print(Fn)
                if str(Loc) != "nan":
                    Nloc = (str(Target) + os.sep + str(Loc))
                else:
                    Nloc = (str(Target))
                if str(Ext) != "nan":
                    recent_file = Path(path).glob('**/*' + Fn + Ext)
                    recent_file = filter(lambda x: not os.path.isdir(x), recent_file)
                    latest = max(recent_file, key=lambda x: os.stat(x).st_mtime)
                    copyLoc = Nloc + os.sep + Fn + str(Ext)
                    print("Searching File: " + Fn + " then " + btn.config('text')[-1] + ":")
                else:
                    recent_file = Path(path).glob('**\*' + Fn)
                    recent_file = filter(lambda x: os.path.isdir(x), recent_file)
                    latest = max(recent_file, key=lambda x: os.stat(x).st_mtime)
                    copyLoc = Nloc + os.sep + Fn
                    print("Searching Folder: " + Fn + " then " + btn.config('text')[-1] + ":")
                print("from: " + str(latest))
                print("to " + str(copyLoc))
                print("\n")
                try:
                    if str(Loc) != "nan":
                        os.makedirs(Nloc + os.sep + Loc)
                except FileExistsError:
                    pass
                if btn.config('text')[-1] == 'Copy':
                    if str(Ext) != "nan":
                        shutil.copy(str(latest), copyLoc)
                    else:
                        try:
                            shutil.copytree(str(latest), copyLoc)
                        except FileExistsError:
                            pass
                elif btn.config('text')[-1] == 'Move':
                    shutil.move(str(latest), copyLoc)
    else:
        print("nothing was moved\n")
        stopThings = True


if __name__ == "__main__":
    # Create window
    app = Tk()
    app.title('Seek and Destory')
    frametop = Frame(app)
    frametop.pack(side="top")
    app.minsize(900, 200)
    app.maxsize(900, 200)
    app.geometry("320x100")
    # Input
    labels = Label(frametop, text="Search Location")
    labels.pack()

    entryTa = StringVar()

    entryTarget = Entry(frametop,textvariable=entryTa, width=140)
    entryTarget.pack()
    # InputSearch Location
    labels = Label(frametop, text="Copy To Location")
    labels.pack()

    entryDest = StringVar()

    entryDestionation = Entry(frametop,textvariable=entryDest , width=140)
    entryDestionation.pack()

    # Run Button
    button_run = Button(frametop, text="Run App/ Load File", command=run_search)
    button_run.pack()
    btn = Button(frametop,text="Copy", width=12, relief="raised", command=toggle,fg="White",bg='Green')
    btn.pack(pady=5)
    #button

    # loop
    app.mainloop()
