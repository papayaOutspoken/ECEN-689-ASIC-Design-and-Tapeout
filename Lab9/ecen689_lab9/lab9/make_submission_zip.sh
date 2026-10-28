#!/bin/bash
# Package the team's Lab 9 submission. Run from your project folder:
#   bash lab9/make_submission_zip.sh <teamnumber>
set -e
T=${1:?usage: bash lab9/make_submission_zip.sh <teamnumber>}
cd "$(dirname "$0")/.."
OUT=lab9_team${T}_submission
rm -rf $OUT ${OUT}.zip && mkdir -p $OUT/reports $OUT/sim_logs
cp lab9/answers.txt $OUT/
cp config.yaml $OUT/
cp microwatt_src/microwatt_top.vhdl $OUT/
cp lab9/sim_*.log $OUT/sim_logs/ 2>/dev/null
cp lab9/*.png $OUT/ 2>/dev/null
cp reports/*lab9*.md $OUT/reports/ 2>/dev/null
# flow evidence: synthesis numbers + placement verdicts from every run tried
for R in runs/RUN_*; do
  [ -d "$R" ] || continue
  tag=$(basename $R)
  grep -iE "Number of cells|Chip area" $R/*-yosys-vhdlsynthesis/*.log 2>/dev/null | tail -2 > $OUT/${tag}_synth.txt
  cp $R/error.log $OUT/${tag}_error.log 2>/dev/null
  grep -oE "DIE_AREA[^,]*" $R/resolved.json 2>/dev/null | head -1 >> $OUT/${tag}_synth.txt
done
M=0
for f in $OUT/answers.txt $OUT/config.yaml $OUT/microwatt_top.vhdl; do
  [ -f $f ] || { echo "MISSING: $f"; M=1; }; done
ls $OUT/sim_logs/*.log >/dev/null 2>&1 || { echo "MISSING: benchmark sim logs (save each config run: ... | tee lab9/sim_<config>.log)"; M=1; }
ls $OUT/*.png >/dev/null 2>&1 || { echo "MISSING: placement screenshot in lab9/"; M=1; }
ls $OUT/reports/*.md >/dev/null 2>&1 || { echo "MISSING: individual reports (reports/<name>_lab9.md)"; M=1; }
[ $M -eq 1 ] && { echo "Fix missing items, rerun."; exit 1; }
zip -qr ${OUT}.zip $OUT
echo "CREATED: $(pwd)/${OUT}.zip  -- upload to Canvas (one per team)"
