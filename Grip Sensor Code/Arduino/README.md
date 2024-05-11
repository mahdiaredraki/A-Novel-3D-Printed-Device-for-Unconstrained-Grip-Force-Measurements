## Calibration
1. Open the Calibrate.ino code in Arduino IDE.
2. Upload the program onto the Arduino.
3. Open the Serial Monitor by clicking Tools -> Serial Monitor.
4. Apply a known load to the device.
5. Adjust the device output in the Serial Monitor by entering + or – until the reading matches the applied load.
6. Apply other loads and adjust the reading until a suitable calibration factor is obtained.
7. Note the calibration factor to be used in the Programming step below.

## Programming
1. Open the Program.ino code in Arduino IDE.
2. Modify the value for the calibration_factor variable to the value found in step 7 above.
3. Upload the program onto the Arduino.

<img src="Instructions to Calibrate Grip Sensor and Program Arduino.png" alt="Calibrate and Program" width="\linewidth"/>