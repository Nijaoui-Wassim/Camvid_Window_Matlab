outputFolder = fullfile(pwd,"CamVid");

if ~exist(outputFolder, "dir")
   
    mkdir(outputFolder)
    labelsZip = fullfile(outputFolder,"labels.zip");
    imagesZip = fullfile(outputFolder,"images.zip");   
    
    disp("Downloading 16 MB CamVid dataset labels..."); 
    websave(labelsZip, labelURL);
    unzip(labelsZip, fullfile(outputFolder,"labels"));
    
    disp("Downloading 557 MB CamVid dataset images...");  
    websave(imagesZip, imageURL);       
    unzip(imagesZip, fullfile(outputFolder,"images"));    
end