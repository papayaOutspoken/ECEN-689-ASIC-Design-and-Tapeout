#!/bin/bash
#SBATCH --job-name=lab9_place
#SBATCH --partition=adademic
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=08:00:00
#SBATCH --output=flow_place_%j.log
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
cd "$SLURM_SUBMIT_DIR"
# runs must live on shared storage (visible from login + all compute nodes)
mkdir -p $HOME/chip_runs && ln -sfn $HOME/chip_runs runs
lane config.yaml --to OpenROAD.DetailedPlacement
