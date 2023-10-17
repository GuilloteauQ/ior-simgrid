set -xe

nix develop .#expe --command smpirun -trace-ti --cfg=tracing/filename:ior-trace-smpi --cfg=smpi/display-timing:yes -np 4 -hostfile hostfile -platform platform.xml ./ior.bin -a MPIIO -t 1m -b 16m -s 16 -o "/scratch/testFile" -V

nix develop .#expe --command smpirun -np 4 -platform platform.xml -hostfile hostfile --cfg=smpi/display-timing:yes -replay ior-trace-smpi replay.bin
