// GripSensor.h

#ifndef GRIP_SENSOR_H
#define GRIP_SENSOR_H

#include <string>
#include <mutex>
#include <thread>
#include <chrono>
#include "SerialPort.h" // Make sure to include the appropriate SerialPort header

class GripSensor {
public:
    GripSensor(SerialPort& arduino); // Constructor
    std::pair<int, double> getSerialData(); // Method to get the latest serial data
    void readSerial(SerialPort& arduino); // Method that runs in the background thread
	void tareSensor(); // Method to tare the sensor data

private:
    SerialPort& arduino; // Reference to the SerialPort
    int serialData; // Integer to store serial data
	double tareOffset; // Double to store tare offset
    double elapsed; // Double to store elapsed time
    std::mutex mtx; // Mutex for controlling access to shared data
    std::chrono::time_point<std::chrono::high_resolution_clock> programStartTime; // Record program start time
};

#endif // GRIP_SENSOR_H