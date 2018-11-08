%##########################################################################
%#                         Projeto de Parâmetros                          #
%#                             CORDIC MSR                                 #
%#                       Utilizando TBS-Modificado                        #
%#   Autor : Callebe Soares Barbosa                                       #
%#   Acadêmico de Engenharia Elétrica                                     #
%#   Universidade Tecnológica Federal do Paraná - Campus Pato Branco      #
%#   GitHub : https://github.com/callebe                                  #
%##########################################################################

clc
clear all
close all

Nfft = 16;
Nspt = 3; % Número de termos de potência de 2
N = 3; % Número de interações
numberOfI = round((Nspt+1)/2); % Deslocamento parte direta
numberOfJ = N - numberOfI; % Deslocamento parte esquerda
S = 16; %Número de Deslocamentos Máximos
Pupper = 1.5; %Valor de Upper Bound 
Plower = 1/Pupper; %Valor de Lower Bound
TargetAngleBase = -2*pi/Nfft; % Angulo de Rotação


%Criando vetor de possibilidades
Cont=1;
for mu1=-1:1
    for mu2=-1:1
        for mu3=-1:1
            for s1=0:S-1
                for s2=0:S-1
                    for s3=0:S-1
                        %Inversão de Eixo
                        I(1)=0;
                        J(1)=mu1*2^-s1+mu2*2^-s2+mu3*2^-s3;
                        Pn(1) = 1/sqrt(I(1)^2+J(1)^2);
                        %Normal 1-2
                        I(2)=mu1*2^-s1;
                        J(2)=mu2*2^-s2+mu3*2^-s3;
                        Pn(2) = 1/sqrt(I(2)^2+J(2)^2);
                        %Normal 2-1
                        I(3)=mu1*2^-s1+mu2*2^-s2;
                        J(3)=mu3*2^-s3;
                        Pn(3) = 1/sqrt(I(3)^2+J(3)^2);
                        %Normal Ajuste de Ganho
                        I(4)=mu1*2^-s1+mu2*2^-s2+mu3*2^-s3;
                        J(4)=0;
                        Pn(4) = 1/sqrt(I(4)^2+J(4)^2);
                        %Calculando Módulo e Ângulo
                        for a=1:4         
                            if(Pn(a) > Plower && Pn(a) < Pupper)
                                rp(Cont)=Pn(a);
                                Parametros(Cont,:) = [a-1 mu1 mu2 mu3 s1 s2 s3];
                                if(I(a) < 0 && J(a) > 0)
                                    rtheta(Cont) = atan(abs(I(a)/J(a))) + pi/2;
                                else
                                    if(I(a) < 0 && J(a) < 0)
                                        rtheta(Cont) = atan(-abs(I(a)/J(a)))- pi/2;
                                    else
                                        if(J(a) == 0)
                                            if(I(a) == 0)
                                                 rtheta(Cont) = 0;
                                            else
                                                if(I(a)>0)
                                                    rtheta(Cont) = 0;
                                                else
                                                    rtheta(Cont) = pi;
                                                end
                                            end

                                        else
                                            if(I(a) == 0)
                                                if(J(a)>0)
                                                    rtheta(Cont) = pi/2;
                                                else
                                                    rtheta(Cont) = -pi/2;
                                                end
                                            else
                                                rtheta(Cont) = atan(J(a)/I(a));
                                            end
                                        end
                                    end
                                end
                                Cont=Cont+1;
                            end
                        end
                    end
                end
            end
        end
    end    
end

%Execultando Algoritmo TBS Alterado
for Cordic=0:Nfft/2-1
    
    TargetAngle = TargetAngleBase*Cordic; 
    
    %Etapa de Criação de Matriz de Operadores Coridc
    Phitheta = zeros(length(rtheta),N);
    Phip = zeros(length(rp),N);
    Phitheta(:,1) = rtheta;
    Phip(:,1) = rp;


    %Fase acumulação e propagação
    for a=2:N
        for b=1:length(rp)
            menorV = Inf;
            menorL = 1;
            for c=1:length(rp)
                DeltaTheta = Phitheta(c,a-1)+rtheta(b)-TargetAngle;
                DeltaP = Phip(c,a-1)*rp(b)-1;
                erro = sqrt(DeltaTheta^2+DeltaP^2);
                if(menorV > erro)
                    menorV = erro;
                    menorL = c;
                end
            end
            Peta(b,a) = menorL;
            Phitheta(b,a)=Phitheta(menorL,a-1)+rtheta(b);
            Phip(b,a)=Phip(menorL,a-1)*rp(b);
        end

    end

    %Fase de Seleção do Melhor Global
    menoErroVG = Inf;
    menoErroLG = 1;
    for a=1:length(rp)
        erro = sqrt((Phip(a,N)-1)^2+(Phitheta(a,N)-TargetAngle)^2);
        if(menoErroVG > erro)
            menoErroVG = erro;
            menoErroLG = a;
        end
    end

    %Fase de Seleção do Caminho ate o melhor Global
    k = menoErroLG;
    Result(Cordic+1, N) = k;
    for a=N:-1:2
        Result(Cordic+1, a-1) = Peta(k,a);
        k = Peta(k,a);

    end

    %Simulador de Operação COrdic
    xi(1) = 5632;
    yi(1) = 1452;
    for a=1:N
        b=Result(Cordic+1, a);
        switch Parametros(b,1)
            case 0
                I=0;
                J=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
            case 1
                I=Parametros(b,2)*2^-Parametros(b,5);
                J=Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
            case 2
                I=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6);
                J=Parametros(b,4)*2^-Parametros(b,7);
            otherwise
                I=Parametros(b,2)*2^-Parametros(b,5)+Parametros(b,3)*2^-Parametros(b,6)+Parametros(b,4)*2^-Parametros(b,7);
                J=0;
        end
        xi(a+1) = I*xi(a) - J*yi(a);
        yi(a+1) = I*yi(a) + J*xi(a);
    end
    Reference = (xi(1)+yi(1)*i)*exp(TargetAngle*i);
    [theta ro] = cart2pol(real(Reference), imag(Reference));
    [thetaf rof] = cart2pol(xi(N+1), yi(N+1));
    ErroTheta(Cordic+1) = (theta-thetaf);
    Erroro(Cordic+1) = (ro-rof);
    ThetaMSR(Cordic+1) = thetaf;
    ThetaRef(Cordic+1) = theta;

end
snr(ThetaRef,ThetaMSR-ThetaRef);
figure;
plot(TargetAngleBase*[1:Cordic],ErroTheta);
hold;
plot(TargetAngleBase*[1:Cordic],Erroro);
legend('Erro Theta','Erro |H|');
figure;
plot(TargetAngleBase*[1:Cordic],rtheta(Result(:,1))+rtheta(Result(:,2))+rtheta(Result(:,3))-TargetAngleBase*[1:Cordic]);
