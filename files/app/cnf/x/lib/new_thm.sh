#!/bin/sh

/usr/share/xlg/
~/app/dat/xlg/
 - thm
 - skl

tpl=$(find ~/app/cnf -name '*.tpl')
for t in ${tpl}; do
  nfn=$(printf '%s' "${tpl}" | sed 's|.tpl||g')
done