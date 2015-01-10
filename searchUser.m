function [username, auth] = searchUser(speechSample, userStruct, distinction_limit, plotEnable)

global nrOfMfccCoeffs;
% distinction_limit = 1.5;
format compact;
format shortG;
auth = 0;

cellContent = fieldnames(userStruct);
nrOfUsers = length(cellContent);

mfcc=getMFCC(speechSample,nrOfMfccCoeffs,'vect');
% %dirty removal of NaN column -> to be improved
% if sum(isnan(mfcc(1,:)))>0
%     mfcc=mfcc(:,1:length(mfcc(1,:))-1);
% end
mfcc = mfcc(:,isfinite(mfcc(1,:))); %Renoves every column that contains a NaN et the first row

for p=1:nrOfUsers
    d=euDist(mfcc,userStruct.(cellContent{p}).characteristics);
    distance(p)=10^(sum(min(d,[],2))/size(d,1))/1e15;
%     distance(p)=(sum(min(d,[],2))/size(d,1));
end
distance
distance_sort = sort(distance,'ascend');
if(((distance_sort(2)-distance_sort(1)) <= distinction_limit) || (sum(distance) <= 300) || (distance_sort(1) >= 100))
% if((distance_sort(2)-distance_sort(1)) <= distinction_limit)
    username = 'error';
else
    [~,winner]=min(distance);
    username = userStruct.(cellContent{winner}).name;
    auth = userStruct.(cellContent{winner}).autorisation;
    disp(['nearest match: ' userStruct.(cellContent{winner}).name]);
end

if(plotEnable == 1)
    [xlim, ylim] = size(mfcc);
    [xq,yq] = meshgrid(linspace(0, ylim, ylim*10), linspace(0, xlim, xlim*10));       % generate close-mesh meshgrid for interpolation
    result_ip = interp2(mfcc,xq,yq);              % interpolate data to close-mesh meshgrid
    subplot(3,2,6)
    h = mesh(result_ip.');
    %get(gca,'XTickLabel', {'25', '50', '75', '100'});
    view(33, 28);                                   % change POV to AZ 33 EL 28
    grid on;
    title('Mel Coefficients');
    axis tight;
    set(gca,'XLim', [0 1000]);
    set(gca,'YLim', [0 600]);
%     set(gca,'ZLim', [-50 50]);
    set(gca,'XTick', [200, 400, 600, 800, 1000]);
    set(gca,'XTickLabel', num2str([20; 40; 60; 80; 100]));
    set(gca,'YTick', [150, 300, 450, 600]);
    set(gca,'YTickLabel', num2str([15; 30; 45; 60]));
    set(get(gca,'XLabel'),'String','Mel Coefficients');
    set(get(gca,'YLabel'),'String','Blocks');
    set(get(gca,'ZLabel'),'String','Amplitude');
end