% Michael Wozny 11.06.2020 - subTOM_idx.m
% 
% Return a table of the tomograms with models with crop points.
% Create a new column to number these tomograms in ascending order of their
% respective Dynamo index, this will be the subTOM index used for symbolic
% links to ####.rec

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write to table to .csv as:
tableName = 'filesCropSubTOM.csv';

% Exclude any tomograms by Dynamo index through excludeTS:
excludeTS = {32,50};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dcmodels('Cat');
tomogramList = {,};

% paths to tomogram file and model, tomogramList columns 1 & 2
for k=1:length(files)
    model = dread(char(files(k)));
    tomogram = model.cvolume.fullFileName();
    tomogramList{k,1} = tomogram;
    tomogramList{k,2} = files(k);
end

% date from the tomogram file path, tomogramList column 3
for k=1:length(tomogramList)
    file = tomogramList{k,1};
    [pathstr,name,ext] = fileparts(file);
    tomogramList{k,3} = pathstr(57:64);
end

% tomogram filename from the path, tomogramList column 4
for k=1:length(tomogramList)
    file = tomogramList{k,1};
    [pathstr,name,ext] = fileparts(file);
    tomogramList{k,4} = name;
end

% volume names from the model file paths
for k=1:length(tomogramList)
    file = char(tomogramList{k,2});
    a = extractBetween(file,"/","/");
    for kk=2:length(a)
        b(kk-1,1) = extractBetween(file,a(kk-1),a(kk));
    end

    for kk=1:length(b)
        b(kk,1) = extractBetween(b{kk},"/","/");
    end

    c = [a;b];
    cidx = [,];
    for kk=1:length(c)
        cidx(kk) = contains(c{kk},"volume");
    end

    for kk=1:length(cidx)
        if cidx(kk) == 1
            tomogramList{k,5} = c(kk);
        end
    end
end

% keep just the index number from volume names, tomogramList column 5
for k=1:length(files)
    idx = char(extractAfter(tomogramList{k,5},'_'));
    tomogramList{k,5} = idx;
end

% number of dipoles in model, tomogramList column 6
for k=1:length(files)
    model = dread(char(files(k)));
    cropPoints = length(model.dipoles);
    tomogramList{k,6} = cropPoints;
end

% make table, label columns
tomogramList = cell2table(tomogramList);
tomogramList.Properties.VariableNames{'tomogramList1'}='volumePath';
tomogramList.Properties.VariableNames{'tomogramList2'}='modelPath';
tomogramList.Properties.VariableNames{'tomogramList3'}='date';
tomogramList.Properties.VariableNames{'tomogramList4'}='label';
tomogramList.Properties.VariableNames{'tomogramList5'}='index';
tomogramList.Properties.VariableNames{'tomogramList6'}='cropPoints';

% make list of tomos with models containing croppoints
filesCrop = {};
for k=1:height(tomogramList)
    if contains(tomogramList{k,4},'bin2') == 1;
        file = tomogramList(k,:);
        file.cropPoints = num2cell(file.cropPoints);
        file = table2array(file);
        filesCrop = vertcat(filesCrop,file);
    end
end

croptable = [];

% grep crop points in models
for k=1:length(filesCrop)
    model = dread(char(filesCrop{k,2}));
    t = model.grepTable;
    croptable = vertcat(croptable,t);
end

% create subTOM index based upon the order of tomos in filesCrop
idxSubTOM = {};
idx = {};
idx{1} = 0;
for k=1:length(filesCrop)
    idxDynamo = str2double(filesCrop{k,5});
    idx{k} = idx{k} + 1;
            if k < length(filesCrop)
                idx{k+1} = idx{k};
            end
    idxSubTOM{k} = idx{k};
    for kk=1:length(excludeTS)
        if idxDynamo == excludeTS{1,kk}
            disp([int2str(idxDynamo),' was excluded.']);
            idxSubTOM{k} = 0;
            idx{k+1} = idx{k-1};
        end
    end
end

% convert filesCrop to table and update with idxSubTOM values in column 7
filesCrop = array2table(filesCrop);
idxSubTOM = cell2table(transpose(idxSubTOM));
filesCropSubTOM = [filesCrop,idxSubTOM];
filesCropSubTOM.Properties.VariableNames{'filesCrop1'}='volumePath';
filesCropSubTOM.Properties.VariableNames{'filesCrop2'}='modelPath';
filesCropSubTOM.Properties.VariableNames{'filesCrop3'}='date';
filesCropSubTOM.Properties.VariableNames{'filesCrop4'}='label';
filesCropSubTOM.Properties.VariableNames{'filesCrop5'}='idxDynamo';
filesCropSubTOM.Properties.VariableNames{'filesCrop6'}='cropPoints';
filesCropSubTOM.Properties.VariableNames{'Var1'}='idxSubTOM';
writetable(filesCropSubTOM, tableName,'Delimiter','tab');