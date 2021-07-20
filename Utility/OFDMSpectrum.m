% This script is meant for plotting the PSD of the different subcarriers
% of a OFDM system.

clear
Mod = comm.QPSKModulator('BitInput', true);
Nbits = 2;
%Demod = comm.QPSKDemodulator('BitOutput',true);

% Set up OFDM system
FFTlen = 8;
CPlen  = 2;
Lguard = 0;
Rguard = 0;
guard = [Lguard;Rguard];
Tx = 1; % Do not change

ofdmMod = comm.OFDMModulator('FFTLength',FFTlen, 'NumTransmitAntennas',Tx, 'CyclicPrefixLength', CPlen,'NumGuardBandCarriers',guard,'Windowing',true);

scope = dsp.SpectrumAnalyzer;

ofdmModDim = info(ofdmMod);
numData = ofdmModDim.DataInputSize(1);  % Number of data subcarriers
numSym = ofdmModDim.DataInputSize(2);   % Number of OFDM symbols
LenFrame = ofdmMod.FFTLength + ofdmMod.CyclicPrefixLength;

subcarrierIndex = [-26:-1 1:26];
% Generate from Guard band.

nframes = 100;
%data = randi([0 1],numData * numSym * Tx * Nbits,nframes);
data  = zeros(numData * numSym * Tx * Nbits,nframes);


fsMHz = 20;
figure;
hold on;


% Select carrier to be displayed.
for CNo = 1:numData  % Update range
    fselect = zeros(numData,1);
    fselect(CNo,1)=1;
    st = zeros(1,3920); % empty vector
    for k = 1:nframes
        modData = Mod(data(:,k));
        modData = reshape(modData,numData,numSym,Tx);
        SelData = modData .* fselect;
        dataOFDM = ofdmMod(SelData);
        st((k-1)*LenFrame+1:k*LenFrame) = dataOFDM; 
    end
%     figure
%     plot(abs(st))
%     figure
%     plot(angle(st))
%     figure
    [Pxx,W] = pwelch(st,[],[],4096,20); 
    plot((-2048:2047)*fsMHz/4096,10*log10(fftshift(Pxx)));
    %plot((-2048:2047)*fsMHz/4096,10*log10(Pxx));
end
xlabel('frequency (MHz)')
ylabel('power spectral density')
title(sprintf('Spectrum of raised cosine windowing based OFDM'));
