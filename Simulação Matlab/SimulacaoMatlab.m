%##########################################################################
%#                             Simulacao TCC                              #
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
% 
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
%  Simulacao do Algoritmo CORDIC
%------------------------------------
clear all
close all
NumeroInteracao = 20;

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
%  Simulacao do FFT
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 1024;
%Numero de Interações Cordic
NumeroInteracao = 16;
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
A = 120;
B= 15;
C=50;
D=8;
E=70;
fA = 10;
fB = 3000;
fC = 250;
fD = 4000;
fE = 2780;

for n = 1: Resolution;
    InputAux(n) = A*sin(2*pi*fA*n*T_s) + B*sin(2*pi*fB*n*T_s) + C*sin(2*pi*fC*n*T_s) + D*sin(2*pi*fD*n*T_s) + E*sin(2*pi*fE*n*T_s);
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

            if(alpha <= -pi/2)
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
ylabel('Amplitude');
xlabel('Frequência (H)');
title('FFT Implementada');

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
ylabel('Amplitude');
xlabel('Frequência (H)');
title('FFT Tradicional');

%Plot do sinal original
figure;
plot((0 : SizeOfFFT-1)*T_0/(SizeOfFFT),Input);
ylabel('Amplitude');
xlabel('Tempo (s)');
title('Sinal de Entrada da FFT');

%Plot do Erro de Aproximação entre Cordic e o Tradicional - Layer 1
figure;
plot([0:(10/10240):10-(10/10240)],smooth((erroY/SizeOfFFT)));
ylabel('Modulo do Erro');
xlabel('Níveis da FFT');
title('Erro de Aproximação Entre Cordic e o Cálculo Tradicional');

% delete(s)
% fclose(s)
% clear all
% close all

%------------------------------------
%  Simulacao do TBS
%------------------------------------

clc
clear all
close all

NumberOfS = 2; %Numero de SPT(Signal Power of Two), ou s's, em Sum tan^-1 [a0j*2^-s0j + a1j*2^-s1j]
W = 3; %word-length de Theta
N = W;
Rm = 4; %Numero máximo de interações CORDIC
TargetAngle = pi/3; % Angulo de Rotação

%Criação do vetor S_{NumberOfS}

alpha = zeros(6,2);
alpha(1:3,:) = combnk([-1:1],2);
alpha(4:6,:) = [-1:1 ; -1:1]';

S2 = zeros((factorial(N)/(factorial(N-NumberOfS)*factorial(NumberOfS)))+N,2);
S2(1:(factorial(N)/(factorial(N-NumberOfS)*factorial(NumberOfS))),:) = combnk([0:N-1],2);
S2(((factorial(N)/(factorial(N-NumberOfS)*factorial(NumberOfS)))+1):end,:) = [0:(N-1) ; 0:(N-1)]';

r = ones(length(alpha)*length(S2),1)*inf;
i = 1;

for cont=1:length(r)
    rRef(cont).counter = 1;
    rRef(cont).Alpha1 = inf*ones(1,1);
    rRef(cont).S1 = inf*ones(1,1);
    rRef(cont).Alpha2 = inf*ones(1,1);
    rRef(cont).S2 = inf*ones(1,1);
end 

for cont=1:length(alpha)
   for conte=1:length(S2)
       aux = atan(alpha(cont,1)*2^-S2(conte,1)+alpha(cont,2)*2^-S2(conte,2));
       equal=0;
       for x=1:length(r)
           if(r(x) == aux)
               rRef(x).Alpha1(rRef(x).counter) = alpha(cont,1);
               rRef(x).Alpha2(rRef(x).counter) = alpha(cont,2);
               rRef(x).S1(rRef(x).counter) = S2(conte,1);
               rRef(x).S2(rRef(x).counter) = S2(conte,2);
               rRef(x).counter =  rRef(x).counter + 1;
               equal=1;
           end
       end
       if(equal == 0)
            r(i) = aux;
            rRef(i).Alpha1(rRef(i).counter) = alpha(cont,1);
            rRef(i).Alpha2(rRef(i).counter) = alpha(cont,2);
            rRef(i).S1(rRef(i).counter) = S2(conte,1);
            rRef(i).S2(rRef(i).counter) = S2(conte,2);
            rRef(i).counter =  rRef(i).counter + 1;
            i = i +1;
       end
   end
end

R = r(1:(i-1));

Phi = Inf*ones((i-1),Rm);
PhiRef = Inf*ones((i-1),Rm);

Phi(:,1) = R;


for count=1: (Rm-1)
    
    for counte=1:(i-1)
        
        [v,k] = min(abs(Phi(:,count)+R(counte)-TargetAngle));
        Phi(counte,count+1)=Phi(k,count)+R(counte);
        PhiRef(counte,count+1) = k;
        
    end
    
end

[v,k] = min(abs(Phi(:,Rm)-TargetAngle));
vetResult = zeros(Rm,1);
VetResult(Rm) = k;

for count=Rm:-1: 2
    
    k=PhiRef(k,count);
    VetResult(count-1) = k;
    
end