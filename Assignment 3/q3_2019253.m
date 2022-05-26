img = im2gray(imread("../../inputs/0002.jpg"));

fprintf("SIFT: \n")
tic
sift_points = detectSIFTFeatures(img);
toc
figure, imshow(img);
hold on;
plot(sift_points.selectStrongest(10),'showOrientation',true)
title("Top 10 descriptors using SIFT");
F2 = getframe;
imwrite(F2.cdata, "../../outputs/q3_sift_des.png")

fprintf("SURF: \n")
tic
surf_points = detectSURFFeatures(img);
toc
figure, imshow(img);
hold on;
plot(surf_points.selectStrongest(10), 'showOrientation',true)
title("Top 10 descriptors using SURF");
F1 = getframe;
imwrite(F1.cdata, "../../outputs/q3_surf_des.png")
