# ECEN 689 — Lab 9 Individual Report

**Shivang Bharti | UIN: 637003202**  
**Your CPU Runs a Program, and Becomes a Floorplan**

## What I personally did

I inspected the synthesis, floorplan, global-placement, and detailed-placement logs for three Microwatt runs using the chosen 16I/8D cache configuration (16 instruction-cache lines and 8 data-cache lines). I checked each run’s error log and compared implementation metrics. My review covered the following saved runs:

I used the final mapped synthesis area of 4,272,735.392004 µm² to check the worksheet calculations:

- H_min = 4,272,735.392004 / (0.45 × 2900) = 3274.126737 µm.
- H_max = 4,272,735.392004 / (0.35 × 2900) = 4209.591519 µm.
- Applying the lab's 4050 µm height cap gives an exploration interval from approximately 3274.13 to 4050 µm. The tested points were 3300, 3650, and 4050 µm.

| Cache configuration and height | Die dimensions (µm) | Implied utilization | error.log |
|---|---|---:|---|
| 16I/8D cache configuration, H = 3300 µm | 2900 × 3300 | 44.65% | Empty |
| 16I/8D cache configuration, H = 3650 µm | 2900 × 3650 | 40.37% | Empty |
| 16I/8D cache configuration, H = 4050 µm | 2900 × 4050 | 36.38% | Empty |

I investigated why synthesis printed two different areas and why the flow reported several utilization values. I narrowed the searches to the surrounding log lines, identified the mapping stage associated with each area, and reproduced the global placer's utilization calculation from its reported area statistics.

Finally, I compared the three placement results to select a height for routing:

| Metric | 3300 µm | 3650 µm | 4050 µm |
|---|---:|---:|---:|
| HPWL after detailed-placement mirroring (µm) | 19,053,661.6 | 19,722,501.0 | 20,148,343.5 |
| Final weighted congestion | 1.0383 | 1.0451 | 1.0423 |
| Timing-repair buffer count | 73,414 | 74,395 | 76,066 |
| Total placed instance area (µm²) | 5,125,112.89 | 5,150,189.44 | 5,186,840.84 |

## Problems encountered and diagnosis path

### 1. Two synthesis areas appeared for the same top module

The synthesis log reported:

```text
Chip area for module '\microwatt_top': 2019156.531202
Chip area for module '\microwatt_top': 4272735.392004
```

I used `grep -n -B 20 -A 8 'Chip area for module'` on the synthesis log to inspect the surrounding stages. Before the first report, the log contained:

```text
Area for cell type $_AND_ is unknown!
Area for cell type $_MUX_ is unknown!
of which used for sequential elements: 2019156.531202 (100.00%)
```

Immediately afterward, the log showed:

```text
192. Executing ABC pass (technology mapping using ABC).
```

The first area counted mapped sequential cells while generic combinational cells still had unknown area. The 100% sequential figure described the area that could be counted at that point; it did not mean the CPU contained only sequential logic. After technology mapping, the report listed SKY130 combinational cells with known areas and reported total area 4,272,735.392004 µm², including sequential area 1,932,011.702402 µm² (45.22%). I therefore used the later mapped total for the worksheet and B6 calculations.

### 2. Utilization figures appeared inconsistent

For the 3650 µm run, the floorplan log reported:

```text
Core area: 10474095.488 um^2
Effective utilization: 0.408
```

The global-placement log reported:

```text
Fixed instances area: 197086.522 um^2
Movable instances area: 4799976.268 um^2
Utilization: 46.706 %
Pin density area adjust: 527240.876 um^2
```

I separated the definitions and denominators. Effective utilization `0.408` is a fraction, equivalent to 40.8%. Dividing synthesis area by the inner core area gives approximately that value. B6 instead uses the full die area: 4,272,735.392004 / (2900 × 3650) × 100 = 40.37%.

The global placer's adjusted utilization is reproduced by:

```text
4799976.268 / (10474095.488 - 197086.522) × 100 = 46.706%
```

Its area accounting includes a pin-density adjustment, so I did not substitute that figure for B6's synthesis-area-based utilization. I also kept placement target density separate from measured utilization.

### 3. Empty error logs did not mean that the routability goal was met

Although all three error logs were empty and detailed-placement outputs were generated, their global-placement logs contained:

```text
[INFO GPL-0089] Routability finished. Reverting to minimal observed routing congestion, could not reach target.
```

For the 3300 µm run, the log also showed:

```text
[INFO GPL-0054] No improvement in routing congestion for 3 consecutive iterations (limit is 3).
[INFO GPL-1005] Routability final weighted congestion: 1.0383
```

I traced the surrounding iterations and observed that the placer stopped improving its congestion estimate and reverted to a saved placement. I distinguished this warning from a fatal placement error. The run completed placement, but actual routing success was not demonstrated. Searches of the saved logs and configuration files did not identify the exact configured congestion target, so I do not claim a verified numerical threshold. Intermediate overflow values preceding the reversion are also not final routing-violation counts.

## Floorplan decision and prediction

Based on my comparison, I selected the 16I/8D cache configuration with a 2900 × 3300 µm die as the point to carry into routing. It is the smallest tested die, has 44.65% implied utilization, and completed detailed placement. It also has the shortest reported HPWL and lowest final weighted congestion of the three tested points. Increasing height reduced utilization but did not improve the final congestion metric and increased estimated wire length.

I predict that the selected 16I/8D cache configuration at 3300 µm height will route successfully. Its implied utilization of 44.65% lies within the reference design's reported 42–45% successful range. It also completed detailed placement and had the shortest HPWL and lowest final weighted congestion among the three tested heights.

## What I learned

I learned to associate each result with its flow stage, area definition, and generated evidence. A synthesis statistic can be incomplete before technology mapping, a utilization fraction can differ from a percentage printed at another stage, and an empty error log can coexist with an unmet optimization goal. Comparing the same metrics across the three runs gave me a measured basis for selecting a compact floorplan while keeping routing uncertainty explicit.
