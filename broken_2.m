
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
threshold = 25; %the value above which the sonar will ignore data %arbitrary
outlier_threshold = 3;
hold_flag_left=0;
hold_flag_right=0;
buffer_count=0;
display_left=0;
display_right=0;
xRecord=1:10;
yRecord=1:10;
thRecord=1:10;

%% Initiate xbee communication

s= serial('COM83', 'BaudRate', 9600,'DataBits',8,'Terminator','CR', 'StopBit', 1, 'Parity', 'None');
set(s,'Timeout',600);
fopen(s);

%% let's draw a pre-determined map! if we want to
% scaled using real-world units (1/2-inch)
figure
%brute force, if nothing better is available
line([3/2 94/2], [3/2 3/2],'Color','b'); %1 
line([94/2 94.5/2], [3/2 35/2],'Color','b'); %2
line([94.5/2 97.5/2], [35/2 35/2],'Color','b'); %3
line([97.5/2 97/2], [35/2 3/2],'Color','b'); %4
line([97/2 189/2], [3/2 3/2],'Color','b'); %5
line([189/2 189/2], [3/2 93/2],'Color','b'); %6 
line([189/2 97/2], [93/2 93/2],'Color','b'); %7 
line([97/2 96.5/2], [93/2 61/2],'Color','b'); %8
line([96.5/2 93.5/2], [61/2 61/2],'Color','b'); %9
line([93.5/2 94/2], [61/2 93/2],'Color','b'); %10
line([94/2 47/2], [93/2 93/2],'Color','b'); %11
line([47/2 45/2], [93/2 31/2],'Color','b'); %12
line([45/2 42/2], [31/2 31/2],'Color','b'); %13
line([42/2 44/2], [31/2 93/2],'Color','b'); %14
line([44/2 3/2], [93/2 93/2],'Color','b'); %15
line([3/2 3/2], [93/2 3/2],'Color','b'); %16

%this might not ultimately be used, if we are going to have the robot
% do a full run to "learn" the map before the showoffy run


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What Follows Could Be Put Into A Loopable (External?) Function:

%% magically, data gets passed in

data=[];
strInd = 1;
while(strInd)

str = fscanf(s);
strInd = strfind(str,'$');

if (strInd ~= 0)
    
str2 = str (strInd(length(strInd))+1:length(str)) ;
s2 = (strsplit(str2,','));

xPos = str2double(char( s2(1)))/100; %x_I
yPos = str2double(char(s2(2)))/100;   % y_I
theta = str2double(char(s2(3)))/100;  %radians
sensorLeft = str2double(char(s2(4)))/100; %whatever units the sensors report back
sensorRight = str2double(char(s2(5)))/100;

%data = [data; xPos,yPos,theta,sensorLeft,sensorRight];


%% establish wall relative to robot

y_wall_left = W_eff + sensorLeft;
y_wall_right = -W_eff - sensorRight;

%if (y_wall_left > threshold) && (y_wall_right < threshold)
%    y_wall_right = -y_wall_left - W_eff*2;
%elseif (y_wall_right > threshold) && (y_wall_left < threshold)
%    y_wall_left = -y_wall_right - W_eff*2;
%elseif (y_wall_right > threshold) && (y_wall_left > threshold)
%    y_wall_right = 100000;
%    y_wall_left = 100000;
%end

%% position magic

%i have no idea what i'm doing but it seems to work alright
pos_adjust = [xPos; yPos];
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
y_temp_right = pos_I_right(2,1)

buffer_left(6)= y_temp_left;
buffer_right(6) = y_temp_right;

for(i=5:1)
    buffer_left(i) = buffer_left(i+1);
    buffer_right(i) = buffer_right(i+1);
end

if(buffer_count<7)
    buffer_count=buffer_count+1;
    display_right=buffer_right(6);
    display_left = buffer_left(6);
end

if(buffer_count>5)
    if((buffer_right(6)>(buffer_right(5) + outlier_threshold))||(buffer_right(6)<(buffer_right(5) - outlier_threshold)))
  %  if((buffer_right(6)>(buffer_right(4) + outlier_threshold))||(buffer_right(6)<(buffer_right(4) - outlier_threshold)))
  %  if((buffer_right(6)>(buffer_right(3) + outlier_threshold))||(buffer_right(6)<(buffer_right(3) - outlier_threshold)))
 %   if((buffer_right(6)>(buffer_right(2) + outlier_threshold))||(buffer_right(6)<(buffer_right(2) - outlier_threshold)))
 %   if((buffer_right(6)>(buffer_right(1) + outlier_threshold))||(buffer_right(6)<(buffer_right(1) - outlier_threshold)))
    display_right=buffer_right(6);
%    end
 %   end
 %   end
 %   end

    end
    
    if((buffer_left(6)<(buffer_left(5) - outlier_threshold))||(buffer_left(6)>(buffer_left(5) + outlier_threshold)))
 %   if((buffer_left(6)<(buffer_left(4) - outlier_threshold))||(buffer_left(5)>(buffer_left(4) + outlier_threshold)))
  %  if((buffer_left(6)<(buffer_left(3) - outlier_threshold))||(buffer_left(5)>(buffer_left(3) + outlier_threshold)))
 %   if((buffer_left(6)<(buffer_left(2) - outlier_threshold))||(buffer_left(5)>(buffer_left(2) + outlier_threshold)))
 %   if((buffer_left(6)<(buffer_left(1) - outlier_threshold))||(buffer_left(5)>(buffer_left(1) + outlier_threshold)))
    display_left=buffer_left(6);
 %   end
 %   end
 %   end
 %   end
    end
    

hold on    % i'm not releasing the hold so we can keep adding to the plot
plot(-display_left+90,x_temp_left+11,'ok','markersize', 2)
plot(-display_right+90,x_temp_right+11,'ok','markersize', 2)
plot(-yPos+90,xPos+11,'.r','markersize', 8)
axis([-20  100 -20 100])   %this will either need to be redefined dynamically
        %or taken out completely   %UNLESS we are also including what we
        %plan to have as the 'predefined' map overlaid. then the overlay
        %will already be roughly the right scale. we will just need to make
        %sure everything is measured equally in the plane
drawnow;
end

xRecord = xPos;%cat(2, xPos, xRecord(1:length(xRecord)-1));
yRecord = yPos;%cat(2, yPos, yRecord(1:length(yRecord)-1));
thRecord = theta;%cat(2, theta, thRecord(1:length(thRecord)-1));
end
hold off
end
fclose(s);

%This Ends Where The Independent Function Should Loop, if we do that.
  %it might just be easier to let the whole thing run a bunch of times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



