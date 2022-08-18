## Conjure additions

Provides two modes to jump to failing test and execute tests (functions have to be mapped manually):
1. Conjure's original mode -- limited jumping but more basic setup and doesn't require nREPL in your `:dev` deps
1. nREPL-based test runner -- no log parsing (instant jump to test) and nicer log output (numbers to jump to, syntax highlighting) but needs nREPL dependency in the project: `https://github.com/clojure-emacs/cider-nrepl/` (personally I added it into my `~/.lein/profiles.clj` file)

Provides these additional helpers:
```
:CcaNsCleanup         // Clean current ns (doesn't break the ns that imports current ns)
:CcaNsRemove          // Run `remove-ns` on the current namespace
:CcaNsJumpToAlternate // Jumps to `-test` or to regular ns depending on which one you're located in
```

It's based on [Conjure](https://github.com/Olical/conjure/) and requires it to operate (strongly coupled, parses the log output).
Mostly useful when editing Clojure.

## Conjure-based basic tests (run tests and output to log)

You can use these functions to bind to your wanted keys:
```
:CcaRunTestsInTestNs     // Run tests from test ns regardless if you're in test or in main ns (doesn't parse exceptions)
:CcaJumpToFailingCljTest // Jump to first failed test
```

### `ccaJumpToFailingCljTest`
This function allows finding first failing test when executing tests.

Example binding:
```
autocmd FileType clojure nnoremap <silent> <localleader>tf :CcaJumpToFailingCljTest<CR>
```

This function allows two jumping modes:
1. When executing all namespace's tests it jumps to the namespace and the line
2. When executing single test suite via `:ConjureCljRunCurrentTest` it jumps only to the line

#### Usage (whole test namespace)
1. Run tests via `<locallleader>tn` or `<locallleader>tN` (`ccaRunTestsInTestNs` and `ConjureCljRunCurrentTest` both work).
2. Execute `:CcaJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

#### Usage (only focused test suite)
1. Run tests via `<locallleader>tc` (`ccaRunTestsInTestNs`).
2. Execute `:CcaJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

### `ccaRunTestsInTestNs`
With this you can run `core_test.clj` regardless whether you're located in `core.clj` or `core_test.clj`.

To bind it to `<locallleader>tn` you can do this (the first two lines change Conjure's keybinds `tn` and `tN` to NOOP):

```
let g:conjure#client#clojure#nrepl#mapping#run_alternate_ns_tests = '🇺🇦'
let g:conjure#client#clojure#nrepl#mapping#run_current_ns_tests = '🇺🇦'
autocmd FileType clojure nnoremap <silent> <localleader>tn :JumpToFirstCljTestRunTestNsTests<CR>
```

## nREPL-based tests

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

The plugin will print the test output and remember the last failed tests (because nREPL middleware does that).

`CcaNreplJumpToFailingCljTest` also supports additional functionality to jump to nth test by typing a number before running the function.
For instance if I bind this function to `<>tf` then I could press `2<>tf` to jump to the second failed test.

When switching REPL then the old test result will be left in the cache and the jump-to-test could be wrong.
It's possible it may not rehook the test middleware as well and to do it manually execute `:CcaNreplLoadTestMiddleware`.
