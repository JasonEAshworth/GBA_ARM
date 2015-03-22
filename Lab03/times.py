
import math
import pygame

deg = 0
rad = 48
startX = 119
startY = 79


fp = open("minutes.as" , "w")

fp.write(".text\n")
fp.write(".align 1\n\t")


while deg < 360:

    x = math.floor(math.cos(math.radians(deg-90)) * rad + startX)
    y = math.floor(math.sin(math.radians(deg-90)) * rad + startY)
    if (x > 256 or y > 256):
        print("X: " + str(x))
        print("Y: " + str(y))
    fp.write(".hword " + str(y << 8 | x) + "\n\t")
    deg += 6
fp.close()

fp = open("hours.as" , "w")

fp.write(".text\n")
fp.write(".align 1\n\t")

deg = 0
while deg < 360:
    x = math.floor(math.cos(math.radians(deg-90)) * rad + startX)
    y = math.floor(math.sin(math.radians(deg-90)) * rad + startY)
    if (x > 256 or y > 256):
        print("X: " + str(x))
        print("Y: " + str(y))
    fp.write(".hword " + str(y << 8 | x) + "\n\t")
    deg += 30

fp.close()

