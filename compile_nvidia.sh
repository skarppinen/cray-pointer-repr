FLAGS="-O3 -fast -acc -Minfo=all"
FILES="kind_mod.F90 cray_pointer_issue_mod.F90 main.F90"
nvfortran ${FLAGS} ${FILES} -DUSE_ALLOCATABLE -DPASS_INTADDR -o main_alloc_intaddr
nvfortran ${FLAGS} ${FILES} -DUSE_ALLOCATABLE -o main_alloc_nointaddr
nvfortran ${FLAGS} ${FILES} -DPASS_INTADDR -o main_noalloc_intaddr
nvfortran ${FLAGS} ${FILES} -o main_noalloc_nointaddr
