# requires ffmpeg.exe
# combines different images to produce a new one, to produce permutations.
# created by Trifan Liviu , https://www.linkedin.com/in/liviu-t-94975536/

import tkinter as tk
from tkinter import *
from tkinter import filedialog, messagebox, simpledialog
from PIL import Image as Img, ImageTk
from pathlib import Path
import zipfile
import os

# functions
# load/open save
def update_tool(i):
    # clear lists, check .f files from inputs, load items in lists
    clearlist(list_box_array[i])
    arch_fab = var_local.get() + os.sep + special_content_folder + os.sep + special_filename + str(i) + special_filesuffix
    loadlist(get_files_from_fzip(zip_data_path = arch_fab), list_box_array[i])

def open_folder():
    # check folder if exists, open folder windows explorer
    if os.path.exists(var_local.get()):
        os.startfile(var_local.get())
def loadsave():
    load_location = filedialog.askdirectory()
    if load_location != "":
        var_local.set(load_location)

        var_number_inputs.set(getinputs(var_local.get() + os.sep + special_content_folder))

        # destory list/entry inputs then generate
        destoryinput()
        generatelists(var_number_inputs.get())

        for i in range(var_number_inputs.get()):
            update_tool(i)

# canvas
def check_aspect(w, h, b_size = 700):
    if h > w:
        ar = w/h
        w = b_size
        h = b_size * ar
    elif h < w:
        ar = h/w
        w = b_size * ar
        h = b_size
    else:
        h = b_size
        w = b_size
    return int(h) ,int(w)
def app_resize(h = 800, w = 800):
    app.minsize(h, w)
    app.maxsize(h, w)

def load_canvas(the_image = None):
    # load image into canvas
    if the_image is None:
        the_image = (Img.new("RGBA", (800,800),(64,64,64)))
    else:
        the_image = the_image

    canvas.img = ImageTk.PhotoImage(image = the_image)
    canvas.create_image(0, 0, anchor = NW, image=canvas.img)
    canvas.config(width = the_image.width, height = the_image.height)
def resize_image(image):
    # resize image
    if image is not None:
        a_r = check_aspect(image.width, image.height)

        h_image = a_r[0]
        w_image = a_r[1]

        re_size = image.resize((int(h_image), int(w_image)), Img.ANTIALIAS)
        return re_size
    else:
        messagebox.showwarning("Error", "Missing Base Render File")

# zip functions
def get_files_from_fzip(zip_data_path = None):
    # get files from fzip
    array_file_items = []
    if os.path.exists(zip_data_path):
        with zipfile.ZipFile(zip_data_path, "r") as zip_data:
            content_list = zip_data.namelist()
            for c in content_list:
                    array_file_items.append(c)
    return array_file_items
def open_zip(zip_data_path = None, file = None):
    if os.path.exists(zip_data_path) and zip_data_path is not None and file is not None and file != "None":
        with zipfile.ZipFile(zip_data_path, "r") as zip_data:
            # content_list = zip_data.namelist()
            return zip_data.open(file)
def read_config(file):
    remove_char = [";","\'","\""," ","\n"]
    pattern = []
    with open(file) as f:
        lines = f.readlines()
        for line in lines:
            for i in remove_char:
                line = line.replace(i,"")
            pattern.append(line.replace(" ","").split("="))
        return (pattern[0][1].split(",")),(pattern[1][1].split(","))
def change_bool_of_var():
    var_the_order_override.set(var_the_order_override.get())
    if var_the_order_override.get():
        the_order = simpledialog.askstring("Change Order", "Enter New Order - Input won't be checked\n EX: 0,1,2,3,4 for 5 inputs can be 4,0,1,3,2")
        if the_order is not None and the_order != "" and len(the_order.split(",")) == var_number_inputs.get():
            var_new_order.set(the_order)
        else:
            the_checkbox.deselect()
            messagebox.showinfo("Error","Invalid Input")

