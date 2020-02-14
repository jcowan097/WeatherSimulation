clear; close all; clc;

year_length = 364;
day_length = 12;

my_point = [50,90];
%min_lat is the minimum absolute value of the peak or trough of 
%the sunline.  
%max_lat is the absolute point at which the peak and trough mirrors along
%the x axis and the equinox is hit. 
min_lat = 65; 
max_lat = 105;

%Initialize the sunline at the northern summer solstice.
%First row is the Longitude
%Second row is the Latitude
sunline = zeros(2,10);

sunline(:,2) = [0,0];
sunline(:,3) = [40,-min_lat+15];
sunline(:,4) = [90,-min_lat];
sunline(:,5) = [140,-min_lat+15];
sunline(:,6) = [180,0];
sunline(:,7) = [220,min_lat-15];
sunline(:,8) = [270,min_lat];
sunline(:,9) = [320,min_lat-15];
%The first and final sunline point is to simulate a spherical planet and is a copy of the first point. 
sunline(:,1) = [sunline(1,9)-360,sunline(2,9)];
sunline(:,10) = [360+sunline(1,2),sunline(2,2)];

%Set up the 'change_rate'
%Change_rate is a sin curve that dictates how much the sunline changes on
%any given day, where the x axis has 364 points representing a 364 day
%year. The 364 number, rather than a typical 365, is used for
%simplification
x = linspace(0,2*pi,year_length);
change_rates = sin(x);


%Max speed that the initial points will move. This number is derived so
%that the initial points hit exactly the min_lat and max_lat. 
max_latitude_rate = (max_lat-min_lat)/sum(change_rates(1:92));
max_longitude_rate = 35/sum(change_rates(1:92));

%Initialize the lat and lon change rates
latitude_change_rate = 0;
longitude_change_rate = 0;

%'direction' is used to modify the initial points longitudinal movement
%direction. 
direction = 1;


%calculate the suns position for every day in a 364 day year
for day=1:1:year_length
    %calculate the suns position for every hour in a day
    for hour=1:1:day_length
        sunline(1,:)= sunline(1,:)+(360/day_length);
        if sunline(1,9)>=360
            sunline(1,9)=sunline(1,9)-360;
            sunline = [sunline(:,1),circshift(sunline(:,2:9),1,2),sunline(:,10)];
            sunline(:,10) = [360+sunline(1,1),sunline(2,1)];
            sunline(:,1) = [sunline(1,9)-360,sunline(2,9)];
        end
        
        %Interpolate between points on the sunline using the spline method
        interp_object = griddedInterpolant(sunline(1,:),sunline(2,:),'pchip');
        xq = linspace(0,360,720);
        yq = interp_object(xq);
        

        %draw plot
        plot(sunline(1,:),sunline(2,:),'ro');
        hold on
        plot(xq,yq,'.');
        xlim([0 360])
        ylim([-90 90])
        hold off
        pause(0.01);   
    end
    
    if sunline(1,10)>360
        sunline(1,10)=360-sunline(1,10);
        sunline = circshift(sunline,1,2);        
    end
    
 
    latitude_change_rate = change_rates(day)*max_latitude_rate;
    longitude_change_rate = change_rates(day)*max_longitude_rate;
   
    %adjust sunline latitude values
    sunline(2,3:5) = sunline(2,3:5) - latitude_change_rate;
    sunline(2,7:9) = sunline(2,7:9) + latitude_change_rate;
    
    %adjust sunline longitude values
    sunline(1,3) = sunline(1,3) - direction*longitude_change_rate;
    sunline(1,5) = sunline(1,5) + direction*longitude_change_rate;
    
    sunline(1,7) = sunline(1,7) - direction*longitude_change_rate;
    sunline(1,9) = sunline(1,9) + direction*longitude_change_rate;
    
    
    %When at apex of sin curve (being ~1) invert the sunline
    if day == 92 || day ==273 %margin of error being +/- 0.000001
        %invert curve
        sunline(2,3:5) = sunline(2,3:5)*-1;
        sunline(2,7:9) = sunline(2,7:9)*-1;
        %for equality reasons, move again when change_rate = 1;
        sunline(2,3:5) = sunline(2,3:5) - latitude_change_rate;
        sunline(2,7:9) = sunline(2,7:9) + latitude_change_rate;
        
        %reverse travel direction 
        direction=direction*-1;
    end

end



