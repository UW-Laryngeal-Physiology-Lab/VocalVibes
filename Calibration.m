clear
close all
videoFile=uigetfile('*.avi');
v=VideoReader(videoFile);
out=struct('imagePoints',[],'boardSize',[]);
k=1;
warning('off','all');
while hasFrame(v)
    I=rgb2gray(readFrame(v));
    disp(k);
    [out(k).imagePoints,out(k).boardSize] = detectCheckerboardPoints(I, 'MinCornerMetric',0.05);
    k=k+1;
end


%Need to convert to arrays so we can conduct operations more efficiently
boardSize=zeros(length(out),2);
for i=1:length(out)
    boardSize(i,:)=out(i).boardSize;
end
modeSize=mode(boardSize);
imagePoints=zeros(length(out),(modeSize(1)-1)*(modeSize(2)-1),2);
exclude=zeros(length(out),1);
for i=1:length(out)
    if(boardSize(i,1)==modeSize(1) && boardSize(i,2)==modeSize(2))
        imagePoints(i,:,:)=out(i).imagePoints;
    else
        exclude(i)=i;
    end
end
exclude(exclude==0)=[];
boardSize(exclude,:)=[];
imagePoints(exclude,:,:)=[];

%Calculate the distance moved by each point
distX=zeros(size(imagePoints,2),1);
distY=zeros(size(distX));
for i=1:length(distX)
    distX(i)=range(imagePoints(:,i,1));
    distY(i)=range(imagePoints(:,i,2));
end

%Finally calculate the ratio between pixels and mm
ratio=zeros(size(imagePoints,1),1);
for i=1:length(ratio)
    ratio(i)=sqrt((imagePoints(i,1,1)-imagePoints(i,end,1))^2+(imagePoints(i,1,2)-imagePoints(i,end,2))^2);
    %Above is the distance between the upper right point and the bottom
    %left in pixels. 
    ratio(i)=ratio(i)/sqrt((modeSize(1)-2)^2+(modeSize(2)-2)^2);
    %We subtract two off of each of these bc they denote the overall size
    %of the checkerboard while we only track "inner points". Look at the
    %details for detectCheckerboardPoints() on mathworks.com for more info
    %(ie try overlaying the imagePoints on the image).
end
%mean(ratio)=pixels/mm

fprintf("Average movement(mm) in the x-direction: %5.3f\nAverage movement(mm) in the y-direction: %5.3f\nTotal average movement(mm): %5.3f\n",mean(distX)/mean(ratio),mean(distY)/mean(ratio),sqrt(mean(distX)^2+mean(distY)^2)/mean(ratio));
