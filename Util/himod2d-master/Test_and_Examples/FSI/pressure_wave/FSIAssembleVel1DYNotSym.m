function [Al,bl]=FSIAssembleVel1DYNotSym(Map,wyq,mb_k,mb_r,mb_yk,mb_yr,ne,...
    mesh_wx,nqnx,FEM_basis,FEM_basis_x,dt,nu,Force,Bx,By,...
    E,MBrobKY,MBrobRY,etadown_old,etaup_old)

% per ogni x (vettorialmente)
% calcola r^st_kr
r11v = ( nu*Map.Jac)*( mb_k.*mb_r.*wyq);
r10v = ( nu*Map.Jac.*Map.D)*( mb_k.*mb_yr .*wyq ) ...
     + (    Map.Jac.*Bx)*( mb_k  .*mb_r .*wyq );
r01v = ( nu*Map.Jac.*Map.D)*( mb_yk.*mb_r .*wyq );
r00v =(nu*Map.Jac.*(Map.D.^2+Map.J.^2) ) *(mb_yk.*mb_yr.*wyq ) ...
     + (    Map.Jac/dt ) *(mb_k.*mb_r.*wyq ) ...
     + (    Map.Jac.*(Map.D.*Bx+Map.J.*By))*(mb_yk .*mb_r .*wyq) ...
     + E*dt*Map.Aup*MBrobKY(1)*MBrobRY(1) ...
     + E*dt*Map.Adown*MBrobKY(2)*MBrobRY(2);
forcev = ( Map.Jac.*Force )*( mb_r.*wyq)...
        - E*etaup_old.*Map.Aup*MBrobRY(1) ...
        - E*etadown_old.*Map.Adown*MBrobRY(2);
    
nx=ne+1;

% Inizializzo le diagonali del blocco, si aumenta l'efficienza nell'assemblaggio di matrici sparse
maindiag =   zeros( ne + nx, 1);
diagsup  =   zeros( ne + nx, 1); % Spdiags taglierà il primo elemento
diaginf  =   zeros( ne + nx, 1); % Spdiags invece taglierà l'ultimo
diagsuper  = zeros( ne + nx, 1); % Spdiags taglierà i primi due elementi
diaginfer  = zeros( ne + nx, 1); % Spdiags invece taglierà gli ultimi due
bl         = zeros( ne + nx, 1);
for ie = 1 : ne  % Per ogni intervallo
    
    %(ie-1)*nqnx+1:ie*nqnx seleziona l'intervallo di punti corretto
    w = mesh_wx((ie-1)*nqnx+1:ie*nqnx); % Calcolo i pesi dell'intervallo in questione
    
    % Seleziono i coefficiweenti relativi all'intervallo in questione
    r11 = r11v ( (ie-1)*nqnx+1 : ie*nqnx)';
    r10 = r10v ( (ie-1)*nqnx+1 : ie*nqnx)';
    r01 = r01v ( (ie-1)*nqnx+1 : ie*nqnx)';
    r00 = r00v ( (ie-1)*nqnx+1 : ie*nqnx)';
    
    for i = 1:3                  % Per ogni funzione di forma EF test
        
        %selezione dei pezzi corretti per le basi FEM
        femb_i  = FEM_basis  ( i, :);
        femb_xi = FEM_basis_x( i, :);
        for j = 1:3             % Per ogni funzione di forma EF sol
            
            femb_j  = FEM_basis  ( j, :);
            femb_xj = FEM_basis_x( j, :);
            
            if(i==j)
                maindiag(2*ie+i-2)=maindiag(2*ie+i-2)+...
                    (  r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;                
            elseif(i==j+1 && i==2)
                diaginf(2*ie-1)=diaginf(2*ie-1)+(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j+1 && i==3)
                diaginf(2*ie)=diaginf(2*ie)+(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j+2)
                diaginfer(2*ie-1)=diaginfer(2*ie-1)+(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j-2)
                diagsuper(2*ie+1)=diagsuper(2*ie+1)+(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j-1 && i==2)
                diagsup(2*ie+1)=diagsup(2*ie+1)+( ...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
                
            elseif(i==j-1 && i==1)
                diagsup(2*ie)=diagsup(2*ie)+( ...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            end
        end
        bl(2*(ie-1)+i) = bl(2*(ie-1)+i) + ( forcev((ie-1)*nqnx+1:ie*nqnx)'.*femb_i )*w;
    end
end
Al=spdiags( [diaginfer,diaginf,maindiag,diagsup,diagsuper], -2:2, (ne+nx), (nx+ne) ); % Assegno le diagonali alla matrice A
end
