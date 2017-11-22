function [x] = run_glm(fnY, fnX, fnP, Con, nPerm)

addpath('~/freesurfer/matlab')

[Y0, M, mr_parms, volsz] = load_mgh(fnY);
Y1 = squeeze(Y0(:,1,1,:)); 
size(Y1)

% Load design
X = importdata(fnX);
nR = size(X,1); nC = size(X,2);

% Parameter and residual variance estimate
invCovX = inv(X' * X);
B = inv(X' * X) * X' * Y1';
size(B);

E = Y1' - X * B;
Rvar = ones(1,nR) * times(E,E) / (nR - nC);
Rvar(Rvar==0) = inf;

% Contrast j
j=2; Con = zeros(1,nC); Con(1,j) = 1;
G = Con * B;
H1 = inv( Con * invCovX * Con');
H2 = G' * H1;
H3 = times(H2, G');
H4 = ones(1, size(H2,2)) * H3;
Fstat = rdivide(H4, size(Con,1) .* Rvar');
Pval = fcdf(Fstat(:,1), size(Con,1), nR - nC,'upper');
logP = -log10(Pval(:,1)); 
clust = zeros(size(logP,1),1,1);
clust(:,1,1) = logP(:,1);

save_mgh(clust, fnP, M, mr_parms);


x = 0;
return;