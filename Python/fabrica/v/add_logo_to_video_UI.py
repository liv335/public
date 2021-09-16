# add logo to a .mp4, logo is .png with alpha
# requires ffmpeg.exe
# created by Trifan Liviu , https://www.linkedin.com/in/liviu-t-94975536/

import subprocess
import os
from tkinter import *
from tkinter import filedialog,messagebox
from subprocess import Popen, CREATE_NEW_CONSOLE
from PIL import Image as Img

def load_video():
    path = filedialog.askopenfilename()
    if path != "" and check_file_suffx(path, suffix = ".mp4"):
        var_video_location.set(path)
def load_logo():
    path = filedialog.askopenfilename()
    if path != "" and check_file_suffx(path, suffix = ".png"):
        var_logo_location.set(path)
def load_save_entry():
    path = filedialog.askdirectory()
    if path != "":
        var_saveloc.set(path)
def load_ffmpeg():
    path = filedialog.askopenfilename()
    if path != "":
        var_ffmpeg.set(path)
        if os.path.exists(var_ffmpeg.get()) and check_file_suffx(var_ffmpeg.get(), suffix = "ffmpeg"):
            button_load_ffmpeg.destroy()

def clear(frame_load):
    the_list = frame_load.grid_slaves()
    for l in the_list:
        print(l)
        if button_load_ffmpeg.config("text")[(-1)] == "Load ff":
            l.destory()
def make_temp(loc, name):
    temp_file_name = "temp"
    if not os.path.exists(loc + os.sep + temp_file_name):
        os.makedirs(loc + os.sep + temp_file_name)
    name_blank = (loc + os.sep + temp_file_name + os.sep + name)
    return name_blank

def check_aspect(w, h, b_size = 700):
    # define height, width, and base size
    # find aspect ration and resize image to have the largest of the two, to the b_size(base size)
    # return integers
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
def resize_image(image, image_size = 100):
    # resize image
    # image needs to be PIL Image
    # resize image
    if image is not None:
        a_r = check_aspect(image.width, image.height, b_size = image_size)

        h_image = a_r[0]
        w_image = a_r[1]

        re_size = image.resize((int(h_image), int(w_image)), Img.ANTIALIAS)
        return re_size
    else:
        messagebox.showwarning("Error", "Missing Base Render File")
def check_file_suffx(filepath, suffix = ".png"):
    if suffix in filepath:
        return True
    else:
        messagebox.showinfo("Error", f"File needs to be {suffix}")
        return False
def check_locations(file):
    if os.path.exists(file):
        return True
    else:
        messagebox.showinfo("Error", f"{file} Not Found")
        return False

def run_command_cmd(value):
    terminal = 'cmd'
    #command = 'Python'
    command = terminal + ' ' + '/c' + ' ' + value
    #command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    subprocess.Popen(command, creationflags=CREATE_NEW_CONSOLE)
def run_app():
    _continue = True
    # check save location
    the_save_loc = var_saveloc.get()

    ffmpeg_loc = var_ffmpeg.get()
    logo_loc = var_logo_location.get()
    the_video = var_video_location.get()

    for vals in [ffmpeg_loc, the_save_loc, logo_loc, the_video]:
        if not check_locations(vals):
            _continue = False

    if _continue:
        # load logo
        resize_temp_filename = "resized_logo.png"
        reized_temp_suffix = ".png"
            # logo resize
        added_logo_resized = resize_image(Img.open(logo_loc), image_size= var_logo_size.get())
        logo_resized_loc = make_temp(the_save_loc, resize_temp_filename + reized_temp_suffix)
        added_logo_resized.save(logo_resized_loc)

        # define save output file
        output_filename = "output_logo"
        output_filesuffix = ".mp4"
        output_full_path = the_save_loc + os.sep + output_filename + output_filesuffix

        # filter options
        radio_button_option = var_radio.get()
        complex_filter = "overlay"
        if radio_button_option == "bottom right":
            complex_filter = "\"overlay=x=main_w-overlay_w-(main_w*0.01):y=main_h-overlay_h-(main_h*0.01)\""
        elif radio_button_option == "bottom left":
            complex_filter = "\"overlay=x=main_w*0.01:y=main_h-overlay_h-(main_h*0.01)\""
        elif radio_button_option == "top right":
            complex_filter = "\"overlay=x=main_w-overlay_w-(main_w*0.01):y=main_h*0.01\""
        elif radio_button_option == "top left":
            complex_filter = "\"overlay=x=main_w*0.01:y=main_h*0.01\""
            pass
        # command
        the_command = f"{ffmpeg_loc} -y -i {the_video} -i {logo_resized_loc} -filter_complex {complex_filter} {output_full_path}"

        run_command_cmd(the_command)

