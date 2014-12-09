#include "digitalInput.h"
#include "cip-fpga.h"


const int8_t dbMaxCount  =5;     //debounce count, signal has to be stable dbMaxCount times
const int8_t dbTime_ms   =1; //debounce time between 2 measurements
const int8_t fallingEdge = -1;
const int8_t risingEdge  = +1;
const int8_t noEdge      = 0;

void DigitalInput_init(DigitalInput_t* me, uint8_t _pinNo)
{
	me->pinNo = _pinNo;
	me->debounceValue = 0;
	me->lastTimeMillis=millis();//-dbTime_ms;
}

void DigitalInput_setInitialValue(DigitalInput_t* me, uint8_t value)
{
	if(value == 1)
	{
		me->debounceValue = dbMaxCount;
	}
	else if(value == 0)
	{
		me->debounceValue = -dbMaxCount;
	}
	else //value not valid
	{
		me->debounceValue = 0;
	}
}

int8_t DigitalInput_detectEdge(DigitalInput_t* me)
{
	int currentValue =0;
	unsigned long currentTimeMillis = millis();
    if((currentTimeMillis -(me->lastTimeMillis) >= dbTime_ms)) //dbTime is over
    {
    	me->lastTimeMillis = currentTimeMillis;
    	currentValue = digitalRead(me->pinNo);
    	if(currentValue == LOW )
    	{
    		if(me->debounceValue <=0)
    		{
    			if(me->debounceValue > -dbMaxCount)
    			{
    				me->debounceValue--;
    				if(me->debounceValue == -dbMaxCount)
    				{
    					return fallingEdge;
    				}
    			}
    		}
    		else
    		{
    			me->debounceValue =0;
    		}
    	}
    	else
    	if(currentValue == HIGH)
    	{
    		if(me->debounceValue >=0)
    		{
    			if(me->debounceValue < dbMaxCount)
    			{
    				me->debounceValue++;
    				if(me->debounceValue == dbMaxCount)
    				{
    					return risingEdge;
    				}
    			}
    		}
    		else
    		{
    			me->debounceValue =0;
    		}
    	}
    }
	return noEdge;
}
