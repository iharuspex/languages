#!/bin/bash

# Defaults
check_only=false
skip_check=false
run_ms=10000
warmup_ms=2000
user="JDoe"
only_langs=false

while getopts "cst:w:u:l:h" opt; do
  case $opt in
    u) user="${OPTARG}" ;;          # Included in result file
    t) run_ms="${OPTARG}" ;;        # How long should the benchmark run?
    w) warmup_ms="${OPTARG}" ;;     # Warmup length
    c) check_only=true ;;           # Skip benchmark
    s) skip_check=true ;;           # Run benchmark even if check fails (typically with non-default input)
    l) only_langs="${OPTARG}" ;;    # Languages to benchmark, comma separated
    *) ;;
  esac
done
shift $((OPTIND-1))

only_langs_slug=""
if [ -n "${only_langs}" ] && [ "${only_langs}" != "false" ]; then
    IFS=',' read -r -a only_langs <<< "${only_langs}"
    only_langs_slug="_only_langs"
fi

is_checked=true
if [ "$skip_check" = true ]; then
  is_checked=false
fi
user=${user//,/_}

override_input_value="${1}"

commit_sha=$(git rev-parse --short HEAD)
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
os=${OSTYPE//,/_}
arch=$(uname -m)

if [[ "${os}" == "darwin"* || "${os}" == "freebsd"* ]]; then
    model=$(sysctl -n machdep.cpu.brand_string)
elif [[ "${os}" == "linux-gnu"* ]]; then
    model=$(lscpu --extended=MODELNAME | awk -F: 'NR==2 {print $1; exit}')
else
    model="Unknown"
fi
model=${model//,/_}

if [[ "${os}" == "darwin"* || "${os}" == "freebsd"* ]]; then
  ram=$(sysctl -n hw.memsize)
  ram=$((ram / 1024 / 1024 / 1024))GB
elif [[ "${os}" == "linux-gnu"* ]]; then
  ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  ram=$((ram / 1024 / 1024))GB
else
  ram="Unknown"
fi

function check {
  local language_name=${1}
  local partial_command=${2}
  local input_arg=${3}

  local command_line
  local program_output

  if [ ${skip_check} = false ]; then
    echo "Checking ${benchmark} ${language_name}"
    command_line="${partial_command} 1 0 ${input_arg}"
    echo ${command_line}
    program_output=$(${command_line})
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

  use_hyperfine=false
  [[ "$benchmark" == "hello-world" ]] && use_hyperfine=true
  cmd_input="$(./check-output.sh -i)"
  if [ -n "${override_input_value}" ]; then
    cmd_input="${override_input_value}"
  fi

  local result
  echo
  if [ -f "${file_that_should_exist}" ]; then
    check "${language_name}" "${partial_command}" "${cmd_input}"
    if [ ${?} -eq 0 ] && [ ${check_only} = false ]; then
      echo "Benchmarking ${benchmark} ${language_name}"
      if [ ${use_hyperfine} = true ]; then
        local command_line="${partial_command} 1 0 ${cmd_input}"
        results_dir="/tmp/languages-benchmark"
        mkdir -p "${results_dir}/hyperfine"
        hyperfine_file="${results_dir}/hyperfine/${results_file_name}"
        hyperfine -i --shell=none --output=pipe --runs 25 --warmup 5 --export-csv "${hyperfine_file}" "${command_line}"
        result=$(tail -n +2 "${hyperfine_file}" | awk -F ',' '{print ($2*1000)","($3*1000)","($7*1000)","($8*1000)","25}')
      else
        local command_line="${partial_command} ${run_ms} ${warmup_ms} ${cmd_input}"
        echo "${command_line}"
        local program_output=$(eval "${command_line}")
        result=$(echo "${program_output}" | awk -F ',' '{print $1","$2","$3","$4","$5}')
      fi
      echo "${benchmark},${timestamp},${commit_sha},${is_checked},${user},${model},${ram},${os},${arch},${language_name},${run_ms},${result}" | tee -a "${results_file}"
    fi
  else
    echo "No executable or script found for ${language_name}. Skipping."
  fi
}

function run_benchmark {
  local benchmark_dir=${1}
  local benchmark=$(basename ${benchmark_dir})
  cd "${benchmark_dir}" || return

  results_dir="/tmp/languages-benchmark"
  mkdir -p "${results_dir}"
  results_file_name="${benchmark}_${user}_${run_ms}_${commit_sha}${only_langs_slug}.csv"
  results_file="${results_dir}/${results_file_name}"
  # Data header, must match what is printed from `run`
  if [ "${check_only}" = false ]; then
    echo "benchmark,timestamp,commit_sha,is_checked,user,model,ram,os,arch,language,run_ms,mean_ms,std-dev-ms,min_ms,max_ms,runs" > "${results_file}"
    echo "Running ${benchmark} benchmark..."
    echo "Results will be written to: ${results_file}"
  else
    echo "Only checking ${benchmark} benchmark"
    echo "No benchmark will be run"
  fi

  source ../languages.sh
  run_languages

  echo
  echo "Done running $(basename ${PWD}) benchmark"
  echo "Results were written to: ${results_file}"
}

available_benchmarks=("loops" "fibonacci" "levenshtein" "hello-world")
benchmarks_to_run=()
current_benchmark=$(basename "${PWD}")

benchmark_found=false
for benchmark in "${available_benchmarks[@]}"; do
  if [[ "${benchmark}" == "${current_benchmark}" ]]; then
    benchmark_found=true
    break
  fi
done

if [ "${benchmark_found}" = true ]; then
  benchmarks_to_run=("${PWD}")
else
  for benchmark in "${available_benchmarks[@]}"; do
    if [ -d "${PWD}/${benchmark}" ]; then
      benchmarks_to_run+=("${PWD}/${benchmark}")
    fi
  done
fi

for benchmark_dir in "${benchmarks_to_run[@]}"; do
  echo
  run_benchmark "${benchmark_dir}"
done


