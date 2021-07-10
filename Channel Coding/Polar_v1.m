
msg = randi([0 1],10000,1,'int8');
msgrx = zeros(size(msg));

%reader = dsp.BinaryFileReader('theoretical.png','DataType','uint8','SamplesPerFrame',16);
%readerData = reader();
%f = dec2bin(readerData);
%binData = de2bi(readerData);



fileID = fopen('theoretical.png');
f = fread(fileID,'*ubit1', 'ieee-le');
f = int8(f);
sz = size(f);
rx = zeros(sz);

rx = polar(f, rx);
    
numBitErrs = biterr(rx,f);
disp(['Number of bit errors: ' num2str(numBitErrs)])

rx2 = int8(rx);
diff = f - rx2;

fileID2 = fopen('out.png','w');
fwrite(fileID2, rx,'*ubit1');
fclose(fileID2);

function rx = polar(message, rx)
    i = 1;
    nVar = 1.5; 
    chan = comm.AWGNChannel('NoiseMethod','Variance','Variance',nVar);
    channel = comm.AWGNChannel('EbNo',-2,'BitsPerSymbol',1);

    bpskMod = comm.BPSKModulator;
    bpskDemod = comm.BPSKDemodulator('DecisionMethod', ...
    'Approximate log-likelihood ratio','Variance',nVar);

    qpskMod = comm.QPSKModulator;
    qpskDemod = comm.QPSKDemodulator;

    K = 164;
    E = 300;
    
    pad = K - rem(length(message), K);
    
    message(end+1:end+pad)=0;
    disp(length(message));
    
    for v=1:K:length(message)
        sub = message(i:i+K-1);
        
        enc = nrPolarEncode(sub,E);
        mod = bpskMod(enc);
        rSig = channel(mod);
        rxLLR = bpskDemod(rSig); 

        L = 4;
        rxBits = nrPolarDecode(rxLLR,K,E,L);
        rx(i:i+K-1) = rxBits;
        i = i + K;
        %disp(i);
    end
    rx(end-pad+1:end)=[];
end