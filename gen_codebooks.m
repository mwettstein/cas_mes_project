%--------------------------------------------------------------------------
function [codebook] = generateCodebook(userStruct, codebookMode, nrOfMfccCoeffs);
%pattern recognition using Vector quantization
%Each region is called a cluster and can be represented by its center
%set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')called a codeword.
%Thecollection of all codewords is called a codebook
%vdqtool

clear all;
close all; clc;
addpath('rsc', 'utilities', 'GUI'); superpack;
format compact;
load('users.mat');
userStruct = users;

nrOfMfccCoeffs = 96;                    % number of MFCC filter coefficients. Use ~(Fs/16e3)*16
nrOfKmeansClusters = 24;                % number of Clusters for K-Means algorithm
% distinction_limit = 1.5;                % minimum distance for clear distinction of speakers
codebookMode = 'kmeans';                % choose codebook generation mode!
% codebookMode = 'lbg';                 % K-Means works much better!

cellContent = fieldnames(userStruct);
nrOfUsers = length(cellContent);

if (strcmp(codebookMode,'lbg'))
    disp('Using LBG to generate Codebook...');
    % LBG
    %parameters for LBG ( I have no idea what I'm doing)
    k=12;
    e = .000000001;
    for p=1:nrOfUsers
        A=getMFCC(userStruct.(cellContent{p}).sample,nrOfMfccCoeffs,'wav');
        %dirty removal of NaN column -> to be improved
        if sum(isnan(A(1,:)))>0
            A=A(:,1:length(A(1,:))-1);
        end
        d=A;
        %VQ - Vector quantization using LBG Algorithm
        r= mean(d, 2); % column vector containing the mean value of each row
        tic
        dpr = 1e8;
        for i = 1:log2(k)
            r = [r*(1+e), r*(1-e)]; % double the size of the current codebook by splitting each current codebook accordingly
            while (true) % do while-loop
                z = euDist(d, r);
                [m,ind] = min(z, [], 2);
                t = 0;
                for j = 1:2^i
                    r(:, j) = mean(d(:, find(ind == j)), 2);
                    x = euDist(d(:, find(ind == j)), r(:, j));
                    for q = 1:length(x)
                        t = t + x(q);
                    end
                end
                if (((dpr - t)/t) < e)
                    userStruct.(cellContent{p}).characteristics=r;
                    break; % while part of the do-while loop
                else
                    dpr = t;
                end
            end
        end
    end
    
elseif(strcmp(codebookMode,'kmeans'))
    % kmeans
    disp('Using K-Means to generate Codebook...');
    rng(1)
    for p=1:nrOfUsers
        A=getMFCC(userStruct.(cellContent{p}).sample,nrOfMfccCoeffs,'vect');
        %dirty removal of NaN column -> to be improved
        if sum(isnan(A(1,:)))>0
            A=A(:,1:length(A(1,:))-1);
        end
        
        X=A';
        opts = statset('Display','off');
        warning('off','all');
        [idx,ctrs,sumd,D] = kmeans(X, nrOfKmeansClusters, 'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts);
        %         [idx,ctrs,sumd] = kmedoids(X, nrOfKmeansClusters, 25);
        r=ctrs;
        userStruct.(cellContent{p}).characteristics=r';
    end
    
else
    error('no valid codebook generation mode chosen');
    return;
end

disp('Codebooks generated')