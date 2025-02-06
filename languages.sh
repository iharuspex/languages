#!/bin/bash

# Please keep in language name alphabetic order in each list


function compile_languages {
  #       'Language name' 'Directory that should exist' 'Command line'
  compile 'C' 'c' 'gcc -O3 -I../lib/c -c ../lib/c/benchmark.c -o c/benchmark.o && gcc -O3 -I../lib/c c/benchmark.o c/*.c -o c/run -lm'
  compile 'Clojure' 'clojure' '(cd clojure && mkdir -p classes && clojure -M -e "(compile (quote run))")'
  compile 'Clojure Native' 'clojure-native-image' '(cd clojure-native-image ; clojure -M:native-image-run --pgo-instrument -march=native) ; ./clojure-native-image/run -XX:ProfilesDumpFile=clojure-native-image/run.iprof 10000 2000 $(./check-output.sh -i) && (cd clojure-native-image ; clojure -M:native-image-run --pgo=run.iprof -march=native)'
  compile 'Crystal' 'crystal' 'crystal build --release --mcpu native crystal/run.cr -o crystal/run'
  compile 'C++' 'cpp' 'g++ -march=native -std=c++23 -O3 -Ofast -I../lib/cpp cpp/run.cpp -o cpp/run'
  compile 'Java' 'jvm' 'javac -cp ../lib/java jvm/*.java'
  compile 'Java Native' 'java-native-image' '(cd java-native-image ; native-image -cp ..:../../lib/java --no-fallback -O3 --pgo-instrument -march=native jvm.run) && ./java-native-image/jvm.run -XX:ProfilesDumpFile=java-native-image/run.iprof 10000 2000 $(./check-output.sh -i) && (cd java-native-image ; native-image -cp ..:../../lib/java -O3 --pgo=run.iprof -march=native jvm.run -o run)'
  compile 'Fortran' 'fortran' 'gfortran -O3 -J../lib/fortran ../lib/fortran/benchmark.f90 fortran/*.f90 -o fortran/run'
  compile 'Rust' 'rust' 'cargo build --manifest-path rust/Cargo.toml --release'
  compile 'Zig' 'zig' 'zig build --build-file zig/build.zig --prefix ${PWD}/zig/zig-out --cache-dir ${PWD}/zig/.zig-cache --release=fast'
}

function run_languages {
  #   'Language name' 'File that should exist' 'Command line'
  run 'Babashka' 'bb/run.clj' 'bb bb/run.clj'
  run 'C' './c/run' './c/run'
  run 'Clojure' './clojure/classes/run.class' "java -cp clojure/classes:$(clojure -Spath) run"
  run 'Clojure Native' './clojure-native-image/run' './clojure-native-image/run'
  run "Crystal" "./crystal/run" "./crystal/run"
  run 'C++' './cpp/run' './cpp/run'
  run 'Fortran' './fortran/run' './fortran/run'
  run 'Java' './jvm/run.class' 'java -cp .:../lib/java jvm.run'
  run 'Java Native' './java-native-image/run' './java-native-image/run'
  run "Python" "./py/run.py" "python3.12 ./py/run.py"
  run "Python JIT" "./py-jit/run.py" "python3.12 ./py-jit/run.py"
  run 'Ruby' 'ruby/run.rb' 'ruby ruby/run.rb'
  run "Ruby YJIT" "./ruby/code.rb" "ruby --yjit ./ruby/run.rb"
  run "Rust" "./rust/target/release/run" "./rust/target/release/run"
  run 'Zig' './zig/zig-out/bin/run' './zig/zig-out/bin/run'
}