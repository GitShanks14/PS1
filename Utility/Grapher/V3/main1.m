%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to vary Eb/No and plot variation of BER  %
% for various systems                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change to configure system
PlotNumber = 1;

%%%%%%%%%%%%%%%%%%%%%%%% initialize Mod / Demod %%%%%%%%%%%%%%%%%%%%%%%%%%
ModOrd = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change. 
Nbits = ceil(log2(ModOrd));
defaultMod = false;
if ( ModOrd == 2 )
    Mod = comm.BPSKModulator();
    Demod = comm.BPSKDemodulator('DecisionMethod','Approximate log-likelihood ratio');
    defaultMod = true;
elseif ( ModOrd == 4 )
    Mod = comm.QPSKModulator('BitInput', true);
    Demod = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio');
    defaultMod = true;
elseif (log2(ModOrd)/2 ~= ceil(log2(ModOrd)/2))
    disp("Invalid Modulation Order!");
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%% Initialize Channel Coding %%%%%%%%%%%%%%%%%%%%%%%%
Enc = comm.LDPCEncoder;
Dec = comm.LDPCDecoder;
K = 32400;
R = 1/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change to configure system
%%%%%%%%%%%%%%%%%%%%%%%%%% Set up MIMO System %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tx = 2;
Rx = 2;

f  = 900*10^6;
d  = 1;

%%%%%%%%%%%%%%%%%%%%%%%%% Set up OFDM Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
FFTlen = 64;
NumPivots = 4;
guard = [6;6];
PCidx = SetPCidx ( NumPivots, Tx, guard, FFTlen );
PulseShaping = true;
WindowLength = 8;
CPLength = 16;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change. 
c  = 3*10^8;
FSPL = c/(4*pi*d*f);

ofdmMod = comm.OFDMModulator('FFTLength',FFTlen,'PilotInputPort',true,...
    'PilotCarrierIndices',PCidx,'InsertDCNull',true,...
    'NumTransmitAntennas',Tx, 'CyclicPrefixLength', CPLength,'NumGuardBandCarriers',guard,...
    'Windowing',PulseShaping); 

if PulseShaping == true
    ofdmMod.WindowLength = WindowLength;
end


ofdmDemod = comm.OFDMDemodulator(ofdmMod);
ofdmDemod.NumReceiveAntennas = Rx;

ofdmModDim = info(ofdmMod);
numData = ofdmModDim.DataInputSize(1);  % Number of data subcarriers
numSym = ofdmModDim.DataInputSize(2);    % Number of OFDM symbols
numPilots = ofdmModDim.PilotInputSize;
LenFrame = ofdmMod.FFTLength + ofdmMod.CyclicPrefixLength;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE
% Displaying the carrier allocation :
% showResourceMapping(ofdmMod)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Be very careful when making changes below this point
% Only major supported changes are is the method of channel estimation used

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Simulation Parameters                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nofdm = numData * numSym * Tx * Nbits;

InputBlockSize = lcm(Nofdm,K);
OutputBlockSize = InputBlockSize/R;

errorRate = comm.ErrorRate;

% Defining the matrix that contains BER information
BER  = zeros(3,length(SNR));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Input Data                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = randi([0 1],InputBlockSize,1);

RxSignalFull = zeros(80,2);
TxSignalFull = zeros(80,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Monte Carlo simulations                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for idx = 1:length(SNR)
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
    
    % Using SNR value from here to compute noise variance
    variance = 10^(-SNR(idx)/10)/2;
    Demod.Variance = variance;
    stdev = sqrt(variance);
    
    for k = 1:N2
        % Modulating the data
        if ( defaultMod == true )
            modData = Mod(ofdmInput(:,k));
            modData = reshape(modData,numData,numSym,Tx);
        else
            modData = qammod(ofdmInput(:,k),ModOrd,...
            'InputType','bit','UnitAveragePower',true );
            modData = reshape(modData,numData,numSym,Tx);
        end
        
        % Generate pilot symbols
        PD = complex(rand(numPilots),rand(numPilots));

        % Modulate symbols using OFDM
        dataOFDM = ofdmMod(modData,PD);
        %TxSignalFull = [TxSignalFull;dataOFDM];

        % Create flat, i.i.d., Rayleigh fading channel
        chGain = complex(randn(Rx,Tx),randn(Rx,Tx))/sqrt(2) * FSPL;

        % Pass OFDM signal through Rayleigh and AWGN channels
        receivedSignal = dataOFDM*chGain + stdev*randn(LenFrame,Rx);
        

        % Demodulate OFDM data
        [receivedOFDMData,RPD] = ofdmDemod(receivedSignal);
        
        % Channel estimation :
        ChGainEst = ChannelEstimation(Tx,Rx,PD,RPD);
        
        % Channel inversion
        RxOFDM = reshape(receivedOFDMData, numData, Tx);
        RxOFDMEst = reshape(LMMSEInversion(Tx,Rx,ChGainEst,RxOFDM,variance), numData,1,Rx);

        % Demodulate QPSK data
        if ( defaultMod == true )
            ofdmOutput(:,k) = Demod(RxOFDMEst(:));
        else
            ofdmOutput(:,k) = qamdemod(RxOFDMEst(:),ModOrd,...
            'OutputType','approxllr','NoiseVariance',variance,...
            'UnitAveragePower',true );
        end
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
    toc;
end

BERs(PlotNumber,:) = BER(1,:);

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

function SymbolEst = LSEInversion(~,~,H,RxOFDM,~)
 
    SymbolEst = RxOFDM/H;
    
end

function SymbolEst = LMMSEInversion(Tx,~,H,RxOFDM,variance)

    SymbolEst = RxOFDM * H' / (H*H'+variance*eye(Tx,Tx));
    
end