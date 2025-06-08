#!/bin/bash
#SBATCH -p cclake-himem
#SBATCH -A TEICHLAB-SL2-CPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -t 00:01:00
#SBATCH -J sbatcher_test_serial
#SBATCH -e ./logs/sbatcher_test_serial/sbatcher_test_serial.%A.e
#SBATCH -o ./logs/sbatcher_test_serial/sbatcher_test_serial.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

eval "$(conda shell.bash hook)"
conda activate scanpy

module load parallel/20240922
mkdir -p ./logs/sbatcher_test_serial
parallel -j1 --result './logs/sbatcher_test_serial/cmd{#}' < commands.txt
