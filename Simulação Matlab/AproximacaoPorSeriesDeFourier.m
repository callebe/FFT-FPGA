close all;
clear all;
%Square wave form
duty = 50;
tf = 1;
fs = 1000;
t = 0:tf/fs:1;
f = 5;

x = square(2*pi*f*t,duty);

%% Figure 1
figure;
plot(t,x);
axis([0 tf -2 2]);
ylabel('Aplitude do Sinal');
xlabel('Tempo(s)');
hold;
%Sum of sins
y = 1.286*sin(2*pi*0.05*t*100)+0.4288*sin(2*pi*0.15*t*100)+0.2575*sin(2*pi*0.25*t*100);
plot(t,y);
legend('Onda Quadrada',{'Onda Quadrada','$1.28 e^{j 2\pi50 t}+0.42 e^{j 2\pi15 t} + 0.25e^{j 2\pi25 t}$'},'Interpreter','latex');

%% Figure 2
figure;
plot(t,x);
axis([0 tf -2 2]);
ylabel('Aplitude do Sinal');
xlabel('Tempo(s)');
hold;
%Sum of sins
y = 1.286*sin(2*pi*0.05*t*100);
plot(t,y);
legend('Onda Quadrada',{'Onda Quadrada','$1.28 e^{j 2 \pi 50 t}$'},'Interpreter','latex');

%% Figure 4
figure;
plot(t,x);
axis([0 tf -2 2]);
ylabel('Aplitude do Sinal');
xlabel('Tempo(s)');
hold;
%Sum of sins
y = 1.286*sin(2*pi*0.05*t*100)+0.4288*sin(2*pi*0.15*t*100)+0.2575*sin(2*pi*0.25*t*100)+0.1821*sin(2*pi*0.35*t*100)+0.1416*sin(2*pi*0.45*t*100)+0.1159*sin(2*pi*55*t)+0.09805*sin(2*pi*65*t)+0.08498*sin(2*pi*75*t);
plot(t,y);
legend('Onda Quadrada',{'Onda Quadrada','$\sum^8 a_k e^{jw_k t}$'},'Interpreter','latex');

%FFT
k = fft(x);
P2 = abs(k/(fs*tf));
P1 = P2(1:(fs*tf)/2+1);
P1(2:end-1) = 2*P1(2:end-1);
figure;
f = (0:fs:(tf*fs)*fs/2)/(fs*tf);
stem(f,P1);

%% Figure 5
close all;
clear all;

figure;
%Sum of sins
fs = 100;
t = 0:1/fs:1-1/fs;
x = sin(2*pi*15*t) + sin(2*pi*40*t);
plot(t,x);
xlabel('Tempo (s)')
ylabel('Magnitude do Sinal');

%Figure 6
figure;
y = fft(x);
ly = length(y);
f = (-ly/2:ly/2-1)/ly*fs;
stem(f,abs(fftshift(y)));
xlabel('Frequência (Hz)')
ylabel('Magnitude do Sinal (%)');

%Figure 7
figure;
phs = angle(fftshift(y));
plot(f,phs/pi);
xlabel('Frequência (Hz)')
ylabel('Fase (\pi rad)');

%%Teste
close all;
clear all;
%Square wave form
tf = 1;
fs = 100;
t = 0:tf/fs:tf;
figure;
ylabel('Aplitude do Sinal');
xlabel('Tempo(s)');
%Sum of sins
y = 1.286*sin(2*pi*0.05*t*100);
plot(t,y);
legend('Onda Quadrada',{'Onda Quadrada','$\sum^8 a_k e^{jw_k t}$'},'Interpreter','latex');

FFTY = fft(y);
Mag = abs(fftshift(FFTY))/fs;
Phase = angle(fftshift(FFTY))/pi;
stem([-(tf*fs*fs)/2:fs:(tf*fs*fs)/2],Mag);
plot([-(tf*fs*fs)/2:fs:(tf*fs*fs)/2],Phase);




