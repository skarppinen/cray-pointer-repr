module cray_pointer_issue_mod
    use kind_mod, only: ik, rk
    implicit none
    contains

    subroutine wrapper_pass_arr(arrlen, nblocks)
        implicit none
        integer(kind = ik), intent(in) :: arrlen
        integer(kind = ik), intent(in) :: nblocks
        integer(kind = ik) :: block_id
#ifdef USE_ALLOCATABLE
        real(kind = rk), allocatable :: stack(:, :)
#else
        real(kind = rk) :: stack(2 * arrlen, nblocks)
#endif
        real(kind = rk) :: output(arrlen, nblocks)
        real(kind = rk) :: x(arrlen)
        real(kind = rk) :: y(arrlen)

        x = 3.0_rk
        y = 7.0_rk
#ifdef USE_ALLOCATABLE
        allocate(stack(2 * arrlen, nblocks))
#endif
        stack = 0.0_rk

        !$acc data copyin(x, y) copyout(output) create(stack)
        !$acc parallel loop
        do block_id = 1, nblocks
            call kernel_pass_arr(arrlen, output(:, block_id), x, y, stack(:, block_id))
        end do
        !$acc end parallel loop
        !$acc end data

        do block_id = 1, nblocks
            print *, "Sum of column ", block_id, " is: ", sum(output(:, block_id))
        end do

#ifdef USE_ALLOCATABLE
        deallocate(stack)
#endif
    end subroutine wrapper_pass_arr

    subroutine kernel_pass_arr(arrlen, output, x, y, stack)
        integer(kind = ik), intent(in) :: arrlen
        real(kind = rk), intent(inout) :: output(arrlen)
        real(kind = rk), intent(in) :: x(arrlen)
        real(kind = rk), intent(in) :: y(arrlen)
        real(kind = rk), intent(inout) :: stack(:)

        real(kind = rk) :: tmpA(arrlen)
        real(kind = rk) :: tmpB(arrlen)
        integer(kind = ik) :: local_stackpos
        integer(kind = ik) :: i
        !$acc routine vector

        ! Setup Cray pointers such that `tmpA` and `tmpB` have their memory
        ! on the scratch space.
        pointer(ptrA, tmpA)
        pointer(ptrB, tmpB)

        !$acc data present(stack, x, y, output)
        local_stackpos = 1_ik
        ptrA = loc(stack(local_stackpos))
        local_stackpos = local_stackpos + arrlen
        ptrB = loc(stack(local_stackpos))

        ! Move the data to the temporaries.
        !$acc loop vector
        do i = 1, arrlen
            tmpA(i) = x(i)
            tmpB(i) = y(i)
        end do

        ! Compute the vector sum.
        !$acc loop vector
        do i = 1, arrlen
            output(i) = tmpA(i) + tmpB(i) 
        end do
        !$acc end data

    end subroutine kernel_pass_arr

    subroutine wrapper_pass_intaddr(arrlen, nblocks)
        implicit none
        integer(kind = ik), intent(in) :: arrlen
        integer(kind = ik), intent(in) :: nblocks
        integer(kind = ik) :: block_id
#ifdef USE_ALLOCATABLE
        real(kind = rk), allocatable :: stack(:, :)
#else
        real(kind = rk) :: stack(2 * arrlen, nblocks)
#endif
        real(kind = rk) :: output(arrlen, nblocks)
        real(kind = rk) :: x(arrlen)
        real(kind = rk) :: y(arrlen)
        integer(kind = ik) :: stackpos

        x = 3.0_rk
        y = 7.0_rk
        
#ifdef USE_ALLOCATABLE
        allocate(stack(2 * arrlen, nblocks))
#endif
        stack = 0.0_rk

        !$acc data copyin(x, y) copyout(output) create(stack)
        !$acc parallel loop private(stackpos)
        do block_id = 1, nblocks
            stackpos = loc(stack(1, block_id))
            call kernel_pass_intaddr(arrlen, output(:, block_id), x, y, stackpos)
        end do
        !$acc end parallel loop
        !$acc end data

        do block_id = 1, nblocks
            print *, "Sum of column ", block_id, " is: ", sum(output(:, block_id))
        end do

#ifdef USE_ALLOCATABLE
        deallocate(stack)
#endif
    end subroutine wrapper_pass_intaddr

    subroutine kernel_pass_intaddr(arrlen, output, x, y, stackpos)
        use iso_c_binding, only: c_sizeof
        integer(kind = ik), intent(in) :: arrlen
        real(kind = rk), intent(inout) :: output(arrlen)
        real(kind = rk), intent(in) :: x(arrlen)
        real(kind = rk), intent(in) :: y(arrlen)
        integer(kind = rk), intent(in) :: stackpos

        real(kind = rk) :: tmpA(arrlen)
        real(kind = rk) :: tmpB(arrlen)
        integer(kind = ik) :: local_stackpos
        integer(kind = ik) :: i
        !$acc routine vector

        ! Setup Cray pointers such that `tmpA` and `tmpB` have their memory
        ! on the scratch space.
        pointer(ptrA, tmpA)
        pointer(ptrB, tmpB)
        local_stackpos = stackpos 
        ptrA = local_stackpos
        local_stackpos = local_stackpos + arrlen * c_sizeof(real(1.0, kind = rk))
        ptrB = local_stackpos

        ! Move the data to the temporaries.
        !$acc loop vector
        do i = 1, arrlen
            tmpA(i) = x(i)
            tmpB(i) = y(i)
        end do

        ! Compute the vector sum using the temporaries.
        !$acc loop vector
        do i = 1, arrlen
            output(i) = tmpA(i) + tmpB(i) 
        end do

    end subroutine kernel_pass_intaddr

end module cray_pointer_issue_mod
