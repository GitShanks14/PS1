%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Init Figure                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = figure;
grid on;
ax = fig.CurrentAxes;
hold(ax,'on');
ax.YScale = 'log';
xlim(ax,[SNR(1), SNR(end)]);
ylim(ax,[1e-4 1]);
xlabel(ax,'Eb/No (dB)');
ylabel(ax,'BER');
fig.NumberTitle = 'off';
fig.Renderer = 'zbuffer';
fig.Name = 'BER vs. SNR';
title(ax,'Error rate vs. SNR');
set(fig, 'DefaultLegendAutoUpdate', 'off');
fig.Position = figposition([15 50 25 30]);

% Write the plot names in the same order as the execution of the scripts. 
legend_text = [ '16  QAM' 
                '64  QAM'
                '256 QAM'
              ];

% Write the desired colour coding here : 
color_text = [ '-go'; '-ro' ; '-bo' ];
                

for i = 1:NScripts
    %semilogy(ax,SNR, BERs(i,:), color_text(i,:));
    fitBER = berfit(SNR, BERs(i,:));
    semilogy(ax,SNR, fitBER, color_text(i,:));
end

legend(ax,legend_text);

% Plot line fit
hold(ax,'off');