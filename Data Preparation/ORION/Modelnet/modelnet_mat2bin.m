function modelnet_mat2bin(D,SourceFolder,DestinationFolder, angle_inc)
%%% This function loads the files in the folders one by one, and saves the bin
%%% versions to a similar subdir in the destination (tries to create it).
%%% We go folder by folder, so that Matlab doesn't need to call the SLOW
%%% fileparts function to find the folder names

%--- Generate folders list
temp_folders_list_file = 'temp_modelnet_folders.txt';
disp('Generating folders list...');
system(sprintf('wsl find %s -mindepth 3 -type d -path "*/%s/*"> %s',SourceFolder,num2str(angle_inc),temp_folders_list_file));

%--- Load the folders list
folders_list = textread(temp_folders_list_file,'%s');

%--- Loop on the folders
disp('Converting files...');
tic;
for d = 1 : numel(folders_list)
    d
    folder = folders_list{d};
    
    %--- Make the destination subfolder
    relative_folder = folder(length(SourceFolder)+2:end);
    system(sprintf('wsl mkdir %s/classes/%s -p',DestinationFolder,relative_folder));
    
    %--- Get the list of files in each folder
    files_list = dir(sprintf('%s/*mat',folder));
    
    %--- Loop on file names
     parfor f = 1 : numel(files_list)

        filename = [files_list(f).name];
        fullfilename = [SourceFolder '/' relative_folder '/' filename];
        
        %- Load the Mat file
        v = load(fullfilename);
        v = v.instance;
        
        %-- padding
        avoxel = zeros(size(v)+2*D);
        avoxel(1+D:end-D,1+D:end-D,1+D:end-D) = v;
        v = avoxel;

        %- Generate the bin filename
        dest_filename = [DestinationFolder '/classes/' relative_folder '/' filename(1:end-3) 'bin'];
        
        %- Save the bin
        fp = fopen(dest_filename,'w');
        fwrite(fp,uint16(size(v)),'uint16');
        fwrite(fp,uint8(v),'uint8');
        fclose(fp);
        
    end
end

disp('Done');
toc


