# PS1 : SDR Design for HD Video Transmission

Prepared in partial fulfillment of the Practice School 1 course, 2021. <br />
We thank BITS Pilani and M.C.E.M.E. for this opportunity. <br />

## Problem Statement : 
Implement a MIMO-OFDM system that employs polar coding, on a USRP n210 / b210, and transmit compressed HD video through the system designed. The system must be able to stream as well as transfer files. The HD video must be compressed using the H.264 / H.265 schemes. 

## Team : 
Sashank Krishna S <br />
2019A8PS0184

Aditya Soni <br />
2019A8PS1282H

## Mentors: 
Industry Mentor:  AEE Naveen Reddy, Executive Engineer, M.C.E.M.E. <br />
Faculty Mentor:   Dr. Rahul Singhal, Assistant Professor, BITS Pilani <br />

## Structure : 
### MIMO-OFDM : 
This folder contains all the previous versions implemented along the way to the final implementation. The files in this folder can be used to plot the BER vs SNR performance of a system, after setting it's parameters. 

### Channel Coding : 
This folder contains the intermediate versions of the different channel coding schemes implemented before finalizing one for the final system.

### Integration :
This folder contains the intermediate versions of the integrated final products. 

### Streaming : 
This folder contains the versions optimized for streaming using the LDPC + MIMO-OFDM system. The parameters of the system can be freely changed.

### Transfer : 
This folder contains the versions optimized for file transfer using the LDPC + MIMO-OFDM system. The parameters of the system can be freely changed.

### Utility : 
This folder contains various useful scripts for the analysis of the system designed. Things such as the plotting of the OFDM spectrum alongside the resource allocation, detection and reasoning out of burst errors, and the plot based comparison of different systems can be done here. 

### FFmpeg scripts : 
This folder contains the a few prominent FFmpeg scripts used for this project.


note : All files with the file name containing "test", were meant for debugging purposes. 
