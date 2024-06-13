var = 142606588

from filewrappers import CWCheatFileDescriptor as cwcheatfd

file = cwcheatfd("CHEATS.TXT")

file.seek(0x8800000)

file.write("Target Camera 1/3")
with open("CAMERA.bin", "rb") as bin:
    file.write(bin.read())

file.write("Target Camera 2/3")

file.write(
    "_L 0xD0000001 0x10000110\n"
    "_L 0x200E5F88 0x0A200004\n"
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
