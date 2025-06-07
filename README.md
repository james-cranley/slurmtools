# slurmtools

A set of pragmatic helper scripts for Slurm users on the University of Cambridge clusters (and potentially adaptable elsewhere).

## Setup

Make the tools available on your `$PATH`:

```bash
cd # move to your HOME directory
git clone git@github.com:james-cranley/slurmtools.git
chmod +x "$HOME/slurmtools/src"/* # makes the scripts executable (assumes you cloned the repo into HOME)
export PATH="$HOME/slurmtools/src:$PATH" # Add to ~/.bashrc for persistence
```

### Email notifications

If you want SLURM jobs submitted by `slurmer` to send email notifications, `set` the environment variable `MY_CAM_EMAIL`:

```bash
export MY_CAM_EMAIL=cr123@cam.ac.uk   # Replace with your CRSid email, 
```

Again consider adding this line to `~/.bashrc` for persistence.

## `qjump`
<details>
<summary>click here</summary>

Identifies the Slurm partition with the **lowest** "Highest Priority" value among pending jobs blocked by the Priority reason, as a heuristic for the likely shortest queue.
Partitions are separated into CPU and GPU classes; edit the lists in the `qjump` script as needed.

**Usage:**

```bash
qjump                # returns optimal CPU queue (default)
qjump --device gpu   # returns optimal GPU queue
qjump --table        # print table of all queues (with pending job stats)
```

Output is a single partition name (unless `--table` is used).

Credit: [Theo Nelson](mailto:tmn2126@columbia.edu) for the original idea.

</details>

## `slurmer`
<details>
<summary>click here</summary>

Generates SLURM submission scripts from a plain text file of commands. By default commands will be executed in series, however there is a seamless parallelisation (`--array` or `--parallel`) if each line is an independent job. It is particularly helpful when running multiple commands with varying parameterisations (i.e. bioinformatics...) because it reduces the slurm submission headache to creating a text file with one command per row. It also handles one-line jobs perfectly fine, making it flexible for all you slurm submissions.

**Key features:**

* **Partition selection**:

  * Default is "auto": for CPU jobs, picks the optimal partition via `qjump`; for GPU jobs, picks via `qjump --device gpu`.
  * Override with `-p <partition>`.
* **Execution modes**:

  * **Serial**: (default) runs commands one after another (`parallel -j1`).
  * **Parallel**: runs commands concurrently with GNU Parallel (`--parallel`). Jobs share the requested resource.
  * **Array**: creates a SLURM array job, one command per task (`--array`). Each job gets the requested resource.
* **Logging**:

  * Each job’s logs are placed in a `logs/<job-name>/` directory by default.
  * Each in non-array mode, each individual command (line from commands text file) has its own stderr and stdout.
  * For future reference/debugging, the commands file and script file are kept in the logs diretory.
* **Email notification**:

  * Only included if `MY_CAM_EMAIL` is set.
* **Conda**:

  * Optionally activate a specified conda environment.
* **GPU jobs**:

  * Optional CUDA MPS for multi-process sharing with `--parallel`.

**Basic usage:**

```bash
slurmer <cmdfile> -J <job-name> -t <hours> -c <cores>
```

**Examples:**

Example `commands.txt`:
```bash
python myGPUscript.py --input A --anotherflag B
python myGPUscript.py --input B --anotherflag D
```

Example `slurmer` calls:
```bash
slurmer commands.txt -J testjob -t 2 -c 4                  # serial (default)
slurmer commands.txt -J testjob -t 2 -c 4 --parallel       # run all commands concurrently
slurmer commands.txt -J testjob -t 2 -g 1 --array          # as a SLURM array, 1 GPU each
slurmer commands.txt -J testjob -t 2 -g 1 --parallel       # concurrently, sharing 1 GPU
slurmer commands.txt -J testjob -t 2 -c 4 --conda myenv    # run in conda environment
```

Example `slurmer`-generated script:
```bash
slurmer -g 1 -t 1 -J slurm_parallel_gpu --conda scanpy --parallel test_cmds.txt
>>> OUTPUT: slurm_parallel_gpu.sh

#!/bin/bash
#SBATCH -p ampere
#SBATCH -A TEICHMANN-SL3-GPU
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH -t 1:00:00
#SBATCH -J slurm_parallel_gpu
#SBATCH -e ./logs/slurm_parallel_gpu/%x.e%A
#SBATCH -o ./logs/slurm_parallel_gpu/%x.o%A
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
parallel --result ./logs/slurm_parallel_gpu/{#}/{#} < test_cmds.txt

echo quit | nvidia-cuda-mps-control
```

