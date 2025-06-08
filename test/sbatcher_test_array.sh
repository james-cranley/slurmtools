#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 00:01:00
#SBATCH -J sbatcher_test_array
#SBATCH -e ./logs/sbatcher_test_array/sbatcher_test_array.%A_%a.e
#SBATCH -o ./logs/sbatcher_test_array/sbatcher_test_array.%A_%a.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

#SBATCH --array=1-3

eval "$(conda shell.bash hook)"
conda activate scanpy

mkdir -p ./logs/sbatcher_test_array
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" commands.txt)
echo "▶ $CMD"
eval "$CMD"
