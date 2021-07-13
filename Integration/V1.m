%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to vary Eb/No and plot variation of BER  %
% for various diversity orders                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clear; clc;

% initialize modulators
Mod = comm.QPSKModulator('BitInput', true);
%Demod = comm.QPSKDemodulator('BitOutput',true);
Demod = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio');
ModOrd = 4;
Nbits = 2;


% initialize channel coding objects
Enc = comm.LDPCEncoder;
Dec = comm.LDPCDecoder;
K = 32400;
R = 1/2;


% Set up MIMO system
Tx = 2;
Rx = 2;
f  = 900*10^6;
d  = 1;
c  = 3*10^8;

FSPL = c/(4*pi*d*f);

% Set up OFDM system
FFTlen = 64;
NumPivots = 4;
guard = [6;6];
PCidx = SetPCidx ( NumPivots, Tx, guard, FFTlen );

ofdmMod = comm.OFDMModulator('FFTLength',FFTlen,'PilotInputPort',true,...
    'PilotCarrierIndices',PCidx,'InsertDCNull',true,...
    'NumTransmitAntennas',Tx, 'CyclicPrefixLength', 16,'NumGuardBandCarriers',guard);

ofdmDemod = comm.OFDMDemodulator(ofdmMod);
ofdmDemod.NumReceiveAntennas = Rx;

ofdmModDim = info(ofdmMod);
numData = ofdmModDim.DataInputSize(1);  % Number of data subcarriers
numSym = ofdmModDim.DataInputSize(2);    % Number of OFDM symbols
numPilots = ofdmModDim.PilotInputSize;
LenFrame = ofdmMod.FFTLength + ofdmMod.CyclicPrefixLength;

showResourceMapping(ofdmMod)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Simulation Parameters                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


EbNo = 0:5:90;
nframes = 10000;
Nofdm = numData * numSym * Tx * Nbits;

InputBlockSize = lcm(Nofdm,K);
OutputBlockSize = InputBlockSize/R;

errorRate = comm.ErrorRate;

% Defining the matrix that contains BER information
BER  = zeros(3,length(EbNo));
constdiag = comm.ConstellationDiagram;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Plotting                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Input Data                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data = randi([0 ModOrd-1],nframes*numData * numSym * Tx,1);
%data = randi([0 1],InputBlockSize* nframes,1);
data = randi([0 1],InputBlockSize,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Monte Carlo simulations                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for idx = 1:length(EbNo)
    reset(errorRate)
    
    % Reshape bit array into LDPC convenient format
    N1 = InputBlockSize/K;
    TransData = reshape(data,K,N1);
    EncData = zeros(K/R,N1);
    
    % Loop encode LDPC
    for LDPCframe = 1:N1
        EncData(:,LDPCframe) = Enc(TransData(:,LDPCframe));
    end
    
    % Reshape for OFDM
    N2 = OutputBlockSize/Nofdm;
    ofdmInput = reshape(EncData,Nofdm,N2);
    ofdmOutput = zeros(Nofdm,N2);
    
    % Using EbNo value from here to compute noise variance
    Demod.Variance = 10^(-EbNo(idx)/10);
    
    for k = 1:N2
%       % Find row indices for kth OFDM frame
%         indData = (k-1)*Nofdm+1:k*Nofdm;
        
        % Modulating the data
        modData = Mod(ofdmInput(:,k));
%         size(modData)
%         numData
%         numSym
%         Tx
%         numData*numSym*Tx
        modData = reshape(modData,numData,numSym,Tx);
        
        % Generate pilot symbols
        PD = complex(rand(numPilots),rand(numPilots));

        % Modulate symbols using OFDM
        dataOFDM = ofdmMod(modData,PD);

        % Create flat, i.i.d., Rayleigh fading channel
        chGain = complex(randn(Rx,Tx),randn(Rx,Tx))/sqrt(2) * FSPL;

        % Pass OFDM signal through Rayleigh and AWGN channels
        receivedSignal = awgn(dataOFDM*chGain,EbNo(idx));

        % Demodulate OFDM data
        [receivedOFDMData,RPD] = ofdmDemod(receivedSignal);
        
        % Channel estimation :
        ChGainEst = ChannelEstimation(Tx,Rx,PD,RPD);
        
        % Channel inversion
        RxOFDM = reshape(receivedOFDMData, numData, Tx);
        RxOFDMEst = reshape((ChGainEst.' \ RxOFDM.').', numData,1,Rx);
        
        %%Caution : Displaying the constellation makes the code very slow.
        %constdiag(RxOFDMEst(:));
        

        % Demodulate QPSK data
        % receivedData 
        ofdmOutput(:,k) = Demod(RxOFDMEst(:));

%         % Compute error statistics
%         dataTmp = data(:,k);
%         BER(:,idx) = errorRate(dataTmp(:),receivedData);
    end
    
    % Reshape Double array into LDPC convenient format
    RecData = reshape(ofdmOutput,K/R,N1);
    DecData = zeros(K,N1);
    
    % Loop encode LDPC
    for LDPCframe = 1:N1
        DecData(:,LDPCframe) = Dec(RecData(:,LDPCframe));
    end
    
    % Reshape bit block into array
    OutData = reshape(DecData,InputBlockSize,1);
    
    % Compute error statistics
    BER(:,idx) = errorRate(data,OutData);
    
    % Print & plot stats
    fprintf('\nSymbol error rate = %d from %d errors in %d symbols\n',BER(:,idx));
    semilogy(ax,EbNo(1:idx), BER(1,1:idx), 'go');
    legend(ax,'2x2 MIMO-OFDM (2Tx, 2Rx)');
    drawnow;
end

% Plot line fit
fitBER = berfit(EbNo, BER(1,:));
semilogy(ax,EbNo, fitBER, 'g');
hold(ax,'off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Function definitions                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PCidx = SetPCidx ( NumPivots, Tx, guard, FFTlen )
    % for N % M = 0 case : equal spacing
    indices = zeros(NumPivots,Tx);
    index = linspace(guard(1), FFTlen-guard(2),NumPivots+2);
    indices(:,1) = index(2:end-1);
    PCidx = cat(3,indices(:,1));

    for i = 2:Tx
        indices(:,i) = indices(:,i-1)+1;
        PCidx = cat(3,PCidx,indices(:,i));
    end
    PCidx = round(PCidx);
end

function ChGainEst = ChannelEstimation(Tx,Rx,PD,RPD)
    ChGainEst = zeros(Rx,Tx);
    for i = 1:Rx
        for j = 1:Tx
            ChGainEst(i,j) = PD(:,:,i)\RPD(:,:,i,j);
        end
    end
end