Example of logging (same commands run in serial, parallel and array):
```bash
.
├── commands.txt
├── logs
│   ├── slurm_array
│   │   ├── commands.txt
│   │   ├── slurm_array.10805579.e
│   │   ├── slurm_array.10805579.o
│   │   └── slurm.sh
│   ├── slurm_parallel
│   │   ├── cmd1
│   │   ├── cmd1.err
│   │   ├── cmd1.seq
│   │   ├── cmd2
│   │   ├── cmd2.err
│   │   ├── cmd2.seq
│   │   ├── cmd3
│   │   ├── cmd3.err
│   │   ├── cmd3.seq
│   │   ├── commands.txt
│   │   ├── slurm_parallel.10805577.e
│   │   ├── slurm_parallel.10805577.o
│   │   └── slurm.sh
│   └── slurm_serial
│       ├── cmd1
│       ├── cmd1.err
│       ├── cmd1.seq
│       ├── cmd2
│       ├── cmd2.err
│       ├── cmd2.seq
│       ├── cmd3
│       ├── cmd3.err
│       ├── cmd3.seq
│       ├── commands.txt
│       ├── slurm_serial.10805576.e
│       ├── slurm_serial.10805576.o
│       └── slurm.sh
├── reset.sh
├── slurm_array.sh
├── slurm_parallel.sh
├── slurm_serial.sh
└── test.sh
```

**Arguments of note:**

* `-c <cores>`: required for CPU jobs.
* `-g <gpus>`: triggers GPU job mode.
* `-J <name>`: sets the SLURM job name.
* `-t <hours>`: sets walltime (hours).
* `--parallel` / `--array`: mutually exclusive execution modes.
* `--conda <env>`: activates a named conda environment before running commands.

The script outputs a batch file named `<job-name>.sh` and prints log/submit instructions.

**One-liner:**

Running `slurmer` generates a slurm script, enabling inspection. This can then be dispatched with `sbatch slurmeroutputscript.sh`. Alternatively, you can pipe the output directly to `sbatch`, like so:

```bash
slurmer commands.txt -J my_job -t 1 -c 2 | sbatch
```

**Dependencies:**

* Python 3
* `GNU Parallel` (loaded via module inside the batch script)
* `qjump` script (on PATH or in the same directory as `slurmer`)

**Testing:**

You can test whether it works on your system by running:

```bash
cd ~/slurmtools/test # go to test area
bash test.sh
```

Then inspect the logs / errors. To reset run `bash reset.sh`.

</details>

## `bashaslurm`
<details>
<summary>click here</summary>

Strips all `#SBATCH` lines from a SLURM script, so you can safely run the body of a batch script interactively (e.g., via `sintr`):

```bash
bashaslurm slurmscript.sh
```

The result is printed to standard output.
</details>

## `sbatcher`
<details>
<summary>click here</summary>

Launches a SLURM batch script **and** starts a detached watcher that will automatically retry the job if it times‑out or runs out of memory.  
It is a thin wrapper around `sbatch`, `screen`, and the companion `tenacity` script.
As is also the case for standard `sbatch` dispatching, jobs should be dispatched when on a *login* node (`sbatcher` checks using string search 'login' as a heuristic).

**Key features**

* Parses the `#SBATCH -o …` line to discover the run‑time log directory, copies
  the original script there for provenance, and drops all watcher logs into
  the same directory.
* Submits the SLURM job and records the Job ID.
* Spawns a detached `screen` session named `tenacity.<JOBID>` running the
  watcher.
* Verbose mode (`-v`) prints every command and redirects the watcher’s stdout +
  stderr to `tenacity_screen.log` in the log directory.

**Basic usage**

```bash
sbatcher myjob.sh                          # normal
sbatcher -v myjob.sh --max-retries 3       # verbose, pass args to tenacity
```

**One-liner with `slurmer`**

```bash
slurmer commands.txt -J my_job -t 1 -c 2 | sbatcher # the job is now dispatched and will retry if OOM/TIMEOUT
```

*Everything after the batch‑script name is forwarded to `tenacity` unchanged.*
</details>

## `tenacity`
<details>
<summary>click here</summary>

A Python watcher that monitors a running SLURM job and, on resource failure,
resubmits an edited copy of the job script with more wall‑time or more CPUs.

**Retries**

* **Timeout**   → adds `--time` by `--time-increment` hours (default `+2 h`)
* **Out‑of‑memory** (exit 137 / Reason=`OutOfMemory`) → adds cores by
  `--core-increment` (default `+2`)
* Caps are enforced by `--max-hours` and `--max-cores`.
* GPU jobs are never retried for OOM because memory is GPU‑tied.

**How it works**

1. Polls `sacct` for `State`, `ExitCode`, and `Reason`.
2. Classifies failure (timeout, OOM, or other).
3. Creates a new script `slurm___TO<n>.sh` or `slurm___OOM<n>.sh`
   * patches `#SBATCH -t …` or `#SBATCH -c …`
   * injects `#SBATCH -D <original‑working‑dir>` so relative paths still work
4. Resubmits and continues until success or retry cap.

**Typical call**

```bash
tenacity -s myjob.sh --jobid 123456          --max-retries 3  --time-increment 1 --poll 120
```

Any arguments accepted by `tenacity` can be forwarded through `sbatcher`:

```bash
sbatcher run_big_job.sh --max-retries 3 --time-increment 1
```

All watcher activity is written to `tenacity.log` in the same directory
specified by the original `#SBATCH -o` path.
</details>

---

[James Cranley](mailto:jc2226@cam.ac.uk)  
June 2025

