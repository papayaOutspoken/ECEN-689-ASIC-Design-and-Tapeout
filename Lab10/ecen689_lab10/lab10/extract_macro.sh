#!/bin/bash
# Extract your finished core as a reusable MACRO KIT for Lab 11 chip assembly.
# Run from your project folder AFTER signoff completes clean:
#   bash lab10/extract_macro.sh
set -e
cd "$(dirname "$0")/.."
R=$(ls -dt runs/RUN_* | head -1)
echo "Extracting from: $R"
[ -f $R/final/gds/microwatt_top.gds ] || { echo "No final GDS - signoff did not complete. Fix that first."; exit 1; }
K=macro_kit
mkdir -p $K/lib $K/spef
cp $R/final/gds/microwatt_top.gds   $K/
cp $R/final/lef/microwatt_top.lef   $K/
cp $R/final/nl/microwatt_top.nl.v   $K/
cp $R/final/sdc/microwatt_top.sdc   $K/ 2>/dev/null || true
cp -r $R/final/lib/.  $K/lib/  2>/dev/null || true
cp -r $R/final/spef/. $K/spef/ 2>/dev/null || true
cp $R/final/metrics.json $K/
cp $R/*-openroad-stapostpnr/summary.rpt $K/timing_summary.rpt 2>/dev/null || true
echo "source run: $(readlink -f $R)" > $K/PROVENANCE.txt
date >> $K/PROVENANCE.txt
md5sum $K/microwatt_top.gds >> $K/PROVENANCE.txt
echo "=== your macro kit ==="
ls -lh $K
echo "KEEP THIS FOLDER - Lab 11 builds your chip from it. Run directories are large and may be cleaned; this kit is the copy that stays."
