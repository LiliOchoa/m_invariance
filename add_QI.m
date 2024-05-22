function [dataset_n_published] = add_QI(dataset_n_published, dataset_n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
column_QI = zeros(height(dataset_n_published),1);
IDs = unique(dataset_n_published.ID);
for i=1:length(IDs)
    index_elements_for_ID  = find(dataset_n_published.ID==IDs(i));
    suma = 0;
    for j=1:length(index_elements_for_ID)
        x = strcmp(dataset_n.ID,dataset_n_published.ID_real(index_elements_for_ID(j)));
        if all(x)==0 %si es una tupla falsa
            QI = randi([min(dataset_n.QI), max(dataset_n.QI)]);
        else
        QI = dataset_n.QI(x);
        end
        suma = suma + QI;
    end
    media = floor(suma/length(index_elements_for_ID));
    column_QI(index_elements_for_ID) = media;
end
 dataset_n_published = addvars(dataset_n_published, column_QI, 'After', 'ID', 'NewVariableNames', 'QI');
 %dataset_n_published = removevars(dataset_n_published, 'ID_real');
dataset_n_published = dataset_n_published(:,[2, 3,4,1]);
end