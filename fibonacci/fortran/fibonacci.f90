module fibonacci_module
    implicit none
    contains

    integer(8) recursive function fibonacci(n) result(f)
        integer(8), intent(in) :: n

        if (n == 0) then
            f = 0
        elseif (n == 1) then
            f = 1
        else
            f = fibonacci(n - 1) + fibonacci(n - 2)
        end if
    end function fibonacci

end module fibonacci_module