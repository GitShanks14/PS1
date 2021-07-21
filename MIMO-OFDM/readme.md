# Documentation

## Version History
V0 to 4 gradually add minor features. <br />
V5 saw the addition of automatic selection of pilot carrier indices. <br />
V6 saw the addition of Free-Space Path loss. <br />
V7 set up for the grapher. <br />
V8 saw minor improvements <br />
V9 introduced frame-based OFDM inputs <br />
V10 introduced LLR QPSK and BPSK demodulation <br />
V11 allowed for the transmission of one coded block <br /> 
V12 introduced more modular channel estimation and inversion, and also saw the introduction of LMMSE channel inversion. <br />
V13 onwards, the system uses SNR and not Eb/No. 
V14 re-introduced QAM into the system. QAM was discontinued when the system started using scripts instead of Simulink models. 

## Features
1. Can switch between BPSK, QPSK and M-QAM by just specifying modulation order. 
2. Can specify the number of transmitter and receiver antennas ( square systems only ).
3. Can set the centre frequency and distance to model path loss.
4. Can change all parameters of the OFDM system : 
a. Number of subcarriers
b. Number of Pilot carriers
c. Number of left and right guard carriers
d. Toggle Pulse Shaping
e. Set windowing length for Pulse Shaping
f. Change Cyclic Prefix length