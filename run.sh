# smpirun -np 16 -platform nancy-2023-07-18.xml -trace --cfg=tracing/filename:ior.trace $(which ior) -f script.ior

smpirun -np 16 -platform nancy-2023-07-18.xml -trace --cfg=tracing/filename:ior.trace $(which ior) -t 1m -b 16m -s 16 -F -i 3

Rscript script.R

evince smpi.pdf
