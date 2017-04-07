%##########################################################################
%#                             Simulação TCC                              #
%#                                                                        #
%#                 IMPLEMENTAÇÃO DO ALGORITMO RADIX-2 PARA                #
%#                       CÁLCULO DA FFT EM FPGA                           #
%#                                                                        #
%#   Autor : Callebe Soares Barbosa                                       #
%#   Acadêmico de Engenharia Elétrica                                     #
%#   Universidade Tecnológica Federal do Paraná - Campus Pato Branco      #
%#   GitHub : https://github.com/callebe                                  #
%##########################################################################

%------------------------------------
%  Interface Serial UART 
%  Baud Rate : 9600
%------------------------------------

SizeOfFFT = 8;

s = serial('COM10');%get(instrfind, 'Port'));
set(s,'BaudRate',9600);
fopen(s);

Resolution = 8;
FundamentaFrequency = 10;
A = 30;
B= 40;
C = 23;
fA = 100;
fB = 3500;
fC = 60;
t = [0 : (1/FundamentaFrequency)/(Resolution) : ((1/FundamentaFrequency)-(1/FundamentaFrequency)/(Resolution))];
y = A*(sin(2*pi*fA*t)+1) + B*(sin(2*pi*fB*t)+1) + C*(sin(2*pi*fC*t)+1);

k = [0 : 1 : (SizeOfFFT/2-1)];
W = exp(-k*i*2*pi/SizeOfFFT)*2^10;
plot(t,y);

clear Aux;
clear AuxB;
clear ResultOfFFT;

for Count = 1: SizeOfFFT
    fwrite(s,y(Count),'int32');
    fwrite(s,0,'int32');
end 

for Count = 1 : SizeOfFFT
    Aux(Count) = fread(s,1,'int32');
    AuxB(Count) = fread(s,1,'int32');
    ResultOfFFT(Count) = Aux(Count) + i*AuxB(Count);
end


%------------------------------------
%  Simulação do Algoritmo CORDIC
%------------------------------------

NumeroInteracao = 16;

x(1) = -10900;
y(1) = 233;
z(1) = (-2*pi/8);
x(2) = x(1);
y(2) = y(1);
z(2) = z(1);

for Count = 2: NumeroInteracao
    if z(Count) >= 0
        H = 1;  
    else
        H = -1;
    end
    x(Count+1) = x(Count) - H*(y(Count)/(2^(Count-2)));
    y(Count+1) = y(Count) + H*(x(Count)/(2^(Count-2)));
    z(Count+1) = z(Count) - H*atan(2^(-(Count-2)));
    
end

%Multiplicação por Cos Phi
x(NumeroInteracao+1) = x(NumeroInteracao+1)/2 + (x(NumeroInteracao+1)/(2^3)) - (x(NumeroInteracao+1)/(2^6));
y(NumeroInteracao+1) = y(NumeroInteracao+1)/2 + (y(NumeroInteracao+1)/(2^3)) - (y(NumeroInteracao+1)/(2^6));

%Transforma em Modulo e Angulo
r1 = abs(x(1)+i*y(1));
O1 = 180/pi*atan(y(1)/x(1)); 
r2 = abs(x(NumeroInteracao+1)+i*y(NumeroInteracao+1));
O2 = 180/pi*atan(y(NumeroInteracao+1)/x(NumeroInteracao+1)); 

fclose(s)
delete(s)
clear all
