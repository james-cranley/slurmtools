#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J slurm_array
#SBATCH -e ./logs/slurm_array/slurm_array.%A.e
#SBATCH -o ./logs/slurm_array/slurm_array.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

#SBATCH --array=1-3

eval "$(conda shell.bash hook)"
conda activate scanpy

mkdir -p ./logs/slurm_array
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" commands.txt)
echo "▶ $CMD"
eval "$CMD"
