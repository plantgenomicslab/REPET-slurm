#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH --time=1-00:00:00
#SBATCH --output=TEdenovo-step4-%a.stdout
#SBATCH --job-name="S4_TEdenovo"
#SBATCH -p stajichlab

module load repet/2.5

# REPET TEdenovo - Step 4
# Multiple alignment computed for each cluster and consensus sequence produced

if  [ ! -n "$ProjectName" ] || [ ! -n "$CLUSTERERS_AVAIL" ] || [ ! -n "$SMPL_ALIGNER" ] || [ ! -n "$MLT_ALIGNER" ]; then
    echo 'One or more environment variables required by this script' \
    'are unset. Either run this script through the scheduler script or' \
    'set the variable(s) and use the --export option of sbatch before' \
    'restarting.'
    exit 1
fi

# split CLUSTERERS_AVAIL string into bash array
IFS=',' read -ra CLUSTERERS_AVAIL_ARRAY <<< "$CLUSTERERS_AVAIL"
CLUSTERER=${CLUSTERERS_AVAIL_ARRAY[$SLURM_ARRAY_TASK_ID]}

if [ ! -d "${ProjectName}_${SMPL_ALIGNER}_${CLUSTERER}_${MLT_ALIGNER}" ]; then
    TEdenovo.py -P $ProjectName -C TEdenovo.cfg -S 4 -s $SMPL_ALIGNER -c $CLUSTERER -m $MLT_ALIGNER
else
    echo "Step 4 output folder detected, skipping..."
fi
