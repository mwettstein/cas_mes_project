%--------------------------------------------------------------------------
% __     _____    _____         _       
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


%% get Codebooks
%generate cell with names, abbreviations and placeholders for the actual
%codebook (Rows: 1-> codebook 2-> abbreviation 3-> Full name 
%Columns: person):
codebooks=cell(3,3);
codebooks{3,1}='Fabian Pfäffli';
codebooks{2,1}='fp';
codebooks{3,2}='Matthias Menzi';
codebooks{2,2}='mm';
codebooks{3,3}='Markus Wettstein';
codebooks{2,3}='mw';
%% LBG 
%parameters for LBG ( I have no idea what I'm doing)
k=12;
e = .000000001;
for p=1:3
    A=getMFCC([codebooks{2,p} '1'],15,'wav');
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
disp('codebooks generated')

%% kmeans
rng(1)
for p=1:3
    A=getMFCC([codebooks{2,p} '1'],15,'wav');
    %dirty removal of NaN column -> to be improved
    if sum(isnan(A(1,:)))>0
    A=A(:,1:length(A(1,:))-1);
    end
    X=A';
    %[idx,ctrs] = kmeans(X,14,'Replicates',15);
    opts = statset('Display','off');
    [idx,ctrs,sumd,D] = kmeans(X, 20, 'Distance', 'sqEuclidean', 'Replicates', 15, 'options', opts);
% figure(1);
% clf;
% color = hsv(12);                                % generate colormap for iterative coloring in for-loop
% hold all;
% 
%  for i=1:12  
% %     plot(X(idx==i,1),X(idx==i,2), '.', 'Color', color(i,:), 'MarkerSize',12);
% %set(gca,'Color',color(i,:))
%     plot3(X(idx==i,1),X(idx==i,2),X(idx==i,3),'.','MarkerFaceColor',color(i,:))
%  end
%  plot3(ctrs(:,1),ctrs(:,2),ctrs(:,3),'*','MarkerFaceColor','black','MarkerSize',8);

%plot(ctrs(:,1),ctrs(:,2),'kx','MarkerSize',12,'LineWidth',2);
% hold off;
% grid on;
    r=ctrs;
    codebooks{1,p}=r';
end
disp('codebooks generated')

%% Automated recognition using prerecorded samples
mfcc=getMFCC('mw1',15,'wav');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:3
    d=euDist(mfcc,codebooks{1,p});
    distance(p)=sum(min(d,[],2))/size(d,1);
end
[~,winner]=min(distance);
distance
disp(['nearest match: ' codebooks{3,winner}]);


%% Automated recognition microphone sample
mfcc=getMFCC(getMicSample,15,'vect');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:3
    d=euDist(mfcc,codebooks{1,p});
    distance(p)=sum(min(d,[],2))/size(d,1)
end
[~,winner]=min(distance);
disp(['nearest match: ' codebooks{3,winner}]);