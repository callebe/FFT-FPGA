%% Cabeçalho
%------------------------------------
%  Simulação do FFT
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 16;
NumeroInteracao = 10;
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
X = zeros(SizeOfFFT,NumberOfLevels+1);
Input = A*(1+sin(2*pi*fA*t)) + B*(1+sin(2*pi*fB*t)) + C*(1+sin(2*pi*fC*t));
Xin(:, 1) = fix(Input);


%% Simulação do FFT

% Simulação dos Rearanjos da FFT
X = zeros(SizeOfFFT,NumberOfLevels+1);
Position = zeros(SizeOfFFT,NumberOfLevels);
X(:,1) = transpose([0:SizeOfFFT-1]);

%% Criação das Memorias COridc
SequenciaDeGiro = zeros(SizeOfFFT/2-1, NumeroInteracao+1);

for C = 0 : (SizeOfFFT/2-1)
%Calculo da Multiplicação pelo Algoritmo Cordic

    alpha = -2*pi*C/SizeOfFFT;

    if(alpha <= -pi/2)
        z(1) =  alpha + pi/2;
        SequenciaDeGiro(C+1, 1) = 1;
        
    else
        z(1) =  alpha;
        SequenciaDeGiro(C+1, 1) = 0;
        
    end

    for Count = 1: (NumeroInteracao)
        if z(Count) >= 0
            SequenciaDeGiro(C+1, Count+1) = 1;
            z(Count+1) = z(Count) - atan(2^-(Count-1));

        else
            SequenciaDeGiro(C+1, Count+1) = 0;
            z(Count+1) = z(Count) + atan(2^-(Count-1));

        end


    end
            
end

%Construindo Layers
for Layer = 0 : (NumberOfLevels-1)
    
    SizeofDFT = SizeOfFFT/(2^(Layer));
    NumberOfDFT = SizeOfFFT/(SizeofDFT);
    Line = 1;
    
    %DFTs
    for CountDFT = 0 :(NumberOfDFT-1) 
        
        Even = (CountDFT)*SizeofDFT;
    
        for CountSizeofDFT = 0 : (SizeofDFT/2-1)
            
            Odd = Even + SizeofDFT/2;
            
            %Entrada do Layer
            %Even
            G = Xin(Even+1, Layer+1);
            %Odd
            H = Xin(Odd+1, Layer+1);
            
            %Calculo da Multiplicação pelo Algoritmo Cordic
            if(SequenciaDeGiro((CountSizeofDFT*SizeOfFFT)/SizeofDFT+1, 1) == 1)
                x(1) = round(imag(G-H)/(2^1)) + round(imag(G-H)/(2^3)) - round(imag(G-H)/(2^6)) - round(imag(G-H)/(2^9));
                y(1) = -(round(real(G-H)/(2^1)) + round(real(G-H)/(2^3)) - round(real(G-H)/(2^6)) - round(real(G-H)/(2^9)));
               
            else
                x(1) = round(real(G-H)/(2^1)) + round(real(G-H)/(2^3)) - round(real(G-H)/(2^6)) - round(real(G-H)/(2^9));
                y(1) = round(imag(G-H)/(2^1)) + round(imag(G-H)/(2^3)) - round(imag(G-H)/(2^6)) - round(imag(G-H)/(2^9));

            end

            for Count = 0: NumeroInteracao-1
                if (SequenciaDeGiro((CountSizeofDFT*SizeOfFFT)/SizeofDFT+1, Count+2) == 1)
                    x(Count+2) = round(x(Count+1) - round((y(Count+1)/(2^Count))));
                    y(Count+2) = round(y(Count+1) + round((x(Count+1)/(2^Count))));
                    
                else
                    x(Count+2) = round(x(Count+1) + round((y(Count+1)/(2^Count))));
                    y(Count+2) = round(y(Count+1) - round((x(Count+1)/(2^Count))));
                    
                end

            end
            
            SUM(Even+1, Layer+1) = G+H;
            SUM(Odd+1, Layer+1) = G-H;
            %Saida do Layer
            %Even
            Xin(Even+1, Layer+2) = G + H;
            %Odd
            Xin(Odd+1, Layer+2) =  (x(NumeroInteracao+1)+i*y((NumeroInteracao+1)));
            
            Position(Line, Layer+1) = Even;
            Line = Line + 1;
            Position(Line, Layer+1) = Odd;
            Line = Line + 1;
            Even = Even + 1;
            
        end
        
    end 
    
