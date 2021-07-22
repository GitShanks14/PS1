% Set M to be the modulation order : 
M = 256;

x = (0:M-1)';

y = qammod(x,M,'UnitAveragePower',true );
        
scatterplot(y)
        