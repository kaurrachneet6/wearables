%% importing data into MATLAB
clear; close all; clc;
%Load images with 'Low' rating
LowImages = imageDatastore('rawfigs1/Low','FileExtensions','.jpg','IncludeSubfolders',true,'LabelSource','foldernames');
rng default %Set the random seed to the default value
[LowKeep, LowDelete] = splitEachLabel(LowImages,0.25,'randomized'); %Keep 25% of the images for classification, and the remainder is omitted
LowKeep.Files;

%% notes
mkdir cwt_low_select 
mkdir stft_low_select
copyfile cwt/0 cwt_low_select; copyfile cwt/1 cwt_low_select
copyfile stft/0 stft_low_select; copyfile stft/1 stft_low_select
%Load images with 'Low' rating
LowImages = imageDatastore('cwt_low_select','FileExtensions','.jpg','IncludeSubfolders',true,'LabelSource','foldernames');
rng default %Set the random seed to the default value
[LowKeep, LowDelete] = splitEachLabel(LowImages,0.25,'randomized'); %Keep 25% of the images for classification, and the remainder is omitted
%%
mkdir cwt_test
mkdir cwt_testB
copyfile cwt/0 cwt_test; copyfile cwt/1 cwt_test
%Load images with 'Low' rating
LowImages = imageDatastore('cwt_test','FileExtensions','.jpg','IncludeSubfolders',true,'LabelSource','foldernames');
rng default %Set the random seed to the default value
[LowKeep, LowDelete] = splitEachLabel(LowImages,0.25,'randomized'); %Keep 25% of the images for classification, and the remainder is omitted
test = LowKeep.Files
for i=1:length(test)
    %char(test{i})
    copyfile char(test{i}) cwt_testB
end

myfile = '/Users/akanksha/Desktop/rep_measurement_dataset/cwt_low_select';
a = length(dir(fullfile(myfile, '*.jpg')));
i = randperm(a,a/4);

for i = 1:size(i)
    %movefile = 
end

mkdir cwt_classify/Low; mkdir cwt_classify/High
mkdir stft_classify/Low; mkdir stft_classify/High
copyfile cwt/0 cwt_classify/Low; copyfile cwt/1 cwt_classify/Low; copyfile cwt/3 cwt_classify/High; copyfile cwt/4 cwt_classify/High
copyfile stft/0 stft_classify/Low; copyfile stft/1 stft_classify/Low; copyfile stft/3 stft_classify/High; copyfile stft/4 stft_classify/High

%%
allImages = imageDatastore('rawfigs2','FileExtensions','.jpg','IncludeSubfolders',true,'LabelSource','foldernames');
rng default %Set the random seed to the default value
[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized'); %Use 80% of the images for training, and the remainder for validation
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]); %Randomly divided from images, group for training
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]); %Randomly divided from images group for validation

%%
net = googlenet; %Load the pretrained GoogLeNet neural network

%Extract and display the layer graph from the network.
lgraph = layerGraph(net);
numberOfLayers = numel(lgraph.Layers);
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)
title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);

%net.Layers(1) %inspect the first layer to confirm that GoogLe Net requires 224x224x3 RGB images

%custom dropout layer to prevent overfitting
newDropoutLayer = dropoutLayer(0.6,'Name','new_Dropout'); %dropoutlayer
lgraph = replaceLayer(lgraph,'pool5-drop_7x7_s1',newDropoutLayer);

%Replace 'loss3-classifier' with a new layer with the number of filters equal to the number of classes. 
%Increase the learning rate factors of the fully connected layer.
numClasses = numel(categories(imgsTrain.Labels));
newConnectedLayer = fullyConnectedLayer(numClasses,'Name','new_fc',...
    'WeightLearnRateFactor',5,'BiasLearnRateFactor',5);
lgraph = replaceLayer(lgraph,'loss3-classifier',newConnectedLayer);

%Replace the classification layer with a new one without class labels
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);

%Use the stochastic gradient descent with momentum optimizer
%Set MiniBatchSize to 10, MaxEpochs to 10, and InitialLearnRate to 0.0001 
%For purposes of reproducibility, set ExecutionEnvironment to cpu
%Visualize training progress by setting Plots to training-progress
%Set the random seed to the default value. 
options = trainingOptions('sgdm',...
    'MiniBatchSize',15,...
    'MaxEpochs',20,...
    'InitialLearnRate',1e-4,...
    'ValidationData',imgsValidation,...
    'ValidationFrequency',10,...
    'Verbose',1,...
    'ExecutionEnvironment','cpu',...
    'Plots','training-progress');
rng default

%train the network
trainedGN = trainNetwork(imgsTrain,lgraph,options);

%Evaluate the network using the validation data
trainedGN.Layers(end)
[YPred,probs] = classify(trainedGN,imgsValidation);
accuracy = mean(YPred==imgsValidation.Labels);
disp(['GoogLeNet Accuracy: ',num2str(100*accuracy),'%'])

%% 
% Examine which areas in the convolutional layers activate on an image from the High class
%Compare with the corresponding areas in the original image

convLayer = 'conv1-7x7_s2';

imgName = 'rawfigs1/High/0022__LA__3_lfx.jpg';
imarr = imread(imgName);

trainingFeaturesARR = activations(trainedGN,imarr,convLayer);
sz = size(trainingFeaturesARR);
trainingFeaturesARR = reshape(trainingFeaturesARR,[sz(1) sz(2) 1 sz(3)]);
figure;hold on
montage(rescale(trainingFeaturesARR),'Size',[8 8])
title(['High',' Activations'])

%Find the strongest channel for this image. 
%Compare the strongest channel with the original image.
imgSize = size(imarr);
imgSize = imgSize(1:2);
[~,maxValueIndex] = max(max(max(trainingFeaturesARR)));
arrMax = trainingFeaturesARR(:,:,:,maxValueIndex);
arrMax = rescale(arrMax);
arrMax = imresize(arrMax,imgSize);
figure;
imshowpair(imarr,arrMax,'montage')
%title(['Strongest ',imgClass,' Channel: ',num2str(maxValueIndex)])