end

%% Processo de Bit-Reverse
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
    ResultAux(n+1) = Xin(bi2de(AuxVector)+1, NumberOfLevels+1);
    ResultAuxBit(n+1) = bi2de(AuxVector);
    
end

RePosition = zeros(SizeOfFFT,NumberOfLevels);
RePosition(:,1) = [0:SizeOfFFT-1];

for C = 1 :(SizeOfFFT) 
    RePosition(C, 1) = Position(C, 1);
        
end 

for Layer = 2:(NumberOfLevels)   
    for C = 1 :(SizeOfFFT) 
        RePosition(C, Layer) = find(Position(:,Layer-1) == Position(C, Layer))-1;
        
    end 
end

XinRearranjado = zeros(SizeOfFFT,NumberOfLevels+1);
for Layer = 1:(NumberOfLevels)   
    for C = 1 :(SizeOfFFT) 
        XinRearranjado(C, Layer) = Xin(Position(C, Layer)+1, Layer);
        SUMR(C, Layer) = SUM(Position(C, Layer)+1, Layer);
    end 
end

Result = round(ResultAux(1:(SizeOfFFT/2+1))/SizeOfFFT);
Result(2:SizeOfFFT/2) = 2*Result(2:SizeOfFFT/2)


%% Construindo Arquivos VHDL

%ROM
fid = fopen('MemoriasCordic.txt','w');
fprintf(fid,'TYPE MEMORY IS ARRAY (%d DOWNTO 0) OF STD_LOGIC_VECTOR(%d DOWNTO 0) ;\n', (SizeOfFFT/2-1), NumeroInteracao);
fprintf(fid,'CONSTANT ROMMEMORY : MEMORY := (');
fprintf(fid,'0 => "');
for C = NumeroInteracao+1: -1 : 1;
  fprintf(fid,'%d', SequenciaDeGiro(1, C));

end
fprintf(fid,'", \n');
for L = 2: SizeOfFFT/2
   fprintf(fid,'\t\t\t\t\t\t\t %d => "', L-1);
   for C = NumeroInteracao+1: -1 : 2 
      fprintf(fid,'%d', SequenciaDeGiro(L, C));
       
   end
   
   C = 1;
   
   if(L == SizeOfFFT/2)
        fprintf(fid,'%d"); \n', SequenciaDeGiro(L, C));
       
   else
        fprintf(fid,'%d", \n', SequenciaDeGiro(L, C));
       
   end 
   
end
fid = fclose(fid);

%Select Out
fid = fopen('SelectOutput.txt','w');
fprintf(fid,'OutputSelectOut(0) <= InputSelectOut(0);\n');
for L = 1: SizeOfFFT-2
    fprintf(fid,'OutputSelectOut(%d) <= InputSelectOut(%d) WHEN ControlSelectOut = "0000" ELSE\n',L,RePosition(L+1,1));
    for C = 2 : NumberOfLevels-1
        fprintf(fid,'\t\t\t InputSelectOut(%d) WHEN ControlSelectOut = "%d%d%d%d" ELSE\n',RePosition(L+1,C),fliplr(de2bi(C-1,4)));
    end 
    fprintf(fid,'\t\t\t InputSelectOut(%d);\n',RePosition(L+1,NumberOfLevels)); 
end
fprintf(fid,'OutputSelectOut(%d) <= InputSelectOut(%d);\n',SizeOfFFT-1,SizeOfFFT-1);
fid = fclose(fid);

