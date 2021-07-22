%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Init Figure                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;

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
title(ax,'Error rate vs. SNR');
set(fig, 'DefaultLegendAutoUpdate', 'off');
fig.Position = figposition([15 50 25 30]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Plot settings                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write the plot names in the same order as the execution of the scripts. 
% Pad the text with spaces such that the length of each string is constant.
legend_text = [ ' LSE   + LSE    '
                ' LSE   + LMMSE  '
                ' ideal + LSE    ' 
                ' ideal + LMMSE  '
              ];

% Place the desired colour coding here. Set CustomColours to false for
% the default
CustomColours = true;
color_text = [ '-go'; '-ro' ; '-bo' ; '-yo'];
                

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Plotter                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:NScripts
    fitBER = berfit(SNR, BERs(i,:));
    if ( CustomColours == true )
        semilogy(ax,SNR, fitBER, color_text(i,:));
    else 
        semilogy(ax,SNR, fitBER);
    end
end

legend(ax,legend_text);