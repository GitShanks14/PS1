%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Burst Error Detector                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clc;

% Set the Deep Fade Threshold ( in dB ) :
DeepFadeThreshold1 = -40;
DeepFadeThreshold2 = -20;

S = size(Gains);
S = S(3);

RayFade = 20.*log10(abs(Gains));

figure('Name','Rayleigh fading');
for i = 1:Tx
    for j = 1:Rx
        subplot(Tx,Rx,(i-1)*Rx+j)
        plot(reshape(RayFade(i,j,:),S,1))
        title(sprintf('Subplot %d: Fading of link from Tx %d to Rx %d',(i-1)*Rx+j,i,j));
    end
end

DeepFade = RayFade < DeepFadeThreshold1;

figure('Name','DeepFade');
for i = 1:Tx
    for j = 1:Rx
        subplot(Tx,Rx,(i-1)*Rx+j)
        plot(reshape(DeepFade(i,j,:),S,1))
        title(sprintf('Subplot %d: Deep Fading of link from Tx %d to Rx %d',(i-1)*Rx+j,i,j));
    end
end

FullFade = ones(size(DeepFade(1,1,:)));
for i = 1:Tx
    for j = 1:Rx
        FullFade = FullFade .* DeepFade(i,j,:);
    end
end

FullFade = reshape(FullFade,S,1);
% figure
% plot(FullFade)


DeepFade = RayFade < DeepFadeThreshold2;
R1Fail = reshape(DeepFade(1,1,:).*DeepFade(1,2,:),S,1);
R2Fail = reshape(DeepFade(2,1,:).*DeepFade(2,2,:),S,1);

T1Fail = reshape(DeepFade(1,1,:).*DeepFade(2,1,:),S,1);
T2Fail = reshape(DeepFade(1,2,:).*DeepFade(2,2,:),S,1);


figure('Name','Link Failures')
%plot(FullFade)
subplot(2,2,1)
plot(R1Fail)
title('Subplot 1: Failure of R1')

subplot(2,2,2)
plot(R2Fail)
title('Subplot 2: Failure of R2')

subplot(2,2,3)
plot(T1Fail)
title('Subplot 3: Failure of T1')

subplot(2,2,4)
plot(T2Fail)
title('Subplot 4: Failure of T2')


figure('Name','Burst Errors');
Nf = Nofdm/Rx;
filter = 1/Nf*ones(Nf,1);
spikes = conv(Errors,filter);
plot(spikes);