%%
%------------------------------------
%  Simulacao do Mux
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 16;
%Definição do Numero de Layers do FFT
NumberOfLevels = log2(SizeOfFFT);

Contest = 1;

X = zeros(SizeOfFFT,NumberOfLevels+1);
X(:,1) = transpose([0:SizeOfFFT-1]);

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

fid = fopen('results.txt','w');
fprintf(fid,'Output(0) <= Input(0);\n');
for L = 1: SizeOfFFT-2
    fprintf(fid,'Output(%d) <= Input(%d) WHEN Control = "0000" ELSE\n',L,Y(L+1,1));
    for C = 2 : NumberOfLevels-1
        fprintf(fid,'\t\t\t Input(%d) WHEN Control = "%d%d%d%d" ELSE\n',Y(L+1,C),fliplr(de2bi(C-1,4)));
    end 
    fprintf(fid,'\t\t\t Input(%d);\n',Y(L+1,NumberOfLevels)); 
end
fprintf(fid,'Output(%d) <= Input(%d);\n',SizeOfFFT-1,SizeOfFFT-1);
fid = fclose(fid);





