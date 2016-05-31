%% Simulation case 2: changing mean level
% support define number of segments
clc;
clear;

% use Rhat to determine whether it is enough

%% generate simulation data
% assume third order system
para.noise_level = 0.05;
para.ARcoeff = [0.2 0; 0.2 0; 0.2 0; 0.2 0];
para.sim_len = 1000;
para.change_point = [250;520;780]; 

para.y0 = [0;0];
data = simulation(para);

AddMeanLevel = [0; 1; 0; -1];
data(1:para.change_point(1)) = data(1:para.change_point(1)) + AddMeanLevel(1);
for i = 1:(length(para.change_point)-1)
   tmp = data(para.change_point(i):para.change_point(i+1));
   data(para.change_point(i):para.change_point(i+1)) = tmp + AddMeanLevel(i+1);
end
data(para.change_point(end):end) = data(para.change_point(end):end) + AddMeanLevel(end);

data = data/max(abs(data));
ARorder = size(para.ARcoeff,2);

%% doing mcmc
saveFile = 'SimulationDiffMeanLevel.mat';
saveFig = 'SimulationDiffMeanLevel.fig';
isTest = 0;
mcmc_para.nchains = 4;
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
