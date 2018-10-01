clc
clear all
close all


Nspt = 3; % Número de termos de potência de 2
N = 3; % Número de interações
numberOfI = round((Nspt+1)/2); % Deslocamento parte direta
numberOfJ = N - numberOfI; % Deslocamento parte esquerda
%S = 16; %Número de Deslocamentos Máximos
Pupper = 1.5; %Valor de Upper Bound 
Plower = 1/Pupper; %Valor de Lower Bound
TargetAngleBase = -2*pi/1024; % Angulo de Rotação


%Criando vetor de possibilidades
Controller = 1;
for a=-1:1
    for b=-1:1
        for c=-1:1
            for x=0:S-1
                for y=0:S-1
                    for z=0:S-1
                        SumIAux = c*2^-z;
                        SumJAux = a*2^-x + b*2^-y;
                        rpAux = 1/sqrt(SumIAux^2 + SumJAux^2);
                        if(rpAux>Plower && rpAux<Pupper)
                            SumJ(Controller) = SumJAux;
                            SumI(Controller) = SumIAux;
                            rp(Controller) = rpAux;
                            if(SumIAux < 0 && SumJAux > 0)
                                rtheta(Controller) = atan(abs(SumIAux/SumJAux)) + pi/2;
                            else
                                if(SumIAux < 0 && SumJAux < 0)
                                    rtheta(Controller) = atan(-abs(SumIAux/SumJAux))- pi/2;
                                else
                                    if(SumJAux == 0)
                                        if(SumIAux == 0)
                                             rtheta(Controller) = 0;
                                        else
                                            if(SumIAux>0)
                                                rtheta(Controller) = 0;
                                            else
                                                rtheta(Controller) = pi;
                                            end
                                        end

                                    else                                        
                                        if(SumIAux == 0)
                                            if(SumJAux>0)
                                                rtheta(Controller) = pi/2;
                                            else
                                                rtheta(Controller) = -pi/2;
                                            end
                                        else
                                            rtheta(Controller) = atan(SumJAux/SumIAux);
                                        end
                                    end
                                end
                            end
                            Controller = Controller + 1;
                        end
                    end
                end
            end
        end
    end
end

% for a=1:length(rp)
%     %Simulador de Operação COrdic
%     xi = 1;
%     yi = 0;
%     I = SumI(a);
%     J = SumJ(a);
%     xf = I*xi - J*yi;
%     yf = J*xi + I*yi;
%     Reference = (xi+yi*i)*exp(rtheta(a)*i);
%     [theta ro] = cart2pol(real(Reference), imag(Reference));
%     [thetaf rof] = cart2pol(xf, yf);
%     ErroTheta(a) = (theta-thetaf);
%     Erroro(a) = (ro-rof);
%     thetaEfetivo(a) = thetaf;
% end
% [ReordenadoTheta, Indice] = sort(rtheta);
% figure;
% plot([1:Controller-1],ReordenadoTheta, [1:Controller-1], thetaEfetivo(Indice(:)));
% legend('Oque ele Diz que Roda', 'Efetivo','Erro');


for Cordic=1:50

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
    Result(Cordic, N) = k;
    for a=N:-1:2
        Result(Cordic, a-1) = Peta(k,a);
        k = Peta(k,a);

    end

    %Imprimir dados em arquivos de texto
    % arquivo = fopen('result.txt');
    % Lambda = Referencia(Result(Cordic,:),:);
    % fprintf(arquivo,'%d', Lambda);
    % fclose(arquivo);

    %Simulador de Operação COrdic
    xi(1) = 1;
    yi(1) = 0;
    for a=1:N
        I = SumI(Result(Cordic,a));
        J = SumJ(Result(Cordic,a));
        xi(a+1) = I*xi(a) - J*yi(a);
        yi(a+1) = I*yi(a) + J*xi(a);
    end
    Reference = (xi(1)+yi(1)*i)*exp(TargetAngle*i);
    [theta ro] = cart2pol(real(Reference), imag(Reference));
    [thetaf rof] = cart2pol(xi(N+1), yi(N+1));
    ErroTheta(Cordic) = (theta-thetaf);
    Erroro(Cordic) = (ro-rof);
    ThetaMSR(Cordic) = thetaf;
    ThetaRef(Cordic) = theta;

end

figure;
grid;
subplot(2,1,1);
plot(TargetAngleBase*[1:Cordic],ErroTheta,'red');
axis([-pi 0 -0.004 0.004]);
legend('Erro \Theta');
xlabel('rad');
ylabel('rad');
subplot(2,1,2); 
plot(TargetAngleBase*[1:Cordic],Erroro);
axis([-pi 0 -0.004 0.004]);
legend('Erro K_c');
xlabel('rad');
ylabel('p.u.');
figure;
SN = [3.07700039264603 16.7242316940052 24.1574110016604 32.9188740308277 40.2413486449923 44.0756636035995 49.5262438837148 52.3695695881040 55.9078904706715 62.6049611495806 67.6209634068088 69.7814262260311 70.7245402601306 71.0384823831502 71.0848300310428];
plot([2:16],SN);
grid on;
ylabel('SQNR (dB)');
xlabel('Valor Máximo de Shift (S)');

