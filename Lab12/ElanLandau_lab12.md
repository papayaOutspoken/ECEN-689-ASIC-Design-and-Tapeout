# Lab 8 individual report  (copy as reports/<your_name>.md - one per member)
Name: Elan landau
NetID: 237007971
Team: 5

# What I did this lab

For lab 12 I checked the `answers.txt` of both my design and the Small design.

# Lab12 answers.txt

The below is the answers.txt for the 2 cache line design, including the drc information and the 9 corners.

```bash
[elandau2@olympus-login ecen689_lab12]$ R=$(cat lab12/FROZEN_RUN.txt)
[elandau2@olympus-login ecen689_lab12]$ cat $R/error.log
Error while reading cell "CF_SRAM_1024x32_macro" (byte position 44100): Unknown layer/datatype in boundary, layer=67 type=10

Error while reading cell "CF_SRAM_1024x32_macro" (byte position 44164): Unknown layer/datatype in boundary, layer=68 type=10

Error while reading cell "CF_SRAM_1024x32_macro" (byte position 44228): Unknown layer/datatype in boundary, layer=69 type=10

245 Magic DRC errors found. - deferred
4 Magic Illegal Overlap errors found. - deferred
[elandau2@olympus-login ecen689_lab12]$ grep '"klayout__drc_error__count"' $R/final/metrics.json   # must be 0
    "klayout__drc_error__count": 0,
[elandau2@olympus-login ecen689_lab12]$ grep -m1 "COUNT" $R/*-magic-drc/magic-drc.log      # nonzero expected; one-line artifact note
[INFO] COUNT: 245
[elandau2@olympus-login ecen689_lab12]$ grep -m1 -ai "uniquely" $R/*-netgen-lvs/netgen-lvs.log
Circuits match uniquely.
[elandau2@olympus-login ecen689_lab12]$ cat $R/*-openroad-stapostpnr/summary.rpt            # whole table: the SS rows are at the bottom
┏━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┓
┃                      ┃ Hold     ┃ Reg to   ┃          ┃          ┃ of which  ┃ Setup    ┃           ┃          ┃           ┃ of which ┃           ┃          ┃
┃                      ┃ Worst    ┃ Reg      ┃          ┃ Hold Vio ┃ reg to    ┃ Worst    ┃ Reg to    ┃ Setup    ┃ Setup Vio ┃ reg to   ┃ Max Cap   ┃ Max Slew ┃
┃ Corner/Group         ┃ Slack    ┃ Paths    ┃ Hold TNS ┃ Count    ┃ reg       ┃ Slack    ┃ Reg Paths ┃ TNS      ┃ Count     ┃ reg      ┃ Violatio… ┃ Violati… ┃
┡━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━┩
│ Overall              │ -0.3109  │ 0.1646   │ -0.3109  │ 1        │ 0         │ 23.2701  │ 27.5770   │ 0.0000   │ 0         │ 0        │ 37        │ 193      │
│ nom_tt_025C_1v80     │ 0.6018   │ 0.6018   │ 0.0000   │ 0        │ 0         │ 30.7563  │ 38.0484   │ 0.0000   │ 0         │ 0        │ 33        │ 64       │
│ nom_ss_100C_1v60     │ 0.3656   │ 0.6556   │ 0.0000   │ 0        │ 0         │ 24.1490  │ 28.2133   │ 0.0000   │ 0         │ 0        │ 33        │ 175      │
│ nom_ff_n40C_1v95     │ 0.6034   │ 0.6034   │ 0.0000   │ 0        │ 0         │ 33.4768  │ 41.9542   │ 0.0000   │ 0         │ 0        │ 33        │ 42       │
│ min_tt_025C_1v80     │ 0.9054   │ 0.9054   │ 0.0000   │ 0        │ 0         │ 31.3046  │ 38.5889   │ 0.0000   │ 0         │ 0        │ 24        │ 50       │
│ min_ss_100C_1v60     │ 1.0221   │ 1.0841   │ 0.0000   │ 0        │ 0         │ 25.0175  │ 28.9262   │ 0.0000   │ 0         │ 0        │ 24        │ 137      │
│ min_ff_n40C_1v95     │ 0.7811   │ 0.7811   │ 0.0000   │ 0        │ 0         │ 33.8923  │ 42.3546   │ 0.0000   │ 0         │ 0        │ 24        │ 41       │
│ max_tt_025C_1v80     │ 0.2278   │ 0.2278   │ 0.0000   │ 0        │ 0         │ 30.1551  │ 37.5778   │ 0.0000   │ 0         │ 0        │ 37        │ 71       │
│ max_ss_100C_1v60     │ -0.3109  │ 0.1646   │ -0.3109  │ 1        │ 0         │ 23.2701  │ 27.5770   │ 0.0000   │ 0         │ 0        │ 37        │ 193      │
│ max_ff_n40C_1v95     │ 0.4485   │ 0.4485   │ 0.0000   │ 0        │ 0         │ 33.0084  │ 41.6097   │ 0.0000   │ 0         │ 0        │ 37        │ 51       │
└──────────────────────┴──────────┴──────────┴──────────┴──────────┴───────────┴──────────┴───────────┴──────────┴───────────┴──────────┴───────────┴──────────┘
[elandau2@olympus-login ecen689_lab12]$ ls -lh $R/final/gds/chip_top.gds
-rwx------. 1 elandau2 1001409 839M Nov 16 05:52 /home/grads/e/elandau2/chip_runs2/RUN_2026-11-16_02-14-24/final/gds/chip_top.gds
[elandau2@olympus-login ecen689_lab12]$ md5sum $R/final/gds/chip_top.gds                    # <- the integrity hash
981ad8e7a830bb77ebaf1504e8f8be27  /home/grads/e/elandau2/chip_runs2/RUN_2026-11-16_02-14-24/final/gds/chip_top.gds
[elandau2@olympus-login ecen689_lab12]$ grep '"design__die__bbox"' $R/final/metrics.json    # frame check
    "design__die__bbox": "0.0 0.0 3160.0 4080.0",
```

