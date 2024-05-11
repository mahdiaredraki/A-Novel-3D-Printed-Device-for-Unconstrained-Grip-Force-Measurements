clear; close all; clc; echo off;

%% User defined
Save_Data=false; 
Plot_Data_in_Real_Time=true; % Set to false to maximize sampling rate.
File_Name="Sample_GripSensor_Data";
Data_Collection_Duration = 60; %in seconds, = Inf for infinite duration
Arduino_Port = 6; % Obtain port number from Arduino IDE e.g "COM6" = 6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%   DO NOT MODIFY CODE BEYOND THIS POINT     %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize Grip Sensor
Grip_Sensor=serialport("COM"+Arduino_Port,9600);
fig = figure('WindowState','minimized');
pause(0.1);
setappdata(fig, 'Grip_force', 0);
Time = datetime('now');
Time = Time.Hour*3600+Time.Minute*60+Time.Second;
setappdata(fig, 'Time', Time);
configureCallback(Grip_Sensor,"byte",10,@(src, event)getData(src, fig))
pause(0.2)

%% Read output from Grip Sensor
h=figure(2);
set(gcf,'Position',[755 396 936 419])
hold on; grid on
ylabel("Grip Force"); xlabel("Time (s)")
yline(0,'linewidth',2,'color','black');
set(gca,'fontsize',25,'fontweight','bold')

Time = [0;0]; Grip_Force = [0;0];
Start_Time =getappdata(fig,'Time');

%% Loop for user specified duration
while Time(end)<Data_Collection_Duration && ishandle(h)
    Grip_Force = [Grip_Force; getappdata(fig,'Grip_Force')];
    Time=[Time; getappdata(fig,'Time')-Start_Time];
    if Plot_Data_in_Real_Time
        plot(Time(end-1:end),Grip_Force(end-1:end),'LineWidth',2,'Marker','o','MarkerFaceColor','blue','color','blue')
        xlim([Time(end)-20 Time(end)+5]);
        title("Grip Force = "+round(Grip_Force(end),2))
        drawnow
        pause(1/80)
    else
        pause(1/30) % Set the sampling rate
    end
end

if ~Plot_Data_in_Real_Time
    plot(Time,Grip_Force,'color','blue','linewidth',2)
end

%% Disconnect Arduino
configureCallback(Grip_Sensor,"off")
clear Grip_Sensor

%% Save Data
if Save_Data
    save(File_Name+".mat",'Grip_Force','Time')
end

%% Local Function
function getData(src, fig)
    O(1) = readline(src);
    O(2) = readline(src);
    Arduino_Output = str2double(extractAfter(O(2),1));
    flush(src)
    Time = datetime('now');
    Time = Time.Hour*3600+Time.Minute*60+Time.Second;
    setappdata(fig,'Grip_Force',Arduino_Output)
    setappdata(fig,'Time',Time)
end

