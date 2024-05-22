function [buckets] = splitting(buckets,dataset_n)
%---------------------------------------------------------------------------
% This function implements the split phase of the m-invariance algorithm. 
% After this phase, each bucket will contain x tuples, with x representing 
% the number of sensitive values in the signature.
%---------------------------------------------------------------------------
%---------
% Input:
%---------
% - buckets:        Array of buckets resulting from previous phases.
% - dataset_n:      Dataset table for re-publication (T(n))
%----------
% Output:
%----------
% - buckets:        An array of buckets after split phase.

% Arrange dataset_n based on the QI value. This ensures that tuples are 
% grouped by proximity during the split phase.
% We have made the assumption of including 'counterfeit' as the initial value.
dataset_n(end + 1, :) = {'counterfeit', 0,'counterfeit'};
dataset_n             = sortrows(dataset_n, 'QI');

    for i = 1:length(buckets)
        bucket = buckets{1,i};
        bucket_values = values(bucket);
        % Each bucket is split into num_tuples_per_signature QI groups.
        num_tuples_per_signature = length(bucket_values{1,1});
        
        % If num_tuples_per_signature = 1, the split phase does not apply
        if num_tuples_per_signature > 1            
            % Split
            for j = 2:num_tuples_per_signature
                % Create a new bucket and define the keys
                bucket_keys = keys(bucket);
                new_bucket = containers.Map(bucket_keys, cell(size(bucket_keys)));
                for z = 1:length(bucket_keys)
                    % Remove 'cell' type from values
                    values_per_key = bucket_values{1,z}; 
                    cell_indices = cellfun(@iscell, values_per_key);
                    values_per_key(cell_indices) = cellfun(@(x) x{1}, values_per_key(cell_indices), 'UniformOutput', false);
                    % Assign the value to each key based on the order in dataset_n
                    [~, indices_orden] = ismember(values_per_key, dataset_n.ID);
                    [~, sorted_indices] = sort(indices_orden);
                    values_per_key = values_per_key(sorted_indices);
                    key = bucket_keys{1,z};                     
                    new_bucket(key)=  values_per_key{1,j};
                    bucket(key) =  values_per_key{1,1};               
                end
               % Locate the splited bucket in the array of buckets
               buckets{1,i} = bucket;
               buckets{end+1} =  new_bucket;

            end    
        end
   end
end