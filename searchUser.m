function [username] = searchUser(speechSample, userStruct, distinction_limit, plotEnable)

global nrOfMfccCoeffs;
% distinction_limit = 1.5;
format compact;
format shortG;

cellContent = fieldnames(userStruct);
nrOfUsers = length(cellContent);

mfcc=getMFCC(speechSample,nrOfMfccCoeffs,'vect');
%dirty removal of NaN column -> to be improved
if sum(isnan(mfcc(1,:)))>0
    mfcc=mfcc(:,2:length(mfcc(1,:))-1);
end
for p=1:nrOfUsers
    d=euDist(mfcc,userStruct.(cellContent{p}).characteristics);
    distance(p)=10^(sum(min(d,[],2))/size(d,1))/1e5;
end
distance
distance_sort = sort(distance,'ascend');
if(((distance_sort(2)-distance_sort(1)) <= distinction_limit) || (sum(distance) <= 300) || (distance_sort(1) >= 100))
    username = 'error';
else
    [~,winner]=min(distance);
    username = userStruct.(cellContent{winner}).name;
    disp(['nearest match: ' userStruct.(cellContent{winner}).name]);
end

if(plotEnable == 1)
    [xlim, ylim] = size(mfcc);
    [xq,yq] = meshgrid(linspace(0, ylim, ylim*10), linspace(0, xlim, xlim*10));       % generate close-mesh meshgrid for interpolation
    result_ip = interp2(mfcc,xq,yq);              % interpolate data to close-mesh meshgrid
    subplot(3,2,6)
    mesh(result_ip.');
    view(33, 28);                                   % change POV to AZ 33 EL 28
    grid on;
    title('Mel Coefficients');
    axis tight;
end