# created by Livxy
# takes a curve array ("0.0,0.0, 0.25,0.25, 0.5,0.5, 0.75,0.75, 1.0,1.0")
# removes any special characters, spaces, parenthesis, commas
# creates a vcccrv for vray frame buffer to match a curve applied on a sRGB image

import binascii
import struct
import numpy as np
from scipy.interpolate import interp1d
from tkinter import *
from tkinter import filedialog,messagebox

# make byte strings lazy
def make_string_byte(value):
    return (str(binascii.hexlify(value)).replace("'", "")[1:])
# remove srgb adjustment
def remove_pseudo_srgb(value):
    if (value <= 0.0404482362771082):
        liniar_value = (value/255) / 12.92
    else:
        liniar_value = (pow(((value/255)+0.055)/1.055,2.4)) * 255
    return liniar_value
# add srgb
def add_adjustment_pseudo_srgb(value):
    if (value <= 0.00313066844250063):
        srgb_value = (value/255) * 12.92
    else:
        srgb_value = (1.055 * (pow((value / 255),(1 / 2.4))) - 0.055) * 255
    return srgb_value
# do curve
def addcurve(the_curve, size):
    curve_points = determin_curve(the_curve)
    # create point cubic point array
    interplate_one_d = interp1d(curve_points[0], curve_points[1], kind='cubic')
    list_array = np.linspace(0, 1, num=size, endpoint=True)
    # adjust list and clean up
    adjustment_list = [int((i) * (size-1)) for i in [1 if i > 1 else i for i in [0 if i < 0 else i for i in interplate_one_d(list_array)]]]
    adjusted_list = np.round((adjustment_list), decimals=0)
    return adjusted_list
# determin x,y points for curve
def determin_curve(the_curve_load):
    the_curve_load = the_curve_load.replace(" ","").split(",")
    x = []
    y = []
    i = 0
    for num in range(int(len(the_curve_load)/2)):
        x.append(float(the_curve_load[i]))
        y.append(float(the_curve_load[i+1]))
        i += 2
    return x,y
# adjust points
def adjust_point_from_curve(point_list,size):
    sexyfy_curve = ""
    # generate point array string to use to write bytes
    for i in range(int(size-1)):
        le_value = remove_pseudo_srgb(point_list[int(add_adjustment_pseudo_srgb(i))])
        if le_value > 255:
            le_value = 255
        elif le_value < 0:
            le_value = 0
        sexyfy_curve += ("," + (str(i / size)[:5]) + "," + (str((le_value)/size)[:5]))
    sexyfy_curve += (",1.0,1.0")
    return sexyfy_curve[1:]
# read a vcccrv
def write_vray_preset_curve(the_base,save_location,the_curve_load,write_mode):
    # zero bytes
    zero_zero_panter = "00000000"  # 00000000
    hidden_dragon = zero_zero_panter  # "248cbdf5" #-0.0684298649 -- originally used these values but nothing wrong with 0
    crunching_tiger = zero_zero_panter  # 3df5248c" #0.0684298649 -- could be used together to create bezier to smooth things, maybe?
    # zero bytes
    start_point = 56
    add_new_value = the_base[:start_point*2]
    curve_value = (determin_curve(the_curve_load))
    for i in range(len(curve_value[1])):
        aPointX = struct.pack('f', curve_value[0][i])
        aPointY = struct.pack('f', curve_value[1][i])
        add_new_value += (make_string_byte(aPointX) + make_string_byte(aPointY) + crunching_tiger + crunching_tiger + hidden_dragon + hidden_dragon + zero_zero_panter + zero_zero_panter)
        start_point += 32
    if write_mode == "w":
        open(save_location, "wb").write(binascii.unhexlify(add_new_value))
    elif write_mode == "c":
        print(add_new_value)
    elif write_mode == "wc":
        print(add_new_value)
        open(save_location, "wb").write(binascii.unhexlify(add_new_value))
# run tool
def convert_preset_to_vcccrv():
    the_file_loc = filedialog.asksaveasfilename(initialfile='smart_VFB_preset', defaultextension=".vcccrv")
    if the_file_loc != "":
        try:
            the_test = ""
            the_curve = string_curve.get()
            # remove special characters, that might pop in copy paste
            keyList = ["\"","\'"," ","[","]","(",")","{","}"]
            for keys in keyList:
                the_curve = the_curve.replace(keys,"")
            # just test input
            for points in the_curve.split(","):
                if float(points) < 0.0:
                    the_test += "negative values,"
                elif float(points) > 1.0:
                    the_test += "values above 1.0,"
            if len(the_curve.split(",")) % 2 == 0:
                if the_test == "":
                    # create point array
                    the_curve = (adjust_point_from_curve(addcurve(the_curve, val_size.get()), val_size.get())) # points
                    # Determin size of curve important otherwise preset file fails
                    le_curve_count = len(the_curve.split(","))
                    # the number of points need to be written in the file, from what I can tell it's being written only as 1 HEX from 00 to ff
                    if le_curve_count < 31:
                        le_curve_count = "0" + str(hex(int(le_curve_count / 2))).split("x")[1]
                    else:
                        le_curve_count = str(hex(int(le_curve_count / 2))).split("x")[1]
                    # base hex for writing the vcccrv
                    the_base_vcccrv = "3b190200000001000100000031cb444e0000010017b7513800000000ec78ade00000803fec78ad608c31c63c000080" \
                                      "3f2184703f" + le_curve_count + "0000000000000000000000"
                    # write the damn thing
                    write_vray_preset_curve(the_base_vcccrv, the_file_loc, the_curve, string_command.get())
                    messagebox.showinfo(title="Yay", message=("Preset Saved " + the_file_loc))
                else:
                    messagebox.showerror(title="FUBAR", message=("Error: " + the_test))
            else:
                messagebox.showerror(title="FUBAR", message=("Error: curve points not disivible by two"))
        except ValueError:
            pass
# meh nothing meh
# does nothing
def do_nothing():
    eveything = 42
    return eveything

if __name__ == "__main__":
    # the app
    app = Tk()
    app.title("Create VFB preset from curve text")
    app.minsize(400, 140)
    app.maxsize(400, 140)
    # variables
    val_size = IntVar()
    val_size.set(255)
    ##
    string_command = StringVar()
    string_command.set("w")
    ##
    string_curve = StringVar()
    string_curve.set("0.0,0.0, 0.25,0.25, 0.5,0.5, 0.75,0.75, 1.0,1.0")
    # the labels
    lbl_info = Label(app, text="enter adjustment curve values, create VFB preset file to match")
    lbl_info.pack()
    # main frame
    frame_local = Frame(app, height=2, borderwidth=2, relief=GROOVE, padx=5, pady=5)
    frame_local.pack()
    # entries
    entry_curve = Entry(frame_local,textvariable = string_curve,width= 50)
    entry_curve.pack()
    # buttons
    bnt_create_file = Button(frame_local,text="create_preset_file", height=3,width=20, command=convert_preset_to_vcccrv,fg="White",bg="Green")
    bnt_create_file.pack(pady=10,padx=5, side="left",expand=NO)
    ##
    bnt_future = Button(frame_local, text="maybe_read_from_VFB_file\n_or_photoshop??\n_or_remove_this",state=DISABLED, height=3, width=20,command=do_nothing,fg="yellow", bg="white")
    bnt_future.pack(pady=10, padx=5, side="left", expand=NO)
    ## loop
    app.mainloop()