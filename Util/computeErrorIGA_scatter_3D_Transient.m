function [errL2,errH1,MeshStruct] = computeErrorIGA_scatter_3D_Transient(size_mb,a_ril,b_ril,cutx,...
                                                                         hx, u,bc_up,bc_down,Coeff_forma,...
                                                                         caso,p,k,space,geometry,map,geoInfo,...
                                                                         iteration,timeDomain,MeshAux)

        % SETTING THE NUMBER OF NODES AND INTERVALS

    ne = round((cutx(2)-cutx(1))/hx);   % Number of Intervals

    nnx = ne*(p - k) + k + 1;           % Number of Control Point on the X Direction
                                        % for the IGA Mesh

    % SETTING THE NUMBER OF MODALS IN THE Y DIRECTION

    M = 150;

    % CREATION OF THE MESH CONTAINING THE POINTS IN THE Y DIRECTION
    % USED TO EVALUATE THE MODAL BASIS

    evalNodesTrans = linspace(0,1,M);

    % INITIALIZATION OF THE SOLUTION MATRICES

    sol   = zeros(nnx,M,M);

    import Core.BasisHandler
    
    % LEGENDRE MODAL BASIS
    
%     obj_newModalBasis = BasisHandler();
%             
%     obj_newModalBasis.dimLegendreBase = size_mb;
%     obj_newModalBasis.evalLegendreNodes = evalNodesTrans;
%     obj_newModalBasis.labelUpBoundCond = bc_up{1};
%     obj_newModalBasis.labelDownBoundCond = bc_down{1};
%     obj_newModalBasis.coeffForm = Coeff_forma;
% 
%     [coeffModalBase,~,~] = newModalBasisLegendre3D(obj_newModalBasis);
    
    % EDUCATED MODAL BASIS

    obj_newModalBasis = BasisHandler();

    obj_newModalBasis.dimModalBasis         = size_mb;
    obj_newModalBasis.evalNodesY            = evalNodesTrans;
    obj_newModalBasis.labelUpBoundCond      = bc_up{1};
    obj_newModalBasis.labelDownBoundCond    = bc_down{1};
    obj_newModalBasis.coeffForm             = Coeff_forma;

    [coeffModalBase,~,~] = newModalBasis3D(obj_newModalBasis);
    
    disp('FINISHED COMPUTE MODAL BASIS for PLOT')

    %---------------------------------------------------------------------%
    % Note:
    % The coefficients 'coeffModalBase' and 'coeffModalBaseDer' are
    % vectors conrresponding respectively to the coefficients of the
    % modal bases and derivative of the modal basis on the points
    % assigned in the Y direction.
    %---------------------------------------------------------------------%

    % SETTING OF THE ISOGEOMETRIC MESH IN THE X DIRECTION
    
    xx3 = {linspace(cutx(1),cutx(2),nnx)};
    evalNodesX = linspace(cutx(1),cutx(2),nnx);

    %---------------------------------------------------------------------%
    % Note:
    % The function 'bspeval' used in the following loops is taken from
    % the NURBS toolbox and its primary objective is to evaluate a 
    % univariate B-Spline function in the desired nodes.
    %
    % The parameter involved in this functions are (in order):
    %
    % (1ST INPUT) Degree of the B-Spline;
    % (2ND INPUT) Control Points, matrix of size (dim,nc), where 'dim' 
    %             is the degree of the B-Spline function and 'nc' is
    %             the number of control points.
    % (3RD INPUT) Knot sequence, row vector of size nk, where 'nk' is
    %             the number of knot points.
    % (4TH INPUT) Parametric evaluation points, row vector of size nu,
    %             where 'nu' is the number of points used to represent
    %             the domain.
    %
    % (OUTPUT) Evaluated points, matrix of size (dim,nu).
    %---------------------------------------------------------------------%
    
    switch caso
            case {1,2,3,4,5,6,7,8,9,10}
            for m = 1:size_mb^2
                
                approx((m-1)*nnx+1:m*nnx)  = sp_eval(u((m-1)*nnx+1:m*nnx), space, geometry, xx3);
                dapprox((m-1)*nnx+1:m*nnx) = sp_eval(u((m-1)*nnx+1:m*nnx), space, geometry, xx3,'gradient');

            end

            % COMPUTATION OF THE NURBS BASE

            u  = approx';

            % COMPUTATION OF THE DERIVATIVE OF THE NURBS BASE

            ux = dapprox';
    end
    
    disp('FINISHED APPLY ISO ANALYSIS for PLOT')

    solMat = zeros(M,M,nnx);

    for h = 1:nnx

        for k = 1:M
            
            for j = 1:M

                for imb = 1:size_mb^2

                    % COMPUTATION OF THE APPROXIMATED SOLUTION VECTOR FIELD
                    % EVALUATED IN THE POINTS OF THE DOMAIN MESH

                    sol(h,k,j)   = sol(h,k,j)   + u(h+(imb-1)*nnx)*coeffModalBase(k,j,imb);
                    % solVect(h + (k-1)*nnx) = solVect(h + (k-1)*nnx) + u(h+(imb-1)*nnx)*coeffModalBase(k,j,imb);

                    % COMPUTATION OF THE DERIVATIVE OF THE APPROXIMATED
                    % SOLUTION VECTOR FIELD EVALUATED IN THE POINTS OF THE
                    % DOMAIN MESH

                    % sol_x(h,k) = sol_x(h,k) + ux(h+(imb-1)*nnx)*coeffModalBase(k,imb);
                    % sol_y(h,k) = sol_y(h,k) + u(h+(imb-1)*nnx)*coeffModalBaseDer(k,imb);

                end

            % sol(h,k) = sol(h,k)+ a_ril(1) * evalNodesTrans(k) + b_ril(1);
        
            end

        end

    end
    
    disp('FINISHED APPLY MODAL ANALYSIS for PLOT')
    
    for ii = 1:M
        for jj = 1:M
            for kk = 1:nnx
                solMat(ii,jj,kk) = sol(kk,ii,jj);
            end
        end
    end
    
    disp('FINISHED EXTRACTING THE HIGAMOD SOLUTION');
    
    type = geoInfo.Type;
    
    [X,Y,Z] = mapOut3DHiMod(evalNodesX,evalNodesTrans,evalNodesTrans,geoInfo,type);
    
    % Create the Freefem++ simulation folder
    
    for ii = 1:1000
        
        checkFolder = exist(['MatlabPlots3D_SimCase',num2str(ii)]);
        
        if (checkFolder == 7)
        else
            fileName = ['MatlabPlots3D_SimCase',num2str(ii-1)];
            break
        end
    end

