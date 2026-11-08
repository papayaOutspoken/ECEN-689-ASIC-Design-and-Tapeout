#!/bin/bash
#SBATCH --job-name=lab10_cts
#SBATCH --partition=adademic
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=flow_cts_%j.log
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
cd "$SLURM_SUBMIT_DIR"
lane config.yaml --last-run --from OpenROAD.CTS --to OpenROAD.ResizerTimingPostCTS
