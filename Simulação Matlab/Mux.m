%%
%------------------------------------
%  Simulacao do Mux
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 16;
Resolution = SizeOfFFT;
%Definição do Numero de Layers do FFT
NumberOfLevels = log2(SizeOfFFT);

%Input FFT
T_0 = 10;
A = 30;
B= 40;
C = 23;
fA = 100;
fB = 3500;
fC = 60;
t = [0 : (1/T_0)/(Resolution) : ((1/T_0)-(1/T_0)/(Resolution))];
y = A*(sin(2*pi*fA*t)) + B*(sin(2*pi*fB*t)) + C*(sin(2*pi*fC*t)) + A + B + C;


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

for Layer = 1:(NumberOfLevels)   
    for C = 1 :(SizeOfFFT) 
        Y(C, Layer) = find(X(:,Layer) == X(C, Layer+1))-1;
    end 
end

fid = fopen('SelectOutput.txt','w');
fprintf(fid,'OutputSelectOut(0) <= InputSelectOut(0);\n');
for L = 1: SizeOfFFT-2
    fprintf(fid,'OutputSelectOut(%d) <= InputSelectOut(%d) WHEN ControlSelectOut = "0000" ELSE\n',L,Y(L+1,1));
    for C = 2 : NumberOfLevels-1
        fprintf(fid,'\t\t\t InputSelectOut(%d) WHEN ControlSelectOut = "%d%d%d%d" ELSE\n',Y(L+1,C),fliplr(de2bi(C-1,4)));
    end 
    fprintf(fid,'\t\t\t InputSelectOut(%d);\n',Y(L+1,NumberOfLevels)); 
end
fprintf(fid,'OutputSelectOut(%d) <= InputSelectOut(%d);\n',SizeOfFFT-1,SizeOfFFT-1);
fid = fclose(fid);

fid = fopen('Mux.txt','w');
fprintf(fid,'OutputMuxFFT(25 DOWNTO 13) <= InputMuxFFT(0).r WHEN SelectMux = "00000000" ELSE\n');
for L = 1: SizeOfFFT/2-2  
    fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).r WHEN SelectMux = "%d%d%d%d%d%d%d%d" ELSE\n', L, fliplr(de2bi(L,8)));
    
end
fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).r;\n', (SizeOfFFT/2-1));

fprintf(fid,'\n\n');
fprintf(fid,'OutputMuxFFT(12 DOWNTO 0) <= InputMuxFFT(0).i WHEN SelectMux = "00000000" ELSE\n');
for L = 1: SizeOfFFT/2-2
   fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).i WHEN SelectMux = "%d%d%d%d%d%d%d%d" ELSE\n', L, fliplr(de2bi(L,8)));
    
end
fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).i;\n',(SizeOfFFT/2-1)); 
fid = fclose(fid);


fid = fopen('Simulacao.txt','w');
for L = 0: SizeOfFFT-1
   fprintf(fid,'InputFFT <= "%d%d%d%d%d%d%d%d%d%d%d%d"; \n SelectDemuxMux <= "%d%d%d%d%d%d%d%d";\n', fliplr(de2bi(fix(y(L+1)),12)), fliplr(de2bi(L,8)));
   fprintf(fid,'wait for 1us;');
end
fid = fclose(fid);






