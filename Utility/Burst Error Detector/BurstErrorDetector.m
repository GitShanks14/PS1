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
RFail = ones(Rx,S);
TFail = ones(Tx,S);


figure('Name','Receiver Failures')

for i = 1:Rx
    subplot(Rx,1,i)
    for j = 1:Tx
        RFail(i,:) = RFail(i,:).*reshape(DeepFade(i,j,:),1,S);
    end
    plot(RFail(i,:))
    title(sprintf('Subplot %d: Failure of R%d',i));
end

figure('Name','Transmitter Failures')

for j = 1:Tx
    subplot(Tx,1,j)
    for i = 1:Rx
        TFail(j,:) = TFail(j,:).*reshape(DeepFade(i,j,:),1,S);
    end
    plot(TFail(j,:))
    title(sprintf('Subplot %d: Failure of T%d',j));
end


figure('Name','Burst Errors');
Nf = Nofdm/Rx;
filter = 1/Nf*ones(Nf,1);
spikes = conv(Errors,filter);
plot(spikes);