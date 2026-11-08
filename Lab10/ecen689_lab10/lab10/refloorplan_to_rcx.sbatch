#!/bin/bash
#SBATCH --job-name=lab10_recover
#SBATCH --partition=adademic
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=flow_recover_%j.log
# Congestion recovery: after editing DIE_AREA (larger H) in config.yaml,
# this reruns from floorplan through extraction in one job.
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
cd "$SLURM_SUBMIT_DIR"
lane config.yaml --to OpenROAD.RCX
