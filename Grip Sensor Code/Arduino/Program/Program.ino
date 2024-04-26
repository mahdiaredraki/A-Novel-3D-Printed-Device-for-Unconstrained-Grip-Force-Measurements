#include "HX711.h"
#define calibration_factor 4201
#define DOUT  3
#define CLK  2

HX711 scale;

void setup() {
  Serial.begin(9600);
  scale.begin(DOUT, CLK);
  scale.set_scale(calibration_factor); //This value is obtained by using the Calibrate.ino program
  scale.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0
}

void loop() {
  myData = round(scale.get_units());//scale.get_units() returns a float
  Serial.print('N');
  Serial.println(myData); 
}
