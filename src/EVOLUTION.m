function u = EVOLUTION(u0, g, lambda, mu, alf, epsilon, delt, numIter)
    u=u0;
    [vx,vy]=gradient(g);
    for k=1:numIter
        u=NeumannBoundCond(u);
        [ux,uy]=gradient(u); 
        normDu=sqrt(ux.^2 + uy.^2 + 1e-10);
        Nx=ux./normDu;
        Ny=uy./normDu;
        diracU=Dirac(u,epsilon);
        K=curvature_central(Nx,Ny);
        weightedLengthTerm=lambda*diracU.*(vx.*Nx + vy.*Ny + g.*K);
        penalizingTerm=mu*(4*del2(u)-K);
        weightedAreaTerm=alf.*diracU.*g;
        u=u+delt*(weightedLengthTerm + weightedAreaTerm + penalizingTerm);  % update the level set function
    end

function f = Dirac(x, sigma)
    f=(1/2/sigma)*(1+cos(pi*x/sigma));
    b = (x<=sigma) & (x>=-sigma);
    f = f.*b;

function K = curvature_central(nx,ny)
    [nxx,junk]=gradient(nx);  
    [junk,nyy]=gradient(ny);
    K=nxx+nyy;

function g = NeumannBoundCond(f)
    % Make a function satisfy Neumann boundary condition
    [nrow,ncol] = size(f);
    g = f;
    g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
    g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
    g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);