function [A,conf_true] = sbm_gen(N,q,cin,cout,seed)
% returns adjacency matrix and community membership vector generated by the
% stochastic block model with N nodes, q communities, intra-community
% average connectivity cin, extra-community average connectivity cout.
% seed initializes the random number generator.

rng(seed);
if(mod(N,q) ~= 0)
    fprintf('Using N = %d, which is a multiple of q\n',q*floor(N/q));
end
size = floor(N/q);
N = q*size;
conf_true = zeros(N,1);
for k = 1:q
    conf_true(1+(k-1)*size:(k)*size) = k;
end
A = sparse(N,N);
for i = 1:q
    current_block = sprand(size,size,cin/N);
    current_block = (current_block ~= 0);
    current_block = triu(current_block,1);
    current_block = current_block + current_block';
    % keyboard
    A(1+(i-1)*size:i*size,1+(i-1)*size:i*size) = current_block;
    for j = i+1:q
        current_block = sprand(size,size,cout/N);
        current_block = (current_block ~= 0);
        A(1+(i-1)*size:i*size,1+(j-1)*size:j*size) = current_block;
        A(1+(j-1)*size:j*size,1+(i-1)*size:i*size) = current_block';
    end
end
end