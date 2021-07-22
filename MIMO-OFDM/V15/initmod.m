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

% initialize channel coding objects
Enc = comm.LDPCEncoder;
Dec = comm.LDPCDecoder;
K = 32400;
R = 1/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
