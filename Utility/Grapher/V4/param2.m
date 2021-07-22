%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The purpose of this script is to vary Eb/No and plot variation of BER  %
% for various diversity orders                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize Mod / Demod
ModOrd = 16;

initmod;

% Set up MIMO system
Tx = 2;
Rx = 2;

% Set the centre frequency and distance in metres. 
f  = 900*10^6;
d  = 1;

% Set up OFDM system
FFTlen = 64;
NumPilots = 4;
guard = [6;6];
PulseShaping = false;
WindowLength = 8;
CPLength = 16;

% Set DispResMap to true to display the resource allocation map.
DispResMap = false;

initOFDM;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Simulation Parameters                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set DispConst to true for seeing the constellation diagram
DispConst = false;

initsim;