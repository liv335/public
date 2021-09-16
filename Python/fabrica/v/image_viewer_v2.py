# viewer for 360 spin images
# runs .f packs
# created by Trifan Liviu , https://www.linkedin.com/in/liviu-t-94975536/

import os
import time
import zipfile
from tkinter import *
from tkinter import filedialog, messagebox
from PIL import Image as Img, ImageTk
from pathlib import Path

# function:: get files from location ~~ presuming we have set of .png at location for 360 in order.
def get_images(location, pattern = "*.png"):
    the_files = []
    for files in Path(location).glob(pattern):
        the_files.append(files)
    return the_files

# change file
def check_file_suffx(filepath, suffix = ".png"):
    if suffix in filepath:
        return True
    else:
        messagebox.showinfo("Error", f"File needs to be {suffix}")
        return False
def change_pack():
    path = filedialog.askopenfilename()
    if path != "" and check_file_suffx(path, suffix = ".f"):
        var_test_location.set(path)
        image_adjust(var_test_location.get(), num=0)

# function:: image resize, loading, canvas,
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
def resize_image(image, resize_value = 700):
    # resize image
    if image is not None:
        a_r = check_aspect(image.width, image.height, b_size = resize_value)

        h_image = a_r[0]
        w_image = a_r[1]

        re_size = image.resize((int(h_image), int(w_image)), Img.ANTIALIAS)
        return re_size
    else:
        pass
        messagebox.showwarning("Error", "Missing Base Render File")
def load_canvas(the_image = None, size = (700,700), color = (64,64,64)):
    # load image into canvas
    if the_image is None:
        the_image = (Img.new("RGBA", size, color))
    else:
        the_image = the_image

    try:
        canvas.img = ImageTk.PhotoImage(image = the_image)
        canvas.create_image(0, 0, anchor = NW, image=canvas.img)
        canvas.config(width = the_image.width, height = the_image.height)
    except AttributeError:
        pass
def image_adjust(location, num = 0):
    if os.path.exists(location):
        the_file = get_files_from_fzip(zip_data_path = location)[num]
        the_image = Img.open(open_zip(zip_data_path=location, file=the_file))
        #the_image = Img.open(get_images(location)[num])
        #load_canvas(resize_image(the_image, resize_value = var_size_image.get()), size = (var_size_image.get(),var_size_image.get()))
        if int(the_image.height * the_image.width) > 600000:
            load_canvas(resize_image(the_image))
            #messagebox.showinfo("Resized","Inputs too large, preview is resized, will not run smooth")
        else:
            load_canvas(the_image)
    else:
        pass

# function:: button go left, go right, play
def load_to_left():
    counter = var_counter.get()
    if counter == var_max_frames.get():
        var_counter.set(var_start_frames.get())
    else:
        var_counter.set(counter + 1)
    image_adjust(var_test_location.get(), num = var_counter.get())
def load_to_right():
    counter = var_counter.get()
    if counter == var_start_frames.get():
        var_counter.set(var_max_frames.get())
    else:
        var_counter.set(counter - 1)
    image_adjust(var_test_location.get(),num = var_counter.get())
def load_to_play_left():
    var_clicked.set(True)
    for i in range(0,var_max_frames.get(),1):
        time.sleep(var_speed_anim.get())
        app.update()
        if not var_clicked.get():
            break
        else:
            var_counter.set(i)
            image_adjust(var_test_location.get(), num = i)
def load_to_play_right():
    var_clicked.set(True)
    for i in range(var_max_frames.get(),0,-1):
        time.sleep(var_speed_anim.get())
        app.update()
        if not var_clicked.get():
            break
        else:
            var_counter.set(i)
            image_adjust(var_test_location.get(), num = i)

# function:: button, click events
def key(event):
    clicked = repr(event.char)
    #print ("pressed", clicked)
def removecall(event):
    canvas.unbind('<Motion>')
    canvas.unbind("<Button-1>")
    canvas.bind("<Button-1>", callback)

    button_play_info.config(text="Static", bg="Orange")
    var_clicked.set(False)
    var_pos_x.set(event.x)
