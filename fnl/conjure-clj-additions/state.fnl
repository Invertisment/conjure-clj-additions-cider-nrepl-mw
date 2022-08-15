(module conjure-clj-additions.state)

(global unwrapped-test-results nil)

(defn put-unwrapped-test-results! [value]
  (global unwrapped-test-results value))

(defn get-unwrapped-test-results []
  unwrapped-test-results)
