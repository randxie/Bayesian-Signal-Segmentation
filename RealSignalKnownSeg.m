%% Real Signal case 1: level signal + random walk (known segment)
% support define number of segments
clc;
clear;

load('TMJ_EMG_500Hz.mat');
data = dataOut;
data = data/max(abs(data));
% use Rhat to determine whether it is enough

% estimate segment 
numSegment = 8;
arOrder = 8;
para.ARcoeff = zeros(numSegment, arOrder);

%% doing mcmc
saveFile = 'RealSignalKnownSeg.mat';
saveFig = 'RealSignalKnownSeg.fig';
isTest = 0;
mcmc_para.nchains = 16;
mcmc_para.nburnin = 20000; 
mcmc_para.nsamples = 40000;  
[samples, stats, structArray] = McmcKnownSeg(data,para,mcmc_para,saveFile,saveFig,isTest);

%% making prediction
load(saveFile);

%%
transition_time = stats.mean.cp+2;
sigma = sqrt(1/stats.mean.tau);
transition_time = transition_time([1,2,5,6,8]);
h(1) = figure;
plot(data)
for i = 1:length(transition_time)
    hold on;
    plot([transition_time(i),transition_time(i)],[min(data),max(data)],'r--');
end

xlabel('Time(s)');
ylabel('Normalized Magnitude');
title('sEMG signal from Temporalis Muscle');

%%
para.noise_level = 0; %sqrt(1/stats.mean.tau);
para.ARcoeff = stats.mean.b;
para.MeanLevel = stats.mean.MeanLevel;

% para.sim_len = length(data);
para.change_point = floor(stats.mean.cp+2); 
para.change_point = para.change_point(1:end-1);

para.change_point = para.change_point([1,2,5,6]);

para.ARorder = ARorder;
% para.y0 = data(1:ARorder);
ypred = predict_ts(data, para);

figure;
plot(data)
hold on
plot(ypred,'r')
