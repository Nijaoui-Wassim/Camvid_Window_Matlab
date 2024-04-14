classdef InMemoryDatastore < matlab.io.Datastore & matlab.io.datastore.MiniBatchable
    properties
        Images
        Labels
        MiniBatchSize
        CurrentIndex
    end

    properties (SetAccess = protected)
        NumObservations  % Total number of observations in the datastore
    end

    methods
        function ds = InMemoryDatastore(images, labels, miniBatchSize)
            ds.Images = images;
            ds.Labels = labels;
            ds.MiniBatchSize = miniBatchSize;
            ds.CurrentIndex = 1;
            ds.NumObservations = size(images, 4);  % Assuming last dimension indexes the observations
        end

        function [data, info] = read(ds)
            % Reads mini-batches of data
            endIndex = min(ds.CurrentIndex + ds.MiniBatchSize - 1, ds.NumObservations);
            batchIndices = ds.CurrentIndex:endIndex;
            
            % Extract images and labels for the batch
            images = ds.Images(:,:,:,batchIndices);
            labels = ds.Labels(:,:,:,batchIndices);

            % Package the data into a table
            data = table({images}, {labels}, 'VariableNames', {'input', 'response'});
            info = struct('BatchSize', numel(batchIndices));
            ds.CurrentIndex = endIndex + 1;
        end
        
        function reset(ds)
            % Resets to the beginning of the data
            ds.CurrentIndex = 1;
        end
        
        function tf = hasdata(ds)
            % Returns true if more data is available
            tf = ds.CurrentIndex <= ds.NumObservations;
        end
        
        function frac = progress(ds)
            % Returns the progress as a fraction between 0 and 1
            frac = (ds.CurrentIndex - 1) / ds.NumObservations;
        end
    end
end
