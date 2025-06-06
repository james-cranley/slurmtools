# slurmtools

This is a small set of useful tools for working on the University of Cambridge cluster.

## Set up

For convenience, make these functions available in your PATH.

```bash
cd # move to your HOME directory
git clone git@github.com:james-cranley/slurmtools.git # clone the repo to your home directory
export PATH="$HOME/slurmtools/src:$PATH" # add this line to your ~/.bashrc file
```

For email alerts, make sure an environemnt variable `MY_CAM_EMAIL` is set, by adding this line to your ~/.bashrc

```bash
export MY_CAM_EMAIL=foo1234@cam.ac.uk # your email
```

## qjump

This is a simple function to identify the slurm partition that is likely to give you the shortest wait time. The principal is to look for the partition which has the **lowest** `Highest Priority` value.
You can edit the list of cpu and cpu partitions by editing the qjump script.

```bash
qjump # (quiet mode) returns the optimal **cpu** queue (same as running qjump --device cpu)
qjump --device gpu # (quiet mode) returns the optimal **gpu** queue
qjump --table # retutns a table of all queues
```

Credit to [Theo Nelson](tmn2126@columbia.edu) for the original idea.

---
James Cranley, June 2025
