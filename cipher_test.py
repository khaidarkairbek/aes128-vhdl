import serial

ser = serial.Serial("COM6", 9600, timeout = 1)
key = "2b7e151628aed2a6abf7158809cf4f3c"
data = "3243f6a8885a308d313198a2e0370734"
print("Sending Key: " + key)
ser.write(bytearray.fromhex(key))

print("Sending Data: " + data)
ser.write(bytearray.fromhex(data))

encrypted_data = ser.read(16)
print("Received Encrypted Data: " + encrypted_data.hex())
# Expected
# 3925841d02dc09fbdc118597196a0b32
ser.close()
