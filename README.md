# IO(R) & Simgrid

This repo investigates the replaying of the IO operations in SimGrid.

We use the IOR benchmark as an application.

## Generate the TIT trace

```
nix develop .#expe --command smpirun -trace-ti --cfg=tracing/filename:ior-trace-smpi --cfg=smpi/display-timing:yes -np 4 -hostfile hostfile_bob -platform hosts_with_disks.xml ./ior.bin -a MPIIO -t 1m -b 16m -s 16 -F -o "/scratch/testFile" -V
```

## Replay the trace

```
nix develop .#expe --command smpirun -np 4 -platform hosts_with_disks.xml -hostfile hostfile_bob --cfg=smpi/display-timing:yes -replay ior-trace-smpi replay.bin
```
