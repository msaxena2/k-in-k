// Written by Xiaohong Chen (hreada)

module KORE-COMMON

  imports STRING-SYNTAX

  syntax Name // defined in KORE-SYNTAX

  syntax Sort ::= Name | Name "{" Sorts "}" [klabel(nameParam)]

  syntax Sorts ::= List{Sort, ","} [klabel(sortList)]

  syntax Symbol ::= Name "{" Sorts "}" [klabel(symbolSorts)]

  syntax Variable ::= Name ":" Sort [klabel(varType)]

  syntax Pattern ::= Variable
                   | String
                   | Symbol "(" Patterns ")" [klabel(symbolParams)]
                   | "\\and" "{" Sort "}" "(" Pattern "," Pattern ")"
                   | "\\not" "{" Sort "}" "(" Pattern ")"
                   | "\\or"  "{" Sort "}" "(" Pattern "," Pattern ")"
                   | "\\implies"  "{" Sort "}" "(" Pattern "," Pattern ")"
                   | "\\iff"  "{" Sort "}" "(" Pattern "," Pattern ")"
                   | "\\forall" "{" Sort "}" "(" Variable "," Pattern ")"
                   | "\\exists" "{" Sort "}" "(" Variable "," Pattern ")"
                   | "\\ceil" "{" Sort "," Sort "}" "(" Pattern ")"
                   | "\\floor" "{" Sort "," Sort "}" "(" Pattern ")"
                   | "\\equals"  "{" Sort "," Sort "}" "(" Pattern "," Pattern ")"
                   | "\\in" "{" Sort "," Sort "}" "(" Pattern "," Pattern ")"
                   | "\\top" "{" Sort "}" "(" ")"
                   | "\\bottom" "{" Sort "}" "(" ")"
                   | "\\next" "{" Sort "}" "(" Pattern ")"
                   //| "\\rewrites" "{" Sort "}" "(" Pattern "," Pattern ")" // commented so it makes visiting easier
                   | "\\dv" "{" Sort "}" "(" Pattern ")"

  syntax Patterns ::= List{Pattern, ","} [klabel(patternList)]

  syntax Attribute ::= "[" Patterns "]"

  syntax Declaration ::=
    "import" Name Attribute
  | "sort" Name "{" Names "}" Attribute
  | "hook-sort" Name "{" Names "}" Attribute
  | "symbol" Name "{" Names "}" "(" Sorts ")" ":" Sort Attribute
  | "hook-symbol" Name "{" Names "}" "(" Sorts ")" ":" Sort Attribute
  | "axiom" "{" Names "}" Pattern Attribute

  syntax Names ::= List{Name, ","} [klabel(nameList)]

  syntax Declarations ::= List{Declaration, ""} [klabel(declList)]

  syntax Module ::= "module" Name Declarations "endmodule" Attribute [klabel(module)]

  syntax Modules ::= List{Module, ""} [klabel(moduleList)]

  syntax Definition ::= Attribute Modules [klabel(definition)]

endmodule

module KORE-SYNTAX

  imports KORE-COMMON

  // TODO:: Fix this regexp.
  syntax Name ::= r"[\\\\]?[-#a-zA-Z0-9]*"     [autoReject, token, prec(2)]
  syntax Name ::= r"\\rewrites"     [token, prec(2)]

endmodule


module KORE

  imports KORE-COMMON  // don't import KORE-SYNTAX

  //configuration <T> <k> $PGM:Definition </k> </T>

  // unit element for \or
  rule \or{_}(X, \bottom{_}()) => X [anywhere]
  rule \or{_}(\bottom{_}(), X) => X [anywhere]
  // \or(X, X) => X
  rule \or{_}(X, X) => X [anywhere]

  syntax Name ::= "inj" [token, prec(2)]

  // inj composition - performs a similar step to TreeCleanerVisitor.java
  rule inj{Y,Z}(inj{X,Y}(W)) => inj{X,Z}(W) [anywhere]

endmodule