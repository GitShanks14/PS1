%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to vary Eb/No and plot variation of BER  %
% for various diversity orders                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clear; clc;

qpskMod = comm.QPSKModulator;
qpskDemod = comm.QPSKDemodulator;
Tx = 2;
Rx = 2;

scope1 = dsp.SpectrumAnalyzer;
scope2 = dsp.SpectrumAnalyzer;

ofdmMod = comm.OFDMModulator('FFTLength',64,'PilotInputPort',true,...
    'PilotCarrierIndices',cat(3,[12; 40; 54],[13; 39; 55]),'InsertDCNull',true,...
    'NumTransmitAntennas',Tx, 'CyclicPrefixLength', 16);

%For 2x2 MIMO, set Tx, Rx to 2, and handle the dimensions of the pilot carrier indices
% eg for 2x2, use 'PilotCarrierIndices',cat(3,[12; 40; 54],[13; 39; 55])

ofdmDemod = comm.OFDMDemodulator(ofdmMod);
ofdmDemod.NumReceiveAntennas = Rx;

showResourceMapping(ofdmMod)

ofdmModDim = info(ofdmMod);

numData = ofdmModDim.DataInputSize(1);  % Number of data subcarriers
numSym = ofdmModDim.DataInputSize(2);    % Number of OFDM symbols
numPilots = ofdmModDim.PilotInputSize;      
LenFrame = ofdmMod.FFTLength + ofdmMod.CyclicPrefixLength;


EbNo = 0:5:60;

nframes = 10000;
data = randi([0 3],nframes*numData,numSym,Tx);

modData = qpskMod(data(:));
modData = reshape(modData,nframes*numData,numSym,Tx);

errorRate = comm.ErrorRate;
RxSignalFull = zeros(nframes*LenFrame,Tx);
RxOFDMDataFull = zeros(numData*nframes,1,Tx);

% Set up the figure to be plotted
BER  = zeros(3,length(EbNo));

fig = figure;
grid on;
ax = fig.CurrentAxes;
hold(ax,'on');

ax.YScale = 'log';
xlim(ax,[EbNo(1), EbNo(end)]);
ylim(ax,[1e-4 1]);
xlabel(ax,'Eb/No (dB)');
ylabel(ax,'BER');
fig.NumberTitle = 'off';
fig.Renderer = 'zbuffer';
fig.Name = 'BER vs. Eb/No';
title(ax,'Error rate vs. Energy per symbol');
set(fig, 'DefaultLegendAutoUpdate', 'off');
fig.Position = figposition([15 50 25 30]);

% Generating the plots
for idx = 1:length(EbNo)
    
    reset(errorRate)
    
    for k = 1:nframes
        % Find row indices for kth OFDM frame
        indData = (k-1)*numData+1:k*numData;

        % Generate random OFDM pilot symbols
        pilotData = complex(rand(numPilots), ...
            rand(numPilots));

        % Modulate QPSK symbols using OFDM
        dataOFDM = ofdmMod(modData(indData,:,:),pilotData);

        % Create flat, i.i.d., Rayleigh fading channel
        chGain = complex(randn(Rx,Tx),randn(Rx,Tx))/sqrt(2); % Random 2x2 channel

        % Pass OFDM signal through Rayleigh and AWGN channels
        receivedSignal = awgn(dataOFDM*chGain,EbNo(idx));

        % Apply least squares solution to remove effects of fading channel
        rxSigMF = chGain.' \ receivedSignal.';      % Solves H' x = y'
        
        RxSignalFull((k-1)*LenFrame+1:k*LenFrame,:) = rxSigMF.';

        % Demodulate OFDM data
        [receivedOFDMData,receivedPilotData] = ofdmDemod(rxSigMF.');
        [x,dummy] = ofdmDemod(receivedSignal);
        RxOFDMDataFull(indData,:,:) = receivedOFDMData;

        % Demodulate QPSK data
        receivedData = qpskDemod(receivedOFDMData(:));

        % Compute error statistics
        dataTmp = data(indData,:,:);
        BER(:,idx) = errorRate(dataTmp(:),receivedData);
    end
    fprintf('\nSymbol error rate = %d from %d errors in %d symbols\n',BER(:,idx));
    semilogy(ax,EbNo(1:idx), BER(1,1:idx), 'go');
    legend(ax,'2x2 MIMO-OFDM (2Tx, 2Rx)');
    drawnow;
end

fitBER = berfit(EbNo, BER(1,:));
semilogy(ax,EbNo, fitBER, 'g');
hold(ax,'off');

scope2(RxSignalFull);
release(scope2);
% scope1(reshape(RxOFDMDataFull(:,1,:),numData*nframes,2));
% release(scope1);

