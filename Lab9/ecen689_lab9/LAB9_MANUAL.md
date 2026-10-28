# ECEN 689 — Lab 9: Your CPU Runs a Program, and Becomes a Floorplan
**Project stage 2 of 5 · One week**

Follow steps in order: type → you must see → record.

## Where you are on the road to tapeout

**THE FRAME (now with its real shape):** the ChipFoundry OpenFrame user area is
a **3166.63 µm × 4766.63 µm rectangle**. In Lab 11 your core shares that
rectangle with two SRAM macros and chip-level margins. Therefore YOUR CORE this
week gets a hard geometry budget:

> **CORE DIE: width = 2900 µm (fixed) · height ≤ 4050 µm **

Width is fixed for everyone — it guarantees chip-level legality later and makes
placement results comparable across teams.

## What you must deliver
`lab9/answers.txt` (B1–B9, two measured frontiers) · `config.yaml` ·
`microwatt_top.vhdl` · benchmark sim logs (one per config tried) · placement
screenshot · all team members individual reports · one team ZIP on Canvas.

## Step 0 — Add the Lab 9 kit
```bash
scp ecen689_lab9.zip <netid>@olympus.ece.tamu.edu:
ssh <netid>@olympus.ece.tamu.edu
cd ~/ecen689_lab8        # your existing project folder — everything continues here
unzip ~/ecen689_lab9.zip
ls lab9
```
**You must see:** `core_tb_course.vhdl  config_template.yaml  synth_only.sbatch
to_placement.sbatch  answers.txt  make_submission_zip.sh`

## Step 1 — Your CPU executes a real program 

The course testbench wires YOUR configured core to a standard memory model
preloaded with a test program (identical for every team). The CPU boots,
executes it, and the TB checks the result and counts cycles.
```bash
cd microwatt_src
cp ../lab9/core_tb_course.vhdl .
ghdl -i --std=08 $(cat ../lab8/core_files.txt) microwatt_top.vhdl core_tb_course.vhdl
ghdl -m --std=08 core_tb_course
ghdl -r --std=08 core_tb_course | tee ../lab9/sim_$(whoami).log
```
**You must see:** `BENCHMARK PASS checksum=500 cycles=<N>`
> **If it didn't work:** `cannot find entity` → you skipped the `-i` line or

## Step 2 — CONFIG SQUAD: map the configuration frontier

Your configuration is the one design lever you fully own, and it follows your
core all the way to the final design evaluation — so characterize it now, with
data, not opinions. For **at least 4 configurations** (S, M, L from Lab 8 + at
least one custom — e.g., asymmetric icache/dcache):
1. Edit the CFG block in `microwatt_top.vhdl` (3 lines, Lab 8 Step 4b).
2. Re-run Step 1, saving each log: `... | tee ../lab9/sim_<configname>.log`
3. Fill a row of **B1** (config | cycles | wall time | who ran it).

**Note:** the cycle count will come out the same for every configuration —
that is the correct result for this benchmark, not a broken setup. Part of
B2 is explaining to yourselves why, and deciding what that means for your
choice.

Two members = two parallel sims in separate copies of the folder; merge results.
**B2:** pick the team's final configuration; justify in 3 sentences **from your
own measurements** — including why the cycles didn't move, and what you based
your choice on instead. There is no "right" config to copy — your data and
reasoning are your argument. Set `microwatt_top.vhdl` to it — this is the
config the flow runs hardens from now through Lab 12.

## Step 3 — Flow synthesis of the final config (Config squad, Wed)
```bash
cd ~/ecen689_lab8
cp lab9/config_template.yaml config.yaml
nano config.yaml      # set CLOCK_PERIOD if you dare change it; leave DIE_AREA for Step 4
mkdir -p ~/chip_runs && ln -sfn ~/chip_runs runs
sbatch lab9/synth_only.sbatch
squeue -u $USER
```
When done (~30 mins at best):
```bash
grep -iE "Number of cells|Chip area" runs/RUN_*/*-yosys-vhdlsynthesis/*.log | tail -4
ls -lh runs/RUN_*/*-yosys-vhdlsynthesis/microwatt_top.nl.v
```
**Record** area → **B4** (fit check!), and the netlist line → **B5**.
**Note what just happened:** the flow CREATED and SAVED your gate-level netlist
(~100 MB). Every later step consumes it through the run's state chain — you
never copy it by hand. That file, matured through Lab 10, becomes your macro.

## Step 4 — FLOORPLAN SQUAD: the worksheet, then the frontier

