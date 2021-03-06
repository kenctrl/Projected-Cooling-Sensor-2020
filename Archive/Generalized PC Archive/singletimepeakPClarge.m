function [v_PC] = singletimepeakPClarge(N,dt,a,m,subdivisions,Hobj)
H = HPCconstr(N,a,m,Hobj);
v = wavefunctionPC(N);

psi1 = zeros(2*N);
psi1(:,1) = exponentiate(v,H,-i*dt,subdivisions);

V0 = psi1(1,1) + psi1(2,1);
V1 = psi1(N+1,1) + psi1(N+2,1);
v_PC = [V0;V1];
index = find(abs(v_PC) == max(abs(v_PC)));
v_PC = v_PC/v_PC(index);