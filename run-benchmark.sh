#!/bin/bash

# We run the benchmark with input from `check-output.sh -i` as argument
# unless the script is run with arguments, then those will be used instead
# With arguments the check will be skipped, unless the only argument is "check"
# The special argument "check" makes the input always input.txt, and skips the benchmark

check_only=false
skip_check=false
run_ms=10000
cmd_input="$(./check-output.sh -i)"
user="J Doe"

while getopts "cst:u:" opt; do
  case $opt in
    c) check_only=true ;;
    s) skip_check=true ;;
    t) run_ms="${OPTARG}" ;;
    u) user="${OPTARG}" ;;
    *) ;;
  esac
done
shift $((OPTIND-1))

user=${user//;/_}

input_value="$1"
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

benchmark=$(basename ${PWD})
commit_sha=$(git rev-parse --short HEAD)
benchmark_dir="/tmp/languages-benchmark"
os=${OSTYPE//;/_}
arch=$(uname -m)

if [[ "${os}" == "darwin"* ]]; then
    model=$(sysctl -n machdep.cpu.brand_string)
elif [[ "${os}" == "linux-gnu"* ]]; then
    model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')
elif [[ "${os}" == "freebsd"* ]]; then
    model=$(sysctl -n machdep.cpu.brand_string)
else
    model="Unknown"
fi

model=${model//;/_}

mkdir -p "${benchmark_dir}"
results_file="${benchmark_dir}/${benchmark}_${user}_${run_ms}_${commit_sha}.txt"
echo "benchmark;commit_sha;user;model;os;arch;language;run_ms;mean_run_ms;times" > "${results_file}"
echo "Running ${benchmark} benchmarks"
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
      # keep only the first two items from the output string
      result=$(echo "${output}" | awk -F ';' '{print $1";"$2}')
      echo "${benchmark};${commit_sha};${user};${model};${os};${arch};${1};${run_ms};${result}" | tee -a "${results_file}"
    fi
  else
    echo "No executable or script found for ${1}. Skipping."
  fi
}

run "Clojure" "./clojure/classes/run.class" "java -cp clojure/classes:$(clojure -Spath) run"
run "Clojure Native" "./clojure-native-image/run" "./clojure-native-image/run"

echo
echo "Done running $(basename ${PWD}) benchmarks"
echo "Results were written to: ${results_file}"