%     % PLOT SLICES
% 
%     set(gcf, 'Renderer', 'OpenGL')
%     fig1 = figure('visible','off');
%     scatter3( X(:), Y(:), Z(:), 3, solMat(:))
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
%     xlabel('X')
%     ylabel('Y')
%     zlabel('Z')
%     title('Concentration')
%     axis equal
%     az = 45;
%     el = 30;
%     view(az, el);
%     colorbar
%     
%     % SAVE PLOT
%     
%     print(fig1,['Plot_At_t=',num2str(iteration),'.jpg'],'-djpeg')
%     
    
    
%     return
%     

    if(iteration == 1)
        
%         fileToRead1 = [pwd,'/Geometry/3D_',geoInfo.Type,'/ff/ffMesh.mesh'];
%         fileToRead2 = [pwd,'/Geometry/3D_',geoInfo.Type,'/ff/ffSolution.sol'];
%         fileToRead3 = [pwd,'/Geometry/3D_',geoInfo.Type,'/ff/A.txt'];
%         fileToRead4 = [pwd,'/Geometry/3D_',geoInfo.Type,'/ff/M.txt'];

        Type = 'Patient_1';

        fileToRead1 = [pwd,'/Geometry/3D_',Type,'/ff/ffMesh.mesh'];
        fileToRead2 = [pwd,'/Geometry/3D_',Type,'/ff/ffSolution.sol'];
        fileToRead3 = [pwd,'/Geometry/3D_',Type,'/ff/A.txt'];
        fileToRead4 = [pwd,'/Geometry/3D_',Type,'/ff/M.txt'];


        [structMesh,ffSol,stiffMat,massMat] = my_FFimportfilemesh_3D(fileToRead1, ...   
                                                                 fileToRead2, ...
                                                                 fileToRead3, ...
                                                                 fileToRead4);
                                                         
        disp('FINISHED EXTRACTING THE FREEFEM++ SOLUTION');
        
        MeshStruct.structMesh = structMesh;
        MeshStruct.ffSol = ffSol;
        MeshStruct.stiffMat = stiffMat;
        MeshStruct.massMat = massMat;
        
        pts = structMesh.Points;
        higaSol = griddata(X,Y,Z,solMat,pts(:,1),pts(:,2),pts(:,3));

        [numbElem] = size(higaSol,1);
        INAN = find(isnan(higaSol));

        aux = higaSol;

        for ii = 1:numbElem
            if(isnan(higaSol(ii)))
                higaSol(ii) = 0;
            end
        end

        disp('STARTED EXPORTING FILE .VTK')

        element_num = structMesh.NumbElements;
        element_order = structMesh.ElementOrder;
        node_num = structMesh.NumbNodes;
        element_node = structMesh.Elements;
        xyz = [pts(:,1),pts(:,2),pts(:,3)]';
        uvw = 0 .* [pts(:,1),pts(:,2),pts(:,3)]';

        fileVTK = ['HigaSol',num2str(iteration),'.vtk'];

        % Open the new folder created

        cd(fileName);

        fid = fopen(fileVTK,'w');
        vtk_puvw_write (fid, fileVTK, node_num, element_num, ...
                        element_order, xyz, element_node', higaSol', uvw )
        fclose(fid);

        cd ..

        disp('FINISHED EXPORTING FILE .VTK')

    else
        
        MeshStruct = MeshAux;
        pts = MeshAux.structMesh.Points;
        higaSol = griddata(X,Y,Z,solMat,pts(:,1),pts(:,2),pts(:,3));

        [numbElem] = size(higaSol,1);
        INAN = find(isnan(higaSol));

        aux = higaSol;

        for ii = 1:numbElem
            if(isnan(higaSol(ii)))
                higaSol(ii) = 0;
            end
        end

        disp('STARTED EXPORTING FILE .VTK')

        element_num = MeshAux.structMesh.NumbElements;
        element_order = MeshAux.structMesh.ElementOrder;
        node_num = MeshAux.structMesh.NumbNodes;
        element_node = MeshAux.structMesh.Elements;
        xyz = [pts(:,1),pts(:,2),pts(:,3)]';
        uvw = 0 .* [pts(:,1),pts(:,2),pts(:,3)]';

        fileVTK = ['HigaSol',num2str(iteration),'.vtk'];

        % Open the new folder created

        cd(fileName);

        fid = fopen(fileVTK,'w');
        vtk_puvw_write (fid, fileVTK, node_num, element_num, ...
                        element_order, xyz, element_node', higaSol', uvw )
        fclose(fid);

        cd ..

        disp('FINISHED EXPORTING FILE .VTK')
        
    end
    
    % EXIT EXPORT FOLDER
    
    errL2 = 0;
    errH1 = 0;
    
end
