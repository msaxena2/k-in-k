require "kore.k"

module KAUX-SYNTAX
  imports KORE-SYNTAX
  imports STRING

  syntax KAuxDeclarations ::= List{KAuxDeclaration, ""}
  syntax KAuxDeclaration  ::= ksyntax ( KAuxSort , KAuxLabel )
  syntax KAuxSort         ::= ksort   ( Name )
  syntax KAuxLabel        ::= klabel  ( Name )

  syntax KAuxModule     ::=  "kmodule" Name KAuxSentences "endkmodule"
  syntax KAuxModules    ::=  List{KAuxModule, " "}                     [klabel(kauxModules)]
  syntax KAuxSentences  ::=  List{KAuxSentence, " "}                   [klabel(kauxSentences)]
  syntax KAuxSentence   ::=  KAuxDeclaration
  syntax KAuxDefinition ::= KAuxModules

endmodule


module KAUX
  imports KAUX-SYNTAX
  imports DOMAINS

  syntax Processed   ::=  #processedDefintion ( KAuxDefinition )

  syntax Intermdiate ::=   #initialization    ( KAuxDefinition )
                         | #sortDeclaration   ( Intermdiate )   [strict]
                         | #symbolDeclaration ( Intermdiate )   [strict]
                         |  Processed

  syntax KResult    ::= Processed
  syntax KItem      ::=  "#done"
                       | "#configurationDefinitionToTerm"

  configuration <T>
                  <k>
                      #symbolDeclaration(
                        #sortDeclaration(
                          #initialization( $PGM:KAuxModules )
                        )
                      ) ~> #configurationDefinitionToTerm ~> #done
                  </k>
                  <koreDefinition> .K </koreDefinition>
                  <kore>
                    <definitionAttributes> [ .Patterns ] </definitionAttributes>
                    <modules>
                      <koreModule multiplicity="*">
                        <name>               .K   </name>
                        <sortDeclarations>   .Set </sortDeclarations>
                        <symbolDeclarations> .Set </symbolDeclarations>
                      </koreModule>
                    </modules>
                  </kore>
                </T>

   syntax PipelineStep ::=     "Initialization"
                             | "SortsDeclaration"
                             | "SymbolsDeclaration"
   syntax Intermediate ::=     "#pipelineStepHelper" "(" PipelineStep "," KAuxDefinition "|" KAuxDefinition ")"

   rule #processedDefintion( _ ) ~> #done => #done

   rule #initialization( AUXDEF ) => #pipelineStepHelper(Initialization, .KAuxModules | AUXDEF)

   rule #pipelineStepHelper( _ ,  MODULES | .KAuxModules ) => #processedDefintion( MODULES )

   rule <k>
           (#pipelineStepHelper( Initialization, MODULE | kmodule MODULENAME KSNTNCS endkmodule MODULES)
               =>
            #pipelineStepHelper( Initialization, (kmodule MODULENAME KSNTNCS endkmodule) MODULE | MODULES))
           ...
        </k>
        <kore>
           ...
           <modules>
           ( .Bag
              =>
             <koreModule>
               <name> MODULENAME </name>
               ...
             </koreModule>)
           </modules>
       </kore>



   syntax Set ::=   #declareSorts         ( KAuxSentences )     [function]
                  | #declareSortsSentence ( KAuxSentence  )     [function]

   rule #sortDeclaration( #processedDefintion( DEF ) ) => #pipelineStepHelper( SortsDeclaration, .KAuxModules | DEF )


   rule <k>
            (#pipelineStepHelper( SortsDeclaration, MODULE | kmodule NAME KSENTENCES endkmodule MODULES)
              =>
             #pipelineStepHelper( SortsDeclaration, kmodule NAME KSENTENCES endkmodule MODULE | MODULES))
           ...
       </k>
       <koreModule>
         <name>              NAME                              </name>
         <sortDeclarations> .Set => #declareSorts( KSENTENCES ) </sortDeclarations>
         ...
       </koreModule>

   rule #declareSorts( .KAuxSentences ) => .Set
   rule #declareSorts( KSNTNC KSNTNCS ) => #declareSortsSentence( KSNTNC ) #declareSorts( KSNTNCS )

   rule #declareSortsSentence( ksyntax( ksort ( SORTNAME:Name ), _ )) => SetItem( sort SORTNAME { .Names } [ .Patterns ])
   rule #declareSortsSentence( KS ) => .Set    [owise]

   syntax Set ::=  #declareSymbols         ( KAuxSentences , Set ) [function]
                 | #declareSymbolsSentence ( KAuxSentence , Set )  [function]

   rule #symbolDeclaration( #processedDefintion ( DEF )) => #pipelineStepHelper( SymbolsDeclaration, .KAuxModules | DEF )


   rule <k> (#pipelineStepHelper( SymbolsDeclaration, MODULE | kmodule NAME KSENTENCES endkmodule MODULES)
              =>
            #pipelineStepHelper( SymbolsDeclaration, kmodule NAME KSENTENCES endkmodule MODULE | MODULES))
           ...
       </k>
       <koreModule>
         <name>               NAME                                          </name>
         <sortDeclarations>   SORTSSET                                      </sortDeclarations>
         <symbolDeclarations> .Set => #declareSymbols(KSENTENCES, SORTSSET) </symbolDeclarations>
       </koreModule>

   rule #declareSymbols( .KAuxSentences, Set ) => .Set

   rule #declareSymbols( KSNTNC KSNTNCS, SORTSSET)
               =>
        #declareSymbolsSentence( KSNTNC, SORTSSET) #declareSymbols( KSNTNCS, SORTSSET )

   rule #declareSymbolsSentence( ksyntax( ksort( SRTNAME ) , klabel( SYMBOLNAME )) , SORTSET)
          =>
        SetItem(symbol SYMBOLNAME { .Names } ( .Sorts ) : SRTNAME [.Patterns])
           requires (sort SRTNAME { .Names } [ .Patterns] in SORTSET)

  syntax KItem        ::=  "#configurationModulesToTerm"
  syntax Declarations ::=  #toKoreSentences ( Set )     [function]

  rule #processedDefintion( DEF ) ~> #configurationDefinitionToTerm
        =>
       #configurationDefinitionToTerm ~> #processedDefintion ( DEF )

  rule <k> (#configurationDefinitionToTerm => #configurationModulesToTerm ) ... </k>
       <koreDefinition> _ => [ .Patterns ] .Modules </koreDefinition>

  // TODO (Issue): This rule doesn't handle multiple modules. Fix this rule.
  rule <k> #configurationModulesToTerm ... </k>
       <koreDefinition>
          _
            =>
          [ .Patterns ]
             `module`( MODULENAME, #toKoreSentences( SYMBOLDECLS SORTDECLS ), [ .Patterns ])
             .Modules
        </koreDefinition>
        <kore>
          ...
          <modules>
            (<koreModule>
                <name>               MODULENAME  </name>
                <sortDeclarations>   SORTDECLS   </sortDeclarations>
                <symbolDeclarations> SYMBOLDECLS </symbolDeclarations>
             </koreModule>
               =>
             .Bag)
            ...
          </modules>
        </kore>

  rule #toKoreSentences( .Set )                 => .Declarations
  rule #toKoreSentences( SetItem (DECL) DECLS ) => DECL #toKoreSentences( DECLS )

  rule <k> (#configurationModulesToTerm => .K) ... </k>
       <kore>
        ...
        <modules> .Bag </modules>
       </kore>

endmodule
