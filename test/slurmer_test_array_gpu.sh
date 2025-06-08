#!/bin/bash
#SBATCH -p ampere
#SBATCH -A TEICHMANN-SL3-GPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH -t 1:00:00
#SBATCH -J slurmer_test_array_gpu
#SBATCH -e ./logs/slurmer_test_array_gpu/slurmer_test_array_gpu.%A_%a.e
#SBATCH -o ./logs/slurmer_test_array_gpu/slurmer_test_array_gpu.%A_%a.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

#SBATCH --array=1-3

eval "$(conda shell.bash hook)"
conda activate scanpy

mkdir -p ./logs/slurmer_test_array_gpu
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" commands.txt)
echo "▶ $CMD"
eval "$CMD"
