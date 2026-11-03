# Lab 9 Individual Report

Name: Manoj Kallu
NetID: manojkallu
Team: 5

## 1. What I personally did in this lab

I worked on the C2 configuration for the MicroWatt design. I checked the benchmark results and synthesis output, then ran placement experiments with the die width fixed at 2900 µm and heights of 3750 µm, 3900 µm, and 4050 µm. I checked the placement logs and copied the generated DEF file to my WSL environment so I could open it in KLayout and view the floorplan.

## 2. Problems I encountered

I could not open KLayout directly on Olympus because the `klayout` command was not available there. I also had trouble finding the run logs at first because the `runs` directory points to a shared location. The synthesis logs showed different area values, so I had to check the summary and log output to identify the final reported area.

## 3. How I resolved the problems

I used the run directory paths to locate the placement files and copied the DEF file to WSL, where KLayout was available. I opened the file in KLayout and took a screenshot of the placement view. I also checked the synthesis summary and the final ABC results to get the reported area and cell count.

## 4. Results and observations

The final C2 synthesis summary reported a chip area of **4,860,251.366405 µm²**, which is below the **5,800,000 µm²** limit. I tried three floorplan heights: **3750 µm, 3900 µm, and 4050 µm**, with the width kept at **2900 µm**. In KLayout, the design appeared as a tall, narrow layout with many repeated vertical regions.

## 5. Placement screenshot

**Filename:** `lab9/lab9_manoj_kallu.png`

The screenshot shows the placement view opened in KLayout from the generated DEF file.

