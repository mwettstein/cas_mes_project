function [ dist_acc ] = param_eval(x)
% parameters:
% x(1): nrOfMelCoeffs
% x(2): nrOfKmeansClusters
% x(3): 
if ((floor(x(2))>floor(x(1))) || x(1)<14 || x(2)<14)
    dist_acc = 10; 
    disp('false input parameters, exiting...')
    return
end
disp('-----------------------------')
disp(['Parameters: ' num2str(x(1)) '(' num2str(floor(x(1))) ') and ' num2str(x(2)) '(' num2str(floor(x(2))) ')'])
disp('-----------------------------')
nrOfMfccCoeffs = floor(x(1));
nrOfKmeansClusters = floor(x(2));

distinction_limit = 1.5;
clear codebooks;
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
         m=1;    
%         while m<(k-1)
%             n=min(m,k-m);
%             m=m+n;
%             e=1e-4*sqrt(esq)*rand(nc,1);
%             opts = statset('Display','off');
%             [x,esq,j]=kmeans(X,m,'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts); 
%         end
        m=k;
        if m>length(X(:,1))
             dist_acc = 10; 
            disp('false input parameters, exiting...')
            return
        end
        opts = statset('Display','off');
        [x,esq,j]=kmeans(X,m,'Distance', 'sqEuclidean', 'Replicates', 25, 'options', opts); 
         r=esq;
        codebooks{1,p}=r';
    end

disp('Codebooks generated')       
%Overall performance checker for parameter adjusting
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
             dist_acc = 10;
    return
    end
    dist_acc=dist_acc+(distance_sort(2)-distance_sort(1))/((distance_sort(1)+distance_sort(2))/2);
end;
dist_acc=length(wavnames)/dist_acc;
disp(['overall distance: ' num2str(dist_acc)]);

end

