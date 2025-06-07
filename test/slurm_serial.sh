#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J slurm_serial
#SBATCH -e ./logs/slurm_serial/slurm_serial.%A.e
#SBATCH -o ./logs/slurm_serial/slurm_serial.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

eval "$(conda shell.bash hook)"
conda activate scanpy

module load parallel/20240922
mkdir -p ./logs/slurm_serial
parallel -j1 --result './logs/slurm_serial/cmd{#}' < commands.txt
