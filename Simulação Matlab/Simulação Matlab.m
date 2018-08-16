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

SizeOfFFT = 32;

s = serial('COM4');%get(instrfind, 'Port'));
set(s,'BaudRate',9600);
fopen(s);

Resolution = SizeOfFFT;
T_0 = 10;
A = 30;
B= 40;
C = 23;
fA = 100;
fB = 3500;
fC = 60;
t = [0 : (1/T_0)/(Resolution) : ((1/T_0)-(1/T_0)/(Resolution))];
y = A*(sin(2*pi*fA*t)) + B*(sin(2*pi*fB*t)) + C*(sin(2*pi*fC*t));

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

delete(s)
fclose(s)
clear all
close all

%------------------------------------
%  Simulação do Algoritmo CORDIC
%------------------------------------
clear all
close all
NumeroInteracao = 6;

H = 10+10*i;
alpha = (-2*pi*3/8)*2^10;

if(alpha < -pi/2)
    x(1) = (imag(H)/2 + imag(H)/(2^3) - imag(H)/(2^6) - imag(H)/(2^9));
    y(1) = -(real(H)/2 + real(H)/(2^3) - real(H)/(2^6) - real(H)/(2^9));
    z(1) =  alpha + pi/2*2^10;

else
    x(1) = (real(H)/2 + real(H)/(2^3) - real(H)/(2^6) - real(H)/(2^9));
    y(1) = (imag(H)/2 + imag(H)/(2^3) - imag(H)/(2^6) - imag(H)/(2^9));
    z(1) =  alpha;
end

for Count = 0: (NumeroInteracao-1)
    if z(Count+1) >= 0
        Half = 1;  
    else
        Half = -1;
    end
    x(Count+2) = x(Count+1) - Half*(y(Count+1)/(2^Count));
    y(Count+2) = y(Count+1) + Half*(x(Count+1)/(2^Count));
    z(Count+2) = z(Count+1) - Half*atan(2^-Count)*2^10;
    
end

%Transforma em Modulo e Angulo
r1 = abs(H);
O1 = 180/pi*atan(imag(H)/real(H)); 
r2 = abs(x(NumeroInteracao+1)+i*y(NumeroInteracao+1));
O2 = 180/pi*atan(y(NumeroInteracao+1)/x(NumeroInteracao+1)); 


%------------------------------------
%  Simulação do FFT
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 2048;
%Numero de Interações Cordic
NumeroInteracao = 8;
%Definição do Numero de Layers do FFT
NumberOfLevels = log2(SizeOfFFT);
%Definição da Resolução
Resolution = SizeOfFFT;
%Definição da Frequencia Fundamental
f_0 = 10; % Hertz
%Definição da Frêquencia Fundamental
T_0 = 1/f_0; %Segundos
%Definição da Frequência de Amostragem
f_s = f_0*SizeOfFFT;
%Definição do Periodo de Amostragem
T_s = 1/f_s
%Definição da Matriz de Resultados
Xin = zeros(SizeOfFFT,NumberOfLevels+1);
erroY = zeros(1,SizeOfFFT*NumberOfLevels);
erroX = zeros(1,SizeOfFFT*NumberOfLevels);
erroComp = zeros(1,SizeOfFFT*NumberOfLevels);
erroXr = zeros(1,SizeOfFFT*NumberOfLevels);

%Definição do Sinal de Entrada
A = 30;
B= 4000;
C=300;
fA = 10;
fB = 3000;
fC = 250;

for n = 1: Resolution;
    InputAux(n) = A*sin(2*pi*fA*n*T_s) + B*sin(2*pi*fB*n*T_s) + C*sin(2*pi*fC*n*T_s);
    Input(n) = InputAux(n);
end


%Inicio do Algoritmo da FFT

%Processo de Bit-Reverse
AuxVector = zeros(1,NumberOfLevels);

for n = 0: (SizeOfFFT-1);
    Count = NumberOfLevels-1;
    Aux = n;
    for k = 1 :  NumberOfLevels
        if (Aux/2^Count >= 1)
            AuxVector(k) = 1;
        else
            AuxVector(k) = 0;
        end; 
        Aux = rem(Aux, 2^Count);
        Count = Count - 1;
    end
    Xin(n+1) = InputAux(bi2de(AuxVector)+1);
end

