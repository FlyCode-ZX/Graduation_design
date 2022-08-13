#fo_in = open("F:/09-file/FPGA/ALTERA/SOC/M3_SOC/Smart_camera/v2.0/RTL/image.hex", "r")
fo_in = open("F:/08-design/FPGA/Altera/EP4CE55/SOC/M3_SOC/bishe/software/image.hex", "r")
fo_out = open("initial.mif", "w")

#for i in range(32):
    #print('%#x'% i)
    #fo.write(format(i, '02x').upper()+"\n")
    #fo_out.write("BRAM["+str(i)+"]<= "+format(i, '02x').upper()+"\n")
    #fo.write("BRAM["+int(i)+"\n")
    
fo_out.write("WIDTH=32;\n")
fo_out.write("DEPTH=16384;\n")
fo_out.write("ADDRESS_RADIX=UNS;\n")
fo_out.write("DATA_RADIX=UNS;\n")
fo_out.write("CONTENT BEGIN\n")

i=0
while True:
    Line = fo_in.readline()
    if(Line==""):break
    Line = "0x"+Line.strip('\n')
    Line = int(Line,16)
    Line = str(Line)+";"
    fo_out.write("   "+str(i)+"   :   "+Line+"\n")
    i = i+1

fo_out.write("["+str(i)+"..16383]  :  0;\n") 
fo_out.write("END;\n")  
#fo.write("hello")
fo_in.close()
fo_out.close()








