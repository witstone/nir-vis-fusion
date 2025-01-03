clear all;
clc;

rgbpath='path_to_rgb_images/';
nirpath='path_to_nir_images/';
rgblist=dir(fullfile(rgbpath,'*.jpg'));
nirlist=dir(fullfile(nirpath,'*.jpg'));

for i=1:length(rgblist)
    % 读取RGB图像和NIR图像
    rgb=im2double(imread([rgbpath '\' rgblist(i).name ]));
    rgb = ALTM_Retinex(rgb);
    
    NIR=im2double(imread([nirpath '\' nirlist(i).name ]));
    if size(NIR,3)==3
        NIR=NIR(:,:,1);
    end
    
    % 调整图像大小
    [m,n,c]=size(NIR);
    m=960;
    n=1280;
    
    % 调用融合函数
    result = NIRRGBFusion(rgb, NIR);
    
    % 保存结果
    imwrite(uint8(result*255),['results/' rgblist(i).name]);
end

% ALTM_Retinex函数定义
function outval = ALTM_Retinex(II)
    Ir=double(II(:,:,1)); 
    Ig=double(II(:,:,2)); 
    Ib=double(II(:,:,3));
    
    % Global Adaptation
    Lw = 0.299 * Ir + 0.587 * Ig + 0.114 * Ib;
    Lwmax = max(max(Lw));
    [m, n] = size(Lw);
    Lwaver = exp(sum(sum(log(0.001 + Lw))) / (m * n));
    Lg = log(Lw / Lwaver + 1) / log(Lwmax / Lwaver + 1);
    gain = Lg ./ Lw;
    gain(Lw == 0) = 0;
    outval = cat(3, gain .* Ir, gain .* Ig, gain .* Ib);
end 