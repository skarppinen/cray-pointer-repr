module load craype-accel-amd-gfx90a
module load rocm
module load cce/16.0.1

FLAGS="-O2 -hacc"
FILES="kind_mod.F90 cray_pointer_issue_mod.F90 main.F90"
ftn ${FLAGS} ${FILES} -DUSE_ALLOCATABLE -DPASS_INTADDR -o main_alloc_intaddr
ftn ${FLAGS} ${FILES} -DUSE_ALLOCATABLE -o main_alloc_nointaddr
ftn ${FLAGS} ${FILES} -DPASS_INTADDR -o main_noalloc_intaddr
ftn ${FLAGS} ${FILES} -o main_noalloc_nointaddr
