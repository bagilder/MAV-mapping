
% brian gilder did a thing on 30nov, 2dec, 3dec2015
% this will hopefully magically transform into a function that accepts
% sonar data and builds a magnificent map therewith

% this is currently incredibly simple but it works so that's what counts

%% definitions

W = 6.625; %width of robot, in whatever length-units we're using. PLACEHOLDER
sensorDepth = 0;  %distance from side of robot to sensor read plane
W_eff = W/2 + sensorDepth;
x_sensor_left = -1.6;  %dist the sensor is shifted relative to robot center
x_sensor_right = -1.6; %ditto
threshold = 35; %the value above which the sonar will ignore data %arbitrary
thRecord = 0;
%% Initiate xbee communication

s= serial('COM83', 'BaudRate', 9600,'DataBits',8,'Terminator','CR', 'StopBit', 1, 'Parity', 'None');
set(s,'Timeout',600);
fopen(s);

%% let's draw a pre-determined map! if we want to
% scaled using real-world units (1/2-inch)

%brute force, if nothing better is available
%line([3 94], [3 3],'Color','b'); %1 
%line([94 94.5], [3 35],'Color','b'); %2
%line([94.5 97.5], [35 35],'Color','b'); %3
%line([97.5 97], [35 3],'Color','b'); %4
%line([97 189], [3 3],'Color','b'); %5
%line([189 189], [3 93],'Color','b'); %6 
%line([189 97], [93 93],'Color','b'); %7 
%line([97 96.5], [93 61],'Color','b'); %8
%line([96.5 93.5], [61 61],'Color','b'); %9
%line([93.5 94], [61 93],'Color','b'); %10
%line([94 47], [93 93],'Color','b'); %11
%line([47 45], [93 31],'Color','b'); %12
%line([45 42], [31 31],'Color','b'); %13
%line([42 44], [31 93],'Color','b'); %14
%line([44 3], [93 93],'Color','b'); %15
%line([3 3], [93 3],'Color','b'); %16

%this might not ultimately be used, if we are going to have the robot
% do a full run to "learn" the map before the showoffy run


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What Follows Could Be Put Into A Loopable (External?) Function:

%% magically, data gets passed in

while(thRecord~=-255)
    
str = fscanf(s);
strInd = strfind(str,'$');

if (strInd ~= 0)
    
str2 = str (strInd(length(strInd))+1:length(str)) ;
s2 = (strsplit(str2,','));

robot_x_absolute = str2double( char( s2(1)))/100; %x_I
robot_y_absolute = str2double( char(s2(2)))/100;   % y_I
theta = str2double( char(s2(3)))/100;  %radians
sensorDistLeft = str2double( char(s2(4)))/100; %whatever units the sensors report back
sensorDistRight = str2double( char(s2(5)))/100;

if (sensorDistLeft > threshold) && (sensorDistRight < threshold)
    sensorDistLeft = -sensorDistRight - W_eff*2;
elseif (sensorDistRight > threshold) && (sensorDistLeft < threshold)
    sensorDistRight = -sensorDistLeft - W_eff*2;
elseif (sensorDistRight > threshold) && (sensorDistLeft > threshold)
    sensorDistRight = 100000;
    sensorDistLeft = 100000;
end

%% establish wall relative to robot

y_wall_left = W_eff + sensorDistLeft;
y_wall_right = -W_eff - sensorDistRight;

%if we are assuming these to be attached perfectly orthogonal to
%robot movement direction, we only need to worry about y-coordinates

%% position magic

%i have no idea what i'm doing but it seems to work alright
pos_adjust = [robot_x_absolute; robot_y_absolute];
pos_R_left = [x_sensor_left; y_wall_left];
rotation_matrix = [cos(theta), -sin(theta); sin(theta), cos(theta)];
pos_I_left = pos_adjust + rotation_matrix*pos_R_left;
pos_R_right = [x_sensor_right; y_wall_right];
rotation_matrix = [cos(theta), - sin(theta); sin(theta), cos(theta)];
pos_I_right = pos_adjust + rotation_matrix*pos_R_right;

%% i'm the map i'm the map i'm the maaaaaaap

x_temp_left = pos_I_left(1,1);
y_temp_left = pos_I_left(2,1)
x_temp_right = pos_I_right(1,1);
y_temp_right =pos_I_right(2,1)

hold on    % i'm not releasing the hold so we can keep adding to the plot
plot(x_temp_left,y_temp_left,'ok','markersize', 2)
plot(x_temp_right, y_temp_right,'ok','markersize', 2)
plot(robot_x_absolute, robot_y_absolute,'.r','markersize', 8)
axis([-30  220 -75 175])   %this will either need to be redefined dynamically
        %or taken out completely   %UNLESS we are also including what we
        %plan to have as the 'predefined' map overlaid. then the overlay
        %will already be roughly the right scale. we will just need to make
        %sure everything is measured equally in the plane
drawnow;
thRecord = theta;
end
hold off
end
fclose(s);

%This Ends Where The Independent Function Should Loop, if we do that.
  %it might just be easier to let the whole thing run a bunch of times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



