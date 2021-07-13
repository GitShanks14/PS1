
fileID = fopen('klee_hevc.mkv');

fileID2 = fopen('outKlee.mkv','w');

ldpc(fileID, fileID2);
    
%numBitErrs = biterr(rx,f);
%disp(['Number of bit errors: ' num2str(numBitErrs)])

%rx = int8(rx);
%diff = f - rx;

%fwrite(fileID2, rx,'*ubit1');
fclose(fileID);
fclose(fileID2);

function ldpc(fileID, fileID2)
    i = 1;
    EbNo = 1;
    nVar = 10^(-EbNo/10);
    chan = comm.AWGNChannel('NoiseMethod','Variance','Variance',nVar);
    %channel = comm.AWGNChannel('EbNo',EbNo,'BitsPerSymbol',1);

    bpskMod = comm.BPSKModulator;
    bpskDemod = comm.BPSKDemodulator('DecisionMethod', ...
    'Approximate log-likelihood ratio','Variance',nVar);

    qpskMod = comm.QPSKModulator('BitInput', true);
    qpskDemod = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod', ...
    'Approximate log-likelihood ratio','Variance',nVar);
    
    ldpcEncoder = comm.LDPCEncoder;
    ldpcDecoder = comm.LDPCDecoder;
    
    constdiag = comm.ConstellationDiagram;
    
    K = 32400;

    frewind(fileID);
    numBitErrs = 0;
    
    while true
        sub = fread(fileID, 32400, '*ubit1', 'ieee-le');    
        
        p = K - rem(length(sub), K);
        if(p == K)
            p = 0;
        end
        sub(end+1:end+p)=0;
        
        enc = ldpcEncoder(sub);
        mod = qpskMod(enc);
        rSig = chan(mod);
        %constdiag(rSig);
        rxLLR = qpskDemod(rSig); 
        rxBits = ldpcDecoder(rxLLR);
        rxBits = uint8(rxBits);
        numBitErrs = numBitErrs + biterr(rxBits,sub);
        i = i + K;       
        if(p~=0)
            rxBits(end-p+1:end)=[];
            fwrite(fileID2, rxBits,'*ubit1');
            break;
        end
        fwrite(fileID2, rxBits,'*ubit1');
    end
    disp(['Number of bit errors: ' num2str(numBitErrs)])
end