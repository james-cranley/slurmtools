#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 3
#SBATCH -t 1:00:00
#SBATCH -J slurmer_test_parallel
#SBATCH -e ./logs/slurmer_test_parallel/slurmer_test_parallel.%A.e
#SBATCH -o ./logs/slurmer_test_parallel/slurmer_test_parallel.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

eval "$(conda shell.bash hook)"
conda activate scanpy

module load parallel/20240922
mkdir -p ./logs/slurmer_test_parallel
parallel --result './logs/slurmer_test_parallel/cmd{#}' < commands.txt
