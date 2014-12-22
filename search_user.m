function [username] = searchUser(speechSample, userStruct, nrOfMfccCoeffs, distinction_limit)

% nrOfMfccCoeffs = 96;
distinction_limit = 1.5;

cellContent = fieldnames(userStruct);
nrOfUsers = length(cellContent);

mfcc=getMFCC(speechSample,nrOfMfccCoeffs,'vect');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
    mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:nrOfUsers
    d=euDist(mfcc,userStruct.(cellContent{p}).characteristics);
    %     d = pdist2(mfcc(2:nrOfKmeansClusters+1),codebooks{1,p},'euclidean');
    distance(p)=sum(min(d,[],2))/size(d,1);
end
distance
distance_sort = sort(distance,'ascend');
if((distance_sort(2)-distance_sort(1)) <= distinction_limit)
    error('No clear distinction possible');
else
    [~,winner]=min(distance);
    disp(['nearest match: ' userStruct.(cellContent{winner}).name);
end