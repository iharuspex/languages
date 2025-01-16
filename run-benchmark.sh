#!/bin/bash

# Defaults
check_only=false
skip_check=false
run_ms=10000
cmd_input="$(./check-output.sh -i)"
user="J Doe"
only_langs=false

while getopts "cst:u:l:" opt; do
  case $opt in
    u) user="${OPTARG}" ;;       # Included in result file
    t) run_ms="${OPTARG}" ;;     # How long should the benchmark run?
    c) check_only=true ;;        # Skip benchmark
    s) skip_check=true ;;        # Run benchmark even if check fails (typically with non-default input)
    l) only_langs="${OPTARG}" ;; # Languages to benchmark (string separated by `:`)
    *) ;;
  esac
done
shift $((OPTIND-1))

only_langs_slug=""
if [ -n "${only_langs}" ] && [ "${only_langs}" != "false" ]; then
    IFS=':' read -r -a only_langs <<< "${only_langs}"
    only_langs_slug="_only_langs"
fi

is_checked=true
if [ "$skip_check" = true ]; then
  is_checked=false
fi
user=${user//;/_}
input_value="${1}"
if [ -n "${input_value}" ]; then
    cmd_input="${input_value}"
fi

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
results_file="${benchmark_dir}/${benchmark}_${user}_${run_ms}_${commit_sha}${only_langs_slug}.txt"
# Data header, should match what is printed from `run`
if [ "${check_only}" = false ]; then
  echo "benchmark;commit_sha;is_checked;user;model;os;arch;language;run_ms;mean_run_ms;times" > "${results_file}"
  echo "Running ${benchmark} benchmark..."
  echo "Results will be written to: ${results_file}"
else
  echo "Only checking ${benchmark} benchmark"
  echo "No benchmark will be run"
fi


function check {
  local language_name=${1}
  local partial_command=${2}
  local run_time_ms=${3}
  local input_arg=${4}
  if [ ${skip_check} = false ]; then
    echo "Checking ${benchmark} ${language_name}"
    echo "${partial_command} ${run_time_ms} ${input_arg}"
    local program_output=$(${partial_command} "${run_time_ms}" "${input_arg}")
    if ! ./check-output.sh "${program_output}"; then
      echo "Check failed for ${benchmark} ${language_name}."
      return 1
    fi
  else
    echo "Skipping check for ${benchmark} ${language_name}"
  fi
}

function run {
  # "Language" "File that should exist" "Partial command line"
  local language_name=${1}
  local file_that_should_exist=${2}
  local partial_command=${3}

  if [ "$only_langs" != false ]; then
    local should_run=false
    for lang in "${only_langs[@]}"; do
      if [ "$lang" = "$language_name" ]; then
        should_run=true
        break
      fi
    done
    if [ "$should_run" = false ]; then
      return
    fi
  fi

  echo
  if [ -f "${file_that_should_exist}" ]; then
    check "${language_name}" "${partial_command}" 1 "${cmd_input}"
    if [ ${?} -eq 0 ] && [ ${check_only} = false ]; then
      echo "Benchmarking ${benchmark} ${language_name}"
      local command_line="${partial_command} ${run_ms} ${cmd_input}"
      echo "${command_line}"
      local program_output=$(eval "${command_line}")
      # keep only the first two items from the output string
      result=$(echo "${program_output}" | awk -F ';' '{print $1";"$2}')
      echo "${benchmark};${commit_sha};${is_checked};${user};${model};${os};${arch};${language_name};${run_ms};${result}" | tee -a "${results_file}"
    fi
  else
    echo "No executable or script found for ${language_name}. Skipping."
  fi
}

# Please keep in language name alphabetic order
# run "Language name" "File that should exist" "Command line"
####### BEGIN The languages
run "Clojure" "./clojure/classes/run.class" "java -cp clojure/classes:$(clojure -Spath) run"
run "Clojure Native" "./clojure-native-image/run" "./clojure-native-image/run"
####### END The languages

echo
echo "Done running $(basename ${PWD}) benchmark"
echo "Results were written to: ${results_file}"
