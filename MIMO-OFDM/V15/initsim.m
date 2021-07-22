c  = 3*10^8;
FSPL = c/(4*pi*d*f);

Nofdm = numData * numSym * Tx * Nbits;
InputBlockSize = lcm(Nofdm,K);
OutputBlockSize = InputBlockSize/R;

errorRate = comm.ErrorRate;

% Defining the matrix that contains BER information
BER  = zeros(3,length(SNR));
constdiag = comm.ConstellationDiagram;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Plotting                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = figure;
grid on;
ax = fig.CurrentAxes;
hold(ax,'on');
ax.YScale = 'log';
xlim(ax,[SNR(1), SNR(end)]);
ylim(ax,[1e-4 1]);
xlabel(ax,'SNR (dB)');
ylabel(ax,'BER');
fig.NumberTitle = 'off';
fig.Renderer = 'zbuffer';
fig.Name = 'BER vs. SNR';
title(ax,'Error rate vs. Energy per symbol');
set(fig, 'DefaultLegendAutoUpdate', 'off');
fig.Position = figposition([15 50 25 30]);
