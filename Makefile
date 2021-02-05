all: wasm/re2.js

wasm/re2.js: wrap/re2_wrap.cc deps/re2/re2/bitstate.cc deps/re2/re2/compile.cc deps/re2/re2/dfa.cc deps/re2/re2/filtered_re2.cc deps/re2/re2/mimics_pcre.cc deps/re2/re2/nfa.cc deps/re2/re2/onepass.cc deps/re2/re2/parse.cc deps/re2/re2/perl_groups.cc deps/re2/re2/prefilter.cc deps/re2/re2/prefilter_tree.cc deps/re2/re2/prog.cc deps/re2/re2/re2.cc deps/re2/re2/regexp.cc deps/re2/re2/set.cc deps/re2/re2/simplify.cc deps/re2/re2/stringpiece.cc deps/re2/re2/tostring.cc deps/re2/re2/unicode_casefold.cc deps/re2/re2/unicode_groups.cc deps/re2/util/rune.cc deps/re2/util/strutil.cc
	mkdir -p wasm
	emcc --bind -s WASM=1 -s WASM_ASYNC_COMPILATION=0 -I deps/re2 -o wasm/re2.js wrap/re2_wrap.cc deps/re2/re2/bitstate.cc deps/re2/re2/compile.cc deps/re2/re2/dfa.cc deps/re2/re2/filtered_re2.cc deps/re2/re2/mimics_pcre.cc deps/re2/re2/nfa.cc deps/re2/re2/onepass.cc deps/re2/re2/parse.cc deps/re2/re2/perl_groups.cc deps/re2/re2/prefilter.cc deps/re2/re2/prefilter_tree.cc deps/re2/re2/prog.cc deps/re2/re2/re2.cc deps/re2/re2/regexp.cc deps/re2/re2/set.cc deps/re2/re2/simplify.cc deps/re2/re2/stringpiece.cc deps/re2/re2/tostring.cc deps/re2/re2/unicode_casefold.cc deps/re2/re2/unicode_groups.cc deps/re2/util/rune.cc deps/re2/util/strutil.cc
