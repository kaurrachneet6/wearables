%% beginning
%clear; close all;clc;
NameF1='PDMotion';
NameF2=['0001';'0002';'0003';'0006';'0007';'0008';'0009';'0010';'0011';'0012';'0013';'0015';'0017';'0018';'0019';'0020';
    '0021';'0022';'0023';'0024';'0025';'0026';'0027';'0028';'0029';'0030'];
%NameF2=['0024';'0025';'0026';'0027';'0028';'0029';'0030'];
% DO 0024,25,28,29,30,check 6,!!
% omitted: 0005 datasheet not ok; 0013 errors idk why; 0014 no TT, no
% folder 0016; 0028 errors idk
NameF3='.xlsx';
NameF4='Test';
Name4='.jpg';

% Components
NameA2=["PS";"HM";"FT";"TT";"LA"];
NameU3=["rfx";"rfy";"rfz";"rwx";"rwy";"rwz";"lfx";"lfy";"lfz";"lwx";"lwy";"lwz"];
NameL3=["rax";"ray";"raz";"rtx";"rty";"rtz";"lax";"lay";"laz";"ltx";"lty";"ltz"];
NameTabs = ["pro-sup";"hand motion";"finger tap";"toe tap";"leg agility"];

s = '/';
u = '_';
home_path = '/Users/akanksha/Desktop/pd_2/';
mkdir a/0; mkdir a/1; mkdir a/2; mkdir a/3; mkdir a/4;

%%
for subj=4
%% importing data

Acc=importdata(strcat(home_path,NameF2(subj,:),s,NameF4,s,NameF2(subj,:),u,NameF4,NameF3));
CompPtr={Acc.data.PS;Acc.data.HM;Acc.data.FT;Acc.data.TT;Acc.data.LA};

for i = 1:5
    IntPtr=CompPtr{i};
    L = length(IntPtr);
    Name2 = NameA2(i);
    for j = 4:6:10
        k = (j-1)/3;
        l = (j+2)/6;
        ss = subj-10;
        start = st_1{subj}{i}(k);
        stop = st_2{subj}{i}(k);
        %start = 1;
        %stop = L;
        %if rt{subj}{i}(k) == 0 | 1
        %    rat = 'Low';
        %elseif rt{subj}{i}(k) == 3 | 4
        %    rat = 'High';
        %else
        %    rat = '2';
        %end
        %rat = num2str(a{ss}{i}(l));
        x1 = sqrt(IntPtr(start:stop,j).^2+IntPtr(start:stop,j+1).^2+IntPtr(start:stop,j+2).^2);
        %[A.(strcat(NameF2,Name2,Name3,Name4))] = x1; find way to add stuff to Excel sheet!   
        Name3=NameU3(j-3);
        figure; plot(start:stop,x1);
        stft(x1); %creating and saving figure
        %cfs = abs(cwt(x1));
        %im = ind2rgb(im2uint8(rescale(cfs)),jet(128));
        %imwrite(imresize(im,[224 224]),strcat(home_path,'a',s,rat,s,NameF2(subj,:),u,Name2,u,rat,u,Name3,Name4));
    end
    %Write out combined data
    %writematrix(A,strcat(NameF5,NameF2,NameF3),'Sheet',NameTabs(i));
end
end