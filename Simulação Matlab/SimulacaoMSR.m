clc
clear all
close all

Nspt = 3; % N�mero de termos de pot�ncia de 2
N = 3; % N�mero de intera��es
numberOfI = round((Nspt+1)/2); % Deslocamento parte direta
numberOfJ = N - numberOfI; % Deslocamento parte esquerda
S = 16; %N�mero de Deslocamentos M�ximos
Pupper = 1.5; %Valor de Upper Bound 
Plower = 1/Pupper; %Valor de Lower Bound
TargetAngleBase = -2*pi/1024; % Angulo de Rota��o

%Criando vetor de possibilidades
Controller = 1;
CC = 1;
for a=-1:1
    for b=-1:1
        for c=-1:1
            for x=0:S-1
                for y=0:S-1
                    for z=0:S-1
                        SumJAux = c*2^(-z);
                        SumIAux = a*2^(-x) + b*2^(-y);
                        CC = CC + 1;
                        rpAux = 1/sqrt(SumIAux^2 + SumJAux^2);
                        if(rpAux>Plower && rpAux<Pupper)                          
                            Referencia(Controller,:) = [a x b y c z];
                            SumI(Controller) = a*2^(-x) + b*2^(-y);
                            SumJ(Controller) = c*2^(-z);
                            rp(Controller) = 1/sqrt(SumI(Controller)^2 + SumJ(Controller)^2);
                            rtheta(Controller) = atan(SumI(Controller)/SumJ(Controller));
                            Controller = Controller + 1;
                        end
                    end
                end
            end
        end
    end
end

%Etapa de Cria��o de Matriz de Operadores Coridc
for Cordic=1:511
    %Escolha do Angulo Alvo
    TargetAngle = TargetAngleBase*Cordic;
    
    %Fase acumula��o e propaga��o
    Phitheta = zeros(length(rtheta),N);
    Phip = zeros(length(rp),N);
    Phitheta(:,1) = rtheta;
    Phip(:,1) = rp;
    for a=2:N
        for b=1:length(rp)
            menorV = 1000000000;
            menorL = 1;
            for count=1:length(rp)
                DeltaTheta = abs(Phitheta(count,a-1)+rtheta(b)-TargetAngle);
                DeltaP = abs( (count,a-1)*rp(b)-1);
                erro = sqrt(DeltaTheta^2+DeltaP^2);
                if(menorV > erro)
                    menorV = erro;
                    menorL = count;
                end
            end
            Peta(b,a) = menorL;
            Phitheta(b,a)=Phitheta(menorL,a-1)+rtheta(b);
            Phip(b,a)=Phip(menorL,a-1)*rp(b);
        end

    end

    %Fase de Sele��o do Melhor Global
    menoErroVG = 1000000000;
    menoErroLG = 0;
    for count=1:length(rp)
        erro = sqrt((Phip(count,N)-1)^2+(Phitheta(count,N)-TargetAngle)^2);
        if(menoErroVG > erro)
            menoErroVG = erro;
            menoErroLG = count;
        end
    end

    %Fase de Sele��o do Caminho ate o melhor Global
    k = menoErroLG;
    Result(Cordic,N) = k;
    counter = 2;
    for a=N:-1:2
        menorV = 1000000000;
        menorL = 0;
        for count=1:length(rp)
            DeltaTheta = Phitheta(count,a-1)+rtheta(k)-TargetAngle;
            DeltaP = Phip(count,a-1)*rp(k)-1;
            erro = sqrt(DeltaTheta^2+DeltaP^2);
            if(menorV > erro)
                menorV = erro;
                menorL = count;
            end
        end
        Result(Cordic,a-1) = menorL;
        k = menorL;
    end
end

%Imprimir dados em arquivos de texto
arquivo = fopen('result.txt');
Referencia(Result(Cordic,:),:);
fprintf(arquivo,'%d,1);
fclose(arquivo);

%Simulador de Opera��o COrdic
xi(1) = 120;
yi(1) = 21;
for x=2:N+1
    xi(x) = SumJ(Result(Cordic,x-1))*xi(x-1) - SumI(Result(Cordic,x-1))*yi(x-1);
    yi(x) = SumI(Result(Cordic,x-1))*xi(x-1) + SumJ(Result(Cordic,x-1))*yi(x-1);
end
Reference = (xi(1)+yi(1)*i)*exp(TargetAngle*i);
[theta ro] = cart2pol(real(Reference), imag(Reference));
[thetaf rof] = cart2pol(xi(N+1), yi(N+1));
ErroTheta = (theta-thetaf)/theta*100;
Erroro = (ro-rof)/ro*100;
ErroTheta
Erroro


