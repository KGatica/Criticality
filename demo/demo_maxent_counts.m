%fit maxent model with additional constraints on spike-count distribution

%% First generate some samples from an Ising model-- in this case
%the parameters for the PKs should be close to 0.
clear all
close all

dim_x=10; %simulate 10 dimensional problem
Ns= 100000; %generate 1000 data-points;

h=randn(dim_x,1)-1; %generate random bias terms;
J=randn(dim_x); J=triu(J,1)/sqrt(dim_x); 
lambda=hJ2lambda(h,J);

        
%set up second-order feature space for binary model:
[features,description,x]=setup_features_maxent(dim_x,2);
            
%calculate corresponding probabilities from ground-truth maximum entropy
%model:
[logPtrue,logZtrue,Ptrue, means_true]=logPMaxEnt(features,lambda);
%to check, also 
logPtrueCheck=qIsing(x,h,J,exp(logZtrue),1);

[cov_true,mean_true]=wcov(x,Ptrue);
 
%now, generate synthetic data from this distribution:
x_sampled=sample_discrete(x,Ptrue,max(Ns));
%calculate  feature-means for ising_count model (note that this is a
%horribly memory-inefficient way of doing it, but I dont care at the moment)
[cov_sampled,mean_sampled]=wcov(x_sampled);

[features_sampled] = setup_features_maxent(x_sampled,'ising_count');
[features_count]   = setup_features_maxent(x,        'ising_count');
means_sampled      = mean(features_sampled,1); clear features_sampled
 
count_histogram_true=ps_2_count_distrib(x,Ptrue);                          % changed order of arguments
count_histogram_sampled=ps_2_count_distrib(x_sampled, ones(Ns,1)/Ns);      % relative to Jakob's version!

fitoptions.optTol=1e-100; 
fitoptions.progTol=1e-100; 
fitoptions.display='off';
fitoptions.MaxIter=3000;

%penalites pK parameters:
penalties=zeros(size(means_sampled'));
%penalties(end-dim_x+1:end)=10*ones(1,dim_x)/Ns;

% fit model with activity counts:
[lambda_learned,logZlearned, logPlearned, means_learned,output]=fit_maxent_linear(features_count,means_sampled,fitoptions,0,penalties);
   %should be identical to:
[h_learned_hJ,J_learned_hJ,logZ_learned_hJ,logP_learned_hJ, patterns,l_hJ]=fit_ising_model(mean_sampled,cov_sampled,count_histogram_sampled(2:end), fitoptions);
% fit model without activity counts:   
[lambda_learned_ising,logZlearned_ising, logPlearned_ising, means_learned_ising,output_ising]=fit_maxent_linear(features_count(:,1:end-dim_x),means_sampled(1:end-dim_x),fitoptions);
 
[logPlearned]=logPMaxEnt(features_count,lambda_learned);
[logPlearned_ising]=logPMaxEnt(features,lambda_learned_ising);

count_histogram_learned=ps_2_count_distrib(x, exp(logPlearned));           % changed order of arguments
count_histogram_learned_hJ=ps_2_count_distrib(x, exp(logP_learned_hJ));    % relative to Jakob's version!
count_histogram_ising=ps_2_count_distrib(x, exp(logPlearned_ising));       %



%%
figure
subplot(2,3,1)
plot(0:dim_x,count_histogram_true,'-')
hold on
plot(0:dim_x,count_histogram_sampled,'r-')
plot(1:dim_x,means_sampled(end-dim_x+1:end),'o')
title('Activity count histograms')
legend('true', 'sampled (from x)', 'sampled(from f(x))') 

xlabel('Counts')
ylabel('Frequency')

subplot(2,3,2)
plot(logPtrue,logPlearned,'b.')
hold on
plot(logPtrue,logPlearned_ising,'r.')
plot(logPtrue,logP_learned_hJ,'gx')
xlabel('true log(P(x))'), ylabel('learned log(P(x))')
legend('(h,J,V(K))', '(h,J)', '(h,J)', 'Location', 'Southeast')
title('Learned P(x) and ground truth')
eqline


subplot(2,3,3)
plot(lambda,'.')
hold on
plot(lambda_learned,'gx')
plot(lambda_learned_ising,'k.')
xlabel(['feature dimension i = 1,...,', num2str(length(lambda_learned))])
ylabel('\lambda_i')
title('Learned parameters \lambda and ground trugh')
legend('true', '(j,J,V(K))', '(h,J)', 'Location', 'Southeast')

subplot(2,3,4)
semilogy(0:dim_x,count_histogram_true,'-')
hold on
semilogy(0:dim_x,count_histogram_learned,'r-')
semilogy(0:dim_x,count_histogram_ising,'o')
semilogy(0:dim_x,count_histogram_learned_hJ,'g-')
legend('true', '(j,J,V(K))', '(h,J)', '(h,J)', 'Location', 'South')
title('Activity count probabilities, semilog')
xlabel('K')
ylabel('log(P(K))')

%%

%% Now, generate from a flat DG model

dim_x=10; %simulate 10 dimensional problem
Ns= 100000; %generate 1000 data-points;

count_histogram_true=flat_dg_count_distrib(-1,.8,[0:dim_x],dim_x);
[P_true]=count_distrib_2_ps(count_histogram_true,x);
 
[x_sampled]=sample_flat_model(count_histogram_true,Ns)';
count_histogram_sampled=ps_2_count_distrib(x_sampled, ones(Ns,1)/Ns);

[cov_sampled,mean_sampled]=wcov(x_sampled);

fitoptions.optTol=1e-100; 
fitoptions.progTol=1e-100; 
fitoptions.display='off';
fitoptions.MaxIter=3000;

%penalites pK parameters:
penalties=zeros(size(means_sampled'));
penalties(end-dim_x+1:end)=10*ones(1,dim_x)/Ns;

[h_learned_ising,J_learned_ising,logZ_learned_ising,logP_learned_ising, patterns]=fit_ising_model(mean_sampled,cov_sampled,          [],                    fitoptions);
[h_learned_PK,J_learned_PK,logZ_learned_PK,logP_learned_PK, patterns,l_PK]       =fit_ising_model(mean_sampled,cov_sampled, count_histogram_sampled(2:end), fitoptions);

count_histogram_learned_ising=ps_2_count_distrib(x, exp(logP_learned_ising));
count_histogram_learned_PK=ps_2_count_distrib(x, exp(logP_learned_PK));



%%
figure
subplot(2,2,1)
plot(0:dim_x,count_histogram_true,'-')
hold on
plot(0:dim_x,count_histogram_sampled,'r.')


xlabel('Counts')
ylabel('Frequency')

subplot(2,2,2)
plot(log(P_true),logP_learned_ising,'g.')
hold on
plot(log(P_true),logP_learned_PK,'r.')


eqline




subplot(2,2,3)
semilogy(0:dim_x,count_histogram_sampled,'r.-')
hold on
plot(0:dim_x,count_histogram_learned_ising,'g')
plot(0:dim_x,count_histogram_learned_PK,'b-')

