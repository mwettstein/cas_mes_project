function [username] = searchUser(speechSample, userStruct, distinction_limit)

global nrOfMfccCoeffs;
% distinction_limit = 1.5;
format compact;
format shortG;

cellContent = fieldnames(userStruct);
nrOfUsers = length(cellContent);

mfcc=getMFCC(speechSample,nrOfMfccCoeffs,'vect');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
    mfcc=mfcc(:,1:length(mfcc(1,:))-1);
end
for p=1:nrOfUsers
    d=euDist(mfcc,userStruct.(cellContent{p}).characteristics);
    distance(p)=10^(sum(min(d,[],2))/size(d,1))/1e5;
end
distance
distance_sort = sort(distance,'ascend');
if(((distance_sort(2)-distance_sort(1)) <= distinction_limit) || (distance_sort(1) >= 12))
    username = 'error';
else
    [~,winner]=min(distance);
    username = userStruct.(cellContent{winner}).name;
    disp(['nearest match: ' userStruct.(cellContent{winner}).name]);
end