# Lab 10 individual report  (copy as reports/<your_name>.md - one per member)
Name: Daniel Garcia
NetID: daniel-gar09
Team: 5

## 1. What I personally did in this lab
I ran the whole flow on my chosen Lab 9 C1 placement run, RUN_2026-10-29_13-53-56 (2900 x 4050 um).
Before Step 1, I deleted my other Lab 9 runs to raise my free space to 32 GB.
I added email notifications and log names to to_cts.sbatch, to_rcx.sbatch, and signoff.sbatch, then launched CTS, routing, and signoff.
While CTS ran, I read the reference run's congestion, antenna, and wirelength reports, and after routing I ran the same reports on our run.
From the post-route summary.rpt, I calculated our achieved period at SS as 52.208 ns from the worst SS setup slack of -2.2080 ns.
Finally, I ran extract_macro.sh, which created macro_kit/ with microwatt_top.gds, microwatt_top.lef, microwatt_top.nl.v, lib/, and PROVENANCE.txt.

## 2. Problems I encountered
The first problem was that my routing job did not start after I raised its time limit to 24 hours.

```
[daniel-gar09@olympus-login ~]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            736621  adademic lab10_ro daniel-g PD       0:00      1 (QOSMaxWallDurationPerJobLimit)
```

The second problem was that the signoff job ended as failed after running for more than 6 hours.

```
Slurm Job_id=738717 Name=lab10_signoff Failed, Run time 06:37:07, FAILED, ExitCode 2
[01:40:24] ERROR    The following error was encountered while    __main__.py:189
                    running the flow:
                    One or more deferred errors were
                    encountered:
                    Hold violations found in the following
                    corners:
                    * max_ff_n40C_1v95
                    * min_ff_n40C_1v95
                    * nom_ff_n40C_1v95
[01:40:24] ERROR    LibreLane will now quit.                     __main__.py:190
```


## 3. How each problem was resolved
Problem 1:
I ran the command "sinfo -p adademic -o "%P %l"", which showed the partition TIMELIMIT as "infinite", so the limit came from my account's QOS, not the partition, and the job would never start.
I cancelled it with "scancel 736621", set "#SBATCH --time=12:00:00" back in to_rcx.sbatch, and resubmitted the job, which squeue showed running on a node.
Routing then finished in 6 h 35 min with "Flow complete."

Problem 2:
The end of flow_signoff_C1_H4050_738717.log showed that all 72 stages had completed and that the manufacturability report listed LVS and DRC as "Passed", 
so the job failed only because of the deferred hold error, even though error.log was empty.
summary.rpt showed hold violations only at the fast corners, 20 endpoints in total, with a worst hold slack of -0.0709 ns at max_ff_n40C_1v95.
I traced them back to the CTS log, where "[RSZ-0064] Unable to repair all hold checks within margin." showed the hold repair ended at only +0.045 ns of slack against its 0.1 ns margin.
Since hold violations at the ff_n40C corners will be addressed in the Lab 11 waiver discussion, I recorded them in C8 and C9 and continued to Step 7.