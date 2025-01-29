#!/bin/bash

benchmark=$(basename "${PWD}")

# Defaults
only_langs=false

while getopts "cst:u:l:h" opt; do
  case $opt in
    l) only_langs="${OPTARG}" ;;    # Languages to benchmark, comma separated
    *) ;;
  esac
done
shift $((OPTIND-1))

if [ -n "${only_langs}" ] && [ "${only_langs}" != "false" ]; then
    IFS=',' read -r -a only_langs <<< "${only_langs}"
fi

function compile {
  local language_name=${1}
  local directory=${2}
  local compile_cmd=${3}

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

  if [ -d ${directory} ]; then
    echo ""
    echo "Compiling ${language_name}"
    eval "${compile_cmd}"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to compile ${language_name} with command: ${compile_cmd}"
    fi
  fi
}

echo "Starting compiles for ${benchmark}"

# Please keep in language name alphabetic order
# run "Language name" "Directory that should exist" "Command line"
####### BEGIN The languages
compile 'C' 'c' 'gcc -O3 -I../lib/c -c ../lib/c/benchmark.c -o c/benchmark.o && gcc -O3 -I../lib/c c/benchmark.o c/*.c -o c/run -lm'
compile 'Clojure' 'clojure' '(cd clojure && mkdir -p classes && clojure -M -e "(compile (quote run))")'
compile 'Clojure Native' 'clojure-native-image' "(cd clojure-native-image ; clojure -M:native-image-run --pgo-instrument -march=native) ; ./clojure-native-image/run -XX:ProfilesDumpFile=clojure-native-image/run.iprof 10000 2000 $(./check-output.sh -i) && (cd clojure-native-image ; clojure -M:native-image-run --pgo=run.iprof -march=native)"
compile 'C++' 'cpp' 'g++ -march=native -std=c++23 -O3 -Ofast -I../lib/cpp cpp/run.cpp -o cpp/run'
compile 'Java' 'jvm' 'javac -cp ../lib/java jvm/*.java'
compile 'Java Native' 'java-native-image' "(cd java-native-image ; native-image -cp ..:../../lib/java --no-fallback -O3 --pgo-instrument -march=native jvm.run) && ./java-native-image/jvm.run -XX:ProfilesDumpFile=java-native-image/run.iprof 10000 2000 $(./check-output.sh -i) && (cd java-native-image ; native-image -cp ..:../../lib/java -O3 --pgo=run.iprof -march=native jvm.run -o run)"
compile 'Fortran' 'fortran' "gfortran -O3 -J../lib/fortran ../lib/fortran/benchmark.f90 fortran/run.f90 -o fortran/run"
compile 'Zig' 'zig' 'zig build --build-file zig/build.zig --prefix ${PWD}/zig/zig-out --cache-dir ${PWD}/zig/.zig-cache --release=fast'

####### END The languages

echo
echo "Done with compiles for ${benchmark}"
