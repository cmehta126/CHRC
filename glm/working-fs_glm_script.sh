eval $matlab_load
matlab -nodisplay -nojvm


addpath('~/project/chrc/glm/')
cd '~/project/fs_glm'
CVAR = {'int', 'age', 'sex', 'tiv', 'pc1', 'pc2', 'pe', 'age_pe', 'tex', 'age_tex'};
prefix='x003_hemi.lh.area.fwhm10';
fnX='x003_design.txt';
Con_matrix = zeros(1,10);
Con_matrix(1,7) = 0; Con_matrix(1,4) = 1;
Contrast_name = 'ttest_tiv'; 
nPerm = 10;
x = run_fs_glm(prefix, fnX, Con_matrix, Contrast_name, nPerm); max(x)

SIG=observed_sig-ttest_PExAge.mgh; thmin=2;
mri_surfcluster --in $SIG --subject fsaverage --hemi lh --annot aparc --thmin $thmin --no-adjust --sign abs  --sum tmp.txt

SIG=observed_sig-ftest_PE.mgh; thmin=2
mri_surfcluster --in $SIG --subject fsaverage --hemi lh --annot aparc --fdr 0.05 --no-adjust --sign pos  --sum tmp.txt


SIG=observed_sig-ttest_tiv.mgh; thfdr=0.05;
mri_surfcluster --in $SIG --subject fsaverage --hemi lh --annot aparc --fdr 0.05 --sign abs  --sum tmp.txt



DIR=/ysm-gpfs/home/cm953/project/fs_glm/GLM_x003_hemi.lh.area.fwhm10/perm_ttest_PExAge
thmin=2
for ((j=1;j<11;j++)); do
  FN=${DIR}/perm-${j}.mgh
  V=$(mri_surfcluster --in $FN --subject fsaverage --hemi lh --thmin $thmin --sign abs | grep 'Max cluster size' | awk '{print $4}');
  echo $V
done





j=7;
addpath('~/project/chrc/glm/')
cd '~/project/fs_glm'
CVAR = {'int', 'age', 'sex', 'tiv', 'pc1', 'pc2', 'pe', 'age_pe', 'tex', 'age_tex'};
prefix='x003_hemi.lh.area.fwhm10';
fnX='x003_design.txt';
Con_matrix = zeros(1,10);
Con_matrix(1,j) = 1; Contrast = strjoin(CVAR(1,j)); nPerm = 1000;
x = run_fs_glm(prefix, fnX, Con_matrix, Contrast, nPerm)









thresh=2;
fn_perm=perm_sig.mgh
for ((j=0;j<10;j++)); do
  VA=($(mri_surfcluster --in $fn_perm --frame $j --subject fsaverage --hemi lh --thmin $thresh --sign abs | grep "Max cluster size" | awk '{print $4}'))
  echo $VA  
done
  
  VA=($(mri_surfcluster --in tmp_perm.mgh --frame $a --subject fsaverage --hemi lh --thmin 2 --sign abs | grep "Max cluster size" | awk '{print $4}'))

