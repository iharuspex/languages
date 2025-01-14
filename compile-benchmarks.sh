function compile {
  if [ -d ${1} ]; then
    echo ""
    echo "Compiling $1"
    eval "${2}"
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to compile ${1} with command: ${2}"
    fi
  fi
}

compile 'clojure' '(cd clojure && mkdir -p classes && clojure -M -e "(compile (quote run))")'
# (cd clojure-native-image && clojure -M:native-image --pgo-instrument -march=native && ./code $(cat input.txt) && clojure -M:native-image --pgo -march=native)

