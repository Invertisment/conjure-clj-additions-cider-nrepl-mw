(module jump-to-clj-test.main
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge}})

(defn bind! [mode keystroke fn-name ns f]
  (nvim.ex.command_
    (.. "-range " fn-name)
    (bridge.viml->lua ns f {}))
  (nvim.buf_set_keymap
    0
    "n"
    keystroke
    (.. ":" fn-name "<cr>")
    {:silent true :noremap true}))

(defn on-filetype []
  (bind! "n" "<localleader>tf" :JumpToFirstCljTest :jump-to-clj-test.core :jump-to-last-failing-test!)
  )

(defn init-mappings! []
  (nvim.ex.augroup :jump_to_clj_test_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," [:clojure])
    (bridge.viml->lua :jump-to-clj-test.main :on-filetype {}))
  (nvim.ex.augroup :END)
  )

(defn init []
  (init-mappings!))
