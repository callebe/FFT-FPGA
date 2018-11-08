%------------------------------------
%  Simulacao do TBS
%------------------------------------

clc
clear all
close all

NumberOfS = 2; %Numero de SPT(Signal Power of Two), ou s's, em Sum tan^-1 [a0j*2^-s0j + a1j*2^-s1j]
W = 3; %word-length de Theta
Rm = 3; %Numero máximo de interações CORDIC
TargetAngleBase = 2*pi/1024; % Angulo de Rotação

%Criando vetor de possibilidades não repetido
LimSupAlpha = 1;
LimInfAlpha = -1;
LimS = 3;
M = 1000*ones(1,(LimSupAlpha-LimInfAlpha+1)*(LimS+1)*(LimSupAlpha-LimInfAlpha+1)*(LimS+1)+1);
Controller = 1;
for x=LimInfAlpha:LimSupAlpha
    for y=LimInfAlpha:LimSupAlpha
        for a=0:LimS
            for b=0:LimS
                SumI(Controller) = x*2^(-a)+y*2^(-b);
                Kn(Controller) = 1/sqrt(1+SumI(Controller)^2);
                r(Controller) = atan(SumI(Controller));
                for Crowler=1:Controller-1
                    if(SumI(Controller) == r(Crowler))
                        Controller = Controller - 1;
                        break;                        
                    end           
                end
                Controller = Controller + 1;               
            end            
        end        
    end    
end

for Cordic=1:511
    
    TargetAngle = TargetAngleBase*Cordic;
    
    %Fase acumulação e propagação
    Phi = zeros(length(r),Rm);
    Phi(:,1) = r;
    for x=2:Rm
        for y=1:length(r)
            [v,k]=min(abs(Phi(:,x-1)+r(y)-TargetAngle));
            Phi(y,x)=Phi(k,x-1)+r(y);
            Path(y,x)=k;
        end    
    end

    %Fase de Seleção do Melhor Global
    [v,k] = min(abs(Phi(:,Rm)-TargetAngle));
    Result(Rm) = k;

    %Fase de Seleção do Caminho ate o melhor Global
    Counter = 2;
    SumResult = r(k);
    for x=Rm:-1:2
        [v,k] = min(abs(Phi(:,x-1)+r(k)-TargetAngle));
        SumResult = SumResult + r(k);
        Result(x-1) = k;
        Counter = Counter + 1;

    end

    %Etapa de Validação do ALgoritmo
    xi(1) = 123;
    yi(1) = -25;
    Kc = ones(1,Rm+1);
    for x=2:Rm+1
        xi(x) = xi(x-1) - SumI(Result(x-1))*yi(x-1);
        yi(x) = SumI(Result(x-1))*xi(x-1) + yi(x-1);
        Kc(x) = Kc(x-1)*Kn(Result(x-1));
    end
    xfinal = xi(Rm+1)*Kc(Rm+1);
    yfinal = yi(Rm+1)*Kc(Rm+1);
    Reference = (xi(1)+yi(1)*i)*exp(TargetAngle*i);
    [theta ro] = cart2pol(real(Reference), imag(Reference));
    [thetaf rof] = cart2pol(xfinal, yfinal);
    ErroTheta(Cordic) = theta-thetaf;
    Erroro(Cordic) = ro-rof;
end

figure;
plot([1:511],ErroTheta);
hold
plot([1:511],Erroro);
legend('Erro Theta','Erro P')