K Semantics of K
================

This project defines the semantics of the K Framework in K itself.
Currently, the project focuses on giving semantics to the
K compilation process. The K compilation process accepts as input
a K definition, and outputs a Matching Logic theory (of the language definition)
in [kore](https://github.com/kframework/kore).


Building
--------
 - `git submodule init` to fetch `k5` and `kore`, needed by the project.
 - `stack build` to build the `k Haskell Backend`.
 - `make generate-kore` to generate kore files from the k-definitions.

Running
-------
 - `make test` to test programs against generated kore using the haskell backend.
