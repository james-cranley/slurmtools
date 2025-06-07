#!/bin/bash
#SBATCH -p ampere
#SBATCH -A TEICHMANN-SL3-GPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH -t 1:00:00
#SBATCH -J slurm_parallel_gpu
#SBATCH -e ./logs/slurm_parallel_gpu/slurm_parallel_gpu.%A.e
#SBATCH -o ./logs/slurm_parallel_gpu/slurm_parallel_gpu.%A.o
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jc2226@cam.ac.uk

eval "$(conda shell.bash hook)"
conda activate scanpy

module load parallel/20240922
# ---- CUDA MPS for multi-process GPU sharing ------------
MPS_BASE="${TMPDIR:-/tmp}/mps_${SLURM_JOB_ID}"
mkdir -p "${MPS_BASE}"
export CUDA_MPS_PIPE_DIRECTORY="${MPS_BASE}"
export CUDA_MPS_LOG_DIRECTORY="${MPS_BASE}"
nvidia-cuda-mps-control -d

mkdir -p ./logs/slurm_parallel_gpu
parallel --result './logs/slurm_parallel_gpu/cmd{#}' < commands.txt

echo quit | nvidia-cuda-mps-control
