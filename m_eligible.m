function [eligible] = m_eligible(set_new_tuples, m,max_equal_sensit_values)
%--------------------------------------------------------------------------
% This function verifies if the table of new tuples (T(n)-T(n-1)) satisfies
% the m-eligible condition.
%--------------------------------------------------------------------------
%---------
% Input:
%---------
% - set_new_tuples: Table of new tuples (T(n)-T(n-1)).
% - max_equal_sensit_values: The most common sensitive value.
% - m: Invariance value.
%----------
% Output:
%----------
% - eligible: A boolean flag indicating the m-eligibility status of the table.

    count_new_tuples = height(set_new_tuples);  
    % If max_equal_sensit_values is equal one then there are no identical
    % sensitive values
    if max_equal_sensit_values == 1
        eligible = false;
    % m-elegible condition: at most 1/m of the tuples in T(n)−T(n−1) have
    % an identical sensitive value.
    elseif (max_equal_sensit_values/count_new_tuples) <= (1/m)
          eligible = true;
        else
          eligible = false;
    end
end