Countest = 1;
%Building the Layers
for Layer = 0 : (NumberOfLevels-1)
    
    SizeofDFT = (2^(Layer+1));
    NumberOfDFT = SizeOfFFT/SizeofDFT;
    
    %Building the DFTs
    for CountDFT = 0 :(NumberOfDFT-1) 
        
        Even = (CountDFT)*SizeofDFT;
    
        %Building the DFT
        for CountSizeofDFT = 0 : (SizeofDFT/2-1)
            
            Odd = Even + SizeofDFT/2;
            
            %Entrada do Layer
            %Even
            G = Xin(Even+1, Layer+1);
            %Odd
            H = Xin(Odd+1, Layer+1);

            %Calculo da Multiplicação pelo Algoritmo Cordic
            alpha = -2*pi*CountSizeofDFT/SizeofDFT*2^10;

            if(alpha < -pi/2)
                x(1) = (imag(H)/2 + imag(H)/(2^3) - imag(H)/(2^6) - imag(H)/(2^9));
                y(1) = -(real(H)/2 + real(H)/(2^3) - real(H)/(2^6) - real(H)/(2^9));
                z(1) =  alpha + pi/2*2^10;

            else
                x(1) = (real(H)/2 + real(H)/(2^3) - real(H)/(2^6) - real(H)/(2^9));
                y(1) = (imag(H)/2 + imag(H)/(2^3) - imag(H)/(2^6) - imag(H)/(2^9));
                z(1) =  alpha;
            end

            for Count = 0: (NumeroInteracao-1)
                if z(Count+1) >= 0
                    x(Count+2) = x(Count+1) - (y(Count+1)/(2^Count));
                    y(Count+2) = y(Count+1) + (x(Count+1)/(2^Count));
                    z(Count+2) = z(Count+1) - atan(2^-Count)*2^10;
                else
                    x(Count+2) = x(Count+1) + (y(Count+1)/(2^Count));
                    y(Count+2) = y(Count+1) - (x(Count+1)/(2^Count));
                    z(Count+2) = z(Count+1) + atan(2^-Count)*2^10;
                end
                

            end
            
            %Saida do Layer
            %Even
            Xin(Even+1, Layer+2) = G + (x(NumeroInteracao+1)+i*y((NumeroInteracao+1)));
            %Odd
            Xin(Odd+1, Layer+2) =  G - (x(NumeroInteracao+1)+i*y((NumeroInteracao+1)));
            
            erroY(Countest) = abs((Xin(Even+1, Layer+2)) - (G + H*exp(-2*pi*CountSizeofDFT/SizeofDFT*i)));
            erroX(Countest) = Even + Layer*SizeOfFFT;
            Countest = Countest +1;
            erroY(Countest) = abs((Xin(Odd+1, Layer+2)) - (G - H*exp(-2*pi*CountSizeofDFT/SizeofDFT*i)));
            erroX(Countest) = Odd + Layer*SizeOfFFT;
            Countest = Countest +1;
            Even = Even + 1;
            
        end
        
    end 
    
end

%Pega o Resultado
for CountFFT = 1 : SizeOfFFT
    
    ModXr(CountFFT) = Xin(CountFFT, NumberOfLevels+1);
    
end

%Modulo da FFT
ModXr = abs(ModXr/SizeOfFFT);
%Pega apenas a metade do Spectro
Xr =  ModXr(1:SizeOfFFT/2+1);
%Compenso os modulos
Xr(2:end-1) = 2*Xr(2:end-1);
%Plot da FFT
figure;
stem((0 : SizeOfFFT/2)*f_s/(SizeOfFFT), Xr);

%FFT via Matlab
Y = fft(Input);
%Modulo da FFT
Y2 = abs(Y/SizeOfFFT);
%Pego apenas metade do Spectro
Y1 = Y2(1:SizeOfFFT/2+1);
%Compenso os modulos
Y1(2:end-1) = 2*Y1(2:end-1);
%Plot da FFT
figure;
stem((0 : SizeOfFFT/2)*f_s/(SizeOfFFT),Y1);

%Plot do sinal original
figure;
plot((0 : SizeOfFFT-1)*T_0/(SizeOfFFT),Input);


%Plot do Erro de Aproximação entre Cordic e o Tradicional - Layer 1
figure;
title('Erro de Aproximação Entre Cordic e o Cálculo Tradicional');
stem((erroX),(erroY/SizeOfFFT));
ylabel('Modulo do Erro');
xlabel('Layers');

delete(s)
fclose(s)
clear all
close all
