K Semantics of K
================


In this repository, we formally define the translation of the K Frontend
Language into axioms in Matching Logic, the logic over which the semantics of
the K Framework are defined. K being a Language used in formal verification, it
is important the K frontend constructs have clearly defined semantics. We choose
to implement this translation in K itself, since becoming a self-hosting
language is an important rite of passage in a languages development.

Dependencies
------------

-   `stack`
-   `ninja` (the `ninja-build` package on Ubuntu)

Building
--------

-   `git submodule init` to fetch `k5` and `kore`, needed by the project.
-   `stack build` to build the `k Haskell Backend`.
-   `ninja` to run tests.

