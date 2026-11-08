# ECEN 689 — Lab 10: Route It, Sign It Off — Your Core Becomes a Macro
**Project stage 3 of 5 · This is the week of 12-hour runs: the
schedule is the strategy.

> **⚠ DISK SPACE — read before launching anything.** This lab's flow runs add
> **~14 GB** to the designated member's home directory, on top of the ~1.5 GB
> Lab 9 run they build on (CTS ~0.5 GB · routing+RCX ~5 GB · signoff ~8 GB).
> Before Step 1: (1) the designated member must have **≥20 GB free** in $HOME
> (`df -h ~`) — clean up until they do; (2) `runs/` must contain **exactly one
> Lab 9 run: your chosen, completed placement run** — delete or move out every
> other Lab 9 run (your B6 evidence is already recorded in answers.txt).
> You get almost all of it back: after Step 8's zip is built, `macro_kit/` is
> the only thing later labs need — the run directory can be deleted (Step 8).

Input: your chosen Lab 9 run (placed, on the 2900-wide frame-legal die).
Output: `macro_kit/` — your hardened core with provenance. Everything after
this week treats your core as a sealed block.

## Roles this week
- **Run pilots (2):** own the launch sequence + monitoring (Steps 1, 3, 5) —
  including launching at the RIGHT time of day (12 h runs)
- **Report analysts (2):** Steps 2, 4, 6 — reference-run literacy, then your
  run's reports, timing table
- **Macro/verification (2):** Steps 7–8 — extraction, provenance, submission
- **Everyone:** individual report; C6 (prediction reckoning) is whole-team.

## Deliver
`lab10/answers.txt` (C1–C10) · `macro_kit/` created (or DEBUG.md if recovery
consumed the week - documented failure = full run credit) · evidence folder
(auto-collected) · 6 individual reports · team ZIP.
---

## Step 0 — Add the kit (5 min)
```bash
scp ecen689_lab10.zip <netid>@olympus.ece.tamu.edu:
ssh <netid>@olympus.ece.tamu.edu
cd ~/ecen689_lab8 && unzip ~/ecen689_lab10.zip && ls lab10
```
**You must see:** `to_cts.sbatch  to_rcx.sbatch  signoff.sbatch
refloorplan_to_rcx.sbatch  extract_macro.sh  answers.txt  make_submission_zip.sh`

## Step 1 — CTS (~2–7 h: the post-CTS repair is the slow part) 
Your placed design has no clock network yet. CTS builds the buffer tree that
delivers `clk` to ~70k flip-flops; a resizer then repairs the timing damage.

> **⚠ `--last-run` resumes the NEWEST run in `runs/`, not your B7 choice —
> make sure unwanted Lab 9 runs are moved out before launching; all of Lab 10
> builds on this one run.**

```bash
sbatch lab10/to_cts.sbatch     # resumes your Lab 9 chosen run - no resynthesis
squeue -u $USER
```
> **If `--last-run` complains there is nothing to resume:** your Lab 9 run was
> purged or you are in the wrong folder — rerun Lab 9 Step 4 for your chosen H
> (placement only, ~3 h), then relaunch.

When done:
```bash
R=$(ls -dt runs/RUN_* | head -1)        # (assignment - prints nothing)
grep -iE "buffers inserted" $R/*-openroad-cts/openroad-cts.log
grep -oE '"clock__skew__worst_[a-z]*__corner:nom_tt[^,]*' $R/*-openroad-stamidpnr-1/state_out.json
```
**Record** → **C1**; answer **C2** (why thousands of buffers for one clock?).

## Step 2 — Learn the reports on the reference run (while CTS cooks)
A finished staff run is staged at `/mnt/nfs-scratch/ecen-689-nowka/docs/example_run/`:
```bash
E=/mnt/nfs-scratch/ecen-689-nowka/docs/example_run
grep -hA10 -i "Final congestion report" $E/*globalrouting/openroad-globalrouting.log
grep -icE "violation" $E/*checkantennas*/*.log
grep -i "Total wire length" $E/*-openroad-detailedrouting/*.log | head -2
```
**Record** → **C3**, and **C4** in your own words (what is an antenna violation;
how does a diode fix it). You will read these same reports on YOUR run in Step 4.

