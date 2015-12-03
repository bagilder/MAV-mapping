
% brian gilder did a thing on 30nov, 2dec, 3dec2015
% this will hopefully magically transform into a function that accepts
% sonar data and builds a magnificent map therewith

% this is currently incredibly simple but it works so that's what counts

%% definitions

W = 14; %width of robot, in whatever length-units we're using. PLACEHOLDER
sensorDepth = -2;  %distance from side of robot to sensor read plane
W_eff = W/2 + sensorDepth;
x_sensor_left = -8;  %dist the sensor is shifted relative to robot center
x_sensor_right = -8; %ditto

%% let's draw a pre-determined map! if we want to
% scaled using real-world units (1/2-inch)

%brute force, if nothing better is available
line([3 94], [3 3],'Color','b'); %1 
line([94 94.5], [3 35],'Color','b'); %2
line([94.5 97.5], [35 35],'Color','b'); %3
line([97.5 97], [35 3],'Color','b'); %4
line([97 189], [3 3],'Color','b'); %5
line([189 189], [3 93],'Color','b'); %6 
line([189 97], [93 93],'Color','b'); %7 
line([97 96.5], [93 61],'Color','b'); %8
line([96.5 93.5], [61 61],'Color','b'); %9
line([93.5 94], [61 93],'Color','b'); %10
line([94 47], [93 93],'Color','b'); %11
line([47 45], [93 31],'Color','b'); %12
line([45 42], [31 31],'Color','b'); %13
line([42 44], [31 93],'Color','b'); %14
line([44 3], [93 93],'Color','b'); %15
line([3 3], [93 3],'Color','b'); %16



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What Follows Could Be Put Into A Loopable (External?) Function:

%% magically, data gets passed in

% data get, somehow

% variables are assigned values from data. currently placeholders

% %x_R_origin = sdfkj; %probably already the next thing
% %y_R_origin = sdf;    %probably already the next thing
robot_x_absolute = 175; %we get sent these, right? x_I
robot_y_absolute = 16;   % y_I
theta = (92)*pi/180;   %radians, if the angle is given in (degrees)
sensorDistLeft = 72; %whatever units the sensors report back
sensorDistRight = 8;

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

%once more, discretely. just for shiggles. idk if this currently works.
%x_I_left = robot_x_absolute + cos(theta)*x_sensor_left - sin(theta)*y_wall_left; % + x_R_origin? %or maybe + robot_x_absolute?
%y_I_left = robot_y_absolute + sin(theta)*x_sensor_left + cos(theta)*y_wall_left; % + y_R_origin? %ditto?
%x_I_right = robot_x_absolute + cos(theta)*x_sensor_right - sin(theta)*y_wall_right;
%y_I_right = robot_y_absolute + sin(theta)*x_sensor_right + cos(theta)*y_wall_right;

%% now something wonderful happens! i just need to figure out what that is

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

%This Ends Where The Independent Function Should Loop, if we do that.
  %it might just be easier to let the whole thing run a bunch of times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%something else should probably come next but idk what that would be

















hopeful_plea = ['NASA is seriously the coolest place   ';
                'I could ever dream to work for.       ';
                'Please hire Brian Gilder. He is great.']

