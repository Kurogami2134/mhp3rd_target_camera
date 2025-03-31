var = 142609676

from ModIO import CwCheatIO

file = CwCheatIO("CHEATS.TXT")

#file.seek(0x88E6D64)

#file.write(b'\x4b\x00\x20\x0e')


file.seek(0x8800C00)

file.write("Target Camera 1/3")
with open("bin/CAMERA.bin", "rb") as bin:
    file.write(bin.read())

file.write("Target Camera 2/3")

file.write(
    "_L 0xD0000001 0x10000110\n"
    "_L 0x200E5F88 0x0A200304\n"
    "_L 0x200E5F8C 0x00000000\n"
    
    "_L 0xD0000001 0x10000140\n"
    "_L 0x200E5F88 0x8EA20074\n"
    "_L 0x200E5F8C 0x9226008F\n"
)

file.write("Target Camera 3/3")

add = hex(var - 0x8800000).replace("0x", "")
add2 = hex(var + 2 - 0x8800000).replace("0x", "")

file.write(
    "_L 0xD0000003 0x10000180\n"
    f"_L 0xE1020000 0x00{add2:0>6}\n"
    f"_L 0xE0010000 0x30{add:0>6}\n"
    f"_L 0x30400004 0x00{add:0>6}\n"
    f"_L 0x00{add2:0>6} 0x00000001\n"
    
    "_L 0xD0000002 0x10000120\n"
    f"_L 0xE1010000 0x00{add2:0>6}\n"
    f"_L 0x30300004 0x00{add:0>6}\n"
    f"_L 0x00{add2:0>6} 0x00000001\n"
    
    "_L 0xD0000001 0x30000120\n"
    "_L 0xD0000000 0x30000180\n"
    f"_L 0x00{add2:0>6} 0x00000000\n"
)

file.write("Target Camera UI 1/2")
file.seek(0x08801600)
with open("bin/RENDER.bin", "rb") as bin:
    file.write_once(bin.read())

file.write("Target Camera UI 2/2")
file.seek(0x09D63ADC)
file.write(
    "_L 0xE0036167 0x01457ca0\n"
    "_L 0xE002004b 0x11563adc\n"
)
file.write(b'\x80\x05\x20\x0a')
file.write(b'\x00\x00\x00\x00')
file.close()
