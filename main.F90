program main
#ifdef PASS_INTADDR
    use cray_pointer_issue_mod, only: wrapper_pass_intaddr
#else
    use cray_pointer_issue_mod, only: wrapper_pass_arr
#endif
    use kind_mod, only: ik
    implicit none
    integer(kind = ik) :: arrlen
    integer(kind = ik) :: nblocks
    
    arrlen = 8_ik 
    nblocks = 16_ik
#ifdef PASS_INTADDR
    call wrapper_pass_intaddr(arrlen=arrlen, nblocks=nblocks)
#else
    call wrapper_pass_arr(arrlen=arrlen, nblocks=nblocks)
#endif
end program main
