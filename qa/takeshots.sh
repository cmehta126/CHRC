#!/bin/bash

if [ -z "$1" ]; then
cat <<EOU
Capture some screenshots of surfaces produced by
FreeSurfer in standard orientations.

Usage: takeshots [options]

The options are:
-s <subjid> : Specify one subject ID
-l <listid> : Specify a file list with the subject IDs, one per line
-m <mesh>   : Specify a surface file (pial, white, inflated, sphere, etc.)
-p <parc>   : Specify a parcellation to load (aparc, aparc.a2009s, aparc.a2005s)
-c <curv>   : Specify a curvature file (not implemented)

_____________________________________
Anderson M. Winkler
Yale University / Institute of Living
Jan/2010
http://brainder.org
EOU
exit 1
fi


# Check and accept the arguments
while getopts 's:l:m:p:c:' OPTION
do
  case ${OPTION} in
    s) SUBJ_LIST="${SUBJ_LIST} ${OPTARG}" ;;
    l) SUBJ_LIST="${SUBJ_LIST} $(cat ${OPTARG})" ;;
    m) MESH_LIST="${MESH_LIST} ${OPTARG}" ;;
    p) PARC_LIST="${PARC_LIST} ${OPTARG}" ;;
    c) CURV_LIST="${CURV_LIST} ${OPTARG}" ;;
  esac
done


for s in ${SUBJ_LIST} ; do
mkdir -p ${SUBJECTS_DIR}/${s}/shots
  for h in lh rh ; do
    for m in ${MESH_LIST} ; do
      for p in ${PARC_LIST} ; do
        export SUBJECT_NAME=${s}
        export SURF=${m}
        export PARC=${p}
        tksurfer ${s} ${h} ${m} -tcl  $(dirname $0)/labelshots.tcl
      done
    done
  done
done




