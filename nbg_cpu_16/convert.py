with open('../stm32-test-mini/Projects/MDK-ARM/stm32-test.bin', 'rb') as bin_file, open('rom.coe', 'w') as coe_file:
    bin_data = bin_file.read()
    coe_file.write("memory_initialization_radix=16;\n")
    coe_file.write("memory_initialization_vector=")
    
    first = True
    for i in range(0,len(bin_data),4):
        if not first:
            coe_file.write(' ')
        else:
            first = False
        coe_file.write('{:02X}{:02X}{:02X}{:02X}'.format(bin_data[i+3],bin_data[i+2],bin_data[i+1],bin_data[i]))
    coe_file.write(";")
