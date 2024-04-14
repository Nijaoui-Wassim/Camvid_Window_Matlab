function imds = resizeCamVidImages(imds, imageFolder)
% Resize images to [224 224].

if ~exist(imageFolder, 'dir')
    mkdir(imageFolder)
else
    imds = imageDatastore(imageFolder);
    return; % Skip if images already resized
end

reset(imds)
while hasdata(imds)
    % Read an image.
    [I, info] = read(imds);

    % Resize image.
    I = imresize(I, [224 224]);

    % Write to disk.
    [~, filename, ext] = fileparts(info.Filename);
    fullPath = fullfile(imageFolder, [filename ext]);  % Correct way to build the path
    imwrite(I, fullPath);
end

imds = imageDatastore(imageFolder);
end
