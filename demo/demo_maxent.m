%% Demo Script to illustrate the "FitMaxEnt" Code Package
% code fits maximum entropy models to multivariate binary data, using
% user-specified feature functions and means. Current implementation only works for data
% for which the sample space can be summed over exactly, and the
% implementation is NOT optimized for memory efficiency, and has only been
% used for N<=15 so far.
%
% This code needs the code-package 'minFunc' to be available in the
% matlab-path. 
%
%


%% Run the code in which we need to construct the features by hand:
clear all
dim_x=10; %simulate 10 dimensional problem
Ns= 5000; %generate 1000 data-points;

h=randn(dim_x,1); %generate random bias terms;
J=randn(dim_x); J=triu(J,1)/sqrt(10); %generate random coupling terms:
%convert h and J to parameter lambda-- use convention that first n entries
%of lambda is a copy of h, and lower-triangular entries in J are ignored,
%and upper-triangular entries are first taken along the first row, then
%second row, etc:
lambda=hJ2lambda(h,J);

        


%now, set up parameters of code: For the moment, are extremely conservative
%on convergence criteria:
%options for parameter learning: see minFunc for their meaning
fitoptions.optTol=1e-50; 
fitoptions.progTol=1e-50; 
fitoptions.display='off';
fitoptions.MaxIter=3000;
        
                
%set up second-order feature space for binary model:
[features,description,x]=SetupFeaturesMaxEnt(dim_x,2);
            
%calculate corresponding probabilities from ground-truth maximum entropy
%model:
[logPtrue,logZtrue,Ptrue, means_true]=PMaxEnt(features,lambda);

%now, generate synthetic data from this distribution:
features_sampled=SampleDiscrete(features,Ptrue,max(Ns));

%calculate their means as we will need this as intput for the fitting
%procedure:
means_sampled=mean(features_sampled,1); clear featuressampled
                    
 
 
 [lambda_learned,logZlearned, Plearned, means_learned,output]=FitMaxEntLinear(features,means_sampled, fitoptions);
 Plearned=exp(Plearned);
 EntropyLogE=ent((Plearned));
 [h_learned,J_learned]=hJ2lambda(lambda_learned);
Plearned_hJ_check=qIsing(x,h_learned,J_learned,exp(logZlearned));
 
 
 close all
 subplot(2,2,1)
 loglog(Plearned,Ptrue,'.')
 xlabel('Learned P')
 ylabel('True P')
 eqline
 
 subplot(2,2,2)
 plot(means_learned,means_sampled,'.')
 xlabel('learned means');
 ylabel('sampled means');
 eqline
 
  subplot(2,2,3)
 plot(h_learned,h,'bx')
 hold on
 plot(J_learned,J,'.g')
 hold on
 plot(lambda_learned,lambda,'.r')
 
 xlabel('Learned h J lambda')
 ylabel('True h J lambda')
 eqline
 
 subplot(2,2,4)
 loglog(means_learned,means_sampled,'.')
 xlabel('learned P from lambda');
 ylabel('learned P from h J');
 eqline
 
 
 %% We also have a function which does the bookkeeping internally, i.e. for whcih we never get to see the features: 
 
 
 
 
 
 
 