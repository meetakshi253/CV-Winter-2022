[pndl1, pndl2, pdl1, pdl2] = WriteSaliencyMetrics("../../inputs/Images-Q1","../../inputs/DL-Saliency/", "../../inputs/Non-DL-Saliency", "../../outputs/");
fprintf("\n ----- For Separation Measure ----- \n")
SignificanceTesting(pdl1, pndl1)
fprintf("\n ----- For Concentration Measure ----- \n")
SignificanceTesting(pdl2, pndl2)

function [phi_non_dl_scores, psi_non_dl_scores, phi_dl_scores, psi_dl_scores] = WriteSaliencyMetrics(dbpath, dl_dbpath, non_dl_dbpath, outputpath)
    scores = {199, 5}; %img filename, Non-DL phi, Non-DL psi, DL phi, DL psi
    phi_non_dl_scores = zeros(199, 1);
    psi_non_dl_scores = zeros(199, 1);
    phi_dl_scores = zeros(199, 1);
    psi_dl_scores = zeros(199, 1);
    allimages = dir(dbpath+'/'+'*.jpg'); 
    for ii = 1:length(allimages)
        dl_saliency_map = imread(dl_dbpath+"/"+allimages(ii).name);
        non_dl_saliency_map = imread(non_dl_dbpath+"/"+allimages(ii).name);
        if(size(dl_saliency_map) ~= size(non_dl_saliency_map))
             dl_saliency_map = imresize(dl_saliency_map, [256, 256]);
             non_dl_saliency_map = imresize(non_dl_saliency_map, [256, 256]);
        end
        phi_dl = FindSeparationMeasure(dl_saliency_map);
        psi_dl = FindConcentrationMeasure(dl_saliency_map);
        phi_non_dl = FindSeparationMeasure(non_dl_saliency_map);
        psi_non_dl = FindConcentrationMeasure(non_dl_saliency_map);
        scores{ii, 1} = allimages(ii).name;
        scores{ii, 2} = phi_non_dl+eps;
        scores{ii, 3} = psi_non_dl+eps;
        scores{ii, 4} = phi_dl+eps;
        scores{ii, 5} = psi_dl+eps;
        phi_non_dl_scores(ii) = phi_non_dl+eps;
        psi_non_dl_scores(ii) = psi_non_dl+eps;
        phi_dl_scores(ii) = phi_dl+eps;
        psi_dl_scores(ii) = psi_dl+eps;
    end
    T = cell2table(scores,'VariableNames',{'Image File Name', 'Non-DL Separation Measure', 'Non-DL Concentration Measure', 'DL Separation Measure', 'DL-Concentration Measure'});
    disp(T)
    writetable(T, outputpath+"Saliency Quality Measurements.csv");
end

%1: Separation Measure
function phi = FindSeparationMeasure(img) %saliency map
    %otsu thresholding
    S = im2double(img);
    thresh = graythresh(S);
    mask = S>thresh;
    fg = S(mask);
    bg = S(~mask);
    if isempty(fg)
        fg=0;
    end
    if isempty(bg)
        bg=0;
    end
    mean_fg = mean(fg(:))+eps;
    std_fg = std(fg(:))+eps;
    mean_bg = mean(bg(:))+eps;
    std_bg = std(bg(:))+eps;

    z = linspace(0,1,256);

    D_fg = exp(-0.5*((z-mean_fg)/std_fg).^2)/(std_fg*sqrt(2*pi));
    D_bg = exp(-0.5*((z-mean_bg)/std_bg).^2)/(std_bg*sqrt(2*pi));

    %find roots of quadratic equation
    p = (1/std_bg^2)-(1/std_fg^2);
    q = -2*((mean_bg/std_bg^2)-(mean_fg/std_fg^2));
    r = (mean_bg^2/std_bg^2)-(mean_fg^2/std_fg^2)+2*log((std_bg/std_fg)+eps);

    rt = roots([p, q, r]);
    zstar = rt(rt>=0 & rt<=1);

    Ls = sum(D_fg(z<zstar))+sum(D_bg(z>=zstar)); 
    phi = 1/(1+log10(1+256*Ls)); %number of bins = 256

end


%2: Concentration Measure
function psi = FindConcentrationMeasure(img)
    %otsu thresholding
    S = im2double(img);
    bnw = imbinarize(S, graythresh(S));
    %imshow(bnw)
    Os = regionprops(bnw);
    Cu_max = -1;
    component_areas = extractfield(Os,'Area');
    sum_areas = sum(component_areas);
    for ii = 1:size(component_areas)
        Cu = component_areas(ii)/sum_areas;
        if(Cu>Cu_max) 
            Cu_max = Cu; 
        end
    end
    psi = (Cu_max)+(1-Cu_max)/size(component_areas, 2);
end

function SignificanceTesting(dist1, dist2)
    [h, p, ci, ~] = ttest2(dist1, dist2, 'Vartype','unequal');
    [p2, h2] = ranksum(dist1, dist2);

    fprintf("\nT-Test:\n");
    if (h==1)
        fprintf("%s \n", "ttest rejects the null hypothesis at the default 5% significance level without assuming equal variances. The two distributions are statistically different.");
    elseif (h==0)
        fprintf("%s \n", "ttest does not reject the null hypothesis at the default 5% significance level without assuming equal variances. The two distributions are not statistically different.");
    end
    fprintf("P-value: %i \n", p);
    fprintf("Confidence Interval: %i, %i \n", ci(1), ci(2))

    fprintf("\nWilcoxon rank sum test:\n");
    if(h2==1)
        fprintf("%s \n", "Wilcoxon rank sum test rejects the null hypothesis at the default 5% significance level.")
    elseif(h2==0)
        fprintf("%s \n", "Wilcoxon rank sum test does not rejects the null hypothesis at the default 5% significance level.")
    end
    fprintf("P-value: %i \n", p2);

    m1 = mean(dist1);
    m2 = mean(dist2);
    if(m1>m2)
        fprintf("Mean of distribution 1 is greater than that of distribution 2 \n");
    elseif(m2>=m1)
        fprintf("Mean of distribution 2 is greater than that of distribution 1 \n");
    end
end
