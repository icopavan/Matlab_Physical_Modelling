%% Plucked String Waveguide .
% Sample Rate
Fs = 44100;
% String Freq
Fc = 432;
%  delay line length
N = floor((Fs/Fc)/2);
% Pluck Pos
Pp = 0.1;
NPp = floor(N * Pp);
% PickUp Pos
Pu = 0.5;
NPu = floor(N * Pu);
% LPF Coeff 
a = 0.6;
% APF coeff 
g = 0.9;

% init left and right delays with triangle input, centre at pluck pos
Ex = [[0:NPp]/NPp,(N-[(NPp+1):N])/(N-NPp)];
Ex = Ex.*(rand(1,length(Ex)));
Ex = Ex - mean(Ex);

[yl yr] = deal(Ex);;

% init output
y = (yl(NPu) + yr(NPu));

% set ups for while loop / amp estimation params
v = true;
i = 1;
windowSize = 1024;
thresh = 0.01;

% vector of previous values (X, XLowPassed, XAllpassed)
prevR = [0 0 0];
prevL = [0 0 0];

while v
        
    % Take nodal values (bridge and nut) and LPF
    LPFR = ((a*yr(end)) + (1-a)*prevR(1));
    LPFL = ((a*yl(1)) + (1-a)*prevL(1));   
      
    % LPF ---> APF 
    APFR =   (-g*LPFR + prevR(2) + g*prevR(3)); 
    APFL =  (-g*LPFL + prevL(2) + g*prevL(3)); 
      
    
    % Save previous values and APF Out
    prevR = [yr(end) LPFR APFR];
    prevL = [yl(1) LPFL APFL];
           
    % shift wave left or right
    yr = circshift(yr,[0 1]);
    yl = circshift(yl,[0 -1]); 
    
    % overwrite start of each direction with lpf/apf values (negative for
    % phase)
    yr(1) = -APFL;
    yl(end) = -APFR;
    
    % read wave at pickup position
    y = [y (yl(NPu) + yr(NPu))];
    
if i > windowSize
   amp = mean(abs(y(i-windowSize:i)))
   if amp < thresh;
    v = false;   
   end
end

i = i+1;
end

soundsc(y,Fs);

figure;
subplot(2,1,1);
plot(Ex);
title('Input');
xlabel('Time');
ylabel('Amp');
subplot(2,1,2);
plot(y);
title('Output');
xlabel('Time');
ylabel('Amp');