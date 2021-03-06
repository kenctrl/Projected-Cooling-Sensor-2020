clear all
close all

L = 100;
D_object = 2;
maxeig = 0.8;
nrepeat = 30;
r = [0:L-1];

H_reservoir = ...
    - sparse(mod(r+1,L)+1,r+1,0.5) ...
    - sparse(mod(r-1,L)+1,r+1,0.5);

% H_object = rand(D_object,D_object) + i*rand(D_object,D_object);
% H_object = 0.5*(H_object + H_object');
H_object = [1 0; 0 -1];

list = sort(eig(H_object));
H_object_new = H_object-(list(1)+list(end/2))/2*eye(D_object);
scale = max(eig(H_object_new));
H_object_new = H_object_new/scale*maxeig;

H = sparse(D_object*L,D_object*L);
for ii = 0:D_object-1 
    H(ii*L+[0:L-1]+1,ii*L+[0:L-1]+1) = H_reservoir;
end

for jj = 0:D_object-1
    for ii = 0:D_object-1
        H(ii*L+1,jj*L+1) = H(ii*L+1,jj*L+1) + H_object_new(ii+1,jj+1)/2.0;
        H(ii*L+2,jj*L+1) = H(ii*L+2,jj*L+1) + H_object_new(ii+1,jj+1)/2.0;
        H(ii*L+1,jj*L+2) = H(ii*L+1,jj*L+2) + H_object_new(ii+1,jj+1)/2.0;
        H(ii*L+2,jj*L+2) = H(ii*L+2,jj*L+2) + H_object_new(ii+1,jj+1)/2.0;
    end
end

[vv,dd] = eig(H_object);
[ee,ord] = sort(diag(dd));
index = find(abs(vv(:,ord(1))) == max(abs(vv(:,ord(1)))));
vv_exact = vv(:,ord(1))/vv(index,ord(1));

vobject_init = zeros(D_object,1);
v_init = zeros(D_object*L,1);

for ii = 0:D_object-1
    vobject_init(ii+1) = (rand-0.5) + i*(rand-0.5);
end

dt = 0.5;
Lt = floor(L/dt*0.8);

for ntrial = 1:nrepeat
    
    for ii = 0:D_object-1
        v_init(ii*L+1) = vobject_init(ii+1,1);
        v_init(ii*L+2) = vobject_init(ii+1,1);       
    end
    psi1(:,1) = lee_final_exponentiate(v_init,H,-i*dt,10);
    
    for nt = 1:Lt
        psi1(:,nt+1) = lee_final_exponentiate(psi1(:,nt),H,-i*dt,10);
    end
    
    figure(ntrial)
    hold on
    for ii = 0:D_object-1
        plot(dt*[1:Lt],log(abs(psi1(ii*L+1,1:Lt)+psi1(ii*L+2,1:Lt)).^2))
    end
    hold off
    
    for ii = 0:D_object-1
        v_PC(ii+1,1) = psi1(ii*L+1,Lt) + psi1(ii*L+2,Lt);
    end
    index = find(abs(v_PC) == max(abs(v_PC)));
    
    ntrial
    v_PC = v_PC/v_PC(index);
    [v_PC vv_exact]
    
    initial_overlap(ntrial,1) = (abs(vv_exact'*vobject_init))^2 ...
        /((vv_exact'*vv_exact)*(vobject_init'*vobject_init));
    final_overlap(ntrial,1) = (abs(v_PC'*vv_exact))^2 ...
        /((vv_exact'*vv_exact)*(v_PC'*v_PC));
    
    initial_overlap(ntrial,1)
    final_overlap(ntrial,1)
    
    vobject_init = v_PC;
    
end

"initial"
initial_overlap(1)
"overlaps"
final_overlap

figure(nrepeat+1)
plot(log(1-final_overlap))
xlabel('Iteration','FontSize',16);
ylabel('Ln(Error) of Calculated Ground State','FontSize',16);
title('Arbitrary 30x30','FontSize',16);

eig(H_object_new)