def callback(event):
    canvas.unbind("<Button-1>")
    canvas.bind('<Motion>', motion)
    canvas.bind("<Button-1>",removecall)

    button_play_info.config(text = "Auto", bg = "#c0fa3b")
    var_pos_x.set(event.x)
    var_clicked.set(False)
def motion(event):
    subdivide = 4
    adjust = divmod((var_counter.get() + int(var_pos_x.get()/subdivide) + int(event.x/subdivide)),var_max_frames.get())[1]
    image_adjust(var_test_location.get(),num = adjust)
def returnpos(event):
    removecall(event)
    image_adjust(var_test_location.get(),num = 0)
    var_clicked.set(False)
    var_pos_x.set(0)

# zippy
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
    # open zip data
    if os.path.exists(zip_data_path) and zip_data_path is not None and file is not None and file != "None":
        with zipfile.ZipFile(zip_data_path, "r") as zip_data:
            return zip_data.open(file)

# app
if __name__ == "__main__":
    #Create window
    app = Tk()
    # setup variables
    size_entry_width = 10
    size_entry_height = 2

    #path = r"C:\_work\sexi_lib\neu_p\t6\render_resized"
    #path = r"C:\Users\335\Desktop\testing\360\images"
    path = r"C:\_work\sexi_lib\neu_p\t6\fp001.f"
    file_load = "fp000.f"

    # app variables
    var_test_location = StringVar()
    if os.path.exists(os.getcwd() + file_load):
        var_test_location.set(os.getcwd() + os.sep + file_load)
    else:
        var_test_location.set(path)

    var_clicked = BooleanVar()
    var_clicked.set(False)

    var_pos_x = IntVar()
    var_pos_x.set(0)

    var_speed_anim = DoubleVar()
    var_speed_anim.set(0.01)

    var_start_frames = IntVar()
    var_start_frames.set(0)

    var_counter = IntVar()
    var_counter.set(0)

    var_max_frames = IntVar()
    var_max_frames.set(71)

    var_size_image = IntVar()
    var_size_image.set(800)

    # frames
    frame_canvas = Frame(app, width = var_size_image.get(), height = var_size_image.get())
    frame_canvas.pack(side="top")

    frame_buttons = Frame(app)
    frame_buttons.pack(side="bottom")

    # canvas
    canvas = Canvas(frame_canvas, width = var_size_image.get(), height = var_size_image.get())
    canvas.bind("<Key>", key)
    canvas.bind("<Button-1>", callback)
    canvas.bind("<Button-3>", returnpos)
    canvas.pack()
    load_canvas()
    image_adjust(var_test_location.get(), num=0)

    canvas.pack(side = "top")

    # buttons
    button_change = Button(frame_buttons, text = "Change Item",
                        command = change_pack, width = size_entry_width, height = size_entry_height, bg = 'grey')
    button_change.pack(side="left")

    button_right = Button(frame_buttons, text = "<-",
                        command = load_to_right, width = size_entry_width, height = size_entry_height, bg = 'grey')
    button_right.pack(side="left")

    button_left = Button(frame_buttons, text = "->",
                        command = load_to_left, width = size_entry_width, height = size_entry_height, bg = 'grey')
    button_left.pack(side="left")

    #button_play_right = Button(frame_buttons, text = "<<",
    #                    command = load_to_play_right, width = size_entry_width, height = size_entry_height, bg = 'green')
    #button_play_right.pack(side="left")

    button_play_left = Button(frame_buttons, text = ">>",
                        command = load_to_play_left, width = size_entry_width, height = size_entry_height, bg = 'green')
    button_play_left.pack(side="left")

    button_play_info = Button(frame_buttons, text = "Static",
                         width = size_entry_width, height = size_entry_height, bg = 'orange',fg = "black" ,state = "disable")
    button_play_info.pack(side="left")

    # app load
    app.title("Image Spin Viewer")

    app_width = 800
    app_height = 750
    app.minsize(app_width, app_height)
    app.maxsize(app_width, app_height)

    app.mainloop()