function modelnet_add_labels_to_list(source_list_file,dest_list_file,rotation_start_index,Pose_file)

list = textread(source_list_file,'%s');
Pose=importdata(Pose_file,'\t');
%parfor
parfor i = 1 : numel(list)
    % extracts from folder classname e.g bathtub and from the filename it
    % extracts the index of the rotation e.g 1
    [class_name,rotation] = modelnet_extract_classname_and_rot_from_filename(list{i});  
    % rotation-rotation_start_index to bring rotation index in [0, maxrot-1]
    % return the class label [0, maxclass-1] anc the pose label
    % if all_singlerots_to_zero=1 then fo all the classes with only 1
    % orientation it gives the the label 0 (independently from the class)
    % otherwise it gives an increasing number based on actual orientation,
    % class number and previus classes orientation labelling
    [class_label,pose_label] = modelnet_generate_class_and_pose_labels(class_name,rotation-rotation_start_index,Pose);
    list{i} = sprintf('%s %d %d %d' ,list{i},1,class_label,pose_label);
end

%--- write the modified list to the destination file
fp = fopen(dest_list_file,'wt');
fprintf(fp,'%s\n',list{:});
fclose(fp);
end


function [class_name,rotation] = modelnet_extract_classname_and_rot_from_filename(filename)

s = strsplit(filename,{'.','/'});
class_name = s{end-4};
r = strsplit(s{end-1},'_');
rotation = str2double(r(end));
end

function [class_label,pose_label] = modelnet_generate_class_and_pose_labels(class_name,rotation,Pose)

%%% Note: Class Label and Pose Label both start from 0.
classes=Pose.textdata';
nrot=Pose.data';

%--- Find the Class Label
[valid_class,class_label] = ismember(class_name,classes);
if(~valid_class)
    class_label = -1;
    pose_label = -1;
    return;
end
class_label = class_label - 1;     %to start from 0
    
%--- Find the rotation label
cr = cumsum(nrot);
cr = circshift(cr,[0,1]);
cr(1) = 0;
pose_label = cr(class_label+1) + mod(rotation,nrot(class_label+1));

end