# run combine image
def combine_local(main_file = "base_render.png"):
    #print("\n")
    content_location = var_local.get() + os.sep + special_content_folder
    baseimage = content_location + os.sep + main_file

    the_order = list(range(var_number_inputs.get()))
    if var_the_order_override.get():
        the_order = var_new_order.get()
        the_order = [int(i) for i in the_order.split(",")]

    base = None
    if os.path.exists(baseimage):
        image = Img.open(baseimage)
        base = Img.new(image.mode, image.size)
        base.paste(image)  # load base image

        for n in the_order:
            entry_value = entry_array[n].get()
            location = content_location + os.sep + special_filename + str(n) + special_filesuffix
            if os.path.exists(location) and entry_value != "None":
                thepas = Img.open(open_zip(zip_data_path = location, file = entry_value))
                base.paste(thepas, (0, 0), thepas)
            else:
                # print (location +" ::not found") # disabled
                pass
    return base

# show -- display in tool image, resized
# save -- saves at location
def show_image():
    the_resized = resize_image(combine_local())
    app_resize(w = (the_resized.height + 220))
    load_canvas(the_image = the_resized)
def save_image(output_file_name = "output" ,ext = ".png"):
    save_location = var_local.get() + os.sep + output_file_name + ext
    combine_local().save(save_location)

# write, clear entry
def write_entry(x):
    # used to load/write selection from list to entry object
    var_array[x].set(list_box_array[x].get(list_box_array[x].curselection()))
    entry_array[x].config(fg = "green")
def entry_clear(x):
    # used to clear entries from list and entry object
    try:
        list_box_array[x].selection_clear(list_box_array[x].curselection())
        var_array[x].set(string_none)
        entry_array[x].config(fg = "black")
    except (TypeError, tk.TclError):
        pass

# search and load
def searchinputs(location = os.getcwd(), pattern = "*"):
    # search inputs, -- legacy used to search inside folders
    listarray = []
    for f in Path(location).glob(pattern):
        listarray.append(f)
    return listarray
def loadlist(the_list, list_box_item):
    # loads items found inside listbox
    cnt = 1
    for files in the_list:
        list_box_item.insert(cnt, files)
        cnt += 1
def clearlist(list_box_item):
    # clears lists box
    list_box_item.delete(0, END)

# generate/destroy/getinputs
def destoryinput():
    # destory tkiner objects
    for p in range(len(list_box_array)):
        #var_array[p].destroy()
        entry_array[p].destroy()
        list_box_array[p].destroy()
def generatelists(max_i):
    # generate input interface dynamically
    for p in range(max_i):
        # string variables
        var_entry = StringVar()
        var_array[p] = var_entry
        var_array[p].set(string_none)

        # create entries
        entry_array[p] = Entry(frm_entry, width = size_entry, textvariable = var_array[p],
                               state = "readonly", fg = "black")
        entry_array[p].pack(side = "left")

        # create list box
        list_box_array[p] = Listbox(frm_listbox, width = size_entry, height = size_height_list)

        exec(f"list_box_array[{p}].bind('<Double-1>', lambda x:write_entry({p}))")
        exec(f"list_box_array[{p}].bind('<Button-3>', lambda x:entry_clear({p}))")

        list_box_array[p].pack(side="left")

        update_tool(p)
def getinputs(location):
    # gets size of inputs, counts files
    found_array = []
    set_filename = "set"
    set_suffix = ".f"
    for f in Path(location).glob("*" + set_filename + "*"):
        if f.suffix == set_suffix:
            found_array.append(f)
    return len(found_array)

