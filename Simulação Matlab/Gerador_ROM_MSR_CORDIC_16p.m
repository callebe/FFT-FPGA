%##########################################################################
%#                       Gerador de ROM Para Algoritmo                    #
%#                           CORDIC MSR - 16p                             #
%#                       Utilizando TBS-Modificado                        #
%#   Autor : Callebe Soares Barbosa                                       #
%#   Acadêmico de Engenharia Elétrica                                     #
%#   Universidade Tecnológica Federal do Paraná - Campus Pato Branco      #
%#   GitHub : https://github.com/callebe                                  #
%##########################################################################

clc
clear all
close all

%Obtendo dados MSR
Result = importdata('Result16.mat');
Parametros = importdata('Parametros16.mat');

%Conexões (Um Cordic a cada 2 Linhas)
Nfft = 16;
CordicConexions=zeros(Nfft,log2(Nfft));
NumberOfLevels = log2(Nfft);
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

k = 1;
for Set=32:32:length(CordicConexions(:,3))
    Lino(k, 1) = CordicConexions(Set-31,3);
    Lino(k, 2) = CordicConexions(Set,3);
    k = k + 1;
    
end

%Twidle Factor (Apenas 16 Unidades Cordic, para N/2 Butterflies)
CordicTwiddleFactor = inf*ones(Nfft/2,NumberOfLevels);
for ButterFly=0:Nfft/2-1
    CordicTwiddleFactor(ButterFly+1,1) = ButterFly;
end

for Level=2:NumberOfLevels
    for ButterFly=0:Nfft/2-1
        Aux = de2bi(CordicTwiddleFactor(ButterFly+1,Level-1),NumberOfLevels-1);
        CordicTwiddleFactor(ButterFly+1,Level) = bi2de([0 Aux(1:NumberOfLevels-2)]);
    end
end

%Imprimir dados em arquivos de texto
for CordicUnit=0:Nfft/2-1
    counter = 0;
    Source = strcat(num2str(CordicUnit),'.vhd');
    Source = strcat('ROMFFT16',Source);
    arquivo = fopen(Source,'w');
    fprintf(arquivo,'library IEEE;\nuse IEEE.STD_LOGIC_1164.ALL;\n\nentity ROMFFT16%d is\n\t', CordicUnit);
    fprintf(arquivo,'Port(\n\t\tAdress : in STD_LOGIC;\n\t\treset : in STD_LOGIC;\n\t\tData : out STD_LOGIC_VECTOR (20 downto 0)\n\t\t);\nend ROMFFT16%d;\n\n', CordicUnit);
    fprintf(arquivo,'architecture Behavioral of ROMFFT16%d is\n\n\ttype ROM is array (11 downto 0) of std_logic_vector(20 downto 0) ;\n', CordicUnit);
    fprintf(arquivo,'\t-- ROM %d \n',CordicUnit+1); 
    fprintf(arquivo,'\tconstant ROM_tb : ROM := (\n');
    OperatorCordic = CordicUnit/2;
    for Level = 1 : log2(Nfft)
        OperatorCordic = rem(OperatorCordic*2,8);
        for step=1:3
            %[a-1 mu1 mu2 mu3 s1 s2 s3]
            %[sw1 mu1 s1 sw2 mu2 s2 sw3 mu3 s3]
            %Swithcs
            Select = Result(OperatorCordic+1,step);
            switch Parametros(Select, 1)
                case 0
                    I = ['1' '1' '1'];
                case 1
                    I = ['0' '1' '1'];
                case 2
                    I = ['0' '0' '1'];
                case 3
                    I = ['0' '0' '0'];
            end
            %mu1
            switch Parametros(Select, 2)
                case -1
                    mu1 = ['1' '1'];
                case 0
                    mu1 = ['0' '0'];
                case 1
                    mu1 = ['0' '1'];
            end
            %mu2
            switch Parametros(Select, 3)
                case -1
                    mu2 = ['1' '1'];
                case 0
                    mu2 = ['0' '0'];
                case 1
                    mu2 = ['0' '1'];
            end
            %mu3
            switch Parametros(Select, 4)
                case -1
                    mu3 = ['1' '1'];
                case 0
                    mu3 = ['0' '0'];
                case 1
                    mu3 = ['0' '1'];
            end
            Memory = [I(1) mu1 dec2bin(Parametros(Select,5),4) I(2) mu2 dec2bin(Parametros(Select,6),4) I(3) mu3 dec2bin(Parametros(Select,7),4)];
            fprintf(arquivo,'\t\t%d => "', counter);
            counter = counter + 1;
            fprintf(arquivo,'%s"', Memory);
            if(Level < log2(Nfft) || step < 3)
                fprintf(arquivo,',\n');
            end
        end
        
        %Simulador de Operação COrdic
%         xi(1) = 5632;
%         yi(1) = 1452;
%         for a=1:3
%             %b=Result(OperatorCordic+1, a);
%             switch Parametros(b,1)
%                 case 0
%                     I=0;
%                     J=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
%                 case 1
%                     I=Parametros(b,2)*2^-Parametros(b,5);
%                     J=Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
%                 case 2
%                     I=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6);
%                     J=Parametros(b,4)*2^-Parametros(b,7);
%                 otherwise
%                     I=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
%                     J=0;
%             end
%             xi(a+1) = I*xi(a) - J*yi(a);
%             yi(a+1) = I*yi(a) + J*xi(a);
%         end
%         Reference = (xi(1)+yi(1)*i)*exp(-2*pi*i*OperatorCordic/Nfft);
%         [theta ro] = cart2pol(real(Reference), imag(Reference));
%         [thetaf rof] = cart2pol(xi(4), yi(4));
%         ErroTheta(CordicUnit+1, Level) = (theta-thetaf);
%         Erroro(CordicUnit+1, Level) = (ro-rof);
%         ThetaMSR(CordicUnit+1, Level) = thetaf;
%         ThetaRef(CordicUnit+1, Level) = theta;
    end
    fprintf(arquivo,');\n\n');
    fprintf(arquivo,'\tbegin\n\t\t--Process to acess Data\n\t\tprocess(Adress, reset)\n\n\t\t\tvariable Counter : integer range 11 downto 0 := 0;\n\n\t\tbegin\n\n\t\tData <= Rom_tb(Counter);\n\t\tif(reset = ''1'')then\n\t\t\tCounter := 0;\n\n');
    fprintf(arquivo,'\t\telsif(Adress''event and Adress = ''1'') then\n\t\t\tCounter := Counter + 1;\n\n\t\tend if;\n\n\tend process;\n\nend Behavioral;');
    fclose(arquivo);
    
end


