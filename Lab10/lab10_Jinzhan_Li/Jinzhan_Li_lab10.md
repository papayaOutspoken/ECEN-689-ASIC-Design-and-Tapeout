# ECEN 689 Lab 10 Individual Report

Name: Jinzhan Li
NetID: jl90
Team: 5

## 1. What I Personally Did in This Lab

I continued the Microwatt CPU physical design flow from the selected Lab 9 placement run (RUN_2026-10-28_19-24-53), using the 2900 x 3650 um die area and Menu S configuration.

First, I launched and monitored the Clock Tree Synthesis (CTS) job (741329), which completed successfully. I examined the clock-tree implementation and timing reports, including the clock skew and hold-repair warnings.

Next, I submitted and monitored the routing and parasitic extraction job (741715). The flow successfully completed global routing, antenna repair, detailed routing, and RC extraction. The final global routing congestion report showed zero overflow across all routing layers, and the SPEF files were generated successfully.

I then ran the signoff flow (job 743121), which performed post-route static timing analysis, GDS generation, DRC, and LVS verification. The Magic DRC report showed zero violations (COUNT: 0), and the Netgen LVS report confirmed that the circuits matched uniquely. I also examined the timing results across nine PVT/RC corners. The worst setup slack was -2.0659 ns at the SS max-RC corner, while no hold violations were reported.

Finally, I recovered the required final design artifacts after encountering a disk-space issue and extracted the Microwatt CPU macro kit. I verified the GDS file integrity, completed the macro kit extraction on shared scratch storage, and prepared the corresponding experimental results for the team report.

## 2. Problems I Encountered

### Problem 1: Hold Timing Repair Warning During CTS

During CTS, OpenROAD reported:

[RSZ-0064] Unable to repair all hold checks within margin

This warning indicated that the timing repair stage could not satisfy all of its requested hold-repair margins. However, the final signoff timing report showed zero hold violations across all nine analysis corners.

### Problem 2: Residual Antenna Violations After Routing

The initial antenna checking stage identified 5,333 violating nets and 6,944 violating pins. Automatic antenna repair substantially reduced the violations, but the final manufacturability report still identified 8 violating nets and 14 violating pins.

### Problem 3: Insufficient Disk Space 

Although DRC, LVS, and timing analysis completed, the signoff job (743121) failed during the final output-saving stage because the home filesystem ran out of space.

The relevant error was:

[Errno 28] No space left on device

I attempted to resume the flow from the final manufacturability reporting stage using job 744730, but the same disk-space error occurred while saving the final views, even though the verification reports had already been generated.

## 3. Diagnosis and Resolution

### Resolution 1: Verify Hold Timing Using Final STA Results

I checked the final post-route timing summary instead of relying solely on the intermediate CTS warning. The final report confirmed zero hold violations and a minimum positive hold slack of approximately 0.0080 ns at the FF max-RC corner.

Therefore, the CTS warning did not correspond to an actual hold timing violation in the final signoff results.

### Resolution 2: Inspect Antenna Repair Results

I compared the antenna-check results before and after automatic repair and confirmed that the number of violations was significantly reduced. I also verified that the detailed routing and RC extraction stages completed successfully and that global routing congestion overflow was zero.

The remaining antenna violations were documented in the final manufacturability report rather than being reported as fully resolved.

### Resolution 3: Final Artifacts

I inspected the filesystem usage and identified insufficient home-directory storage as the cause of the final-view saving failure. After freeing disk space, I restored the missing final design views using the successfully generated intermediate files. I also synchronized the final metrics files with the completed signoff state's metrics, resulting in 338 recorded metrics. To avoid consuming additional home-directory storage, I extracted the macro kit to:

/mnt/shared-scratch/Yi_S/jl90/lab10_macro_kit

The extracted kit included the GDS, LEF, gate-level netlist, SDC, Liberty files, SPEF files, timing summary, metrics, and provenance information.

## 4. Conclusion

In this lab, I completed CTS, routing, parasitic extraction, and the major physical verification stages for the Microwatt CPU. The design achieved zero global routing overflow, passed Magic DRC and Netgen LVS, and produced post-route timing results across nine analysis corners.

The main challenge was a disk-space failure during final signoff output generation. By examining the logs, recovering the generated design artifacts, and relocating the macro kit to shared scratch storage, I preserved the results needed for subsequent labs.

This lab provided practical experience with large-scale CPU physical implementation, timing analysis, physical verification, troubleshooting, and macro-level design handoff.