if __name__ == "__main__":
    #Create window
    app = Tk()
    entry_size_width = 55
    entry_size_height = 12
    # variables
    var_logo_size = IntVar()
    var_logo_size.set(100)

    var_radio = StringVar()
    var_radio.set("bottom right")

    # testing variables
    testing_location = r"C:\_work\_script\ffmpeg\bin\ffmpeg.exe"
    ffmpeg_location = testing_location

    # ffmpeg location
    local_ffmpeg_location = os.getcwd() + os.sep + "app" + os.sep + "ffmpeg.exe"
    if os.path.exists(local_ffmpeg_location):
        ffmpeg_location = local_ffmpeg_location

    var_ffmpeg = StringVar()
    var_ffmpeg.set(ffmpeg_location)

    # save location
    var_saveloc = StringVar()
    var_saveloc.set("Folder Location")
    frame_save_location = Frame(app)
    frame_save_location.pack(side = "top")
    entry_save_location = Entry(frame_save_location, width= entry_size_width, textvariable = var_saveloc)
    entry_save_location.pack(side = "left")
    button_save_location = Button(frame_save_location, text="Save Location", command = load_save_entry,
                                  width = entry_size_height, height = 1, bg='yellow')
    button_save_location.pack(side = "left")

    label_info = Label(app, text="Add Logo To Video")
    label_info.pack(side="top")

    # logo
    var_logo_location = StringVar()
    var_logo_location.set("Logo")
    frame_logo = Frame(app)
    frame_logo.pack(side="top")
    entry_logo = Entry(frame_logo, width = entry_size_width, textvariable = var_logo_location)
    entry_logo.pack(side="left")
    button_load_logo = Button(frame_logo, text="Load Image Png", command = load_logo,
                              width = entry_size_height, height=1, bg="#C7BECF")
    button_load_logo.pack(side="left")

    # video
    var_video_location = StringVar()
    var_video_location.set("Video")
    frame_video = Frame(app)
    frame_video.pack(side="top")
    entry_video = Entry(frame_video, width = entry_size_width, textvariable = var_video_location)
    entry_video.pack(side="left")
    button_load_video = Button(frame_video, text="Load Video Mp4",width=12, height=1, bg="#B48C06", state="normal", command = load_video)
    button_load_video.pack(side="left")

    frame_option = Frame(app)
    frame_option.pack(side="top")
    label_option = Label(frame_option, text = "Logo size pixels: ")
    label_option.pack(side="left")
    entry_size_option = Entry(frame_option, width = int(entry_size_width/10), textvariable = var_logo_size)
    entry_size_option.pack(side="left")

    # run
    button_run = Button(app, text="Make Video", command = run_app, width = 15, height = 2, bg = "#93A689")
    button_run.pack(pady = 1,padx =35 ,side="right")

    # radio button
    radio_button_selection = [("bottom right", "bottom right"), ("bottom left", "bottom left"), ("top left", "top left"), ("top right", "top right")]

    for text, mode in radio_button_selection:
        btnradio2 = Radiobutton(frame_option, text = text, variable = var_radio, value=mode)
        btnradio2.pack(side="left",padx=2)

    if not os.path.exists(var_ffmpeg.get()):
        button_load_ffmpeg = Button(app, text="Load ff", command=load_ffmpeg,
                                    width=15, height=2, fg="black", bg="red", state="normal")
        button_load_ffmpeg.pack(pady=1, padx=35, side="top")
    # app
    title_name = "Add Logo to Mp4 "
    title_version = "v 1.0"
    app_size_min = 500
    app_size_max = 170

    app.title(title_name)
    app.minsize(app_size_min, app_size_max)
    app.maxsize(app_size_min, app_size_max)

    app.mainloop()
