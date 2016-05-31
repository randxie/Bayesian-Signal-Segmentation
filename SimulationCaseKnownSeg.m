%% Simulation case 1: level signal + random walk (known segment)
% support define number of segments
clc;
clear;

% use Rhat to determine whether it is enough

%% generate simulation data
% assume third order system
para.noise_level = 0.05;
para.ARcoeff = [1 0; 0.2 0; 1 0; 0.2 0];
para.sim_len = 1000;
para.change_point = [250;520;780]; 
para.y0 = [0;0];
data = simulation(para);
data = data/max(abs(data));
ARorder = size(para.ARcoeff,2);

%% doing mcmc
saveFile = 'SimulationCaseKnownSeg.mat';
saveFig = 'SimulationCaseKnownSeg.fig';
isTest = 0;
mcmc_para.nchains = 8;
mcmc_para.nburnin = 20000; 
mcmc_para.nsamples = 40000;  
[samples, stats, structArray] = McmcKnownSeg(data,para,mcmc_para,saveFile,saveFig,isTest);

%% making prediction
load(saveFile);
para.noise_level = 0; %sqrt(1/stats.mean.tau);
para.ARcoeff = stats.mean.b;
para.MeanLevel = stats.mean.MeanLevel;

% para.sim_len = length(data);
para.change_point = floor(stats.mean.cp+2); 
para.change_point = para.change_point(1:end-1);

para.ARorder = ARorder;
% para.y0 = data(1:ARorder);
ypred = predict_ts(data, para);

figure;
plot(data)
hold on
plot(ypred,'r')
