#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=1-00:00:00
#SBATCH --output=step3.stdout
#SBATCH --job-name="REPET_Step3"
#SBATCH --array=0-1
#SBATCH -p intel

module load repet/2.5

# REPET - Step 3

CLUSTERER=${CLUSTERERS_AVAIL[$SLURM_ARRAY_TASK_ID]}

if [ ! -d "${ProjectName}_${SMPL_ALIGNER}_${CLUSTERER}" ]; then
    TEdenovo.py -P $ProjectName -C TEdenovo.cfg -S 3 -s $SMPL_ALIGNER -c $CLUSTERER
fi
