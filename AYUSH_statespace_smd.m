function y = AYUSH_statespace_smd(p,u,t,x0,c)

mass = c;

%parameters will be in the form [-c/m; -k/m; 1/m]

A = [0 1; p(2) p(1)];

B = [0; 1/mass];

dt = t(2)-t(1);
N  = length(t);

x = zeros(2,N);      % defining state variable with rows x and v, 1 column for each time step
x(:,1) = x0(:);      % setting initial state

% ----- simulate -----
for i = 1:N-1

    k1 = A*x(:,i) + B*u(i);
    k2 = A*(x(:,i)+0.5*dt*k1) + B*u(i);
    k3 = A*(x(:,i)+0.5*dt*k2) + B*u(i);
    k4 = A*(x(:,i)+dt*k3) + B*u(i);
    
    x(:,i+1) = x(:,i) + dt/6*(k1+2*k2+2*k3+k4);

end

y = x(1,:)';   % return position as Nx1 column

end