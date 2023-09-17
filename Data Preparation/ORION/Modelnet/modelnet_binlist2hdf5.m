function modelnet_binlist2hdf5(DestinationFolder,Pose_plan,angle_inc)

Pose_file=['../poseplans/' Pose_plan '.txt'];
if ~exist(strcat(DestinationFolder,Pose_plan,'/'), 'dir')
    mkdir(strcat(DestinationFolder,Pose_plan,'/'));
end
copyfile(Pose_file,strcat(DestinationFolder,Pose_plan,'/'));

%% ---- Create the lists
rotation_start_index = 1; %this is the original Shapenet convention
lists_dir = sprintf('%s/%s',DestinationFolder,Pose_plan);
alllist_file = sprintf('%s/all.txt',lists_dir);

system(sprintf('wsl find %s -path "*/%s/*" -iname ''*.%s'' | wsl sort -V > %s', DestinationFolder,num2str(angle_inc),'bin',alllist_file));
%
modelnet_add_labels_to_list(alllist_file,alllist_file,rotation_start_index,Pose_file);

% preparing training validation test lists
for set = {'train','test','validation'}
    dest_filename = sprintf('%s/%s.txt',lists_dir,set{1});
    system(sprintf('wsl grep ''/%s/'' %s > %s',set{1},alllist_file,dest_filename));
end
 
%% --- Create some special HDF5 datasets
binlist_to_hdf5([lists_dir '/train.txt'],[DestinationFolder '/' Pose_plan '/hdf5/train/train.hdf5'],[DestinationFolder '/' Pose_plan '/hdf5/train/train.txt'],1000);
binlist_to_hdf5([lists_dir '/validation.txt'],[DestinationFolder '/' Pose_plan '/hdf5/validation/validation.hdf5'],[DestinationFolder '/' Pose_plan '/hdf5/validation/validation.txt'],1000);
binlist_to_hdf5([lists_dir '/test.txt'],[DestinationFolder '/' Pose_plan '/hdf5/test/test.hdf5'],[DestinationFolder '/' Pose_plan '/hdf5/test/test.txt'],1000);