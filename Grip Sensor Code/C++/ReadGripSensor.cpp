#include<iostream>
#include<string>
#include<stdlib.h>
#include<windows.h>
#include <fstream>
#include <mutex>
#include <thread>
#include <chrono>
#include"SerialPort.h"
#include "GripSensor.h"

using namespace std;

int main(){
	// Change the port number with the corresponding port number on your computer
	// Must remember that the backslashes are essential so do not remove them
	char *port = "\\\\.\\COM6";
	SerialPort arduino(port);
	GripSensor arduino_reader(arduino);
	
	// Start background thread running readSerial()
	std::thread readThread(&GripSensor::readSerial, &arduino_reader, std::ref(arduino));
	
	// Store measured grip force in csv file
	std::ofstream myfile;
	myfile.open ("Sample_GripSensor_Data.csv");

	while (true) {
		// Measure grip force
		auto dataAndTime = arduino_reader.getSerialData();
		int serialData = dataAndTime.first;
        double elapsed = dataAndTime.second;
		cout << elapsed << "," << serialData << endl;
		myfile << elapsed << "," << serialData << endl;
		
		// Tare grip sensor every 60 seconds
		if (elapsed % 60 <= 0.01){ 
			arduino_reader.tareSensor();
		}
		
		// Shut down recording after 5 minutes
		if (elapsed >= 300.0) { 
            break; // Exit the loop
        }
	}

    myfile.close();
	readThread.join();
	return 0;
}

