# takes up to 8 inputs, inputs can be Images or Text
# text input can be adjusted, font, color, size, is centered ~~ may require adjustment
# requires ffmpeg.exe
# created by Trifan Liviu , https://www.linkedin.com/in/liviu-t-94975536/

from tkinter import *
from tkinter import filedialog, messagebox, colorchooser, simpledialog
from PIL import Image as Img ,ImageFont, ImageDraw
import subprocess
from subprocess import Popen, CREATE_NEW_CONSOLE
import shutil
import os

def load(i):
    path = filedialog.askopenfilename()
    if path != "" and check_file_suffx(path , suffix = ".png"):
        input_array[i].set(path)
        checkbox_array[i].deselect()
        bool_array[i] = False
def load_save_entry():
    path = filedialog.askdirectory()
    if path != "":
        var_saveloc.set(path)
def check_file(loc):
    while os.path.exists(loc):
        try:
            num = int(loc.split(".")[0][-1])
            num += 1
            loc = loc.split(".")[0][:-1] + str(num) + "." + loc.split(".")[1]
        except ValueError:
            break
    return loc
def check_file_suffx(filepath, suffix = ".png"):
    if suffix in filepath:
        return True
    else:
        messagebox.showinfo("Error", f"File needs to be {suffix}")
        return False
def change_bool_of_var(i):
    bool_array[i] = not bool_array[i]

def text_wrap(text,font,writing,max_width,max_height):
    lines = [[]]
    words = text.split()
    for word in words:
        # try putting this word in last line then measure
        lines[-1].append(word)
        (w,h) = writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]), font=font)
        if w > max_width: # too wide
            # take it back out, put it on the next line, then measure again
            lines.append([lines[-1].pop()])
            (w,h) = writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]), font=font)
            if h > max_height: # too high now, cannot fit this word in, so take out - add ellipses
                lines.pop()
                # try adding ellipses to last word fitting (i.e. without a space)
                #lines[-1][-1] += '...'
                # keep checking that this doesn't make the textbox too wide,
                # if so, cycle through previous words until the ellipses can fit
                while writing.multiline_textsize('\n'.join([' '.join(line) for line in lines]),font=font)[0] > max_width:
                    lines[-1].pop()
                    #lines[-1][-1] += '...'
                break
    return '\n'.join([' '.join(line) for line in lines])
def add_text(imag, color, pos, text_size, text_write, boxsize):
    the_font = var_font.get()
    imag = Img.open(imag)
    draw = ImageDraw.Draw(imag)
    font = ImageFont.truetype(the_font, text_size)

    text_write = text_wrap(text_write, font, draw, boxsize[0], boxsize[1])

    draw.text(pos, text_write, color, font = font)
    imag.save(imag.filename)
    return draw

def check_image_input(imag, imag2): # to do general check // maybe normalize images
    the_check = False
    the_size = (0,0)
    try:
        imag = Img.open(imag)
        imag2 = Img.open(imag2)
        the_check = (imag.size[1] == imag2.size[1] and imag.size[0] == imag2.size[0])
        the_size = imag.size
    except FileNotFoundError:
        pass
    return the_check, the_size
def create_temp_folder(loc, temp_folder):
    the_temp_folder = loc + os.sep + temp_folder
    if not os.path.exists(the_temp_folder):
        os.makedirs(the_temp_folder)
def create_blank_image(loc, size, name, color):
    # define and create temp folder
    the_temp_folder = "temp"
    create_temp_folder(loc, the_temp_folder)
    # define and create blank image, return file name
    blank_image_file = (loc + os.sep + the_temp_folder + os.sep + name)
    blank_image_background = Img.new("RGB", size, color)
    blank_image_background.save(blank_image_file)

    return blank_image_file

