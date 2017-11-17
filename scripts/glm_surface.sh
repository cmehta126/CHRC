# GLM Surface scripts


for aMask in "cat ${scriptpath}/FINDlab90.txt"; do echo "Writing ROI time course for $aMask"; for aSub in "cat ~/tx.txt"
do 
        echo "Writing ROI time course for $aSub";
        TS='3dmaskave -quiet -mask ${studypath}/masks/FINDlab90/${aMask}_TAL_3mm+tlrc;          ${subjectpath}/${aSub}/${aSub}.rest_BP_3mm/errts.${aSub}.fanaticor+tlrc';
        echo $aSub $TS >> ~/ty.txt;
done
done
