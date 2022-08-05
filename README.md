## Conjure additions

Provides these additional functions to bind to your wanted keys:

```
ConjureAdditionsJumpToFailingCljTest // Jump to first failed test
ConjureAdditionsRunTestsInTestNs     // Run tests regardless if you're in test or not in test ns
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
2. When executing single test suite via `<localleader>tc` it jumps only to the line

#### Usage (whole test namespace)
1. Run tests via `<locallleader>tn` or `<locallleader>tN` (both work).
2. Execute `ConjureAdditionsJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

#### Usage (only focused test suite)
1. Run tests via `<locallleader>tt`.
2. Execute `ConjureAdditionsJumpToFailingCljTest` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

### `ConjureAdditionsRunTestsInTestNs`
With this you can run `core_test.clj` regardless whether you're located in `core.clj` or `core_test.clj`.

To bind it to `<>tn` you can do this (it also moves `<>tn` and `<>tN` bindings):

```
let g:conjure#client#clojure#nrepl#mapping#run_alternate_ns_tests = '💩'
let g:conjure#client#clojure#nrepl#mapping#run_current_ns_tests = '💩'
autocmd FileType clojure nnoremap <silent> <localleader>tn :JumpToFirstCljTestRunTestNsTests<CR>
```

