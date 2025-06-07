#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHMANN-SL3-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J slurm_serial_no_conda
#SBATCH -e ./logs/slurm_serial_no_conda/slurm_serial_no_conda.%A.e
#SBATCH -o ./logs/slurm_serial_no_conda/slurm_serial_no_conda.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

module load parallel/20240922
mkdir -p ./logs/slurm_serial_no_conda
parallel -j1 --result './logs/slurm_serial_no_conda/cmd{#}' < commands.txt
