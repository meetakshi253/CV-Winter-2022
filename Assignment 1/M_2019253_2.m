Modified_Otsu('horse.jpg');

function Modified_Otsu(imgpath)    % q2. modified otsu's algorithm
    img = imread(imgpath);
    img_gray = double(rgb2gray(img));
    [nrows, ncols] = size(img_gray);
    [pixel_count, ~] = imhist(uint8(img_gray));
    pixel_prob = pixel_count./(nrows*ncols);
    thresh = 0;
    tss_store = double(zeros(1,256));

    while thresh<=255
        mean_0 = double(0);
        mean_1 = double(0);
        tss_0 = double(0);
        tss_1 = double(0);
        wt_0 = sum(double(pixel_prob(1:thresh+1)));
        wt_1 = sum(double(pixel_prob(thresh+2:256)));

        for i = 0:255
            if i<=thresh
                mean_0 = mean_0+double(i*pixel_prob(i+1));
            else
                mean_1 = mean_1+double(i*pixel_prob(i+1));
            end
        end
        mean_0 = mean_0/wt_0;
        mean_1 = mean_1/wt_1;

        for nrow = 1:nrows
            for ncol = 1:ncols
                if img_gray(nrow,ncol)<=thresh
                    tss_0 = tss_0+double(img_gray(nrow,ncol)-mean_0).^2;
                else
                    tss_1 = tss_1+double(img_gray(nrow,ncol)-mean_1).^2;
                end
            end
        end

        tss_store(thresh+1) = tss_0+tss_1;
        thresh = thresh+1;
    end

    threshold_all = 0:255;
    threshold_0to1 = threshold_all./256;
    T = array2table(horzcat(threshold_all.', threshold_0to1.', tss_store.'));
    T.Properties.VariableNames(1:3) = {'Threshold Value', 'Thresh Value b/w 0-1', 'Sum-of-TSS Value'};
    writetable(T,'q2/q2_tss_thresh.csv')

    tss_min = find(tss_store==(min(tss_store)));
    opt_threshold = (tss_min-1)/256;
    fprintf("Optimal threshold for the image = %i or %i, and minimum TSS = %f\n", tss_min-1, opt_threshold, min(tss_store));
    imwrite(imbinarize(uint8(img_gray), opt_threshold), 'q2/q2_binmask.png', 'png');
end