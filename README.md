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

If you want SLURM jobs submitted by `slurmer` to send email notifications, set the environment variable `MY_CAM_EMAIL`:

```bash
export MY_CAM_EMAIL=cr123@cam.ac.uk   # Replace with your CRSid email, 
```

Again consider adding this line to `~/.bashrc` for persistence.

## qjump

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

## slurmer

Generates SLURM batch scripts from a plain text file of commands. By default commands will be executed in series, however there is a seamless parallelisation (`--array`/`--parallel`) if each line is an independent job. It is particualrly helpful when running multiple commands with varying parameterisations (i.e. bioinformatics...) because it reduces the slurm submission task to creating text file with one command per run.

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
slurmer commands.txt -J testjob -t 2 -g 1 --array          # as a SLURM array on 1 GPU
slurmer commands.txt -J testjob -t 2 -c 4 --conda myenv    # run in conda environment
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

## bashaslurm

Strips all `#SBATCH` lines from a SLURM script, so you can safely run the body of a batch script interactively (e.g., via `sintr`):

```bash
bashaslurm slurmscript.sh
```

The result is printed to standard output.

---

[James Cranley](jc2226@cam.ac.uk)
June 2025

---
