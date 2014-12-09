#include "cip-fpga.h"

typedef struct DigitalInput
{
	uint8_t pinNo;
	int8_t  debounceValue;
	unsigned long lastTimeMillis;
} DigitalInput_t;

extern const int8_t fallingEdge;
extern const int8_t risingEdge;
extern const int8_t noEdge;

int8_t DigitalInput_detectEdge(DigitalInput_t* me);
void DigitalInput_init(DigitalInput_t* me, uint8_t _pinNo);
void DigitalInput_setInitialValue(DigitalInput_t* me, uint8_t value);


