close all; clear; clc;

% Set x axis range
SNR = 50:5:90;

% Set number of scripts to be run
NScripts = 3;

BERs = zeros( NScripts, length(SNR) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Make sure to set the plot number properly in all scripts      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%