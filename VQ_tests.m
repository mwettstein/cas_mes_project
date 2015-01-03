%--------------------------------------------------------------------------
%  __     _____    _____         _       
%  \ \   / / _ \  |_   _|__  ___| |_ ___ 
%   \ \ / / | | |   | |/ _ \/ __| __/ __|
%    \ V /| |_| |   | |  __/\__ \ |_\__ \
%     \_/  \__\_\   |_|\___||___/\__|___/
%                                      
%--------------------------------------------------------------------------
%pattern recognition using Vector quantization
%Each region is called a cluster and can be represented by its center 
%set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')called a codeword. 
%Thecollection of all codewords is called a codebook
%vdqtool
clear all; 
close all; clc; addpath('rsc', 'utilities'); superpack;
format compact;

nrOfMfccCoeffs = 100;                    % number of MFCC filter coefficients. Use ~(Fs/16e3)*16
nrOfKmeansClusters = 59;                % number of Clusters for K-Means algorithm
distinction_limit = 1.5;                % minimum distance for clear distinction of speakers
codebookMode = 'kmeans';                % choose codebook generation mode!
%codebookMode = 'lbg';                 % K-Means works much better!

disp('   Welcome to VoiceActivatedDoor!');
disp('------------------------------------');

% get Codebooks
%generate cell with names, abbreviations and placeholders for the actual
%codebook (Rows: 1-> codebook 2-> abbreviation 3-> Full name 
%Columns: person):
codebooks=cell(3,5);
codebooks{3,1}='Fabian Pfäffli';
codebooks{2,1}='fpta';
codebooks{3,2}='Matthias Menzi';
codebooks{2,2}='mmta';
codebooks{3,3}='Markus Wettstein';
codebooks{2,3}='mwta';
codebooks{3,4}='TP';
codebooks{2,4}='tpta';
codebooks{3,5}='LV';
codebooks{2,5}='lvta';
if (strcmp(codebookMode,'lbg'))
    disp('Using LBG to generate Codebook...');
    % LBG
    %parameters for LBG ( I have no idea what I'm doing)
    k=12;
    e = .000000001;
    for p=1:length(codebooks)
        A=getMFCC([codebooks{2,p} '1'],nrOfMfccCoeffs,'wav');
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
                 codebooks{1,p}=r;
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
    for p=1:length(codebooks)
        A=getMFCC([codebooks{2,p} '1'],nrOfMfccCoeffs,'wav');
        
        %dirty removal of NaN column -> to be improved
        if sum(isnan(A(1,:)))>0
            A=A(:,1:length(A(1,:))-1);
        end
        k=nrOfKmeansClusters;
        X=A';
        nc=size(X,2);
        [x,esq,j]=kmeans(X,1);
        m=k;    
%         while m<k
%             n=min(m,k-m);
%             m=m+n;
%        %     e=1e-4*sqrt(esq)*rand(nc,1);
%             opts = statset('Display','off');
%             [x,esq,j]=kmeans(X,m,'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts); 
%             %x(n+1:m-n,:)]);
%         end
        
         opts = statset('Display','off');
        [x,esq,j]=kmeans(X,m,'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts); 
%         X=A';
%         opts = statset('Display','off');
%         warning('off','all');
%         [idx,ctrs,sumd,D] = kmeans(X, nrOfKmeansClusters, 'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts);
         r=esq;
        codebooks{1,p}=r';
    end
end
disp('Codebooks generated')

%% Automated recognition using prerecorded samples
mfcc=getMFCC('fpta3',nrOfMfccCoeffs,'wav');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:length(codebooks)
    d=euDist(mfcc,codebooks{1,p});
    distance(p)=sum(min(d,[],2))/size(d,1);
end
distance
distance_sort = sort(distance,'ascend');
if((distance_sort(2)-distance_sort(1)) <= distinction_limit)
    error('No clear distinction possible');
else
    [~,winner]=min(distance);
    disp(['nearest match: ' codebooks{3,winner}]);
end

%% Overall performance checker for parameter adjusting
wavnames=['fpta1'; 'fpta2'; 'fpta3'; 'mmta1'; 'mmta2'; 'mmta3'; 'mwta1'; 'tpta1'; 'tpta2'; 'tpta3';'lvta1';'lvta2';'lvta3';];
dist_acc=0;
for i=1:length(wavnames)
    mfcc=getMFCC(wavnames(i,:),nrOfMfccCoeffs,'wav');
    if sum(isnan(mfcc(1,:)))>0
        mfcc=mfcc(:,1:length(mfcc(1,:))-1);
    end
    for p=1:length(codebooks)
        d=euDist(mfcc,codebooks{1,p});
        distance(p)=sum(min(d,[],2))/size(d,1);
    end
    distance_sort = sort(distance,'ascend');
    if((distance_sort(2)-distance_sort(1)) <= distinction_limit)
         dist_acc=dist_acc-1.5*length(wavnames); % penalty
         disp(['no valid distinction: ' wavnames(i,:)])
    end
    dist_acc=dist_acc+(distance_sort(2)-distance_sort(1))/distance_sort(1);
end;
dist_acc=dist_acc/length(wavnames);
disp(['overall distance: ' num2str(dist_acc)]);
%% Automated recognition microphone sample
mfcc=getMFCC(getMicSample,nrOfMfccCoeffs,'vect');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:length(codebooks)
    d=euDist(mfcc,codebooks{1,p});
    distance(p)=sum(min(d,[],2))/size(d,1);
end
distance
distance_sort = sort(distance,'ascend');
if((distance_sort(2)-distance_sort(1)) <= distinction_limit)
    error('No clear distinction possible');
else
    [~,winner]=min(distance);
    disp(['nearest match: ' codebooks{3,winner}]);
end
%% Parameter optimization using fminsearch
[x, fval]= fminsearch(@(x) param_eval(x),[100 59],optimset('TolX',0.5,'maxIter',1e6));
%[x, fval]= fminsearch(@(x) param_eval(x),[61 53]);
