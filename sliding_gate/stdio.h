#pragma once
/*-------------------------
stdio.h only printf
(c) H.Buchmann FHNW 2014
--------------------------
*/
#ifndef INTERFACE
#define INTERFACE(name,id)
#endif
INTERFACE(stdio,$Id$)
extern int printf(const char*const format,...);
/*------------------------
recognized tags
  %x
  %p
  %s
  %c
------------------------*/

extern int strcmp(const char* s1,const char* s2);
/*
 return
  <0     s1<s2
  =0     s1==s2
  >0     s1>s2
*/
extern char getch();
/* reads one char */
extern unsigned readline(char* line,unsigned cap,
                         char eol='\n');      
/*----------------------
   line with at least space for cap chars
   returns length 
   eol terminating char normally \n
  ----------------------*/
