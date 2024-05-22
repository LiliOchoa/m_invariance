function [buckets] = assignment(buckets, set_new_tuples, m)
%---------------------------------------------------------------------------
% This function implements the assignment phase of the m-invariance algorithm. 
% In this phase, the remaining tuples in set_new_tuples are allocated to 
% buckets based on various rules.
%---------------------------------------------------------------------------
%---------
% Input:
%---------
% - buckets:        Array of buckets resulting from previous phases or in 
%                   case of the first publication, an empty array.
% - set_new_tuples: Table with the set of new tuples in T(n). For n-publication 
%                   where n > 1, it includes modifications from previous phases.
% - m:              Invariance value.
%----------
% Output:
%----------
% - buckets:        An array of buckets after assigment phase.

    sensitive_values =  tabulate(categorical(set_new_tuples.Sensitive));
    % Number of distinct sensitive values in set_new_tuples
    lambda = height(sensitive_values); 
    
    while ~isempty(set_new_tuples)    
          
        % Sum of ni from i=1 to lambda, which is equivalent height(set_new_tuples) 
        gamma = height(set_new_tuples);

        % Obtain n_1, n_2, ..., n_lambda where n_i (1 < i < lambda) is the
        % number of tuples having the i-th sensitive value v_i
        sensitive_values =  tabulate(categorical(set_new_tuples.Sensitive));
        % Sorted  in descending order 
        sensitive_values = sortrows(sensitive_values, -2);
        n_i = cell2mat(sensitive_values(:,2)');  

        % When removing elements from the table, if all elements with the
        % same sensitive value are moved, they should be counted as n_i = 0
        if length(n_i) < lambda 
            celda = zeros(1,lambda - length(n_i));            
            n_i = [n_i, celda];
        else
        end

        beta = m;
        n_1 = n_i(1);
        alpha = [];
        
        % Find the largest positive integer alpha satisfying Inequalities 
        while isempty(alpha)
        
            n_beta = n_i(beta) ;
            n_beta_plus_1 = n_i(beta + 1);

            if m == beta && n_1 <= gamma/m 
            % Inequalities when m = beta
             alpha_2 = (gamma - m*n_beta_plus_1)/beta;
             alpha_3 = n_beta;
             if alpha_2 >= 1 && alpha_3 >= 1
                alpha = floor(min(alpha_2,alpha_3)); 
             else
                %if alpha does not exist
                beta = beta + 1; 
             end

            else
            % Inequalities when m != beta
             alpha_1 = (m*n_1-gamma)/(m-beta);
             alpha_2 = (gamma - m*n_beta_plus_1)/beta;
             alpha_3 = n_beta;  
             if alpha_2 >= 1 && alpha_3 >= 1 && alpha_1 <= floor(min(alpha_2, alpha_3))  
                 alpha = floor(min(alpha_2, alpha_3));
             else
                 %if alpha does not exist
                 beta = beta + 1;
             end
            end      
       end

      % Signature with sensitive values {v1, ..., vβ}
      new_signature = sort(sensitive_values(1:beta,1));
      new_signature = new_signature';
      % Bucket for the assignment
      bucket_assignment = [];
      
      if isempty(buckets)
      % In the case of the 1st-publication where the buckets are empty, 
      % proceed to create a new bucket directly for the assignment.
         assignment = 0;
         bucket_assignment = containers.Map(new_signature, cell(size(new_signature)));
         
      else    
      % Find a bucket whose signature is {v1, ..., vβ} or create bucket if 
      % it does not exist yet    
          for i = 1:length(buckets) 
                bucket_keys = sort(keys(buckets{1,i}));
                if isequal(bucket_keys,new_signature)
                    bucket_assignment = buckets{1,i}; 
                    assignment = i; % Flag to indicate the position of the assigned bucket, 
                                    % which is set to 0 if a new bucket is created
                    break;
                end
          end
            
          if isempty(bucket_assignment)
               assignment = 0;
               bucket_assignment = containers.Map(new_signature, cell(size(new_signature))); 
               
          end
      end
          
      % For i = 1 to beta, randomly move alpha tuples with value v_i 
      % from set_new_tuple to bucket_assignment
      for i= 1:beta
          key     = cell2mat(new_signature(i));      
          index_new_values  = find(strcmp(set_new_tuples.Sensitive,key));
          for i=1:alpha
              new_values  = set_new_tuples.ID(index_new_values(i));              
              value = bucket_assignment(key); 
              value{end+1} =  new_values;   
              bucket_assignment(key) = value;         
          end
          % Remove the assigned tuple from set_new_tuple table
          set_new_tuples(index_new_values(1:alpha),:)=[];
      end
        
      % Locate the bucket_assignment in the array of buckets
      if assignment == 0
        buckets{end+1} =  bucket_assignment;
      else
      buckets{1,assignment} = bucket_assignment;
      end
     
    end
end

  
      
   

