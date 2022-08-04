## Jump to first Clojure test

This plugin allows finding first failing test when executing tests.

This plugin binds keystroke `<locallleader>tf` for Clojure mode. 
It also provides function `JumpToFirstCljTest`.

Based on [Conjure](https://github.com/Olical/conjure/) and requires it to operate (strongly coupled, parses the log output).

This plugin allows two jumping modes:
1. When executing all namespace's tests it jumps to the namespace and the line
2. When executing single test suite `,tt` it jumps only to the line

### Usage (whole test namespace)
1. Run tests via `<locallleader>tn` or `<locallleader>tN` (both work).
2. Press `<locallleader>tf` to jump to first failing test.
3. \*mandatory lag\*
4. Profit

### Usage (only focused test suite)
1. Run tests via `<locallleader>tt`.
2. Press `<locallleader>tf` to jump to first failing test.
3. \*mandatory lag\*
4. Profit
