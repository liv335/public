import urllib.request , urllib.error
import os
import ssl
import time

# create SSL
ssl._create_default_https_context = ssl._create_unverified_context

# test variables
#link = r"https://evermotion.org/files/pdf/archmodels_vol_220.pdf"
#pdf_path = r"C:\_work\evermotion_download_pdf\archmodels_vol_220.pdf"

def stringfy(val):
    cnt_to_string = ""
    if len(str(val)) == 1:
        cnt_to_string = "00" + str(val)
    elif len(str(val)) == 2:
        cnt_to_string = "0" + str(val)
    elif len(str(val)) == 3:
        cnt_to_string = str(val)
    return cnt_to_string

def checklink(url):
    try:
        return urllib.request.urlopen(url) , True
    except urllib.error.HTTPError:
        return False , False

def download_file(download_url, filename):
    #response = urllib.request.urlopen(download_url) # url open is already done in checklink, use return variable
    file = open(filename, 'wb')
    file.write(download_url.read())
    file.close()

def loop_over_link(url, filenameloop ,savepath , ext = ".pdf", speed = 0.5, max = 5, start = 12, setdownload = False):
    if max == 0:
        max = 1000
    cnt = start

    netlocation = url + filenameloop + str(cnt) + ext
    _continue = checklink(netlocation)

    print("Start::")
    while _continue[1] and cnt < start + max:
        print("Checking::" + netlocation)
        savelocation = savepath + os.sep + filenameloop + str(cnt) + ext

        if setdownload and not os.path.exists(savelocation):
            download_file(download_url= _continue[0], filename= savelocation)
        else:
            print("Error::" + netlocation)

        cnt += 1
        netlocation = url + filenameloop + str(cnt) + ext

        _continue = checklink(netlocation)

        time.sleep(speed)
    print("Finished::")

if __name__ == '__main__':

    print (stringfy(1))
    # variables
    link = r"https://evermotion.org/files/pdf/"  # where to download
    pdf_path = r"C:\_work\evermotion_download_pdf"  # where to save
    filename = "archmodels_vol_"  # filename to find/save

    loop_over_link(link, filename, pdf_path, speed = 0.5, start = 1, max = 1, setdownload = True)
