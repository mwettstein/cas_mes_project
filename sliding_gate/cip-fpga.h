#pragma once
//--------------------------
//fpga interface
//(c) H.Buchmann FHNW 2014
//--------------------------
#ifndef INTERFACE
#define INTERFACE(name,id)
#endif
 
INTERFACE(cip_fpga,$Id$)
typedef unsigned char  uint8_t;
typedef          int  int8_t;
typedef unsigned short uint16_t;
enum Mode {INPUT,OUTPUT};
#define LOW false
#define HIGH true
struct Input
{
 unsigned pin;
 unsigned val;
 void (*inp)();
};

extern void init();
extern unsigned long millis();
extern void pinMode(unsigned pin,Mode mode);
extern void digitalWrite(unsigned pin,bool v);
extern bool digitalRead(unsigned pin);
extern void delay(unsigned ms);
