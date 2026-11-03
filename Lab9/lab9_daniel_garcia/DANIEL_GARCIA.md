# Lab 9 individual report  (copy as reports/<your_name>.md - one per member)
Name: Daniel Garcia
NetID: daniel-gar09
Team: 5

## 1. What I personally did in this lab
I unzipped ecen689_lab9.zip into my existing ecen689_lab8 project folder on olympus and sourced the ECEN689 env.sh.
I set up a shared Google Drive spreadsheet for the team to organize which cache configurations to test, collect everyone's results for the report, and automatically calculate the fit check and the die height range (H_min and H_max) from each configuration's synthesis area.
For the configuration frontier, I set microwatt_top.vhdl to our custom C1 configuration (CFG_ICACHE_NUM_LINES = 32, CFG_DCACHE_NUM_LINES = 16), ran the core_tb_course benchmark, and received "BENCHMARK PASS checksum=500 cycles=419" with a wall time of 1.961 s.
I then ran flow synthesis of C1 with synth_only.sbatch, which reported "Chip area for module '\microwatt_top': 4870476.172804" and saved the 56 MB netlist runs/RUN_2026-10-28_18-43-43/01-yosys-vhdlsynthesis/microwatt_top.nl.v.
From the 4,870,476 um^2 area, I calculated H_min = 4,870,476 / (0.45 x 2900) = 3,732 um, rounded up to 3,750 um, and H_max = 4,798 um, capped at 4,050 um.
I then ran three placement runs with to_placement.sbatch at die heights of 3,800, 3,900, and 4,050 um, and all three completed detailed placement with an empty error.log at 44.2%, 43.1%, and 41.5% implied utilization (53.5%, 52.3%, and 50.4% post-placement utilization), respectively.
Finally, I opened the 4,050 um run in KLayout with "lane config.yaml --last-run --flow OpenInKLayout", set the hierarchy levels to 0 to 1 to show the placed cells, noted that the cells were packed more densely on the left and upper parts of the die, and saved the screenshot as lab9/placement_4050.png.

## 2. Problems I encountered
The first problem was when copying the testbench in Step 1 after unzipping the Lab 9 kit.

```
[daniel-gar09@olympus-login microwatt_src]$ cp ../lab9/core_tb_course.vhdl .
cp: cannot stat '../lab9/core_tb_course.vhdl': No such file or directory
```

The second problem was that to_placement.sbatch names every log flow_place_<job ID>.log (#SBATCH --output=flow_place_%j.log), so the three placement logs could not be told apart by die height.

## 3. How each problem was resolved
Problem 1:
The unzip output showed "creating: ecen689_lab9/" and "creating: ecen689_lab9/lab9/", so the zip contains an extra top-level folder, and "ls lab9" returned "No such file or directory" while "ls ecen689_lab9" showed lab9 and LAB9_MANUAL.md.
The manual's commands expect lab9 next to microwatt_src, so I deleted the extracted folders, unzipped the kit again, moved the folder up one level with "mv ecen689_lab9/lab9 .", and removed the empty ecen689_lab9 folder.
"ls lab9" then listed the six kit files, and the cp command succeeded.

Problem 2:
I edited the --output line in to_placement.sbatch before each submission to include the die height, which produced flow_place_H3800_722256.log, flow_place_H3900_723057.log, and flow_place_H4050_723496.log.
I confirmed that each name matched its run by checking the "Floorplanned on a die area of 0.0 0.0 2900.0 <H>" line in each log.