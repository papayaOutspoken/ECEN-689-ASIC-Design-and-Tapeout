# ECEN 689 – Lab 10 Individual Report
**Student:** Manoj Kallu  
**Team:** 5

## 1. Work performed
- Worked with the selected Lab 9 implementation using a die area of 2900 × 4050.
- Investigated clock-tree-synthesis failures and continued from an available post-CTS checkpoint.
- Continued the physical-design flow through routing and RCX.
- Reviewed the generated post-route timing summary and retained run evidence for the submission.

## 2. Problems encountered and recovery
The initial CTS attempts (Slurm jobs 743324 and 743606) encountered Signal 11 failures. An available post-CTS checkpoint was used to continue the flow rather than restarting from the beginning.

Routing job 744663 completed successfully. The flow reached the RCX stage, and SPEF output files were reported in the RCX output directory. The run-level `error.log` was reported empty.

## 3. Timing analysis
The available post-route timing summary reports:
- Overall worst hold slack: **−0.1179 ns**
- Overall hold-violation count: **42**
- Overall worst setup slack: **−4.4838 ns**
- Overall setup-violation count: **205**

The corner-level summary indicates that the worst hold slack occurs in the `max_ff_40C_1v95` group (−0.1179 ns), while the worst setup slack occurs in the `max_ss_100C_1v60` group (−4.4838 ns).

The reported negative slack values indicate that the timing constraints are not met for those paths in the available summary. The achieved SS period should be calculated using the configured clock period and the SS setup WNS, as specified in the lab manual.

## 4. Signoff and macro evidence
The available evidence does not establish a passing DRC or LVS result, and the macro extraction provenance/checksum has not been verified. These items should only be described as passed or complete after checking the corresponding final logs and generated macro files.

## 5. Evidence retained
The submission folder contains the available timing summary and run identification. The final DRC/LVS verdicts, macro-kit provenance, and any remaining reference-run measurements should be added from the original run outputs when verified.
