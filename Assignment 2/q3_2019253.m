%create hog features for each patch in an image. Patch size = 32*32
%number of bins = 15 in HoG

q3("../../inputs/dd", "../../inputs/15_19_s.jpg", 4);

function q3(dbpath, imgpath, k)
    bow = BagOfWords(dbpath);
    descriptor = "";
    centroids = SummarizeFeatures(bow, k);
    img = imread(imgpath);
    imgray = im2gray(img);
    imgray = imresize(imgray, [256,256]);
    collective = BoWImage(imgray);

    fprintf("%d Centroid Vectors:\n", k);
    for ii = centroids'
        disp(ii);
        fprintf("\n");
    end

    %iterate over each patch level feature of the image and find the
    %bow representation
    
    for ii = collective'
        index=1;
        dist = zeros(1, k);
        for jj = centroids'
            d = norm(ii-jj);
            dist(index) = d;
            index = index+1;
        end
        [~, minind] = min(dist);
        descriptor = descriptor+minind;
    end
    fprintf("Feature vector of the image as per the bag of %d words: %s\n", k, descriptor);
end

function bag = BagOfWords(dbpath) %create a bag of visual words for the dataset
    bag = [];
    allimages = dir(dbpath+'/'+'*.jpg');
    for ii = 1:length(allimages)
        img = imread(dbpath+"/"+allimages(ii).name);
        imgray = im2gray(img);
        collective = BoWImage(imgray);
        bag = [bag; collective];
    end
end

function centroids = SummarizeFeatures(bow, k)
    [~, centroids] = kmeans(bow, k);
end

function collective = BoWImage(img)
    imgray = im2gray(img);
    imgray = imresize(imgray, [256,256]);
    patch_size = [32, 32];
    im_size = [256, 256];

    collective = zeros(im_size(1)/patch_size(1)*im_size(2)/patch_size(2), 15);
    x_ind = [1:patch_size(2):im_size(2) im_size(2)+1];
    y_ind = [1:patch_size(1):im_size(1) im_size(1)+1];
    patches = cell(length(y_ind)-1,length(x_ind)-1);
    for i = 1:length(y_ind)-1
    p = imgray(y_ind(i):y_ind(i+1)-1,:);
        for j = 1:length(x_ind)-1
            patches{i,j} = p(:,x_ind(j):x_ind(j+1)-1);
        end
    end
    
    index = 1;
    for ii = patches
        for jj = 1:length(ii)
            collective(index, :) = calculateHog(ii{jj});
            index = index+1;
        end
    end
end

function hog = calculateHog(patch) %patch level HoG calculation of a patch
    dim1 = size(patch,1);
    dim2 = size(patch,2);
    hog = extractHOGFeatures(patch, 'BlockSize', [1,1],'NumBins', 15, 'BlockOverlap', [0,0], 'CellSize', [dim1,dim2], 'UseSignedOrientation', 1);
end