#!/bin/bash
SID=$1
Q=$PNC_SUBJECTS/${SID}/${SID}.BOLD_emotionid/stats.${SID}_REML+tlrc
R1=$PNC_SUBJECTS/${SID}/${SID}.BOLD_emotionid/stats.${SID}_REML_all_emotions.nii
R2=$PNC_SUBJECTS/${SID}/${SID}.BOLD_emotionid/stats.${SID}_REML_all_emotions_no_deriv.nii
R3=$PNC_SUBJECTS/${SID}/${SID}.BOLD_emotionid/stats.${SID}_REML_all_emotions-neutral_no_deriv.nii

#3dcalc -a "${Q}[sad#0_Coef]" -b "${Q}[angry#0_Coef]" -c "${Q}[fear#0_Coef]" -d "${Q}[neutral#0_Coef]" -e "${Q}[happy#0_Coef]" -f "${Q}[sad#1_Coef]" -g "${Q}[angry#1_Coef]" -h "${Q}[fear#1_Coef]" -i "${Q}[neutral#1_Coef]" -j "${Q}[happy#1_Coef]" -expr 'a+b+c+d+e+f+g+h+i+j' -prefix $R1
#3dcalc -a "${Q}[sad#0_Coef]" -b "${Q}[angry#0_Coef]" -c "${Q}[fear#0_Coef]" -d "${Q}[neutral#0_Coef]" -e "${Q}[happy#0_Coef]" -expr 'a+b+c+d+e' -prefix $R2
#3drefit -sublabel 0 "all_emotions" $R1
#3drefit -sublabel 0 "all_emotions_no_deriv" $R2


3dcalc -a "${Q}[sad#0_Coef]" -b "${Q}[angry#0_Coef]" -c "${Q}[fear#0_Coef]" -d "${Q}[neutral#0_Coef]" -e "${Q}[happy#0_Coef]" -expr 'a+b+c-4*d+e' -prefix $R3
3drefit -sublabel 0 "all_emotions_no_deriv" $R3

