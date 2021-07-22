# LSE vs LMMSE comparison

The MIMO-OFDM script offers two ways to estimate the signal, and one way to estimate the channel matrix. 
Both LSE and LMMSE can be used to estimate the signal, whereas as of right now, only LSE can be used to find the channel matrix. <br />

This script plots and compares the following 4 cases : 
1. LSE channel estimate + LSE signal estimate
2. LSE channel estimate + LMMSE signal estimate
3. Ideal channel estimate + LSE signal estimate
4. Ideal channel estimate + LMMSE signal estimate
