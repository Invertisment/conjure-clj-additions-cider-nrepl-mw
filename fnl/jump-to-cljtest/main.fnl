(module jump-to-cljtest.main
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge
            config conjure.config
            }})

(defn provide-fn! [fn-name ns f]
  (nvim.ex.command_
    (.. "-range " fn-name)
    (bridge.viml->lua ns f {})))

(defn bind! [mode keystroke fn-name ns f]
  (provide-fn! fn-name ns f)
  (nvim.buf_set_keymap
    0
    mode
    keystroke
    (.. ":" fn-name "<cr>")
    {:silent true :noremap true}))

(defn on-filetype []
  (bind! "n" "<localleader>tf" :JumpToFirstCljTest :jump-to-cljtest.jump :jump-to-last-failing-test!)
  (provide-fn! :JumpToFirstCljTestRunTestNsTests :jump-to-cljtest.additional-fns :run-test-ns-tests!)
  )

(defn init-mappings! []
  (nvim.ex.augroup :jump_to_clj_test_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," [:clojure])
    (bridge.viml->lua :jump-to-cljtest.main :on-filetype {}))
  (nvim.ex.augroup :END)
  )

(defn init []
  (init-mappings!))

