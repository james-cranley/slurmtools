#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 0:01:00
#SBATCH -J slurm_TIMEOUT
#SBATCH -e ./logs/slurm_TIMEOUT/slurm_TIMEOUT.%A.e
#SBATCH -o ./logs/slurm_TIMEOUT/slurm_TIMEOUT.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

module load parallel/20240922
mkdir -p ./logs/slurm_TIMEOUT
parallel -j1 --result './logs/slurm_TIMEOUT/cmd{#}' < TIMEOUT.txt
