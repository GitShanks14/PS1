close all; clear; clc;

% Set x axis range
SNR = 0:5:90;

% Set number of scripts to be run
NScripts = 4;

BERs = zeros( NScripts, length(SNR) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Make sure to set the plot number properly in all scripts      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%