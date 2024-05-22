function [buckets, set_new_tuples, counterfeit] = balancing(buckets,set_new_tuples,m)
%---------------------------------------------------------------------------
% This function implements the balancing phase of the m-invariance algorithm. 
% We say that a bucket is balanced, if every sensitive value in its signature 
% is owned by the same number of tuples in the bucket. This phase balances 
% each bucket. 
%---------------------------------------------------------------------------
%---------
% Input:
%---------
% - buckets:        Array of buckets resulting from the divion phase.
% - set_new_tuples: Table with the set of new tuples in T(n).
% - m:              Invariance value.
%----------
% Output:
%----------
% - buckets:        An array of buckets, where each bucket are balanced.
% - set_new_tuples: Table with the set of new tuples in T(n) excluding those 
%                   employed in balancing the buckets.

% Counterfeit count
counterfeit = 0;
% Initialize delete flag
delete = false(1,numel(buckets));
    for i = 1:length(buckets)
            % Identify the keys that are unbalanced in each bucket
            bucket_keys = keys(buckets{1,i});
            bucket_values = values(buckets{1,i});
            max_values = max(cellfun(@length,bucket_values));
            if max_values == 0
                 % If the maximum value is zero, remove the bucket containing 
                 % only counterfeits
                 delete(1, i) = true;
            end
            keys_unbalanced = find(cellfun(@(x) length(x)~=max_values, bucket_values));        
            
            if ~isempty(keys_unbalanced)
            for j = 1:length(keys_unbalanced)
                values_unbalanced = bucket_values(keys_unbalanced(j));
                % Values to balance per key
                for z = length(values_unbalanced{1}) + 1 :max_values 
                    sensit_values = tabulate(categorical(set_new_tuples.Sensitive)); 
                    max_equal_sensit_values = max(cell2mat(sensit_values(:,2)));
                    if  m_eligible(set_new_tuples(1:end-1,:),m,max_equal_sensit_values)
                    % If set_new_tuples remains m-eligible after the removal of a tuple    
                        key = cell2mat(bucket_keys(keys_unbalanced(j)));
                        index = find(strcmp(set_new_tuples.Sensitive,key),1);
                            if ~isempty(index)
                            %Balance using the set_new element that has the required sensitive value
                                value = buckets{1,i}(key); 
                                value{end+1} =  set_new_tuples.ID(index);   
                                buckets{1,i}(key) = value;
                                set_new_tuples(index,:) = [];
                            else
                            %Balance using a counterfeit
                                 value = buckets{1,i}(key); % si existe un valor no sobreescribir
                                 value{end+1} =  'counterfeit';   
                                 buckets{1,i}(key) = value;
                                 counterfeit = counterfeit + 1;
                            end
                    else 
                        %Balance using a counterfeit                        
                        key = cell2mat(bucket_keys(keys_unbalanced(j)));
                        value = buckets{1,i}(key);
                        value{end+1} =  'counterfeit';   
                        buckets{1,i}(key) = value;
                        counterfeit = counterfeit + 1;
                    end
                end               
            end
            end
     end

  % Remove buckets marked for deletion  
  index_delete = delete == 1;
  buckets = buckets(~index_delete);   
 
end