## Step 3 — THE BIG RUN: routing + extraction 
```bash
sbatch lab10/to_rcx.sbatch     # global route -> antenna repair -> detailed route -> RCX.
squeue -u $USER                # note the job id; check with: tail -20 flow_route_<id>.log
```
## Step 4 — Verdict + the prediction reckoning
```bash
R=$(ls -dt runs/RUN_* | head -1)
cat $R/error.log                  # empty = routed clean
ls -d $R/*-openroad-rcx           # dir exists = the chain reached RCX
ls $R/*-openroad-rcx/nom          # SPEF file = parasitics extracted
```
**Record** → **C5**. Then the whole team answers **C6**: was your Lab 9 B9
prediction right? What does that teach you about your frontier data?

> **If routing FAILED (`GRT-0183`, heap errors, endless DRC loops):** this is
> congestion — your H was too aggressive. The documented path (= full credit):
> 1. `lab10/DEBUG.md`: exact first error line, step dir, your diagnosis.
> 2. Edit `config.yaml`: DIE_AREA height +250 (one step up your worksheet).
> 3. `sbatch lab10/refloorplan_to_rcx.sbatch` (reruns floorplan→RCX, ~8–12 h).
> 4. Record the relaunch verdict in DEBUG.md. **C7.**

## Step 5 — SIGNOFF (~2–4 h)
Everything after routing: parasitic-accurate timing at 9 corners, GDS written
by two independent tools and XOR-compared, DRC by two decks, LVS against your
netlist:
```bash
sbatch lab10/signoff.sbatch
```
When done:
```bash
R=$(ls -dt runs/RUN_* | head -1)
grep -m1 "COUNT" $R/*-magic-drc/magic-drc.log          # want COUNT: 0
grep -m1 -ai "uniquely" $R/*-netgen-lvs/netgen-lvs.log # want: Circuits match uniquely.
cat $R/error.log
```
**Record** all three → **C8**. (Hold violations at ff_n40C corners only may
appear in error.log — note them; the waiver conversation happens in Lab 11.)

## Step 6 — The timing table = your speed is now real 
```bash
cat $R/*-openroad-stapostpnr/summary.rpt
```
Fill **C9**: worst hold/setup per corner group, and compute your **achieved
period at SS** = CLOCK_PERIOD + max(0, −SS setup WNS). This number follows you
to the Lab 11. Setup negative at SS is not failure — it is your real
speed; write it down.

## Step 7 — EXTRACT YOUR MACRO ( the week's deliverable)
```bash
bash lab10/extract_macro.sh
```
**You must see:** `macro_kit/` listing with gds, lef, nl.v, lib/, PROVENANCE.txt.
**Record** → **C10**. This folder is your CPU as a sealed, reusable block, because in Lab 12 every artifact must trace to one run. From here on, `macro_kit/` is ALL that Labs
11–12 need from this week — but do NOT delete the run yet: Step 8's packager
still reads its logs.

## Step 8 — Reports + submit
```bash
cp lab8/REPORT_TEMPLATE.md reports/<name>_lab10.md   # each member
bash lab10/make_submission_zip.sh <teamnumber>
scp <netid>@olympus.ece.tamu.edu:~/ecen689_lab8/lab10_team<N>_submission.zip .
```
**After the zip is built and uploaded — reclaim your ~15 GB for Labs 11–12:**
```bash
rm -rf runs/RUN_*      # macro_kit/ + the submission zip hold everything that matters
df -h ~                # verify the space came back
```

## Grading (100 = 60 team + 40 individual)
### Team (60)
| Item | Evidence | Pts |
|---|---|---|
| CTS done + understood | C1, C2 | 8 |
| Reference literacy | C3, C4 | 8 |
| Routing outcome | C5 clean **or** C7 complete DEBUG.md + recovery | 15 |
| Prediction reckoning | C6 honest analysis | 4 |
| Signoff verdicts | C8 three lines | 10 |
| Timing read correctly | C9 incl. achieved-period arithmetic | 7 |
| Macro kit + provenance | C10 | 5 |
| Submission hygiene | script-built, on time | 3 |
### Individual (40): specific contribution 15 · real errors 10 · diagnosis path 15.

