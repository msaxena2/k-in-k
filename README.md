K Semantics of K
================

This project defines the semantics of the K Framework in K itself.
Currently, the project focuses on giving semantics to the
K compilation process. The K compilation process accepts as input
a K definition, and outputs a Matching Logic theory (of the language definition)
in [kore](https://github.com/kframework/kore).


Dependencies
------------

-   `stack`
-   `ninja` (the `ninja-build` package on Ubuntu)

Building
--------

-   `git submodule init` to fetch `k5` and `kore`, needed by the project.
-   `stack build` to build the `k Haskell Backend`.
-   `ninja` to run tests.

