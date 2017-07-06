#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=0:10:00
#SBATCH --output=scheduler.stdout
#SBATCH --job-name="Sched_TEdenovo"
#SBATCH -p intel

# REPET TEdenovo Pipeline Scheduler

# Setup/reset MySQL database for new run
# WARNING: Do NOT drop the "jobs" table if multiple instances of REPET
#          are concurrently using the same database
MYSQL_HOST=$(grep "repet_host" TEdenovo.cfg | cut -d" " -f2)
MYSQL_USER=$(grep "repet_user" TEdenovo.cfg | cut -d" " -f2)
MYSQL_PASS=$(grep "repet_pw" TEdenovo.cfg | cut -d" " -f2)
MYSQL_DB=$(grep "repet_db" TEdenovo.cfg | cut -d" " -f2)

# Set project-specific variables
export ProjectName=$(grep "project_name" TEdenovo.cfg | cut -d" " -f2)
export SMPL_ALIGNER="Blaster"
export CLUSTERERS_AVAIL="Grouper,Recon"
export MLT_ALIGNER="Map"
export FINAL_CLUSTERER="Blastclust"

# Clear the jobs table for the current project
## in case last run failed for some reason while sub-jobs were running
echo "DELETE FROM jobs WHERE groupid LIKE '${ProjectName}_%';" | \
mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $MYSQL_DB

# Submit jobs to SLURM
jid_step1=$(sbatch \
    --export=ProjectName \
    --kill-on-invalid-dep=yes \
    TEdenovo_Step1.sh | \
    cut -d" " -f4)

jid_step2=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step1 \
    TEdenovo_Step2.sh | \
    cut -d" " -f4)
jid_step2s=$(sbatch \
    --export=ProjectName \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step1 \
    TEdenovo_Step2s.sh | \
    cut -d" " -f4)

jid_step3=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step2 \
    TEdenovo_Step3.sh | \
    cut -d" " -f4)
jid_step3s=$(sbatch \
    --export=ProjectName \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step2s \
    TEdenovo_Step3s.sh | \
    cut -d" " -f4)

jid_step4=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL,MLT_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step3 \
    TEdenovo_Step4.sh | \
    cut -d" " -f4)
jid_step4s=$(sbatch \
    --export=ProjectName,MLT_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step3s \
    TEdenovo_Step4s.sh | \
    cut -d" " -f4)

jid_step5=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL,MLT_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step4:$jid_step4s \
    TEdenovo_Step5.sh | \
    cut -d" " -f4)

jid_step6=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL,MLT_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step5 \
    TEdenovo_Step6.sh | \
    cut -d" " -f4)

jid_step7=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL,MLT_ALIGNER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step6 \
    TEdenovo_Step7.sh | \
    cut -d" " -f4)

jid_step8=$(sbatch \
    --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL,MLT_ALIGNER,FINAL_CLUSTERER \
    --kill-on-invalid-dep=yes \
    --dependency=afterok:$jid_step7 \
    TEdenovo_Step8.sh | \
    cut -d" " -f4)

echo "Finished submitting all jobs at $(date)"