# the app
if __name__ == "__main__":
    #Create window
    app = Tk()

    # pre_defined varibles
    test_location = r"C:\_work\sexi_lib\neu_p\t1"
    string_base_render = "base_render.png"
    string_none = "None"

    special_filename = "set"
    special_filesuffix = ".f"
    special_content_folder = "_content"
    special_config_filename = "config"
    string_pattern_array = []

    size_entry = 20
    size_height_list = 8
    number_inputs = 5  # 5 used for testing

    var_the_order_override = BooleanVar()
    var_the_order_override.set(False)

    var_new_order = StringVar()
    var_new_order.set("0,1,2,3,4")

    var_number_inputs = IntVar()
    var_number_inputs.set(number_inputs)

    # frames
    frm_main = Frame(app)
    frm_main.pack(side = "top")

        # on main
    frm_entry_main = Frame(frm_main)
    frm_entry_main.pack(side = "top")

    frm_entry = Frame(frm_main)
    frm_entry.pack(side = "top")

    frm_listbox = Frame(frm_main)
    frm_listbox.pack(side = "top")

    # scrollbar testing, needs more work
    """
    # create canvas
    framecanvas = Canvas(frm_entry_main, height = 2)
    framecanvas.pack(side="bottom")

    # Create Frame
    frameitemsload = Frame(framecanvas)
    # add scroll bar
    scrollbar = Scrollbar(frm_entry_main, command = framecanvas.xview, orient = HORIZONTAL)
    scrollbar.pack(side=BOTTOM, fill=X)
    # Window
    framecanvas.create_window((0, 0), window = frameitemsload)
    framecanvas.configure(xscrollcommand = scrollbar.set)
    framecanvas.configure(height = 150)
    framecanvas.configure(scrollregion=(0, 0, 0, 0))
    framecanvas.configure(width = 500)
    """

    frm_buttons = Frame(frm_main)
    frm_buttons.pack(side = "top")

    frm_viewer_canvas = Frame(frm_main)
    frm_viewer_canvas.pack(side = "left")

        # on viewer canvas
    frm_viewer_big = Frame(frm_viewer_canvas)
    frm_viewer_big.pack(side = "top")

        # on big
    frm_side = Frame(frm_viewer_big)
    frm_side.pack(side = "top")

    frm_viewer = Frame(frm_viewer_big)
    frm_viewer.pack(side = "right")

    # variables check or use local
    var_local = StringVar()
    if os.path.exists(test_location):
        var_local.set(test_location) # testing place
    else:
        var_local.set(os.getcwd())

    # entry location
    lb_location = Label(frm_entry_main, text = "Content Location")
    lb_location.pack(side = "top")
    entry_location = Entry (frm_entry_main,width= 75, textvariable = var_local, state = "readonly", fg = "green")
    entry_location.pack(side = "left")

    button_load_location = Button(
        frm_entry_main, text = "Load Input",
        command = loadsave, width = 10, height = 1, bg = "grey",state = "normal"
    )
    button_load_location.pack(side = "left")

    the_checkbox = Checkbutton(frm_entry_main, text="Override Order",
                               variable=var_the_order_override, onvalue=1, offvalue=0)
    the_checkbox.config(command = change_bool_of_var)
    the_checkbox.pack(side = "left")

    # create interface
    var_array = {}
    entry_array = {}
    list_box_array = {}

    number_inputs = getinputs(var_local.get() + os.sep + special_content_folder)
    generatelists(number_inputs)

    # run buttons
    button_run = Button(frm_buttons, text = "Combine and Show",
                        command = show_image, width = size_entry, height = 2, bg = 'Yellow')
    button_run.pack(side="left")
    button_save = Button(frm_buttons, text = "Save",
                         command = save_image, width = size_entry, height = 2, bg = 'Green')
    button_save.pack(side="left")
    button_open = Button(frm_buttons, text = "Open Folder",
                         command = open_folder, width = size_entry, height = 2, bg = 'Cyan')
    button_open.pack(side="left")

    # cavans
    canvas = Canvas(frm_viewer_big, width = 100, height = 100)

    # load canvas
    load_canvas()
    canvas.pack(side = "top")

    # app geometry
    title_name = "Profile Combine "
    title_version = "v 1.0"
    app_s_h = 800
    app_s_w = 800

    app.title(title_name + title_version)
    app.minsize(app_s_h, app_s_w)
    app.maxsize(app_s_h, app_s_w)

    app.mainloop()