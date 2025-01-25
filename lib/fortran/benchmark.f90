module benchmark
  implicit none
  private
  public :: run, format_results, benchmark_result_t  ! Make benchmark_result_t public

  type :: benchmark_result_t
    integer :: runs
    real(8) :: mean_ms
    real(8) :: std_dev_ms
    real(8) :: min_ms
    real(8) :: max_ms
    integer(8) :: result
  end type benchmark_result_t

contains

  subroutine run(f, run_ms, result)
    implicit none
    interface
      integer(8) function f()
      end function f
    end interface
    procedure(f), pointer :: func_ptr
    integer, intent(in) :: run_ms
    type(benchmark_result_t), intent(out) :: result
    integer(8) :: start_time, end_time, elapsed_time, total_elapsed_time
    integer :: count
    real(8) :: elapsed_times(1000), mean, variance, std_dev, min_time, max_time

    func_ptr => f
    total_elapsed_time = 0
    count = 0
    min_time = 1.0e12
    max_time = 0.0

    do while (total_elapsed_time < run_ms * 1.0e6)
      call system_clock(start_time)
      result%result = func_ptr()
      call system_clock(end_time)
      elapsed_time = end_time - start_time
      elapsed_times(count + 1) = elapsed_time / 1.0e6
      total_elapsed_time = total_elapsed_time + elapsed_time
      count = count + 1
      if (elapsed_times(count) < min_time) min_time = elapsed_times(count)
      if (elapsed_times(count) > max_time) max_time = elapsed_times(count)
    end do

    mean = sum(elapsed_times(1:count)) / count
    variance = sum((elapsed_times(1:count) - mean)**2) / count
    std_dev = sqrt(variance)

    result%runs = count
    result%mean_ms = mean
    result%std_dev_ms = std_dev
    result%min_ms = min_time
    result%max_ms = max_time
  end subroutine run

  subroutine format_results(benchmark_result, result_str)
    implicit none
    type(benchmark_result_t), intent(in) :: benchmark_result
    character(len=256), intent(out) :: result_str
    write(result_str, '(f6.3,1x,f6.3,1x,f6.3,1x,f6.3,1x,i0,1x,i8)') &
      benchmark_result%mean_ms, benchmark_result%std_dev_ms, benchmark_result%min_ms, benchmark_result%max_ms, benchmark_result%runs, benchmark_result%result
  end subroutine format_results

end module benchmark
