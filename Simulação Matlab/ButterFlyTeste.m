%------------------------------------
%  Simulação do FFT
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 16;

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

%Definição do Sinal de Entrada
T_0 = 10;
A = 30;
B= 40;
C = 23;
fA = 100;
fB = 3500;
fC = 60;
t = [0 : (1/T_0)/(Resolution) : ((1/T_0)-(1/T_0)/(Resolution))];
Input = A*(1+sin(2*pi*fA*t)) + B*(1+sin(2*pi*fB*t)) + C*(1+sin(2*pi*fC*t));
Xin(:, 1) = fix(Input);

%Simulação do FFT
%Building the Layers
for Layer = 0 : (NumberOfLevels)
    
    SizeofDFT = SizeOfFFT/(2^(Layer));
    NumberOfDFT = SizeOfFFT/(SizeofDFT);
    
    W = exp(-2*pi*i/SizeofDFT);
    Conteste = 1;
    
    %Building the DFTs
    for CountDFT = 0 :(NumberOfDFT-1) 
        
        Even = (CountDFT)*SizeofDFT;
    
        %Building the DFT
        for CountSizeofDFT = 0 : (SizeofDFT/2-1)
            Wn = -2*pi*CountSizeofDFT/SizeofDFT;
            if(Wn <= -pi/2) 
                LL = 1;
            else
                LL = 0;
            end
            Odd = Even + SizeofDFT/2;
            
            %Entrada do Layer
            %Even
            G = Xin(Even+1, Layer+1);
            %Odd
            H = Xin(Odd+1, Layer+1);
            
            %Saida do Layer
            %Even
            Xin(Even+1, Layer+2) = G + H;
            %Odd
            Xin(Odd+1, Layer+2) =  (G - H);%*W^(CountSizeofDFT);
            
            Mark(Conteste, Layer+1) = Even;
            Conteste = Conteste + 1;
            Mark(Conteste, Layer+1) = Odd;
            Conteste = Conteste + 1;
            Even = Even + 1;
            
        end
        
    end 
    
end

%Simulação dos Rearanjos da FFT
X = zeros(SizeOfFFT,NumberOfLevels+1);
X(:,1) = transpose([0:SizeOfFFT-1]);

Contest = 1;
%Building the Layers
for Layer = 0:(NumberOfLevels-1)
    
    SizeofDFT = SizeOfFFT/(2^(Layer));
    NumberOfDFT = SizeOfFFT/SizeofDFT;
    Contest = Contest + 1;
    Linha = 1;
    
    %Building the DFTs
    for CountDFT = 0 :(NumberOfDFT-1) 
        
        Even = (CountDFT)*SizeofDFT;
        
        %Building the DFT
        for CountSizeofDFT = 0 : (SizeofDFT/2-1)
            
            Odd = Even + SizeofDFT/2;
            X(Linha, Contest) = Even;
            Linha = Linha + 1;
            X(Linha, Contest) = Odd;
            Linha = Linha + 1;
            Even = Even + 1;
            
        end
        
    end 
    
end

Y = zeros(SizeOfFFT,NumberOfLevels);
XinRearranjado = zeros(SizeOfFFT,NumberOfLevels+1);


for Layer = 1:(NumberOfLevels)   
    for C = 1 :(SizeOfFFT) 
        Y(C, Layer) = find(X(:,Layer) == X(C, Layer+1))-1;
        
    end 
end

for C = 1 :(SizeOfFFT) 
    XinRearranjado(C, 1) = Xin(C,1);

end 

for Layer = 2:(NumberOfLevels)   
    for C = 1 :(SizeOfFFT) 
        XinRearranjado(C, Layer) = Xin(Y(C, Layer-1)+1, Layer);
        
    end 
end

%Convertendo niveis para hexa
for Layer = 0 : (NumberOfLevels)
    
    for Count = 0: SizeOfFFT-1
        if(real(XinRearranjado(Count+1, Layer+1)) <0)
            XinHexReal(Count+1, Layer+1) = string(dec2hex(abs(8192+round(real(XinRearranjado(Count+1, Layer+1))))));
            
        else
            XinHexReal(Count+1, Layer+1) = string(dec2hex(abs(round(real(XinRearranjado(Count+1, Layer+1))))));
            
        end
        
        if(imag(XinRearranjado(Count+1, Layer+1)) <0)
            XinHexImag(Count+1, Layer+1) = string(dec2hex(abs(8192+round(imag(XinRearranjado(Count+1, Layer+1))))));
            
        else
            XinHexImag(Count+1, Layer+1) = string(dec2hex(abs(round(imag(XinRearranjado(Count+1, Layer+1))))));
            
        end
        
    end
    
end

Result(1) = abs(Xin(1, NumberOfLevels+1)/SizeOfFFT);
ResultHexa(1) = string(dec2hex(round(abs(Xin(1, NumberOfLevels+1)*2/SizeOfFFT))));
for C = 1 :(SizeOfFFT/2-1)
   Result(C+1) = abs(Xin(2*C+1, NumberOfLevels+1)*2/SizeOfFFT);
   ResultHexa(C+1) = string(dec2hex(round(abs(Xin(2*C+1, NumberOfLevels+1)*2/SizeOfFFT))));
   
end

FFTOriginalAux = abs(fft(Input)/SizeOfFFT);
FFTOriginal = FFTOriginalAux(1:SizeOfFFT/2+1);
FFTOriginal(2:end-1) = 2*FFTOriginal(2:end-1);

Xin
XinHexReal
XinHexImag
Mark
Y
ResultHexa
Result
FFTOriginal

