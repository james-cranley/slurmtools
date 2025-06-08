#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 3
#SBATCH -t 00:01:00
#SBATCH -J sbatcher_test_parallel
#SBATCH -e ./logs/sbatcher_test_parallel/sbatcher_test_parallel.%A.e
#SBATCH -o ./logs/sbatcher_test_parallel/sbatcher_test_parallel.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

eval "$(conda shell.bash hook)"
conda activate scanpy

module load parallel/20240922
mkdir -p ./logs/sbatcher_test_parallel
parallel --result './logs/sbatcher_test_parallel/cmd{#}' < commands.txt
