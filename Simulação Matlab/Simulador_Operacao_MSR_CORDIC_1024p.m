%##########################################################################
%#                         Simulador de Operação                          #
%#                         CORDIC MSR 1024 Pontos                         #
%#                 IMPLEMENTAÇÃO DO ALGORITMO RADIX-2 PARA                #
%#                       CÁLCULO DA FFT EM FPGA                           #
%#                                                                        #
%#   Autor : Callebe Soares Barbosa                                       #
%#   Acadêmico de Engenharia Elétrica                                     #
%#   Universidade Tecnológica Federal do Paraná - Campus Pato Branco      #
%#   GitHub : https://github.com/callebe                                  #
%##########################################################################

clc
clear all
close all

%%Variaveis
Nfft = 1024;
CordicConexions=zeros(Nfft,log2(Nfft));
NumberOfLevels = log2(Nfft);
RAM = zeros(Nfft, NumberOfLevels+1);

%%Input FFT
%Limite de representação -32768 : 32768
%Limite de representação sem Overflow 2048:2048
f_0 = 3200; %Frequência de Amostragem
T_0 = 1/f_0;
A = 1012;
B= 520;
C = 183;
fA = 213;
fB = 410;
fC = 1403;
t = [0 :  T_0 : T_0*Nfft-T_0];
y = A*(sin(2*pi*fA*t)) + B*(sin(2*pi*fB*t)) + C*(sin(2*pi*fC*t));

%%Obtendo dados MSR
Result = importdata('Result1024.mat');
Parametros = importdata('Parametros1024.mat');

%%Conexões (Um Cordic a cada 2 Linhas)
for Level=1:NumberOfLevels
    NumberOfBlocks = Nfft/(2^(NumberOfLevels-Level+1));
    LengthDFT = Nfft/(2*NumberOfBlocks);
    Counter = 1;
    for Blocks=1:NumberOfBlocks
        a=LengthDFT*2*(Blocks-1);
        for UnitsOfBlock=1:LengthDFT
            CordicConexions(Counter,Level)=a;
            Counter=Counter+1;
            CordicConexions(Counter,Level)=a+LengthDFT;
            a=a+1;
            Counter=Counter+1;
        end
    end
end

%%Operadores CORDIC
CordicOperators = zeros(Nfft/2, NumberOfLevels-1);
CordicOperators(:,1) = [0:Nfft/2-1];
for Level=1:NumberOfLevels-2
    for CordicUnit=1:Nfft/2
        CordicOperators(CordicUnit,Level+1) = mod(CordicOperators(CordicUnit,Level)*2,(2^(NumberOfLevels-1)));
    end
end

