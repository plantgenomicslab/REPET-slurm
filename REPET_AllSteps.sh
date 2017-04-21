#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=01:00:00
#SBATCH --output=scheduler.stdout
#SBATCH --job-name="REPET_Scheduler"
#SBATCH -p intel

# REPET - Whole Pipeline Scheduler

# Setup/Reset MySQL Database for new run
# WARNING: Do NOT drop the "jobs" table if multiple instances of REPET
#          are concurrently using the same database
MYSQL_HOST=$(grep "repet_host" TEdenovo.cfg | cut -d" " -f2)
MYSQL_USER=$(grep "repet_user" TEdenovo.cfg | cut -d" " -f2)
MYSQL_PASS=$(grep "repet_pw" TEdenovo.cfg | cut -d" " -f2)
MYSQL_DB=$(grep "repet_db" TEdenovo.cfg | cut -d" " -f2)

echo "DROP TABLE jobs;" | mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $MYSQL_DB

# Set Project-Specific Variables
export ProjectName="Fairchild"
export SMPL_ALIGNER="Blaster"
export CLUSTERERS_AVAIL=("Grouper" "Recon")
export CLUSTERERS="GrpRec"
export MLT_ALIGNER="Map"
export FINAL_CLUSTERER="Blastclust"

jid_step1=$(sbatch --export=ProjectName --kill-on-invalid-dep=yes REPET_Step1.sh | cut -d" " -f4)

jid_step2=$(sbatch --export=ProjectName,SMPL_ALIGNER --kill-on-invalid-dep=yes --dependency=afterok:$jid_step1 REPET_Step2.sh | cut -d" " -f4)
jid_step2s=$(sbatch --export=ProjectName --kill-on-invalid-dep=yes --dependency=afterok:$jid_step1 REPET_Step2s.sh | cut -d" " -f4)

jid_step3=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL --kill-on-invalid-dep=yes --dependency=afterok:$jid_step2 REPET_Step3.sh | cut -d" " -f4)
jid_step3s=$(sbatch --export=ProjectName --kill-on-invalid-dep=yes --dependency=afterok:$jid_step2s REPET_Step3s.sh | cut -d" " -f4)

jid_step4=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS_AVAIL --kill-on-invalid-dep=yes --dependency=afterok:$jid_step3 REPET_Step4.sh | cut -d" " -f4)
jid_step4s=$(sbatch --export=ProjectName --kill-on-invalid-dep=yes --dependency=afterok:$jid_step3s REPET_Step4s.sh | cut -d" " -f4)

jid_step5=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS,MLT_ALIGNER --kill-on-invalid-dep=yes --dependency=afterok:$jid_step4:$jid_step4s REPET_Step5.sh | cut -d" " -f4)

jid_step6=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS,MLT_ALIGNER --kill-on-invalid-dep=yes --dependency=afterok:$jid_step5 REPET_Step6.sh | cut -d" " -f4)

jid_step7=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS,MLT_ALIGNER --kill-on-invalid-dep=yes --dependency=afterok:$jid_step6 REPET_Step7.sh | cut -d" " -f4)

jid_step8=$(sbatch --export=ProjectName,SMPL_ALIGNER,CLUSTERERS,MLT_ALIGNER,FINAL_CLUSTERER --kill-on-invalid-dep=yes --dependency=afterok:$jid_step7 REPET_Step8.sh | cut -d" " -f4)

echo "Finished submitting all jobs at $(date)"
