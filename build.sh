#!/bin/bash
# Build the ACM ICPS paper: pdflatex, bibtex, pdflatex, pdflatex.
#   ./build.sh            camera-ready build  -> main.pdf
#   ./build.sh --preprint author preprint     -> preprint.pdf (no ACM rights block)
set -euo pipefail
cd "$(dirname "$0")"
export PATH="/Library/TeX/texbin:$PATH"
job=main
src=main.tex
if [ "${1:-}" = "--preprint" ]; then
  job=preprint
  src='\def\forcepreprint{1}\input{main.tex}'
fi
run() { pdflatex -jobname="$job" -interaction=nonstopmode -halt-on-error "$src" >/dev/null; }
run
bibtex "$job" >/dev/null
run
run
errors=$(grep -c '^!' "$job.log" || true)
undefined=$(grep -c 'undefined' "$job.log" || true)
overfull=$(grep -c 'Overfull \\hbox' "$job.log" || true)
bibwarn=$(grep -c '^Warning--' "$job.blg" || true)
pages=$(sed -n "s/^Output written on $job.pdf (\([0-9]*\) page.*/\1/p" "$job.log")
echo "$job.pdf pages: ${pages}, errors: ${errors}, undefined: ${undefined}, overfull hboxes: ${overfull}, bibtex warnings: ${bibwarn}"
