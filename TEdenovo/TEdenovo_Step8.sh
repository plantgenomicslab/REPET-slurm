#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem 2G
#SBATCH --time=1-00:00:00
#SBATCH --output=TEdenovo-step8.stdout
#SBATCH --job-name="S8_TEdenovo"
#SBATCH -p stajichlab

module load repet/2.5
module load ncbi-blast/2.2.26

# REPET TEdenovo - Step 8 - Combined Standard and Structural
# Consensus sequences clustered into families

if  [ ! -n "$ProjectName" ] || [ ! -n "$CLUSTERERS_AVAIL" ] || [ ! -n "$SMPL_ALIGNER" ] || [ ! -n "$MLT_ALIGNER" ] || [ ! -n "$FINAL_CLUSTERER" ]; then
    echo 'One or more environment variables required by this script' \
    'are unset. Either run this script through the scheduler script or' \
    'set the variable(s) and use the --export option of sbatch before' \
    'restarting.'
    exit 1
fi

if [ ! -d "${ProjectName}_${SMPL_ALIGNER}_${CLUSTERERS}_Struct_${MLT_ALIGNER}_TEclassif_Filtered_${FINAL_CLUSTERER}" ]; then
    CLUSTERERS=$( echo $CLUSTERERS_AVAIL | tr -d ',' )

    TEdenovo.py -P $ProjectName -C TEdenovo.cfg -S 8 -s $SMPL_ALIGNER -c $CLUSTERERS -m $MLT_ALIGNER -f $FINAL_CLUSTERER --struct
else
    echo "Step 8 output folder detected, skipping..."
fi
