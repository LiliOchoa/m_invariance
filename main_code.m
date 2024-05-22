%--------------------------------------------------------------------------
%                          m-invariance algorithm 
%--------------------------------------------------------------------------
%---------
% Inputs:
%---------
% - n:       Publication number (n => 1).
% - m:       Invariance value (m > 1).
% - T(n):    Dataset table for re-publication (.xlsx file).
% - T(n-1):  Last original version of the dataset table (.xlsx file).
% - T*(n-1): Last published version of the dataset table (.xlsx file).
%
% The tables are expected to have the following columns, in the same order
% and the same name as described:
% - 'ID': Unique identifier for each record or for each groups of QIs().
% - 'QI': Quasi-identifier attribute ()
% - 'Sensitive': Private data to be protected ().
%----------
% Outputs:
%----------
% - T*(n): Public version of the dataset table T(n)(.xlsx file).
%
% The output table will have the following columns, in the same order as 
% described:"
% - 'ID': Unique identifier for each groups of QIs().
% - 'QI': Quasi-identifier attribute ()
% - 'Sensitive': Private data to be protected ().
% - 'ID-real': Unique identifier for each record ().
%
% Please consider that for a more precise analysis of the scope of this 
% algorithm, the implementation relies on the relationship between ID_real 
% and ID being known. For this reason, by default, ID_real is a column in 
% the output table T*(n). However, this is not a public value. To remove it, 
% simply uncomment line 22 of the Add_QI function. Otherwise, to establish 
% this relationship, each tuple of T(n-1) and T*(n-1) must have the same 
% position in both tables (uncomment line 81 of main_code), with the 
% counterfeits at the end (e.g: if Bob is the fifth tuple in T(n-1), he must 
% also be the fifth tuple in % T*(n-1)).

fprintf(['-------------------------------------------------------------\n' ...
         '             m-invariance algorithm \n' ...
         '-------------------------------------------------------------\n'])
fprintf('User, please enter the following input values:\n')
n                        = input('Publication number (n) = ');
m                        = input('Invariance value   (m) = ');

if n == 0 || m == 0
    fprintf('Invalid value for n or m (must be != 0)');
    quit
end

%First publication (required T(1))
if n == 1
    fprintf('User, please enter the filename (.xlsx file) containing the following table.\n')
    fprintf("Example: 'table1.xlsx'\n") 
    dataset_n               = import_dataset(input('T(1):    '));        
    sensit_values           = tabulate(categorical(dataset_n.Sensitive)); 
    max_equal_sensit_values = max(cell2mat(sensit_values(:,2)));
    eligible                = m_eligible(dataset_n,m,max_equal_sensit_values);
    
    %is m-eligible?
    if eligible == false
        fprintf(['The re-publication is not permit.\nAt most 1/m of the new ' ...
               'tuples in the dataset must have an identical sensitive value']);
        return;
    else 
     buckets                   = {};
     buckets                   = assignment(buckets,dataset_n,m);
     buckets                   = splitting(buckets, dataset_n); 
     dataset_n_published       = buckets2table(buckets);
     dataset_n_published       = add_QI(dataset_n_published, dataset_n);

     end

% n-publication (n>1) (required T(n-1), T*(n-1), T(n))     
else 
    fprintf('User, please enter the filenames (.xlsx file) containing the following tables.\n') 
    fprintf("Example: 'table1.xlsx'\n") 
    dataset_n               = import_dataset(input('T(n):    '));           
    dataset_n_1             = import_dataset(input('T(n-1):  '));          
    dataset_n_1_published   = import_dataset(input('T*(n-1): ')); 
    dataset_n_1_published   = addvars(dataset_n_1_published, dataset_n_1.ID, 'NewVariableNames', 'ID_real');
    
    set_new_tuples   = setdiff(dataset_n, dataset_n_1);   % S- = T(n)-T(n-1)
    set_comun_tuples = setdiff(dataset_n, set_new_tuples);% S∩ = T(n)∩T(n-1)
    
    sensit_values           = tabulate(categorical(set_new_tuples.Sensitive)); 
    max_equal_sensit_values = max(cell2mat(sensit_values(:,2)));    
    eligible = m_eligible(set_new_tuples,m,max_equal_sensit_values);

    %is m-eligible?
    if eligible == false
        fprintf(['The re-publication is not permit.\nAt most 1/m of the new ' ...
                'tuples in the dataset must have an identical sensitive value']);
        return;
    else 
     buckets                                 = division(set_comun_tuples, dataset_n_1_published);
     [buckets, set_new_tuples, counterfeits] = balancing(buckets,set_new_tuples,m);
     buckets                                 = assignment(buckets,set_new_tuples,m);
     buckets                                 = splitting(buckets, dataset_n); 
     dataset_n_published                     = buckets2table(buckets);
     dataset_n_published                     = add_QI(dataset_n_published, dataset_n);
    
    end
end










