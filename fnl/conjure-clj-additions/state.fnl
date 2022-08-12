(module conjure-clj-additions.state)

(global unwrapped-test-results nil)

(defn put-unwrapped-test-results! [value]
  (global unwrapped-test-results value))

(defn get-unwrapped-test-results []
  unwrapped-test-results)

(global nrepl-test-middleware-present false)

(defn put-nrepl-test-middleware-present! [value]
  (global nrepl-test-middleware-present value))

(defn get-nrepl-test-middleware-present []
  nrepl-test-middleware-present)