%%Simulação CORDIC MSR
RAMFFT = zeros(Nfft,NumberOfLevels+1);
RAMFFT(:,1) = y;
for Level=1:NumberOfLevels-1
    for CordicUnit=0:Nfft/2-1
        %Simulador de Operação COrdic
        X = RAMFFT(CordicConexions(CordicUnit*2+1,Level)+1,Level);
        Y = RAMFFT(CordicConexions(CordicUnit*2+2,Level)+1,Level);
        RAMFFT(CordicConexions(CordicUnit*2+1,Level)+1,Level+1) = X + Y;
        xi(1) = real(X - Y);
        yi(1) = imag(X - Y);
        for a=1:3
            b=Result(CordicOperators(CordicUnit+1,Level)+1, a);
            switch Parametros(b,1)
                case 0
                    xi(a+1) = -Parametros(b,2)*fix(yi(a)*2^-Parametros(b,5))-Parametros(b,3)*fix(yi(a)*2^-Parametros(b,6))-Parametros(b,4)*fix(yi(a)*2^-Parametros(b,7));
                    yi(a+1) =  Parametros(b,2)*fix(xi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(xi(a)*2^-Parametros(b,6))+Parametros(b,4)*fix(xi(a)*2^-Parametros(b,7));
                case 1
                    xi(a+1) =  Parametros(b,2)*fix(xi(a)*2^-Parametros(b,5))-Parametros(b,3)*fix(yi(a)*2^-Parametros(b,6))-Parametros(b,4)*fix(yi(a)*2^-Parametros(b,7));
                    yi(a+1) =  Parametros(b,2)*fix(yi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(xi(a)*2^-Parametros(b,6))+Parametros(b,4)*fix(xi(a)*2^-Parametros(b,7));
                case 2
                    xi(a+1) =  Parametros(b,2)*fix(xi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(xi(a)*2^-Parametros(b,6))-Parametros(b,4)*fix(yi(a)*2^-Parametros(b,7));
                    yi(a+1) =  Parametros(b,2)*fix(yi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(yi(a)*2^-Parametros(b,6))+Parametros(b,4)*fix(xi(a)*2^-Parametros(b,7));
                otherwise
                    xi(a+1) =  Parametros(b,2)*fix(xi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(xi(a)*2^-Parametros(b,6))+Parametros(b,4)*fix(xi(a)*2^-Parametros(b,7));
                    yi(a+1) =  Parametros(b,2)*fix(yi(a)*2^-Parametros(b,5))+Parametros(b,3)*fix(yi(a)*2^-Parametros(b,6))+Parametros(b,4)*fix(yi(a)*2^-Parametros(b,7));
            end
        end
        RAMFFT(CordicConexions(CordicUnit*2+2,Level)+1,Level+1) = xi(4)+i*yi(4);
    end
end

% Ultima Nivel
for CordicUnit=0:Nfft/2-1
    %Simulador de Operação COrdic
    X = RAMFFT(CordicConexions(CordicUnit*2+1,NumberOfLevels)+1,NumberOfLevels);
    Y = RAMFFT(CordicConexions(CordicUnit*2+2,NumberOfLevels)+1,NumberOfLevels);
    RAMFFT(CordicConexions(CordicUnit*2+1,NumberOfLevels)+1,NumberOfLevels+1) = X + Y;
    RAMFFT(CordicConexions(CordicUnit*2+2,NumberOfLevels)+1,NumberOfLevels+1) = X - Y;
end

% Bit-Reverse
AuxVector = zeros(1,NumberOfLevels);
for n = 0: Nfft-1;
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
    Saida(n+1) = RAMFFT(bi2de(AuxVector)+1,Level+2);
end

%%Plots

%Sinal Original
figure;
x = [0 : 1/10000 : (T_0*Nfft)-1/10000];
z = A*(sin(2*pi*fA*x)) + B*(sin(2*pi*fB*x)) + C*(sin(2*pi*fC*x));
plot(x, z);
axis([0,0.32,-1800,1800]);
grid on;
title('Sinal de Entrada Original');
ylabel('Amplitude (p.u.)');
xlabel('Tempos (s)');

%Sinal Original Amostrado
figure;
grid on;
stem(t,y);
axis([0,0.32,-1800,1800]);
grid on;
title('Sinal de Entrada Amostrado');
ylabel('Amplitude (p.u.)');
xlabel('Tempos (s)');

%FFT Calculada
figure;
grid on;
S = fix(abs(fix(Saida(1:Nfft/2+1)/Nfft)));
S(2:end-1) = 2*S(2:end-1);
tx = f_0*[0 : (Nfft)/2]/Nfft;
stem(tx,S);
grid on;
title('FFT Implementada');
ylabel('|Amplitude| (p.u.)');
xlabel('Frequência (Hz)');

%FFT MATLAB
figure;
P2 = abs(fft(y)/Nfft);
P1 = P2(1:Nfft/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = f_0*(0:(Nfft/2))/Nfft;
stem(f,P1);
grid on;
title('FFT Matlab');
ylabel('|Amplitude| (p.u.)');
xlabel('Frequência (Hz)');

%Erro entre FFT Implementada e a FFT Simulada
figure;
plot(tx,abs(P1-S));
grid on;
title('Erro de Aproximação entre FFTs');
ylabel('|Amplitude| (p.u.)');
xlabel('Frequência (Hz)');