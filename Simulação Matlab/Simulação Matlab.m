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
T_0 = 10;
A = 30;
B= 40;
C = 23;
fA = 100;
fB = 3500;
fC = 60;
t = [0 : (1/T_0)/(Resolution) : ((1/T_0)-(1/T_0)/(Resolution))];
y = A*(sin(2*pi*fA*t)+1) + B*(sin(2*pi*fB*t)+1) + C*(sin(2*pi*fC*t)+1);

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
clear all
close all
NumeroInteracao = 16;

x(1) = 19.3412;
y(1) = 0;
z(1) = (-2*pi*0/8);
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


%------------------------------------
%  Simulação do FFT
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 8;
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
Xin=zeros(SizeOfFFT,NumberOfLevels+1);

%Definição do Sinal de Entrada
A = 30;
B= 40;
fA = 100;
fB = 3500;

for n = 1: Resolution;
    InputAux(n) = A*sin(2*pi*fA*n*T_s) + B*sin(2*pi*fB*n*T_s);
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

            %Calculo da Multiplicação
            x(1) = real(H);
            y(1) = imag(H);
            z(1) = (-2*pi*CountSizeofDFT/SizeofDFT);
            x(2) = x(1);
            y(2) = y(1);
            z(2) = z(1);

            for Count = 2: NumeroInteracao
                if z(Count) >= 0
                    Half = 1;  
                else
                    Half = -1;
                end
                x(Count+1) = x(Count) - Half*(y(Count)/(2^(Count-2)));
                y(Count+1) = y(Count) + Half*(x(Count)/(2^(Count-2)));
                z(Count+1) = z(Count) - Half*atan(2^(-(Count-2)));

            end

            %Multiplicação por Cos Phi
            x(NumeroInteracao+1) = x(NumeroInteracao+1)/2 + (x(NumeroInteracao+1)/(2^3)) - (x(NumeroInteracao+1)/(2^6));
            y(NumeroInteracao+1) = y(NumeroInteracao+1)/2 + (y(NumeroInteracao+1)/(2^3)) - (y(NumeroInteracao+1)/(2^6));
            
            %Saida do Layer
            %Even
            Xin(Even+1, Layer+2) = G + (x(NumeroInteracao+1)+i*y((NumeroInteracao+1)));
            %Odd
            Xin(Odd+1, Layer+2) =  G - (x(NumeroInteracao+1)+i*y((NumeroInteracao+1)));
            
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

delete(s)
fclose(s)
clear all
close all
