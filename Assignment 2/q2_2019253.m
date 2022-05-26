%images resized to 256*256
%SPP number of patches: 16, 4, 1
%Patch sizes: 64*64, 128*128, 256*256

q2("../../inputs/dd", 5)

function q2(dbpath, k)
    opdirpath = "../../outputs/";
    [allimages, labels] = GroupImages(dbpath, k);
    for ii = 1:size(labels, 1)
        foldername = opdirpath+"Cluster"+ii;
        if exist(foldername, 'dir')
          rmdir(foldername, 's');
        end
        mkdir(foldername)
        for jj = labels{ii, :}
            ipfilename = dbpath+"/"+allimages(jj).name;
            opfilename = foldername+"/"+allimages(jj).name;
            img = imread(ipfilename);
            imwrite(img, opfilename, "jpg");
        end
    end
    fprintf("\nDone! Check the output folder for the clustered images\n");
end


function [allimages, labels] = GroupImages(dbpath, k)
    allimages = dir(dbpath+'/'+'*.jpg'); 
    aggr = [];
    for ii = 1:length(allimages)
        img = imread(dbpath+"/"+allimages(ii).name);
        imgray = im2gray(img);
        imgray = imresize(imgray, [256, 256]);
        sppfeatures = SPPFeatures(imgray);
        aggr = [aggr; sppfeatures];
    end
    [~, U] = FuzzyCMeans(aggr, k);
    maxU = max(U);
    labels = cell(k,1);
    for i=1:5
        labels{i} = find(U(i,:) == maxU);
    end
end

function [centers, U] = FuzzyCMeans(data, k)
    [centers, U] = fcm(data, k);
end

function sppfeatures = SPPFeatures(img)  %grayscale image resized to 256*256
    sppfeatures = [];
    lbprepresentation = LBPForImage(img);
    patchsizes = [64, 128, 256];
    for ps = patchsizes
        h = ReturnHistogram(img, lbprepresentation, ps);
        sppfeatures = [sppfeatures, h];
    end
end

function hstgm = ReturnHistogram(img, lbprepresentation, patchsize)
    dim1 = size(img, 1)/patchsize;
    dim2 = size(img, 2)/patchsize;
    hstgm = zeros(1, 256*dim1*dim2);
    index1=1; index2=256;
    for ii = 1:dim1
        r1 = (ii-1)*patchsize + 1;
        r2 = ii*patchsize;
        for jj = 1:dim2
            c1 = (jj-1)*patchsize + 1;
            c2 = jj*patchsize;
            i = mat2gray(uint8(lbprepresentation(r1:r2, c1:c2)));
            h = imhist(i, 256);
            hstgm(index1:index2) = h;
            index1=index1+256;
            index2=index2+256;
        end
    end
end

%lbp for each cell in the image. Can be used later
function lbprepresentation = LBPForImage(img) %grayscale image resized to 256*256
    imgpad = padarray(img, [1,1], 0, 'both');
    lbprepresentation = zeros(256, 256);
    for i = 1:256
        for j = 1:256
            r = i+1; c = j+1;
            lbpcode = CalculateLBP(imgpad, r, c);
            lbprepresentation(i,j) = lbpcode;
        end
    end
end

function lbp = CalculateLBP(imgpad, r, c)
   % Create LBP of the corner pixel using 8 neighbours with the starting, LSB pixel in the upper left.
   centerpixel = imgpad(r,c);
   pixel8 = round(min(imgpad(r-1, c-1), centerpixel)/max(max(imgpad(r-1, c-1), centerpixel), eps));
   pixel7 = round(min(imgpad(r-1, c), centerpixel)/max(max(imgpad(r-1, c), centerpixel), eps));
   pixel6 = round(min(imgpad(r-1, c+1), centerpixel)/max(max(imgpad(r-1, c+1), centerpixel),eps));
   pixel5 = round(min(imgpad(r, c+1), centerpixel)/max(max(imgpad(r, c+1), centerpixel),eps));
   pixel4 = round(min(imgpad(r+1, c+1), centerpixel)/max(max(imgpad(r+1, c+1), centerpixel),eps));
   pixel3 = round(min(imgpad(r+1, c), centerpixel)/max(max(imgpad(r+1, c), centerpixel), eps));
   pixel2 = round(min(imgpad(r+1, c-1), centerpixel)/max(max(imgpad(r+1, c-1), centerpixel),eps));
   pixel1 = round(min(imgpad(r, c-1), centerpixel)/max(max(imgpad(r, c-1), centerpixel),eps));
    
    lbp = uint8(...
			pixel8 * 2^7 + pixel7 * 2^6 + ...
			pixel6 * 2^5 + pixel5 * 2^4 + ...
			pixel4 * 2^3 + pixel3 * 2^2 + ...
			pixel2 * 2 + pixel1);
end