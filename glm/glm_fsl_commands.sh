
e=d002; m=fa; em=$e-$m
c=1

for ((i=3;i<4;i++)); do
  fslmaths fsl-${em}_glm_varcope_tstat$c.nii.gz -sqrt -mas $mask _a.nii.gz
  fslmaths fsl-${em}_glm_cope_tstat$c.nii.gz -div _a.nii.gz -mas $mask _a.nii.gz _${em}_tstat$c.nii.gz
done



