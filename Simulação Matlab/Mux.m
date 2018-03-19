%%
%------------------------------------
%  Simulacao do Mux
%------------------------------------
clear all
close all
% Tamanho da FFT
SizeOfFFT = 256;
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
fprintf(fid,'OutputMuxFFT(25 DOWNTO 13) <= InputMuxFFT(0).r WHEN CounterControl = 0 ELSE\n');
for L = 0: SizeOfFFT/2-2  
    fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).r WHEN CounterControl = %d ELSE\n',L,L);
    
end
fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).r;\n',SizeOfFFT/2-1);
fprintf(fid,'\n\n');
fprintf(fid,'OutputMuxFFT(12 DOWNTO 0) <= InputMuxFFT(0).i WHEN CounterControl = 0 ELSE\n',L,L);
for L = 1: SizeOfFFT/2-2
   fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).i WHEN CounterControl = %d ELSE\n',L,L);
    
end
fprintf(fid,'\t\t\t\t\t\t InputMuxFFT(%d).i;\n',SizeOfFFT/2-1); 
fid = fclose(fid);





