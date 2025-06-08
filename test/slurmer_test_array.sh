#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J slurmer_test_array
#SBATCH -e ./logs/slurmer_test_array/slurmer_test_array.%A_%a.e
#SBATCH -o ./logs/slurmer_test_array/slurmer_test_array.%A_%a.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

#SBATCH --array=1-3

eval "$(conda shell.bash hook)"
conda activate scanpy

mkdir -p ./logs/slurmer_test_array
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" commands.txt)
echo "▶ $CMD"
eval "$CMD"
