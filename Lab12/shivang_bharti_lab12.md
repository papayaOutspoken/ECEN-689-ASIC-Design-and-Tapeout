# ECEN 689 — Lab 12 Individual Report

**Name:** Shivang Bharti  
**NetID:** shivangbharti  
**Team:** 5

## 1. What I personally contributed

My main contribution was carrying the C4 Microwatt configuration through core implementation, SRAM integration, and chip-level verification. I evaluated area and routability with the FPU disabled, 16 instruction-cache lines, 8 data-cache lines, and a 50 ns clock target. I investigated the 3300 and 3650 um floorplan failures and completed routing and extraction at 2900 x 3900 um. I then integrated the hardened core with two ChipFoundry 1024x32 SRAMs and investigated chip routing, DRC, LVS, and timing failures using the stage reports.

For Lab 12, I applied the prescribed routing obstructions and floorplan changes, evaluated a routing-layer experiment, and used a targeted buffer-placement correction to resolve the remaining congestion. I checked the resulting chip against the actual KLayout metric, LVS verdict, nine-corner timing table, and tapeout frame limits. I also traced the remaining Magic markers to the SRAMs and prepared the verification evidence and timing-exception draft.

## 2. Problems I encountered

The most difficult problem was chip routing across an otherwise clean core macro. The first chip run completed its stages but reported 671 routing DRC errors, 1386 KLayout errors, and six LVS errors. The original Lab 11 KLayout counting command could incorrectly print zero; reading `klayout__drc_error__count` in `final/metrics.json` exposed the actual result. Inspection showed chip wires crossing the core footprint.

The Lab 12 CASE 2 changes prevented those crossings, but the next run stopped at global routing with `[GRT-0116]`. Congestion reports showed overflow associated with `delaynet_8_clk`, `net788`, and `net786`. Raising the minimum routing layer moved the overflow from met1 to met3 without removing it.

Earlier in the project, the 3300 and 3650 um core runs stopped with `[GRT-0183]` heap-underflow errors during antenna repair. The 3900 um run exceeded its 12-hour allocation during detailed routing, and a subsequent RCX interruption coincided with exhausted disk space. These failures required distinguishing tool errors from resource limits before choosing where to restart.

## 3. How I resolved the problems and what I would redo

**Core implementation:** Increasing the core height to 3900 um allowed routing to complete. I used Slurm accounting and stage logs to identify the timeout, then resumed from completed checkpoints. After freeing space, I restarted RC extraction without repeating synthesis, placement, and CTS. This showed that placement completion alone was insufficient evidence of routability.

**Chip routing:** I retained the Lab 12 CASE 2 settings and moved `delaybuf_8_clk`, `wire786`, and `wire787` into the open corridor above the core. Detailed placement legalized the cells, and the routing probe reported zero overflow. I then reran global routing through extraction and signoff from the modified checkpoint. This placement correction was an additional experiment beyond the manual; the Tcl scripts and checkpoint provenance preserve how it was performed. The RTL and hardened core were unchanged.

The resulting run, `RUN_2026-11-23_09-26-12`, has **zero final routing DRC errors, zero KLayout DRC errors, and matching LVS**. Its 3160 x 4680 um die fits the 3166.63 x 4766.63 um frame. All nine chip corners have zero register-to-register hold violations and zero setup violations. The core's internal SS setup slack still determines the achieved period: 50 + 4.2573 = **54.2573 ns**, approximately **18.43 MHz**. The unchanged core benchmark passed in 419 cycles, giving **22.7338087 us** at that period.

**Measured implementation results:**

| Measurement | Result |
|---|---:|
| Hardened core dimensions / die area | 2900 x 3900 um / 11.31 mm² |
| Final chip dimensions / die area | 3160 x 4680 um / 14.7888 mm² |
| Remaining frame margin, width / height | 6.63 um / 86.63 um |
| SRAM capacity | Two 1024 x 32-bit macros; 8 KiB total |
| Final chip routed wire length | 633,224 um (633.224 mm) |
| Core benchmark | PASS; checksum 500; 419 cycles |
| Achieved period including core internal timing | 54.2573 ns |
| Corresponding frequency / benchmark execution time | 18.43 MHz / 22.7338087 us |

The areas above are geometric die areas, not synthesized cell areas. The benchmark is the required core simulation; the execution time is calculated using the achieved SS period, not measured on silicon.

**Physical-verification improvement:**

| Check | Original chip run, Nov. 12 | Corrected chip run, Nov. 23 |
|---|---:|---:|
| Final routing DRC errors | 671 | 0 |
| KLayout DRC errors | 1386 | 0 |
| LVS errors | 6 | 0; circuits match uniquely |
| Magic DRC markers | 12,274 | 245 |
| Magic illegal-overlap markers | 1089 | 4 |

This comparison records two distinct runs; all final chip results come from `RUN_2026-11-23_09-26-12`. The remaining Magic markers are discussed below.

**Chip timing across all nine corners:**

| Corner | Worst setup slack (ns) | Worst hold slack, all paths (ns) | Worst register-to-register hold slack (ns) |
|---|---:|---:|---:|
| nom_tt_025C_1v80 | 29.3557 | 1.3296 | 1.3296 |
| nom_ss_100C_1v60 | 21.7304 | -0.2519 | 2.2872 |
| nom_ff_n40C_1v95 | 32.5174 | 1.2246 | 1.2246 |
| min_tt_025C_1v80 | 29.9584 | 1.4603 | 1.4603 |
| min_ss_100C_1v60 | 22.6815 | 2.4335 | 2.4335 |
| min_ff_n40C_1v95 | 32.9599 | 1.3412 | 1.3412 |
| max_tt_025C_1v80 | 28.8611 | 1.2063 | 1.2063 |
| max_ss_100C_1v60 | 20.9656 | -0.7002 | 2.2378 |
| max_ff_n40C_1v95 | 32.1286 | 1.1439 | 1.1439 |

There are zero setup violations and zero register-to-register hold violations at every chip corner. Negative all-path hold entries are input-port paths. The chip table models core interface timing; the Lab 10 internal core result must still be included when calculating achieved speed. The timing summary also reports overall counts of 150 maximum-capacitance violations and 1052 maximum-slew violations.

Sources: the final chip run's `final/metrics.json` and `17-openroad-stapostpnr/summary.rpt`, `macro_kit/metrics.json`, and `lab11/sim_final.log`. Original-run counts are retained in the Lab 11 individual report and submission evidence.

**Remaining exceptions:** LibreLane still returned a deferred failure. All 245 Magic DRC markers lie inside the SRAM bounds; the four extraction-overlap markers lie on SRAM met2 pin shapes. Their locations, the vendor-layer warnings, clean KLayout, and matching LVS support a Magic vendor-view interpretation issue. The SS hold failures start at `rst` and `ext_irq` under the default 10 ns input constraints, matching the Lab 11 D5 case. Capacitance and slew warnings remain, and the core's two internal fast-corner hold violations, worst -0.0182 ns, remain pending waiver approval. I have not treated flow completion as unconditional signoff.

**What I would redo:** I would inspect macro pin access, routing obstructions, and the specific congested nets before launching another full assembly run. I would also reserve disk headroom and plan checkpoint boundaries before long jobs. The main lesson was to diagnose the failing geometry or timing path directly: unused routing capacity elsewhere on the chip did not resolve connections trapped around the core, and a scheduler failure did not by itself identify which verification checks failed.