**Worksheet (B3)** — pure arithmetic, no judgment calls:
```
H_min = chip_area / (0.45 × 2900)     # denser than 45% risks routing failure
H_max = chip_area / (0.35 × 2900)     # sparser than 35% wastes silicon, hurts timing
```
Pick **≥3 heights** spanning that range (cap 4050, round to 50). For each, one
flow run:
```bash
nano config.yaml          # DIE_AREA: [0, 0, 2900, <H>]
sbatch lab9/to_placement.sbatch
```
Runs are ~2–4 h and your team queues ONE at a time — this is why floorplan
exploration will take time and why the squad of 2 or more will be needed for parallel execution.
**Exploration runs may be launched from any member's account, but all run
evidence must end up in the ONE designated submission folder before packaging
(Step 7 has the exact commands), and the CHOSEN height's run must be launched
from that designated folder — Lab 10 resumes it there.** For each
run fill **B6**: W×H | implied utilization (chip_area/ (WxH)) | cat runs/RUN_<that run>/error.log — empty = ok; `DPL-0036` = too dense; anything else = "other" with the line result.
**Note: a `DPL-0036` row is not a failed deliverable — it's a data point that tells you where your real H_min is. Grading explicitly rewards recorded failures ("B6 ≥3 runs incl. any failures recorded").**
**B7:** choose your floorplan. A decision not measurement.Pick height you'll carry into routing and future labs.

> **Why these two numbers aren't cosmetic:** at 55% utilization the reference
> design failed placement; at 48% it failed routing; at 42–45% it passed
> everything. Your frontier tells you where YOUR configuration's cliff is —
> before Lab 10's 12-hour routing runs make each mistake cost a day.

## Step 5 — VERIFICATION: look at the placement
```bash
# ssh -Y, on the team's chosen run:
lane config.yaml --last-run --flow OpenInKLayout
```
Screenshot → `lab9/placement_<H>.png`. **B8:** one observation (densest region? how even is the fill?).

## Step 6 — The Lab 10 prediction B9
Routing is next week's expensive step. Commit to a prediction: will your chosen
point route? Evidence: your frontier spacing, the reference cliff data above,
your Lab 8 area. (Graded on reasoning now — and revisited against reality in
Lab 10. Honest wrong beats lucky vague.)

## Step 7 — Individual reports + submit

**First: pool the team's work into the ONE submission folder.** The packager
only collects what it finds in the designated member's `~/ecen689_lab8`. NEVER
share passwords or log in as someone else — move files with read permissions
instead:
```bash
# EACH teammate, once, from their OWN account - lets the submitter read your files:
setfacl -m u:<submitter_netid>:x $HOME
setfacl -R -m u:<submitter_netid>:rX ~/ecen689_lab8/lab9 ~/ecen689_lab8/reports ~/chip_runs

# SUBMITTER pulls teammates' benchmark sim logs + reports:
cp ~<teammate_netid>/ecen689_lab8/lab9/sim_*.log  lab9/
cp ~<teammate_netid>/ecen689_lab8/reports/*lab9*.md  reports/

# SUBMITTER pulls a teammate's placement-run EVIDENCE (small files only - do NOT
# copy whole multi-GB runs). Repeat per run:
T=~<teammate_netid>/chip_runs/RUN_<tag>
mkdir -p ~/chip_runs/RUN_<tag>/01-yosys-vhdlsynthesis
cp $T/error.log $T/resolved.json  ~/chip_runs/RUN_<tag>/  2>/dev/null
cp $T/*-yosys-vhdlsynthesis/*.log ~/chip_runs/RUN_<tag>/01-yosys-vhdlsynthesis/ 2>/dev/null
```

Then package:
```bash
cp lab8/REPORT_TEMPLATE.md reports/<name>_lab9.md    # each member, Aggie honor code
bash lab9/make_submission_zip.sh <teamnumber>
scp <netid>@olympus.ece.tamu.edu:~/ecen689_lab8/lab9_team<N>_submission.zip .
```
The packager refuses incomplete submissions and auto-collects every run's
synthesis numbers + error logs — your failures are evidence, not embarrassments.

## Grading (100 = 60 team + 40 individual)
### Team (60)
| Item | Evidence | Pts |
|---|---|---|
| Config frontier measured | B1 ≥4 real PASS lines | 12 |
| Final config justified | B2 | 5 |
| Worksheet + fit | B3 arithmetic right, B4 PASS | 8 |
| Netlist custody | B5 | 3 |
| Placement frontier | B6 ≥3 runs incl. any failures recorded | 15 |
| Floorplan choice + view | B7, B8 | 7 |
| Prediction | B9 reasoning | 5 |
| Submission hygiene | script-built, complete, on time | 5 |
### Individual (40) — your report
What I personally did (specific, verifiable) 15 · problems with real error
lines 10 · diagnosis path 15. Missing report = 0/40 for that member.
*Six people, four sims, three flow runs, one week: a member without a
verifiable personal contribution will be visible. Plan accordingly.*