def remove_temp_files():
    loc = var_saveloc.get() + os.sep + "temp"
    if os.path.exists(loc):
        if messagebox.askokcancel("Delete Temp?","Do you want to delete temp folder from save location, action cannot be undone"):
            shutil.rmtree(loc)
            messagebox.showinfo("Info", "Temp file deleted")
    else:
        messagebox.showinfo("Info", "Temp Folder doesn't exists")
def run_command_cmd(value):
    terminal = 'cmd'
    #command = 'Python'
    #command = terminal + ' ' + '/c' + ' ' + value
    command = terminal + ' ' + '/K' + ' ' + value
    # /K keeps the command prompt open when execution takes place
    # CREATE_NEW_CONSOLE opens a new console
    subprocess.Popen(command, creationflags = CREATE_NEW_CONSOLE)

def choose_color_text():
    # variable to store hexadecimal code of color
    color_code = colorchooser.askcolor(title = "Choose color")
    if color_code[0] is not None:
        button_color.config(bg = color_code[1])
        var_textcolor.set(color_code[0])
def choose_font_text():
    # variable to store hexadecimal code of color
    path = filedialog.askopenfilename()
    font_suffix = path[-4:]
    if (font_suffix == ".otf" or font_suffix == ".ttf") and font_suffix != "":
        var_font.set(path)
        messagebox.showinfo("New font selected",f"New Font Found At : {path}")
    else:
        if font_suffix != ".ttf" and font_suffix != "":
            check_file_suffx(path, suffix= ".ttf")
        elif font_suffix != ".otf" and font_suffix != "":
            check_file_suffx(path, suffix=".otf")
def create_blank_add_text(local_path, image_size, temp_name_prefix, color, text, text_color, text_pos, text_size, b):
    # to prevent text repeating
    temp_name = f"{b}.png"
    input_create_blank = create_blank_image(local_path, image_size, temp_name_prefix + temp_name, color)
    add_text(input_create_blank, text_color, text_pos, text_size, text, image_size)
    return input_create_blank

def test_something():
    pass

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

def normalize_size_image(image_list):
    # takes images location
    max_pixel_size_dict = {}
    max_pixel_size_array = []
    for i in range(len(image_list)):
        # load image
        load_image = Img.open(image_list[i])
        # define array, dict
        pixels_in_image = load_image.height * load_image.width
        max_pixel_size_array.append(pixels_in_image)
        max_pixel_size_dict[pixels_in_image] = (load_image.width, load_image.height)
    # return max height, width
    return max_pixel_size_dict[sorted(max_pixel_size_array, reverse = True)[0]]
def resize_image_add_temp(local_path, temp_name_prefix ,image_path, b, image_size = (1920, 1080)):
    temp_name = f"{b}.png"
    the_temp_folder = "temp"

    create_temp_folder(local_path, the_temp_folder)
    name_image_temp = local_path + os.sep + the_temp_folder + os.sep + temp_name_prefix + temp_name

    resized_image = Img.open(image_path)
    resized_image = resize_image(resized_image, sorted(image_size, reverse = True)[0])
    resized_image.save(name_image_temp)
    return name_image_temp

def resolution_setup(size = (1920, 1080)):
    # adjust resolution var
    var_height.set(size[1])
    var_width.set(size[0])
def create_interface(local_max):
    # array inputs
    for i in range(local_max):
        # labels
        label_text = input_label_values[i:i+1] # slice to prevent error
        entry_text = input_text_array[i:i+1] # slice to prevent error

        if len(label_text) == 0:
            label_text = "Extra Input"
        else:
            label_text = input_label_values[i]
        if len(entry_text) == 0:
            entry_text = "Another Input"
        else:
            entry_text = input_text_array[i]

        the_label = Label(frm_top, text = label_text)
        label_array[i] = the_label
        label_array[i].pack()

        # string variable
        var_input = StringVar()
        input_array[i] = var_input
        input_array[i].set(entry_text)

        # bool variable
        var_bool = BooleanVar()
        bool_array[i] = var_bool
        bool_array[i].set(True)

        # entry box
        the_frame = Frame(frm_top)
        frame_array[i] = the_frame
        frame_array[i].pack(side = "top")

        the_entry = Entry(frame_array[i], width = 50, textvariable = input_array[i], state = "normal")
        entry_array[i] = the_entry
        entry_array[i].pack(side = "left")

        the_button = Button(frame_array[i], text="Load Input",
                            width = 10, height = 1, bg = "grey", state = "normal")
        button_array[i] = the_button
        button_array[i].pack(side = "left")
        exec(f"button_array[{i}].config(command = lambda:load({i}))")

        the_checkbox = Checkbutton(frame_array[i], text="text",
                                   variable = bool_array[i], onvalue = 1, offvalue = 0)
        checkbox_array[i] = the_checkbox
        exec(f"checkbox_array[{i}].config(command = lambda:change_bool_of_var({i}))")
        checkbox_array[i].pack(side = "left")

