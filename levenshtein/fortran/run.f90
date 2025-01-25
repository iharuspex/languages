program main
   use benchmark
   implicit none

   integer :: run_ms, warmup_ms, iostat, word_count
   character(len = 256) :: run_ms_str, warmup_ms_str, input_path
   character(len = :), allocatable :: args(:)
   integer, allocatable :: distances(:)
   type(benchmark_result_t) :: warmup_result, benchmark_result
   character(len = :), allocatable :: result_str

   call get_command_argument(1, run_ms_str)
   call get_command_argument(2, warmup_ms_str)
   call get_command_argument(3, input_path)
   read(run_ms_str, *) run_ms
   read(warmup_ms_str, *) warmup_ms

   call read_all_words(input_path, args, iostat)
   if (iostat /= 0) stop "Error reading file."
   word_count = size(args)
   if (word_count == 0) stop "No words read."

   allocate(distances((word_count * (word_count - 1)) / 2))
   call run(benchmark_function, warmup_ms, warmup_result)
   call run(benchmark_function, run_ms, benchmark_result)
   benchmark_result%result = sum(distances)

   call format_results(benchmark_result, result_str)
   write(*, '(A)') trim(adjustl(result_str))

   deallocate(args, distances)

   contains

      integer(8) function benchmark_function()
      implicit none
      integer :: i, j, idx
      integer(8) :: sum_distances
      sum_distances = 0
      idx = 1
      do i = 1, size(args)
         do j = i + 1, size(args)
            distances(idx) = levenshtein_distance(trim(args(i)), trim(args(j)))
            sum_distances = sum_distances + distances(idx)
            idx = idx + 1
         end do
      end do
      benchmark_function = sum_distances
   end function benchmark_function

   subroutine read_all_words(filename, all_words, iostat)
      implicit none
      character(len = *), intent(in) :: filename
      character(len = :), allocatable, intent(out) :: all_words(:)
      integer, intent(out) :: iostat
      integer :: unit, num_words, i
      integer, parameter :: max_len = 10000 ! Allow for really long words
      character(len = max_len) :: word

      open(newunit = unit, file = filename, status = 'old', action = 'read', iostat = iostat)
      if (iostat /= 0) return

      num_words = 0
      do
         read(unit, '(A)', iostat = iostat) word
         if (iostat /= 0) exit
         num_words = num_words + 1
      end do

      if (num_words > 0) then
         allocate(character(len = max_len) :: all_words(num_words))
         rewind(unit)
         do i = 1, num_words
            read(unit, '(A)', iostat = iostat) all_words(i)
            if (iostat /= 0) exit
         end do
      else
         allocate(all_words, mold = [character(len = max_len) :: ''])
      end if

      close(unit)
   end subroutine read_all_words

   subroutine split(string, delimiter, parts)
      character(len = *), intent(in) :: string
      character(len = *), intent(in) :: delimiter
      character(len = *), intent(out) :: parts(:)
      integer :: i, start, finish, p
      start = 1
      p = 1
      do i = 1, len(string)
         if (string(i:i) == delimiter) then
            finish = i - 1
            if (finish < start) then
               parts(p) = ''
            else
               parts(p) = string(start:finish)
            end if
            p = p + 1
            start = i + 1
         end if
      end do
      if (start <= len(string)) then
         parts(p) = string(start:)
      else
         parts(p) = ''
      end if
   end subroutine split

   ! Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
   ! Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
   ! Time Complexity: O(m*n) where m and n are the lengths of the input strings
   function levenshtein_distance(s1, s2) result(distance)
      character(len = *), intent(in) :: s1, s2
      integer :: distance

      integer :: m, n, i, j, cost
      integer, allocatable :: prev_row(:), curr_row(:)
      character(len = 1) :: c1, c2
      character(len = :), allocatable :: str1, str2

      ! Early termination checks
      if (s1 == s2) then
         distance = 0
         return
      end if

      if (len_trim(s1) == 0) then
         distance = len_trim(s2)
         return
      end if

      if (len_trim(s2) == 0) then
         distance = len_trim(s1)
         return
      end if

      ! Make s1 the shorter string for space optimization
      if (len_trim(s1) > len_trim(s2)) then
         str1 = trim(s2)
         str2 = trim(s1)
      else
         str1 = trim(s1)
         str2 = trim(s2)
      end if

      m = len_trim(str1)
      n = len_trim(str2)

      ! Use two arrays instead of full matrix for space optimization
      allocate(prev_row(0:m), curr_row(0:m))

      ! Initialize first row
      do i = 0, m
         prev_row(i) = i
      end do

      ! Main computation loop
      do j = 1, n
         curr_row(0) = j

         do i = 1, m
            ! Get characters at current position
            c1 = str1(i:i)
            c2 = str2(j:j)

            ! Calculate cost
            if (c1 == c2) then
               cost = 0
            else
               cost = 1
            end if

            ! Calculate minimum of three operations
            curr_row(i) = min(prev_row(i) + 1, & ! deletion
            curr_row(i - 1) + 1, & ! insertion
            prev_row(i - 1) + cost)     ! substitution
         end do

         ! Swap rows
         prev_row = curr_row
      end do

      distance = prev_row(m)

      ! Clean up
      deallocate(prev_row, curr_row)
   end function levenshtein_distance

end program main
