% imgpath = input("Enter path to input image: ");
% oppath = input("Enter path for the output: ");
% N = input("Enter the number of superpixels N: ");
Create_Saliency_Map("../../inputs/0002.jpg", "../../outputs/", 500);

function Create_Saliency_Map(imgpath, oppath, N)
  img = imread(imgpath);
    [labels, numlabels] = superpixels(img, N);
    sppxl_avg_colours = zeros(3, numlabels);
    sppxl_avg_dist = zeros(2, numlabels);
    saliency_map = zeros(size(labels));
    wh = sqrt(sum(size(img(:,:,1)).^2));
    bndmask = boundarymask(labels);

    %find average colour and location each superpixel
    for ii = 1:numlabels
        k = find(labels==ii);
        [r, c] = ind2sub(size(img), k);
        mx = round(mean(r));
        my = round(mean(c));
        sppxl_avg_dist(:, ii) = [mx, my];
        sppxl_avg_colours(:, ii) = [img(mx,my,1);img(mx,my,2);img(mx,my,3)];
    end

    %compute the saliency map
    for ii = 1:numlabels
        sal_ii = 0;
        for jj = 1:numlabels
            if (ii==jj)
                continue
            end
            colour_diff = sqrt(sum((sppxl_avg_colours(:, ii)-sppxl_avg_colours(:, jj)).^2));
            dist_diff = sqrt(sum((sppxl_avg_dist(:, ii)-sppxl_avg_dist(:, jj)).^2));
            sal_ii = sal_ii + colour_diff*exp(dist_diff/wh);
        end
        mask = labels==ii;
        saliency_map(mask) = sal_ii;
    end

    saliency_map = saliency_map - min(saliency_map(:));
    div = max(saliency_map(:));
    saliency_map = saliency_map/div;
    montage({imoverlay(img, bndmask), saliency_map});
    imwrite(saliency_map, oppath+"/"+"q1_saliency_map.png");
    fprintf("Saliency map written to output folder\n");
end