def add_delete_button():
    button_delete_option.destroy()
    button_delete_temp = Button(frm_run, text="Clear Temp Files", command=remove_temp_files, width=15, height=1, bg="orange")
    button_delete_temp.pack(side="right", padx = 1)
def change_inputs():
    # ask for inputs
    new_max = simpledialog.askinteger("Enter new Input","New Max Inputs, max = 8")
    if new_max is not None:
        if new_max > 8:
            messagebox.showinfo("Error", "Max 8 inputs otherwise will flip fast between frames")
            new_max = 8
        elif new_max < 1:
            messagebox.showinfo("Error", "Min input 1")
            new_max = 1
        var_maxinputs.set(new_max)

    # destory tkiner objects
    for p in range(len(entry_array)):
        label_array[p].destroy()
        #input_array[p].destroy()
        #bool_array[p].destroy()
        frame_array[p].destroy()
        entry_array[p].destroy()
        button_array[p].destroy()
        checkbox_array[p].destroy()
    # remake interface
    create_interface(var_maxinputs.get())

    local_size_min = 500
    local_size_max = 180 + 45 * var_maxinputs.get()

    app.title('Fast Video Creator')
    app.minsize(local_size_min, local_size_max)
    app.maxsize(local_size_min, local_size_max)
    pass
