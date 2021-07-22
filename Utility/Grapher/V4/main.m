%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Plotter Main                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make the following changes and run the system once per system 
% 1. call the param file corresponding to the system below.
% 2. Set PlotNumber = the system number that you are plotting now. 

param2;
PlotNumber = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Be very careful when making changes below this point
% Only supported change is the changing of channel estimation method used


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
    
    % Using EbNo value from here to compute noise variance
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
        
        %%Caution : Displaying the constellation makes the code very slow.
        if ( DispConst == true )
            constdiag(RxOFDMEst(:));
        end

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
    % RxSignalFull = zeros(80,2);
    fprintf('\nSymbol error rate = %d from %d errors in %d symbols at an SNR of %d dB\n',BER(:,idx),SNR(idx));
    toc;
end

BERs(PlotNumber,:) = BER(1,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Function definitions                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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