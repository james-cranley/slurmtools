slurmer -c 1 -t 1 -J slurm_serial_no_conda commands.txt | sbatch # basic
slurmer -c 1 -t 1 -J slurm_serial --conda scanpy -A TEICHLAB-SL2-CPU commands.txt | sbatch # account and conda env selection
slurmer -c 3 -t 1 -J slurm_parallel --conda scanpy --parallel -A TEICHLAB-SL2-CPU commands.txt | sbatch # parallel functionality, nb n cores > 1
slurmer -c 1 -t 1 -J slurm_array --conda scanpy --array -A TEICHLAB-SL2-CPU commands.txt | sbatch # array functionality
slurmer -g 1 -t 1 -J slurm_parallel_gpu --conda scanpy --parallel commands.txt | sbatch # parallel gpu
slurmer -g 1 -t 1 -J slurm_array_gpu --conda scanpy --array commands.txt | sbatch # array gpu
