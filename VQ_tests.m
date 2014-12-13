%pattern recognition using Vector quantization
%Each region is called a cluster and can be represented by its center 
%set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')called a codeword. Thecollection of all codewords is called a codebook
%vdqtool
%%clear all; 
close all; clc; addpath('rsc', 'utilities'); superpack;
%featureplot(result(2:4,:))

% X = [randn(100,2)+ones(100,2);...
%     randn(100,2)-ones(100,2)];
%%
X=A';
clf;
[idx,ctrs] = kmeans(X,13,...
                    'Distance','city',...
                    'Replicates',15);


plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)
plot(X(idx==4,1),X(idx==4,2),'c.','MarkerSize',12)
plot(X(idx==5,1),X(idx==5,2),'m.','MarkerSize',12)
plot(X(idx==6,1),X(idx==6,2),'b.','MarkerSize',12)
plot(X(idx==7,1),X(idx==7,2),'y.','MarkerSize',12)
plot(X(idx==8,1),X(idx==8,2),'r.','MarkerSize',12)
plot(X(idx==9,1),X(idx==9,2),'b.','MarkerSize',12)
plot(X(idx==10,1),X(idx==10,2),'g.','MarkerSize',12)
plot(X(idx==11,1),X(idx==11,2),'c.','MarkerSize',12)
plot(ctrs(:,1),ctrs(:,2),'kx',...
    'MarkerSize',12,'LineWidth',2)
axis([-5 5 -3 3]);
 legend('Cluster 1','Cluster 2','Cluster3','Centroids',...
        'Location','NW')
 %%
  subplot(3,1,1)
 [idx,ctrs1] = kmeans(X,13,...
                    'Replicates',5);

 plot(ctrs1(:,1),ctrs1(:,2),'kx','MarkerSize',12,'LineWidth',2)
 axis([-5 5 -1 2])
 subplot(3,1,2) 
 [idx,ctrs2] = kmeans(B',13,...
                    'Replicates',5);
 plot(ctrs2(:,1),ctrs2(:,2),'kx','MarkerSize',12,'LineWidth',2)
 axis([-5 5 -1 2])
 subplot(3,1,3)
 [idx,ctrs3] = kmeans(C',13,...
                    'Replicates',5);  
 plot(ctrs3(:,1),ctrs3(:,2),'kx','MarkerSize',12,'LineWidth',2)
 axis([-5 5 -1 2])