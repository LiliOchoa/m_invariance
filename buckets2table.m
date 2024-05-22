function [dataset_n_published] = buckets2table(buckets)

nombres_columnas = {'ID_real', 'ID', 'Sensitive'};
 tipos_de_datos = {'cell', 'double', 'cell'};
dataset_n_published = table('Size', [0, numel(nombres_columnas)], 'VariableNames', nombres_columnas, 'VariableTypes', tipos_de_datos);

for j = 1:length(buckets)
    bucket = buckets{1,j};   
    
    bucket_values = values(bucket);
    bucket_keys = keys(bucket);
    
    % Nombres de las columnas
    
    
    % Tipos de datos (puedes usar 'double', 'cell' u otros tipos según tus necesidades)
    
    
    % Crear una tabla vacía con nombres de columnas y tipos de datos
    
    
    
    
    for i = 1: numel(bucket_values)
        nueva_fila =[];
        %if class(bucket_values{i}) == 'cell' 
 %           if class(bucket_values{i}{1}) == 'cell' && %% %%%% implementar antes de split
             if length(bucket_values{i}) > 1 && all(class(bucket_values{i}) == 'cell')
                 for z=1:length(bucket_values{i}) 
                    if class(bucket_values{i}{z}) == 'cell'
                         nueva_fila{1} = bucket_values{i}{z}{1};
                    else
                        nueva_fila{1} = bucket_values{i}{z};
                    end
                    nueva_fila{2} = j;
                    nueva_fila{3} = bucket_keys{i};
                    dataset_n_published = [dataset_n_published; nueva_fila];
                 end
             else   
             %bucket_values{i} = bucket_values{i};
                 if class(bucket_values{i}) == 'cell'
                    nueva_fila{1} = bucket_values{i}{1};
                 else
                    nueva_fila{1} = bucket_values{i};
                 end
                     nueva_fila{2} = j;
                     nueva_fila{3} = bucket_keys{i};
                     dataset_n_published = [dataset_n_published; nueva_fila];  
                 
            end
            
            
        %end
        
    end
end
end