(module conjure-clj-additions.state)

(global first-failing-test-loc nil)

(defn put-first-failing-test-jump-loc! [jump-loc]
  (global first-failing-test-loc jump-loc))

(defn get-first-failing-test-jump-loc []
  first-failing-test-loc)

(global nrepl-test-middleware-present nil)

(defn put-nrepl-test-middleware-present! [value]
  (global nrepl-test-middleware-present value))

(defn get-nrepl-test-middleware-present []
  nrepl-test-middleware-present)
