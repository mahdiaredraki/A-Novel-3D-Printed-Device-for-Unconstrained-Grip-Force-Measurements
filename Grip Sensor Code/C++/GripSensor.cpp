// GripSensor.cpp

#include "GripSensor.h" // Include the GripSensor header
#include <iostream>
#include <string>
#include <windows.h>
#include <fstream>
#include "SerialPort.h" // Include the appropriate SerialPort implementation

GripSensor::GripSensor(SerialPort& arduino) : arduino(arduino) {

    if (arduino.isConnected()) {
        std::cout << "Connection to Grip Sensor Successful" << std::endl;
    } else {
        std::cout << "Could not connect to Grip Sensor - Check port name" << std::endl;
    }
    programStartTime = std::chrono::high_resolution_clock::now(); // Record program start time
	tareOffset = 0.0; // Initialize tare offset to zero
}

std::pair<int, double> GripSensor::getSerialData() {
    std::lock_guard<std::mutex> lock(mtx); // Lock the mutex for safe access to shared data
    return std::make_pair(serialData, elapsed); // Return serial data and elapsed time as a pair
}

void GripSensor::readSerial(SerialPort& arduino) {
    int count = 0;
    int index1 = 0, index2 = 0;
    char output[MAX_DATA_LENGTH];
    unsigned int bufferSize = 0;

    while (arduino.isConnected()) {
        bufferSize = arduino.bufferSize();
        if (bufferSize > 25) {
            arduino.readSerialPort(output, MAX_DATA_LENGTH); // Read from the serial port
            char* p = output;
            count = 0;
            while (*p != '\0') {
                if (*p == 'N') {
                    count++;
                    if (count == 1) {
                        index1 = p - output;
                    }
                    if (count == 2) {
                        index2 = p - output;
                        break;
                    }
                }
                p++;
            }
            index2--;
            if (index1 >= 0 && index2 > index1) {
                int length = index2 - index1 - 1;
                std::lock_guard<std::mutex> lock(mtx); // Lock the mutex for safe data update
                serialData = std::stod(std::string(output + index1 + 1, length)); // Convert to int and store
				serialData -= tareOffset; // Apply tare offset to the reading
            } else {
                std::cout << "invalid indexes" << std::endl;
            }
        }

        auto currentTime = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsedSeconds = currentTime - programStartTime;
        elapsed = elapsedSeconds.count();
        std::this_thread::sleep_for(std::chrono::milliseconds(10)); // Sleep before the next read
    }
}

// Tare the sensor data by capturing the current reading as the offset
void GripSensor::tareSensor() {
    std::lock_guard<std::mutex> lock(mtx); // Lock the mutex for safe data update
    tareOffset += serialData; // Set the tare offset based on the current data
	std::cout << "Grip Sensor tared." << std::endl;
}