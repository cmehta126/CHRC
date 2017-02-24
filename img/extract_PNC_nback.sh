#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

SID=$1
PWD_RAW_DATA=$2
PWD_WORK=$3
PWD_NIFTI=$4
PWD_DCM2NII=$5

# Extract tar.gz file
run_extraction_to_nifti () {
	# PWD_DCM2NII, PWD_NIFTI, SID, MODE=$2, SHORT_NAME;
	PWD_NIFTI=$1
	PWD_DCM2NII=$2
	SID=$3
	MODE=$4
	SHORT_NAME=$5
	LOG_NAME=$6
	
	FN_RAW_DATA=${SID}_1.tar.gz
	EXTRACT_SID_MODE=$(tar -xf $FN_RAW_DATA ${SID}/${MODE}/)$?
	if (($EXTRACT_SID_MODE == 0)); then
		${PWD_DCM2NII}./dcm2nii -a y -e n -d n -p n ${SID}/${MODE}/Dicoms/
		mv ${SID}/${MODE}/Dicoms/*nii.gz ${PWD_NIFTI}/${SID}.${SHORT_NAME}.nii.gz
		[ -e ${SID}/${MODE}/Logs/${LOG_NAME}_presentation.log ] && mv ${SID}/${MODE}/Logs/${LOG_NAME}_presentation.log ${PWD_NIFTI}/${SID}.${SHORT_NAME}_presentation.log
		rm -rf ${SID}/
	fi
	return $EXTRACT_SID_MODE
}

FN_RAW_DATA=${SID}_1.tar.gz
# Move to raw data directory
cp ${PWD_RAW_DATA}/${FN_RAW_DATA} ${PWD_WORK}/
cd $PWD_WORK

#echo "##################################################################################"
#echo "Extracting structural"
#run_extraction_to_nifti $PWD_NIFTI $PWD_DCM2NII $SID T1_3DAXIAL T1_structural Null
#EX_STRUCT=$?
#echo "##################################################################################"
#run_extraction_to_nifti $PWD_NIFTI $PWD_DCM2NII $SID FMRI_BOLD_rest BOLD_rest Null
#EX_REST=$?
#echo "##################################################################################"
#run_extraction_to_nifti $PWD_NIFTI $PWD_DCM2NII $SID FMRI_BOLD_emotion_identification BOLD_emotionid emotion_identification
#EX_EMO=$?
echo "##################################################################################"
run_extraction_to_nifti $PWD_NIFTI $PWD_DCM2NII $SID FMRI_BOLD_fractal_nback BOLD_nback fractal_nback
EX_NBACK=$?
echo "##################################################################################"
rm $FN_RAW_DATA
echo "##################################################################################"
echo "Complete $SID"
#EXTRACTION_STATUS="$SID $EX_STRUCT $EX_REST $EX_EMO $EX_NBACK"
#echo $EXTRACTION_STATUS >> ${PWD_WORK}/extraction_status.txt
echo "$SID $EX_NBACK" >> ${PWD_WORK}/extracted_nback.txt



