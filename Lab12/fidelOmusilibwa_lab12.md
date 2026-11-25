# Lab 12 individual report — Fidel Omusilibwa (Team 5)

## 1. What I personally did in this lab

**Labs 8-9 (core design).** I compiled the Microwatt core, created
`microwatt_top.vhdl` with configuration M (I-cache 32 / D-cache 32, no FPU), ran the
multiply testbench including the break-test on `multiply.vhdl` line 66 (6 of 7 vectors
failed with the sign flipped, then passed after restoring), and synthesized it
(4,765,382 um^2 in Lab 8; 5,272,338 um^2 / 386,874 cells in the Lab 9 flow). I simulated
four cache configurations (S, M, L, 64/16 - all 419 cycles, because the benchmark loop
lives in one cache line) and ran three placement heights (4050, 3900, 3750 um) in
parallel from separate folders; all three placed, and 4050 (44.9 %) became the floorplan.

**Lab 10 (core hardening) - my biggest contribution.** I took the core from placement to
a signed-off macro: CTS, routing, RCX and signoff with Magic DRC `COUNT: 0`, LVS
`Circuits match uniquely.`, 0 hold violations at all 9 corners, and an achieved SS
period of 53.6029 ns. Getting there required diagnosing two failures (below) and
writing my own job scripts with explicit starting states (`--with-initial-state`) for
every resumed stage.

**Lab 11 (chip assembly).** I did the chip worksheet (H = 4050 -> die 4730, SRAM y 4340),
ran three full chip assemblies, and traced every routing short and KLayout error to a
single reset net crossing the core. My chip completed the flow but with DRC errors
(KLayout 663-843), and I chose not to keep fixing it (see section 3). I also merged all six members' Lab 11 submissions
into one team package around Jinzhan's run, which was the only one passing every gate.

**Lab 12 (freeze).** I classified my chip's DRC result with `lab12/drc_where.py` as
CASE 2 (core clean: `core macro KLayout errors (Lab 10): 0`) and completed the freeze
checklist for the team's frozen run (Jinzhan's: KLayout 0, LVS match, reg-to-reg hold
clean, 21,815.6 ns benchmark).

## 2. Problems I encountered

**Worst day - Lab 10 CTS (12 hours lost).**
```
slurmstepd: error: *** JOB 734863 ON n03-poseidon CANCELLED AT 2026-11-05T06:14:36 DUE TO TIME LIMIT ***
```
The post-CTS repair crawled at WNS -275 ns, TNS -8,374,752, 67,127 failing endpoints.

**Lab 10 RCX - disk full.** Routing job 737141 `FAILED 1:0` after 6 h 50 m in
`46-openroad-rcx`; `df -h ~` showed `50G 50G 0 100% /home/grads`.

**Lab 10/12 - container could not see scratch.**
```
ERROR    last_run used without any existing runs
OSError: [Errno 30] Read-only file system: '/mnt/nfs-scratch'
```

**Lab 11 - chip-level DRC on my assembly.** Three runs: 100 / 14 / 15 routing shorts,
KLayout 696 / 663 / 843, each time one net (`net714`, `net721`, `net718`) against
`inst:u_core` on met1.

**Lab 12 - CASE 2 settings on my assembly.**
`[GRT-0116] Global routing finished with congestion` (met1 overflow 421, then met5 412).

## 3. How each problem was resolved (or why I stopped)

**CTS timeout.** The worst path showed a nor2 driving fanout 8,120 with 1.8 us slew, yet
design repair (step 25) reported `Inserted 86651 buffers ... Remaining 0`. I counted
references to that net (`_159883_`) in each step's netlist: 8122 (synthesis) -> 4 (step 25)
-> 4 (step 27) -> 8122 (CTS). `29-openroad-cts/state_in.json` pointed at
`19-openroad-ioplacement`: the resume had picked a pre-placement state, most likely
because a KLayout viewing step (`28-klayout-opengui`) sat in the run folder. Fix: moved
steps 28-31 aside and relaunched with
`--with-initial-state .../27-openroad-detailedplacement/state_out.json`; job 735964
completed in 6 h 45 m with 13,917 clock buffers and 0.518 ns skew.

**Disk full.** Routing itself was clean (0 overflow, 0 violations), so only RCX was rerun:
I copied the 9.4 GB run to shared scratch (file counts verified), linked it back as
`~/chip_runs`, and reran RCX alone from step 45 (3 min 56 s).

**Container binds.** `env.sh` sets `SINGULARITY_BIND="/var/tmp/$USER,$ECEN689_SHARE"`;
my first fix replaced that list and hid the PDK. Appending
(`export SINGULARITY_BIND="$SINGULARITY_BIND,/mnt/shared-scratch"`) and testing
`singularity exec "$OL_SIF" ls $PDK_ROOT` inside an `srun` session fixed it for RCX,
signoff and every later chip run.

**Chip DRC.** DEF placements showed the cause: the net's driver and load sat on opposite
sides of the core (e.g. `wire714` at x = 110.9 um, flop `_173_` at x = 3050.7 um). My
core has `clk`, `rst` and the instruction-bus control pins on its left edge but the data
bus on the right, so the glue logic is split across it. Moving the chip `rst`/`clk` pins
cut the shorts from 100 to 14 but never to 0. `drc_where.py` confirmed CASE 2, and the
reference CASE 2 settings made global routing fail (GRT-0116) because that one net had
no legal path. The real fix was re-hardening the core with all its pins on one edge,
which meant redoing Lab 10 (a 13+ hour CTS and routing cycle) right before the freeze.
**I decided not to do that.** My chip was left with its DRC errors and was not used for
tapeout; the team froze Jinzhan's run instead, which passes every gate. This problem is
not resolved on my chip - the decision was to put the team's time into the clean run.

