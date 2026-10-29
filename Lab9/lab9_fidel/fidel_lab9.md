# Lab 9 Individual Report — Fidel Makatia (Team 5)

## 1. What I personally did

I ran every step below myself on the olympus login node, in my project folder
`~/ASIC_Project/ecen689_lab8`, and read all tool output.

- **Step 1 (CPU runs a program):** Loaded the course environment, copied
  `core_tb_course.vhdl` into `microwatt_src/`, analyzed all core files plus
  `microwatt_top.vhdl`, and ran the benchmark. Result:
  `BENCHMARK PASS checksum=500 cycles=419`.
- **Step 2 (config frontier, B1):** Simulated four configurations, editing only the
  CFG block each time and timing each run with `time (...)`:

  | Config | ICACHE / DCACHE | Cycles | Wall time | Log |
  |---|---|---|---|---|
  | S | 16 / 16 | 419 | 5.0 s | `lab9/sim_S.log` |
  | M | 32 / 32 | 419 | 5.1 s | `lab9/sim_M.log` |
  | L | 64 / 64 | 419 | 5.3 s | `lab9/sim_L.log` |
  | Custom | 64 / 16 | 419 | 5.1 s | `lab9/sim_I64D16.log` |

  I confirmed each edit with `grep "CFG_.*NUM_LINES" microwatt_top.vhdl` before
  running, then set the file back to the final config, M (32/32).
- **Step 3 (flow synthesis, B4/B5):** Created `config.yaml` from the template, set up
  `~/chip_runs` with the `runs` symlink, and submitted
  `sbatch --cpus-per-task=4 lab9/synth_only.sbatch` (job 722074, ~25 min). Result
  from `reports/stat.rpt`: **386,874 cells, 5,272,337.84 µm²** (fits under 5,800,000).
  Netlist: `runs/RUN_2026-10-28_17-55-43/01-yosys-vhdlsynthesis/microwatt_top.nl.v` (61 MB).
- **Step 4 (floorplan frontier, B3/B6/B7):** Computed the worksheet from the Step 3
  area (H_min = H_max = 4050 after rounding and the cap), then launched three
  placement runs, all with width 2900:

  | Height | Utilization | Job | Run folder | Result |
  |---|---|---|---|---|
  | 4050 | 44.9% | 722159 | `RUN_2026-10-28_18-36-01` | COMPLETED 0:0, error.log empty |
  | 3900 | 46.6% | 722228 | `RUN_2026-10-28_19-25-16` | COMPLETED 0:0, error.log empty |
  | 3750 | 48.5% | 722232 | `RUN_2026-10-28_19-26-35` | COMPLETED 0:0, error.log empty |

  The 4050 run was launched from the main folder (for Lab 10); I ran 3900 and 3750
  in parallel from separate folder copies. I chose 4050 (B7).
- **Step 5 (placement view, B8):** Opened the 4050 run in KLayout and captured
  `lab9/placement_4050.png`.
- **Step 6 (B9):** Wrote the routing prediction from the frontier, utilization, and
  area data.

## 2. Problems I encountered

**Problem 1 — disk full on the shared home filesystem.** Editing `config.yaml`
before the first placement run failed:
```
sed: couldn't open temporary file ./sedas1EuT: No space left on device
```
and `grep DIE_AREA config.yaml` still showed the template's `3600`.

**Problem 2 — area not found in the synthesis logs.** The manual's command returned
nothing:
```
grep -iE "Number of cells|Chip area" runs/RUN_*/*-yosys-vhdlsynthesis/*.log | tail -4
```
and a broader search found two different areas for the same design:
```
Chip area for module '\microwatt_top': 2515416.233599
Chip area for module '\microwatt_top': 5272337.840003
```

**Problem 3 — area larger than Lab 8, collapsing the worksheet range.** The same M
configuration measured 4,765,382 µm² in Lab 8 but 5,272,338 µm² in the Lab 9 flow.
With the new area, H_min = 5,272,338 / 1305 = 4040.1 → 4050 and H_max = 5194.4 →
capped at 4050, so the allowed range was a single height, while B6 requires ≥3 runs.

**Problem 4 — only one run at a time, and a shared config file.** Each placement run
takes ~4 h. Changing `config.yaml` in the main folder and resubmitting risked a
queued job reading the wrong height, and `lane --last-run` would open whichever run
finished last instead of my chosen 4050 run.

**Problem 5 — cycle count identical for every configuration.** All four configs
gave `cycles=419`, so the benchmark could not separate them on performance.

## 3. How they were resolved

**Problem 1:** I checked space before launching anything that writes gigabytes.
`df -h ~` showed `/home/grads` is a 50 GB filesystem shared by all grad students
(22 GB free at that point, later 18 GB), so the error came from shared usage
rather than my files. Once space was available the `sed` edit succeeded, and I
verified `DIE_AREA: [0, 0, 2900, 4050]` with `grep`. I also measured the first run
with `du -sh` (1.1 GB partway through) before queuing more runs.

**Problem 2:** I listed the synthesis step folder and found a `reports/` directory,
then searched it: `grep -rilE "chip area|number of cells"` matched
`reports/post_dff.rpt` and `reports/stat.rpt`. `post_dff.rpt` is an intermediate
snapshot, so the final value is the one in `stat.rpt` (5,272,337.84). The cell count
was not labeled "Number of cells"; `head -30 reports/stat.rpt` showed it as
`386874 5.27E+06 cells`.

**Problem 3:** Comparing the cell lists explained the increase: the Lab 8 log used
`_1` cells (e.g. `sky130_fd_sc_hd__a21o_1`) while the Lab 9 `stat.rpt` uses `_2`
cells (e.g. `sky130_fd_sc_hd__a21o_2`), which are larger drive-strength variants. I
recomputed B3 with the official Step 3 area instead of the Lab 8 estimate. Since
only 4050 was inside the rule, I deliberately chose 3900 (46.6%) and 3750 (48.5%) as
denser points to locate our placement cliff, which the manual treats as valid data.

**Problem 4:** I created separate folders (`~/ASIC_Project/lab9_h3900` and
`lab9_h3750`), each with its own copy of `microwatt_src/`, `lab8/`, `lab9/` and
`config.yaml`, and a `runs` symlink to `~/chip_runs`. Before submitting, I checked
`grep -nE "ecen689_lab8|cd " lab9/to_placement.sbatch`, which showed only
`cd "$SLURM_SUBMIT_DIR"`, so each job would read the config in the folder it was
submitted from. Because the runs started close together, I matched each run folder
to its height by grepping `DIE_AREA` in its `config.json` rather than by start
time, and confirmed completion with
`sacct -j 722159,722228,722232` (all `COMPLETED 0:0`, ~4 h each). For the screenshot,
I checked the layout's aspect ratio (≈1.40 = 4050/2900, versus 1.34 for 3900 and
1.29 for 3750) to confirm I was viewing the 4050 run.

**Problem 5:** The simulation log showed every instruction address between `0x00`
and `0x24` and every fetch as `cache hit ... idx:00`, so the whole program fits in
one cache line and cache size cannot change the cycle count. I therefore based the
final config on area and risk instead: M has a measured fit, and S remains the
fallback if Lab 10 routing needs more room.