import serial

ser = serial.Serial("COM6", 9600, timeout = 1)
key = "2b7e151628aed2a6abf7158809cf4f3c"
encrypted_data = "3925841d02dc09fbdc118597196a0b32"
print("Sending Key: " + key)
ser.write(bytearray.fromhex(key))

print("Sending Data: " + encrypted_data)
ser.write(bytearray.fromhex(encrypted_data))

data = ser.read(16)
print("Received Decrypted Data: " + data.hex())
# Expected
# 3243f6a8885a308d313198a2e0370734
ser.close()
