function [dataset] = import_dataset(filename)
%--------------------------------------------------------------------------------
% This function reads data from an .xlsx file and returns a table with those data
%--------------------------------------------------------------------------------
%---------
% Input:
%---------
% - filename: Name of the .xlsx file containing the data to be read.
%
% The file is expected to have the following columns, in the same order
% and the same name as described:
% - 'ID': Unique identifier for each record or for each groups of QIs().
% - 'QI': Quasi-identifier attribute ()
% - 'Sensitive': Private data to be protected ().
%----------
% Output:
%----------
% - data_table: Table with the data read from the .xlsx file.
%----------------
% Usage example:
%----------------
% dataset = import_dataset('data.xlsx');
%
    dataset = readtable(filename);

end

