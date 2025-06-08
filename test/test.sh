slurmer -c 1 -t 1 -J slurmer_test_serial_no_conda commands.txt | sbatch # basic
slurmer -c 1 -t 1 -J slurmer_test_serial --conda scanpy -A TEICHLAB-SL2-CPU commands.txt | sbatch # account and conda env selection
slurmer -c 3 -t 1 -J slurmer_test_parallel --conda scanpy --parallel -A TEICHLAB-SL2-CPU commands.txt | sbatch # parallel functionality, nb n cores > 1
slurmer -c 1 -t 1 -J slurmer_test_array --conda scanpy --array -A TEICHLAB-SL2-CPU commands.txt | sbatch # array functionality
slurmer -g 1 -t 1 -J slurmer_test_parallel_gpu --conda scanpy --parallel commands.txt | sbatch # parallel gpu
slurmer -g 1 -t 1 -J slurmer_test_array_gpu --conda scanpy --array commands.txt | sbatch # array gpu

# test sbatcher with pre-made scripts with 1 minute job times
sbatcher -v sbatcher_test_serial.sh
sbatcher -v sbatcher_test_parallel.sh
sbatcher -v sbatcher_test_array.sh