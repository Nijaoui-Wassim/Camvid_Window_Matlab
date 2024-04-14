% Verify GPU Environment
%envCfg = coder.cpuEnvConfig("host");
%envCfg.DeepLibTarget = "cudnn";
%envCfg.DeepCodegen = 1;
%envCfg.Quiet = 1;
%coder.checkGpuInstall(envCfg);

% Downlaod Camvid dataset if it does not exist already
imageURL = "http://web4.cs.ucl.ac.uk/staff/g.brostow/" + ...
    "MotionSegRecData/files/701_StillsRaw_full.zip";
labelURL = "http://web4.cs.ucl.ac.uk/staff/g.brostow/" + ...
    "MotionSegRecData/data/LabeledApproved_full.zip";

outputFolder = fullfile(pwd,"CamVid");


% Load Camvid Dataset
imgDir = fullfile(outputFolder,"images","701_StillsRaw_full");
imds = imageDatastore(imgDir);

% Displaying one sample image
%I = readimage(imds,25);
%I = histeq(I);
%imshow(I)

% Defining the classes we have 12 if we include the background
classes = [
    "Sky"
    "Building"
    "Pole"
    "Road"
    "Pavement"
    "Tree"
    "SignSymbol"
    "Fence"
    "Car"
    "Pedestrian"
    "Bicyclist"
    ];

labelIDs = camvidPixelLabelIDs();
labelDir = fullfile(outputFolder,"labels");
pxds = pixelLabelDatastore(labelDir,classes,labelIDs);


C = readimage(pxds,25);
cmap = camvidColorMap;
B = labeloverlay(I,C,"ColorMap",cmap);
%imshow(B)
pixelLabelColorbar(cmap,classes);

% resizing the data:
imageFolder = fullfile(outputFolder,"imagesResized",filesep);
imds = resizeCamVidImages(imds,imageFolder);

labelFolder = fullfile(outputFolder,"labelsResized",filesep);
pxds = resizeCamVidPixelLabels(pxds,labelFolder);

% Prepare Training and Test Sets
[imdsTrain,imdsTest,pxdsTrain,pxdsTest] = partitionCamVidData(imds ...
    ,pxds);
numTrainingImages = numel(imdsTrain.Files);
numTestingImages = numel(imdsTest.Files); % we did a 60 40 split

% Defining the training model
imageSize = [224 224];
numClasses = numel(classes);
lgraph = fcnLayers(imageSize,numClasses);

% Define backbone
backbone = resnet50('Weights','imagenet');

% dataset stats:
tbl = countEachLabel(pxds);

% Balancing the class weights:
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer("Name","labels","Classes", ...
    tbl.Name,"ClassWeights",classWeights);

% replacing the classification/last layer
lgraph = removeLayers(lgraph,"pixelLabels");
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph,"softmax","labels");

% Hyperparameters
options = trainingOptions("adam", ...
    "InitialLearnRate",1e-3, ...
    "MaxEpochs",5, ...  
    "MiniBatchSize",4, ...
    "Shuffle","every-epoch", ...
    "CheckpointPath", tempdir, ...
    "VerboseFrequency",2);

% some light data augmentation
dsTrain = combine(imdsTrain, pxdsTrain);
xTrans = [-10 10];
yTrans = [-10 10];
dsTrain = transform(dsTrain, @(data)augmentImageAndLabel(data, ...
    xTrans,yTrans));

% training model
doTraining = false;
if doTraining    
    [net, info] = trainNetwork(dsTrain,lgraph,options);
    save("FCN8sCamVid.mat","net");
end


% Preforming some predictions
type("fcn_predict.m")

% Configuration for CPU
cfg = coder.config('mex');  % Code configuration for MEX-file generation
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('mkldnn');  % Use MKL-DNN for CPU

% Correct code generation for the defined function
codegen -config cfg fcn_predict -args {ones(224,224,3,"uint8")} -report


im = imread("testImage.png");
imshow(im);

predict_scores = fcn_predict_mex(im);
[~,argmax] = max(predict_scores,[],3);


cmap = camvidColorMap();
SegmentedImage = labeloverlay(im,argmax,"ColorMap",cmap);
figure
imshow(SegmentedImage);
pixelLabelColorbar(cmap,classes);


function data = augmentImageAndLabel(data, xTrans, yTrans)
% Augment images and pixel label images using random reflection and
% translation.

for i = 1:size(data,1)
    
    tform = randomAffine2d(...
        "XReflection",true,...
        "XTranslation", xTrans, ...
        "YTranslation", yTrans);
    
    % Center the view at the center of image in the output space while
    % allowing translation to move the output image out of view.
    rout = affineOutputView(size(data{i,1}), tform, "BoundsStyle", ...
        "centerOutput");
    
    % Warp the image and pixel labels using the same transform.
    data{i,1} = imwarp(data{i,1}, tform, "OutputView", rout);
    data{i,2} = imwarp(data{i,2}, tform, "OutputView", rout);
    
end
end