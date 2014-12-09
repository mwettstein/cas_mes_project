/*******************************************************************
        SYSTEM cipsystem
        Module for PROCESS lightBarrier
        Filename: lightBarrier.c
        generated by CIP Tool(R)

        activated code options:
        	C code
        		naming option: channel name prefix
        	enable PENDING_ information
        	incremental build
        	'unsigned char' for delays
*********************************************************************/

/* Include Files */

#include "mDoorControlUnit.h"

/* Process Macro Definitions */

#define EXCEPTION return;
#define SELF status_lightBarrier.write_access_
#define STATUS (pStatus_lightBarrier->read_access_)
#define TIME time_

/* Process Enumerations */

enum eMODES_lightBarrier
	{normal = 1};

enum eSTATES_lightBarrier
	{Clear = 1, Interrupted, Off};

enum eINPULS_lightBarrier
	{IP_on = 8, IP_off = 9};
	

/* External Declarations */

extern unsigned char time_;
extern struct tCHNOUT_mDoorControlUnit CHNOUT_mDoorControlUnit;
void fUPDATE_DoorControlSystem (void);
int fPULSE_doorControl (enum eOUTPLS_ name_);

/* Global Declarations */

union tSTATUS_lightBarrier status_lightBarrier;
const union tSTATUS_lightBarrier *pStatus_lightBarrier = &status_lightBarrier;

/* Function Prototypes */

void IN_lightBarrierInChannel_interrupted (void);
void IN_lightBarrierInChannel_cleared (void);
int fPULSE_lightBarrier (enum eOUTPLS_ name_);
void fINIT_lightBarrier (void);

/* Input Channel Functions */

void IN_lightBarrierInChannel_interrupted (void)
{
	switch(status_lightBarrier.read_access_.STATE)
	{
	case Clear:
	 	status_lightBarrier.write_access_.STATE = Interrupted;
	 	fPULSE_doorControl (O20_interrupted);
		break;
	default:
		return;
	}
	fUPDATE_DoorControlSystem ();
	return;
}
void IN_lightBarrierInChannel_cleared (void)
{
	switch(status_lightBarrier.read_access_.STATE)
	{
	case Interrupted:
	 	status_lightBarrier.write_access_.STATE = Clear;
	 	fPULSE_doorControl (O20_cleared);
		break;
	default:
		return;
	}
	fUPDATE_DoorControlSystem ();
	return;
}		
int fPULSE_lightBarrier (enum eOUTPLS_ name_)
{
	switch(name_)
	{
		/* INPULSE on */
	case O18_opened:		/* PULSE CAST from PROCESS door */
		switch(status_lightBarrier.read_access_.STATE)
		{
		case Off:
			status_lightBarrier.write_access_.STATE = Interrupted;
			CHNOUT_mDoorControlUnit.message_.CHAN_lightBarrierOutChannel.name_ = lightBarrierOutChannel_on;
			OUT_lightBarrierOutChannel_on();
			break;
		default:
			break;
		}
		break;
		/* INPULSE off */
	case O18_closed:		/* PULSE CAST from PROCESS door */
		switch(status_lightBarrier.read_access_.STATE)
		{
		case Clear:
			status_lightBarrier.write_access_.STATE = Off;
			CHNOUT_mDoorControlUnit.message_.CHAN_lightBarrierOutChannel.name_ = lightBarrierOutChannel_off;
			OUT_lightBarrierOutChannel_off();
			break;
		case Interrupted:
			status_lightBarrier.write_access_.STATE = Off;
			CHNOUT_mDoorControlUnit.message_.CHAN_lightBarrierOutChannel.name_ = lightBarrierOutChannel_off;
			OUT_lightBarrierOutChannel_off();
			break;
		default:
			break;
		}
		break;
	default:
		return 0;
	}
	return 1;
}

/* Process Initialization Function */

void fINIT_lightBarrier (void)
{
	status_lightBarrier.write_access_.STATE = Off;
}		

/*********************************************************************
	End of Module for PROCESS lightBarrier
*********************************************************************/
/* Actifsource ID=[e9267837-2596-11e1-ae2f-a14f3e396de6,79056c7a-4728-11e4-aefa-c3efe9fa99c0,cca6c98c-462e-11e4-8d10-617b527355dd,5bf79245-4729-11e4-aefa-c3efe9fa99c0,790879be-4728-11e4-aefa-c3efe9fa99c0,632d07b4-462f-11e4-8d10-617b527355dd,e9b9ee3f-7092-11e4-99ab-454e858e60a3,3Pw7HGv6QDI2g6B7Eqy7e8r9t3E=] */
