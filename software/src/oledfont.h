#ifndef __OLEDFONT_H
#define __OLEDFONT_H 	   
//����ASCII��
//ƫ����32
//ASCII�ַ���
//ƫ����32
//��С:12*6
#define	u8 unsigned char
#define	u16 unsigned int
#define	u32 unsigned long
/************************************6*8�ĵ���************************************/
unsigned char Hzk16[]={
	
0x00,
	
};

const unsigned char Hzk24[]={ //128B
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x01,0x00,0x80,
0x01,0x00,0x80,0xD9,0x0C,0xE0,0xDF,0x0F,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,
0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,
0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD9,0x0C,0x80,0xD8,0x0C,0x40,
0xD8,0x0F,0x20,0xCE,0x0C,0x10,0x01,0x00,//?0
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x60,0x00,0x40,
0x60,0x00,0xC0,0xFC,0x07,0x80,0x60,0x00,0x80,0x64,0x06,0x00,0xFC,0x07,0xF0,0x64,
0x06,0xC0,0x64,0x06,0xC0,0xFC,0x07,0xC0,0xE4,0x06,0xC0,0xF0,0x00,0xC0,0x70,0x01,
0xC0,0x78,0x03,0xC0,0x68,0x06,0xC0,0x64,0x06,0xC0,0x62,0x04,0xC0,0x60,0x00,0x70,
0x01,0x00,0x30,0xFE,0x07,0x00,0x00,0x00,//?1
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x06,0xC0,0xEF,0x07,0xC0,
0x6C,0x06,0xC0,0x6C,0x06,0xC0,0x6C,0x06,0xC0,0x6C,0x06,0xC0,0xEF,0x07,0xC0,0x90,
0x00,0x00,0x18,0x01,0xE0,0xFF,0x0F,0x00,0x4C,0x00,0x00,0x82,0x01,0x80,0x01,0x1F,
0xE0,0xEF,0x1F,0xC0,0x6C,0x06,0xC0,0x6C,0x06,0xC0,0x6C,0x06,0xC0,0x6C,0x06,0xC0,
0xEF,0x07,0xC0,0x6C,0x06,0x00,0x00,0x00,//?2
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC3,0x00,0x00,0xC3,0x00,0x00,
0xC3,0x01,0x00,0xC3,0x02,0x10,0xC3,0x06,0x20,0xC3,0x04,0x20,0xC3,0x00,0x60,0xFF,
0x0F,0x00,0xC3,0x00,0x00,0xC3,0x00,0x00,0xC3,0x00,0x80,0xC3,0x00,0x40,0xC3,0x00,
0x70,0xE3,0x00,0x30,0x63,0x01,0x10,0x23,0x03,0x00,0x33,0x07,0x00,0x13,0x0E,0x00,
0x0B,0x0C,0x00,0x07,0x0C,0x00,0x04,0x00,//?3
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x18,0x00,0x00,
0x18,0x00,0x00,0x18,0x00,0xE0,0xFF,0x0F,0x00,0x38,0x00,0x00,0x48,0x00,0x00,0x84,
0x00,0x00,0x8A,0x01,0x00,0x31,0x0F,0x80,0x20,0x0C,0x60,0x20,0x08,0xC0,0x16,0x00,
0xC0,0x26,0x02,0xC0,0x66,0x06,0xC0,0x66,0x05,0xC0,0x06,0x0D,0xC0,0x06,0x09,0x40,
0x06,0x01,0x20,0xFE,0x01,0x00,0x00,0x00,//?4
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0xC0,0xC4,0x00,0xC0,
0xC4,0x00,0xC0,0xC4,0x0F,0xC0,0x44,0x00,0xC0,0x64,0x00,0xC0,0xA4,0x00,0xC0,0x14,
0x01,0xC0,0x04,0x03,0xC0,0x04,0x02,0x00,0x04,0x02,0x00,0x00,0x00,0xC0,0xFF,0x03,
0xC0,0x64,0x03,0xC0,0x64,0x03,0xC0,0x64,0x03,0xC0,0x64,0x03,0xC0,0x64,0x03,0xC0,
0x64,0x03,0xF0,0xFF,0x0F,0x00,0x00,0x00,//?5
/* (24 X 24 , ???? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0xC1,0x00,0x80,
0x81,0x00,0x80,0xFD,0x0F,0x80,0x0D,0x0C,0xF0,0x0F,0x04,0x80,0x61,0x03,0x80,0x21,
0x02,0x80,0x35,0x06,0x80,0x13,0x0C,0xC0,0x09,0x0C,0xF0,0x01,0x00,0xA0,0xF9,0x0F,
0x80,0xC1,0x00,0x80,0xC1,0x00,0x80,0xC1,0x00,0x80,0xC1,0x00,0x80,0xC1,0x00,0x80,
0xC1,0x00,0xE0,0xFC,0x1F,0x00,0x00,0x00,//?6
/* (24 X 24 , ???? )*/
};