def run_app():
    # main variables
    local_path = var_saveloc.get()
    local_ffmpeg_loc = var_ffmpeg.get()

    # color variables
    temp_filename = "blank"
    temp_image_filename = "image"
    white = (255, 255, 255)
    black = (0, 0, 0)

    # options
    max_inputs = var_maxinputs.get()
    duration = int(var_duration.get() / max_inputs)

    # check inputs, determin text size position
    image_collection = []
    for b in range(len(input_array)):
        if os.path.exists(input_array[b].get()) and not bool_array[b]:
            image_collection.append(input_array[b].get())
    # check how many image files are found
    if len(image_collection) != 0:
        max_size = normalize_size_image(image_collection)
    else:
        max_size = (var_width.get(), var_height.get())

    the_input_checked = (True, max_size)
    text_size = int(the_input_checked[1][1] * (var_textsize.get() / 100))
    text_pos_y = (the_input_checked[1][1] / 2) - text_size / 2

    print(max_size)
    if os.path.exists(local_path) and os.path.exists(local_ffmpeg_loc):
        save_path = check_file(local_path + "/" + "out1.mp4")
        # colors
        try:
            the_text_color = ([int(float(i)) for i in var_textcolor.get().replace("(","").replace(")","").split(",")])
            the_text_color = (the_text_color[0],the_text_color[1],the_text_color[2])
        except ValueError:
            the_text_color = black

        ######## the input needs to be improved validate inputs get resolution.

        print((the_input_checked[1][0] % 2), (the_input_checked[1][1] % 2))
        if the_input_checked[0] and (the_input_checked[1][0] % 2) == 0 and (the_input_checked[1][1] % 2) == 0:
            # create/define inputs text or image
            inputs = {}
            # too lazy to optimize now
            for b in range(len(bool_array)):
                if bool_array[b]:
                    text = input_array[b].get()
                    inputs[b] = create_blank_add_text(local_path, the_input_checked[1], temp_filename, white, text,
                                                      the_text_color, (50, text_pos_y), text_size, b)
                else:
                    if os.path.exists(input_array[b].get()):
                        the_input = resize_image_add_temp(local_path, temp_image_filename, input_array[b].get(), b, max_size)
                        inputs[b] = the_input
                    else:
                        text = "Failed::" + input_array[b].get()
                        inputs[b] = create_blank_add_text(local_path, the_input_checked[1], temp_filename, white,
                                                          text, the_text_color, (50, text_pos_y), text_size, b)
            # define the inputs string
            the_inputs = []
            the_complex_filter_loop = []
            the_complex_filter_options = []
            the_delays = var_delays.get().split(",")
            # define inputs loop
            for i in range(max_inputs):
                inputs_values = f"-loop 1 -t {duration} -i {inputs[i]} "
                the_inputs.append(inputs_values)

            # define complex filter loop phase 1
            for i in range(max_inputs):
                the_delay_check = the_delays[i:i+1]
                if len(the_delay_check) == 0:
                    the_delay_check = "+5"
                else:
                    the_delay_check = the_delays[i]
                filter_inputs = f"[{i}:v]format=yuva444p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS{the_delay_check}/TB[f{i}]; "
                the_complex_filter_loop.append(filter_inputs)

            # define complex filter loop phase 2
            for i in range(max_inputs):
                if i == 0:
                    f_i = f"[{i}]"
                else:
                    f_i = f"[bg{i}]"

                if i == max_inputs-1:
                    e_i = ","
                else:
                    e_i = f"[bg{i+1}];"
                overlay_option = f"{f_i}[f{i}]overlay{e_i}"
                the_complex_filter_options.append(overlay_option)
            format_input = "format = yuv420p[v]"
            the_complex_filter_options.append(format_input)
            the_complex_filter = the_complex_filter_loop + the_complex_filter_options

            # options
            the_options = [" -map \"[v]\"  "]
            the_command = f"{local_ffmpeg_loc} "

            # collect and concat strings
            for i in the_inputs:
                the_command += i
            the_command += "-filter_complex \""
            for f in the_complex_filter:
                the_command += f
            the_command = the_command + "\""
            for o in the_options:
                the_command += o
            the_command += f"{save_path}"

            # define command, run command via cmd
            print(the_command)
            run_command_cmd(the_command)
        else:
            messagebox.showinfo("Error","Something went wrong\n>>Check inputs\n>>Check resolution (resolution divisible by 2)")
        pass
    else:
        messagebox.showinfo("Error", "Check Save Path or ff location")

