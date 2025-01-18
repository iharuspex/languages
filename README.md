
# Languages

A repo for collaboratively building small benchmarks to compare languages.
If you have a suggestion for improvement: PR!
If you want to add a language: PR!

## Running

See also: [New runner](#new-runner)

To run one of the benchmarks:

1. `cd` into desired benchmark directory (EG `$ cd loops`)
2. Compile by running `$ ../compile.sh`
3. Run via `$ ../run.sh`.
  You should see output something like:
  
  ```
  $ ../run.sh

  Benchmarking Zig
  Benchmark 1: ./zig/code 40
    Time (mean ± σ):     513.9 ms ±   2.9 ms    [User: 504.5 ms, System: 2.6 ms]
    Range (min … max):   510.6 ms … 516.2 ms    3 runs


  Benchmarking C
  Benchmark 1: ./c/code 40
    Time (mean ± σ):     514.0 ms ±   1.1 ms    [User: 505.6 ms, System: 2.8 ms]
    Range (min … max):   513.2 ms … 515.2 ms    3 runs


  Benchmarking Rust
  Benchmark 1: ./rust/target/release/code 40
    Time (mean ± σ):     514.1 ms ±   2.0 ms    [User: 504.6 ms, System: 3.1 ms]
    Range (min … max):   512.4 ms … 516.3 ms    3 runs

  ...
  ```

4. For good measure, execute `$ ../clean.sh` when finished.

Hyperfine is used to warm, execute, and time the runs of the programs.

## Adding

To add a language:

1. Select the benchmark directory you want to add to (EG `$ cd loops`)
2. Create a new subdirectory for the language (EG `$ mkdir rust`)
3. Implement the code in the appropriately named file (EG: `code.rs`)
4. If the language is compiled, add appropriate command to `../compile.sh` and `../clean.sh`
5. Add appropriate line to `../run.sh`

You are also welcome to add new top-level benchmarks dirs

## Available Benchmarks

#### [hello-world](./hello-world/README.md)

#### [loops](./loops/README.md)

#### [fibonacci](./fibonacci/README.md)

#### [levenshtein](./levenshtein/README.md)

## Corresponding visuals

Several visuals have been published based on the work here.
More will likely be added in the future, as this repository improves:

- https://benjdd.com/languages
- https://benjdd.com/languages2
- https://benjdd.com/languages3
- https://pez.github.io/languages-visualizations/ 
  - check https://github.com/PEZ/languages-visualizations/tags for tags, which correspond to a snapshot of some particular benchmark run: e.g:
  - https://pez.github.io/languages-visualizations/v2024.12.31/

## New runner

There's a new runner system that is supposed to replace the old one. The main goal is to eliminate start times from the benchmarks. The general strategy is that the programs being benchmarked do the benchmarking in-process, and only around the single piece of work that the benchmark is about. So for **fibonacci** only the call to the function calculating the fibonacci sum should be measured. Additionally each program (language) will be allowed the same amount of time to complete the benchmark work (as many times as it can).

For this, each language will have to have some minimal utility/tooling for running the function-under-benchmark as many times as a timeout allows, plus reporting the measurements and the result. Here are two implementations, that we can regard as being reference:

* [benchmark.clj](lib/clojure/src/languages/benchmark.clj)
* [benchmark.java](lib/java/languages/Benchmark.java)

You'll see that the `benchmark/run` function takes two arguments:

1. `f`: A function (a thunk)
1. `run-ms`: A total time in milliseconds within which the function should be run as many times as possible

To make the overhead of running and measuring as small as possible, the runner takes a delta time for each time it calls `f`. It is when the sum of these deltas, `total-elapsed-time`, is over the `run-ms` time that we stop calling `f`. So, for a `run-ms` of `1000` the total runtime will always be longer than a second. Because we will almost always “overshoot” with the last run, and because the overhead of running and keeping tally, even if tiny, will always be _something_.

The benchmark/run function is responsible to report back the result/answer to the task being benchmarked, as well as some stats, like mean run time, standard deviation, min and max times, and how many runs where completed.

### Running a benchmark

The new run script is named [run-benchmark.sh](run-benchmark.sh). Let's say we run it in the **levenstein** directory:

```sh
../run-benchmark.sh -u PEZ
```

The default run time is `10000` ms. `-u` sets the user name (preferably your GitHub handle). The output was this:

```csv
benchmark,commit_sha,is_checked,user,model,os,arch,language,run_ms,mean_ms,std-dev-ms,min_ms,max_ms,times
levenshtein,4c83540,true,PEZ,Apple M4 Max,darwin24,arm64,Babashka,10000,23521.408167,0.0,23521.408167,23521.408167,1
levenshtein,4c83540,true,PEZ,Apple M4 Max,darwin24,arm64,Clojure,10000,57.37351194285714,5.3806423301901845,55.77275,125.076208,175
levenshtein,4c83540,true,PEZ,Apple M4 Max,darwin24,arm64,Clojure Native,10000,60.39511344578313,1.1564638823645572,58.955917,65.086,166
levenshtein,4c83540,true,PEZ,Apple M4 Max,darwin24,arm64,Java,10000,55.280637,1.975461,52.659084,64.202375,181
levenshtein,4c83540,true,PEZ,Apple M4 Max,darwin24,arm64,Java Native,10000,63.549330,4.861132,53.100375,74.261416,158
```

It's a CSV file you can open in something Excel-ish or consume with your favorite language.

![Example Result CSV in Numbers.app](docs/example-results-csv.png)

As you can see, it has some meta data about the run, in addition to the benchmark results. **Clojure** ran the benchmark 175 times, with a mean time of **57.3 ms**. Which shows the point with the new runner, considering that Clojure takes **300 ms** (on the same machine) to start.

See [run-benchmark.sh](run-benchmark.sh) for some more command line options it accepts. Let's note one of them: `-l` which takes a string of comma separated language names, and only those languages will be run. Good for when contributing a new language or updates to a language. E.g:

```
~/Projects/languages/levenshtein ❯ ../run-benchmark.sh -u PEZ -l Clojure
Running levenshtein benchmark...
Results will be written to: /tmp/languages-benchmark/levenshtein_PEZ_10000_5bb1995_only_langs.csv

Checking levenshtein Clojure
Check passed
Benchmarking levenshtein Clojure
java -cp clojure/classes:src:/Users/pez/.m2/repository/org/clojure/clojure/1.12.0/clojure-1.12.0.jar:/Users/pez/.m2/repository/org/clojure/core.specs.alpha/0.4.74/core.specs.alpha-0.4.74.jar:/Users/pez/.m2/repository/org/clojure/spec.alpha/0.5.238/spec.alpha-0.5.238.jar run 10000 levenshtein-words.txt
levenshtein,5bb1995,true,PEZ,Apple M4 Max,darwin24,arm64,Clojure,10000,56.84122918181818,0.8759056030546785,55.214541,59.573,176

Done running levenshtein benchmark
Results were written to: /tmp/languages-benchmark/levenshtein_PEZ_10000_5bb1995_only_langs.csv
```

### Compiling a benchmark

This works as before, but since the new programs are named `run` instead of `code`, we need a new script. Meet: [compile-benchmark.sh](compile-benchmark.sh)

```sh
../compile-benchmark.sh
```

### Adding a language

To add a language for a benchmark to the new runner you'll need to add:

1. A benchmarking utility
1. Code in `<benchmark>/<language>/run.<language-extension>` (plus whatever extra project files)
1. An entry in `compile-benchmark.sh`
1. An entry in `run-benchmark.sh`
1. Maybe some code in `clean.sh`

The `main` function of the program provided should take two arguments:

1. The run time in milliseconds
1. The input to the function
   - There is only one input argument, unlike before. How this input argument should be interpreted depends on the benchmark. For **levenshtein** it is a file path, to the file containing the words to use for the test.

As noted before the program should run the function-under-benchmark as many times as it can, following the example of the reference implementations mentioned above. The program is allowed to use an equal amount of time as the run time for warmup, so that any JIT compilers will have had some chance to optimize.

The program should output a csv row with:

```csv
mean_ms,std-dev-ms,min_ms,max_ms,times,result
```

### Some changes to the benchmarks:

* **fibonacci**: The input is now `36`, to allow slower languages to complete more runs.
* **loops**: The inner loop is now 10k, again to allow slower languages to complete more runs.
* **levenshtein**:
  1. Smaller input (slower languages...)
  1. We only calculate each word pairing distance once (A is as far from B as B is from A)
  1. There is a single result, the sum of the distances.
* **hello-world**: No changes.
  * It needs to accept and ignore the two arguments
  * There is no benchmarking code in there, because it will be benchmarked out-of-process, using **hyperfine**

Let's look at the `-main` function for the Clojure **levenshtein** contribution:

```clojure
(defn -main [& args]
  (let [run-ms (parse-long (first args))
        input-path (second args)
        strings (-> (slurp input-path)
                    (string/split #"\s+"))
        _warmup (benchmark/run #(levenshtein-distances strings) run-ms)
        results (benchmark/run #(levenshtein-distances strings) run-ms)]
    (-> results
        (update :result (partial reduce +))
        benchmark/format-results
        println)))
```

The `benchmark/run` function returns a map with the measurements and the result keyed on `:result`. *This result is a sequence of all the distances.* Outside the benchmarked function we sum the distances, and then format the output with this sum. It's done this way to minimize the impact that the benchmarking needs has on the benchmarked work. (See [levenshtein/jvm/run.java](levenshtein/jvm/run.java) if the Lisp is tricky to read for you.)

### You can help

Please consider helping us making a speedy transition by porting your favorite language(s) from the old runner to this new one.
