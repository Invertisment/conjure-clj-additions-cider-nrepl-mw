## Conjure Clojure additions (run tests via nREPL)

Usage example: https://asciinema.org/a/mOpVfgCFCzvZBzANP09BqLBNY

This plugin activates nREPL test middleware when it's included into the project.
Then it allows to run tests using nREPL and jump to the first/numbered test.
It also provides some convenience functions to interact with current namespace.

To use the fully-vanilla (no test middleware) plugin you may want to look into this plugin: https://github.com/Invertisment/conjure-clj-additions-nrepl-vanilla

Provides a set of functions to jump to failing test and execute tests (functions have to be mapped manually):
1. nREPL-based test runner -- no log parsing (instant jump to test) and nicer log output (numbers to jump to, syntax highlighting) but needs nREPL dependency in the project: `https://github.com/clojure-emacs/cider-nrepl/` (personally I added it into my `~/.lein/profiles.clj` file)

Provides these additional functions:
```
:CcaNsCleanup         // Clean current ns (doesn't break the ns that imports current ns)
:CcaNsRemove          // Run `remove-ns` on the current namespace
:CcaNsJumpToAlternate // Jumps to `-test` or to regular ns depending on which one you're located in
```

It's based on [Conjure](https://github.com/Olical/conjure/) and requires it to operate (strongly coupled, parses the log output).
Mostly useful when editing Clojure.

## nREPL setup
Requires [nREPL](https://github.com/clojure-emacs/cider-nrepl/) to be added to your `:dependencies`.
You may want to add it to `.lein/profiles.clj` file so that it would be present in all projects.

These functions are provided to interact with nREPL session that will run the tests:
```
:CcaNreplLoadTestMiddleware   // Loads nREPL test middleware into the REPL (has to be done at least once per new REPL)
:CcaNreplRunTestsInTestNs     // Run tests from test ns regardless if you're in test or in main ns
:CcaNreplRunCurrentTest       // Run testsuite under the cursor
:CcaNreplJumpToFailingCljTest // Jump to first failed test
```
These functions are not compatible with Conjure config so Conjure's test execution mappings must be removed.
They work similarly to the ones on the top but the output is driven from nREPL instead of being captured by hand.

Example configuration:
```
let g:conjure#client#clojure#nrepl#mapping#run_alternate_ns_tests = '🇺🇦'
let g:conjure#client#clojure#nrepl#mapping#run_current_ns_tests = '🇺🇦'
let g:conjure#client#clojure#nrepl#mapping#run_current_test = '🇺🇦'
autocmd FileType clojure nnoremap <silent> <localleader>tn :CcaNreplRunTestsInTestNs<CR>
autocmd FileType clojure nnoremap <silent> <localleader>tf :CcaNreplJumpToFailingCljTest<CR>
autocmd FileType clojure nnoremap <silent> <localleader>tc :CcaNreplRunCurrentTest<CR>
" Not the original Conjure mapping but it's better to have it under the finger that you already pressed:
"autocmd FileType clojure nnoremap <silent> <localleader>tt :CcaNreplRunCurrentTest<CR>
```

The plugin will format+print the test output and remember the last failed tests (because nREPL middleware returns test results so it's possible to to it).

`CcaNreplJumpToFailingCljTest` also supports additional functionality to jump to nth test by typing a number before running the function.
For instance if I bind this function to `<>tf` then I could press `2<>tf` to jump to the second failed test.

When switching REPL then the old test result will be left in the cache and the jump-to-test could be wrong.
It's possible it may not rehook the test middleware as well and to do it manually execute `:CcaNreplLoadTestMiddleware`.
