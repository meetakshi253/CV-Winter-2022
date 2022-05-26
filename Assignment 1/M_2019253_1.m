%equation 3
% Saliency_Map_Eqn3('leaf_kmeans.png', "leaf.jpg");
%Saliency_Map_Eqn5('BigTree.jpg', 'BigTree_segmented2.png');
 dbpath = "originals"
 oppath = "ops"
 allimages = dir(dbpath+'/'+'*.jpg'); 
     for ii = 1:length(allimages)
         img = imread(dbpath+"/"+allimages(ii).name);
          kmeansclus = kmeans_seg_k(img, 85);
          imshow(kmeansclus)
          Saliency_Map_Eqn3(kmeansclus, oppath+"/"+allimages(ii).name);
     end

    function Saliency_Map_Eqn3(img, filename)
    img_rgb_columns = reshape(img, [], 3);
    [img_centroids, ~, n] = unique(img_rgb_columns, 'rows');
    color_counts = accumarray(n, 1);
    [nrows, ncols] = size(img(:,:,1));
    saliency_map = zeros([nrows ,ncols]);
    color_probability = color_counts./(nrows*ncols);
    img_centroids = double(img_centroids);
    size(img_centroids)
    %centroids are actually the 85 colours used

    for ii = 1:size(img_centroids)  %85 colours
        sum_dist = double(0);
        for jj = 1:size(img_centroids)
            temp = double(double(img_centroids(ii,1)-img_centroids(jj,1)).^2 + double(img_centroids(ii,2)-img_centroids(jj,2)).^2 + double(img_centroids(ii,3)-img_centroids(jj,3)).^2);
            sum_dist = sum_dist + double(color_probability(jj)*sqrt(temp));
        end
        condition = img(:,:,1)==img_centroids(ii,1) & img(:,:,2)==img_centroids(ii,2) & img(:,:,3)==img_centroids(ii,3);
        saliency_map(condition) = sum_dist;
    end

    %normalise
    saliency_map = saliency_map - min(saliency_map(:));
    div = max(saliency_map(:));
    saliency_map_norm = saliency_map/div;
    
%     montage({img, saliency_map_norm});
%     title('85-colour Image and its Saliency Map using Eqn 3');
    imwrite(saliency_map_norm, filename, "jpg");
end

%equation 5
function Saliency_Map_Eqn5(img_path, segmented_img_path)
    img = imread(img_path);
    img = im2uint8(img);
    img_segmented = imread(segmented_img_path);
    img_segmented = im2uint8(img_segmented);
    [nrows, ncols] = size(img(:,:,1));
    saliency_map = zeros([nrows ,ncols]);

    %find number of segments/regions (colours) used in the image
    img_rgb_columns = reshape(img_segmented, [], 3);
    [img_centroids, ~, n] = unique(img_rgb_columns, 'rows');
    color_counts = accumarray(n, 1);
    img_centroids = double(img_centroids);
    [nsegments, ~] = size(img_centroids);

    all_reg_col = cell(nsegments,1);
    all_reg_col_pbbty = cell(nsegments,1);

    %find probability of colours in each region

    for k=1:nsegments
        %region mask
        region_mask = img_segmented(:,:,1)==img_centroids(k,1) & img_segmented(:,:,2)==img_centroids(k,2) & img_segmented(:,:,3)==img_centroids(k,3);
        temp = int8(img);
        temp(~region_mask) = -1;

        %calculate the probability of all colours in that region
        rgb_col = reshape(temp, [], 3);
        [col_region, ~, n_region] = unique(rgb_col, 'rows');
        region_color_counts = accumarray(n_region, 1);
        cond = col_region(:,1)==-1 | col_region(:,2)==-1 | col_region(:,3)==-1;
        col_region(cond, :) = [];
        region_color_counts(cond, :) = [];
        region_color_pbbty = region_color_counts./color_counts(k);

        all_reg_col{k,:} = double(col_region);
        all_reg_col_pbbty{k,:} = double(region_color_pbbty);
    end

    %weight of the region
    for k=1:nsegments
        sum = double(0);
        for i = 1:nsegments
            if(i==k)
                continue
            end
        weight = double(color_counts(i));

        %now, distance has to be found

        Dr = double(0);

        k_pixels = all_reg_col{k};
        i_pixels = all_reg_col{i};
        k_pbbty = all_reg_col_pbbty{k};
        i_pbbty = all_reg_col_pbbty{i};

        [k_rows, ~] = size(k_pbbty);
        [i_rows, ~] = size(i_pbbty);

        for ii = 1:k_rows
            for jj = 1:i_rows
                dist = double(double(k_pixels(ii,1)-i_pixels(jj,1)).^2 + double(k_pixels(ii,2)-i_pixels(jj,2)).^2 + double(k_pixels(ii,3)-i_pixels(jj,3)).^2);
                dist = double(sqrt(dist));
                dr = k_pbbty(ii)*i_pbbty(jj)*dist;
                Dr = Dr+double(dr);
            end
        end

        sum = double(sum+weight*Dr);

        %now find region mask for region k
        condition = img_segmented(:,:,1)==img_centroids(k,1) & img_segmented(:,:,2)==img_centroids(k,2) & img_segmented(:,:,3)==img_centroids(k,3);
        saliency_map(condition) = sum;
        end
    end

    %normalise
    saliency_map = saliency_map - min(saliency_map(:));
    div = max(saliency_map(:));
    saliency_map_norm = saliency_map/div;

    montage({img, saliency_map_norm});
    title('18-segment Image and its Saliency Map using Eqn 5');
    imwrite(saliency_map_norm, "BigTree_saliency_eqn5_100_segments.png", "png");
end

