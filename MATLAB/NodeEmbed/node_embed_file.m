function [Em_true,ccr,nmi] = node_embed_file(G,L,doNBT)
% Implements the node embeddings 'vec' algorithm of Ding et al. including a
% non-backtracking random walks option. This version works with file I/O
% and the use of the compiled "word2vec" code of Mikolov et al. 
% Inputs:
% G: graph in adjacency matrix form. Directed graphs should work; weighted
%    graphs should be tested but might work (TODO).
% L: ground truth of the embedding.
% doNBT: whether or not to do non-backtracking random walks on the graph.
% other parameters can be set manually for now; it's more annoying than
% helpful to have 10 different arguments to the program.
% Outputs:
% Em_true: the embedding produced by the algorithm.
% ccr: the correct classification rate.
% nmi: the normalized mutual information of the output.
% 
% Brian Rappaport, 7/24/17

% set vars
if size(L,2) ~= 1, L = L'; end % ensure L is a column vector
k = max(L); % number of communities
len = 5; % length of random walk
rw_reps = 15; % number of random walks per data point
dim = 50; % embedded dimension
winsize = 4; % window size
read_fp = 'sentences.txt';
write_fp = 'embeddings.txt';
numWorkers = 4;

% write random walks to file
disp 'beginning random walks...'
nodes2file(G,read_fp,rw_reps,len,doNBT);
% run word2vec with external C code
command = ['./word2vec -train ' read_fp ' -output ' write_fp ...
          ' -size ' int2str(dim) ' -window ' int2str(winsize) ...
          ' -negative 5 -cbow 0 -sample 1e-4 -debug 2 -workers ' ...
          int2str(numWorkers)];
system(command);
% get embeddings from word2vec
[U,labels] = file2embs(write_fp);
L = L(labels);
% run kmeans
Em = kmeans(U,k);
Em_true = get_true_emb(Em,L);
ccr = sum(Em_true == L)*100/numel(L);
nmi = get_nmi(Em_true, L);
end

function [U,labels] = file2embs(filename)
% Reads a file from word2vec and returns it as an array in memory.
U = dlmread(filename,' ',2,0);
labels = U(:,1);
U = U(:,2:end-1);
end

function nodes2file(G,filename,rw_reps,len,doNBT)
% Runs random walks on G and writes to a file. Note that all walks must be
% exactly len nodes long or this will have fairly catastrophic off-by-one
% errors.
n = size(G,1);
rw = zeros(len,rw_reps,n);
parfor i = 1:n
    if isempty(find(G(i,:),1))
        continue
    end
    for j = 1:rw_reps
        rw(:,j,i) = random_walk(i,len,G,doNBT);
    end
end
rw(rw==0) = [];
fmtstr = repmat('%d ',1,len);
fmtstr = [fmtstr(1:end-1) '\n'];
fp = fopen(filename,'wb');
fprintf(fp,fmtstr,rw);
fclose(fp);
end
