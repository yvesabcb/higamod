classdef AssemblerStokesHandler
    
    %% ASSEMBLER STOKES HANDLER CLASS
    % the AssemblerStokesHandler is a class that contain all the scripts
    % responsible for the assembling and building of the block matrix that
    % describe the discretized differential problem. On one hand, the class
    % properties, the properties of the objects were defined based on the
    % variables needed in the implementation of each function. On the other 
    % hand, all of the previous functions are concentrated and organized in
    % the class methods.
    
    properties (SetAccess = public, GetAccess = public)
        
        %% ASSEMBLER STOKES HANDLER - OBJECT PROPERTIES
        % The properties of the objects used in the AssemblerStokeshandler
        % encapsulate all of the variables needed to run the methods
        % bellow, from the support methods to the final building methods.
        
        % BUILDING PROPERTIES
        
        leftBDomain_inX;            % Left Limit of the Domain in the X Direction
   
        rightBDomain_inX;           % Right Limit of the Domain in the X Direction
        
        stepMeshX;                  % Vector Containing the Step of the Finite
                                    % Element Mesh
                      
        label_upBoundDomain;        % Contains the Label Identifying the Nature of
                                    % the Boundary Conditions on the Upper Limit of
                                    % the Domain                 
        label_downBoundDomain;     % Contains the Label Identifying the Nature of
                                    % the Boundary Conditions on the Lower Limit of
                                    % the Domain
                      
        localdata_upBDomainX;       % Contains the Values of the Boundary Conditions
        localdata_upBDomainY;       % on the Upper Limir of the Domain
                      
        localdata_downBDomainX;      % Contains the Values of the Boundary Conditions
        localdata_downBDomainY;      % on the Lower Limir of the Domain
                      
        
        coefficientForm;            % Data Structure Containing All the @-Functions
                                    % and the Constants Relative to the Bilinear Form
                            
        dirCondFuncStruct;          % Data Structure Containing All the @-Functions
                                    % for the Dirichlet Conditions at the Inflow and
                                    % for the Exciting Force
                      
        geometricInfo;              % Data Structure Containing All the
                                    % Geometric Information regarding the
                                    % Domain. The current version of the code
                                    % works only for the specific condition of:
                                    % (L = 1, a = 0, psi_x = 0)
    
        robinCondStruct;            % NO Data Structure Containing the Two Values of the
                                    % Coefficients (R, L) for the Robin Condition Used
                                    % in the Domain Decomposition
                      
        physicMesh_inX;             % Vector Containing the Physical Mesh in the X
                                    % Direction
                      
        physicMesh_inY;             % Vector Containing the Physical Mesh in the Y
                                    % Direction
                      
        jacAtQuadNodes;             % Data Sturcture Used to Save the Value of the
                                    % Jacobians Computed in the Quadratures Nodes 
        
        domainProfile;              % Symbolic Function Defining the Profile of the
                                    % Simulation Domain
                      
        domainProfileDer;           % Symbolic Function Defining the Derivative of
                                    % the Profile of the Simulation Domain   
        
        numbHorQuadNodes;           % Number of horizontal nodes to apply the quadrature
                                    % formula
                                    
        numbVerQuadNodes;           % Number of vertical nodes to apply the quadrature
                                    % formula
                                    
        dimModalBasisP              % Dimension of the modal basis for the pressure
        
        dimModalBasisUx             % Dimension of the modal basis for the X component
                                    % of the velocity field
                                    
        dimModalBasisUy             % Dimension of the modal basis for the Y component
                                    % of the velocity field
                                    
        label_upBoundDomainP        % Tag of the boundary condition on the top lateral boundary
                                    % for the pressure
        
        label_downBoundDomainP      % Tag of the boundary condition on the bottom lateral boundary
                                    % for the pressure
                                    
        label_upBoundDomainUx       % Tag of the boundary condition on the top lateral boundary
                                    % for the pressure
        
        label_downBoundDomainUx     % Tag of the boundary condition on the bottom lateral boundary
                                    % for the pressure
                                    
        label_upBoundDomainUy       % Tag of the boundary condition on the top lateral boundary
                                    % for the pressure
        
        label_downBoundDomainUy     % Tag of the boundary condition on the bottom lateral boundary
                                    % for the pressure
                                    
        discStruct      % Structure containing the discretization parameters
        
        boundCondStruct % Structure containing the boundary condition 
                        % information

        igaBasisStruct  % Structure containing the isogeometric basis
                        % paramters

        probParameters  % Structure containing the problem parameters

        timeStruct      % Structure containing the time domain and time
                        % simulation parameters

        quadProperties  % Structure containing the quadrature parameters
    end
    
    methods (Access = public)
        
        %% ASSEMBLER STOKES HANDLER - CONSTRUCT METHOD
        % The construct method is the basic structure that defines a new
        % object uppon creation. It contains the basic properties that need
        % to be assigned when an object of the class AssemblerADRHandler is
        % created.
        % 
        % By default, MATLAB generates a default constructor with no input 
        % arguments. We chose to leave the default definition of the
        % constructor because in this way we can freely defines the
        % properties we need each time a method is used. 
        %
        % Since all the properties are public, they can me changed from the
        % outside of the class.
        
        %% ASSEMBLER STOKES HANDLER - BUILDING METHODS
        
            %% Method 'buildIGAScatter'
            
            function [AA,FF,plotStruct] = buildSystemIGAScatter(obj)
                                                         
            %%
            % buildSystemIGA - This function computes the assembled matrices
            %                    relative to the variational problem considering 
            %                    IGA modal basis.
            %
            % Note:
            % All of the following inputs are encapsulated in the
            % object properties.
            %
            % The inputs are:
            %%
            %   (1)  dimModalBasis              : Dimension of the Modal Basis
            %   (2)  leftBDomain_inX            : Left Limit of the Domain in the X Direction
            %   (3)  rightBDomain_inX           : Right Limit of the Domain in the X Direction
            %   (4)  stepMeshX                  : Vector Containing the Step of the Finite
            %                                     Element Mesh
            %   (5)  label_upBoundDomain        : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Upper Limit of
            %                                     the Domain
            %   (6)  label_downBoundDomain      : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Lower Limit of
            %                                     the Domain
            %   (7)  localdata_upBDomain        : Contains the Values of the Boundary Conditions
            %                                     on the Upper Limir of the Domain
            %   (8) localdata_downBDomain       : Contains the Values of the Boundary Conditions
            %                                     on the Lower Limir of the Domain
            %   (9) domainPosition              : Current domain used in the domain decomposition
            %                                     Computations
            %   (10) coefficientForm            : Data Strusture Containing All the @-Functions
            %                                     and the Constants Relative to the Bilinear Form
            %   (11) dirCondFuncStruct          : Data Structure Containing All the @-Functions
            %                                     for the Dirichlet Conditions at the Inflow and
            %                                     for the Exciting Force
            %   (12) geometricInfo              : Data Structure Containing All the
            %                                     Geometric Information regarding the
            %                                     Domain. The current version of the code
            %                                     works only for the specific condition of:
            %                                     (L = 1, a = 0, psi_x = 0)
            %   (13) robinCondStruct            : Data Structure Containing the Two Values of the
            %                                     Coefficients (R, L) for the Robin Condition Used
            %                                     in the Domain Decomposition
            %   (14) numbDimMBEachDomain        : Number of Elements in the Vector Containing the
            %                                     Dimensions of the Modal Basis in Each Domain
            %   (15) couplingCond_DD            : Contains the Label Adressing the Coupling Condition
            %                                     of the Problem
            %   (16) physicMesh_inX             : Vector Containing the Physical Mesh in the X
            %                                     Direction
            %   (17) physicMesh_inY             : Vector Containing the Physical Mesh in the Y
            %                                     Direction
            %   (18) jacAtQuadNodes             : Data Sturcture Used to Save the Value of the
            %                                     Jacobians Computed in the Quadratures Nodes 
            %   (19) degreePolySplineBasis      : Degree of the Polynomial B-Spline Basis
            %   (20) continuityParameter        : Degree of Continuity of the Basis 'C^(p-k)'
            %   (21) domainProfile              : Symbolic Function Defining the Profile of the
            %                                     Simulation Domain
            %   (22) domainProfileDer           : Symbolic Function Defining the Derivative of
            %                                     the Profile of the Simulation Domain
            % 
            % The outputs are:
            %%
            %   (1) A                   : Final Assembled Block Matrix Using IGA Basis
            %   (2) b                   : Final Assembled Block Vector Using IGA Basis
            %   (3) modalBasis          : Modal Basis Obtained
            %   (3) liftCoeffA          : First Offset Adjustment Coefficient
            %   (4) liftCoeffB          : Second Offset Adjustment Coefficient
            %   (5) intNodesGaussLeg    : Gauss-Legendre Integration Nodes
            %   (6) intNodesWeights     : Weights of the Gauss-Legendre Integration Nodes
            
            %% IMPORT CLASSES
            
            import Core.AssemblerADRHandler
            import Core.AssemblerStokesHandler
            import Core.AssemblerNSHandler
            import Core.BoundaryConditionHandler
            import Core.IntegrateHandler
            import Core.EvaluationHandler
            import Core.BasisHandler
            import Core.SolverHandler
            
            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp('Started BUILDING TIME STRUCTURES');
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 
            
            %% NUMBER OF NODES IN THE QUADRATURE FORMULA
            %-------------------------------------------------------------%
            % The values of 'nqnx' and 'nqny' does not change during the
            % computation of the Gauss-Legendre Integration Points.
            % Attention, if you increase the number of nodes in the
            % discretization, it is necessary to refine the quadrature
            % rule.
            %-------------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesP = obj.quadProperties.numbHorNodesP;
            
            % Vertical Direction
            
            numbVerNodesP = obj.quadProperties.numbVerNodesP;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUx = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUx = obj.quadProperties.numbVerNodesUx;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUy = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUy = obj.quadProperties.numbVerNodesUx;
            
            %% NUMBER OF KNOTS - IDOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of knots used to divide the spline curve in the
            % isogeometric analysis.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsP  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUx  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUy  = obj.discStruct.numbElements;
            
            %% NUMBER OF CONTROL POINTS - ISOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of control points used in the isogeometric
            % approach. Note that this number is equal to the dimension of
            % the basis used to define the Spline curve and that the
            % formula used bellow corresponds to use a straight line as
            % reference supporting fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisP  = obj.igaBasisStruct.degreeSplineBasisP;
            continuityParameterP    = obj.igaBasisStruct.continuityParameterP; 
            numbControlPtsP         = numbKnotsP*(degreePolySplineBasisP - continuityParameterP) + ...
                                      1 + continuityParameterP;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUx = obj.igaBasisStruct.degreeSplineBasisUx;
            continuityParameterUx   = obj.igaBasisStruct.continuityParameterUx; 
            numbControlPtsUx        = numbKnotsUx * (degreePolySplineBasisUx - continuityParameterUx) + ...
                                      1 + continuityParameterUx;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUy = obj.igaBasisStruct.degreeSplineBasisUy;
            continuityParameterUy   = obj.igaBasisStruct.continuityParameterUy; 
            numbControlPtsUy        = numbKnotsUy * (degreePolySplineBasisUy - continuityParameterUy) + ...
                                      1 + continuityParameterUy;

            %% GAUSS-LEGENDRE INTEGRATION NODES
            %-------------------------------------------------------------%
            % The following method reveives the number of integration nodes
            % in the horizontal and vertical direction and retruns the
            % respective Gauss-Legendre nodes and weigths for the
            % integration interval [0,1].   
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreP = IntegrateHandler();
            obj_gaussLegendreP.numbQuadNodes = numbVerNodesP;
            [~, verGLNodesP, verWeightsP] = gaussLegendre(obj_gaussLegendreP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUx = IntegrateHandler();
            obj_gaussLegendreUx.numbQuadNodes = numbVerNodesUx;
            [~, verGLNodesUx, verWeightsUx] = gaussLegendre(obj_gaussLegendreUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUy = IntegrateHandler();
            obj_gaussLegendreUy.numbQuadNodes = numbVerNodesUy;
            [~, verGLNodesUy, verWeightsUy] = gaussLegendre(obj_gaussLegendreUy);
            
            %% EXTRACT GEOMETRIC INFORMATION
            
            geometry  = obj.geometricInfo.geometry;
            map       = @(x,y) obj.geometricInfo.map(x,y);
            Jac       = @(x,y) obj.geometricInfo.Jac(x,y);
            Hes       = @(x,y) obj.geometricInfo.Hes(x,y);
            
            %% COMPUTE REFERENCE KNOT AND CONTROL POINTS
            %-------------------------------------------------------------%
            % Note: Create the knots and control points of the reference
            % supporting fiber where the coupled 1D problems will be
            % solved.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubP = numbKnotsP;
            degreeP = degreePolySplineBasisP;
            regularityP = continuityParameterP;
            
            [knotsP, zetaP] = kntrefine (refDomain1D.nurbs.knots, nsubP-1, degreeP, regularityP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUx = numbKnotsUx;
            degreeUx = degreePolySplineBasisUx;
            regularityUx = continuityParameterUx;
            
            [knotsUx, zetaUx] = kntrefine (refDomain1D.nurbs.knots, nsubUx-1, degreeUx, regularityUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUy = numbKnotsUy;
            degreeUy = degreePolySplineBasisUy;
            regularityUy = continuityParameterUy;
            
            [knotsUy, zetaUy] = kntrefine (refDomain1D.nurbs.knots, nsubUy-1, degreeUy, regularityUy);
            
            %% GENERATE ISOGEOMETRIC MESH FUNCTION
            %-------------------------------------------------------------%
            % Note: Use the number of quadrature nodes to generate the
            % quadrature rule using the gauss nodes. Then, use this
            % information with the computed knots and control points to
            % generate the isogeometric mesh of the centreline.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%
            % PRESSURE MESH %
            %%%%%%%%%%%%%%%%%
            
            ruleP       = msh_gauss_nodes (numbHorNodesP);
            [qnP, qwP]  = msh_set_quad_nodes (zetaP, ruleP);
            mshP        = msh_cartesian (zetaP, qnP, qwP, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUx       = msh_gauss_nodes (numbHorNodesUx);
            [qnUx, qwUx] = msh_set_quad_nodes (zetaUx, ruleUx);
            mshUx        = msh_cartesian (zetaUx, qnUx, qwUx, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y  MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUy       = msh_gauss_nodes (numbHorNodesUy);
            [qnUy, qwUy] = msh_set_quad_nodes (zetaUy, ruleUy);
            mshUy        = msh_cartesian (zetaUy, qnUy, qwUy, refDomain1D);
            
            %% CONSTRUCT THE ISOGEOMETRIC FUNCTIONAL SPACE
            %-------------------------------------------------------------%
            % Note: Construct the functional space used to discretize the
            % problem along the centreline and perform the isogeometric
            % analysis. 
            % Here, we also evaluate the functional spaces in the specific
            % element. This will be used in the assembling loop to compute
            % the operators using the basis functions.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceP    = sp_bspline (knotsP, degreeP, mshP);
            
            numbKnotsP = mshP.nel_dir;
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncP = sp_evaluate_col (spaceP, msh_colP, 'value', false, 'gradient', true);
                shapFuncP = sp_evaluate_col (spaceP, msh_colP);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncP{iel,1} = shapFuncP;
                spaceFuncP{iel,2} = gradFuncP;
                spaceFuncP{iel,3} = msh_colP;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUx    = sp_bspline (knotsUx, degreeUx, mshUx);
            
            numbKnotsUx = mshUx.nel_dir;
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUx = sp_evaluate_col (spaceUx, msh_colUx, 'value', false, 'gradient', true);
                shapFuncUx = sp_evaluate_col (spaceUx, msh_colUx);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUx{iel,1} = shapFuncUx;
                spaceFuncUx{iel,2} = gradFuncUx;
                spaceFuncUx{iel,3} = msh_colUx;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUy    = sp_bspline (knotsUy, degreeUy, mshUy);
            
            numbKnotsUy = mshUy.nel_dir;
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUy = sp_evaluate_col (spaceUy, msh_colUy, 'value', false, 'gradient', true);
                shapFuncUy = sp_evaluate_col (spaceUy, msh_colUy);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUy{iel,1} = shapFuncUy;
                spaceFuncUy{iel,2} = gradFuncUy;
                spaceFuncUy{iel,3} = msh_colUy;

            end
            
            %% AUGMENTED HORIZONTAL POINTS 
            %-------------------------------------------------------------%
            % Note: The FOR loop runs over the knots in the centerline ans
            % compute the required quadrature nodes. The quadrature nodes
            % will be necessary to evaluate the bilinear coefficients and
            % the forcing component.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesP = zeros(numbKnotsP * numbHorNodesP,1);
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                localNodesP = reshape (msh_colP.geo_map(1,:,:), msh_colP.nqn, msh_colP.nel);  
                horEvalNodesP((iel - 1)*numbHorNodesP + 1 : iel*numbHorNodesP) = localNodesP;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUx = zeros(numbKnotsUx * numbHorNodesUx,1);
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                localNodesUx = reshape (msh_colUx.geo_map(1,:,:), msh_colUx.nqn, msh_colUx.nel);  
                horEvalNodesUx((iel - 1)*numbHorNodesUx + 1 : iel*numbHorNodesUx) = localNodesUx;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUy = zeros(numbKnotsUy * numbHorNodesUy,1);
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                localNodesUy = reshape (msh_colUy.geo_map(1,:,:), msh_colUy.nqn, msh_colUy.nel);  
                horEvalNodesUy((iel - 1)*numbHorNodesUy + 1 : iel*numbHorNodesUy) = localNodesUy;  
                
            end
            
            %% AUGMENTED VERTICAL POINTS
            %-------------------------------------------------------------%
            % Note: Since we are using the full map from the physical
            % domain to the reference domain, then the whole modal analysis
            % has to be performed in the vertical direction in the interval
            % [0,1];
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleP = IntegrateHandler();

            objVertQuadRuleP.leftBoundInterval = 0;
            objVertQuadRuleP.rightBoundInterval = 1;
            objVertQuadRuleP.inputNodes = verGLNodesP;
            objVertQuadRuleP.inputWeights = verWeightsP;

            [augVerNodesP, augVerWeightsP] = quadratureRule(objVertQuadRuleP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUx = IntegrateHandler();

            objVertQuadRuleUx.leftBoundInterval = 0;
            objVertQuadRuleUx.rightBoundInterval = 1;
            objVertQuadRuleUx.inputNodes = verGLNodesUx;
            objVertQuadRuleUx.inputWeights = verWeightsUx;

            [augVerNodesUx, augVerWeightsUx] = quadratureRule(objVertQuadRuleUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUy = IntegrateHandler();

            objVertQuadRuleUy.leftBoundInterval = 0;
            objVertQuadRuleUy.rightBoundInterval = 1;
            objVertQuadRuleUy.inputNodes = verGLNodesUy;
            objVertQuadRuleUy.inputWeights = verWeightsUy;

            [augVerNodesUy, augVerWeightsUy] = quadratureRule(objVertQuadRuleUy);
            
            %% COMPUTATION OF THE MODAL BASIS IN THE TRANSVERSE DIRECTION
            %-------------------------------------------------------------%
            % The next method takes the coefficients of the bilinear form,
            % the dimension of the modal basis (assigned in the demo) and
            % the vertical evaluation points and computes the coefficients
            % of the modal basis when evaluated in the points of the
            % transverse fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisP = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisP.dimLegendreBase = obj.discStruct.numbModesP;
            objNewModalBasisP.evalLegendreNodes = verGLNodesP;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisP.dimModalBasis = obj.discStruct.numbModesP;
            objNewModalBasisP.evalNodesY = verGLNodesP;
            objNewModalBasisP.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_P;
            objNewModalBasisP.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_P;
            objNewModalBasisP.coeffForm = obj.probParameters;

            [modalBasisP, modalBasisDerP] = newModalBasisStokes(objNewModalBasisP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUx = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUx.dimLegendreBase = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalLegendreNodes = verGLNodesUx;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUx.dimModalBasis = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalNodesY = verGLNodesUx;
            objNewModalBasisUx.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Ux;
            objNewModalBasisUx.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Ux;
            objNewModalBasisUx.coeffForm = obj.probParameters;

            [modalBasisUx, modalBasisDerUx] = newModalBasisStokes(objNewModalBasisUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUy = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUy.dimLegendreBase = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalLegendreNodes = verGLNodesUy;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUy.dimModalBasis = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalNodesY = verGLNodesUy;
            objNewModalBasisUy.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Uy;
            objNewModalBasisUy.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Uy;
            objNewModalBasisUy.coeffForm = obj.probParameters;

            [modalBasisUy, modalBasisDerUy] = newModalBasisStokes(objNewModalBasisUy);
            
            % DEBUG
            
%             figure
%             syms x y
%             fplot(legendreP(1:4, x))
%             axis([-1.0 1.0 -1.0 1.0])
%             
%             figure
%             for ii = 1:obj.discStruct.numbModesP
%                 plot(verGLNodesUy,modalBasisP(:,ii))
%                 hold on
%                 grid on
%             end
%             
%             return
            
            %% EVALUATION OF THE GEOMETRIC PROPERTIES OF THE DOMAIN
            %-------------------------------------------------------------%
            % We use the horizontal mesh created previously to evaluate the
            % thickness and the vertical coordinate of the centerline of
            % the channel.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesP = augVerNodesP;
            XP = mapOut(horEvalNodesP,verEvalNodesP,map,1);
            YP = mapOut(horEvalNodesP,verEvalNodesP,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUx = augVerNodesUx;
            XUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,1);
            YUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUy = augVerNodesUy;
            XUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,1);
            YUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATE GEOMETRIC STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            geoData.XP = XP;
            geoData.YP = YP;
            geoData.XUx = XUx;
            geoData.YUx = YUx;
            geoData.XUy = XUy;
            geoData.YUy = YUy;
            geoData.horNodesP = horEvalNodesP;
            geoData.verNodesP = verEvalNodesP;
            geoData.horNodesUx = horEvalNodesUx;
            geoData.verNodesUx = verEvalNodesUx;
            geoData.horNodesUy = horEvalNodesUy;
            geoData.verNodesUy = verEvalNodesUy;
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % JACOBIAN PROPERTIES %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            evalJac     = jacOut(horEvalNodesP,verEvalNodesP,Jac);
            evalDetJac  = detJac(horEvalNodesP,verEvalNodesP,Jac);
            
            Phi1_dx = invJac(1,1,evalJac);
            Phi1_dy = invJac(1,2,evalJac);
            Phi2_dx = invJac(2,1,evalJac);
            Phi2_dy = invJac(2,2,evalJac);
            
            jacFunc.evalJac     = evalJac;
            jacFunc.evalDetJac  = evalDetJac;
            jacFunc.Phi1_dx     = Phi1_dx;
            jacFunc.Phi1_dy     = Phi1_dy;
            jacFunc.Phi2_dx     = Phi2_dx;
            jacFunc.Phi2_dy     = Phi2_dy;
            
            jacFunc.modGradPhi1         = Phi1_dx.^2 + jacFunc.Phi1_dy.^2;
            jacFunc.modGradPhi2         = Phi2_dx.^2 + jacFunc.Phi2_dy.^2;
            jacFunc.modGradPhi1_Proj1   = Phi1_dx.^2;
            jacFunc.modGradPhi1_Proj2   = Phi1_dy.^2;
            jacFunc.modGradPhi2_Proj1   = Phi2_dx.^2;
            jacFunc.modGradPhi2_Proj2   = Phi2_dy.^2;

            jacFunc.GPhi1DotGPhi2       = Phi1_dx .* Phi2_dx + Phi1_dy .* Phi2_dy;
            jacFunc.GPhi1DotGPhi2_Proj1 = Phi1_dx .* Phi2_dx;
            jacFunc.GPhi1DotGPhi2_Proj2 = Phi1_dy .* Phi2_dy;

            jacFunc.GPhi1Proj1DotGPhi1Proj2 = Phi1_dx .* Phi1_dy;
            jacFunc.GPhi2Proj1DotGPhi1Proj2 = Phi2_dx .* Phi1_dy;
            jacFunc.GPhi1Proj1DotGPhi2Proj2 = Phi1_dx .* Phi2_dy;
            jacFunc.GPhi2Proj1DotGPhi2Proj2 = Phi2_dx .* Phi2_dy;
            
            %% MEMORY ALLOCATION FOR SYSTEM MATRICES
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE STIFFNESS MATRIX %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Axx = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Bxy = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Byx = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Ayy = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Px  = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Py  = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Qx  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Qy  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUy * (obj.discStruct.numbModesUy) );            
            P   = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsP  * (obj.discStruct.numbModesP)  );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE SOURCE TERM %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Fx = zeros ( numbControlPtsUx * (obj.discStruct.numbModesUx), 1);
            Fy = zeros ( numbControlPtsUy * (obj.discStruct.numbModesUy), 1);
            Fp = zeros ( numbControlPtsP  * (obj.discStruct.numbModesP ), 1);

            %% EVALUATION OF THE BILINEAR COEFFICIENTS OF THE DOMAIN
            %-------------------------------------------------------------%
            % We need to evaluate all the coefficients of the bilinear form
            % in the quadrature nodes along the vertical direction to
            % perform the first integral (along the transverse fiber) to
            % obtain a the coefficients of the 1D coupled problem. The
            % result will be coefficients as a function of 'x'.
            %-------------------------------------------------------------%

            % KINETIC VISCOSITY OF THE FLUID

            evalNu    = obj.probParameters.nu(XP,YP);
            
            % ARTIFICIAL REACTION OF THE FLUID

            evalSigma = obj.probParameters.sigma(XP,YP);
            
            % PRESSURE COMPENSATION

            evalDelta = obj.probParameters.delta(XP,YP);

            %% EVALUATION OF THE EXCITING FORCE 
            %-------------------------------------------------------------%
            % Finally, we use the horizontal and vertical meshes to
            % evaluate the exciting force acting on the system in the whole
            % domain.
            %-------------------------------------------------------------%

            evalForceX = obj.probParameters.force_x(XP,YP);
            evalForceY = obj.probParameters.force_y(XP,YP);

            %-------------------------------------------------------------%
            % Note: All of the coefficients of the bilinear form and the
            % exciting term evaluated in the domain, as well as the mesh of
            % vertical coordinates are stored in a data structure called
            % "Computed" to be treated in the assembler function.
            %-------------------------------------------------------------%

            Computed.nu = evalNu;
            Computed.sigma = evalSigma;
            Computed.delta = evalDelta;
            Computed.forceX = evalForceX;
            Computed.forceY = evalForceY;
            Computed.y = verEvalNodesP;

            %% Axx - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUx(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Mx_mb,Ax_mb,Fx_mb] = assemblerIGAScatterAx(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Axx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Ax_mb;
                    Mxx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Mx_mb;

                end

                % Assignment of the Block Vector Just Assembled
                Fx( 1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx ) = Fx_mb;
            end

            tAxx = toc;

            disp(['Axx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAxx),' [s]']);

            %% Ayy - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUy(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [My_mb,Ay_mb,Fy_mb] = assemblerIGAScatterAy(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Ayy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Ay_mb;
                    Myy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = My_mb;

                end

                % Assignment of the Block Vector Just Assembled
                Fy( 1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy ) = Fy_mb;
            end

            tAyy = toc;

            disp(['Ayy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAyy),' [s]']);

            %% Bxy - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUx(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Bxy_mb] = assemblerIGAScatterBxy(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Bxy(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Bxy_mb;

                end
            end

            tBxy = toc;

            disp(['Bxy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tBxy),' [s]']);

            %% Byx - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUy(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Byx_mb] = assemblerIGAScatterByx(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Byx(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Byx_mb;

                end
            end

            tByx = toc;

            disp(['Byx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tByx),' [s]']);

            %% Px  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Px_mb] = assemblerIGAScatterPx(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Px(1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Px_mb';

                end
            end

            tPx = toc;

            disp(['Px  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPx),' [s]']);

            %% Py  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Py_mb] = assemblerIGAScatterPy(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Py(1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Py_mb';

                end
            end

            tPy = toc;

            disp(['Py  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPy),' [s]']);

            %% Qx  - ASSEMBLING LOOP

            Qx = 1 * Px';

            %% Qy  - ASSEMBLING LOOP

            Qy = 1 * Py';
            
            %% P   - ASSEMBLING LOOP
            
            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesP

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisP(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerP(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshP;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceP;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncP;

                    [P_mb] = assemblerIGAScatterP(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    P(1 + (jmb-1) * numbControlPtsP : jmb * numbControlPtsP , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = P_mb';

                end
            end

            tP = toc;

            disp(['P   - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tP),' [s]']);

            %% Axx - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            tic;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Ux;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Ux;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Ux;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Ux;
            boundaryStruct.augVerNodes      = augVerNodesUx;
            boundaryStruct.augVerWeights    = augVerWeightsUx;
            boundaryStruct.modalBasis       = modalBasisUx;
            boundaryStruct.numbModes        = obj.discStruct.numbModesUx;
            boundaryStruct.numbCtrlPts      = numbControlPtsUx;
            boundaryStruct.stiffMatrix      = Axx;
            boundaryStruct.forceTerm        = Fx;
            boundaryStruct.couplingMat      = Bxy;
            boundaryStruct.pressureMat      = Px;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructUx,outStructUx] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructUx;
            boundaryStruct.projOutBC = outStructUx;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [Axx,Bxy,Px,Fx] = imposeBoundaryStokes(obj_bcCoeff);
            
            %% Ayy - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Uy;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Uy;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Uy;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Uy;
            boundaryStruct.augVerNodes      = augVerNodesUy;
            boundaryStruct.augVerWeights    = augVerWeightsUy;
            boundaryStruct.modalBasis       = modalBasisUy;
            boundaryStruct.numbModes        = obj.discStruct.numbModesUy;
            boundaryStruct.numbCtrlPts      = numbControlPtsUy;
            boundaryStruct.stiffMatrix      = Ayy;
            boundaryStruct.forceTerm        = Fy;
            boundaryStruct.couplingMat      = Byx;
            boundaryStruct.pressureMat      = Py;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructUy,outStructUy] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructUy;
            boundaryStruct.projOutBC = outStructUy;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [Ayy,Byx,Py,Fy] = imposeBoundaryStokes(obj_bcCoeff);

            tImp = toc;

            disp(['FINISHED IMPOSING BC - SIM. TIME Ts = ',num2str(tImp),' [s]']);
            
            %% P   - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            tic;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_P;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_P;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_P;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_P;
            boundaryStruct.augVerNodes      = augVerNodesP;
            boundaryStruct.augVerWeights    = augVerWeightsP;
            boundaryStruct.modalBasis       = modalBasisP;
            boundaryStruct.numbModes        = obj.discStruct.numbModesP;
            boundaryStruct.numbCtrlPts      = numbControlPtsP;
            boundaryStruct.stiffMatrix      = P;
            boundaryStruct.forceTerm        = Fx;
            boundaryStruct.couplingMat      = Bxy;
            boundaryStruct.pressureMat      = Px;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructP,outStructP] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructP;
            boundaryStruct.projOutBC = outStructP;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [P,~,~,~] = imposeBoundaryStokes(obj_bcCoeff);

            %% GLOBAL SYSTEM ASSEMBLING

            tic;

            AA = [Axx,Bxy,Px;Byx,Ayy,Py;Qx,Qy,P];
            FF = [Fx;Fy;Fp];
            
            tGMat = toc;

            disp(['FINISHED ASSEMBLING GLOBAL MATRIX - SIM. TIME Ts = ',num2str(tGMat),' [s]']);

            tTotal = tAxx + tAyy + tBxy + tByx + tPx + tPy + tImp + tGMat;

            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp(['FINISHED ASSEMBLING - SIM. TIME Ts = ',num2str(tTotal),' [s]']);
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 

            %% CREATE PLOT STRUCTURE

            plotStruct.numbControlPtsP  = numbControlPtsP;
            plotStruct.numbControlPtsUx = numbControlPtsUx;
            plotStruct.numbControlPtsUy = numbControlPtsUy;
            plotStruct.numbKnotsP       = numbKnotsP;
            plotStruct.numbKnotsUx      = numbKnotsUx;
            plotStruct.numbKnotsUy      = numbKnotsUy;
            plotStruct.geometricInfo    = obj.geometricInfo;
            plotStruct.discStruct       = obj.discStruct;
            plotStruct.boundaryStruct   = boundaryStruct;
            plotStruct.mshP             = mshP;
            plotStruct.mshUx            = mshUx;
            plotStruct.mshUy            = mshUy;
            plotStruct.spaceP           = spaceP;
            plotStruct.spaceUx          = spaceUx;
            plotStruct.spaceUy          = spaceUy;
            plotStruct.spaceFuncP       = spaceFuncP;
            plotStruct.spaceFuncUx      = spaceFuncUx;
            plotStruct.spaceFuncUy      = spaceFuncUy;
            plotStruct.jacFunc          = jacFunc;
            plotStruct.refDomain1D      = refDomain1D;
            plotStruct.probParameters   = obj.probParameters;
            plotStruct.map              = map;
                
            end
        
            %% Method 'buildIGAScatterSimplified'
            
            function [AA,FF,plotStruct] = buildSystemIGAScatterSimplified(obj)
                                                         
            %%
            % buildSystemIGA - This function computes the assembled matrices
            %                    relative to the variational problem considering 
            %                    IGA modal basis.
            %
            % Note:
            % All of the following inputs are encapsulated in the
            % object properties.
            %
            % The inputs are:
            %%
            %   (1)  dimModalBasis              : Dimension of the Modal Basis
            %   (2)  leftBDomain_inX            : Left Limit of the Domain in the X Direction
            %   (3)  rightBDomain_inX           : Right Limit of the Domain in the X Direction
            %   (4)  stepMeshX                  : Vector Containing the Step of the Finite
            %                                     Element Mesh
            %   (5)  label_upBoundDomain        : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Upper Limit of
            %                                     the Domain
            %   (6)  label_downBoundDomain      : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Lower Limit of
            %                                     the Domain
            %   (7)  localdata_upBDomain        : Contains the Values of the Boundary Conditions
            %                                     on the Upper Limir of the Domain
            %   (8) localdata_downBDomain       : Contains the Values of the Boundary Conditions
            %                                     on the Lower Limir of the Domain
            %   (9) domainPosition              : Current domain used in the domain decomposition
            %                                     Computations
            %   (10) coefficientForm            : Data Strusture Containing All the @-Functions
            %                                     and the Constants Relative to the Bilinear Form
            %   (11) dirCondFuncStruct          : Data Structure Containing All the @-Functions
            %                                     for the Dirichlet Conditions at the Inflow and
            %                                     for the Exciting Force
            %   (12) geometricInfo              : Data Structure Containing All the
            %                                     Geometric Information regarding the
            %                                     Domain. The current version of the code
            %                                     works only for the specific condition of:
            %                                     (L = 1, a = 0, psi_x = 0)
            %   (13) robinCondStruct            : Data Structure Containing the Two Values of the
            %                                     Coefficients (R, L) for the Robin Condition Used
            %                                     in the Domain Decomposition
            %   (14) numbDimMBEachDomain        : Number of Elements in the Vector Containing the
            %                                     Dimensions of the Modal Basis in Each Domain
            %   (15) couplingCond_DD            : Contains the Label Adressing the Coupling Condition
            %                                     of the Problem
            %   (16) physicMesh_inX             : Vector Containing the Physical Mesh in the X
            %                                     Direction
            %   (17) physicMesh_inY             : Vector Containing the Physical Mesh in the Y
            %                                     Direction
            %   (18) jacAtQuadNodes             : Data Sturcture Used to Save the Value of the
            %                                     Jacobians Computed in the Quadratures Nodes 
            %   (19) degreePolySplineBasis      : Degree of the Polynomial B-Spline Basis
            %   (20) continuityParameter        : Degree of Continuity of the Basis 'C^(p-k)'
            %   (21) domainProfile              : Symbolic Function Defining the Profile of the
            %                                     Simulation Domain
            %   (22) domainProfileDer           : Symbolic Function Defining the Derivative of
            %                                     the Profile of the Simulation Domain
            % 
            % The outputs are:
            %%
            %   (1) A                   : Final Assembled Block Matrix Using IGA Basis
            %   (2) b                   : Final Assembled Block Vector Using IGA Basis
            %   (3) modalBasis          : Modal Basis Obtained
            %   (3) liftCoeffA          : First Offset Adjustment Coefficient
            %   (4) liftCoeffB          : Second Offset Adjustment Coefficient
            %   (5) intNodesGaussLeg    : Gauss-Legendre Integration Nodes
            %   (6) intNodesWeights     : Weights of the Gauss-Legendre Integration Nodes
            
            %% IMPORT CLASSES
            
            import Core.AssemblerADRHandler
            import Core.AssemblerStokesHandler
            import Core.AssemblerNSHandler
            import Core.BoundaryConditionHandler
            import Core.IntegrateHandler
            import Core.EvaluationHandler
            import Core.BasisHandler
            import Core.SolverHandler
            
            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp('Started BUILDING TIME STRUCTURES');
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 
            
            %% NUMBER OF NODES IN THE QUADRATURE FORMULA
            %-------------------------------------------------------------%
            % The values of 'nqnx' and 'nqny' does not change during the
            % computation of the Gauss-Legendre Integration Points.
            % Attention, if you increase the number of nodes in the
            % discretization, it is necessary to refine the quadrature
            % rule.
            %-------------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesP = obj.quadProperties.numbHorNodesP;
            
            % Vertical Direction
            
            numbVerNodesP = obj.quadProperties.numbVerNodesP;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUx = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUx = obj.quadProperties.numbVerNodesUx;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUy = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUy = obj.quadProperties.numbVerNodesUx;
            
            %% NUMBER OF KNOTS - IDOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of knots used to divide the spline curve in the
            % isogeometric analysis.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsP  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUx  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUy  = obj.discStruct.numbElements;
            
            %% NUMBER OF CONTROL POINTS - ISOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of control points used in the isogeometric
            % approach. Note that this number is equal to the dimension of
            % the basis used to define the Spline curve and that the
            % formula used bellow corresponds to use a straight line as
            % reference supporting fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisP  = obj.igaBasisStruct.degreeSplineBasisP;
            continuityParameterP    = obj.igaBasisStruct.continuityParameterP; 
            numbControlPtsP         = numbKnotsP*(degreePolySplineBasisP - continuityParameterP) + ...
                                      1 + continuityParameterP;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUx = obj.igaBasisStruct.degreeSplineBasisUx;
            continuityParameterUx   = obj.igaBasisStruct.continuityParameterUx; 
            numbControlPtsUx        = numbKnotsUx * (degreePolySplineBasisUx - continuityParameterUx) + ...
                                      1 + continuityParameterUx;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUy = obj.igaBasisStruct.degreeSplineBasisUy;
            continuityParameterUy   = obj.igaBasisStruct.continuityParameterUy; 
            numbControlPtsUy        = numbKnotsUy * (degreePolySplineBasisUy - continuityParameterUy) + ...
                                      1 + continuityParameterUy;

            %% GAUSS-LEGENDRE INTEGRATION NODES
            %-------------------------------------------------------------%
            % The following method reveives the number of integration nodes
            % in the horizontal and vertical direction and retruns the
            % respective Gauss-Legendre nodes and weigths for the
            % integration interval [0,1].   
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreP = IntegrateHandler();
            obj_gaussLegendreP.numbQuadNodes = numbVerNodesP;
            [~, verGLNodesP, verWeightsP] = gaussLegendre(obj_gaussLegendreP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUx = IntegrateHandler();
            obj_gaussLegendreUx.numbQuadNodes = numbVerNodesUx;
            [~, verGLNodesUx, verWeightsUx] = gaussLegendre(obj_gaussLegendreUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUy = IntegrateHandler();
            obj_gaussLegendreUy.numbQuadNodes = numbVerNodesUy;
            [~, verGLNodesUy, verWeightsUy] = gaussLegendre(obj_gaussLegendreUy);
            
            %% EXTRACT GEOMETRIC INFORMATION
            
            geometry  = obj.geometricInfo.geometry;
            map       = @(x,y) obj.geometricInfo.map(x,y);
            Jac       = @(x,y) obj.geometricInfo.Jac(x,y);
            Hes       = @(x,y) obj.geometricInfo.Hes(x,y);
            
            %% COMPUTE REFERENCE KNOT AND CONTROL POINTS
            %-------------------------------------------------------------%
            % Note: Create the knots and control points of the reference
            % supporting fiber where the coupled 1D problems will be
            % solved.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubP = numbKnotsP;
            degreeP = degreePolySplineBasisP;
            regularityP = continuityParameterP;
            
            [knotsP, zetaP] = kntrefine (refDomain1D.nurbs.knots, nsubP-1, degreeP, regularityP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUx = numbKnotsUx;
            degreeUx = degreePolySplineBasisUx;
            regularityUx = continuityParameterUx;
            
            [knotsUx, zetaUx] = kntrefine (refDomain1D.nurbs.knots, nsubUx-1, degreeUx, regularityUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUy = numbKnotsUy;
            degreeUy = degreePolySplineBasisUy;
            regularityUy = continuityParameterUy;
            
            [knotsUy, zetaUy] = kntrefine (refDomain1D.nurbs.knots, nsubUy-1, degreeUy, regularityUy);
            
            %% GENERATE ISOGEOMETRIC MESH FUNCTION
            %-------------------------------------------------------------%
            % Note: Use the number of quadrature nodes to generate the
            % quadrature rule using the gauss nodes. Then, use this
            % information with the computed knots and control points to
            % generate the isogeometric mesh of the centreline.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%
            % PRESSURE MESH %
            %%%%%%%%%%%%%%%%%
            
            ruleP       = msh_gauss_nodes (numbHorNodesP);
            [qnP, qwP]  = msh_set_quad_nodes (zetaP, ruleP);
            mshP        = msh_cartesian (zetaP, qnP, qwP, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUx       = msh_gauss_nodes (numbHorNodesUx);
            [qnUx, qwUx] = msh_set_quad_nodes (zetaUx, ruleUx);
            mshUx        = msh_cartesian (zetaUx, qnUx, qwUx, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y  MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUy       = msh_gauss_nodes (numbHorNodesUy);
            [qnUy, qwUy] = msh_set_quad_nodes (zetaUy, ruleUy);
            mshUy        = msh_cartesian (zetaUy, qnUy, qwUy, refDomain1D);
            
            %% CONSTRUCT THE ISOGEOMETRIC FUNCTIONAL SPACE
            %-------------------------------------------------------------%
            % Note: Construct the functional space used to discretize the
            % problem along the centreline and perform the isogeometric
            % analysis. 
            % Here, we also evaluate the functional spaces in the specific
            % element. This will be used in the assembling loop to compute
            % the operators using the basis functions.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceP    = sp_bspline (knotsP, degreeP, mshP);
            
            numbKnotsP = mshP.nel_dir;
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncP = sp_evaluate_col (spaceP, msh_colP, 'value', false, 'gradient', true);
                shapFuncP = sp_evaluate_col (spaceP, msh_colP);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncP{iel,1} = shapFuncP;
                spaceFuncP{iel,2} = gradFuncP;
                spaceFuncP{iel,3} = msh_colP;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUx    = sp_bspline (knotsUx, degreeUx, mshUx);
            
            numbKnotsUx = mshUx.nel_dir;
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUx = sp_evaluate_col (spaceUx, msh_colUx, 'value', false, 'gradient', true);
                shapFuncUx = sp_evaluate_col (spaceUx, msh_colUx);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUx{iel,1} = shapFuncUx;
                spaceFuncUx{iel,2} = gradFuncUx;
                spaceFuncUx{iel,3} = msh_colUx;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUy    = sp_bspline (knotsUy, degreeUy, mshUy);
            
            numbKnotsUy = mshUy.nel_dir;
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUy = sp_evaluate_col (spaceUy, msh_colUy, 'value', false, 'gradient', true);
                shapFuncUy = sp_evaluate_col (spaceUy, msh_colUy);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUy{iel,1} = shapFuncUy;
                spaceFuncUy{iel,2} = gradFuncUy;
                spaceFuncUy{iel,3} = msh_colUy;

            end
            
            %% AUGMENTED HORIZONTAL POINTS 
            %-------------------------------------------------------------%
            % Note: The FOR loop runs over the knots in the centerline ans
            % compute the required quadrature nodes. The quadrature nodes
            % will be necessary to evaluate the bilinear coefficients and
            % the forcing component.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesP = zeros(numbKnotsP * numbHorNodesP,1);
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                localNodesP = reshape (msh_colP.geo_map(1,:,:), msh_colP.nqn, msh_colP.nel);  
                horEvalNodesP((iel - 1)*numbHorNodesP + 1 : iel*numbHorNodesP) = localNodesP;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUx = zeros(numbKnotsUx * numbHorNodesUx,1);
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                localNodesUx = reshape (msh_colUx.geo_map(1,:,:), msh_colUx.nqn, msh_colUx.nel);  
                horEvalNodesUx((iel - 1)*numbHorNodesUx + 1 : iel*numbHorNodesUx) = localNodesUx;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUy = zeros(numbKnotsUy * numbHorNodesUy,1);
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                localNodesUy = reshape (msh_colUy.geo_map(1,:,:), msh_colUy.nqn, msh_colUy.nel);  
                horEvalNodesUy((iel - 1)*numbHorNodesUy + 1 : iel*numbHorNodesUy) = localNodesUy;  
                
            end
            
            %% AUGMENTED VERTICAL POINTS
            %-------------------------------------------------------------%
            % Note: Since we are using the full map from the physical
            % domain to the reference domain, then the whole modal analysis
            % has to be performed in the vertical direction in the interval
            % [0,1];
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleP = IntegrateHandler();

            objVertQuadRuleP.leftBoundInterval = 0;
            objVertQuadRuleP.rightBoundInterval = 1;
            objVertQuadRuleP.inputNodes = verGLNodesP;
            objVertQuadRuleP.inputWeights = verWeightsP;

            [augVerNodesP, augVerWeightsP] = quadratureRule(objVertQuadRuleP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUx = IntegrateHandler();

            objVertQuadRuleUx.leftBoundInterval = 0;
            objVertQuadRuleUx.rightBoundInterval = 1;
            objVertQuadRuleUx.inputNodes = verGLNodesUx;
            objVertQuadRuleUx.inputWeights = verWeightsUx;

            [augVerNodesUx, augVerWeightsUx] = quadratureRule(objVertQuadRuleUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUy = IntegrateHandler();

            objVertQuadRuleUy.leftBoundInterval = 0;
            objVertQuadRuleUy.rightBoundInterval = 1;
            objVertQuadRuleUy.inputNodes = verGLNodesUy;
            objVertQuadRuleUy.inputWeights = verWeightsUy;

            [augVerNodesUy, augVerWeightsUy] = quadratureRule(objVertQuadRuleUy);
            
            %% COMPUTATION OF THE MODAL BASIS IN THE TRANSVERSE DIRECTION
            %-------------------------------------------------------------%
            % The next method takes the coefficients of the bilinear form,
            % the dimension of the modal basis (assigned in the demo) and
            % the vertical evaluation points and computes the coefficients
            % of the modal basis when evaluated in the points of the
            % transverse fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisP = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisP.dimLegendreBase = obj.discStruct.numbModesP;
            objNewModalBasisP.evalLegendreNodes = verGLNodesP;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisP.dimModalBasis = obj.discStruct.numbModesP;
            objNewModalBasisP.evalNodesY = verGLNodesP;
            objNewModalBasisP.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_P;
            objNewModalBasisP.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_P;
            objNewModalBasisP.coeffForm = obj.probParameters;

            [modalBasisP, modalBasisDerP] = newModalBasisStokes(objNewModalBasisP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUx = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUx.dimLegendreBase = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalLegendreNodes = verGLNodesUx;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUx.dimModalBasis = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalNodesY = verGLNodesUx;
            objNewModalBasisUx.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Ux;
            objNewModalBasisUx.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Ux;
            objNewModalBasisUx.coeffForm = obj.probParameters;

            [modalBasisUx, modalBasisDerUx] = newModalBasisStokes(objNewModalBasisUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUy = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUy.dimLegendreBase = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalLegendreNodes = verGLNodesUy;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUy.dimModalBasis = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalNodesY = verGLNodesUy;
            objNewModalBasisUy.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Uy;
            objNewModalBasisUy.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Uy;
            objNewModalBasisUy.coeffForm = obj.probParameters;

            [modalBasisUy, modalBasisDerUy] = newModalBasisStokes(objNewModalBasisUy);
            
            % DEBUG
            
%             figure
%             syms x y
%             fplot(legendreP(1:4, x))
%             axis([-1.0 1.0 -1.0 1.0])
%             
%             figure
%             for ii = 1:obj.discStruct.numbModesP
%                 plot(verGLNodesUy,modalBasisP(:,ii))
%                 hold on
%                 grid on
%             end
%             
%             return
            
            %% EVALUATION OF THE GEOMETRIC PROPERTIES OF THE DOMAIN
            %-------------------------------------------------------------%
            % We use the horizontal mesh created previously to evaluate the
            % thickness and the vertical coordinate of the centerline of
            % the channel.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesP = augVerNodesP;
            XP = mapOut(horEvalNodesP,verEvalNodesP,map,1);
            YP = mapOut(horEvalNodesP,verEvalNodesP,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUx = augVerNodesUx;
            XUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,1);
            YUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUy = augVerNodesUy;
            XUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,1);
            YUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATE GEOMETRIC STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            geoData.XP = XP;
            geoData.YP = YP;
            geoData.XUx = XUx;
            geoData.YUx = YUx;
            geoData.XUy = XUy;
            geoData.YUy = YUy;
            geoData.horNodesP = horEvalNodesP;
            geoData.verNodesP = verEvalNodesP;
            geoData.horNodesUx = horEvalNodesUx;
            geoData.verNodesUx = verEvalNodesUx;
            geoData.horNodesUy = horEvalNodesUy;
            geoData.verNodesUy = verEvalNodesUy;
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % JACOBIAN PROPERTIES %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            evalJac     = jacOut(horEvalNodesP,verEvalNodesP,Jac);
            evalDetJac  = detJac(horEvalNodesP,verEvalNodesP,Jac);
            
            Phi1_dx = invJac(1,1,evalJac);
            Phi1_dy = invJac(1,2,evalJac);
            Phi2_dx = invJac(2,1,evalJac);
            Phi2_dy = invJac(2,2,evalJac);
            
            jacFunc.evalJac     = evalJac;
            jacFunc.evalDetJac  = evalDetJac;
            jacFunc.Phi1_dx     = Phi1_dx;
            jacFunc.Phi1_dy     = Phi1_dy;
            jacFunc.Phi2_dx     = Phi2_dx;
            jacFunc.Phi2_dy     = Phi2_dy;
            
            jacFunc.modGradPhi1         = Phi1_dx.^2 + jacFunc.Phi1_dy.^2;
            jacFunc.modGradPhi2         = Phi2_dx.^2 + jacFunc.Phi2_dy.^2;
            jacFunc.modGradPhi1_Proj1   = Phi1_dx.^2;
            jacFunc.modGradPhi1_Proj2   = Phi1_dy.^2;
            jacFunc.modGradPhi2_Proj1   = Phi2_dx.^2;
            jacFunc.modGradPhi2_Proj2   = Phi2_dy.^2;

            jacFunc.GPhi1DotGPhi2       = Phi1_dx .* Phi2_dx + Phi1_dy .* Phi2_dy;
            jacFunc.GPhi1DotGPhi2_Proj1 = Phi1_dx .* Phi2_dx;
            jacFunc.GPhi1DotGPhi2_Proj2 = Phi1_dy .* Phi2_dy;

            jacFunc.GPhi1Proj1DotGPhi1Proj2 = Phi1_dx .* Phi1_dy;
            jacFunc.GPhi2Proj1DotGPhi1Proj2 = Phi2_dx .* Phi1_dy;
            jacFunc.GPhi1Proj1DotGPhi2Proj2 = Phi1_dx .* Phi2_dy;
            jacFunc.GPhi2Proj1DotGPhi2Proj2 = Phi2_dx .* Phi2_dy;
            
            %% MEMORY ALLOCATION FOR SYSTEM MATRICES
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE STIFFNESS MATRIX %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Axx = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Bxy = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Byx = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Ayy = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Px  = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Py  = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Qx  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Qy  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUy * (obj.discStruct.numbModesUy) );            
            P   = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsP  * (obj.discStruct.numbModesP)  );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE SOURCE TERM %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Fx = zeros ( numbControlPtsUx * (obj.discStruct.numbModesUx), 1);
            Fy = zeros ( numbControlPtsUy * (obj.discStruct.numbModesUy), 1);
            Fp = zeros ( numbControlPtsP  * (obj.discStruct.numbModesP ), 1);

            %% EVALUATION OF THE BILINEAR COEFFICIENTS OF THE DOMAIN
            %-------------------------------------------------------------%
            % We need to evaluate all the coefficients of the bilinear form
            % in the quadrature nodes along the vertical direction to
            % perform the first integral (along the transverse fiber) to
            % obtain a the coefficients of the 1D coupled problem. The
            % result will be coefficients as a function of 'x'.
            %-------------------------------------------------------------%

            % KINETIC VISCOSITY OF THE FLUID

            evalNu    = obj.probParameters.nu(XP,YP);
            
            % ARTIFICIAL REACTION OF THE FLUID

            evalSigma = obj.probParameters.sigma(XP,YP);
            
            % PRESSURE COMPENSATION

            evalDelta = obj.probParameters.delta(XP,YP);

            %% EVALUATION OF THE EXCITING FORCE 
            %-------------------------------------------------------------%
            % Finally, we use the horizontal and vertical meshes to
            % evaluate the exciting force acting on the system in the whole
            % domain.
            %-------------------------------------------------------------%

            evalForceX = obj.probParameters.force_x(XP,YP);
            evalForceY = obj.probParameters.force_y(XP,YP);

            %-------------------------------------------------------------%
            % Note: All of the coefficients of the bilinear form and the
            % exciting term evaluated in the domain, as well as the mesh of
            % vertical coordinates are stored in a data structure called
            % "Computed" to be treated in the assembler function.
            %-------------------------------------------------------------%

            Computed.nu = evalNu;
            Computed.sigma = evalSigma;
            Computed.delta = evalDelta;
            Computed.forceX = evalForceX;
            Computed.forceY = evalForceY;
            Computed.y = verEvalNodesP;

            %% Axx - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUx(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Mx_mb,Ax_mb,Fx_mb] = assemblerIGAScatterAxSimplified(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Axx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Ax_mb;
                    Mxx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Mx_mb;

                end

                % Assignment of the Block Vector Just Assembled
                Fx( 1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx ) = Fx_mb;
            end

            tAxx = toc;

            disp(['Axx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAxx),' [s]']);

            %% Ayy - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerUy(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [My_mb,Ay_mb,Fy_mb] = assemblerIGAScatterAySimplified(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Ayy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Ay_mb;
                    Myy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = My_mb;

                end

                % Assignment of the Block Vector Just Assembled
                Fy( 1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy ) = Fy_mb;
            end

            tAyy = toc;

            disp(['Ayy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAyy),' [s]']);

            %% Px  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Px_mb] = assemblerIGAScatterPx(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Px(1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Px_mb';

                end
            end

            tPx = toc;

            disp(['Px  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPx),' [s]']);

            %% Py  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Py_mb] = assemblerIGAScatterPy(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Py(1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Py_mb';

                end
            end

            tPy = toc;

            disp(['Py  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPy),' [s]']);

            %% Qx  - ASSEMBLING LOOP

            Qx = 1 * Px';

            %% Qy  - ASSEMBLING LOOP

            Qy = 1 * Py';
            
            %% P   - ASSEMBLING LOOP
            
            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesP

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisP(:,jmb);
                    assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                    assemblerStruct.dmb2       = modalBasisDerP(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshP;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceP;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncP;

                    [P_mb] = assemblerIGAScatterP(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    P(1 + (jmb-1) * numbControlPtsP : jmb * numbControlPtsP , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = P_mb';

                end
            end

            tP = toc;

            disp(['P   - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tP),' [s]']);

            %% Axx - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            tic;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Ux;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Ux;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Ux;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Ux;
            boundaryStruct.augVerNodes      = augVerNodesUx;
            boundaryStruct.augVerWeights    = augVerWeightsUx;
            boundaryStruct.modalBasis       = modalBasisUx;
            boundaryStruct.numbModes        = obj.discStruct.numbModesUx;
            boundaryStruct.numbCtrlPts      = numbControlPtsUx;
            boundaryStruct.stiffMatrix      = Axx;
            boundaryStruct.forceTerm        = Fx;
            boundaryStruct.couplingMat      = Bxy;
            boundaryStruct.pressureMat      = Px;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructUx,outStructUx] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructUx;
            boundaryStruct.projOutBC = outStructUx;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [Axx,Px,Fx] = imposeBoundaryStokesSimplified(obj_bcCoeff);
            
            %% Ayy - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Uy;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Uy;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Uy;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Uy;
            boundaryStruct.augVerNodes      = augVerNodesUy;
            boundaryStruct.augVerWeights    = augVerWeightsUy;
            boundaryStruct.modalBasis       = modalBasisUy;
            boundaryStruct.numbModes        = obj.discStruct.numbModesUy;
            boundaryStruct.numbCtrlPts      = numbControlPtsUy;
            boundaryStruct.stiffMatrix      = Ayy;
            boundaryStruct.forceTerm        = Fy;
            boundaryStruct.couplingMat      = Byx;
            boundaryStruct.pressureMat      = Py;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructUy,outStructUy] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructUy;
            boundaryStruct.projOutBC = outStructUy;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [Ayy,Py,Fy] = imposeBoundaryStokesSimplified(obj_bcCoeff);

            tImp = toc;

            disp(['FINISHED IMPOSING BC - SIM. TIME Ts = ',num2str(tImp),' [s]']);
            
            %% P   - IMPOSE BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            tic;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_P;
            boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_P;
            boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_P;
            boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_P;
            boundaryStruct.augVerNodes      = augVerNodesP;
            boundaryStruct.augVerWeights    = augVerWeightsP;
            boundaryStruct.modalBasis       = modalBasisP;
            boundaryStruct.numbModes        = obj.discStruct.numbModesP;
            boundaryStruct.numbCtrlPts      = numbControlPtsP;
            boundaryStruct.stiffMatrix      = P;
            boundaryStruct.forceTerm        = Fx;
            boundaryStruct.couplingMat      = Bxy;
            boundaryStruct.pressureMat      = Px;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct    = boundaryStruct;

            [infStructP,outStructP] = computeFourierCoeffStokes(obj_bcCoeff);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBC = infStructP;
            boundaryStruct.projOutBC = outStructP;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [P,~,~,~] = imposeBoundaryStokes(obj_bcCoeff);

            %% GLOBAL SYSTEM ASSEMBLING

            tic;

            Bxy = zeros(numbControlPtsUx * obj.discStruct.numbModesUx , numbControlPtsUy * obj.discStruct.numbModesUy);
            Byx = zeros(numbControlPtsUy * obj.discStruct.numbModesUy , numbControlPtsUx * obj.discStruct.numbModesUx);
            
            AA = [Axx,Bxy,Px;Byx,Ayy,Py;Qx,Qy,P];
            FF = [Fx;Fy;Fp];
            
            tGMat = toc;

            disp(['FINISHED ASSEMBLING GLOBAL MATRIX - SIM. TIME Ts = ',num2str(tGMat),' [s]']);

            tTotal = tAxx + tAyy + tPx + tPy + tImp + tGMat;

            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp(['FINISHED ASSEMBLING - SIM. TIME Ts = ',num2str(tTotal),' [s]']);
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 

            %% CREATE PLOT STRUCTURE

            plotStruct.numbControlPtsP  = numbControlPtsP;
            plotStruct.numbControlPtsUx = numbControlPtsUx;
            plotStruct.numbControlPtsUy = numbControlPtsUy;
            plotStruct.numbKnotsP       = numbKnotsP;
            plotStruct.numbKnotsUx      = numbKnotsUx;
            plotStruct.numbKnotsUy      = numbKnotsUy;
            plotStruct.geometricInfo    = obj.geometricInfo;
            plotStruct.discStruct       = obj.discStruct;
            plotStruct.boundaryStruct   = boundaryStruct;
            plotStruct.mshP             = mshP;
            plotStruct.mshUx            = mshUx;
            plotStruct.mshUy            = mshUy;
            plotStruct.spaceP           = spaceP;
            plotStruct.spaceUx          = spaceUx;
            plotStruct.spaceUy          = spaceUy;
            plotStruct.spaceFuncP       = spaceFuncP;
            plotStruct.spaceFuncUx      = spaceFuncUx;
            plotStruct.spaceFuncUy      = spaceFuncUy;
            plotStruct.jacFunc          = jacFunc;
            plotStruct.refDomain1D      = refDomain1D;
            plotStruct.probParameters   = obj.probParameters;
            plotStruct.map              = map;
                
            end
            
            %% Method 'buildIGAScatterTransient'
            
            function [stiffTimeStruct,massTimeStruct,forceTimeStruct,plotStruct] = buildSystemIGAScatterTransient(obj)
                                                         
            %%
            % buildSystemIGA - This function computes the assembled matrices
            %                    relative to the variational problem considering 
            %                    IGA modal basis.
            %
            % Note:
            % All of the following inputs are encapsulated in the
            % object properties.
            %
            % The inputs are:
            %%
            %   (1)  dimModalBasis              : Dimension of the Modal Basis
            %   (2)  leftBDomain_inX            : Left Limit of the Domain in the X Direction
            %   (3)  rightBDomain_inX           : Right Limit of the Domain in the X Direction
            %   (4)  stepMeshX                  : Vector Containing the Step of the Finite
            %                                     Element Mesh
            %   (5)  label_upBoundDomain        : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Upper Limit of
            %                                     the Domain
            %   (6)  label_downBoundDomain      : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Lower Limit of
            %                                     the Domain
            %   (7)  localdata_upBDomain        : Contains the Values of the Boundary Conditions
            %                                     on the Upper Limir of the Domain
            %   (8) localdata_downBDomain       : Contains the Values of the Boundary Conditions
            %                                     on the Lower Limir of the Domain
            %   (9) domainPosition              : Current domain used in the domain decomposition
            %                                     Computations
            %   (10) coefficientForm            : Data Strusture Containing All the @-Functions
            %                                     and the Constants Relative to the Bilinear Form
            %   (11) dirCondFuncStruct          : Data Structure Containing All the @-Functions
            %                                     for the Dirichlet Conditions at the Inflow and
            %                                     for the Exciting Force
            %   (12) geometricInfo              : Data Structure Containing All the
            %                                     Geometric Information regarding the
            %                                     Domain. The current version of the code
            %                                     works only for the specific condition of:
            %                                     (L = 1, a = 0, psi_x = 0)
            %   (13) robinCondStruct            : Data Structure Containing the Two Values of the
            %                                     Coefficients (R, L) for the Robin Condition Used
            %                                     in the Domain Decomposition
            %   (14) numbDimMBEachDomain        : Number of Elements in the Vector Containing the
            %                                     Dimensions of the Modal Basis in Each Domain
            %   (15) couplingCond_DD            : Contains the Label Adressing the Coupling Condition
            %                                     of the Problem
            %   (16) physicMesh_inX             : Vector Containing the Physical Mesh in the X
            %                                     Direction
            %   (17) physicMesh_inY             : Vector Containing the Physical Mesh in the Y
            %                                     Direction
            %   (18) jacAtQuadNodes             : Data Sturcture Used to Save the Value of the
            %                                     Jacobians Computed in the Quadratures Nodes 
            %   (19) degreePolySplineBasis      : Degree of the Polynomial B-Spline Basis
            %   (20) continuityParameter        : Degree of Continuity of the Basis 'C^(p-k)'
            %   (21) domainProfile              : Symbolic Function Defining the Profile of the
            %                                     Simulation Domain
            %   (22) domainProfileDer           : Symbolic Function Defining the Derivative of
            %                                     the Profile of the Simulation Domain
            % 
            % The outputs are:
            %%
            %   (1) A                   : Final Assembled Block Matrix Using IGA Basis
            %   (2) b                   : Final Assembled Block Vector Using IGA Basis
            %   (3) modalBasis          : Modal Basis Obtained
            %   (3) liftCoeffA          : First Offset Adjustment Coefficient
            %   (4) liftCoeffB          : Second Offset Adjustment Coefficient
            %   (5) intNodesGaussLeg    : Gauss-Legendre Integration Nodes
            %   (6) intNodesWeights     : Weights of the Gauss-Legendre Integration Nodes
            
            %% IMPORT CLASSES
            
            import Core.AssemblerADRHandler
            import Core.AssemblerStokesHandler
            import Core.AssemblerNSHandler
            import Core.BoundaryConditionHandler
            import Core.IntegrateHandler
            import Core.EvaluationHandler
            import Core.BasisHandler
            import Core.SolverHandler
            
            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp('Started BUILDING TIME STRUCTURES');
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 
            
            %% NUMBER OF NODES IN THE QUADRATURE FORMULA
            %-------------------------------------------------------------%
            % The values of 'nqnx' and 'nqny' does not change during the
            % computation of the Gauss-Legendre Integration Points.
            % Attention, if you increase the number of nodes in the
            % discretization, it is necessary to refine the quadrature
            % rule.
            %-------------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesP = obj.quadProperties.numbHorNodesP;
            
            % Vertical Direction
            
            numbVerNodesP = obj.quadProperties.numbVerNodesP;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUx = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUx = obj.quadProperties.numbVerNodesUx;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUy = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUy = obj.quadProperties.numbVerNodesUx;
            
            %% NUMBER OF KNOTS - IDOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of knots used to divide the spline curve in the
            % isogeometric analysis.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsP  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUx  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUy  = obj.discStruct.numbElements;
            
            %% NUMBER OF CONTROL POINTS - ISOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of control points used in the isogeometric
            % approach. Note that this number is equal to the dimension of
            % the basis used to define the Spline curve and that the
            % formula used bellow corresponds to use a straight line as
            % reference supporting fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisP  = obj.igaBasisStruct.degreeSplineBasisP;
            continuityParameterP    = obj.igaBasisStruct.continuityParameterP; 
            numbControlPtsP         = numbKnotsP*(degreePolySplineBasisP - continuityParameterP) + ...
                                      1 + continuityParameterP;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUx = obj.igaBasisStruct.degreeSplineBasisUx;
            continuityParameterUx   = obj.igaBasisStruct.continuityParameterUx; 
            numbControlPtsUx        = numbKnotsUx * (degreePolySplineBasisUx - continuityParameterUx) + ...
                                      1 + continuityParameterUx;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUy = obj.igaBasisStruct.degreeSplineBasisUy;
            continuityParameterUy   = obj.igaBasisStruct.continuityParameterUy; 
            numbControlPtsUy        = numbKnotsUy * (degreePolySplineBasisUy - continuityParameterUy) + ...
                                      1 + continuityParameterUy;

            %% GAUSS-LEGENDRE INTEGRATION NODES
            %-------------------------------------------------------------%
            % The following method reveives the number of integration nodes
            % in the horizontal and vertical direction and retruns the
            % respective Gauss-Legendre nodes and weigths for the
            % integration interval [0,1].   
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreP = IntegrateHandler();
            obj_gaussLegendreP.numbQuadNodes = numbVerNodesP;
            [~, verGLNodesP, verWeightsP] = gaussLegendre(obj_gaussLegendreP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUx = IntegrateHandler();
            obj_gaussLegendreUx.numbQuadNodes = numbVerNodesUx;
            [~, verGLNodesUx, verWeightsUx] = gaussLegendre(obj_gaussLegendreUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUy = IntegrateHandler();
            obj_gaussLegendreUy.numbQuadNodes = numbVerNodesUy;
            [~, verGLNodesUy, verWeightsUy] = gaussLegendre(obj_gaussLegendreUy);
            
            %% EXTRACT GEOMETRIC INFORMATION
            
            geometry  = obj.geometricInfo.geometry;
            map       = @(x,y) obj.geometricInfo.map(x,y);
            Jac       = @(x,y) obj.geometricInfo.Jac(x,y);
            Hes       = @(x,y) obj.geometricInfo.Hes(x,y);
            
            %% COMPUTE REFERENCE KNOT AND CONTROL POINTS
            %-------------------------------------------------------------%
            % Note: Create the knots and control points of the reference
            % supporting fiber where the coupled 1D problems will be
            % solved.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubP = numbKnotsP;
            degreeP = degreePolySplineBasisP;
            regularityP = continuityParameterP;
            
            [knotsP, zetaP] = kntrefine (refDomain1D.nurbs.knots, nsubP-1, degreeP, regularityP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUx = numbKnotsUx;
            degreeUx = degreePolySplineBasisUx;
            regularityUx = continuityParameterUx;
            
            [knotsUx, zetaUx] = kntrefine (refDomain1D.nurbs.knots, nsubUx-1, degreeUx, regularityUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUy = numbKnotsUy;
            degreeUy = degreePolySplineBasisUy;
            regularityUy = continuityParameterUy;
            
            [knotsUy, zetaUy] = kntrefine (refDomain1D.nurbs.knots, nsubUy-1, degreeUy, regularityUy);
            
            %% GENERATE ISOGEOMETRIC MESH FUNCTION
            %-------------------------------------------------------------%
            % Note: Use the number of quadrature nodes to generate the
            % quadrature rule using the gauss nodes. Then, use this
            % information with the computed knots and control points to
            % generate the isogeometric mesh of the centreline.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%
            % PRESSURE MESH %
            %%%%%%%%%%%%%%%%%
            
            ruleP       = msh_gauss_nodes (numbHorNodesP);
            [qnP, qwP]  = msh_set_quad_nodes (zetaP, ruleP);
            mshP        = msh_cartesian (zetaP, qnP, qwP, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUx       = msh_gauss_nodes (numbHorNodesUx);
            [qnUx, qwUx] = msh_set_quad_nodes (zetaUx, ruleUx);
            mshUx        = msh_cartesian (zetaUx, qnUx, qwUx, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y  MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUy       = msh_gauss_nodes (numbHorNodesUy);
            [qnUy, qwUy] = msh_set_quad_nodes (zetaUy, ruleUy);
            mshUy        = msh_cartesian (zetaUy, qnUy, qwUy, refDomain1D);
            
            %% CONSTRUCT THE ISOGEOMETRIC FUNCTIONAL SPACE
            %-------------------------------------------------------------%
            % Note: Construct the functional space used to discretize the
            % problem along the centreline and perform the isogeometric
            % analysis. 
            % Here, we also evaluate the functional spaces in the specific
            % element. This will be used in the assembling loop to compute
            % the operators using the basis functions.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceP    = sp_bspline (knotsP, degreeP, mshP);
            
            numbKnotsP = mshP.nel_dir;
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncP = sp_evaluate_col (spaceP, msh_colP, 'value', false, 'gradient', true);
                shapFuncP = sp_evaluate_col (spaceP, msh_colP);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncP{iel,1} = shapFuncP;
                spaceFuncP{iel,2} = gradFuncP;
                spaceFuncP{iel,3} = msh_colP;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUx    = sp_bspline (knotsUx, degreeUx, mshUx);
            
            numbKnotsUx = mshUx.nel_dir;
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUx = sp_evaluate_col (spaceUx, msh_colUx, 'value', false, 'gradient', true);
                shapFuncUx = sp_evaluate_col (spaceUx, msh_colUx);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUx{iel,1} = shapFuncUx;
                spaceFuncUx{iel,2} = gradFuncUx;
                spaceFuncUx{iel,3} = msh_colUx;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUy    = sp_bspline (knotsUy, degreeUy, mshUy);
            
            numbKnotsUy = mshUy.nel_dir;
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUy = sp_evaluate_col (spaceUy, msh_colUy, 'value', false, 'gradient', true);
                shapFuncUy = sp_evaluate_col (spaceUy, msh_colUy);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUy{iel,1} = shapFuncUy;
                spaceFuncUy{iel,2} = gradFuncUy;
                spaceFuncUy{iel,3} = msh_colUy;

            end
            
            %% AUGMENTED HORIZONTAL POINTS 
            %-------------------------------------------------------------%
            % Note: The FOR loop runs over the knots in the centerline ans
            % compute the required quadrature nodes. The quadrature nodes
            % will be necessary to evaluate the bilinear coefficients and
            % the forcing component.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesP = zeros(numbKnotsP * numbHorNodesP,1);
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                localNodesP = reshape (msh_colP.geo_map(1,:,:), msh_colP.nqn, msh_colP.nel);  
                horEvalNodesP((iel - 1)*numbHorNodesP + 1 : iel*numbHorNodesP) = localNodesP;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUx = zeros(numbKnotsUx * numbHorNodesUx,1);
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                localNodesUx = reshape (msh_colUx.geo_map(1,:,:), msh_colUx.nqn, msh_colUx.nel);  
                horEvalNodesUx((iel - 1)*numbHorNodesUx + 1 : iel*numbHorNodesUx) = localNodesUx;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUy = zeros(numbKnotsUy * numbHorNodesUy,1);
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                localNodesUy = reshape (msh_colUy.geo_map(1,:,:), msh_colUy.nqn, msh_colUy.nel);  
                horEvalNodesUy((iel - 1)*numbHorNodesUy + 1 : iel*numbHorNodesUy) = localNodesUy;  
                
            end
            
            %% AUGMENTED VERTICAL POINTS
            %-------------------------------------------------------------%
            % Note: Since we are using the full map from the physical
            % domain to the reference domain, then the whole modal analysis
            % has to be performed in the vertical direction in the interval
            % [0,1];
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleP = IntegrateHandler();

            objVertQuadRuleP.leftBoundInterval = 0;
            objVertQuadRuleP.rightBoundInterval = 1;
            objVertQuadRuleP.inputNodes = verGLNodesP;
            objVertQuadRuleP.inputWeights = verWeightsP;

            [augVerNodesP, augVerWeightsP] = quadratureRule(objVertQuadRuleP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUx = IntegrateHandler();

            objVertQuadRuleUx.leftBoundInterval = 0;
            objVertQuadRuleUx.rightBoundInterval = 1;
            objVertQuadRuleUx.inputNodes = verGLNodesUx;
            objVertQuadRuleUx.inputWeights = verWeightsUx;

            [augVerNodesUx, augVerWeightsUx] = quadratureRule(objVertQuadRuleUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUy = IntegrateHandler();

            objVertQuadRuleUy.leftBoundInterval = 0;
            objVertQuadRuleUy.rightBoundInterval = 1;
            objVertQuadRuleUy.inputNodes = verGLNodesUy;
            objVertQuadRuleUy.inputWeights = verWeightsUy;

            [augVerNodesUy, augVerWeightsUy] = quadratureRule(objVertQuadRuleUy);
            
            %% COMPUTATION OF THE MODAL BASIS IN THE TRANSVERSE DIRECTION
            %-------------------------------------------------------------%
            % The next method takes the coefficients of the bilinear form,
            % the dimension of the modal basis (assigned in the demo) and
            % the vertical evaluation points and computes the coefficients
            % of the modal basis when evaluated in the points of the
            % transverse fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisP = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisP.dimLegendreBase = obj.discStruct.numbModesP;
            objNewModalBasisP.evalLegendreNodes = verGLNodesP;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisP.dimModalBasis = obj.discStruct.numbModesP;
            objNewModalBasisP.evalNodesY = verGLNodesP;
            objNewModalBasisP.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_P;
            objNewModalBasisP.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_P;
            objNewModalBasisP.coeffForm = obj.probParameters;
            
            [modalBasisP, modalBasisDerP] = newModalBasisStokes(objNewModalBasisP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUx = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUx.dimLegendreBase = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalLegendreNodes = verGLNodesUx;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUx.dimModalBasis = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalNodesY = verGLNodesUx;
            objNewModalBasisUx.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Ux;
            objNewModalBasisUx.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Ux;
            objNewModalBasisUx.coeffForm = obj.probParameters;

            [modalBasisUx, modalBasisDerUx] = newModalBasisStokes(objNewModalBasisUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUy = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUy.dimLegendreBase = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalLegendreNodes = verGLNodesUy;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUy.dimModalBasis = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalNodesY = verGLNodesUy;
            objNewModalBasisUy.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Uy;
            objNewModalBasisUy.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Uy;
            objNewModalBasisUy.coeffForm = obj.probParameters;

            [modalBasisUy, modalBasisDerUy] = newModalBasisStokes(objNewModalBasisUy);
            
            %% EVALUATION OF THE GEOMETRIC PROPERTIES OF THE DOMAIN
            %-------------------------------------------------------------%
            % We use the horizontal mesh created previously to evaluate the
            % thickness and the vertical coordinate of the centerline of
            % the channel.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesP = augVerNodesP;
            XP = mapOut(horEvalNodesP,verEvalNodesP,map,1);
            YP = mapOut(horEvalNodesP,verEvalNodesP,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUx = augVerNodesUx;
            XUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,1);
            YUx = mapOut(horEvalNodesUx,verEvalNodesUx,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            verEvalNodesUy = augVerNodesUy;
            XUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,1);
            YUy = mapOut(horEvalNodesUy,verEvalNodesUy,map,2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATE GEOMETRIC STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            geoData.XP = XP;
            geoData.YP = YP;
            geoData.XUx = XUx;
            geoData.YUx = YUx;
            geoData.XUy = XUy;
            geoData.YUy = YUy;
            geoData.horNodesP = horEvalNodesP;
            geoData.verNodesP = verEvalNodesP;
            geoData.horNodesUx = horEvalNodesUx;
            geoData.verNodesUx = verEvalNodesUx;
            geoData.horNodesUy = horEvalNodesUy;
            geoData.verNodesUy = verEvalNodesUy;
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % JACOBIAN PROPERTIES %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            evalJac     = jacOut(horEvalNodesP,verEvalNodesP,Jac);
            evalDetJac  = detJac(horEvalNodesP,verEvalNodesP,Jac);
            
            Phi1_dx = invJac(1,1,evalJac);
            Phi1_dy = invJac(1,2,evalJac);
            Phi2_dx = invJac(2,1,evalJac);
            Phi2_dy = invJac(2,2,evalJac);
            
            jacFunc.evalJac     = evalJac;
            jacFunc.evalDetJac  = evalDetJac;
            jacFunc.Phi1_dx     = Phi1_dx;
            jacFunc.Phi1_dy     = Phi1_dy;
            jacFunc.Phi2_dx     = Phi2_dx;
            jacFunc.Phi2_dy     = Phi2_dy;
            
            jacFunc.modGradPhi1         = Phi1_dx.^2 + jacFunc.Phi1_dy.^2;
            jacFunc.modGradPhi2         = Phi2_dx.^2 + jacFunc.Phi2_dy.^2;
            jacFunc.modGradPhi1_Proj1   = Phi1_dx.^2;
            jacFunc.modGradPhi1_Proj2   = Phi1_dy.^2;
            jacFunc.modGradPhi2_Proj1   = Phi2_dx.^2;
            jacFunc.modGradPhi2_Proj2   = Phi2_dy.^2;

            jacFunc.GPhi1DotGPhi2       = Phi1_dx .* Phi2_dx + Phi1_dy .* Phi2_dy;
            jacFunc.GPhi1DotGPhi2_Proj1 = Phi1_dx .* Phi2_dx;
            jacFunc.GPhi1DotGPhi2_Proj2 = Phi1_dy .* Phi2_dy;

            jacFunc.GPhi1Proj1DotGPhi1Proj2 = Phi1_dx .* Phi1_dy;
            jacFunc.GPhi2Proj1DotGPhi1Proj2 = Phi2_dx .* Phi1_dy;
            jacFunc.GPhi1Proj1DotGPhi2Proj2 = Phi1_dx .* Phi2_dy;
            jacFunc.GPhi2Proj1DotGPhi2Proj2 = Phi2_dx .* Phi2_dy;
            
            %% MEMORY ALLOCATION FOR SYSTEM MATRICES
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE MASS MATRIX %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Mxx = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Myy = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE STIFFNESS MATRIX %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Axx = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Bxy = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Byx = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Ayy = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Px  = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Py  = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Qx  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Qy  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUy * (obj.discStruct.numbModesUy) );            
            P   = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsP  * (obj.discStruct.numbModesP)  );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE SOURCE TERM %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Fx = zeros ( numbControlPtsUx * (obj.discStruct.numbModesUx), 1);
            Fy = zeros ( numbControlPtsUy * (obj.discStruct.numbModesUy), 1);
            Fp = zeros ( numbControlPtsP  * (obj.discStruct.numbModesP ), 1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % STRCUT CONTAINING TIME DEPENDENT INFORMATION %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            stiffTimeStruct = cell(size(obj.timeStruct.timeDomain));
            forceTimeStruct = cell(size(obj.timeStruct.timeDomain));
            massTimeStruct  = cell(size(obj.timeStruct.timeDomain));
            
            %% ASSEMBLE TIME DEPENDENT STRUCTURES
            
            for ii = 1:length(obj.timeStruct.timeDomain)

                %% EVALUATION OF THE BILINEAR COEFFICIENTS OF THE DOMAIN
                %-------------------------------------------------------------%
                % We need to evaluate all the coefficients of the bilinear form
                % in the quadrature nodes along the vertical direction to
                % perform the first integral (along the transverse fiber) to
                % obtain a the coefficients of the 1D coupled problem. The
                % result will be coefficients as a function of 'x'.
                %-------------------------------------------------------------%

                % KINETIC VISCOSITY OF THE FLUID

                evalNu    = obj.probParameters.nu(XP,YP,obj.timeStruct.timeDomain(ii));
                
                % ARTIFICIAL REACTION OF THE FLUID

                evalSigma = obj.probParameters.sigma(XP,YP,obj.timeStruct.timeDomain(ii));

                % PRESSURE COMPENSATION

                evalDelta = obj.probParameters.delta(XP,YP,obj.timeStruct.timeDomain(ii));

                %% EVALUATION OF THE EXCITING FORCE 
                %-------------------------------------------------------------%
                % Finally, we use the horizontal and vertical meshes to
                % evaluate the exciting force acting on the system in the whole
                % domain.
                %-------------------------------------------------------------%

                evalForceX = obj.probParameters.force_x(XP,YP,obj.timeStruct.timeDomain(ii));
                evalForceY = obj.probParameters.force_y(XP,YP,obj.timeStruct.timeDomain(ii));

                %-------------------------------------------------------------%
                % Note: All of the coefficients of the bilinear form and the
                % exciting term evaluated in the domain, as well as the mesh of
                % vertical coordinates are stored in a data structure called
                % "Computed" to be treated in the assembler function.
                %-------------------------------------------------------------%

                Computed.nu = evalNu;
                Computed.sigma = evalSigma;
                Computed.delta = evalDelta;
                Computed.forceX = evalForceX;
                Computed.forceY = evalForceY;
                Computed.y = verEvalNodesP;           

                %% Axx - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesUx
                    for jmb = 1:obj.discStruct.numbModesUx

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsUx;
                        assemblerStruct.wgh2       = augVerWeightsUx;
                        assemblerStruct.mb1        = modalBasisUx(:,kmb);
                        assemblerStruct.mb2        = modalBasisUx(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerUx(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshUx;
                        assemblerStruct.msh2       = mshUx;
                        assemblerStruct.space1     = spaceUx;
                        assemblerStruct.space2     = spaceUx;
                        assemblerStruct.spaceFunc1 = spaceFuncUx;
                        assemblerStruct.spaceFunc2 = spaceFuncUx;

                        [Mx_mb,Ax_mb,Fx_mb] = assemblerIGAScatterAx(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Axx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Ax_mb;
                        Mxx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Mx_mb;

                    end

                    % Assignment of the Block Vector Just Assembled
                    Fx( 1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx ) = Fx_mb;
                end
                
                tAxx = toc;

                disp(['Axx - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tAxx),' [s]']);

                %% Ayy - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesUy
                    for jmb = 1:obj.discStruct.numbModesUy

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsUy;
                        assemblerStruct.wgh2       = augVerWeightsUy;
                        assemblerStruct.mb1        = modalBasisUy(:,kmb);
                        assemblerStruct.mb2        = modalBasisUy(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerUy(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshUy;
                        assemblerStruct.msh2       = mshUy;
                        assemblerStruct.space1     = spaceUy;
                        assemblerStruct.space2     = spaceUy;
                        assemblerStruct.spaceFunc1 = spaceFuncUy;
                        assemblerStruct.spaceFunc2 = spaceFuncUy;

                        [My_mb,Ay_mb,Fy_mb] = assemblerIGAScatterAy(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Ayy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Ay_mb;
                        Myy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = My_mb;

                    end

                    % Assignment of the Block Vector Just Assembled
                    Fy( 1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy ) = Fy_mb;
                end
                
                tAyy = toc;

                disp(['Ayy - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tAyy),' [s]']);

                %% Bxy - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesUx
                    for jmb = 1:obj.discStruct.numbModesUy

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsUx;
                        assemblerStruct.wgh2       = augVerWeightsUy;
                        assemblerStruct.mb1        = modalBasisUx(:,kmb);
                        assemblerStruct.mb2        = modalBasisUy(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerUx(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshUx;
                        assemblerStruct.msh2       = mshUy;
                        assemblerStruct.space1     = spaceUx;
                        assemblerStruct.space2     = spaceUy;
                        assemblerStruct.spaceFunc1 = spaceFuncUx;
                        assemblerStruct.spaceFunc2 = spaceFuncUy;

                        [Bxy_mb] = assemblerIGAScatterBxy(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Bxy(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Bxy_mb;

                    end
                end
                
                tBxy = toc;

                disp(['Bxy - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tBxy),' [s]']);

                %% Byx - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesUy
                    for jmb = 1:obj.discStruct.numbModesUx

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsUy;
                        assemblerStruct.wgh2       = augVerWeightsUx;
                        assemblerStruct.mb1        = modalBasisUy(:,kmb);
                        assemblerStruct.mb2        = modalBasisUx(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerUy(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshUy;
                        assemblerStruct.msh2       = mshUx;
                        assemblerStruct.space1     = spaceUy;
                        assemblerStruct.space2     = spaceUx;
                        assemblerStruct.spaceFunc1 = spaceFuncUy;
                        assemblerStruct.spaceFunc2 = spaceFuncUx;

                        [Byx_mb] = assemblerIGAScatterByx(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Byx(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Byx_mb;

                    end
                end
                
                tByx = toc;

                disp(['Byx - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tByx),' [s]']);

                %% Px  - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesP
                    for jmb = 1:obj.discStruct.numbModesUx

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsP;
                        assemblerStruct.wgh2       = augVerWeightsUx;
                        assemblerStruct.mb1        = modalBasisP(:,kmb);
                        assemblerStruct.mb2        = modalBasisUx(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUx(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshP;
                        assemblerStruct.msh2       = mshUx;
                        assemblerStruct.space1     = spaceP;
                        assemblerStruct.space2     = spaceUx;
                        assemblerStruct.spaceFunc1 = spaceFuncP;
                        assemblerStruct.spaceFunc2 = spaceFuncUx;

                        [Px_mb] = assemblerIGAScatterPx(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Px(1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Px_mb';

                    end
                end
                
                tPx = toc;

                disp(['Px  - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tPx),' [s]']);

                %% Py  - ASSEMBLING LOOP

                assemblerStruct = [];
                
                tic;

                for kmb = 1:obj.discStruct.numbModesP
                    for jmb = 1:obj.discStruct.numbModesUy

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsP;
                        assemblerStruct.wgh2       = augVerWeightsUy;
                        assemblerStruct.mb1        = modalBasisP(:,kmb);
                        assemblerStruct.mb2        = modalBasisUy(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerUy(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshP;
                        assemblerStruct.msh2       = mshUy;
                        assemblerStruct.space1     = spaceP;
                        assemblerStruct.space2     = spaceUy;
                        assemblerStruct.spaceFunc1 = spaceFuncP;
                        assemblerStruct.spaceFunc2 = spaceFuncUy;

                        [Py_mb] = assemblerIGAScatterPy(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        Py(1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Py_mb';

                    end
                end
                
                tPy = toc;

                disp(['Py  - FINISHED ASSEMBLING LOOP AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tPy),' [s]']);

                %% Qx  - ASSEMBLING LOOP

                Qx = Px';

                %% Qy  - ASSEMBLING LOOP

                Qy = Py';
                
                %% P   - ASSEMBLING LOOP
            
                assemblerStruct = [];

                tic;

                for kmb = 1:obj.discStruct.numbModesP
                    for jmb = 1:obj.discStruct.numbModesP

                        assemblerStruct.index1     = kmb;
                        assemblerStruct.index2     = jmb;
                        assemblerStruct.wgh1       = augVerWeightsP;
                        assemblerStruct.wgh2       = augVerWeightsUx;
                        assemblerStruct.mb1        = modalBasisP(:,kmb);
                        assemblerStruct.mb2        = modalBasisP(:,jmb);
                        assemblerStruct.dmb1       = modalBasisDerP(:,kmb);
                        assemblerStruct.dmb2       = modalBasisDerP(:,jmb);
                        assemblerStruct.param      = Computed;
                        assemblerStruct.geodata    = geoData;
                        assemblerStruct.jacFunc    = jacFunc;
                        assemblerStruct.msh1       = mshP;
                        assemblerStruct.msh2       = mshP;
                        assemblerStruct.space1     = spaceP;
                        assemblerStruct.space2     = spaceP;
                        assemblerStruct.spaceFunc1 = spaceFuncP;
                        assemblerStruct.spaceFunc2 = spaceFuncP;

                        [P_mb] = assemblerIGAScatterP(assemblerStruct);

                        % Assignment of the Block Matrix Just Assembled

                        P(1 + (jmb-1) * numbControlPtsP : jmb * numbControlPtsP , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = P_mb';

                    end
                end

                tP = toc;

                disp(['P   - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tP),' [s]']);

                %% Axx - IMPOSE BOUNDARY CONDITIONS
                %---------------------------------------------------------%
                % Compute the projection of the inflow and outflow
                % boundary conditions using the expression for the modal
                % expansion and impose them in the stiffness matrix.
                %---------------------------------------------------------%

                tic;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CREATION OF THE BOUNDARY STRUCTURE %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.boundCondStruc   = obj.boundCondStruct;
                boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Ux;
                boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Ux;
                boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Ux;
                boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Ux;
                boundaryStruct.augVerNodes      = augVerNodesUx;
                boundaryStruct.augVerWeights    = augVerWeightsUx;
                boundaryStruct.modalBasis       = modalBasisUx;
                boundaryStruct.numbModes        = obj.discStruct.numbModesUx;
                boundaryStruct.numbCtrlPts      = numbControlPtsUx;
                boundaryStruct.stiffMatrix      = Axx;
                boundaryStruct.forceTerm        = Fx;
                boundaryStruct.time             = obj.timeStruct.timeDomain(ii);
                boundaryStruct.couplingMat      = Bxy;
                boundaryStruct.pressureMat      = Px;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct    = boundaryStruct;

                [infStructUx,outStructUx] = computeFourierCoeffStokesTransient(obj_bcCoeff);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % IMPOSE BOUNDARY CONDITIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.projInfBC = infStructUx;
                boundaryStruct.projOutBC = outStructUx;

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct = boundaryStruct;

                [Axx,Bxy,Px,Fx] = imposeBoundaryStokes(obj_bcCoeff);

                %% Ayy - IMPOSE BOUNDARY CONDITIONS
                %---------------------------------------------------------%
                % Compute the projection of the inflow and outflow
                % boundary conditions using the expression for the modal
                % expansion and impose them in the stiffness matrix.
                %---------------------------------------------------------%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CREATION OF THE BOUNDARY STRUCTURE %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.boundCondStruc   = obj.boundCondStruct;
                boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_Uy;
                boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_Uy;
                boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_Uy;
                boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_Uy;
                boundaryStruct.augVerNodes      = augVerNodesUy;
                boundaryStruct.augVerWeights    = augVerWeightsUy;
                boundaryStruct.modalBasis       = modalBasisUy;
                boundaryStruct.numbModes        = obj.discStruct.numbModesUy;
                boundaryStruct.numbCtrlPts      = numbControlPtsUy;
                boundaryStruct.stiffMatrix      = Ayy;
                boundaryStruct.forceTerm        = Fy;
                boundaryStruct.time             = obj.timeStruct.timeDomain(ii);
                boundaryStruct.couplingMat      = Byx;
                boundaryStruct.pressureMat      = Py;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct    = boundaryStruct;

                [infStructUy,outStructUy] = computeFourierCoeffStokesTransient(obj_bcCoeff);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % IMPOSE BOUNDARY CONDITIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.projInfBC = infStructUy;
                boundaryStruct.projOutBC = outStructUy;

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct = boundaryStruct;

                [Ayy,Byx,Py,Fy] = imposeBoundaryStokes(obj_bcCoeff);
                
                tImp = toc;
                
                disp(['FINISHED IMPOSING BC AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tImp),' [s]']);
                
                %% P   - IMPOSE BOUNDARY CONDITIONS
                %---------------------------------------------------------%
                % Compute the projection of the inflow and outflow
                % boundary conditions using the expression for the modal
                % expansion and impose them in the stiffness matrix.
                %---------------------------------------------------------%

                tic;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CREATION OF THE BOUNDARY STRUCTURE %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.boundCondStruc   = obj.boundCondStruct;
                boundaryStruct.bc_inf_tag       = obj.boundCondStruct.bc_inf_tag_P;
                boundaryStruct.bc_out_tag       = obj.boundCondStruct.bc_out_tag_P;
                boundaryStruct.bc_inf_data      = obj.boundCondStruct.bc_inf_data_P;
                boundaryStruct.bc_out_data      = obj.boundCondStruct.bc_out_data_P;
                boundaryStruct.augVerNodes      = augVerNodesP;
                boundaryStruct.augVerWeights    = augVerWeightsP;
                boundaryStruct.modalBasis       = modalBasisP;
                boundaryStruct.numbModes        = obj.discStruct.numbModesP;
                boundaryStruct.numbCtrlPts      = numbControlPtsP;
                boundaryStruct.stiffMatrix      = P;
                boundaryStruct.forceTerm        = Fx;
                boundaryStruct.couplingMat      = Bxy;
                boundaryStruct.pressureMat      = Px;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct    = boundaryStruct;

                [infStructP,outStructP] = computeFourierCoeffStokesTransient(obj_bcCoeff);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % IMPOSE BOUNDARY CONDITIONS %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                boundaryStruct.projInfBC = infStructP;
                boundaryStruct.projOutBC = outStructP;

                obj_bcCoeff = BoundaryConditionHandler();

                obj_bcCoeff.boundaryStruct = boundaryStruct;

                [P,~,~,~] = imposeBoundaryStokes(obj_bcCoeff);
                
                %% GLOBAL SYSTEM ASSEMBLING

                tic;
                
                stiffTimeStruct{ii} = [Axx,Bxy,Px;Byx,Ayy,Py;Qx,Qy,P];
                forceTimeStruct{ii} = [Fx;Fy;Fp];
                massTimeStruct{ii}  = [Mxx,zeros(size(Bxy)),zeros(size(Px));...
                                       zeros(size(Byx)),Myy,zeros(size(Py));...
                                       zeros(size(Qx)),zeros(size(Qy)),zeros(size(P))];
                
                tGMat = toc;
                
                disp(['FINISHED ASSEMBLING GLOBAL MATRIX AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tGMat),' [s]']);
                
                tTotal = tAxx + tAyy + tBxy + tByx + tPx + tPy + tImp + tGMat;
                
                disp('  '); 
                disp('---------------------------------------------------------------------------------------------')
                disp(['FINISHED ASSEMBLING AT t = ',num2str(obj.timeStruct.timeDomain(ii)),' [s] - SIM. TIME Ts = ',num2str(tTotal),' [s]']);
                disp('---------------------------------------------------------------------------------------------')
                disp('  '); 
                
                %% CREATE PLOT STRUCTURE
                
                plotStruct.numbControlPtsP  = numbControlPtsP;
                plotStruct.numbControlPtsUx = numbControlPtsUx;
                plotStruct.numbControlPtsUy = numbControlPtsUy;
                plotStruct.numbKnotsP       = numbKnotsP;
                plotStruct.numbKnotsUx      = numbKnotsUx;
                plotStruct.numbKnotsUy      = numbKnotsUy;
                plotStruct.geometricInfo    = obj.geometricInfo;
                plotStruct.discStruct       = obj.discStruct;
                plotStruct.boundaryStruct   = boundaryStruct;
                plotStruct.mshP             = mshP;
                plotStruct.mshUx            = mshUx;
                plotStruct.mshUy            = mshUy;
                plotStruct.spaceP           = spaceP;
                plotStruct.spaceUx          = spaceUx;
                plotStruct.spaceUy          = spaceUy;
                plotStruct.spaceFuncP       = spaceFuncP;
                plotStruct.spaceFuncUx      = spaceFuncUx;
                plotStruct.spaceFuncUy      = spaceFuncUy;
                plotStruct.jacFunc          = jacFunc;
                plotStruct.refDomain1D      = refDomain1D;
                plotStruct.probParameters   = obj.probParameters;
                plotStruct.map              = map;

            end
                
            end
            
            %% Method 'buildIGAScatter3D'
            
            function [AA,FF,plotStruct] = buildSystemIGAScatter3D(obj)
                                                         
            %%
            % buildSystemIGA - This function computes the assembled matrices
            %                    relative to the variational problem considering 
            %                    IGA modal basis.
            %
            % Note:
            % All of the following inputs are encapsulated in the
            % object properties.
            %
            % The inputs are:
            %%
            %   (1)  dimModalBasis              : Dimension of the Modal Basis
            %   (2)  leftBDomain_inX            : Left Limit of the Domain in the X Direction
            %   (3)  rightBDomain_inX           : Right Limit of the Domain in the X Direction
            %   (4)  stepMeshX                  : Vector Containing the Step of the Finite
            %                                     Element Mesh
            %   (5)  label_upBoundDomain        : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Upper Limit of
            %                                     the Domain
            %   (6)  label_downBoundDomain      : Contains the Label Identifying the Nature of
            %                                     the Boundary Conditions on the Lower Limit of
            %                                     the Domain
            %   (7)  localdata_upBDomain        : Contains the Values of the Boundary Conditions
            %                                     on the Upper Limir of the Domain
            %   (8) localdata_downBDomain       : Contains the Values of the Boundary Conditions
            %                                     on the Lower Limir of the Domain
            %   (9) domainPosition              : Current domain used in the domain decomposition
            %                                     Computations
            %   (10) coefficientForm            : Data Strusture Containing All the @-Functions
            %                                     and the Constants Relative to the Bilinear Form
            %   (11) dirCondFuncStruct          : Data Structure Containing All the @-Functions
            %                                     for the Dirichlet Conditions at the Inflow and
            %                                     for the Exciting Force
            %   (12) geometricInfo              : Data Structure Containing All the
            %                                     Geometric Information regarding the
            %                                     Domain. The current version of the code
            %                                     works only for the specific condition of:
            %                                     (L = 1, a = 0, psi_x = 0)
            %   (13) robinCondStruct            : Data Structure Containing the Two Values of the
            %                                     Coefficients (R, L) for the Robin Condition Used
            %                                     in the Domain Decomposition
            %   (14) numbDimMBEachDomain        : Number of Elements in the Vector Containing the
            %                                     Dimensions of the Modal Basis in Each Domain
            %   (15) couplingCond_DD            : Contains the Label Adressing the Coupling Condition
            %                                     of the Problem
            %   (16) physicMesh_inX             : Vector Containing the Physical Mesh in the X
            %                                     Direction
            %   (17) physicMesh_inY             : Vector Containing the Physical Mesh in the Y
            %                                     Direction
            %   (18) jacAtQuadNodes             : Data Sturcture Used to Save the Value of the
            %                                     Jacobians Computed in the Quadratures Nodes 
            %   (19) degreePolySplineBasis      : Degree of the Polynomial B-Spline Basis
            %   (20) continuityParameter        : Degree of Continuity of the Basis 'C^(p-k)'
            %   (21) domainProfile              : Symbolic Function Defining the Profile of the
            %                                     Simulation Domain
            %   (22) domainProfileDer           : Symbolic Function Defining the Derivative of
            %                                     the Profile of the Simulation Domain
            % 
            % The outputs are:
            %%
            %   (1) A                   : Final Assembled Block Matrix Using IGA Basis
            %   (2) b                   : Final Assembled Block Vector Using IGA Basis
            %   (3) modalBasis          : Modal Basis Obtained
            %   (3) liftCoeffA          : First Offset Adjustment Coefficient
            %   (4) liftCoeffB          : Second Offset Adjustment Coefficient
            %   (5) intNodesGaussLeg    : Gauss-Legendre Integration Nodes
            %   (6) intNodesWeights     : Weights of the Gauss-Legendre Integration Nodes
            
            %% IMPORT CLASSES
            
            import Core.AssemblerADRHandler
            import Core.AssemblerStokesHandler
            import Core.AssemblerNSHandler
            import Core.BoundaryConditionHandler
            import Core.IntegrateHandler
            import Core.EvaluationHandler
            import Core.BasisHandler
            import Core.SolverHandler
            
            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp('Started BUILDING TIME STRUCTURES');
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 
            
            %% NUMBER OF NODES IN THE QUADRATURE FORMULA
            %-------------------------------------------------------------%
            % The values of 'nqnx' and 'nqny' does not change during the
            % computation of the Gauss-Legendre Integration Points.
            % Attention, if you increase the number of nodes in the
            % discretization, it is necessary to refine the quadrature
            % rule.
            %-------------------------------------------------------------%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesP = obj.quadProperties.numbHorNodesP;
            
            % Vertical Direction
            
            numbVerNodesP = obj.quadProperties.numbVerNodesP;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUx = obj.quadProperties.numbHorNodesUx;
            
            % Vertical Direction
            
            numbVerNodesUx = obj.quadProperties.numbVerNodesUx;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUy = obj.quadProperties.numbHorNodesUy;
            
            % Vertical Direction
            
            numbVerNodesUy = obj.quadProperties.numbVerNodesUy;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z QUADRATURE NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Horizontal Direction
            
            numbHorNodesUz = obj.quadProperties.numbHorNodesUz;
            
            % Vertical Direction
            
            numbVerNodesUz = obj.quadProperties.numbVerNodesUz;
            
            %% NUMBER OF KNOTS - IDOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of knots used to divide the spline curve in the
            % isogeometric analysis.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsP  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUx  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUy  = obj.discStruct.numbElements;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z NUMBER KNOTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            numbKnotsUz  = obj.discStruct.numbElements;
            
            %% NUMBER OF CONTROL POINTS - ISOGEOMETRIC ANALYSIS
            %-------------------------------------------------------------%
            % Total number of control points used in the isogeometric
            % approach. Note that this number is equal to the dimension of
            % the basis used to define the Spline curve and that the
            % formula used bellow corresponds to use a straight line as
            % reference supporting fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisP  = obj.igaBasisStruct.degreeSplineBasisP;
            continuityParameterP    = obj.igaBasisStruct.continuityParameterP; 
            numbControlPtsP         = numbKnotsP*(degreePolySplineBasisP - continuityParameterP) + ...
                                      1 + continuityParameterP;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUx = obj.igaBasisStruct.degreeSplineBasisUx;
            continuityParameterUx   = obj.igaBasisStruct.continuityParameterUx; 
            numbControlPtsUx        = numbKnotsUx * (degreePolySplineBasisUx - continuityParameterUx) + ...
                                      1 + continuityParameterUx;
                          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUy = obj.igaBasisStruct.degreeSplineBasisUy;
            continuityParameterUy   = obj.igaBasisStruct.continuityParameterUy; 
            numbControlPtsUy        = numbKnotsUy * (degreePolySplineBasisUy - continuityParameterUy) + ...
                                      1 + continuityParameterUy;
                                  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z NUMBER OF CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            degreePolySplineBasisUz = obj.igaBasisStruct.degreeSplineBasisUz;
            continuityParameterUz   = obj.igaBasisStruct.continuityParameterUz; 
            numbControlPtsUz        = numbKnotsUz * (degreePolySplineBasisUz - continuityParameterUz) + ...
                                      1 + continuityParameterUz;

            %% GAUSS-LEGENDRE INTEGRATION NODES
            %-------------------------------------------------------------%
            % The following method reveives the number of integration nodes
            % in the horizontal and vertical direction and retruns the
            % respective Gauss-Legendre nodes and weigths for the
            % integration interval [0,1].   
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreP = IntegrateHandler();
            obj_gaussLegendreP.numbQuadNodes = numbVerNodesP;
            [~, verGLNodesP, verWeightsP] = gaussLegendre(obj_gaussLegendreP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUx = IntegrateHandler();
            obj_gaussLegendreUx.numbQuadNodes = numbVerNodesUx;
            [~, verGLNodesUx, verWeightsUx] = gaussLegendre(obj_gaussLegendreUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUy = IntegrateHandler();
            obj_gaussLegendreUy.numbQuadNodes = numbVerNodesUy;
            [~, verGLNodesUy, verWeightsUy] = gaussLegendre(obj_gaussLegendreUy);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z MODAL GL INTEGRATION NODES %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj_gaussLegendreUz = IntegrateHandler();
            obj_gaussLegendreUz.numbQuadNodes = numbVerNodesUz;
            [~, verGLNodesUz, verWeightsUz] = gaussLegendre(obj_gaussLegendreUz);
            
            %% EXTRACT GEOMETRIC INFORMATION
            % Note: This section was modified to account for the third
            % coordinate of the domain.
            
            geometry  = obj.geometricInfo.geometry;
            map       = @(x,y,z) geometry.map([x;y;z]);
            Jac       = @(x,y,z) geometry.map_der([x;y;z]);
            Hes       = @(x,y,z) geometry.map_der2([x;y;z]);
            type      = obj.geometricInfo.Type;
            
            disp('Finished EXTRACT GEOMETRIC INFORMATION')
            
            %% COMPUTE REFERENCE KNOT AND CONTROL POINTS
            %-------------------------------------------------------------%
            % Note: Create the knots and control points of the reference
            % supporting fiber where the coupled 1D problems will be
            % solved.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubP = numbKnotsP;
            degreeP = degreePolySplineBasisP;
            regularityP = continuityParameterP;
            
            [knotsP, zetaP] = kntrefine (refDomain1D.nurbs.knots, nsubP-1, degreeP, regularityP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUx = numbKnotsUx;
            degreeUx = degreePolySplineBasisUx;
            regularityUx = continuityParameterUx;
            
            [knotsUx, zetaUx] = kntrefine (refDomain1D.nurbs.knots, nsubUx-1, degreeUx, regularityUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUy = numbKnotsUy;
            degreeUy = degreePolySplineBasisUy;
            regularityUy = continuityParameterUy;
            
            [knotsUy, zetaUy] = kntrefine (refDomain1D.nurbs.knots, nsubUy-1, degreeUy, regularityUy);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z REFERENCE KNOTS AND CONTROL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            refDomain1D = geo_load(nrbline ([0 0], [1 0]));
            
            nsubUz = numbKnotsUz;
            degreeUz = degreePolySplineBasisUz;
            regularityUz = continuityParameterUz;
            
            [knotsUz, zetaUz] = kntrefine (refDomain1D.nurbs.knots, nsubUz-1, degreeUz, regularityUz);
            
            %% GENERATE ISOGEOMETRIC MESH FUNCTION
            %-------------------------------------------------------------%
            % Note: Use the number of quadrature nodes to generate the
            % quadrature rule using the gauss nodes. Then, use this
            % information with the computed knots and control points to
            % generate the isogeometric mesh of the centreline.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%
            % PRESSURE MESH %
            %%%%%%%%%%%%%%%%%
            
            ruleP       = msh_gauss_nodes (numbHorNodesP);
            [qnP, qwP]  = msh_set_quad_nodes (zetaP, ruleP);
            mshP        = msh_cartesian (zetaP, qnP, qwP, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUx       = msh_gauss_nodes (numbHorNodesUx);
            [qnUx, qwUx] = msh_set_quad_nodes (zetaUx, ruleUx);
            mshUx        = msh_cartesian (zetaUx, qnUx, qwUx, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y  MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUy       = msh_gauss_nodes (numbHorNodesUy);
            [qnUy, qwUy] = msh_set_quad_nodes (zetaUy, ruleUy);
            mshUy        = msh_cartesian (zetaUy, qnUy, qwUy, refDomain1D);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z  MESH %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            ruleUz       = msh_gauss_nodes (numbHorNodesUz);
            [qnUz, qwUz] = msh_set_quad_nodes (zetaUz, ruleUz);
            mshUz        = msh_cartesian (zetaUz, qnUz, qwUz, refDomain1D);
            
            %% CONSTRUCT THE ISOGEOMETRIC FUNCTIONAL SPACE
            %-------------------------------------------------------------%
            % Note: Construct the functional space used to discretize the
            % problem along the centreline and perform the isogeometric
            % analysis. 
            % Here, we also evaluate the functional spaces in the specific
            % element. This will be used in the assembling loop to compute
            % the operators using the basis functions.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceP    = sp_bspline (knotsP, degreeP, mshP);
            
            numbKnotsP = mshP.nel_dir;
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncP = sp_evaluate_col (spaceP, msh_colP, 'value', false, 'gradient', true);
                shapFuncP = sp_evaluate_col (spaceP, msh_colP);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncP{iel,1} = shapFuncP;
                spaceFuncP{iel,2} = gradFuncP;
                spaceFuncP{iel,3} = msh_colP;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUx    = sp_bspline (knotsUx, degreeUx, mshUx);
            
            numbKnotsUx = mshUx.nel_dir;
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUx = sp_evaluate_col (spaceUx, msh_colUx, 'value', false, 'gradient', true);
                shapFuncUx = sp_evaluate_col (spaceUx, msh_colUx);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUx{iel,1} = shapFuncUx;
                spaceFuncUx{iel,2} = gradFuncUx;
                spaceFuncUx{iel,3} = msh_colUx;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUy    = sp_bspline (knotsUy, degreeUy, mshUy);
            
            numbKnotsUy = mshUy.nel_dir;
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUy = sp_evaluate_col (spaceUy, msh_colUy, 'value', false, 'gradient', true);
                shapFuncUy = sp_evaluate_col (spaceUy, msh_colUy);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUy{iel,1} = shapFuncUy;
                spaceFuncUy{iel,2} = gradFuncUy;
                spaceFuncUy{iel,3} = msh_colUy;

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z ISOGEOMETRIC FUNCTIONAL SPACE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            spaceUz    = sp_bspline (knotsUz, degreeUz, mshUz);
            
            numbKnotsUz = mshUz.nel_dir;
            
            for iel = 1:numbKnotsUz
                
                msh_colUz = msh_evaluate_col (mshUz, iel);
                
                %---------------------------------------------------------%
                % Evaluated space to compute the operators
                %---------------------------------------------------------%
                
                gradFuncUz = sp_evaluate_col (spaceUz, msh_colUz, 'value', false, 'gradient', true);
                shapFuncUz = sp_evaluate_col (spaceUz, msh_colUz);
                
                %---------------------------------------------------------%
                % Store the spaces in the cell matrix
                %---------------------------------------------------------%
                
                spaceFuncUz{iel,1} = shapFuncUz;
                spaceFuncUz{iel,2} = gradFuncUz;
                spaceFuncUz{iel,3} = msh_colUz;

            end
            
            %% AUGMENTED HORIZONTAL POINTS 
            %-------------------------------------------------------------%
            % Note: The FOR loop runs over the knots in the centerline ans
            % compute the required quadrature nodes. The quadrature nodes
            % will be necessary to evaluate the bilinear coefficients and
            % the forcing component.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesP = zeros(numbKnotsP * numbHorNodesP,1);
            
            for iel = 1:numbKnotsP
                
                msh_colP = msh_evaluate_col (mshP, iel);
                
                localNodesP = reshape (msh_colP.geo_map(1,:,:), msh_colP.nqn, msh_colP.nel);  
                horEvalNodesP((iel - 1)*numbHorNodesP + 1 : iel*numbHorNodesP) = localNodesP;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUx = zeros(numbKnotsUx * numbHorNodesUx,1);
            
            for iel = 1:numbKnotsUx
                
                msh_colUx = msh_evaluate_col (mshUx, iel);
                
                localNodesUx = reshape (msh_colUx.geo_map(1,:,:), msh_colUx.nqn, msh_colUx.nel);  
                horEvalNodesUx((iel - 1)*numbHorNodesUx + 1 : iel*numbHorNodesUx) = localNodesUx;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUy = zeros(numbKnotsUy * numbHorNodesUy,1);
            
            for iel = 1:numbKnotsUy
                
                msh_colUy = msh_evaluate_col (mshUy, iel);
                
                localNodesUy = reshape (msh_colUy.geo_map(1,:,:), msh_colUy.nqn, msh_colUy.nel);  
                horEvalNodesUy((iel - 1)*numbHorNodesUy + 1 : iel*numbHorNodesUy) = localNodesUy;  
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z AUGMENTED HORIZONTAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            horEvalNodesUz = zeros(numbKnotsUz * numbHorNodesUz,1);
            
            for iel = 1:numbKnotsUz
                
                msh_colUz = msh_evaluate_col (mshUz, iel);
                
                localNodesUz = reshape (msh_colUz.geo_map(1,:,:), msh_colUz.nqn, msh_colUz.nel);  
                horEvalNodesUz((iel - 1)*numbHorNodesUz + 1 : iel*numbHorNodesUz) = localNodesUz;  
                
            end
            
            %% AUGMENTED VERTICAL POINTS
            %-------------------------------------------------------------%
            % Note: Since we are using the full map from the physical
            % domain to the reference domain, then the whole modal analysis
            % has to be performed in the vertical direction in the interval
            % [0,1];
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleP = IntegrateHandler();

            objVertQuadRuleP.leftBoundInterval = 0;
            objVertQuadRuleP.rightBoundInterval = 1;
            objVertQuadRuleP.inputNodes = verGLNodesP;
            objVertQuadRuleP.inputWeights = verWeightsP;

            [augVerNodesP, augVerWeightsP] = quadratureRule(objVertQuadRuleP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUx = IntegrateHandler();

            objVertQuadRuleUx.leftBoundInterval = 0;
            objVertQuadRuleUx.rightBoundInterval = 1;
            objVertQuadRuleUx.inputNodes = verGLNodesUx;
            objVertQuadRuleUx.inputWeights = verWeightsUx;

            [augVerNodesUx, augVerWeightsUx] = quadratureRule(objVertQuadRuleUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUy = IntegrateHandler();

            objVertQuadRuleUy.leftBoundInterval = 0;
            objVertQuadRuleUy.rightBoundInterval = 1;
            objVertQuadRuleUy.inputNodes = verGLNodesUy;
            objVertQuadRuleUy.inputWeights = verWeightsUy;

            [augVerNodesUy, augVerWeightsUy] = quadratureRule(objVertQuadRuleUy);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z AUGMENTED VERTICAL POINTS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objVertQuadRuleUz = IntegrateHandler();

            objVertQuadRuleUz.leftBoundInterval = 0;
            objVertQuadRuleUz.rightBoundInterval = 1;
            objVertQuadRuleUz.inputNodes = verGLNodesUz;
            objVertQuadRuleUz.inputWeights = verWeightsUz;

            [augVerNodesUz, augVerWeightsUz] = quadratureRule(objVertQuadRuleUz);
            
            %% COMPUTATION OF THE MODAL BASIS IN THE TRANSVERSE DIRECTION
            %-------------------------------------------------------------%
            % The next method takes the coefficients of the bilinear form,
            % the dimension of the modal basis (assigned in the demo) and
            % the vertical evaluation points and computes the coefficients
            % of the modal basis when evaluated in the points of the
            % transverse fiber.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisP = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisP.dimLegendreBase = obj.discStruct.numbModesP;
            objNewModalBasisP.evalLegendreNodes = verGLNodesP;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisP.dimModalBasis = obj.discStruct.numbModesP;
            objNewModalBasisP.evalNodesY = verGLNodesP;
            objNewModalBasisP.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_P;
            objNewModalBasisP.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_P;
            objNewModalBasisP.coeffForm = obj.probParameters;

            [modalBasisP, modalBasisDerYP, modalBasisDerZP] = newModalBasisStokes3D(objNewModalBasisP);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUx = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUx.dimLegendreBase = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalLegendreNodes = verGLNodesUx;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUx.dimModalBasis = obj.discStruct.numbModesUx;
            objNewModalBasisUx.evalNodesY = verGLNodesUx;
            objNewModalBasisUx.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Ux;
            objNewModalBasisUx.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Ux;
            objNewModalBasisUx.coeffForm = obj.probParameters;

            [modalBasisUx, modalBasisDerYUx, modalBasisDerZUx] = newModalBasisStokes3D(objNewModalBasisUx);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUy = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUy.dimLegendreBase = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalLegendreNodes = verGLNodesUy;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUy.dimModalBasis = obj.discStruct.numbModesUy;
            objNewModalBasisUy.evalNodesY = verGLNodesUy;
            objNewModalBasisUy.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Uy;
            objNewModalBasisUy.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Uy;
            objNewModalBasisUy.coeffForm = obj.probParameters;

            [modalBasisUy, modalBasisDerYUy, modalBasisDerZUy] = newModalBasisStokes3D(objNewModalBasisUy);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z MODAL BASIS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            objNewModalBasisUz = BasisHandler();
            
            % Set variables to use a Legendre Modal Base
            
            objNewModalBasisUz.dimLegendreBase = obj.discStruct.numbModesUz;
            objNewModalBasisUz.evalLegendreNodes = verGLNodesUz;
            
            % Set variables to use a Educated Modal Basis
            
            objNewModalBasisUz.dimModalBasis = obj.discStruct.numbModesUz;
            objNewModalBasisUz.evalNodesY = verGLNodesUz;
            objNewModalBasisUz.labelUpBoundCond = obj.boundCondStruct.bc_up_tag_Uz;
            objNewModalBasisUz.labelDownBoundCond = obj.boundCondStruct.bc_down_tag_Uz;
            objNewModalBasisUz.coeffForm = obj.probParameters;

            [modalBasisUz, modalBasisDerYUz, modalBasisDerZUz] = newModalBasisStokes3D(objNewModalBasisUz);
            
            %% EVALUATION OF THE GEOMETRIC PROPERTIES OF THE DOMAIN
            %-------------------------------------------------------------%
            % We use the horizontal mesh created previously to evaluate the
            % thickness and the vertical coordinate of the centerline of
            % the channel.
            %-------------------------------------------------------------%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PRESSURE PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [XP,YP,ZP] = mapOut3DHiMod(horEvalNodesP,augVerNodesP,augVerNodesP,obj.geometricInfo,type);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG X PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % [XUx,YUx,ZUx] = mapOut3DHiMod(horEvalNodesUx,augVerNodesUx,augVerNodesUx,obj.geometricInfo,type);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Y PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % [XUy,YUy,ZUy] = mapOut3DHiMod(horEvalNodesUy,augVerNodesUy,augVerNodesUy,obj.geometricInfo,type);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % VELOCITY FIELD ALONG Z PHYSICAL DOMAIN %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % [XUz,YUz,ZUz] = mapOut3DHiMod(horEvalNodesUz,augVerNodesUz,augVerNodesUz,obj.geometricInfo,type);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATE GEOMETRIC STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            geoData.XP = XP;
            geoData.YP = YP;
            geoData.ZP = ZP;
            % geoData.XUx = XUx;
            % geoData.YUx = YUx;
            % geoData.ZUx = ZUx;
            % geoData.XUy = XUy;
            % geoData.YUy = YUy;
            % geoData.ZUy = ZUy;
            % geoData.XUz = XUz;
            % geoData.YUz = YUz;
            % geoData.ZUz = ZUz;
            geoData.horNodesP = horEvalNodesP;
            geoData.verNodesP = augVerNodesP;
            % geoData.horNodesUx = horEvalNodesUx;
            % geoData.verNodesUx = augVerNodesUx;
            % geoData.horNodesUy = horEvalNodesUy;
            % geoData.verNodesUy = augVerNodesyx;
            % geoData.horNodesUz = horEvalNodesUz;
            % geoData.verNodesUz = augVerNodesUz;
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % JACOBIAN PROPERTIES %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            [evalJac,structPsi,evalDetJac] = jacOut3DHiMod(horEvalNodesP,augVerNodesP, ...
                                                           augVerNodesP,obj.geometricInfo,type);   

            Psi1_dx = structPsi.Psi1_dx;
            Psi1_dy = structPsi.Psi1_dy;
            Psi1_dz = structPsi.Psi1_dz;
            Psi2_dx = structPsi.Psi2_dx;
            Psi2_dy = structPsi.Psi2_dy;
            Psi2_dz = structPsi.Psi2_dz;
            Psi3_dx = structPsi.Psi3_dx;
            Psi3_dy = structPsi.Psi3_dy;
            Psi3_dz = structPsi.Psi3_dz;
            
            jacFunc.evalJac     = evalJac;
            jacFunc.evalDetJac  = evalDetJac;
            jacFunc.PsiX_dx     = Psi1_dx;
            jacFunc.PsiX_dy     = Psi1_dy;
            jacFunc.PsiX_dz     = Psi1_dz;
            jacFunc.PsiY_dx     = Psi2_dx;
            jacFunc.PsiY_dy     = Psi2_dy;
            jacFunc.PsiY_dz     = Psi2_dz;
            jacFunc.PsiZ_dx     = Psi3_dx;
            jacFunc.PsiZ_dy     = Psi3_dy;
            jacFunc.PsiZ_dz     = Psi3_dz;
            
            %% MEMORY ALLOCATION FOR SYSTEM MATRICES
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE STIFFNESS MATRIX %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Axx = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Ayy = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Azz = sparse( numbControlPtsUz * (obj.discStruct.numbModesUz), numbControlPtsUz * (obj.discStruct.numbModesUz) );
            
            Bxy = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Bxz = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsUz * (obj.discStruct.numbModesUz) );
            Byz = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUz * (obj.discStruct.numbModesUz) );
            Byx = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Bzx = sparse( numbControlPtsUz * (obj.discStruct.numbModesUz), numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Bzy = sparse( numbControlPtsUz * (obj.discStruct.numbModesUz), numbControlPtsUy * (obj.discStruct.numbModesUy) );
            
            Px  = sparse( numbControlPtsUx * (obj.discStruct.numbModesUx), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Py  = sparse( numbControlPtsUy * (obj.discStruct.numbModesUy), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            Pz  = sparse( numbControlPtsUz * (obj.discStruct.numbModesUz), numbControlPtsP  * (obj.discStruct.numbModesP)  );
            
            Qx  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUx * (obj.discStruct.numbModesUx) );
            Qy  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUy * (obj.discStruct.numbModesUy) );
            Qx  = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsUz * (obj.discStruct.numbModesUz) );
            
            P   = sparse( numbControlPtsP  * (obj.discStruct.numbModesP) , numbControlPtsP  * (obj.discStruct.numbModesP)  );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLOCK COMPONENTS OF THE SOURCE TERM %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Fx = zeros ( numbControlPtsUx * (obj.discStruct.numbModesUx), 1);
            Fy = zeros ( numbControlPtsUy * (obj.discStruct.numbModesUy), 1);
            Fz = zeros ( numbControlPtsUz * (obj.discStruct.numbModesUz), 1);
            Fp = zeros ( numbControlPtsP  * (obj.discStruct.numbModesP ), 1);

            %% EVALUATION OF THE BILINEAR COEFFICIENTS OF THE DOMAIN
            %-------------------------------------------------------------%
            % We need to evaluate all the coefficients of the bilinear form
            % in the quadrature nodes along the vertical direction to
            % perform the first integral (along the transverse fiber) to
            % obtain a the coefficients of the 1D coupled problem. The
            % result will be coefficients as a function of 'x'.
            %-------------------------------------------------------------%

            % KINETIC VISCOSITY OF THE FLUID

            evalNu    = obj.probParameters.nu(XP,YP,ZP);
            
            % ARTIFICIAL REACTION OF THE FLUID

            evalSigma = obj.probParameters.sigma(XP,YP,ZP);
            
            % PRESSURE COMPENSATION

            evalDelta = obj.probParameters.delta(XP,YP,ZP);

            %% EVALUATION OF THE EXCITING FORCE 
            %-------------------------------------------------------------%
            % Finally, we use the horizontal and vertical meshes to
            % evaluate the exciting force acting on the system in the whole
            % domain.
            %-------------------------------------------------------------%

            evalForceX = obj.probParameters.force_x(XP,YP,ZP);
            evalForceY = obj.probParameters.force_y(XP,YP,ZP);
            evalForceZ = obj.probParameters.force_z(XP,YP,ZP);

            %-------------------------------------------------------------%
            % Note: All of the coefficients of the bilinear form and the
            % exciting term evaluated in the domain, as well as the mesh of
            % vertical coordinates are stored in a data structure called
            % "Computed" to be treated in the assembler function.
            %-------------------------------------------------------------%

            Computed.nu = evalNu;
            Computed.sigma = evalSigma;
            Computed.delta = evalDelta;
            Computed.forceX = evalForceX;
            Computed.forceY = evalForceY;
            Computed.forceZ = evalForceZ;
            Computed.y = augVerNodesP;

            %% Axx 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUx(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUx(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUx(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Mx_mb,Ax_mb,Fx_mb] = assemblerIGAScatterAxx3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Axx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Ax_mb;
                    Mxx(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Mx_mb;

                end

                % Assignment of the Block Vector Just Assembled
                
                Fx( 1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx ) = Fx_mb;
            end

            tAxx = toc;

            disp(['Axx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAxx),' [s]']);

            %% Ayy 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUy(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUy(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUy(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [My_mb,Ay_mb,Fy_mb] = assemblerIGAScatterAyy3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Ayy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Ay_mb;
                    Myy(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = My_mb;

                end

                % Assignment of the Block Vector Just Assembled
                
                Fy( 1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy ) = Fy_mb;
            end

            tAyy = toc;

            disp(['Ayy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAyy),' [s]']);
            
            %% Azz 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUz
                for jmb = 1:obj.discStruct.numbModesUz

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUz;
                    assemblerStruct.wgh2       = augVerWeightsUz;
                    assemblerStruct.mb1        = modalBasisUz(:,kmb);
                    assemblerStruct.mb2        = modalBasisUz(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUz(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUz(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUz(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUz(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUz;
                    assemblerStruct.msh2       = mshUz;
                    assemblerStruct.space1     = spaceUz;
                    assemblerStruct.space2     = spaceUz;
                    assemblerStruct.spaceFunc1 = spaceFuncUz;
                    assemblerStruct.spaceFunc2 = spaceFuncUz;

                    [Mz_mb,Az_mb,Fz_mb] = assemblerIGAScatterAzz3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Azz(1 + (kmb-1) * numbControlPtsUz : kmb * numbControlPtsUz , 1 + (jmb-1) * numbControlPtsUz : jmb * numbControlPtsUz) = Az_mb;
                    Mzz(1 + (kmb-1) * numbControlPtsUz : kmb * numbControlPtsUz , 1 + (jmb-1) * numbControlPtsUz : jmb * numbControlPtsUz) = Mz_mb;

                end

                % Assignment of the Block Vector Just Assembled
                
                Fz( 1 + (kmb-1) * numbControlPtsUz : kmb * numbControlPtsUz ) = Fz_mb;
            end

            tAzz = toc;

            disp(['Azz - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tAzz),' [s]']);
            
            %% Bxy 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUx(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUy(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUx(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Bxy_mb] = assemblerIGAScatterBxy3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Bxy(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Bxy_mb;

                end
            end

            tBxy = toc;

            disp(['Bxy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tBxy),' [s]']);
            
            %% Byx 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUy(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUx(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUy(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Byx_mb] = assemblerIGAScatterByx3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Byx(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Byx_mb;

                end
            end

            tByx = toc;

            disp(['Byx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tByx),' [s]']);
            
            %% Bxz 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUx
                for jmb = 1:obj.discStruct.numbModesUz

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUx;
                    assemblerStruct.wgh2       = augVerWeightsUz;
                    assemblerStruct.mb1        = modalBasisUx(:,kmb);
                    assemblerStruct.mb2        = modalBasisUz(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUx(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUz(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUx(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUz(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUx;
                    assemblerStruct.msh2       = mshUz;
                    assemblerStruct.space1     = spaceUx;
                    assemblerStruct.space2     = spaceUz;
                    assemblerStruct.spaceFunc1 = spaceFuncUx;
                    assemblerStruct.spaceFunc2 = spaceFuncUz;

                    [Bxz_mb] = assemblerIGAScatterBxz3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Bxz(1 + (kmb-1) * numbControlPtsUx : kmb * numbControlPtsUx , 1 + (jmb-1) * numbControlPtsUz : jmb * numbControlPtsUz) = Bxz_mb;

                end
            end

            tBxz = toc;

            disp(['Bxz - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tBxz),' [s]']);
            
            %% Bzx 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUz
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUz;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisUz(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUz(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUx(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUz(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUz;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceUz;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncUz;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Bzx_mb] = assemblerIGAScatterBzx3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Bzx(1 + (kmb-1) * numbControlPtsUz : kmb * numbControlPtsUz , 1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx) = Bzx_mb;

                end
            end

            tBzx = toc;

            disp(['Bzx - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tBzx),' [s]']);
            
            %% Byz 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUy
                for jmb = 1:obj.discStruct.numbModesUz

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUy;
                    assemblerStruct.wgh2       = augVerWeightsUz;
                    assemblerStruct.mb1        = modalBasisUy(:,kmb);
                    assemblerStruct.mb2        = modalBasisUz(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUy(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUz(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUy(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUz(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUy;
                    assemblerStruct.msh2       = mshUz;
                    assemblerStruct.space1     = spaceUy;
                    assemblerStruct.space2     = spaceUz;
                    assemblerStruct.spaceFunc1 = spaceFuncUy;
                    assemblerStruct.spaceFunc2 = spaceFuncUz;

                    [Byz_mb] = assemblerIGAScatterByz3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Byz(1 + (kmb-1) * numbControlPtsUy : kmb * numbControlPtsUy , 1 + (jmb-1) * numbControlPtsUz : jmb * numbControlPtsUz) = Byz_mb;

                end
            end

            tByz = toc;

            disp(['Byz - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tByz),' [s]']);
            
            %% Bzy 3D - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesUz
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsUz;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisUz(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYUz(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUy(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZUz(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshUz;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceUz;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncUz;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Bzy_mb] = assemblerIGAScatterBzy3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Bzy(1 + (kmb-1) * numbControlPtsUz : kmb * numbControlPtsUz , 1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy) = Bzy_mb;

                end
            end

            tBzy = toc;

            disp(['Bzy - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tBzy),' [s]']);
            
            %% Px 3D  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUx

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUx;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUx(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYP(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUx(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZP(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUx(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUx;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUx;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUx;

                    [Px_mb] = assemblerIGAScatterPx3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Px(1 + (jmb-1) * numbControlPtsUx : jmb * numbControlPtsUx , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Px_mb';

                end
            end

            tPx = toc;

            disp(['Px  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPx),' [s]']);

            %% Py 3D  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUy

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUy;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUy(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYP(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUy(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZP(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUy(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUy;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUy;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUy;

                    [Py_mb] = assemblerIGAScatterPy3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Py(1 + (jmb-1) * numbControlPtsUy : jmb * numbControlPtsUy , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Py_mb';

                end
            end

            tPy = toc;

            disp(['Py  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPy),' [s]']);
            
            %% Pz 3D  - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesUz

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsUz;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisUz(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYP(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYUz(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZP(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZUz(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshUz;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceUz;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncUz;

                    [Pz_mb] = assemblerIGAScatterPz3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    Pz(1 + (jmb-1) * numbControlPtsUz : jmb * numbControlPtsUz , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = Pz_mb';

                end
            end

            tPz = toc;

            disp(['Pz  - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tPz),' [s]']);

            %% Qx 3D  - ASSEMBLING LOOP

            Qx = 1 * Px';

            %% Qy 3D  - ASSEMBLING LOOP

            Qy = 1 * Py';
            
            %% Qz 3D  - ASSEMBLING LOOP

            Qz = 1 * Pz';
            
            %% P 3D   - ASSEMBLING LOOP

            assemblerStruct = [];

            tic;

            for kmb = 1:obj.discStruct.numbModesP
                for jmb = 1:obj.discStruct.numbModesP

                    assemblerStruct.index1     = kmb;
                    assemblerStruct.index2     = jmb;
                    assemblerStruct.wgh1       = augVerWeightsP;
                    assemblerStruct.wgh2       = augVerWeightsP;
                    assemblerStruct.mb1        = modalBasisP(:,kmb);
                    assemblerStruct.mb2        = modalBasisP(:,jmb);
                    assemblerStruct.dymb1      = modalBasisDerYP(:,kmb);
                    assemblerStruct.dymb2      = modalBasisDerYP(:,jmb);
                    assemblerStruct.dzmb1      = modalBasisDerZP(:,kmb);
                    assemblerStruct.dzmb2      = modalBasisDerZP(:,jmb);
                    assemblerStruct.param      = Computed;
                    assemblerStruct.geodata    = geoData;
                    assemblerStruct.jacFunc    = jacFunc;
                    assemblerStruct.msh1       = mshP;
                    assemblerStruct.msh2       = mshP;
                    assemblerStruct.space1     = spaceP;
                    assemblerStruct.space2     = spaceP;
                    assemblerStruct.spaceFunc1 = spaceFuncP;
                    assemblerStruct.spaceFunc2 = spaceFuncP;

                    [P_mb] = assemblerIGAScatterP3D(assemblerStruct);

                    % Assignment of the Block Matrix Just Assembled

                    P(1 + (jmb-1) * numbControlPtsP : jmb * numbControlPtsP , 1 + (kmb-1) * numbControlPtsP : kmb * numbControlPtsP) = P_mb;

                end
            end

            tP = toc;

            disp(['P   - FINISHED ASSEMBLING LOOP - SIM. TIME Ts = ',num2str(tP),' [s]']);

            %% COMPUTE PROJECTION OF BOUNDARY CONDITIONS
            %---------------------------------------------------------%
            % Compute the projection of the inflow and outflow
            % boundary conditions using the expression for the modal
            % expansion and impose them in the stiffness matrix.
            %---------------------------------------------------------%

            tic;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CREATION OF THE BOUNDARY STRUCTURE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.boundCondStruc   = obj.boundCondStruct;
            
            boundaryStruct.bcInfTagUx       = obj.boundCondStruct.bc_inf_tag_Ux;
            boundaryStruct.bcOutTagUx       = obj.boundCondStruct.bc_out_tag_Ux;
            boundaryStruct.bcInfTagUy       = obj.boundCondStruct.bc_inf_tag_Uy;
            boundaryStruct.bcOutTagUy       = obj.boundCondStruct.bc_out_tag_Uy;
            boundaryStruct.bcInfTagUz       = obj.boundCondStruct.bc_inf_tag_Uz;
            boundaryStruct.bcOutTagUz       = obj.boundCondStruct.bc_out_tag_Uz;
            
            boundaryStruct.bcInfDataUx      = obj.boundCondStruct.bc_inf_data_Ux;
            boundaryStruct.bcOutDataUx      = obj.boundCondStruct.bc_out_data_Ux;
            boundaryStruct.bcInfDataUy      = obj.boundCondStruct.bc_inf_data_Uy;
            boundaryStruct.bcOutDataUy      = obj.boundCondStruct.bc_out_data_Uy;
            boundaryStruct.bcInfDataUz      = obj.boundCondStruct.bc_inf_data_Uz;
            boundaryStruct.bcOutDataUz      = obj.boundCondStruct.bc_out_data_Uz;
            
            boundaryStruct.augVerNodesUx    = augVerNodesUx;
            boundaryStruct.augVerWeightsUx  = augVerWeightsUx;
            boundaryStruct.augVerNodesUy    = augVerNodesUy;
            boundaryStruct.augVerWeightsUy  = augVerWeightsUy;
            boundaryStruct.augVerNodesUz    = augVerNodesUz;
            boundaryStruct.augVerWeightsUz  = augVerWeightsUz;
            
            boundaryStruct.modalBasisUx     = modalBasisUx;
            boundaryStruct.modalBasisUy     = modalBasisUy;
            boundaryStruct.modalBasisUz     = modalBasisUz;
            
            boundaryStruct.numbModesUx      = obj.discStruct.numbModesUx;
            boundaryStruct.numbModesUy      = obj.discStruct.numbModesUy;
            boundaryStruct.numbModesUz      = obj.discStruct.numbModesUz;
            
            boundaryStruct.numbCtrlPtsUx    = numbControlPtsUx;
            boundaryStruct.numbCtrlPtsUy    = numbControlPtsUy;
            boundaryStruct.numbCtrlPtsUz    = numbControlPtsUz;
            
            boundaryStruct.Axx = Axx;
            boundaryStruct.Ayy = Ayy;
            boundaryStruct.Azz = Azz;
            boundaryStruct.Bxy = Bxy;
            boundaryStruct.Bxz = Bxz;
            boundaryStruct.Byz = Byz;
            boundaryStruct.Byx = Byx;
            boundaryStruct.Bzx = Bzx;
            boundaryStruct.Bzy = Bzy;
            boundaryStruct.Px  = Px;
            boundaryStruct.Py  = Py;
            boundaryStruct.Pz  = Pz;
            boundaryStruct.Fx  = Fx;
            boundaryStruct.Fy  = Fy;
            boundaryStruct.Fz  = Fz;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE THE PROJECTION OF THE BOUNDARY CONDTIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [bcDataStruct] = computeFourierCoeffStokes3D(obj_bcCoeff);
            
            %% IMPOSE BOUNDARY CONDITIONS

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % IMPOSE BOUNDARY CONDITIONS %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            boundaryStruct.projInfBCUx = bcDataStruct.infStructUx;
            boundaryStruct.projOutBCUx = bcDataStruct.outStructUx;
            boundaryStruct.projInfBCUy = bcDataStruct.infStructUy;
            boundaryStruct.projOutBCUy = bcDataStruct.outStructUy;
            boundaryStruct.projInfBCUz = bcDataStruct.infStructUz;
            boundaryStruct.projOutBCUz = bcDataStruct.outStructUz;

            obj_bcCoeff = BoundaryConditionHandler();

            obj_bcCoeff.boundaryStruct = boundaryStruct;

            [probDataStruct] = imposeBoundaryStokes3D(obj_bcCoeff);
            
            Axx = probDataStruct.Axx;
            Ayy = probDataStruct.Ayy;
            Azz = probDataStruct.Azz;
            Bxy = probDataStruct.Bxy;
            Bxz = probDataStruct.Bxz;
            Byz = probDataStruct.Byz;
            Byx = probDataStruct.Byx;
            Bzx = probDataStruct.Bzx;
            Bzy = probDataStruct.Bzy;
            Px  = probDataStruct.Px;
            Py  = probDataStruct.Py;
            Pz  = probDataStruct.Pz;
            Fx  = probDataStruct.Fx;
            Fy  = probDataStruct.Fy;
            Fz  = probDataStruct.Fz;
            
            tImp = toc;

            %% GLOBAL SYSTEM ASSEMBLING

            tic;

            AA = [Axx,Bxy,Bxz,Px;Byx,Ayy,Byz,Py;Bzx,Bzy,Azz,Pz;Qx,Qy,Qz,P];
            FF = [Fx;Fy;Fz;Fp];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % DEBUG
            
            disp('DEBUG INSIDE ASSEMBLER')
            
            rcond(full(Axx))
            rcond(full(Ayy))
            rcond(full(Azz))
            rcond(full(Bxy))
            rcond(full(Byx))
            rcond(full(Bxz))
            rcond(full(Bzx))
            rcond(full(Byz))
            rcond(full(Bzy))
            rcond(full(Px))
            rcond(full(Py))
            rcond(full(Pz))
            rcond(full(Qx))
            rcond(full(Qy))
            rcond(full(Qz))
            rcond(full(P))
            
            return
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            tGMat = toc;

            disp(['FINISHED ASSEMBLING GLOBAL MATRIX - SIM. TIME Ts = ',num2str(tGMat),' [s]']);

            tTotal = tAxx + tAyy+ tAzz + tBxy+ tBxz + tByx + tByz + tBzx + tBzy + tPx + tPy+ tPz + tImp + tGMat;

            disp('  '); 
            disp('---------------------------------------------------------------------------------------------')
            disp(['FINISHED ASSEMBLING - SIM. TIME Ts = ',num2str(tTotal),' [s]']);
            disp('---------------------------------------------------------------------------------------------')
            disp('  '); 

            %% CREATE PLOT STRUCTURE

            % NUMBER OF CONTROL POINTS
            
            plotStruct.numbControlPtsP  = numbControlPtsP;
            plotStruct.numbControlPtsUx = numbControlPtsUx;
            plotStruct.numbControlPtsUy = numbControlPtsUy;
            plotStruct.numbControlPtsUz = numbControlPtsUz;
            
            % NUMBER OF ELEMENTS IN THE KNOT VECTOR
            
            plotStruct.numbKnotsP       = numbKnotsP;
            plotStruct.numbKnotsUx      = numbKnotsUx;
            plotStruct.numbKnotsUy      = numbKnotsUy;
            plotStruct.numbKnotsUz      = numbKnotsUz;
            
            % GEOMETRIC INFORMATION ABOUT THE PHYSICAL DOMAIN
            
            plotStruct.geometricInfo    = obj.geometricInfo;
            
            % DICRETIZATION PARAMETERS
            
            plotStruct.discStruct       = obj.discStruct;
            
            % STRUCTURE CONTAINING THE INFORMATION ON THE BOUNDARY
            
            plotStruct.boundaryStruct   = boundaryStruct;
            
            % ISOGEOMETRIC TESSELATION OF THE SUPPORTING FIBRE
            
            plotStruct.mshP             = mshP;
            plotStruct.mshUx            = mshUx;
            plotStruct.mshUy            = mshUy;
            plotStruct.mshUz            = mshUz;
            
            % ISOGEOMTRIC FUNCTIONAL SPACE
            
            plotStruct.spaceP           = spaceP;
            plotStruct.spaceUx          = spaceUx;
            plotStruct.spaceUy          = spaceUy;
            plotStruct.spaceUz          = spaceUz;
            
            % STRUCTURE OF OPERATOR DEFINED IN THE ISOGEOMETRIC FUNCTIONAL
            % SPACES
            
            plotStruct.spaceFuncP       = spaceFuncP;
            plotStruct.spaceFuncUx      = spaceFuncUx;
            plotStruct.spaceFuncUy      = spaceFuncUy;
            plotStruct.spaceFuncUz      = spaceFuncUz;
            
            % JACOBIAN PROPERTIES OF THE MAP
            
            plotStruct.jacFunc          = jacFunc;
            plotStruct.refDomain1D      = refDomain1D;
            
            % PROBLEM PARAMETERS
            
            plotStruct.probParameters   = obj.probParameters;
            
            % MAP INFORMATION FROM THE PHYSICAL TO THE REFERENCE DOMAIN
            
            plotStruct.map              = map;
                
            end
            
    end
end

%% ASSEMBLER STOKES HANDLER - ASSEMBLING METHODS

%% Method 'assemblerIGAScatterAxSimplified'
            
function [Mx,Ax,Fx] = assemblerIGAScatterAxSimplified(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceX) .* assemblerStruct.jacFunc.evalDetJac;
    funcWeight      = assemblerStruct.mb2 .* assemblerStruct.wgh2;
    forceVec        = sum(funcToIntegrale .* funcWeight , 1);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_02 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_03 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_04 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_05 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    funcToIntegrate_06 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_07 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_08 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_09 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_10 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi2_dy;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_05 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_06 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_07 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_08 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_09 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_10 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    aux5   = sum(funcToIntegrate_05 .* funcWeight_05 , 1);
    aux6   = sum(funcToIntegrate_06 .* funcWeight_06 , 1);
    aux7   = sum(funcToIntegrate_07 .* funcWeight_07 , 1);
    aux8   = sum(funcToIntegrate_08 .* funcWeight_08 , 1);
    aux9   = sum(funcToIntegrate_09 .* funcWeight_09 , 1);
    aux10  = sum(funcToIntegrate_10 .* funcWeight_10 , 1);
    
    % Definition of the modal coefficients
    
    m00 = aux5;
    r00 = aux4 + aux6 + aux10;
    r10 = aux3 + aux9;
    r01 = aux2 + aux8;
    r11 = aux1 + aux7;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    Mx  = Local_Mass;
    Ax  = Local_11 + Local_10 + Local_01 + Local_00;
    Fx  = rhs;
    
end

%% Method 'assemblerIGAScatterAySimplified'
            
function [My,Ay,Fy] = assemblerIGAScatterAySimplified(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceY) .* assemblerStruct.jacFunc.evalDetJac;
    funcWeight      = assemblerStruct.mb2 .* assemblerStruct.wgh2;
    forceVec        = sum(funcToIntegrale .* funcWeight , 1);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_02 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_03 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_04 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_05 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    funcToIntegrate_06 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_07 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_08 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_09 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_10 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi2_dy;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_05 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_06 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_07 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_08 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_09 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_10 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    aux5   = sum(funcToIntegrate_05 .* funcWeight_05 , 1);
    aux6   = sum(funcToIntegrate_06 .* funcWeight_06 , 1);
    aux7   = sum(funcToIntegrate_07 .* funcWeight_07 , 1);
    aux8   = sum(funcToIntegrate_08 .* funcWeight_08 , 1);
    aux9   = sum(funcToIntegrate_09 .* funcWeight_09 , 1);
    aux10  = sum(funcToIntegrate_10 .* funcWeight_10 , 1);
    
    % Definition of the modal coefficients
    
    m00 = aux5;
    r00 = aux4 + aux6 + aux10;
    r10 = aux3 + aux9;
    r01 = aux2 + aux8;
    r11 = aux1 + aux7;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    My  = Local_Mass;
    Ay  = Local_11 + Local_10 + Local_01 + Local_00;
    Fy  = rhs;
    
end

%% Method 'assemblerIGAScatterAx'
            
function [Mx,Ax,Fx] = assemblerIGAScatterAx(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceX) .* assemblerStruct.jacFunc.evalDetJac;
    funcWeight      = assemblerStruct.mb2 .* assemblerStruct.wgh2;
    forceVec        = sum(funcToIntegrale .* funcWeight , 1);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_02 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_03 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_04 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_09 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_10 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_05 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_06 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_07 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_08 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_09 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_10 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    aux5   = sum(funcToIntegrate_05 .* funcWeight_05 , 1);
    aux6   = sum(funcToIntegrate_06 .* funcWeight_06 , 1);
    aux7   = sum(funcToIntegrate_07 .* funcWeight_07 , 1);
    aux8   = sum(funcToIntegrate_08 .* funcWeight_08 , 1);
    aux9   = sum(funcToIntegrate_09 .* funcWeight_09 , 1);
    aux10  = sum(funcToIntegrate_10 .* funcWeight_10 , 1);
    
    % Definition of the modal coefficients
    
    m00 = aux10;
    r00 = aux4 + aux8 + aux9;
    r10 = aux3 + aux7;
    r01 = aux2 + aux6;
    r11 = aux1 + aux5;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    Mx  = Local_Mass;
    Ax  = Local_11 + Local_10 + Local_01 + Local_00;
    Fx  = rhs;
    
end

%% Method 'assemblerIGAScatterAy'
            
function [My,Ay,Fy] = assemblerIGAScatterAy(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceY) .* assemblerStruct.jacFunc.evalDetJac;
    funcWeight      = assemblerStruct.mb2 .* assemblerStruct.wgh2;
    forceVec        = sum(funcToIntegrale .* funcWeight , 1);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_02 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_03 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_04 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dy .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dx;
    funcToIntegrate_09 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_10 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_05 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_06 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_07 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_08 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_09 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_10 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    aux5   = sum(funcToIntegrate_05 .* funcWeight_05 , 1);
    aux6   = sum(funcToIntegrate_06 .* funcWeight_06 , 1);
    aux7   = sum(funcToIntegrate_07 .* funcWeight_07 , 1);
    aux8   = sum(funcToIntegrate_08 .* funcWeight_08 , 1);
    aux9   = sum(funcToIntegrate_09 .* funcWeight_09 , 1);
    aux10  = sum(funcToIntegrate_10 .* funcWeight_10 , 1);
    
    % Definition of the modal coefficients
    
    m00 = aux10;
    r00 = aux4 + aux8 + aux9;
    r10 = aux3 + aux7;
    r01 = aux2 + aux6;
    r11 = aux1 + aux5;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    My  = Local_Mass;
    Ay  = Local_11 + Local_10 + Local_01 + Local_00;
    Fy  = rhs;
    
end

%% Method 'assemblerIGAScatterBxy'
            
function [Bxy] = assemblerIGAScatterBxy(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_02 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_03 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_04 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dy;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    
    % Definition of the modal coefficients
    
    r00 = aux4;
    r10 = aux3;
    r01 = aux2;
    r11 = aux1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
    end

    Bxy = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterByx'
            
function [Byx] = assemblerIGAScatterByx(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_02 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi1_dx .* assemblerStruct.jacFunc.Phi2_dy;
    funcToIntegrate_03 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_04 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.Phi2_dx .* assemblerStruct.jacFunc.Phi2_dy;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    funcWeight_03 = assemblerStruct.dmb1 .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_04 = assemblerStruct.dmb1 .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    aux3   = sum(funcToIntegrate_03 .* funcWeight_03 , 1);
    aux4   = sum(funcToIntegrate_04 .* funcWeight_04 , 1);
    
    % Definition of the modal coefficients
    
    r00 = aux4;
    r10 = aux3;
    r01 = aux2;
    r11 = aux1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
    end

    Byx = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterPx'
            
function [Px] = assemblerIGAScatterPx(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.Phi1_dx;
    funcToIntegrate_02 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.Phi2_dx;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    
    % Definition of the modal coefficients
    
    r00 = aux2;
    r01 = aux1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local)';
        
    end

    Px = Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterPy'
            
function [Py] = assemblerIGAScatterPy(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.Phi1_dy;
    funcToIntegrate_02 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.Phi2_dy;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    funcWeight_02 = assemblerStruct.mb1  .* assemblerStruct.dmb2 .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    aux2   = sum(funcToIntegrate_02 .* funcWeight_02 , 1);
    
    % Definition of the modal coefficients
    
    r00 = aux2;
    r01 = aux1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local)';
        
    end

    Py = Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterP'
            
function [P] = assemblerIGAScatterP(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    % Computation of coefficients of the modal expansion
    
    funcToIntegrate_01 = assemblerStruct.param.delta .* assemblerStruct.jacFunc.evalDetJac;
    
    % Computation of quadrature weights for the modal expansion
    
    funcWeight_01 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* assemblerStruct.wgh2;
    
    % Numerical integration of the modal coefficients
    
    aux1   = sum(funcToIntegrate_01 .* funcWeight_01 , 1);
    
    % Definition of the modal coefficients
    
    r00 = aux1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        
    end

    P = Local_00;
    
end

%% Method 'assemblerIGAScatterAxx3D'
            
function [Mxx,Axx,Fxx] = assemblerIGAScatterAxx3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceX) .* assemblerStruct.jacFunc.evalDetJac;
    weightMat       = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    funcWeight      = assemblerStruct.mb2 .* weightMat;
    
    aux         = funcToIntegrale .* funcWeight;
    auxx        = sum(sum(aux));
    forceVec(:) = auxx(1,1,:);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcToIntegrate_01 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_02 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_03 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_04 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_05 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_06 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_07 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_08 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_09 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    
    funcToIntegrate_10 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_11 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_12 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_13 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_14 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_15 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_16 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_17 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_18 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    
    funcToIntegrate_21 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_22 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_23 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_24 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_25 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_26 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_27 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_28 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_29 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    
    % TIME COMPONENTS
    
    funcToIntegrate_19 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_20 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_10 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_11 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_12 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_13 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_14 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_15 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_16 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_17 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_18 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_21 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_22 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_23 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_24 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_25 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_26 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_27 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_28 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_29 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    % TIME COMPONENTS
    
    funcWeight_19 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    funcWeight_20 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;
    
    aux10 = funcToIntegrate_10 .* funcWeight_10;
    aux11 = funcToIntegrate_11 .* funcWeight_11;
    aux12 = funcToIntegrate_12 .* funcWeight_12;
    aux13 = funcToIntegrate_13 .* funcWeight_13;
    aux14 = funcToIntegrate_14 .* funcWeight_14;
    aux15 = funcToIntegrate_15 .* funcWeight_15;
    aux16 = funcToIntegrate_16 .* funcWeight_16;
    aux17 = funcToIntegrate_17 .* funcWeight_17;
    aux18 = funcToIntegrate_18 .* funcWeight_18;
    
    aux21 = funcToIntegrate_21 .* funcWeight_21;
    aux22 = funcToIntegrate_22 .* funcWeight_22;
    aux23 = funcToIntegrate_23 .* funcWeight_23;
    aux24 = funcToIntegrate_24 .* funcWeight_24;
    aux25 = funcToIntegrate_25 .* funcWeight_25;
    aux26 = funcToIntegrate_26 .* funcWeight_26;
    aux27 = funcToIntegrate_27 .* funcWeight_27;
    aux28 = funcToIntegrate_28 .* funcWeight_28;
    aux29 = funcToIntegrate_29 .* funcWeight_29;
    
    aux19 = funcToIntegrate_19 .* funcWeight_19;
    aux20 = funcToIntegrate_20 .* funcWeight_20;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    auxVec10 = sum(sum(aux10));
    auxVec11 = sum(sum(aux11));
    auxVec12 = sum(sum(aux12));
    auxVec13 = sum(sum(aux13));
    auxVec14 = sum(sum(aux14));
    auxVec15 = sum(sum(aux15));
    auxVec16 = sum(sum(aux16));
    auxVec17 = sum(sum(aux17));
    auxVec18 = sum(sum(aux18));
    
    auxVec21 = sum(sum(aux21));
    auxVec22 = sum(sum(aux22));
    auxVec23 = sum(sum(aux23));
    auxVec24 = sum(sum(aux24));
    auxVec25 = sum(sum(aux25));
    auxVec26 = sum(sum(aux26));
    auxVec27 = sum(sum(aux27));
    auxVec28 = sum(sum(aux28));
    auxVec29 = sum(sum(aux29));
    
    auxVec19 = sum(sum(aux19));
    auxVec20 = sum(sum(aux20));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m00 = auxVec20;
    r00 = auxVec05 + auxVec06 + auxVec08 + auxVec09 + auxVec14 + auxVec15 + auxVec17 + auxVec18 + auxVec19 + auxVec25 + auxVec26 + auxVec28 + auxVec29;
    r10 = auxVec02 + auxVec03 + auxVec11 + auxVec12 + auxVec22 + auxVec23;
    r01 = auxVec04 + auxVec07 + auxVec13 + auxVec16 + auxVec24 + auxVec27;
    r11 = auxVec01 + auxVec10 + auxVec21;
    
    auxx0(:) = m00(1,1,:);
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    m00 = auxx0;
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    Mxx  = Local_Mass;
    Axx  = Local_11 + Local_10 + Local_01 + Local_00;
    Fxx  = rhs;
    
end

%% Method 'assemblerIGAScatterAyy3D'
            
function [Myy,Ayy,Fyy] = assemblerIGAScatterAyy3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceY) .* assemblerStruct.jacFunc.evalDetJac;
    weightMat       = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    funcWeight      = assemblerStruct.mb2 .* weightMat;
    
    aux         = funcToIntegrale .* funcWeight;
    auxx        = sum(sum(aux));
    forceVec(:) = auxx(1,1,:);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcToIntegrate_01 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_02 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_03 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_04 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_05 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_06 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_07 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_08 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_09 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    
    funcToIntegrate_10 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_11 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_12 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_13 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_14 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_15 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_16 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_17 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_18 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    
    funcToIntegrate_21 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_22 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_23 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_24 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_25 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_26 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_27 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_28 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_29 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    
    % TIME COMPONENTS
    
    funcToIntegrate_19 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_20 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_10 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_11 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_12 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_13 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_14 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_15 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_16 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_17 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_18 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_21 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_22 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_23 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_24 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_25 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_26 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_27 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_28 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_29 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    % TIME COMPONENTS
    
    funcWeight_19 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    funcWeight_20 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;
    
    aux10 = funcToIntegrate_10 .* funcWeight_10;
    aux11 = funcToIntegrate_11 .* funcWeight_11;
    aux12 = funcToIntegrate_12 .* funcWeight_12;
    aux13 = funcToIntegrate_13 .* funcWeight_13;
    aux14 = funcToIntegrate_14 .* funcWeight_14;
    aux15 = funcToIntegrate_15 .* funcWeight_15;
    aux16 = funcToIntegrate_16 .* funcWeight_16;
    aux17 = funcToIntegrate_17 .* funcWeight_17;
    aux18 = funcToIntegrate_18 .* funcWeight_18;
    
    aux21 = funcToIntegrate_21 .* funcWeight_21;
    aux22 = funcToIntegrate_22 .* funcWeight_22;
    aux23 = funcToIntegrate_23 .* funcWeight_23;
    aux24 = funcToIntegrate_24 .* funcWeight_24;
    aux25 = funcToIntegrate_25 .* funcWeight_25;
    aux26 = funcToIntegrate_26 .* funcWeight_26;
    aux27 = funcToIntegrate_27 .* funcWeight_27;
    aux28 = funcToIntegrate_28 .* funcWeight_28;
    aux29 = funcToIntegrate_29 .* funcWeight_29;
    
    aux19 = funcToIntegrate_19 .* funcWeight_19;
    aux20 = funcToIntegrate_20 .* funcWeight_20;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    auxVec10 = sum(sum(aux10));
    auxVec11 = sum(sum(aux11));
    auxVec12 = sum(sum(aux12));
    auxVec13 = sum(sum(aux13));
    auxVec14 = sum(sum(aux14));
    auxVec15 = sum(sum(aux15));
    auxVec16 = sum(sum(aux16));
    auxVec17 = sum(sum(aux17));
    auxVec18 = sum(sum(aux18));
    
    auxVec21 = sum(sum(aux21));
    auxVec22 = sum(sum(aux22));
    auxVec23 = sum(sum(aux23));
    auxVec24 = sum(sum(aux24));
    auxVec25 = sum(sum(aux25));
    auxVec26 = sum(sum(aux26));
    auxVec27 = sum(sum(aux27));
    auxVec28 = sum(sum(aux28));
    auxVec29 = sum(sum(aux29));
    
    auxVec19 = sum(sum(aux19));
    auxVec20 = sum(sum(aux20));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m00 = auxVec20;
    r00 = auxVec05 + auxVec06 + auxVec08 + auxVec09 + auxVec14 + auxVec15 + auxVec17 + auxVec18 + auxVec19 + auxVec25 + auxVec26 + auxVec28 + auxVec29;
    r10 = auxVec02 + auxVec03 + auxVec11 + auxVec12 + auxVec22 + auxVec23;
    r01 = auxVec04 + auxVec07 + auxVec13 + auxVec16 + auxVec24 + auxVec27;
    r11 = auxVec01 + auxVec10 + auxVec21;
    
    auxx0(:) = m00(1,1,:);
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    m00 = auxx0;
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    Myy  = Local_Mass;
    Ayy  = Local_11 + Local_10 + Local_01 + Local_00;
    Fyy  = rhs;
    
end

%% Method 'assemblerIGAScatterAzz3D'
            
function [Mzz,Azz,Fzz] = assemblerIGAScatterAzz3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% EXCITATION FORCE
    %---------------------------------------------------------------------%
    % Computation of the excitation force condiering the boundary
    % conditions acting on the system. The weights used to perform the
    % integration are the Gauss-Legendre nodes used in the horizontal
    % mesh.
    %---------------------------------------------------------------------%
    
    funcToIntegrale = (assemblerStruct.param.forceZ) .* assemblerStruct.jacFunc.evalDetJac;
    weightMat       = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    funcWeight      = assemblerStruct.mb2 .* weightMat;
    
    aux         = funcToIntegrale .* funcWeight;
    auxx        = sum(sum(aux));
    forceVec(:) = auxx(1,1,:);
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcToIntegrate_01 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_02 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_03 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_04 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_05 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_06 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_07 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_08 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_09 = 2 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiZ_dz;
    
    funcToIntegrate_10 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_11 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_12 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_13 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_14 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_15 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_16 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_17 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_18 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiZ_dx;
    
    funcToIntegrate_21 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_22 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_23 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_24 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_25 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_26 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_27 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_28 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_29 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiZ_dy;
    
    % TIME COMPONENTS
    
    funcToIntegrate_19 = assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.sigma;
    funcToIntegrate_20 = assemblerStruct.jacFunc.evalDetJac .* ones(size(assemblerStruct.param.nu));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_10 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_11 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_12 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_13 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_14 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_15 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_16 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_17 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_18 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    funcWeight_21 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_22 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_23 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_24 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_25 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_26 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_27 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_28 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_29 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    % TIME COMPONENTS
    
    funcWeight_19 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    funcWeight_20 = assemblerStruct.mb1  .* assemblerStruct.mb2  .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;
    
    aux10 = funcToIntegrate_10 .* funcWeight_10;
    aux11 = funcToIntegrate_11 .* funcWeight_11;
    aux12 = funcToIntegrate_12 .* funcWeight_12;
    aux13 = funcToIntegrate_13 .* funcWeight_13;
    aux14 = funcToIntegrate_14 .* funcWeight_14;
    aux15 = funcToIntegrate_15 .* funcWeight_15;
    aux16 = funcToIntegrate_16 .* funcWeight_16;
    aux17 = funcToIntegrate_17 .* funcWeight_17;
    aux18 = funcToIntegrate_18 .* funcWeight_18;
    
    aux21 = funcToIntegrate_21 .* funcWeight_21;
    aux22 = funcToIntegrate_22 .* funcWeight_22;
    aux23 = funcToIntegrate_23 .* funcWeight_23;
    aux24 = funcToIntegrate_24 .* funcWeight_24;
    aux25 = funcToIntegrate_25 .* funcWeight_25;
    aux26 = funcToIntegrate_26 .* funcWeight_26;
    aux27 = funcToIntegrate_27 .* funcWeight_27;
    aux28 = funcToIntegrate_28 .* funcWeight_28;
    aux29 = funcToIntegrate_29 .* funcWeight_29;
    
    aux19 = funcToIntegrate_19 .* funcWeight_19;
    aux20 = funcToIntegrate_20 .* funcWeight_20;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    auxVec10 = sum(sum(aux10));
    auxVec11 = sum(sum(aux11));
    auxVec12 = sum(sum(aux12));
    auxVec13 = sum(sum(aux13));
    auxVec14 = sum(sum(aux14));
    auxVec15 = sum(sum(aux15));
    auxVec16 = sum(sum(aux16));
    auxVec17 = sum(sum(aux17));
    auxVec18 = sum(sum(aux18));
    
    auxVec21 = sum(sum(aux21));
    auxVec22 = sum(sum(aux22));
    auxVec23 = sum(sum(aux23));
    auxVec24 = sum(sum(aux24));
    auxVec25 = sum(sum(aux25));
    auxVec26 = sum(sum(aux26));
    auxVec27 = sum(sum(aux27));
    auxVec28 = sum(sum(aux28));
    auxVec29 = sum(sum(aux29));
    
    auxVec19 = sum(sum(aux19));
    auxVec20 = sum(sum(aux20));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m00 = auxVec20;
    r00 = auxVec05 + auxVec06 + auxVec08 + auxVec09 + auxVec14 + auxVec15 + auxVec17 + auxVec18 + auxVec19 + auxVec25 + auxVec26 + auxVec28 + auxVec29;
    r10 = auxVec02 + auxVec03 + auxVec11 + auxVec12 + auxVec22 + auxVec23;
    r01 = auxVec04 + auxVec07 + auxVec13 + auxVec16 + auxVec24 + auxVec27;
    r11 = auxVec01 + auxVec10 + auxVec21;
    
    auxx0(:) = m00(1,1,:);
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    m00 = auxx0;
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_Mass  = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    rhs         = zeros (assemblerStruct.space1.ndof, 1);
    
    for iel = 1:numbKnots
        
        m00Local = m00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        fLocal   = forceVec((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_Mass  = Local_Mass + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, m00Local);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);
        
        rhs         = rhs + op_f_v (assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, fLocal);

    end

    Mzz  = Local_Mass;
    Azz  = Local_11 + Local_10 + Local_01 + Local_00;
    Fzz  = rhs;
    
end

%% Method 'assemblerIGAScatterBxy3D'
            
function [Bxy] = assemblerIGAScatterBxy3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiZ_dx;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Bxy  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterBxz3D'
            
function [Bxz] = assemblerIGAScatterBxz3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiZ_dx;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiZ_dx;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Bxz  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterByz3D'
            
function [Byz] = assemblerIGAScatterByz3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dz .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dz .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dz .* assemblerStruct.jacFunc.PsiZ_dy;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Byz  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterByx3D'
            
function [Byx] = assemblerIGAScatterByx3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiZ_dy;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiZ_dy;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Byx  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterBzx3D'
            
function [Bzx] = assemblerIGAScatterBzx3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dx .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dx .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dx .* assemblerStruct.jacFunc.PsiZ_dz;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Bzx  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterBzy3D'
            
function [Bzy] = assemblerIGAScatterBzy3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_02 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_03 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiX_dy .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_04 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_05 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_06 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiY_dy .* assemblerStruct.jacFunc.PsiZ_dz;
    funcToIntegrate_07 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_08 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_09 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.nu .* assemblerStruct.jacFunc.PsiZ_dy .* assemblerStruct.jacFunc.PsiZ_dz;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TENSOR PRODUCT COMPONENTS
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_04 = assemblerStruct.dymb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_05 = assemblerStruct.dymb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_06 = assemblerStruct.dymb1 .* assemblerStruct.dzmb2 .* weightMat;
    funcWeight_07 = assemblerStruct.dzmb1 .* assemblerStruct.mb2   .* weightMat;
    funcWeight_08 = assemblerStruct.dzmb1 .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_09 = assemblerStruct.dzmb1 .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    aux04 = funcToIntegrate_04  .* funcWeight_04;
    aux05 = funcToIntegrate_05  .* funcWeight_05;
    aux06 = funcToIntegrate_06  .* funcWeight_06;
    aux07 = funcToIntegrate_07  .* funcWeight_07;
    aux08 = funcToIntegrate_08  .* funcWeight_08;
    aux09 = funcToIntegrate_09  .* funcWeight_09;

    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    auxVec04 = sum(sum(aux04));
    auxVec05 = sum(sum(aux05));
    auxVec06 = sum(sum(aux06));
    auxVec07 = sum(sum(aux07));
    auxVec08 = sum(sum(aux08));
    auxVec09 = sum(sum(aux09));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec06 + auxVec07 + auxVec08 + auxVec09;
    r10 = auxVec02 + auxVec03;
    r01 = auxVec04 + auxVec05;
    r11 = auxVec01;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    auxx3(:) = r10(1,1,:);
    auxx4(:) = r11(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    r10 = auxx3;
    r11 = auxx4;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_10    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_11    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r10Local = r10((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r11Local = r11((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
                
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local);
        Local_10    = Local_10   + op_gradu_v(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r10Local);
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local);
        Local_11    = Local_11   + op_gradu_gradv(assemblerStruct.spaceFunc1{iel,2}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r11Local);

    end

    Bzy  = Local_11 + Local_10 + Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterPx3D'
            
function [Px] = assemblerIGAScatterPx3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiX_dx;
    funcToIntegrate_02 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiY_dx;
    funcToIntegrate_03 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiZ_dx;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    
    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec01;
    r01 = auxVec02 + auxVec03;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local)';

    end

    Px  = Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterPy3D'
            
function [Py] = assemblerIGAScatterPy3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiX_dy;
    funcToIntegrate_02 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiY_dy;
    funcToIntegrate_03 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiZ_dy;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    
    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec01;
    r01 = auxVec02 + auxVec03;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local)';

    end

    Py  = Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterPz3D'
            
function [Pz] = assemblerIGAScatterPz3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiX_dz;
    funcToIntegrate_02 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiY_dz;
    funcToIntegrate_03 = -1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.jacFunc.PsiZ_dz;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    funcWeight_02 = assemblerStruct.mb1   .* assemblerStruct.dymb2 .* weightMat;
    funcWeight_03 = assemblerStruct.mb1   .* assemblerStruct.dzmb2 .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    aux02 = funcToIntegrate_02  .* funcWeight_02;
    aux03 = funcToIntegrate_03  .* funcWeight_03;
    
    auxVec01 = sum(sum(aux01));
    auxVec02 = sum(sum(aux02));
    auxVec03 = sum(sum(aux03));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec01;
    r01 = auxVec02 + auxVec03;
    
    auxx1(:) = r00(1,1,:);
    auxx2(:) = r01(1,1,:);
    
    r00 = auxx1;
    r01 = auxx2;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    Local_01    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        r01Local = r01((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        Local_01    = Local_01   + op_u_gradv(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,2}, assemblerStruct.spaceFunc1{iel,3}, r01Local)';

    end

    Pz  = Local_01 + Local_00;
    
end

%% Method 'assemblerIGAScatterP3D'
            
function [P] = assemblerIGAScatterP3D(assemblerStruct)

    %% IMPORT CLASS
    
    import Core.AssemblerADRHandler
    import Core.BoundaryConditionHandler
    import Core.IntegrateHandler
    import Core.EvaluationHandler
    import Core.BasisHandler
    import Core.SolverHandler
    
    %% MODAL BASIS INTEGRATION
    %---------------------------------------------------------------------%
    % Computation of the auxiliary coefficients, presented in the original
    % work as 'r_{ik}^{st}'. Those coeffients simplify the computation of 
    % the parts to be assembled.
    %---------------------------------------------------------------------%
    
    weightMat = assemblerStruct.wgh2 * assemblerStruct.wgh2';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF COEFFICIENTS OF THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcToIntegrate_01 = 1 * assemblerStruct.jacFunc.evalDetJac .* assemblerStruct.param.delta;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTATION OF QUADRATURE WEIGHTS FOR THE MODAL EXPANSION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    funcWeight_01 = assemblerStruct.mb1   .* assemblerStruct.mb2   .* weightMat;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % NUMERICAL INTEGRATION %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    aux01 = funcToIntegrate_01  .* funcWeight_01;
    auxVec01 = sum(sum(aux01));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINITION OF THE MODAL COEFFICIENTS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r00 = auxVec01;
    auxx1(:) = r00(1,1,:);
    r00 = auxx1;
    
    %% ASSEMBLE OF STIFFNESS MATRIX AND RHS VECTOR
    
    numbKnots = assemblerStruct.msh1.nel_dir;
    numbHorNodes = length(r00)/numbKnots;
    
    Local_00    = spalloc (assemblerStruct.space1.ndof, assemblerStruct.space2.ndof, 3 * assemblerStruct.space2.ndof);
    
    for iel = 1:numbKnots
        
        r00Local = r00((iel - 1)*numbHorNodes + 1 : iel*numbHorNodes);
        Local_00    = Local_00   + op_u_v(assemblerStruct.spaceFunc1{iel,1}, assemblerStruct.spaceFunc2{iel,1}, assemblerStruct.spaceFunc1{iel,3}, r00Local)';
        
    end

    P = Local_00;
    
end