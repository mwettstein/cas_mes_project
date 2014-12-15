#include "cip-fpga.h"
#include "sDoorControlUnit.h" //sxxx.h xxx=Unitname
#include "mDoorControlUnit.h" //mxxx.h xxx=Unitname
#include "eDoorControlUnit.h" //exxx.h xxx=Unitname
#include "digitalInput.h"
//#include <../../../../barebone/tc/arm-none-linux-gnueabi/include/c++/4.9.1/tr1/cstdio.h>
#include <stdio.h>
//#include <stdlib.h>

#define TICKS_PER_SECOND  10
unsigned int z_phys = 0;

//pin definition
#define DoorNotClosedPin      0
#define DoorNotOpenedPin      1
#define LightBarrierClearPin  2
#define Button1ReleasedPin    3
#define Button2ReleasedPin    4

#define DriveOnPin            7
#define DriveDirectionOpenPin 8
#define LightBarrierOnPin     9
#define Light1OnPin           10
#define Light2OnPin           11

/* Action initiation functions,
   called by Reactive-Machine when a Message is written. */
void OUT_light1OutChannel_off 		(void) 	{ digitalWrite(Light1OnPin, LOW);}
void OUT_light1OutChannel_on  		(void) 	{ digitalWrite(Light1OnPin, HIGH);}
void OUT_light2OutChannel_off 		(void) 	{ digitalWrite(Light2OnPin, LOW);}
void OUT_light2OutChannel_on 		(void) 	{ digitalWrite(Light2OnPin, HIGH);}
void OUT_driveOutChannel_open  		(void)	{ digitalWrite(DriveOnPin,  HIGH);
											  digitalWrite(DriveDirectionOpenPin,HIGH);}
void OUT_driveOutChannel_close  	(void)	{ digitalWrite(DriveOnPin,  HIGH);
											  digitalWrite(DriveDirectionOpenPin,LOW);}
void OUT_driveOutChannel_stop  		(void)	{ digitalWrite(DriveOnPin,  LOW);}

void OUT_lightBarrierOutChannel_on     (void)	{ digitalWrite(LightBarrierOnPin, HIGH);}
void OUT_lightBarrierOutChannel_off     (void)	{ digitalWrite(LightBarrierOnPin, LOW);}



void initPins()
{
	//set pinModes
	pinMode(DoorNotClosedPin, INPUT);
	pinMode(DoorNotOpenedPin, INPUT);
	pinMode(LightBarrierClearPin, INPUT);
	pinMode(Button1ReleasedPin, INPUT);
	pinMode(Button2ReleasedPin, INPUT);

	pinMode(DriveOnPin, OUTPUT);
	pinMode(DriveDirectionOpenPin, OUTPUT);
	pinMode(LightBarrierOnPin, OUTPUT);
	pinMode(Light1OnPin, OUTPUT);
	pinMode(Light2OnPin, OUTPUT);

	//set outpins LOW
	digitalWrite(DriveOnPin, LOW);
	digitalWrite(DriveDirectionOpenPin, LOW);
	digitalWrite(LightBarrierOnPin, LOW);
	digitalWrite(Light1OnPin, LOW);
	digitalWrite(Light2OnPin, LOW);
}
//digital input objects
static DigitalInput_t button1;
static DigitalInput_t button2;
static DigitalInput_t doorNotOpend;
static DigitalInput_t doorNotClosed;
static DigitalInput_t lightBarrierClear;

void initDigitalInputs()
{
	DigitalInput_init(&button1, Button1ReleasedPin);
	DigitalInput_init(&button2, Button2ReleasedPin);
	DigitalInput_init(&doorNotOpend,  DoorNotOpenedPin);
	DigitalInput_init(&doorNotClosed, DoorNotClosedPin);
	DigitalInput_init(&lightBarrierClear, LightBarrierClearPin);

	DigitalInput_setInitialValue(&button1,1);
	DigitalInput_setInitialValue(&button2,1);
	DigitalInput_setInitialValue(&doorNotOpend,1);
	DigitalInput_setInitialValue(&doorNotClosed,1);
	DigitalInput_setInitialValue(&lightBarrierClear,1);
}

unsigned long lastTimeMillis = 0;
unsigned long waitTime = 2200;         // 10'000 = 13s => 2'200 = 3s!
unsigned long newWaitTime = 0;

const uint16_t loopMax = 10000;

void detectAndHandleEvents()
{
	//set old values to defined initial states
	//these are part of the interface definition
	int8_t edge =0;

	edge = DigitalInput_detectEdge(&button1);
	if     (edge == fallingEdge){IN_button1InChannel_press();}
	else if(edge == risingEdge ){IN_button1InChannel_release();}

	edge = DigitalInput_detectEdge(&button2);
	if     (edge == fallingEdge){IN_button2InChannel_press();}
	else if(edge == risingEdge ){IN_button2InChannel_release();}

	edge = DigitalInput_detectEdge(&doorNotClosed);
	if     (edge == fallingEdge){IN_doorInChannel_doorClosed();}
	else if(edge == risingEdge ){IN_doorInChannel_doorNotClosed();}

	edge = DigitalInput_detectEdge(&doorNotOpend);
	if     (edge == fallingEdge){IN_doorInChannel_doorOpened();}
	else if(edge == risingEdge ){IN_doorInChannel_doorNotOpened();}

	edge = DigitalInput_detectEdge(&lightBarrierClear);
	if     (edge == fallingEdge){IN_lightBarrierInChannel_interrupted();}
	else if(edge == risingEdge ){IN_lightBarrierInChannel_cleared();}

	unsigned long currentTimeMillis = millis();
    unsigned long tickCount = (TICKS_PER_SECOND*(currentTimeMillis-lastTimeMillis))/1000;
    for(int i= 0; i< tickCount;i++)
    {
		TRG_TICK_();// ticking time
	    lastTimeMillis = currentTimeMillis;
    }

	while(TRG_PENDING_.ANY_) {TRG_STEP_();}
}

void runCycle(void)
{
  int8_t edge = 0;

  OUT_driveOutChannel_open();       // activate motor to open door
  //printf("Opening gate\n");

  do
  {
    //lastTimeMillis = millis();
    edge = DigitalInput_detectEdge(&doorNotOpend);
  }
  while(edge!= fallingEdge);        // wait for door to be opened

  OUT_driveOutChannel_stop();       // stop motor
  //printf("Gate stop\n");

  newWaitTime = millis() + waitTime;

  do
  {
    lastTimeMillis = millis();
  }
  while(lastTimeMillis < newWaitTime);  // wait for 3s

  OUT_driveOutChannel_close();       // activate motor to close door
  //printf("Closing gate\n");

  do
  {
   	edge = DigitalInput_detectEdge(&doorNotClosed);
  }
  while(edge!= fallingEdge);        // wait for door to be closed

  OUT_driveOutChannel_stop();       // stop motor
  //printf("Gate stop\n");
}

int main()
{
	init();							  //init arduino
	initPins();
	initDigitalInputs();

	lastTimeMillis = millis();

  char term_input[20];

	if(!fINIT_()) {return 1;} //init reactive machine

	printf("READY\n");

  while(1)
	{
    printf("Command: ");
    readline(term_input, 20);

    if(!strcmp(term_input, "run"))
    {
      printf("\nack\n");
      runCycle();
      //printf("Cycle has ended\n");
    }

    else
    {
      printf("\nnack\n", term_input);
    }
	}
}
