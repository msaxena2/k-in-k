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

   rule #initialization( AuxDef ) => #pipelineStepHelper(Initialization, .KAuxModules | AuxDef)

   rule #pipelineStepHelper( _ ,  Ms | .KAuxModules ) => #processedDefintion( Ms )

   rule <k>
           (#pipelineStepHelper( Initialization, M | kmodule ModuleName KSntncs endkmodule Ms)
               =>
            #pipelineStepHelper( Initialization, (kmodule ModuleName KSntncs endkmodule) M | Ms))
           ...
        </k>
        <kore>
           ...
           <modules>
           ( .Bag
              =>
             <koreModule>
               <name> ModuleName </name>
               ...
             </koreModule>)
           </modules>
       </kore>



   syntax Set ::=   #declareSorts         ( KAuxSentences )     [function]
                  | #declareSortsSentence ( KAuxSentence  )     [function]

   rule #sortDeclaration( #processedDefintion( Def ) ) => #pipelineStepHelper( SortsDeclaration, .KAuxModules | Def )


   rule <k>
            (#pipelineStepHelper( SortsDeclaration, M | kmodule Name KSentences endkmodule Ms)
              =>
             #pipelineStepHelper( SortsDeclaration, kmodule Name KSentences endkmodule M | Ms))
           ...
       </k>
       <koreModule>
         <name>              Name                              </name>
         <sortDeclarations> .Set => #declareSorts (KSentences) </sortDeclarations>
         ...
       </koreModule>

   rule #declareSorts( .KAuxSentences ) => .Set
   rule #declareSorts( KSntnc KSntncs ) => #declareSortsSentence( KSntnc ) #declareSorts( KSntncs )

   rule #declareSortsSentence( ksyntax(ksort (SortName:Name), _ )) => SetItem(sort SortName { .Names } [ .Patterns ])
   rule #declareSortsSentence( KS ) => .Set    [owise]

   syntax Set ::=  #declareSymbols         ( KAuxSentences , Set ) [function]
                 | #declareSymbolsSentence ( KAuxSentence , Set )  [function]

   rule #symbolDeclaration( #processedDefintion ( Def )) => #pipelineStepHelper( SymbolsDeclaration, .KAuxModules | Def )


   rule <k> (#pipelineStepHelper( SymbolsDeclaration, M | kmodule Name KSentences endkmodule Ms)
              =>
            #pipelineStepHelper( SymbolsDeclaration, kmodule Name KSentences endkmodule M | Ms))
           ...
       </k>
       <koreModule>
         <name>               Name                                          </name>
         <sortDeclarations>   SortsSet                                      </sortDeclarations>
         <symbolDeclarations> .Set => #declareSymbols(KSentences, SortsSet) </symbolDeclarations>
       </koreModule>

   rule #declareSymbols( .KAuxSentences, Set ) => .Set

   rule #declareSymbols( KSntnc KSntncs, SortsSet)
               =>
        #declareSymbolsSentence( KSntnc, SortsSet) #declareSymbols( KSntncs, SortsSet )

   rule #declareSymbolsSentence( ksyntax( ksort( SrtName ) , klabel( SymbolName )) , SortSet)
          =>
        SetItem(symbol SymbolName { .Names } ( .Sorts ) : SrtName [.Patterns])
           requires (sort SrtName { .Names } [ .Patterns] in SortSet)

  syntax KItem        ::=  "#configurationModulesToTerm"
  syntax Declarations ::=  #toKoreSentences ( Set )     [function]

  rule #processedDefintion( Def ) ~> #configurationDefinitionToTerm
        =>
       #configurationDefinitionToTerm ~> #processedDefintion ( Def )

  rule <k> (#configurationDefinitionToTerm => #configurationModulesToTerm ) ... </k>
       <koreDefinition> _ => [ .Patterns ] .Modules </koreDefinition>

  // TODO (Issue): This rule doesn't handle multiple modules. Fix this rule.
  rule <k> #configurationModulesToTerm ... </k>
       <koreDefinition>
          _
            =>
          [ .Patterns ]
             `module`( ModuleName, #toKoreSentences( SymbolDecls SortDecls ), [ .Patterns ])
             .Modules
        </koreDefinition>
        <kore>
          ...
          <modules>
            (<koreModule>
                <name>               ModuleName  </name>
                <sortDeclarations>   SortDecls   </sortDeclarations>
                <symbolDeclarations> SymbolDecls </symbolDeclarations>
             </koreModule>
               =>
             .Bag)
            ...
          </modules>
        </kore>

  rule #toKoreSentences( .Set )                 => .Declarations
  rule #toKoreSentences( SetItem (Decl) Decls ) => Decl #toKoreSentences( Decls )

  rule <k> (#configurationModulesToTerm => .K) ... </k>
       <kore>
        ...
        <modules> .Bag </modules>
       </kore>

endmodule