const unsigned char  ASCII_num[]={

0x00,0x00,0x00,0x18,0x24,0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x24,0x18,0x00,0x00,//00
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x10,0x1C,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x7C,0x00,0x00,//11
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3C,0x42,0x42,0x42,0x40,0x20,0x10,0x08,0x04,0x42,0x7E,0x00,0x00,//22
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3C,0x42,0x42,0x40,0x20,0x18,0x20,0x40,0x42,0x42,0x3C,0x00,0x00,//33
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x20,0x30,0x30,0x28,0x24,0x24,0x22,0xFE,0x20,0x20,0xF8,0x00,0x00,//44
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7E,0x02,0x02,0x02,0x1E,0x22,0x40,0x40,0x42,0x22,0x1C,0x00,0x00,//55
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x18,0x24,0x02,0x02,0x3A,0x46,0x42,0x42,0x42,0x44,0x38,0x00,0x00,//66
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7E,0x42,0x20,0x20,0x10,0x10,0x08,0x08,0x08,0x08,0x08,0x00,0x00,//77
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3C,0x42,0x42,0x42,0x24,0x18,0x24,0x42,0x42,0x42,0x3C,0x00,0x00,//88
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x1C,0x22,0x42,0x42,0x42,0x62,0x5C,0x40,0x40,0x24,0x18,0x00,0x00,//99
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x08,0x08,0x18,0x14,0x14,0x24,0x3C,0x22,0x42,0x42,0xE7,0x00,0x00,//A10
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x1F,0x22,0x22,0x22,0x1E,0x22,0x42,0x42,0x42,0x22,0x1F,0x00,0x00,//B11
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7C,0x42,0x42,0x01,0x01,0x01,0x01,0x01,0x42,0x22,0x1C,0x00,0x00,//C12
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x1F,0x22,0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x22,0x1F,0x00,0x00,//D13
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3F,0x42,0x12,0x12,0x1E,0x12,0x12,0x02,0x42,0x42,0x3F,0x00,0x00,//E14
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3F,0x42,0x12,0x12,0x1E,0x12,0x12,0x02,0x02,0x02,0x07,0x00,0x00,//F15
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3C,0x22,0x22,0x01,0x01,0x01,0x71,0x21,0x22,0x22,0x1C,0x00,0x00,//G16
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0xE7,0x42,0x42,0x42,0x42,0x7E,0x42,0x42,0x42,0x42,0xE7,0x00,0x00,//H17
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3E,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x3E,0x00,0x00,//I18
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7C,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x11,0x0F,//J19
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x77,0x22,0x12,0x0A,0x0E,0x0A,0x12,0x12,0x22,0x22,0x77,0x00,0x00,//K20
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x07,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x42,0x7F,0x00,0x00,//L21
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x77,0x36,0x36,0x36,0x36,0x36,0x2A,0x2A,0x2A,0x2A,0x6B,0x00,0x00,//M22
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0xE3,0x46,0x46,0x4A,0x4A,0x52,0x52,0x52,0x62,0x62,0x47,0x00,0x00,//N23
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x1C,0x22,0x41,0x41,0x41,0x41,0x41,0x41,0x41,0x22,0x1C,0x00,0x00,//O24
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3F,0x42,0x42,0x42,0x42,0x3E,0x02,0x02,0x02,0x02,0x07,0x00,0x00,//P25
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x1C,0x22,0x41,0x41,0x41,0x41,0x41,0x41,0x4D,0x32,0x1C,0x60,0x00,//Q26
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x3F,0x42,0x42,0x42,0x3E,0x12,0x12,0x22,0x22,0x42,0xC7,0x00,0x00,//R27
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7C,0x42,0x42,0x02,0x04,0x18,0x20,0x40,0x42,0x42,0x3E,0x00,0x00,//S28
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7F,0x49,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x1C,0x00,0x00,//T29
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0xE7,0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x42,0x3C,0x00,0x00,//U30
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0xE7,0x42,0x42,0x22,0x24,0x24,0x14,0x14,0x18,0x08,0x08,0x00,0x00,//V31
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x6B,0x2A,0x2A,0x2A,0x2A,0x2A,0x36,0x14,0x14,0x14,0x14,0x00,0x00,//W32
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0xE7,0x42,0x24,0x24,0x18,0x18,0x18,0x24,0x24,0x42,0xE7,0x00,0x00,//X33
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x77,0x22,0x22,0x14,0x14,0x08,0x08,0x08,0x08,0x08,0x1C,0x00,0x00,//Y34
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x7E,0x21,0x20,0x10,0x10,0x08,0x04,0x04,0x42,0x42,0x3F,0x00,0x00,//Z35
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1C,0x22,0x30,0x2C,0x22,0x32,0x6C,0x00,0x00,//a36
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x03,0x02,0x02,0x1A,0x26,0x42,0x42,0x42,0x26,0x1A,0x00,0x00,//b37
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x44,0x02,0x02,0x02,0x44,0x38,0x00,0x00,//c38
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x60,0x40,0x40,0x7C,0x42,0x42,0x42,0x42,0x62,0xDC,0x00,0x00,//d39
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3C,0x42,0x42,0x7E,0x02,0x42,0x3C,0x00,0x00,//e40
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x30,0x48,0x08,0x3E,0x08,0x08,0x08,0x08,0x08,0x3E,0x00,0x00,//f41
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7C,0x22,0x22,0x1C,0x02,0x3C,0x42,0x42,0x3C,//g42
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x03,0x02,0x02,0x3A,0x46,0x42,0x42,0x42,0x42,0xE7,0x00,0x00,//h43
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x0C,0x0C,0x00,0x00,0x0E,0x08,0x08,0x08,0x08,0x08,0x3E,0x00,0x00,//i44
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x30,0x30,0x00,0x00,0x38,0x20,0x20,0x20,0x20,0x20,0x20,0x22,0x1E,//j45
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x03,0x02,0x02,0x72,0x12,0x0A,0x0E,0x12,0x22,0x77,0x00,0x00,//k46
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x08,0x0E,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x3E,0x00,0x00,//l47
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7F,0x92,0x92,0x92,0x92,0x92,0xB7,0x00,0x00,//m48
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3B,0x46,0x42,0x42,0x42,0x42,0xE7,0x00,0x00,//n49
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3C,0x42,0x42,0x42,0x42,0x42,0x3C,0x00,0x00,//o50
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1B,0x26,0x42,0x42,0x42,0x26,0x1A,0x02,0x07,//p51
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x58,0x64,0x42,0x42,0x42,0x64,0x58,0x40,0xE0,//q52
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0x4C,0x04,0x04,0x04,0x04,0x1F,0x00,0x00,//r53
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7C,0x42,0x02,0x3C,0x40,0x42,0x3E,0x00,0x00,//s54
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x08,0x08,0x3E,0x08,0x08,0x08,0x08,0x48,0x30,0x00,0x00,//t55
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x63,0x42,0x42,0x42,0x42,0x62,0xDC,0x00,0x00,//u56
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0x22,0x22,0x14,0x14,0x08,0x08,0x00,0x00,//v57
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xDB,0x91,0x52,0x5A,0x2A,0x24,0x24,0x00,0x00,//w58
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x6E,0x24,0x18,0x18,0x18,0x24,0x76,0x00,0x00,//x59
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE7,0x42,0x24,0x24,0x18,0x18,0x08,0x08,0x06,//y60
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7E,0x22,0x10,0x08,0x08,0x44,0x7E,0x00,0x00,//z61
/* (8 X 16 , ?? )*/

0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,//_0
0x00,0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00,0x00,0x00,0x00,0x18,0x18,0x00,0x00,//:0
0x00,0x00,0x00,0x40,0x20,0x10,0x08,0x04,0x02,0x04,0x08,0x10,0x20,0x40,0x00,0x00,//<,0
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,// ,0
0x00,0x00,0x00,0x00,0x00,0x10,0x10,0x10,0xFE,0x10,0x10,0x10,0x00,0x00,0x00,0x00,//+,0
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7E,0x00,0x00,0x00,0x00,0x00,0x00,0x00,//-,0
};

#endif

