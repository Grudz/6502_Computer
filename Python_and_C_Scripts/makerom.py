rom = bytearray([0xea] * 32768) # full of 32k EA hex bytes (no op)

rom[0] = 0xa9 # A register
rom[1] = 0x42 # Load 42 in A

rom[2] = 0x8d # Store 42 in A register
rom[3] = 0x00 # 42 in address 6000
rom[4] = 0x60

rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom.bin", "wb") as out_file:
    out_file.write(rom)
