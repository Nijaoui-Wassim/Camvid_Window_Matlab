function pxds = resizeCamVidPixelLabels(pxds, labelFolder)
% Resize pixel label data to [224 224].

classes = pxds.ClassNames;
labelIDs = 1:numel(classes);
if ~exist(labelFolder, 'dir')
    mkdir(labelFolder)
else
    pxds = pixelLabelDatastore(labelFolder, classes, labelIDs);
    return; % Skip if images already resized
end

reset(pxds)
while hasdata(pxds)
    % Read the pixel data.
    [C, info] = read(pxds);
    
    % Convert from categorical to uint8.
    L = uint8(C{1});
    
    % Resize the data. Use 'nearest' interpolation to
    % preserve label IDs.
    L = imresize(L, [224 224], 'nearest');
    
    % Write the data to disk.
    [~, filename, ext] = fileparts(info.Filename);
    fullPath = fullfile(labelFolder, [filename ext]);  % Correct way to build the path
    imwrite(L, fullPath, 'png');  % Specify format if needed
end

pxds = pixelLabelDatastore(labelFolder, classes, labelIDs);
end
