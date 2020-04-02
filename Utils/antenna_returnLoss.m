% return loss (dB) = 10 * log10(incident / reflected)

p_incident = 1;
p_reflection = linspace(0,1,1000);

close all
figure;
plot(p_reflection,10*log10(p_reflection.^-1));
xlabel('Reflected (%)');
set(gca,'xticklabels',compose('%2.0f',xticks*100));
ylabel('Return Loss (dB)');