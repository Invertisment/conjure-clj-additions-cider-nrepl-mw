(module conjure-clj-additions.main
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge
            config conjure.config
            fns conjure-clj-additions.additional-fns}})

(defn provide-fn! [fn-name ns f]
  (nvim.ex.command_
    (.. "-range " fn-name)
    (bridge.viml->lua ns f {})))

(defn on-filetype []
  ;; log-parsing functions (based on original way Conjure does things on its own)
  (provide-fn! :CcaRunTestsInTestNs :conjure-clj-additions.additional-fns :run-test-ns-tests!)
  (provide-fn! :CcaJumpToFailingCljTest :conjure-clj-additions.additional-fns :jump-to-first-failing!)

  ;; nrepl-based functions
  (provide-fn! :CcaNreplRunTestsInTestNs :conjure-clj-additions.additional-fns :nrepl-middleware-run-test-ns-tests!)
  (provide-fn! :CcaNreplRunCurrentTest :conjure-clj-additions.additional-fns :nrepl-run-current-test!)
  (provide-fn! :CcaNreplJumpToFailingCljTest :conjure-clj-additions.additional-fns :nrepl-jump-to-nth-failing!)
  ;todo (provide-fn! :ConjureAdditionsRunTestsRetest :conjure-clj-additions.additional-fns :retest!)

  ;; util
  (provide-fn! :CcaNsRemove :conjure-clj-additions.additional-fns :remove-ns!)
  (provide-fn! :CcaNsCleanup :conjure-clj-additions.additional-fns :cleanup-ns!)
  )

(defn init-mappings! []
  (nvim.ex.augroup :jump_to_clj_test_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," [:clojure])
    (bridge.viml->lua :conjure-clj-additions.main :on-filetype {}))
  (nvim.ex.augroup :END))

(defn init []
  (fns.load-test-middleware!)
  (init-mappings!))
