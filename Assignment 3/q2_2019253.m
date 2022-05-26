pts = [[0.025, 10]; [0.05, 10]; [0.08, 20];[0.1, 30]; [0.02, 3]];
for i = 1:size(pts,1)
    performdbscan("../../inputs/0002.jpg", "../../outputs/", pts(i,1), pts(i,2));
end

function performdbscan(inputpath, oppath, eps, minpts)  
img = imread(inputpath);
[r, c, ~] = size(img);
imgdata = zeros(r*c, 5);
ind = 0;
for ii=1:c
     for jj=1:r
         ind = ind+1;
         imgdata(ind, 1:3) = img(jj,ii,:);
         imgdata(ind, 4:5) = [jj,ii];
     end
 end
imgdata=imgdata./repmat([255 255 255 r c],[r*c 1]);
idx = dbscan(imgdata,eps, minpts); % Euclidean distance
%0.025,10
mean_colors = [];
idx(idx==-1) = size(unique(idx),1);
%find mean of colours in the region
for i = 1:(size(unique(idx),1))
    cols = imgdata(idx==i,1:3);
    mean_colors(i,:) = mean(cols);
end

rr=reshape(idx,[r,c]); % reshaping the labelled data to 2D
conv_img=zeros(r,c,3);
for i=1:r
    for j=1:c
        if(rr(i,j) == -1)
            continue
        end
        conv_img(i,j,:)=mean_colors(rr(i,j),:);% constructing the segmented image
    end
end

figure, montage({img, conv_img});
title("For eps and minpts = "+eps+" ,"+minpts);
imwrite(conv_img, oppath+"/q2_segmented"+eps+minpts+".png"); 
end
