## Conjure additions

Provides these additional functions to bind to your wanted keys:

```
:ConjureAdditionsJumpToFailingCljTest // Jump to first failed test
:ConjureAdditionsRunTestsInTestNs     // Run tests from test ns regardless if you're in test or in main ns
:ConjureAdditionsNsRemove             // Run `remove-ns` on the current namespace
:ConjureAdditionsNsCleanup            // Clean current ns (doesn't break the ns that imports current ns)
```

It's based on [Conjure](https://github.com/Olical/conjure/) and requires it to operate (strongly coupled, parses the log output).

### `ConjureAdditionsJumpToFailingCljTest`
This function allows finding first failing test when executing tests.

Example binding:
```
autocmd FileType clojure nnoremap <silent> <localleader>tf :ConjureAdditionsJumpToFailingCljTest<CR>
```

This function allows two jumping modes:
1. When executing all namespace's tests it jumps to the namespace and the line
2. When executing single test suite via `:ConjureCljRunCurrentTest` it jumps only to the line

#### Usage (whole test namespace)
1. Run tests via `<locallleader>tn` or `<locallleader>tN` (`ConjureAdditionsRunTestsInTestNs` and `ConjureCljRunCurrentTest` both work).
2. Execute `:ConjureAdditionsJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

#### Usage (only focused test suite)
1. Run tests via `<locallleader>tc` (`ConjureAdditionsRunTestsInTestNs`).
2. Execute `:ConjureAdditionsJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

### `ConjureAdditionsRunTestsInTestNs`
With this you can run `core_test.clj` regardless whether you're located in `core.clj` or `core_test.clj`.

To bind it to `<locallleader>tn` you can do this (the first two lines change Conjure's keybinds `tn` and `tN` to NOOP):

```
let g:conjure#client#clojure#nrepl#mapping#run_alternate_ns_tests = '🇺🇦'
let g:conjure#client#clojure#nrepl#mapping#run_current_ns_tests = '🇺🇦'
autocmd FileType clojure nnoremap <silent> <localleader>tn :JumpToFirstCljTestRunTestNsTests<CR>
```

