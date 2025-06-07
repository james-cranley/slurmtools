#!/bin/bash
#SBATCH -p ampere
#SBATCH -A TEICHMANN-SL3-GPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH -t 1:00:00
#SBATCH -J slurm_array_gpu
#SBATCH -e ./logs/slurm_array_gpu/slurm_array_gpu.%A.e
#SBATCH -o ./logs/slurm_array_gpu/slurm_array_gpu.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

#SBATCH --array=1-3

eval "$(conda shell.bash hook)"
conda activate scanpy

mkdir -p ./logs/slurm_array_gpu
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" commands.txt)
echo "▶ $CMD"
eval "$CMD"
