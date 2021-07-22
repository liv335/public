import math

def trinagle_coords(ipotenuse, angle, decimals = 4, _flip = False):
    result = [ipotenuse, 0]
    sign = (int(angle / 90) % 4)

    if angle < -90:
        pass
        angle = angle * -1
        _flip = True
    elif angle >= 180:
        angle = ((int(angle/180))-(float(angle/180)))*180

    if angle != 0:
        print (sign)
        oposite = float(int(float(math.cos(math.pi/(180/angle)) * ipotenuse) * pow(10,decimals)) / pow(10,decimals))
        nextto = float(int(float(math.sin(math.pi/(180/angle)) * ipotenuse) * pow(10,decimals)) / pow(10,decimals))

        if oposite < 0 and 0 == sign or sign == 3:
            pass
            oposite = oposite * -1
        if nextto < 0 and 1 == sign or sign == 2:
            pass
            nextto = nextto * -1

        if _flip == True:
            result = [nextto, oposite]
        else:
            result = [oposite,nextto]
    return result

# inputs
angle = 45
ipotenuse = 10

print(trinagle_coords(ipotenuse,angle))
