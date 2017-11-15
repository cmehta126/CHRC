addpath('~/project/chrc/qa/ENIGMA_QC/')
cd ~/project/pnc/mri/subjects
PWD_QC_OUTPUT = '~/scratch60/pnc/mri/qa/internal_surface';
PWD_FSURF_SUBJECT = '~/project/pnc/mri/subjects';
a = dir(char(strcat(PWD_FSURF_SUBJECT, '/mri/*')));

fn0 = '/ysm-gpfs/scratch60/cm953/id_is_remaining.txt';
a = num2str(importdata(fn0));

for x = 1:size(a,1)
	%b = fileparts(a(x,1).name);
	b = a(x,:)
	try
		b_orig = [PWD_FSURF_SUBJECT, '/', b, '/mri/orig.mgz'];
		b_aseg = [PWD_FSURF_SUBJECT, '/', b, '/mri/aparc+aseg.mgz'];
		func_make_corticalpngs_ENIGMA_QC(PWD_QC_OUTPUT, b, [PWD_FSURF_SUBJECT, '/', b, '/mri/orig.mgz'], [PWD_FSURF_SUBJECT, '/', b, '/mri/aparc+aseg.mgz'])
	end
	display(['Done with subject: ', b, ': ', num2str(x-2), ' of ', num2str(size(a,1)-2)]);
end

