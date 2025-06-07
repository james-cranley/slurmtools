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

[content unchanged]
</details>

## `slurmer`
<details>
<summary>click here</summary>

[content unchanged]
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

Launches a SLURM batch script **and** starts a detached watcher that will
automatically retry the job if it times‑out or runs out of memory.  
It is a thin wrapper around `sbatch`, `screen`, and the companion `tenacity`
script.

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

