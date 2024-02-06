'compile_lumi.sh' compiles 4 different versions, created by on/offing the following #defines:

- USE_ALLOCATABLE: If set, the `stack` array in the wrapper routine is defined to be an allocatable,
that is also allocated and deallocated. If unset, `stack` will be an automatic array.

- PASS_INTADDR: If set, the wrapper routine calls a version of the kernel routine that only accepts the
memory address to the `stack` variable (as opposed to a slice of the `stack` array). The memory address
is obtained using the intrinsic function `loc`. If unset, a version of the kernel routine is used
that accepts a slice of the `stack` array. Note that the different kernels set up the Cray pointers 
in different ways as a consequence.

Only the version with neither of the above set doesn't crash on LUMI and produces the correct result.

To reproduce on LUMI:
```
# Interactive job.
srun --account=*your_account_num* --partition=dev-g --gpus=1 --time=00:30:00 --pty bash
./compile_lumi.sh # Creates executables

./main_alloc_intaddr # crash
./main_noalloc_intaddr # crash
./main_alloc_nointaddr # crash
./main_noalloc_nointaddr # no crash, correct results
```
