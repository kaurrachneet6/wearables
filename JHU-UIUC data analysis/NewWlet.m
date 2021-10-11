%% beginning
%clear; close all;clc;
NameF1='PDMotion';
NameF2=['0001';'0002';'0003';'0006';'0007';'0008';'0009';'0010';
    '0011';'0012';'0013';'0015';'0017';'0018';'0019';'0020';
    '0021';'0022';'0023';'0024';'0025';'0026';'0027';'0028';'0029';'0030'];
NameF3='.xlsx';
NameF4='Test';
Name4='.jpg';

% Components
NameA2=["_PS_";"_HM_";"_FT_";"_TT_";"_LA_"];
NameU3=["rfx";"rfy";"rfz";"rwx";"rwy";"rwz";"lfx";"lfy";"lfz";"lwx";"lwy";"lwz"];
NameL3=["rax";"ray";"raz";"rtx";"rty";"rtz";"lax";"lay";"laz";"ltx";"lty";"ltz"];
NameTabs = ["pro-sup";"hand motion";"finger tap";"toe tap";"leg agility"];

s = '/';
u = '_';
home_path = '/Users/akanksha/Desktop/rep_measurement_dataset/';
mkdir cwt/0; mkdir cwt/1; mkdir cwt/2; mkdir cwt/3; mkdir cwt/4;
mkdir stft/0; mkdir stft/1; mkdir stft/2; mkdir stft/3; mkdir stft/4;

%%
for subj=1:size(NameF2,1)
%% importing data

Acc=importdata(strcat(home_path,NameF2(subj,:),s,NameF4,s,NameF2(subj,:),u,NameF4,NameF3));
CompPtr={Acc.data.PS;Acc.data.HM;Acc.data.FT;Acc.data.TT;Acc.data.LA};

for i = 1:5
    IntPtr=CompPtr{i};
    Name2 = NameA2(i);
    for j = 4:6:10 %only finger, use 4:3:13 for finger+wrist
        k = (j-1)/3;
        start = st_1{subj}{i}(k);
        stop = st_2{subj}{i}(k);
        mi = mean([start stop]);
        stop = round(mi+300);
        start = round(mi-500);
        rat = num2str(rt{subj}{i}(k)); 
        x1 = sqrt(((IntPtr(start:stop,j)-mean(IntPtr(start:stop,j)))/abs(max(IntPtr(start:stop,j)))).^2+((IntPtr(start:stop,j+1)-mean(IntPtr(start:stop,j+1)))/abs(max(IntPtr(start:stop,j+1)))).^2+((IntPtr(start:stop,j+2)-mean(IntPtr(start:stop,j+2)))/abs(max(IntPtr(start:stop,j+2)))).^2);  
        Name3=NameU3(j-3);
        %cfs = abs(stft(x1)); %short-term Fourier transform
        cfs = abs(cwt(x1)); %continuous wavelet transform
        im = ind2rgb(im2uint8(rescale(cfs)),bone(128));
        imwrite(imresize(im,[224 224]),strcat(home_path,'cwt',s,rat,s,NameF2(subj,:),u,Name2,u,rat,u,Name3,Name4));
    end
end
end
