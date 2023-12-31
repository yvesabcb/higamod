ne=400;
nx=ne+1;
nqnx=4;
mesh_x=linspace(0,1,nx);
%Setting up a quadrature rule for the x direction.
[~, node_x, weights_x] = gausslegendre( 4 );
quad_nodes_mesh_x = zeros( ne*4, 1);
quad_weights_mesh_x = zeros( ne*4, 1);
for i=1:ne
    [ ...
        quad_nodes_mesh_x( (i-1)*4+1 : i*4 ), ...
        quad_weights_mesh_x( (i-1)*4+1 : i*4 ) ...
        ] = quadrature_rule( mesh_x(i), mesh_x(i+1), node_x, weights_x);
end
mesh_wx=quad_weights_mesh_x;
[ FEM_basis , FEM_basis_x]=fembasis(2,mesh_x(1:2),quad_nodes_mesh_x(1:4));
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
    r11 = 1;
    r10 = 0;
    r01 = 0;
    r00 = 0;
    
    for i = 1:3                  % Per ogni funzione di forma EF test
        
        %selezione dei pezzi corretti per le basi FEM
        femb_i  = FEM_basis  ( :, i)';
        femb_xi = FEM_basis_x( :, i)';
        for j = 1:3             % Per ogni funzione di forma EF sol
            
            femb_j  = FEM_basis  ( :, j)';
            femb_xj = FEM_basis_x( :, j)';
            
            if(i==j)
                maindiag(2*ie+i-2)=maindiag(2*ie+i-2)+...
                    (  r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
                
            elseif(i==j+1 && i==2)
                diaginf(2*ie-1)=(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j+1 && i==3)
                diaginf(2*ie)=(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j+2)
                diaginfer(2*ie-1)=(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j-2)
                diagsuper(2*ie+1)=(...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            elseif(i==j-1 && i==2)
                diagsup(2*ie+1)=( ...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
                
            elseif(i==j-1 && i==1)
                diagsup(2*ie)=( ...
                    r11.*femb_xi.*femb_xj ...
                    + r01.*femb_xi.*femb_j...
                    + r10.*femb_i.*femb_xj ...
                    + r00.*femb_i.*femb_j  ...
                    )*w;
            end
        end
        bl(2*(ie-1)+i) = bl(2*(ie-1)+i) + ( 1.*femb_i )*w;
    end
end
Al=spdiags( [diaginfer,diaginf,maindiag,diagsup,diagsuper], -2:2, (ne+nx), (nx+ne) ); % Assegno le diagonali alla matrice A

Al(1,1)=1e30;
bl(1)=1e30;
Al(end,end)=1e30;
bl(end)=1e30;

u=Al\bl;
h=(mesh_x(2)-mesh_x(1))/2;
xd=0:h:1;
plot(xd,u);
hold on
plot(xd,0.5*xd.*(1-xd)+1,'dr')