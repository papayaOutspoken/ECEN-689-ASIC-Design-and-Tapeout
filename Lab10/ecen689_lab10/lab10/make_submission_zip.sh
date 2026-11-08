#!/bin/bash
# Package the team's Lab 10 submission:
#   bash lab10/make_submission_zip.sh <teamnumber>
set -e
T=${1:?usage: bash lab10/make_submission_zip.sh <teamnumber>}
cd "$(dirname "$0")/.."
OUT=lab10_team${T}_submission
rm -rf $OUT ${OUT}.zip && mkdir -p $OUT/reports $OUT/evidence
cp lab10/answers.txt $OUT/
cp lab10/DEBUG.md $OUT/ 2>/dev/null || true
cp reports/*lab10*.md $OUT/reports/ 2>/dev/null
R=$(ls -dt runs/RUN_* | head -1)
cp $R/error.log $OUT/evidence/ 2>/dev/null
cp $R/*-openroad-stapostpnr/summary.rpt $OUT/evidence/timing_summary.rpt 2>/dev/null
grep -m1 "COUNT" $R/*-magic-drc/magic-drc.log > $OUT/evidence/drc_verdict.txt 2>/dev/null || true
grep -m1 -ai "uniquely" $R/*-netgen-lvs/netgen-lvs.log > $OUT/evidence/lvs_verdict.txt 2>/dev/null || true
cp $R/*globalrouting/openroad-globalrouting.log $OUT/evidence/ 2>/dev/null || true
cp macro_kit/PROVENANCE.txt $OUT/ 2>/dev/null
cp macro_kit/metrics.json $OUT/ 2>/dev/null
readlink -f $R > $OUT/RUN_PATH.txt; date >> $OUT/RUN_PATH.txt
M=0
[ -f $OUT/answers.txt ] || M=1
[ -f $OUT/PROVENANCE.txt ] || { echo "MISSING: macro_kit (run lab10/extract_macro.sh after clean signoff) - OR include DEBUG.md if not clean"; [ -f $OUT/DEBUG.md ] || M=1; }
ls $OUT/reports/*.md >/dev/null 2>&1 || { echo "MISSING: individual reports"; M=1; }
[ -f $OUT/evidence/timing_summary.rpt ] || { echo "MISSING: timing summary (signoff incomplete?)"; [ -f $OUT/DEBUG.md ] || M=1; }
[ $M -eq 1 ] && { echo "Fix missing items, rerun."; exit 1; }
zip -qr ${OUT}.zip $OUT
echo "CREATED: $(pwd)/${OUT}.zip"
