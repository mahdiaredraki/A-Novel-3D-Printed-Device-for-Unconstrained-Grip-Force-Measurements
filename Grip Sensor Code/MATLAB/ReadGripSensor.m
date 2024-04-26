clear all; close all; clc; echo off;

%% User defined
save_data=1;
plot_data_in_real_Time=0;
FileName="Sample_GripSensor_Data";
Data_Collection_Duration = 60; %in seconds, = Inf for infinite duration
ARDUINO=serialport("COM6",9600);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%   DO NOT MODIFY CODE BEYOND THIS POINT     %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize Grip Sensor
fig = figure;
setappdata(fig, 'output', 0);
setappdata(fig, 'time_now', now);
configureCallback(ARDUINO,"byte",10,@(src, event)getData(src, fig))

%% Read output from Grip Sensor
FIG=figure(2);
set(gcf,'Position',[482 230 1392 601])
hold on
grid on
title("Grip Sensor")
ylabel("Force (N)")
xlabel("Time (s)")
yline(0,'linewidth',2,'color','black');
set(gca,'fontsize',25,'fontweight','bold')

Continuous_Time = [];
Grip_Sensor_Output = [];
Start_Time =getappdata(fig,'time_now');

while Continuous_Time(end)<Data_Collection_Duration
    Grip_Sensor_Output = [Grip_Sensor_Output; getappdata(fig,'output')];
    Continuous_Time=[Continuous_Time; getappdata(fig,'time_now')-Start_Time];
    if plot_data_in_real_Time==1
        scatter(Continuous_Time,Grip_Sensor_Output,100,'blue','filled')
        xlim([Continuous_Time(end)-20 Continuous_Time(end)+5]);
        drawnow
    else
        pause(1/30) % Set the sampling rate
    end
end

if plot_data_in_real_Time==0
    plot(Continuous_Time,Grip_Sensor_Output,'color','blue','linewidth',2)
end

%% Disconnect Arduino
configureCallback(ARDUINO,"off")
clear ARDUINO

%% Save Data
if save_data == 1
    save(FileName+".mat",'Grip_Sensor_Output','Continuous_Time')
end

%% Local Function
function getData(src, fig)
    O(1) = readline(src);
    O(2) = readline(src);
    Output = str2double(extractAfter(O(2),1));
    flush(src)
    Time = datetime('now');
    Time = Time.Hour*3600+Time.Minute*60+Time.Second;
    setappdata(fig,'output',Output)
    setappdata(fig,'time_now',Time)
end

