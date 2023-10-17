# smpirun -np 16 -platform nancy-2023-07-18.xml -trace --cfg=tracing/filename:ior.trace $(which ior) -f script.ior

# smpirun -np 32 -platform nancy-2023-07-18.xml -trace-ti --cfg=tracing/filename:ior.tracei --cfg=smpi/display-timing:yes $(which ior) -t 1m -b 16m -s 16 -F -i 3 -a MPIIO

# smpirun -np 4 -hostfile hostfile_4 -platform platform.xml -trace-ti --cfg=tracing/filename:ior.tracei --cfg=smpi/display-timing:yes $(which ior) -t 1m -b 16m -s 16 -F -i 3 -a MPIIO -o /scratch/testFile
# smpirun -np 4 -hostfile hostfile_4 -platform platform.xml -trace-ti --cfg=tracing/filename:ior.tracei --cfg=smpi/display-timing:yes $(which ior) -t 1m -b 16m -s 16 -F -i 3 -o /home/quentin/ghq/github.com/GuilloteauQ/fuse-sg/src/ici

# exit

# smpirun -np 1 -hostfile hostfile_bob1 -platform platform.xml $(which ior) -a MPIIO -o "/scratch/testFile" -V

# smpirun -trace-ti --cfg=tracing/filename:ior.tracei --cfg=smpi/display-timing:yes -platform hosts_with_disks.xml -hostfile hostfile_io -np 8 $(which ior) -a MPIIO -t 1m -b 16m -s 16  -F -o /scratch/testFile

# exit

# smpirun  -trace --cfg=tracing/filename:ior.trace -platform hosts_with_disks.xml -hostfile hostfile_io -np 8 $(which ior) -a MPIIO -t 1m -b 16m -s 16  -F

# smpirun -np 4 -hostfile $PLATFORMDIR/cluster_hostfile.txt -platform $PLATFORMDIR/cluster_crossbar.xml  -trace-ti -replay HPL_trace

# smpirun -platform hosts_with_disks.xml -hostfile hostfile_io -np 8 -trace-ti -ext ./myreplay  ior.tracei

find ./ior.tracei_files -type f -exec sed -i -e 's/IO - write/io-write/g' {} \;
find ./ior.tracei_files -type f -exec sed -i -e 's/IO - read/io-read/g' {} \;

smpicxx replay.cpp -o myreplay -std=c++17 
smpirun -replay ior.tracei -np 8 -platform hosts_with_disks.xml -hostfile hostfile_io myreplay


# Rscript script.R

# evince smpi.pdf
