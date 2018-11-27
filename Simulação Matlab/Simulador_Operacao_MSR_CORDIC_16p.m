%##########################################################################
%#                         Simulador de Opera��o                      #
%#                           CORDIC MSR 16 Pontos                         #
%#                 IMPLEMENTA��O DO ALGORITMO RADIX-2 PARA            #
%#                       C�LCULO DA FFT EM FPGA                         #
%#                                                                        #
%#   Autor : Callebe Soares Barbosa                                       #
%#   Acad�mico de Engenharia El�trica                                 #
%#   Universidade Tecnol�gica Federal do Paran� - Campus Pato Branco  #
%#   GitHub : https://github.com/callebe                                  #
%##########################################################################

clc
clear all
close all

%%Variaveis
Nfft = 16;
CordicConexions=zeros(Nfft,log2(Nfft));
NumberOfLevels = log2(Nfft);
RAM = zeros(Nfft, NumberOfLevels+1);

%%Input FFT
%Limite de representa��o -32768 : 32768
%Limite de representa��o sem Overflow 2048:2048
f_0 = 3200; %Frequ�ncia de Amostragem
T_0 = 1/f_0;
A = 1012/2;
B = 520/2;
C = 183/2;
fA = 213;
fB = 410;
fC = 1403;
t = [0 :  T_0 : T_0*Nfft-T_0];
y = A*(sin(2*pi*fA*t)) + B*(sin(2*pi*fB*t)) + C*(sin(2*pi*fC*t)) + A + B + C;

%%Obtendo dados MSR
Result = importdata('Result16.mat');
Parametros = importdata('Parametros16.mat');

%%Conex�es (Um Cordic a cada 2 Linhas)
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

%%Simula��o CORDIC MSR
RAMFFT = zeros(Nfft,NumberOfLevels+1);
RAMFFT(:,1) = y;
KL(:,1) = y;
for Level=1:NumberOfLevels-1
    vc = 1;
    for CordicUnit=0:Nfft/2-1
        %Simulador de Opera��o COrdic
        X = RAMFFT(CordicConexions(CordicUnit*2+1,Level)+1,Level);
        Y = RAMFFT(CordicConexions(CordicUnit*2+2,Level)+1,Level);
        RAMFFT(CordicConexions(CordicUnit*2+1,Level)+1,Level+1) = X + Y;
        KL(CordicConexions(CordicUnit*2+1,Level)+1,Level+1)=X+Y;
        KL(CordicConexions(CordicUnit*2+2,Level)+1,Level+1)=X-Y;
        pl(vc,Level+1)=CordicConexions(CordicUnit*2+1,Level);
        vc = vc + 1;
        pl(vc,Level+1)=CordicConexions(CordicUnit*2+2,Level);
        vc = vc + 1;
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
    %Simulador de Opera��o COrdic
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
        end 
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
grid on;
title('Sinal de Entrada Original');
ylabel('Amplitude (p.u.)');
xlabel('Tempos (s)');

%Sinal Original Amostrado
figure;
grid on;
stem(t,y);
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
xlabel('Frequ�ncia (Hz)');

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
xlabel('Frequ�ncia (Hz)');

%Erro entre FFT Implementada e a FFT Simulada
figure;
plot(tx,abs(P1-S));
grid on;
title('Erro de Aproxima��o entre FFTs');
ylabel('|Amplitude| (p.u.)');
xlabel('Frequ�ncia (Hz)');

% Reference = (xi(1)+yi(1)*i)*exp(-2*pi*i*OperatorCordic/Nfft);
% [theta ro] = cart2pol(real(Reference), imag(Reference));
% [thetaf rof] = cart2pol(xi(4), yi(4));
% ErroTheta(CordicUnit+1, Level) = (theta-thetaf);
% Erroro(CordicUnit+1, Level) = (ro-rof);
% ThetaMSR(CordicUnit+1, Level) = thetaf;
% ThetaRef(CordicUnit+1, Level) = theta;


%%Simula��o CORDIC MSR
RAMFF = zeros(Nfft,NumberOfLevels+1);
RAMFF(:,1) = y;
KL(:,1) = y;
for Level=1:NumberOfLevels-1
    CordicConexion(:,Level) = CordicConexions(:,1);
end

for Level=1:NumberOfLevels-1
    vc = 1;
    for CordicUnit=0:Nfft/2-1
        %Simulador de Opera��o COrdic
        X = RAMFF(CordicConexion(CordicUnit*2+1,Level)+1,1);
        Y = RAMFF(CordicConexion(CordicUnit*2+2,Level)+1,1);
        RAMFF(CordicConexion(CordicUnit*2+1,Level)+1,Level+1) = X + Y;
        RAMFFC(CordicUnit*2+1,Level) = X + Y;
        KL(CordicUnit*2+1,Level+1)=X+Y;
        KL(CordicUnit*2+2,Level+1)=X-Y;
        pl(vc,Level+1)=CordicConexion(CordicUnit*2+1,Level);
        vc = vc + 1;
        pl(vc,Level+1)=CordicConexion(CordicUnit*2+2,Level);
        vc = vc + 1;
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
        RAMFF(CordicConexion(CordicUnit*2+2,Level)+1,Level+1) = xi(4)+i*yi(4);
        RAMFFC(CordicUnit*2+2,Level) = xi(4)+i*yi(4);
        RAMFF(CordicConexion(CordicUnit*2+2,Level)+1,Level+1)
        RAMFFC(CordicUnit*2+2,Level)
    end
end