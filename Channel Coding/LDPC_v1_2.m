% Please change ipath and opath to the input file and destination file
% paths
clc; close all; clear;
tic;
ipath = '/Users/sashank/Documents/MATLAB/Programs/PS/Learning/video.mp4';
opath = '/Users/sashank/Documents/MATLAB/Programs/PS/Learning/output.mp4';
EbNo  = 20;

fileID = fopen(ipath);
f = fread(fileID,'*ubit1', 'ieee-le');
f = int8(f);
sz = size(f);
rx = zeros(sz);

toc;

rx = ldpc(f, rx, EbNo);

toc;
    

% numBitErrs = sum(rx ~= f);
% disp(['Number of bit errors ( actual ) : ' num2str(numBitErrs)])

numBitErrs = biterr(rx,f);
disp(['Number of bit errors : ' num2str(numBitErrs)])

rx = int8(rx);
diff = f - rx;

fileID2 = fopen(opath,'w');
fwrite(fileID2, rx,'*ubit1');
fclose(fileID2);

toc;

function rx = ldpc(message, rx, EbNo)
    i = 1;
    nVar = 10^(-EbNo/10); 
    chan = comm.AWGNChannel('NoiseMethod','Variance','Variance',nVar);
    channel = comm.AWGNChannel('EbNo',EbNo,'BitsPerSymbol',1);

    bpskMod = comm.BPSKModulator;
    bpskDemod = comm.BPSKDemodulator('DecisionMethod', ...
    'Approximate log-likelihood ratio','Variance',nVar);
    
    %bpskDemod = comm.BPSKDemodulator();

    %qpskMod = comm.QPSKModulator;
    %qpskDemod = comm.QPSKDemodulator;
    
    ldpcEncoder = comm.LDPCEncoder;
    ldpcDecoder = comm.LDPCDecoder;
    
    constdiag = comm.ConstellationDiagram;
    
    K = 32400;
    
    pad = K - rem(length(message), K);
    
    message(end+1:end+pad)=0;
    disp(length(message));
    
    for v=1:K:length(message)
        sub = message(i:i+K-1);
        
        enc = ldpcEncoder(sub);
        mod = bpskMod(enc);
        rSig = channel(mod);
        constdiag(rSig);
        rxLLR = bpskDemod(rSig);
        rxBits = ldpcDecoder(rxLLR);
        rx(i:i+K-1) = rxBits;
        i = i + K;
    end
    rx(end-pad+1:end)=[];
end