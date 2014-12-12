/*******************************************************************
        SYSTEM cipsystem
        Module for PROCESS blinker
        Filename: blinker.c
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

#define SELF status_blinker.write_access_
#define STATUS (pStatus_blinker->read_access_)
#define TIME time_

/* Process Enumerations */

enum eMODES_blinker
	{normal = 1};

enum eSTATES_blinker
	{BlinkingOff = 1, BlinkingOn, Off};

enum eINPULS_blinker
	{IP_start = 4, IP_stop = 5, TIMEUP_ = 6};
	

/* External Declarations */

extern unsigned char time_;
extern struct tTMQE_mDoorControlUnit *tuhead_mDoorControlUnit, *tutail_mDoorControlUnit;
extern struct tCHNOUT_mDoorControlUnit CHNOUT_mDoorControlUnit;
extern struct tTIMING_mDoorControlUnit TIMING_mDoorControlUnit[TIMER_COUNT_];
void fUPDATE_DoorControlSystem (void);
int fPULSE_light1 (enum eOUTPLS_ name_);
void fSETTIM_mDoorControlUnit (unsigned char *delay_, struct tTMEL_mDoorControlUnit *timer_, struct tTMQE_mDoorControlUnit *timeup_);
void fSTOPTIM_mDoorControlUnit (struct tTMEL_mDoorControlUnit *timer_, struct tTMQE_mDoorControlUnit *timeup_);

/* Global Declarations */

static unsigned char delay_;
struct tPRINST_blinker IO_blinker;
union tSTATUS_blinker status_blinker;
const union tSTATUS_blinker *pStatus_blinker = &status_blinker;

/* Function Prototypes */

int fPULSE_blinker (enum eOUTPLS_ name_);
void fINIT_blinker (void);

/* Input Channel Functions */

int fPULSE_blinker (enum eOUTPLS_ name_)
{
	switch(name_)
	{
		/* INPULSE start */
	case O18_startClosing:		/* PULSE CAST from PROCESS door */
		switch(status_blinker.read_access_.STATE)
		{
		case Off:
			{
				delay_ =  _500ms;	/* DELAY _500ms */
				status_blinker.write_access_.STATE = BlinkingOn;
				fSETTIM_mDoorControlUnit(&delay_, 
					&IO_blinker.timer_, 
					&IO_blinker.timeup_);
				fPULSE_light1 (O19_on);
			}
			break;
		default:
			break;
		}
		break;
		/* INPULSE stop */
	case O18_closed:		/* PULSE CAST from PROCESS door */
		switch(status_blinker.read_access_.STATE)
		{
		case BlinkingOff:
			status_blinker.write_access_.STATE = Off;
			fPULSE_light1 (O19_off);
			break;
		case BlinkingOn:
			status_blinker.write_access_.STATE = Off;
			fPULSE_light1 (O19_off);
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

/* Timer Functions */

static void fTICK_blinker (void)
{
	if (IO_blinker.timer_.set_ &&
		IO_blinker.timer_.end_ == time_)
	{
		IO_blinker.timer_.set_ = FALSE;
		--TIMING_mDoorControlUnit[TIMER_blinker_19].set_;
		if (tuhead_mDoorControlUnit != &IO_blinker.timeup_ &&
			!IO_blinker.timeup_.preced_ &&
			!IO_blinker.timeup_.next_)
		{
			if (!tuhead_mDoorControlUnit)
			{
				tuhead_mDoorControlUnit = tutail_mDoorControlUnit = &IO_blinker.timeup_;
			}
			else
			{
				tutail_mDoorControlUnit->next_ = &IO_blinker.timeup_;
				IO_blinker.timeup_.preced_ = tutail_mDoorControlUnit;
				tutail_mDoorControlUnit = &IO_blinker.timeup_;
			}
		}
	}			
}

static void fTUHNDL_blinker(void)
{
	struct tTMQE_mDoorControlUnit *element_ = tuhead_mDoorControlUnit;
	if (tuhead_mDoorControlUnit == tutail_mDoorControlUnit)
	{
		tuhead_mDoorControlUnit = tutail_mDoorControlUnit = 0;
	}
	else 
	{
		tuhead_mDoorControlUnit = element_->next_;
		element_->next_ = 0;
		tuhead_mDoorControlUnit->preced_ = 0;
	}
	switch(status_blinker.read_access_.STATE)
	{
	case BlinkingOff:
		{
			delay_ =  _500ms;	/* DELAY _500ms */
			status_blinker.write_access_.STATE = BlinkingOn;
			fSETTIM_mDoorControlUnit(&delay_, 
				&IO_blinker.timer_, 
				&IO_blinker.timeup_);
			fPULSE_light1 (O19_on);
		}
		break;
	case BlinkingOn:
		{
			delay_ =  _500ms;	/* DELAY _500ms */
			status_blinker.write_access_.STATE = BlinkingOff;
			fSETTIM_mDoorControlUnit(&delay_, 
				&IO_blinker.timer_, 
				&IO_blinker.timeup_);
			fPULSE_light1 (O19_off);
		}
		break;
	default:
		break;
	}
	fUPDATE_DoorControlSystem (); 
}

/* Process Initialization Function */

void fINIT_blinker (void)
{
	status_blinker.write_access_.STATE = Off;
	status_blinker.write_access_.halfPeriod = _500ms;
	IO_blinker.timer_.set_ = FALSE;
	IO_blinker.timeup_.preced_ = 0;
	IO_blinker.timeup_.next_ = 0;
	IO_blinker.timeup_.proctype_ = TIMER_blinker_19;
	TIMING_mDoorControlUnit[TIMER_blinker_19].tkhndl_ = fTICK_blinker;
	TIMING_mDoorControlUnit[TIMER_blinker_19].tuhndl_ = fTUHNDL_blinker;
}		

/*********************************************************************
	End of Module for PROCESS blinker
*********************************************************************/
/* Actifsource ID=[e9267837-2596-11e1-ae2f-a14f3e396de6,79056c7a-4728-11e4-aefa-c3efe9fa99c0,cca6c98c-462e-11e4-8d10-617b527355dd,5bf79245-4729-11e4-aefa-c3efe9fa99c0,790879be-4728-11e4-aefa-c3efe9fa99c0,632d07b4-462f-11e4-8d10-617b527355dd,b223c6fb-5dcf-11e4-963d-dbfaab6e834b,22wEoI9lw2R0N07C+oqWelMmw3k=] */