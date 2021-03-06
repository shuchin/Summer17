% Node Embedding via Word Embedding
% Main testing file
% Experimental results of Vec with and without NBRW
% Anu Gamage 7/12/2017

%clear;clc;close all 
reps = 1;           
%diary 'vec_results.txt' 
diary off  % change to 'on' if writing results to text file

tic

% Graph parameters
n = 500;
k = 2;
c = 1;
lambda = 0.99;

CCR = zeros(1,reps);                        
NMI = zeros(1,reps);
CCR_nbrw = zeros(1,reps);                        
NMI_nbrw = zeros(1,reps);

% Run node embedding
for i=1:reps
    [G, labels] = make_SBM(n,k,'const',c,lambda);
    [~, CCR(i), NMI(i)] = node_embed_cpu(G,labels,0);
    [~, CCR_nbrw(i), NMI_nbrw(i)] = node_embed_cpu(G,labels,1);
end

% Display and write results to file
fprintf('N : %i\n', n)
fprintf('k : %i\n', k)
fprintf('c : %i\n', c)
fprintf('lambda : %f\n', lambda)
fprintf('reps : %d\n\n', reps)
disp('Backtracking RW:')
% disp(CCR)
% disp(NMI)
fprintf('Avg CCR : %.3f%%\n', mean(CCR))
fprintf('Avg NMI : %.3f%%\n\n', mean(NMI))

disp('Non-backtracking RW:')
% disp(CCR_nbrw)
% disp(NMI_nbrw)
fprintf('Avg CCR : %.3f%%\n', mean(CCR_nbrw))
fprintf('Avg NMI : %.3f%%\n\n\n', mean(NMI_nbrw))
toc

diary off

% Plot results
%plot_metrics(CCR, CCR_nbrw, NMI, NMI_nbrw)
