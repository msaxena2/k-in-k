require "kore.k"
require "domains.k"

module KAUX-SYNTAX
  imports KORE-SYNTAX
  imports STRING

  syntax KDeclarations ::= List{KDeclaration, ""}
  syntax KDeclaration ::= "ksyntax" "(" KSort "," KLabel ")" 
  syntax KSort        ::= "ksort"   "(" String ")"
  syntax KLabel       ::= "klabel"  "(" String ")"
endmodule


module KAUX
  imports KAUX-SYNTAX
  imports DOMAINS

  configuration <KinK> <pipeline> #extractKSortStructureStep ~> .K </pipeline>
                       <k> $PGM:KDeclarations </k>
                       <kore> .Declarations </kore>
                </KinK>

  syntax KItem ::= "#extractKSortStructureStep"
  rule <pipeline> #extractKSortStructureStep => .K ... </pipeline>
       <k> PGM </k>
       <kore> KORE => #KSortStructureToKore(#extractKSortStructure(PGM, .Map)) </kore> 

  syntax Map ::= #extractKSortStructure(KDeclarations, Map)    [function]
  rule #extractKSortStructure(.KDeclarations, MAP) => MAP
  rule #extractKSortStructure(ksyntax(ksort(SORT), klabel(LABEL)) NEXT:KDeclarations, MAP)
    => #extractKSortStructure( NEXT:KDeclarations
                             , updateMap( MAP
                                        , #parseToken("Name", SORT)|-> ( MAP[#parseToken("Name", SORT)]
                                                                             orDefault(.Set)
                                                                         SetItem(#parseToken("Name", LABEL))
                             )          )                              )

  syntax Declarations ::= #KSortStructureToKore(Map) [function]
  rule #KSortStructureToKore(.Map) => .Declarations
  rule #KSortStructureToKore((SORT:Name |-> LABELS))
    => sort SORT { .Names } [ .Patterns ]
       #mkKoreSymbols(SORT, LABELS)

  syntax Declarations ::= #mkKoreSymbols(Sort, Set) [function]
  rule #mkKoreSymbols(SORT, .Set) => .Declarations
  rule #mkKoreSymbols(SORT, SetItem(L:Name) (LS:Set))
    => (symbol L { .Names } ( .Sorts ) : SORT [.Patterns])
       #mkKoreSymbols(SORT, LS)

endmodule
