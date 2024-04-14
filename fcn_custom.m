function lgraph = fcn_custom(imageSize, numClasses, windowSize, varargin)
    % Check for deep learning toolbox.
    vision.internal.requiresNeuralToolbox(mfilename);

    iCheckIfVGG16AddOnIsAvailable()

    narginchk(3,inf);

    type = parseInputs(imageSize, numClasses, varargin{:});

    switch type
        case '32s'        
            lgraph = vision.internal.cnn.fcn32sLayers(windowSize, numClasses);
        case '16s'
            lgraph = vision.internal.cnn.fcn16sLayers(windowSize, numClasses);
        case '8s'
            lgraph = vision.internal.cnn.fcn8sLayers(windowSize, numClasses);        
    end
end

function type = parseInputs(imageSize, numClasses, varargin)
    p = inputParser();
    p.addParameter('Type', '8s');

    p.parse(varargin{:});

    % imageSize
    validateattributes(imageSize, {'numeric'}, ...
        {'numel', 2, 'real', 'positive', 'finite', 'nonsparse', 'integer', '>=', 224}, ...
        mfilename, 'imageSize');

    % numClasses
    validateattributes(numClasses, {'numeric'}, ...
        {'scalar', 'real', 'positive', 'finite', 'nonsparse', 'integer', '>' 1}, ...
        mfilename, 'numClasses');

    % type
    type = validatestring(p.Results.Type, {'32s', '16s', '8s'}, mfilename, 'type');
end

function iCheckIfVGG16AddOnIsAvailable()
    breadcrumbFile = 'nnet.internal.cnn.supportpackages.IsVGG16Installed';
    fullpath = which(breadcrumbFile);

    if isempty(fullpath)
        name = 'Deep Learning Toolbox Model for VGG-16 Network';
        basecode = 'VGG16';
        error(message('vision:semanticseg:missingVGGAddon', name, basecode));
    end
end
