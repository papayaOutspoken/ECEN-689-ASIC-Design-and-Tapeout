# Lab 9 individual report  (copy as reports/<your_name>.md - one per member)
Name: Jinzhan Li 
NetID: jl90
Team: 5


## 1. What I personally did in this lab
(2-5 sentences. Be specific: which steps you drove, what you typed/read.)
I configured and verified the Microwatt CPU using Menu S, with the FPU disabled and both instruction and data caches configured to 16 lines, obtaining BENCHMARK PASS checksum=500 cycles=419 with a simulation wall time of 1.983 seconds. I performed synthesis using the provided SKY130 flow on the Olympus cluster and obtained 330,753 standard cells with a total cell area of 4,465,263.792 µm², satisfying the 5,800,000 µm² area constraint. Based on the synthesized area, I calculated the allowable floorplan height range and submitted three placement experiments with core dimensions of 2900 × 3450, 2900 × 3550, and 2900 × 3650 µm. All three placement jobs completed successfully with empty error.log files, corresponding to estimated utilizations of 44.63%, 43.37%, and 42.18%, respectively. Finally, I inspected the 3650 µm placement using KLayout, saved the screenshot as lab9/placement_3650.png, and recommended this floorplan for subsequent routing experiments.
## 2. Problems I encountered
(Every error message you personally hit. Paste the exact line.) During floorplan exploration, I needed to run three 
different core heights without mixing their generated run directories or overwriting existing results. The original 
placement script contained a command that redirected the runs symbolic link to the default run-storage directory
mkdir -p "$HOME/chip_runs" && ln -sfn "$HOME/chip_runs" runs
This created a potential conflict when executing experiments from separate working directories.
## 3. How each problem was resolved
I used separate working directories for the 3450 µm and 3550 µm experiments while keeping the 3650 µm experiment in 
the main ~/ecen689_lab8 directory. For the 3550 µm experiment, I modified the placement script to redirect the runs 
symbolic link to a dedicated directory: mkdir -p "$HOME/chip_runs_H3550" && ln -sfn "$HOME/chip_runs_H3550" runs
This allowed the experiments to retain their own run results without interfering with the selected floorplan's files. The three placement jobs (722268, 732070, and 722226) all completed successfully.