if __name__ == "__main__":
    #Create window
    app = Tk()
    # variables
    # ffmpeg -- to investigate python module
    var_ffmpeg = StringVar()
    var_ffmpeg.set(r"C:\_work\_script\ffmpeg\bin\ffmpeg.exe")
    if not os.path.exists(var_ffmpeg.get()):
        var_ffmpeg.set(os.getcwd() + os.sep + "app" + os.sep + "ffmpeg.exe")

    # font
    var_font = StringVar()
    var_font.set(r"C:\Klearn\video\AdobeArabic-Bold.otf")
    if not os.path.exists(var_font.get()):
        var_font.set(os.getcwd() + "/" + "app" + "/" + "AdobeArabic-Bold.otf")

    # global variables
    var_duration = IntVar()
    var_duration.set(8)
    var_textsize = IntVar()
    var_textsize.set(20)
    var_textcolor = StringVar()
    var_textcolor.set("(0.0,0.0,0.0)")
    var_maxinputs = IntVar()
    var_maxinputs.set(4)

    # resolution
    default_h = 1080
    default_w = 1920

    var_height = IntVar()
    var_height.set(default_h)
    var_width = IntVar()
    var_width.set(default_w)

    var_saveloc = StringVar()
    var_saveloc.set("Select Folder Path")

    # main frame
    frm_top = Frame(app)
    frm_top.pack(side="top")

    # save bar location and button
    frm_info_top = Frame(frm_top)
    frm_info_top.pack(side = "top")
    lb_o = Label(frm_info_top, text = "Options")
    lb_o.pack(side = "top")

    frm_s = Frame(frm_top)
    frm_s.pack(side = "top")
    entry_s = Entry(frm_s, width= 50, textvariable = var_saveloc)
    entry_s.pack(side = "left")
    btn_s = Button(frm_s, text="Save Location", command = load_save_entry,
                   width = 10, height = 1, bg='yellow')
    btn_s.pack(side = "left")

    # options
    frm_o = Frame(frm_top)
    frm_o.pack(side="top")

        # duration
    lb_o = Label(frm_o, text="Duration")
    lb_o.pack(side="left")
    entry_d = Entry(frm_o, width= 7, textvariable = var_duration, state = "disabled")
    entry_d.pack(side="left")
        # text size procent
    lb_d = Label(frm_o, text="Text Size %")
    lb_d.pack(side="left")
    entry_ts = Entry(frm_o, width= 7, textvariable = var_textsize, state = "normal")
    entry_ts.pack(side="left")
        # change color, font
    button_color = Button(frm_o, text="Text Color", command = choose_color_text,
                          width = 10, height = 1, bg = "black", fg = "grey")
    button_color.pack(side="left")
    button_font = Button(frm_o, text="Text Font", command = choose_font_text,
                         width = 10, height = 1, bg = "black", fg = "grey")
    button_font.pack(side="left")

    # options menu
    frm_extrao = Frame(frm_top)
    frm_extrao.pack(side="top")

    delays = "-3, +1, +2, +4"
    var_delays = StringVar()
    var_delays.set(delays)

    lb_maxinpunts = Label(frm_extrao, text="Inputs")
    lb_maxinpunts.pack(side="left")

    button_change_inputs = Button(frm_extrao, text="Max Inputs", command = change_inputs,
                         width=10, height=1, bg="black", fg="grey")
    button_change_inputs.pack(side="left")

    entry_maxinput = Entry(frm_extrao, width= 5, textvariable = var_maxinputs, state = "disabled")
    entry_maxinput.pack(side="left")

    lb_extrao = Label(frm_extrao, text="distribution")
    lb_extrao.pack(side="left")
    entry_distribution = Entry(frm_extrao, width= 20, textvariable = var_delays, state = "normal")
    entry_distribution.pack(side="left")

    # run
    frm_run = Frame(frm_top)
    frm_run.pack(side="top")
    button_run = Button(frm_run, text="Make Video", command = run_app,
                        width = 15, height = 2, bg = "green")
    button_run.pack(side="left",padx = 100)

    button_delete_option = Button(frm_run, text="", command=add_delete_button, width=1, height=1, bg="white")
    button_delete_option.pack(side = "left")

    # create dynamic interface
    #input_text_array = ["Input %s" % s for s in range(var_maxinputs.get())]
    #input_label_values = ["Entry %s'" % s for s in range(var_maxinputs.get())]

    input_text_array = ["Start Video", "Load Input", "Load Input", "End Video"] # base
    input_label_values = ["Input 1", "Input 2", "Input 3", "Input 4"] # base

    maxinputs = len(input_text_array)
    var_maxinputs.set(maxinputs)

    # array list
    label_array = {}
    input_array = {}
    bool_array = {}
    frame_array = {}
    entry_array = {}
    button_array = {}
    checkbox_array = {}
    # create function
    create_interface(var_maxinputs.get())

    title_name = "Profile Combine "
    title_version = "v 1.0"
    app_size_min = 500
    app_size_max = 360

    app.title('Fast Video Creator')
    app.minsize(app_size_min, app_size_max)
    app.maxsize(app_size_min, app_size_max)
    app.geometry("320x100")

    app.mainloop()
