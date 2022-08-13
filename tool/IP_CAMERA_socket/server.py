import pymjpeg
from glob import glob
import sys
import logging
import cv2
import numpy as np
import socket 
import time

logging.info('Listening on port 8080...')
host = '192.168.2.6' #host = '192.168.2.6'
port = 8080  
address = (host,port)  
server_sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  
server_sock.bind(address)  
server_sock.listen(10) 
cap = cv2.VideoCapture(0)
print('waiting for connection...')
clientsock,addr = server_sock.accept()  
print('received from :',addr)  
Send_content = 'Hello!\r\n'
pattern=48

while True:
    a = cv2.waitKey(1)                            #camera
    ret,fram     = cap.read()
    fram_resize  = cv2.resize(fram,(640,480))
    cv2.imshow('fram_resize',fram_resize)
    ret, jpeg = cv2.imencode('.jpeg', fram_resize) 
    jpeg_byte = jpeg.tobytes()
    
    clientsock.send(bytes(pymjpeg.boundary, 'utf-8'))
    for i in jpeg_byte:
        clientsock.send(i.to_bytes(length=1, byteorder='big', signed=False))
        
clientsock.close()  
server_sock.close()  
sys.exit()




















