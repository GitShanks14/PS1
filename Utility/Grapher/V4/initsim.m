c  = 3*10^8;
FSPL = c/(4*pi*d*f);

Nofdm = numData * numSym * Tx * Nbits;
InputBlockSize = lcm(Nofdm,K);
OutputBlockSize = InputBlockSize/R;

errorRate = comm.ErrorRate;

% Defining the matrix that contains BER information
BER  = zeros(3,length(SNR));
constdiag = comm.ConstellationDiagram;