%Mux
fid = fopen('Mux.txt','w');
fprintf(fid,'OutputMuxFFTAux(25 DOWNTO %d) <= (OTHERS => OutputMuxFFTAux(%d));\n', (25-(NumberOfLevels-1)), (25-(NumberOfLevels-1)-1));
fprintf(fid,'OutputMuxFFTAux(12 DOWNTO %d) <= (OTHERS => OutputMuxFFTAux(%d));\n', (12-(NumberOfLevels-1)), (12-(NumberOfLevels-1)-1));
fprintf(fid,'OutputMuxFFTAux(%d DOWNTO 13) <= Butterfly_MuxFirst(%d) & Butterfly_MuxFirst(%d DOWNTO %d) WHEN Counter = 0 ELSE\n',(25-(NumberOfLevels-1)*2), (25-NumberOfLevels*2), (25-NumberOfLevels*2), (13-NumberOfLevels));
for L = 0: SizeOfFFT/2-3 
    fprintf(fid,'\t\t\t\t\t\t Butterfly_MuxOthers(%d)(%d DOWNTO %d) WHEN Counter = %d ELSE\n', L, (25-((NumberOfLevels-1)*2)), (13-(NumberOfLevels-1)), ResultAuxBit(2*(L+1)+1));
    
end
fprintf(fid,'\t\t\t\t\t\t Butterfly_MuxOthers(%d)(%d DOWNTO %d);\n',(SizeOfFFT/2-2), (25-((NumberOfLevels-1)*2)), (13-(NumberOfLevels-1))); 
fprintf(fid,'OutputMuxFFTAux(%d DOWNTO 0) <= Butterfly_MuxFirst(%d) & Butterfly_MuxFirst(%d DOWNTO 0) WHEN Counter = 0 ELSE\n',(12-(NumberOfLevels-1)), (12-NumberOfLevels), (12-NumberOfLevels));
for L = 0: SizeOfFFT/2-3
   fprintf(fid,'\t\t\t\t\t\t Butterfly_MuxOthers(%d)(%d DOWNTO 0) WHEN Counter = %d ELSE\n', L, (12-(NumberOfLevels-1)), ResultAuxBit(2*(L+1)+1));
    
end
fprintf(fid,'\t\t\t\t\t\t Butterfly_MuxOthers(%d)(%d DOWNTO 0);\n',(SizeOfFFT/2-2), (12-(NumberOfLevels-1))); 
fid = fclose(fid);


%Arquivo de Simulação
fid = fopen('Simulacao.txt','w');
fprintf(fid,'TYPE MemoInput IS ARRAY (%d DOWNTO 0) OF STD_LOGIC_VECTOR(%d DOWNTO 0) ;\n', (SizeOfFFT-1), 11);
fprintf(fid,'CONSTANT Xin : MemoInput := (');
fprintf(fid,'0 => "%d%d%d%d%d%d%d%d%d%d%d%d",\n', fliplr(de2bi(Xin(1, 1),12)));
for L = 1: SizeOfFFT-2
   fprintf(fid,'\t\t\t\t\t\t\t %d => "%d%d%d%d%d%d%d%d%d%d%d%d",\n', L, fliplr(de2bi(Xin(L+1, 1),12)));
   
end
fprintf(fid,'\t\t\t\t\t\t\t %d => "%d%d%d%d%d%d%d%d%d%d%d%d");\n', SizeOfFFT-1, fliplr(de2bi(Xin(L+1, 1),12)));
fid = fclose(fid);



%% Print de Resultados

FFTOriginalAux = abs(fft(Input)/SizeOfFFT);
FFTOriginal = FFTOriginalAux(1:SizeOfFFT/2+1);
FFTOriginal(2:end-1) = 2*FFTOriginal(2:end-1);

% %FFT via Matlab
% figure;
% stem((0 : SizeOfFFT/2)*f_s/(SizeOfFFT),FFTOriginal);
% ylabel('Amplitude');
% xlabel('Frequência (H)');
% title('FFT Matlab');
% 
% %FFT Calculada
% figure;
% stem((0 : SizeOfFFT/2)*f_s/(SizeOfFFT),abs(Result));
% ylabel('Amplitude');
% xlabel('Frequência (H)');
% title('FFT Calculada');


