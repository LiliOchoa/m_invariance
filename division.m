function [buckets] = division(set_comun_tuples,dataset_n_1_published)
%---------------------------------------------------------------------------
% This function implements the division phase of the m-invariance algorithm. 
% This phase simply partitions set_comun_tuples table into several buckets, 
% such that each bucket contains only the tuples with the same signature.
%---------------------------------------------------------------------------
%---------
% Input:
%---------
% - set_comun_tuples:      Table of comun tuples between T(n) and T(n-1) 
% - dataset_n_1_published: Table T*(n-1).
%----------
% Output:
%----------
% - buckets: An array of buckets, where each bucket exclusively contains 
%            tuples with the same signature.

%Create a bucket for each signature
    ID_groups = unique(dataset_n_1_published.ID);
    buckets = cell(1, numel(ID_groups));
    parfor i = 1:numel(ID_groups)
        % Filter the dataset to get only the signature corresponding to a specific ID
        signature_per_group = dataset_n_1_published(dataset_n_1_published.ID == ID_groups(i), 3); 
        keys = table2cell(signature_per_group); 
        % Initialize and save the map container for this group
        bucket = containers.Map(keys, cell(size(keys)));
        buckets{i} = bucket;
    end

% Locate set_common_tuples in the corresponding buckets
    % create a new table of set_comun_tuples that has the relationship real ID, 
    % published ID and sensitive value. Operate on this table to locate the real
    % IDs in the buckets
    index_comun_tuples = ismember(dataset_n_1_published.ID_real,set_comun_tuples.ID);
    set_comun_tuples = dataset_n_1_published( index_comun_tuples,[1,3,4]);
 
    tuple_ID = unique(set_comun_tuples.ID);
     for i = 1:length(tuple_ID)
         index = find(set_comun_tuples.ID == tuple_ID(i));
         for j = 1:length(index)
             key = cell2mat(set_comun_tuples.Sensitive(index(j)));
             bucket_values = buckets{1,tuple_ID(i)}(key); 
             value = set_comun_tuples.ID_real(index(j));
             bucket_values{end+1} = value{1}; 
             buckets{1,tuple_ID(i)}(key) = bucket_values;
         end
     end

% Group the buckets with the same signature  
    % Initialize delete flag
    delete_flag = false(1,numel(buckets));    
    
    % Sort keys for each bucket before comparison
    sorted_keys = cell(1, numel(buckets));    
    for i = 1:numel(buckets)
        sorted_keys{i} = sort(buckets{i}.keys);
    end
    
    %Find the buckets with the same keys
    for i = 1:numel(buckets)
        bucket_keys_i = sorted_keys{i};
         for j = i+1:numel(buckets)
             bucket_keys_j = sorted_keys{j};
             if isequal(bucket_keys_i, bucket_keys_j)
             % If buckets i and j share identical keys
                % flag bucket j for deletion
                delete_flag(1, j) = true; 
                bucket_keys = bucket_keys_i;
                %Transfer each value associated with each of the keys to bucket i
                for z = 1:numel(bucket_keys)
                    key = bucket_keys(z);
                    move_values = buckets{1,j}(key{1});
                    if ~isempty(move_values)
                        for y=1:numel(move_values)
                            bucket_values = buckets{1,i}(key{1}); 
                            bucket_values{end+1} = move_values{y}; 
                            buckets{1,i}(key{1}) = bucket_values;
                
                        end
                    end
                end
            end
         end
    end

    % Remove buckets marked for deletion
    index_delete = delete_flag == 1;
    buckets = buckets(~index_delete);
end