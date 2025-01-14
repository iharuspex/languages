#!/bin/bash

# We run the benchmark with input from `check-output.sh -i` as argument
# unless the script is run with arguments, then those will be used instead
# With arguments the check will be skipped, unless the only argument is "check"
# The special argument "check" makes the input always input.txt, and skips the benchmark

input_value="$1"
shift

check_only=false
skip_check=false
run_ms=10000
cmd_input="$(./check-output.sh -i)"

while getopts "cst:" opt; do
  case $opt in
    c) check_only=true ;;
    s) skip_check=true ;;
    t) run_ms="${OPTARG}" ;;
    *) ;;
  esac
done

if [ -n "${input_value}" ]; then
    cmd_input="${input_value}"
fi

function check {
  if [ ${skip_check} = false ]; then
    echo "Checking $1"
    echo "${2} ${3} ${4}"
    output=$(${2} ${3} ${4})
    if ! ./check-output.sh "$output"; then
      echo "Check failed for $1."
      return 1
    fi
  fi
}

benchmark_dir="/tmp/languages-benchmark"
mkdir -p "${benchmark_dir}"
timestamp=$(date +%Y%m%d_%H%M%S)
results_file="${benchmark_dir}/results_${timestamp}.txt"
echo "Running $(basename ${PWD}) benchmarks"
echo "Results will be written to: ${results_file}"

function run {
  echo
  if [ -f "${2}" ]; then
    check "${1}" "${3}" 1 "${cmd_input}"
    if [ ${?} -eq 0 ] && [ ${check_only} = false ]; then
      echo "Benchmarking $1"
      cmd="${3} ${run_ms} ${cmd_input}"
      echo "${cmd}"
      output=$(eval "${cmd}")
      echo "${1};${output}" | tee -a "${results_file}"
    fi
  else
    echo "No executable or script found for ${1}. Skipping."
  fi
}

run "Clojure" "./clojure/classes/run.class" "java -cp clojure/classes:$(clojure -Spath) run"
run "Clojure" "./clojure/classes/run.class" "java -cp clojure/classes:$(clojure -Spath) run"
run "Clojure Native" "./clojure-native-image/run" "./clojure-native-image/run"

echo
echo "Done running $(basename ${PWD}) benchmarks"
echo "Results were written to: ${results_file}"
