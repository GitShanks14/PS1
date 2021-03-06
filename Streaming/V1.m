%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to vary Eb/No and plot variation of BER  %
% for various diversity orders                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clear; clc;
tic;

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
%FSPL = 1;

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

%showResourceMapping(ofdmMod)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Input Data                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EbNo = 100;
Nofdm = numData * numSym * Tx * Nbits;

InputBlockSize = lcm(Nofdm,K);
OutputBlockSize = InputBlockSize/R;

% Calculating convenient dimensions
N1 = InputBlockSize/K;
N2 = OutputBlockSize/Nofdm;

constdiag = comm.ConstellationDiagram;

ipath = '/Users/sashank/Documents/MATLAB/Programs/PS/Learning/video.mp4';
opath = '/Users/sashank/Documents/MATLAB/Programs/PS/Learning/output.mp4';

fileID = fopen(ipath,'r');
fileID2 = fopen(opath,'w');

frewind(fileID);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Transmission loop                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read from file
%sub = fread(fileID, InputBlockSize, '*ubit1', 'ieee-le');    
%sub = fread(fileID, '*ubit1', 'ieee-le');    

streaming = true;

Gains = ones(Rx,Tx,1);
gctr = 2;

while streaming
    % Find current position and new position
    current = ftell(fileID);
    sub = fread(fileID, InputBlockSize, '*ubit1', 'ieee-le');
    newpos = ftell(fileID);

    % Check if read successful
    if((newpos-current) ~= (InputBlockSize/8))
        t0 = clock;
        % Wait for the source to catch up
        while etime(clock, t0) < 5
            fseek(fileID,-(newpos-current),'cof');
            pause(0.05);
            sub = fread(fileID, InputBlockSize, '*ubit1', 'ieee-le');
            newpos = ftell(fileID);

            % Check if read successful the second time
            if((newpos-current) == (InputBlockSize/8))
                break;
            end
        end

        % If read fails. ie if timeout.
        if etime(clock, t0) >= 5
            streaming = false;
            % Zero padding
            p = InputBlockSize - rem(length(sub), InputBlockSize);
            if(p == InputBlockSize)
                p = 0;
            end
            disp("Terminating livestream");
            sub(end+1:end+p)=0;
        end
    end
    data = sub;
    
    % Reshape bit array into LDPC convenient format
    TransData = reshape(data,K,N1);
    EncData = zeros(K/R,N1);

    % Loop encode LDPC
    for LDPCframe = 1:N1
        EncData(:,LDPCframe) = Enc(TransData(:,LDPCframe));
    end

    % Reshape for OFDM
    ofdmInput = reshape(EncData,Nofdm,N2);
    ofdmOutput = zeros(Nofdm,N2);

    % Using EbNo value from here to compute noise variance
    Demod.Variance = 10^(-EbNo/10);

    for k = 1:N2
        % Modulating the data
        modData = Mod(ofdmInput(:,k));
        modData = reshape(modData,numData,numSym,Tx);

        % Generate pilot symbols
        PD = complex(rand(numPilots),rand(numPilots));

        % Modulate symbols using OFDM
        dataOFDM = ofdmMod(modData,PD);

        % Create flat, i.i.d., Rayleigh fading channel
        chGain = complex(randn(Rx,Tx),randn(Rx,Tx))/sqrt(2);
        Gains(:,:,gctr) = chGain;
        gctr = gctr + 1;
        chGain = chGain * FSPL;

        % Pass OFDM signal through Rayleigh and AWGN channels
        receivedSignal = awgn(dataOFDM*chGain,EbNo);

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
        ofdmOutput(:,k) = Demod(RxOFDMEst(:));
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
    fwrite(fileID2, OutData,'*ubit1');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Winding up                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Closing files
fclose(fileID);
fclose(fileID2);

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

