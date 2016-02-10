%% Plucked String Waveguide .
[x,SFs] = audioread('Taylor314ce.wav');

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
Pu = 0.7;
NPu = floor(N * Pu);
% LPF Coeff 
a = 0.995;
% APF coeff 
g = 0;

% init left and right delays with triangle input, centre at pluck pos
% [yl,yr,in] = deal([[0:NPp]/NPp,(N-[(NPp+1):N])/(N-NPp)]);
[yl,yr,in] = deal(conv([[0:NPp]/NPp,(N-[(NPp+1):N])/(N-NPp)],x,'same'));

% init output
y = yl(NPu) + yr(NPu);

% set ups for while loop / amp estimation params
v = true;
i = 1;
windowSize = 1024;
thresh = 0.001;

% vector of previous values (X, XLowPassed, XAllpassed)
prevR = [0 0 0];
prevL = [0 0 0];

while v
        
    % Take nodal values (bridge and nut) and LPF
    LPFR = (a*yr(end)) + (a*prevR(1));
    LPFL = (a*yl(1)) + (a*prevL(1));   
      
    % LPF ---> APF 
    APFR =   -g*LPFR + prevR(2) + g*prevR(3); 
    APFL =  -g*LPFL + prevL(2) + g*prevL(3); 
   
    % Save previous values and APF Out
    prevR = [yr(end) LPFR APFR];
    prevL = [yl(1) LPFL APFL];
           
    % shift wave left or right
    yr = circshift(yr,[0 1]);
    yl = circshift(yl,[0 -1]); 
    
    % overwrite start of each direction with lpf/apf values (negative for
    % phase)
    yr(1) = -LPFL/2;
    yl(end) = -APFL/2;
    
    % read wave at pickup position
    y = [y (yl(NPu) + yr(NPu))*0.5];
    
if i > windowSize
   amp = mean(abs(y(i-windowSize:i)))
   if amp < thresh;
    v = false;   
   end
end
i = i+1;
end

figure;
subplot(2,1,1);
plot(in);
title('Input - Triangle convolved with body IR');
xlabel('Time');
ylabel('Amp');
subplot(2,1,2);
plot(y);
title('Output');
xlabel('Time');
ylabel('Amp');

soundsc(y,Fs);