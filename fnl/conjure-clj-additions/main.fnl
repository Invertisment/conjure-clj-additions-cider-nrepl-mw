(module conjure-clj-additions.main
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge
            config conjure.config}})

(defn provide-fn! [fn-name ns f]
  (nvim.ex.command_
    (.. "-range " fn-name)
    (bridge.viml->lua ns f {})))

(defn on-filetype []
  (provide-fn! :ConjureAdditionsJumpToFailingCljTest :conjure-clj-additions.jump :jump-to-last-failing-test!)
  (provide-fn! :ConjureAdditionsRunTestsInTestNs :conjure-clj-additions.additional-fns :run-test-ns-tests!)

  (provide-fn! :ConjureAdditionsNsRemove :conjure-clj-additions.additional-fns :remove-ns!)
  (provide-fn! :ConjureAdditionsNsCleanup :conjure-clj-additions.additional-fns :cleanup-ns!)
  )

(defn init-mappings! []
  (nvim.ex.augroup :jump_to_clj_test_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," [:clojure])
    (bridge.viml->lua :conjure-clj-additions.main :on-filetype {}))
  (nvim.ex.augroup :END))

(defn init []
  (init-mappings!))