# Design
The design I ran through most of these labs was a design that used 2 cache lines for the instruction and data. This was the smallest configuration that was able to be synthesized by the microwatt VHDL code.

We found that for the benchmark that was being run, the cache sizes don't actually matter. As such, the smallest cache design performs just as well on this toy problem as other design. This is because the benchmark fits in 2 cache lines of instruction cache and doesn't do very much data accesses. In practice, we decided not to go with this design mostly because it doesn't do as good a job at representing the larger sizes of taped-out processors one might see. In other words, if the benchmark was the only design that we every planned to run (as is technically the case in this lab where the benchmark is hard-coded in the silicon) then the processors just compete on cycle time and power. My design point of 2,2 would win. However, it is not as realistic of a core, and future classes that plan to verify and learn how to deal with more realistic tape-outs would likely benefit from a more realistic core than this one.

The floorplan of the design followed that of the labs, so the main core is below the 2 srams which serve as main memory above it. There's not a big reason to pick this design, except that the majority of the io of the core itself was on the top and right, so it made routing a bit easier.

The clock is calculated in the results section, but is somewhat higher than the initial expectation because of how small the whole thing is with only cache 2 lines.


# RESULTS
See the answers.txt section for the 9 corners, klayout and magic drc. Note that klayout drc is 0 but magic is not. This is because of undefined to magic layers that klayout understands, as we discussed in previous labs.

Fortunately, this design needed no waivers.

The numbers from the worksheet on this design from previous labs was:
   DIE height = H + 677 rounded = 4080   SRAM row y = H + 290 = 3690
   Legality: die 3160 x 4080 inside 3166.63 x 4766.63?  YES required.
   YES, legal.

   Achieved period at SS = 50 + max(0, -23.2701) = 50 ns  ->  frequency = 20 MHz

   If we didn't have the max in that formula it would be 50 - 23.2701 = 26.7299ns = 37.411 MHz

   For benchmark cycles
`core_tb_course.vhdl:108:29:@4295ns:(report note): BENCHMARK PASS checksum=500 cycles=419`

# JOURNEY (worst problems)

By far the worst challenge of this lab for me was when I tried to make use of the detailed placement results to go to routing. For a reason that was never determined, most of the detailed placement runs at various heights were corrupted and unusable. Fortunately, one of the runs (the last) still worked.

Debugging this issue involved running all the designs through the layout viewer to see any issues. In doing so 4 of the 5 were clearly bugged and missing the various layers. The run size I actually used was not bugged.

This issue was identified from the log indicated "no geometry" for the clock when using the corrupted runs.


In Lab 11 I had no real issues. I thought I had a hold violation issue, but I just misread the output and lab instructions. It was simply an async io pin  (which can be expected to give timing violations).

In Lab 10, other than the detailed placement runs not working, I also had issues with some hold violations which appeared as
"Hold violation failed in `flow.log`, `warning.log`, and `33-openroad-resizertimingpostcts/openroad-resizertimingpostcts.log`: `[RSZ-0064] Unable to repair all hold checks within margin.`"
and were fixed when I added at line 48 in `config.yaml`
```yaml
 PL_RESIZER_FIX_HOLD_FIRST: true # attempt to fix hold violation
 PL_RESIZER_HOLD_MAX_BUFFER_PCT: 60 # attempt to fix hold violation
```

In Lab 9 the only issue I had was because I originally wanted to use an even smaller cache line size, since my goal was to show that the smallest cache line size that could still go through all the desing and layout steps. I went with 2 because 1 failed. This wasn't a terrible bug because the error "-1 downto 0" made it pretty clear something was too small by 1 and I had only changed the cache size.

# Biggest contribution
Surprisingly I think my biggest contribution might genuinley be telling people to use srun to get interactive terminals in a batch job instead of trying to use olympus. I believe that before I had done this at least 2 teamates had waited over 30 minutes trying to load up the lab environment and being unable because the login node was too overloaded. If I had not done this, most team mates probably wouldn't have been able to finish the labs at all. I also made the github repo that we organized all our files in. I successfully convinced everyone in the group to work on the various parats together, which would have helped error resiliency if any teamate's design failed, but fortunately this did not occur.

# Worst day
My worst day goes back to that day were most of the detailed placement results were missing. This wasn't a huge deal since I was able to find a working design, but it was the day were the most problems occurred.
# What to Redo
If I had to redo something I think it would be the detailed placement. I might be able to run more heights through the whole process to compare how they affect final timing. Since the chip taped out fine (with above expected worst-case clock) this is not particularly important, but would be high on my list if I were to continue working on this project.
