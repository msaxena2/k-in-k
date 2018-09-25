module FOOBAR
  syntax Foo ::= "bar" [klabel(bar), function]
               | "buzz" [klabel(buzz)]
               | "fizz" [klabel(fizz)]
  rule bar => buzz
  rule fizz => buzz
endmodule

