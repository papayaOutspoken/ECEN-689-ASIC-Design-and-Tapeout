# Lab 9 individual report  (copy as reports/<your_name>.md - one per member)
Name: Elan landau
NetID: 237007971
Team: 5

## 1. What I personally did in this lab
<!-- (2-5 sentences. Be specific: which steps you drove, what you typed/read.) -->

Made github for group's files.

copied lab9 to olympus with scp and unison program

logged in
```bash
ssh elandau2@olympus.ece.tamu.edu
```

volunteered to try the min-sized cache configuration.

Attempted to benchmark the program after configuring with 1 cache line for data and 1 for instruction.

This gave an error about -1 downto 0 not being valid, so I assumed it was subtracting the config by 1 to get the -1, changed to 2 and re-ran:

```bash
cd microwatt_src
cp ../lab9/core_tb_course.vhdl .
ghdl -i --std=08 $(cat ../lab8/core_files.txt) microwatt_top.vhdl core_tb_course.vhdl
ghdl -m --std=08 core_tb_course
ghdl -r --std=08 core_tb_course | tee ../lab9/sim_$(whoami).log
```

checked the output and got
`BENCHMARK PASS checksum=500 cycles=419`

real    0m1.670s
user    0m1.237s
sys     0m0.163s

which showed even a tiny cache has the same performance.

then I ran various config heights (2900 3400 3600 3900 4050) for the 2,2 configuration.

Then, ran klayout visualization (lane config.yaml --last-run --flow OpenInKLayout) and took screenshot.

## 2. Problems I encountered

1. Trying cache line size of 1 failed.

## 3. How each problem was resolved
1. Changed to 2 since 1 was too small for a min-sized cache configuration.
