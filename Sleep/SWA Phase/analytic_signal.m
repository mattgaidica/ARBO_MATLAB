function z = analytic_signal(x)
%x is a real-valued record of length N, where N is even %returns the analytic signal z[n]
x = x(:); %serialize
N = length(x);
X = fft(x,N);
z = ifft([X(1); 2*X(2:N/2); X(N/2+1); zeros(N/2-1,1)],N);
end