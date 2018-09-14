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
                       <koreSorts>
                </KinK>

  syntax KItem ::= "#extractKSortStructureStep"
  rule <pipeline> #extractKSortStructureStep => .K ... </pipeline>
       <k> PGM </k>
       <kore> KORE => #KSortStructureToKore(#extractKSortStructure(PGM, .Map)) </kore>

  syntax Map ::= #extractKSortStructure(KDeclarations, Map)    [function]
  rule #extractKSortStructure(.KDeclarations, MAP) => MAP

  rule #extractKSortStructure(ksyntax(ksort(SORT), klabel(LABEL)) NEXT:KDeclarations, MAP)
    => #extractKSortStructure( NEXT:KDeclarations
                             , MAP [#parseToken("Name", SORT) <- SetItem(#parseToken("Name", LABEL))])
      requires notBool (#parseToken("Name", SORT) in_keys (MAP))

  syntax Set ::= #getLabelsKSortStructure(Map, Name) [function]
  rule #getLabelsKSortStructure(MAP:Map, SORT) => MAP[SORT]

  syntax Map ::= #insertKSortStructure(Map, K, K) [function]
  rule #insertKSortStructure(MAP, SORT, LABEL)
    => updateMap(MAP, SORT |-> (SetItem(LABEL) getLabelsKSortStructure(MAP, SORT)))

  rule #extractKSortStructure(ksyntax(ksort(SORT), klabel(LABEL)) NEXT:KDeclarations, MAP)
    => #extractKSortStructure( NEXT:KDeclarations
                             , #insertKSortStructure(MAP, #parseToken("Name", SORT)
                                                        , #parseToken("Name", LABEL)))

  // rule #extractKSortStructure(ksyntax(ksort(SORT), klabel(LABEL)) NEXT:KDeclarations, MAP)
  //   => #extractKSortStructure( NEXT:KDeclarations
  //                            , updateMap( MAP
  //                                       , #parseToken("Name", SORT)|-> ( #lookupSetInMap(MAP,  #parseToken("Name", SORT))
  //                                                                        SetItem(#parseToken("Name", LABEL))
  //                            )          )                              )

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
