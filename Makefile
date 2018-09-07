.DEFAULT_GOAL := test

generate-kore: syntax-k/foobar.k
	kompile --directory .build syntax-k/foobar.k --backend kore --syntax-module FOOBAR && mv .build/foobar.kore syntax-kore

tests/%.foobar.kore: tests/%.foobar syntax-kore/foobar.kore
	kast --directory .build --kore $< > $<.kore

tests/%.output: tests/%.foobar.kore syntax-kore/foobar.kore
	stack exec -- kore-exec syntax-kore/foobar.kore --module FOOBAR --pattern $< > $@

%.korun: %.output
	cat $<

tests/%.test: tests/%.output
	diff $< $<.expected

test: tests/bar.test tests/buzz.test

.PHONY: clean

clean:
	rm -rf tests/*.foobar.kore tests/*.output

