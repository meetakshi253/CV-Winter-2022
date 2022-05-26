q4("../../inputs/dd", "../../inputs/15_19_s.jpg", 7);

function q4(dbpath, imgpath, k)
    [allimages, distances]=CompareLBPHistograms(dbpath, imgpath);
    [~, min_ind] = mink(distances, k);
    ipdirpath = allimages(1).folder;
    opdirpath = "../../outputs/";

    fprintf("%d Nearest Neighbours: \n", k);
    for ii = min_ind
        opfilename = opdirpath+allimages(ii).name;
        ipfilename = ipdirpath+"/"+allimages(ii).name;
        im = imread(ipfilename);
        imwrite(im, opfilename, "jpg");
        fprintf(allimages(ii).name+"\n");
    end
end

function [allimages, distances] = CompareLBPHistograms(dbpath, imgpath)
    target_image = im2gray(imread(imgpath));  
    target_image = imresize(target_image, [256, 256]);
    target_features = CreateLBPFeatures(target_image);
    allimages = dir(dbpath+'/'+'*.jpg'); 
    distances = zeros(1, size(allimages,1));
    for ii = 1:length(allimages)
        img = imread(dbpath+"/"+allimages(ii).name);
        imgray = im2gray(img);
        imgray = imresize(imgray, [256, 256]);
        features = CreateLBPFeatures(imgray);
        d = sqrt(mean((features - target_features).^2));
        distances(ii) = d;
    end
end

function imagefeatures = CreateLBPFeatures(img)
    imagefeatures = zeros(1, 10);
    imgray = im2gray(img);
    corners = ShiTomasiCorners(imgray, 10);
    index1 = 1;
    for ii = 1:10
        lbpfeature = FindLBPForPatch(imgray, corners(ii, :));
        imagefeatures(index1) = lbpfeature; %median LBP value of all 10 corners
        index1 = index1+1;
    end
end

function corners = ShiTomasiCorners(img, num_corners)
    C = detectMinEigenFeatures(img);
    corners = uint8(C.selectStrongest(num_corners).Location);
end

function lbpmedian = FindLBPForPatch(img, corner)
    lbpfeature = zeros(1, 9);
    imgray = im2gray(img);
    imgpad = padarray(imgray, [2,2], 0, 'both');
    r = corner(2)+2;
    c = corner(1)+2;
    %8 nearest neighbours, and find LBP for those neighbours
    ops = [-1, 0, 1];
    index=1;
    for ii = ops
        for jj = ops
            lbp = CalculateLBP(imgpad, r+ii, c+jj);
            lbpfeature(index) = lbp;
            index=index+1;
        end
    end
    lbpmedian = median(lbpfeature, 'all');    %median LBP for a patch
end

function lbp = CalculateLBP(imgpad, r, c)
   % Create LBP of the corner pixel using 8 neighbours with the starting, LSB pixel in the upper left.
   centerpixel = imgpad(r,c);
   pixel8 = imgpad(r-1, c-1)>centerpixel;
   pixel7 = imgpad(r-1, c)>centerpixel;
   pixel6 = imgpad(r-1, c+1)>centerpixel;
   pixel5 = imgpad(r, c+1)>centerpixel;
   pixel4 = imgpad(r+1, c+1)>centerpixel;
   pixel3 = imgpad(r+1, c)>centerpixel;
   pixel2 = imgpad(r+1, c-1)>centerpixel;
   pixel1 = imgpad(r, c-1)>centerpixel;
    
    lbp = uint8(...
			pixel8 * 2^7 + pixel7 * 2^6 + ...
			pixel6 * 2^5 + pixel5 * 2^4 + ...
			pixel4 * 2^3 + pixel3 * 2^2 + ...
			pixel2 * 2 + pixel1);
end