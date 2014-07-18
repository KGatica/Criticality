%% 0) introduction
% This scripts describes how to use the code to fit a bivariate
% dichotomized Gaussian process to a bivariate Bernoulli process using
% bayesian inference. The present version is stable, but may change in the
% future.

%% 1) initialize the prior distributions for the parameters

N = 101;    % number of samples for each parameter
% CREATION OF THE SUPPORTS FOR THE PARAMETERS' PDFs
% all of them must be column vectors
pfire = linspace(0.9999, 0.0001, N)';   % firing probability axis
theta = norminv(1 - pfire);             % parameter actually used by the model
lambda = linspace(-1, 1, N)';           % covariance of the latent gaussian process

% CREATION OF THE PRIORS

% Here we assume that the firing probability of a neuron is distributed
% according to a Beta distribution with parameters alpha = 2 and beta = 3;
% attention must be paid to find the right expression for the prior for
% theta, due to the non-linear relation between theta and pfire.
a1 = 2; b1 = 3;
pdfTheta = normpdf(theta) .* (pfire.^(a1 - 1)) .* ((1 - pfire).^(b1 - 2));
% this operation creates an object with normalized probability distribution
priTheta = ProbDist(theta, pdfTheta);

%  For the prior on lambda, we assume that 0.5*(lambda + 1) is Beta
%  distributed with parameters a2 and b2.
a2 = 2; b2 = 2;
pdfLambda = ((0.5 * (1 + lambda)).^(b2 - 1))...
    .* ((0.5 * (1 - lambda)).^(b2 - 1));
priLambda = ProbDist(lambda, pdfLambda);

%% 1.2) create a lookup table of the probability of observing 2 events
% this may take some time
tic
LUTp11 = bivbern_lut(theta, lambda);
toc

%% 2) generate a spike train with the desired properties

numBins = 200;  % number of time bins
% Desired firing properties for the dichotomize Gaussian model
prob_lat = [0.4, 0.5];
corr_lat = 0.3;
% Find the parameters for the DichGauss code
mu = norminv(prob_lat);
Lambda = [[1, corr_lat]; [corr_lat, 1]];
% Generate the spike train.
bins = sampleDichGauss01(mu, Lambda, numBins, 1);

%% 3) fit the model to the simulated data
% find the total number of events for each case (00, 10, 01, 11)
m = count_events(bins);
[marginals, joints] = bivbern_fit(m, priTheta, priLambda, LUTp11);

%% 4) plot the results

colour = 'bgr'; 
figure('Position', [0 0 800 600]);
for i = 1:3
    subplot(3,1,i); 
    hold on
    m = marginals{i}.expectation;
    plot(marginals{i}.sup_x, marginals{i}.pdf_x, colour(i), 'LineWidth', 2);
    stem(m, marginals{i}.eval_pdf(m), colour(i));
    switch i
        case 1
            title('Firing probability cell #1 PDF');
            xlabel('Firing probability');
        case 2
            title('Firing probability cell #2  PDF');
            xlabel('Firing probability');
        case 3
            title('Latent correlation dich. Gaussian model PDF');
            xlabel('Latent correlation');
    end
    
    % improve a bit the look of the plot
    % first set the default appearance for the axes object
    set(gca, 'FontName', 'Arial', 'FontSize', 10);
    % set legend
    set(legend(gca),'FontSize', 8,'box','off');
    % set axes labels and title
    set(get(gca,'Xlabel'),'FontSize', 12);
    set(get(gca,'Xlabel'),'FontSize', 12);
    set(get(gca,'Title') ,'FontSize', 14,'FontWeight','bold');
    % set everithing else
    set(gca,...
        'Box'           , 'off'     ,...
        'TickDir'       , 'out'     ,...
        'TickLength'    , [.02 .02] ,...
        'XColor'        , [.1 .1 .1],...
        'YColor'        , [.1 .1 .1]);
end


