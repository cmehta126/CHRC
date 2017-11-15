FS_directory='~/project/pnc/subjects';
QC_output_directory='~/project/pnc/qc';
ENIGMA_QC_folder='~/project/chrc/qa/ENIGMA_QC';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(ENIGMA_QC_folder)
%%%%% some variable changes: %%%%%
% inDirectory: previously 'a'
% subjectID: previously 'b'
% i: previously 'x' 
 
% 'dir' will list all folders in the directory, so we need to start indexing from 3 as 1 and 2 will correspond to "." and ".." which correspond to the current directory and its parent directory 
 
inDirectory=dir(char(strcat(FS_directory,'/*')));
N=size(inDirectory,1);
 
%% if this errors out, change the N below to 3 and remove the semicolons ';' at the end of the 'T1mgz' and 'APSmgz' to check and make sure those paths exist!!
 
for i = 3:N  
    [c,subjectID,d]=fileparts(inDirectory(i,1).name); 
    try
    T1mgz=[FS_directory, '/', subjectID, '/mri/orig_nu.mgz'];
    APSmgz=[FS_directory,'/', subjectID, '/mri/aparc+aseg.mgz'];
        func_make_corticalpngs_ENIGMA_QC( QC_output_directory, subjectID, T1mgz ,APSmgz );
    end
    display(['Done with subject: ', subjectID, ': ', num2str(i-2), ' of ', num2str(N-2)]);
end

